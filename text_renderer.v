`timescale 1ns / 1ps

module text_renderer(
    input wire clk,
    input wire [9:0] x,
    input wire [9:0] y,
    input wire [3:0] menu_sel,
    input wire [7:0] green_duration,
    input wire [7:0] yellow_duration,
    input wire [7:0] red_holding,
    input wire [7:0] font_pixels,
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
    parameter MENU_NUM_LINES = 9;

    // Menu item indices
    parameter MENU_GREEN_DUR = 4'd1;
    parameter MENU_YELLOW_DUR = 4'd2;
    parameter MENU_RED_HOLD = 4'd3;
    parameter MENU_PLAY = 4'd6;
    parameter MENU_PAUSE = 4'd7;
    parameter MENU_STOP = 4'd8;

    // ========================================================================
    // TITLE TEXT RENDERING
    // ========================================================================
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

    // Character lookup for "TRAFFIC LIGHT CONTROLLER"
    reg [5:0] text_char_code;
    always @(*) begin
        case (char_index)
            5'd0:  text_char_code = 6'd20; // T
            5'd1:  text_char_code = 6'd18; // R
            5'd2:  text_char_code = 6'd1;  // A
            5'd3:  text_char_code = 6'd6;  // F
            5'd4:  text_char_code = 6'd6;  // F
            5'd5:  text_char_code = 6'd9;  // I
            5'd6:  text_char_code = 6'd3;  // C
            5'd7:  text_char_code = 6'd0;  // Space
            5'd8:  text_char_code = 6'd12; // L
            5'd9:  text_char_code = 6'd9;  // I
            5'd10: text_char_code = 6'd7;  // G
            5'd11: text_char_code = 6'd8;  // H
            5'd12: text_char_code = 6'd20; // T
            5'd13: text_char_code = 6'd0;  // Space
            5'd14: text_char_code = 6'd3;  // C
            5'd15: text_char_code = 6'd15; // O
            5'd16: text_char_code = 6'd14; // N
            5'd17: text_char_code = 6'd20; // T
            5'd18: text_char_code = 6'd18; // R
            5'd19: text_char_code = 6'd15; // O
            5'd20: text_char_code = 6'd12; // L
            5'd21: text_char_code = 6'd12; // L
            5'd22: text_char_code = 6'd5;  // E
            5'd23: text_char_code = 6'd18; // R
            default: text_char_code = 6'd0;
        endcase
    end

    // ========================================================================
    // MENU TEXT RENDERING
    // ========================================================================
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

    // Convert number to character code
    function [5:0] digit_to_char;
        input [3:0] digit;
        begin
            digit_to_char = 6'd27 + digit;
        end
    endfunction

    // Extract digits
    wire [3:0] green_tens = green_duration / 10;
    wire [3:0] green_ones = green_duration % 10;
    wire [3:0] yellow_tens = yellow_duration / 10;
    wire [3:0] yellow_ones = yellow_duration % 10;
    wire [3:0] red_tens = red_holding / 10;
    wire [3:0] red_ones = red_holding % 10;

    // Menu character lookup
    reg [5:0] menu_char_code;
    always @(*) begin
        menu_char_code = 6'd0;

        case (menu_line)
            // Line 0: "Setting"
            4'd0: begin
                case (menu_char_pos)
                    6'd0:  menu_char_code = 6'd19; // S
                    6'd1:  menu_char_code = 6'd5;  // E
                    6'd2:  menu_char_code = 6'd20; // T
                    6'd3:  menu_char_code = 6'd20; // T
                    6'd4:  menu_char_code = 6'd9;  // I
                    6'd5:  menu_char_code = 6'd14; // N
                    6'd6:  menu_char_code = 6'd7;  // G
                    default: menu_char_code = 6'd0;
                endcase
            end

            // Line 1: "Green duration"
            4'd1: begin
                case (menu_char_pos)
                    6'd0:  menu_char_code = (menu_sel == MENU_GREEN_DUR) ? 6'd37 : 6'd0;
                    6'd1:  menu_char_code = 6'd0;
                    6'd2:  menu_char_code = 6'd7;  // G
                    6'd3:  menu_char_code = 6'd18; // R
                    6'd4:  menu_char_code = 6'd5;  // E
                    6'd5:  menu_char_code = 6'd5;  // E
                    6'd6:  menu_char_code = 6'd14; // N
                    6'd7:  menu_char_code = 6'd0;
                    6'd8:  menu_char_code = 6'd4;  // D
                    6'd9:  menu_char_code = 6'd21; // U
                    6'd10: menu_char_code = 6'd18; // R
                    6'd11: menu_char_code = 6'd1;  // A
                    6'd12: menu_char_code = 6'd20; // T
                    6'd13: menu_char_code = 6'd9;  // I
                    6'd14: menu_char_code = 6'd15; // O
                    6'd15: menu_char_code = 6'd14; // N
                    6'd16: menu_char_code = 6'd0;
                    6'd17: menu_char_code = 6'd0;
                    6'd18: menu_char_code = 6'd0;
                    6'd19: menu_char_code = 6'd0;
                    6'd20: menu_char_code = digit_to_char(green_tens);
                    6'd21: menu_char_code = digit_to_char(green_ones);
                    6'd22: menu_char_code = 6'd0;
                    6'd23: menu_char_code = 6'd19; // S
                    6'd24: menu_char_code = 6'd5;  // E
                    6'd25: menu_char_code = 6'd3;  // C
                    default: menu_char_code = 6'd0;
                endcase
            end

            // Line 2: "Yellow duration"
            4'd2: begin
                case (menu_char_pos)
                    6'd0:  menu_char_code = (menu_sel == MENU_YELLOW_DUR) ? 6'd37 : 6'd0;
                    6'd1:  menu_char_code = 6'd0;
                    6'd2:  menu_char_code = 6'd25; // Y
                    6'd3:  menu_char_code = 6'd5;  // E
                    6'd4:  menu_char_code = 6'd12; // L
                    6'd5:  menu_char_code = 6'd12; // L
                    6'd6:  menu_char_code = 6'd15; // O
                    6'd7:  menu_char_code = 6'd23; // W
                    6'd8:  menu_char_code = 6'd0;
                    6'd9:  menu_char_code = 6'd4;  // D
                    6'd10: menu_char_code = 6'd21; // U
                    6'd11: menu_char_code = 6'd18; // R
                    6'd12: menu_char_code = 6'd1;  // A
                    6'd13: menu_char_code = 6'd20; // T
                    6'd14: menu_char_code = 6'd9;  // I
                    6'd15: menu_char_code = 6'd15; // O
                    6'd16: menu_char_code = 6'd14; // N
                    6'd17: menu_char_code = 6'd0;
                    6'd18: menu_char_code = 6'd0;
                    6'd19: menu_char_code = 6'd0;
                    6'd20: menu_char_code = digit_to_char(yellow_tens);
                    6'd21: menu_char_code = digit_to_char(yellow_ones);
                    6'd22: menu_char_code = 6'd0;
                    6'd23: menu_char_code = 6'd19; // S
                    6'd24: menu_char_code = 6'd5;  // E
                    6'd25: menu_char_code = 6'd3;  // C
                    default: menu_char_code = 6'd0;
                endcase
            end

            // Line 3: "Red Holding"
            4'd3: begin
                case (menu_char_pos)
                    6'd0:  menu_char_code = (menu_sel == MENU_RED_HOLD) ? 6'd37 : 6'd0;
                    6'd1:  menu_char_code = 6'd0;
                    6'd2:  menu_char_code = 6'd18; // R
                    6'd3:  menu_char_code = 6'd5;  // E
                    6'd4:  menu_char_code = 6'd4;  // D
                    6'd5:  menu_char_code = 6'd0;
                    6'd6:  menu_char_code = 6'd8;  // H
                    6'd7:  menu_char_code = 6'd15; // O
                    6'd8:  menu_char_code = 6'd12; // L
                    6'd9:  menu_char_code = 6'd4;  // D
                    6'd10: menu_char_code = 6'd9;  // I
                    6'd11: menu_char_code = 6'd14; // N
                    6'd12: menu_char_code = 6'd7;  // G
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
                    6'd23: menu_char_code = 6'd19; // S
                    6'd24: menu_char_code = 6'd5;  // E
                    6'd25: menu_char_code = 6'd3;  // C
                    default: menu_char_code = 6'd0;
                endcase
            end

            // Line 4: Blank
            4'd4: menu_char_code = 6'd0;

            // Line 5: "Simulation"
            4'd5: begin
                case (menu_char_pos)
                    6'd0:  menu_char_code = 6'd19; // S
                    6'd1:  menu_char_code = 6'd9;  // I
                    6'd2:  menu_char_code = 6'd13; // M
                    6'd3:  menu_char_code = 6'd21; // U
                    6'd4:  menu_char_code = 6'd12; // L
                    6'd5:  menu_char_code = 6'd1;  // A
                    6'd6:  menu_char_code = 6'd20; // T
                    6'd7:  menu_char_code = 6'd9;  // I
                    6'd8:  menu_char_code = 6'd15; // O
                    6'd9:  menu_char_code = 6'd14; // N
                    default: menu_char_code = 6'd0;
                endcase
            end

            // Line 6: "Play"
            4'd6: begin
                case (menu_char_pos)
                    6'd0:  menu_char_code = (menu_sel == MENU_PLAY) ? 6'd37 : 6'd0;
                    6'd1:  menu_char_code = 6'd0;
                    6'd2:  menu_char_code = 6'd16; // P
                    6'd3:  menu_char_code = 6'd12; // L
                    6'd4:  menu_char_code = 6'd1;  // A
                    6'd5:  menu_char_code = 6'd25; // Y
                    default: menu_char_code = 6'd0;
                endcase
            end

            // Line 7: "Pause"
            4'd7: begin
                case (menu_char_pos)
                    6'd0:  menu_char_code = (menu_sel == MENU_PAUSE) ? 6'd37 : 6'd0;
                    6'd1:  menu_char_code = 6'd0;
                    6'd2:  menu_char_code = 6'd16; // P
                    6'd3:  menu_char_code = 6'd1;  // A
                    6'd4:  menu_char_code = 6'd21; // U
                    6'd5:  menu_char_code = 6'd19; // S
                    6'd6:  menu_char_code = 6'd5;  // E
                    default: menu_char_code = 6'd0;
                endcase
            end

            // Line 8: "Stop"
            4'd8: begin
                case (menu_char_pos)
                    6'd0:  menu_char_code = (menu_sel == MENU_STOP) ? 6'd37 : 6'd0;
                    6'd1:  menu_char_code = 6'd0;
                    6'd2:  menu_char_code = 6'd19; // S
                    6'd3:  menu_char_code = 6'd20; // T
                    6'd4:  menu_char_code = 6'd15; // O
                    6'd5:  menu_char_code = 6'd16; // P
                    default: menu_char_code = 6'd0;
                endcase
            end

            default: menu_char_code = 6'd0;
        endcase
    end

    // ========================================================================
    // OUTPUT MULTIPLEXING
    // ========================================================================
    wire [5:0] final_char_code;
    wire [2:0] final_char_row;

    assign final_char_code = in_menu_region ? menu_char_code :
                            (in_text_region ? text_char_code : 6'd0);
    assign final_char_row = in_menu_region ? menu_char_row :
                           (in_text_region ? text_char_row : 3'd0);

    assign char_code = final_char_code;
    assign char_row = final_char_row;

    // Generate text pixel output from font ROM
    // Use the appropriate pixel column based on which region we're in
    wire [2:0] active_pixel_col = in_menu_region ? menu_pixel_col : pixel_col;
    wire font_pixel = (active_pixel_col < 8) ? font_pixels[7 - active_pixel_col] : 1'b0;

    assign text_pixel = (in_text_region || in_menu_region) && font_pixel;

endmodule
