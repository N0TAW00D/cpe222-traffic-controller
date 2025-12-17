`timescale 1ns / 1ps

module text_renderer(
    input wire clk,
    input wire [9:0] x,
    input wire [9:0] y,
    input wire [3:0] menu_sel,
    input wire [7:0] n_duration,
    input wire [7:0] s_duration,
    input wire [7:0] w_duration,
    input wire [7:0] e_duration,
    input wire [7:0] yellow_duration,
    input wire [7:0] red_holding,
    input wire [7:0] countdown_sec,
    input wire [1:0] active_direction,  // 00=N, 01=E, 10=S, 11=W
    input wire show_countdown,          
    input wire [7:0] font_pixels,
    input wire [7:0] yellow_light_count, 
    output wire text_pixel,
    output wire [5:0] char_code,
    output wire [2:0] char_row
);

    // Text display parameters
    parameter TEXT_X = 20;
    parameter TEXT_Y = 20;
    parameter CHAR_WIDTH = 9;
    parameter CHAR_HEIGHT = 8;
    parameter LINE_HEIGHT = 12;
    parameter TEXT_LENGTH = 24;

    // Menu display parameters
    parameter MENU_X = 300;
    parameter MENU_Y = 50;
    parameter MENU_MAX_CHARS = 30;
    parameter MENU_NUM_LINES = 8; 

    // Menu item 
    parameter MENU_N_DUR = 4'd1;
    parameter MENU_S_DUR = 4'd2;
    parameter MENU_W_DUR = 4'd3;
    parameter MENU_E_DUR = 4'd4;
    parameter MENU_YELLOW_DUR = 4'd5;
    parameter MENU_RED_HOLD = 4'd6;
    parameter MENU_YELLOW_COUNT = 4'd7;

    wire in_text_region;
    wire [4:0] char_index;
    wire [2:0] pixel_col;
    wire [2:0] text_char_row;

    assign in_text_region = (x >= TEXT_X) &&
                           (x < TEXT_X + TEXT_LENGTH * CHAR_WIDTH) &&
                           (y >= TEXT_Y) &&
                           (y < TEXT_Y + CHAR_HEIGHT);

    assign char_index = in_text_region ? ((x - TEXT_X) / CHAR_WIDTH) : 5'd0;
    assign pixel_col = in_text_region ? ((x - TEXT_X) % CHAR_WIDTH) : 3'd0;
    assign text_char_row = in_text_region ? (y - TEXT_Y) : 3'd0;

    reg [5:0] text_char_code;
    always @(*) begin
        case (char_index)
            5'd0:  text_char_code = 6'd20;
            5'd1:  text_char_code = 6'd18;
            5'd2:  text_char_code = 6'd1;
            5'd3:  text_char_code = 6'd6;
            5'd4:  text_char_code = 6'd6;
            5'd5:  text_char_code = 6'd9;
            5'd6:  text_char_code = 6'd3;
            5'd7:  text_char_code = 6'd0;
            5'd8:  text_char_code = 6'd12;
            5'd9:  text_char_code = 6'd9;
            5'd10: text_char_code = 6'd7;
            5'd11: text_char_code = 6'd8;
            5'd12: text_char_code = 6'd20;
            5'd13: text_char_code = 6'd0;
            5'd14: text_char_code = 6'd3;
            5'd15: text_char_code = 6'd15;
            5'd16: text_char_code = 6'd14;
            5'd17: text_char_code = 6'd20;
            5'd18: text_char_code = 6'd18;
            5'd19: text_char_code = 6'd15;
            5'd20: text_char_code = 6'd12;
            5'd21: text_char_code = 6'd12;
            5'd22: text_char_code = 6'd5;
            5'd23: text_char_code = 6'd18;
            default: text_char_code = 6'd0;
        endcase
    end

    wire in_menu_region;
    wire in_menu_bounds;
    wire [3:0] menu_line;
    wire [5:0] menu_char_pos;
    wire [2:0] menu_pixel_col;
    wire [2:0] menu_char_row;
    wire [3:0] menu_line_offset;

    assign in_menu_bounds = (x >= MENU_X) &&
                           (x < MENU_X + MENU_MAX_CHARS * CHAR_WIDTH) &&
                           (y >= MENU_Y) &&
                           (y < MENU_Y + MENU_NUM_LINES * LINE_HEIGHT);

    assign menu_line_offset = in_menu_bounds ? ((y - MENU_Y) % LINE_HEIGHT) : 4'd0;
    assign in_menu_region = in_menu_bounds && (menu_line_offset < CHAR_HEIGHT);

    assign menu_line = in_menu_bounds ? ((y - MENU_Y) / LINE_HEIGHT) : 4'd0;
    assign menu_char_pos = in_menu_bounds ? ((x - MENU_X) / CHAR_WIDTH) : 6'd0;
    assign menu_pixel_col = in_menu_bounds ? ((x - MENU_X) % CHAR_WIDTH) : 3'd0;
    assign menu_char_row = menu_line_offset[2:0];

    function [5:0] digit_to_char;
        input [3:0] digit;
        begin
            digit_to_char = 6'd27 + digit;
        end
    endfunction

    wire [3:0] n_tens = n_duration / 10;
    wire [3:0] n_ones = n_duration % 10;
    wire [3:0] s_tens = s_duration / 10;
    wire [3:0] s_ones = s_duration % 10;
    wire [3:0] w_tens = w_duration / 10;
    wire [3:0] w_ones = w_duration % 10;
    wire [3:0] e_tens = e_duration / 10;
    wire [3:0] e_ones = e_duration % 10;
    wire [3:0] yellow_tens = yellow_duration / 10;
    wire [3:0] yellow_ones = yellow_duration % 10;
    wire [3:0] red_tens = red_holding / 10;
    wire [3:0] red_ones = red_holding % 10;
    wire [3:0] yellow_count_tens = yellow_light_count / 10;
    wire [3:0] yellow_count_ones = yellow_light_count % 10;


    reg [5:0] menu_char_code;
    always @(*) begin
        menu_char_code = 6'd0;

        case (menu_line)
            4'd0: begin
                case (menu_char_pos)
                    6'd0:  menu_char_code = 6'd19;
                    6'd1:  menu_char_code = 6'd5;
                    6'd2:  menu_char_code = 6'd20;
                    6'd3:  menu_char_code = 6'd20;
                    6'd4:  menu_char_code = 6'd9;
                    6'd5:  menu_char_code = 6'd14;
                    6'd6:  menu_char_code = 6'd7;
                    default: menu_char_code = 6'd0;
                endcase
            end

            4'd1: begin
                case (menu_char_pos)
                    6'd0:  menu_char_code = (menu_sel == MENU_N_DUR) ? 6'd37 : 6'd0;
                    6'd2:  menu_char_code = 6'd14;
                    6'd8:  menu_char_code = 6'd4;
                    6'd9:  menu_char_code = 6'd21;
                    6'd10: menu_char_code = 6'd18;
                    6'd11: menu_char_code = 6'd1;
                    6'd12: menu_char_code = 6'd20;
                    6'd13: menu_char_code = 6'd9;
                    6'd14: menu_char_code = 6'd15;
                    6'd15: menu_char_code = 6'd14;
                    6'd20: menu_char_code = digit_to_char(n_tens);
                    6'd21: menu_char_code = digit_to_char(n_ones);
                    6'd23: menu_char_code = 6'd19;
                    6'd24: menu_char_code = 6'd5;
                    6'd25: menu_char_code = 6'd3;
                    default: menu_char_code = 6'd0;
                endcase
            end

            4'd2: begin
                case (menu_char_pos)
                    6'd0:  menu_char_code = (menu_sel == MENU_S_DUR) ? 6'd37 : 6'd0;
                    6'd2:  menu_char_code = 6'd19;
                    6'd8:  menu_char_code = 6'd4;
                    6'd9:  menu_char_code = 6'd21;
                    6'd10: menu_char_code = 6'd18;
                    6'd11: menu_char_code = 6'd1;
                    6'd12: menu_char_code = 6'd20;
                    6'd13: menu_char_code = 6'd9;
                    6'd14: menu_char_code = 6'd15;
                    6'd15: menu_char_code = 6'd14;
                    6'd20: menu_char_code = digit_to_char(s_tens);
                    6'd21: menu_char_code = digit_to_char(s_ones);
                    6'd23: menu_char_code = 6'd19;
                    6'd24: menu_char_code = 6'd5;
                    6'd25: menu_char_code = 6'd3;
                    default: menu_char_code = 6'd0;
                endcase
            end

            4'd3: begin
                case (menu_char_pos)
                    6'd0:  menu_char_code = (menu_sel == MENU_W_DUR) ? 6'd37 : 6'd0;
                    6'd2:  menu_char_code = 6'd23;
                    6'd8:  menu_char_code = 6'd4;
                    6'd9:  menu_char_code = 6'd21;
                    6'd10: menu_char_code = 6'd18;
                    6'd11: menu_char_code = 6'd1;
                    6'd12: menu_char_code = 6'd20;
                    6'd13: menu_char_code = 6'd9;
                    6'd14: menu_char_code = 6'd15;
                    6'd15: menu_char_code = 6'd14;
                    6'd20: menu_char_code = digit_to_char(w_tens);
                    6'd21: menu_char_code = digit_to_char(w_ones);
                    6'd23: menu_char_code = 6'd19;
                    6'd24: menu_char_code = 6'd5;
                    6'd25: menu_char_code = 6'd3;
                    default: menu_char_code = 6'd0;
                endcase
            end

            4'd4: begin
                case (menu_char_pos)
                    6'd0:  menu_char_code = (menu_sel == MENU_E_DUR) ? 6'd37 : 6'd0;
                    6'd2:  menu_char_code = 6'd5;
                    6'd8:  menu_char_code = 6'd4;
                    6'd9:  menu_char_code = 6'd21;
                    6'd10: menu_char_code = 6'd18;
                    6'd11: menu_char_code = 6'd1;
                    6'd12: menu_char_code = 6'd20;
                    6'd13: menu_char_code = 6'd9;
                    6'd14: menu_char_code = 6'd15;
                    6'd15: menu_char_code = 6'd14;
                    6'd20: menu_char_code = digit_to_char(e_tens);
                    6'd21: menu_char_code = digit_to_char(e_ones);
                    6'd23: menu_char_code = 6'd19;
                    6'd24: menu_char_code = 6'd5;
                    6'd25: menu_char_code = 6'd3;
                    default: menu_char_code = 6'd0;
                endcase
            end

            4'd5: begin
                case (menu_char_pos)
                    6'd0:  menu_char_code = (menu_sel == MENU_YELLOW_DUR) ? 6'd37 : 6'd0;
                    6'd1:  menu_char_code = 6'd0;
                    6'd2:  menu_char_code = 6'd25;
                    6'd3:  menu_char_code = 6'd5;
                    6'd4:  menu_char_code = 6'd12;
                    6'd5:  menu_char_code = 6'd12;
                    6'd6:  menu_char_code = 6'd15;
                    6'd7:  menu_char_code = 6'd23;
                    6'd8:  menu_char_code = 6'd0;
                    6'd9:  menu_char_code = 6'd4;
                    6'd10: menu_char_code = 6'd21;
                    6'd11: menu_char_code = 6'd18;
                    6'd12: menu_char_code = 6'd1;
                    6'd13: menu_char_code = 6'd20;
                    6'd14: menu_char_code = 6'd9;
                    6'd15: menu_char_code = 6'd15;
                    6'd16: menu_char_code = 6'd14;
                    6'd17: menu_char_code = 6'd0;
                    6'd18: menu_char_code = 6'd0;
                    6'd19: menu_char_code = 6'd0;
                    6'd20: menu_char_code = digit_to_char(yellow_tens);
                    6'd21: menu_char_code = digit_to_char(yellow_ones);
                    6'd22: menu_char_code = 6'd0;
                    6'd23: menu_char_code = 6'd19;
                    6'd24: menu_char_code = 6'd5;
                    6'd25: menu_char_code = 6'd3;
                    default: menu_char_code = 6'd0;
                endcase
            end

            4'd6: begin
                case (menu_char_pos)
                    6'd0:  menu_char_code = (menu_sel == MENU_RED_HOLD) ? 6'd37 : 6'd0;
                    6'd1:  menu_char_code = 6'd0;
                    6'd2:  menu_char_code = 6'd18;
                    6'd3:  menu_char_code = 6'd5;
                    6'd4:  menu_char_code = 6'd4;
                    6'd5:  menu_char_code = 6'd0;
                    6'd6:  menu_char_code = 6'd8;
                    6'd7:  menu_char_code = 6'd15;
                    6'd8:  menu_char_code = 6'd12;
                    6'd9:  menu_char_code = 6'd4;
                    6'd10: menu_char_code = 6'd9;
                    6'd11: menu_char_code = 6'd14;
                    6'd12: menu_char_code = 6'd7;
                    6'd13: menu_char_code = 6'd0;
                    6'd14: menu_char_code = 6'd0;
                    6'd15: menu_char_code = 6'd0;
                    6'd16: menu_char_code = 6'd0;
                    6'd17: menu_char_code = 6'd0;
                    6'd18: menu_char_code = 6'd0;
                    6'd19: menu_char_code = 6'd0;
                    6'd20: menu_char_code = digit_to_char(red_tens);
                    6'd21: menu_char_code = digit_to_char(red_ones);
                    6'd22: menu_char_code = 6'd0;
                    6'd23: menu_char_code = 6'd19;
                    6'd24: menu_char_code = 6'd5;
                    6'd25: menu_char_code = 6'd3;
                    default: menu_char_code = 6'd0;
                endcase
            end

            4'd7: menu_char_code = 6'd0;

            default: menu_char_code = 6'd0;
        endcase
    end

    parameter COUNTDOWN_N_X = 165;
    parameter COUNTDOWN_N_Y = 70;

    parameter COUNTDOWN_E_X = 220;
    parameter COUNTDOWN_E_Y = 170;

    parameter COUNTDOWN_S_X = 125;
    parameter COUNTDOWN_S_Y = 220;

    parameter COUNTDOWN_W_X = 70;
    parameter COUNTDOWN_W_Y = 130;

    parameter COUNTDOWN_MAX_CHARS = 3;

    reg [9:0] countdown_x, countdown_y;
    always @(*) begin
        case (active_direction)
            2'b00: begin
                countdown_x = COUNTDOWN_N_X;
                countdown_y = COUNTDOWN_N_Y;
            end
            2'b01: begin
                countdown_x = COUNTDOWN_E_X;
                countdown_y = COUNTDOWN_E_Y;
            end
            2'b10: begin
                countdown_x = COUNTDOWN_S_X;
                countdown_y = COUNTDOWN_S_Y;
            end
            2'b11: begin
                countdown_x = COUNTDOWN_W_X;
                countdown_y = COUNTDOWN_W_Y;
            end
        endcase
    end

    wire in_countdown_region;
    wire [5:0] countdown_char_pos;
    wire [2:0] countdown_pixel_col;
    wire [2:0] countdown_char_row;

    assign in_countdown_region = (x >= countdown_x) &&
                                (x < countdown_x + COUNTDOWN_MAX_CHARS * CHAR_WIDTH) &&
                                (y >= countdown_y) &&
                                (y < countdown_y + CHAR_HEIGHT);

    assign countdown_char_pos = in_countdown_region ? ((x - countdown_x) / CHAR_WIDTH) : 6'd0;
    assign countdown_pixel_col = in_countdown_region ? ((x - countdown_x) % CHAR_WIDTH) : 3'd0;
    assign countdown_char_row = in_countdown_region ? (y - countdown_y) : 3'd0;

    wire [3:0] countdown_tens = (countdown_sec % 100) / 10;
    wire [3:0] countdown_ones = countdown_sec % 10;

    reg [5:0] countdown_char_code;
    always @(*) begin
        countdown_char_code = 6'd0;
        if (show_countdown) begin
            case (countdown_char_pos)
                6'd0:  countdown_char_code = (countdown_sec >= 10) ? digit_to_char(countdown_tens) : 6'd0;
                6'd1:  countdown_char_code = digit_to_char(countdown_ones);
                default: countdown_char_code = 6'd0;
            endcase
        end else begin
            countdown_char_code = 6'd0;
        end
    end

    wire [5:0] final_char_code;
    wire [2:0] final_char_row;

    assign final_char_code = in_countdown_region ? countdown_char_code :
                            (in_menu_region ? menu_char_code :
                            (in_text_region ? text_char_code : 6'd0));
    assign final_char_row = in_countdown_region ? countdown_char_row :
                           (in_menu_region ? menu_char_row :
                           (in_text_region ? text_char_row : 3'd0));

    assign char_code = final_char_code;
    assign char_row = final_char_row;

    wire [2:0] active_pixel_col = in_countdown_region ? countdown_pixel_col :
                                 (in_menu_region ? menu_pixel_col : pixel_col);
    wire font_pixel = (active_pixel_col < 8) ? font_pixels[7 - active_pixel_col] : 1'b0;

    assign text_pixel = (in_text_region || in_menu_region || in_countdown_region) && font_pixel;

endmodule
