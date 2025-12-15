`timescale 1ns / 1ps

//=============================================================================
// TRAFFIC LIGHT CONTROL - 4-Way Intersection Controller
//=============================================================================
// Features:
// - Automatic mode: Sequential N→E→S→W cycle with configurable timing
// - Manual mode: Direct control (sequential or parallel)
// - Safe transitions: All-red periods between direction changes
// - Yellow transition: Smooth manual→auto mode switching
//=============================================================================

module traffic_light_control (
    // Clock and reset
    input  wire        clk,
    input  wire        rst,

    // Control inputs
    input  wire [15:0] switches,
    input  wire [7:0]  n_duration,   // Configurable timing (seconds)
    input  wire [7:0]  s_duration,
    input  wire [7:0]  w_duration,
    input  wire [7:0]  e_duration,
    input  wire [7:0]  yellow_duration,
    input  wire [7:0]  red_holding,

    // North direction lights
    output wire        N_red,
    output wire        N_yellow,
    output wire        N_green,

    // East direction lights
    output wire        E_red,
    output wire        E_yellow,
    output wire        E_green,

    // South direction lights
    output wire        S_red,
    output wire        S_yellow,
    output wire        S_green,

    // West direction lights
    output wire        W_red,
    output wire        W_yellow,
    output wire        W_green,

    // Status outputs
    output wire [7:0]  countdown_sec,    // Time remaining in current state
    output wire [1:0]  active_direction, // 0=N, 1=E, 2=S, 3=W
    output wire        manual_yellow_transition,  // Status flag for transition
    output wire        show_countdown,    // 1=show countdown, 0=hide in pure manual
    output reg [7:0]   yellow_light_count // Count of yellow light occurrences
);

    //=========================================================================
    // PARAMETERS AND CONSTANTS
    //=========================================================================
    localparam CLK_FREQ = 100_000_000;  // 100 MHz system clock

    // Direction encodings
    localparam DIR_NORTH = 2'd0;
    localparam DIR_EAST  = 2'd1;
    localparam DIR_SOUTH = 2'd2;
    localparam DIR_WEST  = 2'd3;

    // State machine states (3 states per direction: GREEN, YELLOW, ALL_RED)
    localparam [3:0]
        ST_N_GREEN    = 4'd0,
        ST_N_YELLOW   = 4'd1,
        ST_N_RED      = 4'd2,
        ST_E_GREEN    = 4'd3,
        ST_E_YELLOW   = 4'd4,
        ST_E_RED      = 4'd5,
        ST_S_GREEN    = 4'd6,
        ST_S_YELLOW   = 4'd7,
        ST_S_RED      = 4'd8,
        ST_W_GREEN    = 4'd9,
        ST_W_YELLOW   = 4'd10,
        ST_W_RED      = 4'd11,
        ST_TRANSITION = 4'd12;  // Special state for manual→auto transition

    //=========================================================================
    // SWITCH DECODING
    //=========================================================================
    wire mode_manual      = switches[0];    // 0=Auto, 1=Manual
    wire mode_parallel    = switches[1];    // Manual: 0=Sequential, 1=Parallel
    wire sw_north         = switches[2];    // North or N+S control
    wire sw_east          = switches[3];    // East or E+W control
    wire sw_south         = switches[4];    // South control
    wire sw_west          = switches[5];    // West control

    //=========================================================================
    // INTERNAL REGISTERS
    //=========================================================================
    reg [3:0]  current_state;
    reg [3:0]  next_state;
    reg [31:0] cycle_counter;       // Clock cycles elapsed in current state
    reg [31:0] cycle_duration;      // Total cycles for current state
    reg        prev_mode_manual;    // Previous mode for edge detection

    // Mode transition control
    reg        manual_mode_pending;  // Manual mode requested, waiting for safe transition
    reg [3:0]  green_snapshot;       // Snapshot of which lights were green at manual→auto
    reg [1:0]  last_auto_direction;  // Last direction in auto mode (for smooth transition)

    // Manual mode transition control
    reg prev_sw_north, prev_sw_east, prev_sw_south, prev_sw_west;
    reg [1:0]  manual_state;
    localparam MANUAL_IDLE = 2'd0;
    localparam MANUAL_YELLOW = 2'd1;
    reg [31:0] manual_timer;
    reg [3:0]  manual_yellow_lights;

    reg [7:0] yellow_light_counter; // Counter for yellow light occurrences

    // Internal light control registers
    reg [3:0]  red_lights;          // {W, S, E, N}
    reg [3:0]  yellow_lights;
    reg [3:0]  green_lights;

    //=========================================================================
    // TIMING CALCULATIONS
    //=========================================================================
    wire [31:0] cycles_n_green = n_duration * CLK_FREQ;
    wire [31:0] cycles_s_green = s_duration * CLK_FREQ;
    wire [31:0] cycles_w_green = w_duration * CLK_FREQ;
    wire [31:0] cycles_e_green = e_duration * CLK_FREQ;
    wire [31:0] cycles_yellow = yellow_duration * CLK_FREQ;
    wire [31:0] cycles_red    = red_holding     * CLK_FREQ;

    // State duration lookup
    always @(*) begin
        case (current_state)
            ST_N_GREEN:
                cycle_duration = cycles_n_green;
            ST_E_GREEN:
                cycle_duration = cycles_e_green;
            ST_S_GREEN:
                cycle_duration = cycles_s_green;
            ST_W_GREEN:
                cycle_duration = cycles_w_green;
            ST_N_YELLOW, ST_E_YELLOW, ST_S_YELLOW, ST_W_YELLOW:
                cycle_duration = cycles_yellow;
            ST_N_RED, ST_E_RED, ST_S_RED, ST_W_RED:
                cycle_duration = cycles_red;
            ST_TRANSITION:
                cycle_duration = cycles_yellow;
            default:
                cycle_duration = cycles_n_green;
        endcase
    end

    //=========================================================================
    // MODE TRANSITION DETECTION
    //=========================================================================
    wire auto_to_manual_request = mode_manual && !prev_mode_manual;
    wire manual_to_auto_request = !mode_manual && prev_mode_manual;

    // Falling edge detection for manual switches
    wire north_off = prev_sw_north && !sw_north;
    wire east_off  = prev_sw_east  && !sw_east;
    wire south_off = prev_sw_south && !sw_south;
    wire west_off  = prev_sw_west  && !sw_west;

    //=========================================================================
    // STATE MACHINE - Sequential Logic
    //=========================================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state       <= ST_N_GREEN;
            cycle_counter       <= 0;
            // Initialize based on current switch state
            prev_mode_manual    <= mode_manual;
            manual_mode_pending <= 0;
            green_snapshot      <= 4'b0000;
            last_auto_direction <= DIR_NORTH;
            manual_state        <= MANUAL_IDLE;
            manual_timer        <= 0;
            manual_yellow_lights<= 4'b0;
            prev_sw_north       <= sw_north;
            prev_sw_east        <= sw_east;
            prev_sw_south       <= sw_south;
            prev_sw_west        <= sw_west;
            yellow_light_counter<= 8'd0; // Initialize counter
        end else begin
            // Track mode changes
            prev_mode_manual <= mode_manual;

            // Previous switch states for manual mode
            prev_sw_north <= sw_north;
            prev_sw_east  <= sw_east;
            prev_sw_south <= sw_south;
            prev_sw_west  <= sw_west;

            if (!mode_manual) begin
                //=============================================================
                // AUTOMATIC MODE
                //=============================================================
                manual_state <= MANUAL_IDLE; // Reset manual FSM when in auto mode

                // Track current direction in auto mode
                case (current_state)
                    ST_N_GREEN, ST_N_YELLOW, ST_N_RED, ST_TRANSITION:
                        last_auto_direction <= DIR_NORTH;
                    ST_E_GREEN, ST_E_YELLOW, ST_E_RED:
                        last_auto_direction <= DIR_EAST;
                    ST_S_GREEN, ST_S_YELLOW, ST_S_RED:
                        last_auto_direction <= DIR_SOUTH;
                    ST_W_GREEN, ST_W_YELLOW, ST_W_RED:
                        last_auto_direction <= DIR_WEST;
                endcase

                // Check for manual→auto transition request
                if (manual_to_auto_request) begin
                    // Capture which lights are currently green in manual mode
                    green_snapshot <= green_lights;
                    current_state  <= ST_TRANSITION;
                    cycle_counter  <= 0;
                    yellow_light_counter <= yellow_light_counter + 1; // Increment yellow light count
                end
                // Normal state progression
                else if (cycle_counter >= cycle_duration - 1) begin
                    current_state <= next_state;
                    cycle_counter <= 0;
                    if (next_state == ST_N_YELLOW || next_state == ST_E_YELLOW ||
                        next_state == ST_S_YELLOW || next_state == ST_W_YELLOW) begin
                        yellow_light_counter <= yellow_light_counter + 1; // Increment yellow light count
                    end
                end else begin
                    cycle_counter <= cycle_counter + 1;
                end

            end else begin
                //=============================================================
                // MANUAL MODE (or transitioning from AUTO→MANUAL)
                //=============================================================

                // Manual mode state machine
                case(manual_state)
                    MANUAL_IDLE: begin
                        if (!mode_parallel) begin // Sequential manual mode
                            if (north_off) begin
                                manual_state <= MANUAL_YELLOW;
                                manual_yellow_lights <= 4'b0001;
                                manual_timer <= 0;
                                yellow_light_counter <= yellow_light_counter + 1; // Increment yellow light count
                            end else if (east_off) begin
                                manual_state <= MANUAL_YELLOW;
                                manual_yellow_lights <= 4'b0010;
                                manual_timer <= 0;
                                yellow_light_counter <= yellow_light_counter + 1; // Increment yellow light count
                            end else if (south_off) begin
                                manual_state <= MANUAL_YELLOW;
                                manual_yellow_lights <= 4'b0100;
                                manual_timer <= 0;
                                yellow_light_counter <= yellow_light_counter + 1; // Increment yellow light count
                            end else if (west_off) begin
                                manual_state <= MANUAL_YELLOW;
                                manual_yellow_lights <= 4'b1000;
                                manual_timer <= 0;
                                yellow_light_counter <= yellow_light_counter + 1; // Increment yellow light count
                            end
                        end else begin // Parallel manual mode
                            if (north_off) begin // N+S were on
                                manual_state <= MANUAL_YELLOW;
                                manual_yellow_lights <= 4'b0101; // N and S yellow
                                manual_timer <= 0;
                                yellow_light_counter <= yellow_light_counter + 1; // Increment yellow light count
                            end else if (east_off) begin // E+W were on
                                manual_state <= MANUAL_YELLOW;
                                manual_yellow_lights <= 4'b1010; // E and W yellow
                                manual_timer <= 0;
                                yellow_light_counter <= yellow_light_counter + 1; // Increment yellow light count
                            end
                        end
                    end
                    MANUAL_YELLOW: begin
                        if(manual_timer >= cycles_yellow - 1) begin
                            manual_state <= MANUAL_IDLE;
                            manual_timer <= 0;
                        end else begin
                            manual_timer <= manual_timer + 1;
                        end
                    end
                endcase

                if (manual_mode_pending) begin
                    // Finishing current AUTO cycle before giving manual control
                    if (cycle_counter >= cycle_duration - 1) begin
                        current_state <= next_state;
                        cycle_counter <= 0;

                        // Check if we've reached an ALL_RED state (safe to switch)
                        if (next_state == ST_N_RED || next_state == ST_E_RED ||
                            next_state == ST_S_RED || next_state == ST_W_RED) begin
                            // Safe to switch to manual now
                            manual_mode_pending <= 0;
                        end
                    end else begin
                        cycle_counter <= cycle_counter + 1;
                    end

                end else begin
                    // Check for auto→manual transition request
                    if (auto_to_manual_request) begin
                        // User wants to switch to manual - set pending flag
                        manual_mode_pending <= 1;
                        // Keep current state and continue countdown
                    end else begin
                        // Pure manual mode - hold in initial state
                        current_state       <= ST_N_GREEN;
                        cycle_counter       <= 0;
                    end
                end
            end
        end
    end

    //=========================================================================
    // STATE MACHINE - Next State Logic
    //=========================================================================
    always @(*) begin
        case (current_state)
            // North sequence
            ST_N_GREEN:    next_state = ST_N_YELLOW;
            ST_N_YELLOW:   next_state = ST_N_RED;
            ST_N_RED:      next_state = ST_E_GREEN;

            // East sequence
            ST_E_GREEN:    next_state = ST_E_YELLOW;
            ST_E_YELLOW:   next_state = ST_E_RED;
            ST_E_RED:      next_state = ST_S_GREEN;

            // South sequence
            ST_S_GREEN:    next_state = ST_S_YELLOW;
            ST_S_YELLOW:   next_state = ST_S_RED;
            ST_S_RED:      next_state = ST_W_GREEN;

            // West sequence
            ST_W_GREEN:    next_state = ST_W_YELLOW;
            ST_W_YELLOW:   next_state = ST_W_RED;
            ST_W_RED:      next_state = ST_N_GREEN;  // Loop back to North

            // Transition state
            ST_TRANSITION: next_state = ST_N_GREEN;

            default:       next_state = ST_N_GREEN;
        endcase
    end

    //=========================================================================
    // OUTPUT LOGIC - Traffic Lights
    //=========================================================================
    always @(*) begin
        if (!mode_manual) begin
            //=================================================================
            // AUTOMATIC MODE
            //=================================================================
            // Default: all red (safety first)
            red_lights    = 4'b1111;
            yellow_lights = 4'b0000;
            green_lights  = 4'b0000;

            // Transition state: selective yellow
            // Only lights that were GREEN turn yellow, RED stays red
            if (current_state == ST_TRANSITION) begin
                yellow_lights = green_snapshot;     // Turn green→yellow
                red_lights    = ~green_snapshot;    // Keep others red
            end
            // Normal operation: set lights based on state
            else begin
                case (current_state)
                    // North
                    ST_N_GREEN: begin
                        red_lights[0]   = 0;
                        green_lights[0] = 1;
                    end
                    ST_N_YELLOW: begin
                        red_lights[0]    = 0;
                        yellow_lights[0] = 1;
                    end

                    // East
                    ST_E_GREEN: begin
                        red_lights[1]   = 0;
                        green_lights[1] = 1;
                    end
                    ST_E_YELLOW: begin
                        red_lights[1]    = 0;
                        yellow_lights[1] = 1;
                    end

                    // South
                    ST_S_GREEN: begin
                        red_lights[2]   = 0;
                        green_lights[2] = 1;
                    end
                    ST_S_YELLOW: begin
                        red_lights[2]    = 0;
                        yellow_lights[2] = 1;
                    end

                    // West
                    ST_W_GREEN: begin
                        red_lights[3]   = 0;
                        green_lights[3] = 1;
                    end
                    ST_W_YELLOW: begin
                        red_lights[3]    = 0;
                        yellow_lights[3] = 1;
                    end

                    // All RED states: keep defaults
                endcase
            end

        end else if (manual_mode_pending) begin
            //=================================================================
            // MANUAL MODE REQUESTED (but finishing AUTO cycle first)
            //=================================================================
            // Continue showing automatic mode lights until safe to switch
            // Default: all red (safety first)
            red_lights    = 4'b1111;
            yellow_lights = 4'b0000;
            green_lights  = 4'b0000;

            case (current_state)
                // North
                ST_N_GREEN: begin
                    red_lights[0]   = 0;
                    green_lights[0] = 1;
                end
                ST_N_YELLOW: begin
                    red_lights[0]    = 0;
                    yellow_lights[0] = 1;
                end

                // East
                ST_E_GREEN: begin
                    red_lights[1]   = 0;
                    green_lights[1] = 1;
                end
                ST_E_YELLOW: begin
                    red_lights[1]    = 0;
                    yellow_lights[1] = 1;
                end

                // South
                ST_S_GREEN: begin
                    red_lights[2]   = 0;
                    green_lights[2] = 1;
                end
                ST_S_YELLOW: begin
                    red_lights[2]    = 0;
                    yellow_lights[2] = 1;
                end

                // West
                ST_W_GREEN: begin
                    red_lights[3]   = 0;
                    green_lights[3] = 1;
                end
                ST_W_YELLOW: begin
                    red_lights[3]    = 0;
                    yellow_lights[3] = 1;
                end

                // All RED states: keep defaults
            endcase

        end else begin
            //=================================================================
            // MANUAL MODE
            //=================================================================
            if (manual_state == MANUAL_YELLOW) begin
                red_lights    = ~manual_yellow_lights;
                yellow_lights = manual_yellow_lights;
                green_lights  = 4'b0;
            end else begin
                // Default: all red (safety first)
                red_lights    = 4'b1111;
                yellow_lights = 4'b0000;
                green_lights  = 4'b0000;

                if (!mode_parallel) begin
                    //=============================================================
                    // Sequential: One direction at a time
                    //=============================================================
                    if (sw_north) begin
                        red_lights[0]   = 0;
                        green_lights[0] = 1;
                    end else if (sw_east) begin
                        red_lights[1]   = 0;
                        green_lights[1] = 1;
                    end else if (sw_south) begin
                        red_lights[2]   = 0;
                        green_lights[2] = 1;
                    end else if (sw_west) begin
                        red_lights[3]   = 0;
                        green_lights[3] = 1;
                    end

                end else begin
                    //=============================================================
                    // Parallel: N+S or E+W pairs
                    //=============================================================
                    if (sw_north && !sw_east) begin
                        // North + South green
                        red_lights[0]   = 0;
                        green_lights[0] = 1;
                        red_lights[2]   = 0;
                        green_lights[2] = 1;
                    end else if (sw_east && !sw_north) begin
                        // East + West green
                        red_lights[1]   = 0;
                        green_lights[1] = 1;
                        red_lights[3]   = 0;
                        green_lights[3] = 1;
                    end
                    // If both or neither: stay all red (safety)
                end
            end
        end
    end

    //=========================================================================
    // OUTPUT LOGIC - Active Direction
    //=========================================================================
    reg [1:0] active_dir;

    always @(*) begin
        if (!mode_manual) begin
            // Automatic mode: based on state
            case (current_state)
                ST_N_GREEN, ST_N_YELLOW, ST_N_RED, ST_TRANSITION:
                    active_dir = DIR_NORTH;
                ST_E_GREEN, ST_E_YELLOW, ST_E_RED:
                    active_dir = DIR_EAST;
                ST_S_GREEN, ST_S_YELLOW, ST_S_RED:
                    active_dir = DIR_SOUTH;
                ST_W_GREEN, ST_W_YELLOW, ST_W_RED:
                    active_dir = DIR_WEST;
                default:
                    active_dir = DIR_NORTH;
            endcase
        end else if (manual_mode_pending) begin
            // Finishing auto cycle - keep showing last auto direction
            active_dir = last_auto_direction;
        end else begin
            // Pure manual mode: based on which light is green
            if (!mode_parallel) begin
                // Sequential
                if (sw_north)      active_dir = DIR_NORTH;
                else if (sw_east)  active_dir = DIR_EAST;
                else if (sw_south) active_dir = DIR_SOUTH;
                else if (sw_west)  active_dir = DIR_WEST;
                else               active_dir = DIR_NORTH;
            end else begin
                // Parallel
                if (sw_north)      active_dir = DIR_NORTH;  // Represents N+S
                else if (sw_east)  active_dir = DIR_EAST;   // Represents E+W
                else               active_dir = DIR_NORTH;
            end
        end
    end

    assign active_direction = active_dir;

    //=========================================================================
    // OUTPUT LOGIC - Countdown Timer
    //=========================================================================
    wire [31:0] cycles_remaining = (cycle_duration > cycle_counter) ?
                                   (cycle_duration - cycle_counter) : 32'd0;
    wire [31:0] seconds_remaining = cycles_remaining / CLK_FREQ;

    assign countdown_sec = (seconds_remaining > 255) ? 8'd255 : seconds_remaining[7:0];

    //=========================================================================
    // OUTPUT ASSIGNMENTS
    //=========================================================================
    // Map internal vectors to individual output signals
    assign N_red    = red_lights[0];
    assign N_yellow = yellow_lights[0];
    assign N_green  = green_lights[0];

    assign E_red    = red_lights[1];
    assign E_yellow = yellow_lights[1];
    assign E_green  = green_lights[1];

    assign S_red    = red_lights[2];
    assign S_yellow = yellow_lights[2];
    assign S_green  = green_lights[2];

    assign W_red    = red_lights[3];
    assign W_yellow = yellow_lights[3];
    assign W_green  = green_lights[3];

    // Transition status indicator
    assign manual_yellow_transition = (current_state == ST_TRANSITION);

    // Show countdown in auto mode OR during transition, hide in pure manual
    assign show_countdown = !mode_manual || manual_mode_pending;

endmodule
