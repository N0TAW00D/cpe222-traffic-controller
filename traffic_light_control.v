`timescale 1ns / 1ps

module traffic_light_control(
    input wire clk,
    input wire rst,
    input wire [15:0] switches,
    input wire [7:0] green_duration,   // From menu controller (in seconds)
    input wire [7:0] yellow_duration,  // From menu controller (in seconds)
    input wire [7:0] red_holding,      // From menu controller (in seconds)

    // North direction lights
    output reg N_red,
    output reg N_yellow,
    output reg N_green,

    // East direction lights
    output reg E_red,
    output reg E_yellow,
    output reg E_green,

    // South direction lights
    output reg S_red,
    output reg S_yellow,
    output reg S_green,

    // West direction lights
    output reg W_red,
    output reg W_yellow,
    output reg W_green,

    // Countdown timer (remaining seconds)
    output wire [7:0] countdown_sec,

    // Current active direction (for display purposes)
    // 2'b00 = North, 2'b01 = East, 2'b10 = South, 2'b11 = West
    output wire [1:0] active_direction
);

    // =======================================================================
    // CLOCK FREQUENCY PARAMETER
    // =======================================================================
    parameter CLK_FREQ = 100_000_000;  // 100MHz clock frequency

    // =======================================================================
    // STATE MACHINE DEFINITIONS
    // CHECK LOGIC - FSM state sequence (currently N->E->S->W)
    // =======================================================================
    localparam STATE_N_GREEN   = 4'd0;
    localparam STATE_N_YELLOW  = 4'd1;
    localparam STATE_ALL_RED1  = 4'd2;
    localparam STATE_E_GREEN   = 4'd3;
    localparam STATE_E_YELLOW  = 4'd4;
    localparam STATE_ALL_RED2  = 4'd5;
    localparam STATE_S_GREEN   = 4'd6;
    localparam STATE_S_YELLOW  = 4'd7;
    localparam STATE_ALL_RED3  = 4'd8;
    localparam STATE_W_GREEN   = 4'd9;
    localparam STATE_W_YELLOW  = 4'd10;
    localparam STATE_ALL_RED4  = 4'd11;

    // =======================================================================
    // INTERNAL REGISTERS
    // =======================================================================
    reg [3:0] state, next_state;
    reg [31:0] timer;
    reg [31:0] duration;
    reg prev_mode_auto;           // To detect mode transition
    reg [1:0] transition_state;   // 0=normal, 1=yellow, 2=red
    reg [1:0] transition_direction; // Which direction was green in manual mode

    // CHECK LOGIC - Switch assignments for mode and direction control
    // Switch decoding
    wire mode_auto;       // 0 = auto, 1 = manual
    wire manual_parallel; // 0 = sequential, 1 = parallel
    wire sw_N, sw_E, sw_S, sw_W;
    wire sw_NS, sw_EW;

    assign mode_auto       = ~switches[0];  // Switch[0]: 0=auto, 1=manual
    assign manual_parallel = switches[1];   // Switch[1]: 0=sequential, 1=parallel
    assign sw_N            = switches[2];   // Switch[2]: North control
    assign sw_E            = switches[3];   // Switch[3]: East control
    assign sw_S            = switches[4];   // Switch[4]: South control
    assign sw_W            = switches[5];   // Switch[5]: West control
    assign sw_NS           = switches[2];   // Switch[2]: North+South pair
    assign sw_EW           = switches[3];   // Switch[3]: East+West pair

    // Detect manual to auto transition (0->1 in mode_auto means switch[0] went 1->0)
    wire manual_to_auto_transition = mode_auto && !prev_mode_auto;

    // =======================================================================
    // STATE MACHINE - Sequential Logic
    // =======================================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= STATE_N_GREEN;
            timer <= 0;
            prev_mode_auto <= 0;
            transition_state <= 0;
            transition_direction <= 2'b00;
        end else begin
            // Update previous mode
            prev_mode_auto <= mode_auto;

            if (mode_auto) begin
                // Check if we just transitioned from manual to auto
                if (manual_to_auto_transition) begin
                    // Capture which direction had green in manual mode
                    if (manual_parallel) begin
                        transition_direction <= sw_NS ? 2'b00 : (sw_EW ? 2'b01 : 2'b00);
                    end else begin
                        if (sw_N) transition_direction <= 2'b00;
                        else if (sw_E) transition_direction <= 2'b01;
                        else if (sw_S) transition_direction <= 2'b10;
                        else if (sw_W) transition_direction <= 2'b11;
                        else transition_direction <= 2'b00;
                    end
                    // Start yellow transition
                    transition_state <= 2'd1;
                    timer <= 0;
                end else if (transition_state != 0) begin
                    // We're transitioning from manual to auto
                    if (timer >= duration - 1) begin
                        if (transition_state == 2'd1) begin
                            // Yellow complete, go to red
                            transition_state <= 2'd2;
                            timer <= 0;
                        end else if (transition_state == 2'd2) begin
                            // Red complete, enter normal FSM
                            transition_state <= 0;
                            state <= STATE_N_GREEN;
                            timer <= 0;
                        end
                    end else begin
                        timer <= timer + 1;
                    end
                end else begin
                    // Normal automatic mode FSM operation
                    if (timer >= duration - 1) begin
                        state <= next_state;
                        timer <= 0;
                    end else begin
                        timer <= timer + 1;
                    end
                end
            end else begin
                // Manual mode - stay in current state, reset timer
                state <= STATE_N_GREEN;  // Default state for manual mode
                timer <= 0;
                transition_state <= 0;
            end
        end
    end

    // =======================================================================
    // STATE MACHINE - Next State and Duration Logic
    // CHECK LOGIC - State transition sequence and timing durations
    // =======================================================================
    // Convert seconds to clock cycles
    wire [31:0] green_cycles = green_duration * CLK_FREQ;
    wire [31:0] yellow_cycles = yellow_duration * CLK_FREQ;
    wire [31:0] red_cycles = red_holding * CLK_FREQ;

    always @(*) begin
        // Handle transition state durations
        if (transition_state == 2'd1) begin
            duration = yellow_cycles;  // Yellow transition
            next_state = STATE_N_GREEN;
        end else if (transition_state == 2'd2) begin
            duration = red_cycles;     // Red transition
            next_state = STATE_N_GREEN;
        end else begin
            // CHECK LOGIC - Normal FSM state transitions (modify sequence here)
            // Normal FSM operation
            case (state)
                STATE_N_GREEN: begin
                    duration = green_cycles;
                    next_state = STATE_N_YELLOW;
                end
                STATE_N_YELLOW: begin
                    duration = yellow_cycles;
                    next_state = STATE_ALL_RED1;
                end
                STATE_ALL_RED1: begin
                    duration = red_cycles;
                    next_state = STATE_E_GREEN;
                end
                STATE_E_GREEN: begin
                    duration = green_cycles;
                    next_state = STATE_E_YELLOW;
                end
                STATE_E_YELLOW: begin
                    duration = yellow_cycles;
                    next_state = STATE_ALL_RED2;
                end
                STATE_ALL_RED2: begin
                    duration = red_cycles;
                    next_state = STATE_S_GREEN;
                end
                STATE_S_GREEN: begin
                    duration = green_cycles;
                    next_state = STATE_S_YELLOW;
                end
                STATE_S_YELLOW: begin
                    duration = yellow_cycles;
                    next_state = STATE_ALL_RED3;
                end
                STATE_ALL_RED3: begin
                    duration = red_cycles;
                    next_state = STATE_W_GREEN;
                end
                STATE_W_GREEN: begin
                    duration = green_cycles;
                    next_state = STATE_W_YELLOW;
                end
                STATE_W_YELLOW: begin
                    duration = yellow_cycles;
                    next_state = STATE_ALL_RED4;
                end
                STATE_ALL_RED4: begin
                    duration = red_cycles;
                    next_state = STATE_N_GREEN;
                end
                default: begin
                    duration = green_cycles;
                    next_state = STATE_N_GREEN;
                end
            endcase
        end
    end

    // =======================================================================
    // COUNTDOWN TIMER CALCULATION
    // =======================================================================
    // Calculate remaining seconds: (duration - timer) / CLK_FREQ
    wire [31:0] remaining_cycles = (duration > timer) ? (duration - timer) : 32'd0;
    wire [31:0] remaining_seconds = remaining_cycles / CLK_FREQ;
    assign countdown_sec = (remaining_seconds > 255) ? 8'd255 : remaining_seconds[7:0];

    // =======================================================================
    // ACTIVE DIRECTION OUTPUT
    // CHECK LOGIC - Direction encoding for countdown display
    // =======================================================================
    // Determine which direction is currently active
    // 2'b00 = North, 2'b01 = East, 2'b10 = South, 2'b11 = West
    reg [1:0] active_dir;
    always @(*) begin
        if (mode_auto) begin
            // Check if in transition
            if (transition_state != 0) begin
                // Use the transition direction
                active_dir = transition_direction;
            end else begin
                // CHECK LOGIC - Map states to active directions
                case (state)
                    STATE_N_GREEN, STATE_N_YELLOW, STATE_ALL_RED1:
                        active_dir = 2'b00;  // North
                    STATE_E_GREEN, STATE_E_YELLOW, STATE_ALL_RED2:
                        active_dir = 2'b01;  // East
                    STATE_S_GREEN, STATE_S_YELLOW, STATE_ALL_RED3:
                        active_dir = 2'b10;  // South
                    STATE_W_GREEN, STATE_W_YELLOW, STATE_ALL_RED4:
                        active_dir = 2'b11;  // West
                    default:
                        active_dir = 2'b00;  // Default to North
                endcase
            end
        end else begin
            // CHECK LOGIC - Manual mode direction selection
            // Manual mode - determine based on which light is green
            if (manual_parallel) begin
                if (sw_NS) active_dir = 2'b00;  // North (representing N+S)
                else if (sw_EW) active_dir = 2'b01;  // East (representing E+W)
                else active_dir = 2'b00;
            end else begin
                if (sw_N) active_dir = 2'b00;  // North
                else if (sw_E) active_dir = 2'b01;  // East
                else if (sw_S) active_dir = 2'b10;  // South
                else if (sw_W) active_dir = 2'b11;  // West
                else active_dir = 2'b00;
            end
        end
    end
    assign active_direction = active_dir;

    // =======================================================================
    // OUTPUT LOGIC
    // CHECK LOGIC - Light color outputs for each direction
    // =======================================================================
    always @(*) begin
        if (mode_auto) begin
            // CHECK LOGIC - Automatic mode light control
            // ===== AUTOMATIC MODE =====
            // Default all lights to red
            N_red = 1; N_yellow = 0; N_green = 0;
            E_red = 1; E_yellow = 0; E_green = 0;
            S_red = 1; S_yellow = 0; S_green = 0;
            W_red = 1; W_yellow = 0; W_green = 0;

            // Check if in transition from manual to auto
            if (transition_state == 2'd1) begin
                // Yellow transition - show yellow for the direction that had green
                case (transition_direction)
                    2'b00: begin N_red = 0; N_yellow = 1; end  // North
                    2'b01: begin E_red = 0; E_yellow = 1; end  // East
                    2'b10: begin S_red = 0; S_yellow = 1; end  // South
                    2'b11: begin W_red = 0; W_yellow = 1; end  // West
                endcase
            end else if (transition_state == 2'd2) begin
                // Red transition - all lights stay red (default values)
            end else begin
                // Set active lights based on current state
                case (state)
                    STATE_N_GREEN: begin
                        N_red = 0; N_green = 1;
                    end
                    STATE_N_YELLOW: begin
                        N_red = 0; N_yellow = 1;
                    end
                    STATE_E_GREEN: begin
                        E_red = 0; E_green = 1;
                    end
                    STATE_E_YELLOW: begin
                        E_red = 0; E_yellow = 1;
                    end
                    STATE_S_GREEN: begin
                        S_red = 0; S_green = 1;
                    end
                    STATE_S_YELLOW: begin
                        S_red = 0; S_yellow = 1;
                    end
                    STATE_W_GREEN: begin
                        W_red = 0; W_green = 1;
                    end
                    STATE_W_YELLOW: begin
                        W_red = 0; W_yellow = 1;
                    end
                    // All RED states keep default values
                endcase
            end

        end else begin
            // CHECK LOGIC - Manual mode light control
            // ===== MANUAL MODE =====
            if (~manual_parallel) begin
                // CHECK LOGIC - Sequential mode (one direction at a time)
                // --- Sequential Sub-Mode ---
                // Only one direction green at a time, others red
                N_red = 1; N_yellow = 0; N_green = 0;
                E_red = 1; E_yellow = 0; E_green = 0;
                S_red = 1; S_yellow = 0; S_green = 0;
                W_red = 1; W_yellow = 0; W_green = 0;

                if (sw_N) begin
                    N_red = 0; N_green = 1;
                end else if (sw_E) begin
                    E_red = 0; E_green = 1;
                end else if (sw_S) begin
                    S_red = 0; S_green = 1;
                end else if (sw_W) begin
                    W_red = 0; W_green = 1;
                end
                // else: all stay red

            end else begin
                // CHECK LOGIC - Parallel mode (N+S or E+W pairs)
                // --- Parallel Sub-Mode ---
                // Control N+S pair or E+W pair
                N_red = 1; N_yellow = 0; N_green = 0;
                E_red = 1; E_yellow = 0; E_green = 0;
                S_red = 1; S_yellow = 0; S_green = 0;
                W_red = 1; W_yellow = 0; W_green = 0;

                if (sw_NS && ~sw_EW) begin
                    // North and South green
                    N_red = 0; N_green = 1;
                    S_red = 0; S_green = 1;
                end else if (sw_EW && ~sw_NS) begin
                    // East and West green
                    E_red = 0; E_green = 1;
                    W_red = 0; W_green = 1;
                end else if (sw_NS && sw_EW) begin
                    // Both requested - invalid, all red (safety)
                    // All stay red
                end
                // else: all stay red
            end
        end
    end

endmodule
