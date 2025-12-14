`timescale 1ns / 1ps

module vga_display_top(
    input wire clk,              // 100MHz system clock
    input wire reset,
    output wire hsync,
    output wire vsync,
    output wire [3:0] vga_r,
    output wire [3:0] vga_g,
    output wire [3:0] vga_b
);

    // VGA controller signals
    wire video_on;
    wire [9:0] x, y;
    
    // Instantiate VGA controller
    vga_controller vga_ctrl(
        .clk(clk),
        .reset(reset),
        .hsync(hsync),
        .vsync(vsync),
        .video_on(video_on),
        .x(x),
        .y(y)
    );
    
    // Text display parameters
    parameter TEXT_X = 20;
    parameter TEXT_Y = 20;
    parameter CHAR_WIDTH = 9;   // 8 pixels + 1 spacing
    parameter CHAR_HEIGHT = 8;
    
    // Text string: "TRAFFIC LIGHT CONTROLLER"
    // Character codes: T=20, R=18, A=1, F=6, I=9, C=3, L=12, G=7, H=8, O=15, N=14, E=5, Space=0
    parameter TEXT_LENGTH = 24;
    
    // Font ROM signals
    wire [5:0] char_code;
    wire [2:0] char_row;
    wire [7:0] font_pixels;
    
    font_rom font(
        .clk(clk),
        .char_code(char_code),
        .row(char_row),
        .pixels(font_pixels)
    );
    
    // Text rendering logic
    wire in_text_region;
    wire [4:0] char_index;      // Which character in the string (0-23)
    wire [2:0] pixel_col;       // Which column within character (0-7)
    wire text_pixel;
    
    assign in_text_region = (x >= TEXT_X) && 
                           (x < TEXT_X + TEXT_LENGTH * CHAR_WIDTH) &&
                           (y >= TEXT_Y) && 
                           (y < TEXT_Y + CHAR_HEIGHT);
    
    assign char_index = (x - TEXT_X) / CHAR_WIDTH;
    assign pixel_col = (x - TEXT_X) % CHAR_WIDTH;
    assign char_row = y - TEXT_Y;
    
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
            default: text_char_code = 6'd0; // Space
        endcase
    end
    
    assign char_code = text_char_code;
    
    // Extract the pixel at current column (only if within 8-pixel font width)
    assign text_pixel = (pixel_col < 8) ? font_pixels[7 - pixel_col] : 1'b0;
    
    // White shape components (independent connectors)
    wire top_square2, top_square4;
    wire nd_square1, nd_square2;
    wire th_square1, th_square2;
    wire bot_square2, bot_square4;

    // Main white shape sections (can be grouped)
    wire white_main_sections;

    // Colored squares
    wire green_square, blue_square, yellow_square;

    // =======================================================================
    // TOP ROW - Main sections
    wire top_row_main;
    assign top_row_main = ((x >= 50) && (x < 120) && (y >= 50) && (y < 120)) ||   // top_square1
                          ((x >= 150) && (x < 160) && (y >= 50) && (y < 120)) ||  // top_square3
                          ((x >= 190) && (x < 260) && (y >= 50) && (y < 120));    // top_square5

    // TOP ROW - Independent connectors
    assign top_square2 = (x >= 130) && (x < 140) && (y >= 110) && (y < 120);
    assign top_square4 = (x >= 170) && (x < 180) && (y >= 110) && (y < 120);

    // =======================================================================
    // ROW 2 - Independent connectors
    assign nd_square1 = (x >= 110) && (x < 120) && (y >= 130) && (y < 140);
    assign nd_square2 = (x >= 190) && (x < 200) && (y >= 130) && (y < 140);

    // =======================================================================
    // ROW 3 - Horizontal bars
    wire row3_bars;
    assign row3_bars = ((x >= 50) && (x < 120) && (y >= 150) && (y < 160)) ||   // rd_square1
                       ((x >= 190) && (x < 260) && (y >= 150) && (y < 160));    // rd_square2

    // =======================================================================
    // ROW 4 - Independent connectors
    assign th_square1 = (x >= 110) && (x < 120) && (y >= 170) && (y < 180);
    assign th_square2 = (x >= 190) && (x < 200) && (y >= 170) && (y < 180);

    // =======================================================================
    // BOTTOM ROW - Main sections
    wire bot_row_main;
    assign bot_row_main = ((x >= 50) && (x < 120) && (y >= 190) && (y < 260)) ||   // bot_square1
                          ((x >= 150) && (x < 160) && (y >= 190) && (y < 260)) ||  // bot_square3
                          ((x >= 190) && (x < 260) && (y >= 190) && (y < 260));    // bot_square5

    // BOTTOM ROW - Independent connectors
    assign bot_square2 = (x >= 130) && (x < 140) && (y >= 190) && (y < 200);
    assign bot_square4 = (x >= 170) && (x < 180) && (y >= 190) && (y < 200);

    // =======================================================================
    // Combine all white shape sections
    assign white_main_sections = top_row_main || row3_bars || bot_row_main;

    // =======================================================================
    // Colored squares at (500, 50), size 80x80
    assign green_square = (x >= 500) && (x < 580) && (y >= 50) && (y < 130);
    
    // Blue square at (50, 350), size 80x80
    assign blue_square = (x >= 50) && (x < 130) && (y >= 350) && (y < 430);
    
    // Yellow square at (500, 350), size 80x80
    assign yellow_square = (x >= 500) && (x < 580) && (y >= 350) && (y < 430);
    
    // RGB output logic
    reg [3:0] rgb_r, rgb_g, rgb_b;
    
    always @(*) begin
        if (!video_on) begin
            // Blanking period - output black
            rgb_r = 4'b0000;
            rgb_g = 4'b0000;
            rgb_b = 4'b0000;
        end else if (in_text_region && text_pixel) begin
            // White text
            rgb_r = 4'b1111;
            rgb_g = 4'b1111;
            rgb_b = 4'b1111;
        end else if (white_main_sections ||
                     top_square2 || top_square4 ||
                     nd_square1 || nd_square2 ||
                     th_square1 || th_square2 ||
                     bot_square2 || bot_square4) begin
            // White shape
            rgb_r = 4'b1111;
            rgb_g = 4'b1111;
            rgb_b = 4'b1111;
        end else if (green_square) begin
            // Green square
            rgb_r = 4'b0000;
            rgb_g = 4'b1111;
            rgb_b = 4'b0000;
        end else if (blue_square) begin
            // Blue square
            rgb_r = 4'b0000;
            rgb_g = 4'b0000;
            rgb_b = 4'b1111;
        end else if (yellow_square) begin
            // Yellow square
            rgb_r = 4'b1111;
            rgb_g = 4'b1111;
            rgb_b = 4'b0000;
        end else begin
            // Black background
            rgb_r = 4'b0000;
            rgb_g = 4'b0000;
            rgb_b = 4'b0000;
        end
    end
    
    assign vga_r = rgb_r;
    assign vga_g = rgb_g;
    assign vga_b = rgb_b;

endmodule