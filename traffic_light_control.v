`timescale 1ns / 1ps

module traffic_light_control (
    input  wire        clk,
    input  wire        rst,

    input  wire [15:0] switches,
    input  wire [7:0]  n_duration,
    input  wire [7:0]  s_duration,
    input  wire [7:0]  w_duration,
    input  wire [7:0]  e_duration,
    input  wire [7:0]  yellow_duration,
    input  wire [7:0]  red_holding,

    output wire        N_red,
    output wire        N_yellow,
    output wire        N_green,

    output wire        E_red,
    output wire        E_yellow,
    output wire        E_green,

    output wire        S_red,
    output wire        S_yellow,
    output wire        S_green,

    output wire        W_red,
    output wire        W_yellow,
    output wire        W_green,

    output wire [7:0]  countdown_sec,
    output wire [1:0]  active_direction,
    output wire        manual_yellow_transition,
    output wire        show_countdown,
    output reg [7:0]   yellow_light_count
);

    localparam CLK_FREQ = 100_000_000;

    localparam DIR_NORTH = 2'd0;
    localparam DIR_EAST  = 2'd1;
    localparam DIR_SOUTH = 2'd2;
    localparam DIR_WEST  = 2'd3;

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
        ST_W_RED      = 4'd11;

    wire mode_manual      = switches[0];
    wire mode_parallel    = switches[1];
    wire sw_north         = switches[2];
    wire sw_east          = switches[3];
    wire sw_south         = switches[4];
    wire sw_west          = switches[5];

    reg [3:0]  current_state;
    reg [3:0]  next_state;
    reg [31:0] cycle_counter;
    reg [31:0] cycle_duration;
    reg        prev_mode_manual;

    reg        manual_mode_pending;
    reg        auto_mode_pending;
    reg [3:0]  green_snapshot;
    reg [1:0]  last_auto_direction;

    reg prev_sw_north, prev_sw_east, prev_sw_south, prev_sw_west;
    reg [1:0]  manual_state;
    localparam MANUAL_IDLE = 2'd0;
    localparam MANUAL_YELLOW = 2'd1;
    localparam MANUAL_RED = 2'd2;
    reg [31:0] manual_timer;
    reg [3:0]  manual_yellow_lights;

    reg [7:0] yellow_light_counter;

    reg [3:0]  red_lights;
    reg [3:0]  yellow_lights;
    reg [3:0]  green_lights;

    wire [31:0] cycles_n_green = n_duration * CLK_FREQ;
    wire [31:0] cycles_s_green = s_duration * CLK_FREQ;
    wire [31:0] cycles_w_green = w_duration * CLK_FREQ;
    wire [31:0] cycles_e_green = e_duration * CLK_FREQ;
    wire [31:0] cycles_yellow = yellow_duration * CLK_FREQ;
    wire [31:0] cycles_red    = red_holding     * CLK_FREQ;

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
            default:
                cycle_duration = cycles_n_green;
        endcase
    end

    wire auto_to_manual_request = mode_manual && !prev_mode_manual;
    wire manual_to_auto_request = !mode_manual && prev_mode_manual;

    wire north_off = prev_sw_north && !sw_north;
    wire east_off  = prev_sw_east  && !sw_east;
    wire south_off = prev_sw_south && !sw_south;
    wire west_off  = prev_sw_west  && !sw_west;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state       <= ST_N_GREEN;
            cycle_counter       <= 0;
            prev_mode_manual    <= mode_manual;
            manual_mode_pending <= 0;
            auto_mode_pending   <= 0;
            green_snapshot      <= 4'b0000;
            last_auto_direction <= DIR_NORTH;
            manual_state        <= MANUAL_IDLE;
            manual_timer        <= 0;
            manual_yellow_lights<= 4'b0;
            prev_sw_north       <= sw_north;
            prev_sw_east        <= sw_east;
            prev_sw_south       <= sw_south;
            prev_sw_west        <= sw_west;
            yellow_light_counter<= 8'd0;
        end else begin
            prev_mode_manual <= mode_manual;

            prev_sw_north <= sw_north;
            prev_sw_east  <= sw_east;
            prev_sw_south <= sw_south;
            prev_sw_west  <= sw_west;

            if (!mode_manual) begin
                manual_state <= MANUAL_IDLE;
                auto_mode_pending <= 0;

                case (current_state)
                    ST_N_GREEN, ST_N_YELLOW, ST_N_RED:
                        last_auto_direction <= DIR_NORTH;
                    ST_E_GREEN, ST_E_YELLOW, ST_E_RED:
                        last_auto_direction <= DIR_EAST;
                    ST_S_GREEN, ST_S_YELLOW, ST_S_RED:
                        last_auto_direction <= DIR_SOUTH;
                    ST_W_GREEN, ST_W_YELLOW, ST_W_RED:
                        last_auto_direction <= DIR_WEST;
                endcase

                if (cycle_counter >= cycle_duration - 1) begin
                    current_state <= next_state;
                    cycle_counter <= 0;
                    if (next_state == ST_N_YELLOW || next_state == ST_E_YELLOW ||
                        next_state == ST_S_YELLOW || next_state == ST_W_YELLOW) begin
                        yellow_light_counter <= yellow_light_counter + 1;
                    end
                end else begin
                    cycle_counter <= cycle_counter + 1;
                end

            end else begin

                case(manual_state)
                    MANUAL_IDLE: begin
                        if (!mode_parallel) begin
                            if (north_off) begin
                                manual_state <= MANUAL_YELLOW;
                                manual_yellow_lights <= 4'b0001;
                                manual_timer <= 0;
                                yellow_light_counter <= yellow_light_counter + 1;
                            end else if (east_off) begin
                                manual_state <= MANUAL_YELLOW;
                                manual_yellow_lights <= 4'b0010;
                                manual_timer <= 0;
                                yellow_light_counter <= yellow_light_counter + 1;
                            end else if (south_off) begin
                                manual_state <= MANUAL_YELLOW;
                                manual_yellow_lights <= 4'b0100;
                                manual_timer <= 0;
                                yellow_light_counter <= yellow_light_counter + 1;
                            end else if (west_off) begin
                                manual_state <= MANUAL_YELLOW;
                                manual_yellow_lights <= 4'b1000;
                                manual_timer <= 0;
                                yellow_light_counter <= yellow_light_counter + 1;
                            end
                        end else begin
                            if (north_off) begin
                                manual_state <= MANUAL_YELLOW;
                                manual_yellow_lights <= 4'b0101;
                                manual_timer <= 0;
                                yellow_light_counter <= yellow_light_counter + 1;
                            end else if (east_off) begin
                                manual_state <= MANUAL_YELLOW;
                                manual_yellow_lights <= 4'b1010;
                                manual_timer <= 0;
                                yellow_light_counter <= yellow_light_counter + 1;
                            end
                        end
                    end
                    MANUAL_YELLOW: begin
                        if(manual_timer >= cycles_yellow - 1) begin
                            manual_state <= MANUAL_RED;
                            manual_timer <= 0;
                        end else begin
                            manual_timer <= manual_timer + 1;
                        end
                    end
                    MANUAL_RED: begin
                        if(manual_timer >= cycles_red - 1) begin
                            if (!auto_mode_pending) begin
                                manual_state <= MANUAL_IDLE;
                            end
                            manual_timer <= 0;
                        end else begin
                            manual_timer <= manual_timer + 1;
                        end
                    end
                endcase

                if (manual_to_auto_request) begin
                    auto_mode_pending <= 1;

                    if (manual_state == MANUAL_IDLE && (sw_north || sw_east || sw_south || sw_west)) begin
                        manual_state <= MANUAL_YELLOW;
                        manual_yellow_lights <= green_lights;
                        manual_timer <= 0;
                        yellow_light_counter <= yellow_light_counter + 1;
                    end
                end

                if (manual_mode_pending) begin
                    if (cycle_counter >= cycle_duration - 1) begin
                        current_state <= next_state;
                        cycle_counter <= 0;

                        if (next_state == ST_N_RED || next_state == ST_E_RED ||
                            next_state == ST_S_RED || next_state == ST_W_RED) begin
                            manual_mode_pending <= 0;
                        end
                    end else begin
                        cycle_counter <= cycle_counter + 1;
                    end

                end else begin
                    if (auto_to_manual_request) begin
                        manual_mode_pending <= 1;
                    end else begin
                        current_state       <= ST_N_GREEN;
                        cycle_counter       <= 0;
                    end
                end
            end
        end
    end

    always @(*) begin
        case (current_state)
            ST_N_GREEN:    next_state = ST_N_YELLOW;
            ST_N_YELLOW:   next_state = ST_N_RED;
            ST_N_RED:      next_state = ST_E_GREEN;

            ST_E_GREEN:    next_state = ST_E_YELLOW;
            ST_E_YELLOW:   next_state = ST_E_RED;
            ST_E_RED:      next_state = ST_S_GREEN;

            ST_S_GREEN:    next_state = ST_S_YELLOW;
            ST_S_YELLOW:   next_state = ST_S_RED;
            ST_S_RED:      next_state = ST_W_GREEN;

            ST_W_GREEN:    next_state = ST_W_YELLOW;
            ST_W_YELLOW:   next_state = ST_W_RED;
            ST_W_RED:      next_state = ST_N_GREEN;

            default:       next_state = ST_N_GREEN;
        endcase
    end

    always @(*) begin
        if (!mode_manual) begin
            red_lights    = 4'b1111;
            yellow_lights = 4'b0000;
            green_lights  = 4'b0000;

            case (current_state)
                    ST_N_GREEN: begin
                        red_lights[0]   = 0;
                        green_lights[0] = 1;
                    end
                    ST_N_YELLOW: begin
                        red_lights[0]    = 0;
                        yellow_lights[0] = 1;
                    end

                    ST_E_GREEN: begin
                        red_lights[1]   = 0;
                        green_lights[1] = 1;
                    end
                    ST_E_YELLOW: begin
                        red_lights[1]    = 0;
                        yellow_lights[1] = 1;
                    end

                    ST_S_GREEN: begin
                        red_lights[2]   = 0;
                        green_lights[2] = 1;
                    end
                    ST_S_YELLOW: begin
                        red_lights[2]    = 0;
                        yellow_lights[2] = 1;
                    end

                    ST_W_GREEN: begin
                        red_lights[3]   = 0;
                        green_lights[3] = 1;
                    end
                    ST_W_YELLOW: begin
                        red_lights[3]    = 0;
                        yellow_lights[3] = 1;
                    end

            endcase

        end else if (manual_mode_pending) begin
            red_lights    = 4'b1111;
            yellow_lights = 4'b0000;
            green_lights  = 4'b0000;

            case (current_state)
                ST_N_GREEN: begin
                    red_lights[0]   = 0;
                    green_lights[0] = 1;
                end
                ST_N_YELLOW: begin
                    red_lights[0]    = 0;
                    yellow_lights[0] = 1;
                end

                ST_E_GREEN: begin
                    red_lights[1]   = 0;
                    green_lights[1] = 1;
                end
                ST_E_YELLOW: begin
                    red_lights[1]    = 0;
                    yellow_lights[1] = 1;
                end

                ST_S_GREEN: begin
                    red_lights[2]   = 0;
                    green_lights[2] = 1;
                end
                ST_S_YELLOW: begin
                    red_lights[2]    = 0;
                    yellow_lights[2] = 1;
                end

                ST_W_GREEN: begin
                    red_lights[3]   = 0;
                    green_lights[3] = 1;
                end
                ST_W_YELLOW: begin
                    red_lights[3]    = 0;
                    yellow_lights[3] = 1;
                end

            endcase

        end else begin
            if (manual_state == MANUAL_YELLOW) begin
                red_lights    = ~manual_yellow_lights;
                yellow_lights = manual_yellow_lights;
                green_lights  = 4'b0;
            end else if (manual_state == MANUAL_RED) begin
                red_lights    = 4'b1111;
                yellow_lights = 4'b0000;
                green_lights  = 4'b0000;
            end else begin
                red_lights    = 4'b1111;
                yellow_lights = 4'b0000;
                green_lights  = 4'b0000;

                if (!mode_parallel) begin
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
                    if (sw_north && !sw_east) begin
                        red_lights[0]   = 0;
                        green_lights[0] = 1;
                        red_lights[2]   = 0;
                        green_lights[2] = 1;
                    end else if (sw_east && !sw_north) begin
                        red_lights[1]   = 0;
                        green_lights[1] = 1;
                        red_lights[3]   = 0;
                        green_lights[3] = 1;
                    end
                end
            end
        end
    end

    reg [1:0] active_dir;

    always @(*) begin
        if (!mode_manual) begin
            case (current_state)
                ST_N_GREEN, ST_N_YELLOW, ST_N_RED:
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
            active_dir = last_auto_direction;
        end else begin
            if (!mode_parallel) begin
                if (sw_north)      active_dir = DIR_NORTH;
                else if (sw_east)  active_dir = DIR_EAST;
                else if (sw_south) active_dir = DIR_SOUTH;
                else if (sw_west)  active_dir = DIR_WEST;
                else               active_dir = DIR_NORTH;
            end else begin
                if (sw_north)      active_dir = DIR_NORTH;
                else if (sw_east)  active_dir = DIR_EAST;
                else               active_dir = DIR_NORTH;
            end
        end
    end

    assign active_direction = active_dir;

    wire [31:0] cycles_remaining = (cycle_duration > cycle_counter) ?
                                   (cycle_duration - cycle_counter) : 32'd0;
    wire [31:0] seconds_remaining = (cycles_remaining + CLK_FREQ - 1) / CLK_FREQ;

    assign countdown_sec = (seconds_remaining > 255) ? 8'd255 : seconds_remaining[7:0];

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

    assign manual_yellow_transition = (manual_mode_pending || auto_mode_pending);

    assign show_countdown = !mode_manual || manual_mode_pending || auto_mode_pending;

endmodule
