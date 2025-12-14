`timescale 1ns / 1ps

module vga_display_top(
    input wire clk,              // 100MHz system clock
    input wire reset,
    input wire btn_up,           // Button for menu navigation up
    input wire btn_down,         // Button for menu navigation down
    input wire btn_left,         // Button for decrease value
    input wire btn_right,        // Button for increase value
    input wire btn_center,       // Button for enter/select
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

    // ========================================================================
    // BUTTON DEBOUNCING AND EDGE DETECTION
    // ========================================================================
    reg [19:0] debounce_counter;
    reg [4:0] btn_stable;           // Stable button states
    reg [4:0] btn_prev;             // Previous button states
    wire [4:0] btn_pressed;         // Button press edge detection

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            debounce_counter <= 0;
            btn_stable <= 5'b00000;
            btn_prev <= 5'b00000;
        end else begin
            debounce_counter <= debounce_counter + 1;

            // Debounce every ~10ms (at 100MHz: 2^20 cycles ≈ 10ms)
            if (debounce_counter == 0) begin
                btn_stable <= {btn_center, btn_right, btn_left, btn_down, btn_up};
            end

            btn_prev <= btn_stable;
        end
    end

    // Edge detection - trigger on rising edge
    assign btn_pressed = btn_stable & ~btn_prev;

    // ========================================================================
    // MENU STATE MANAGEMENT
    // ========================================================================
    reg [3:0] menu_sel;             // Current menu selection (0-8)
    reg [7:0] green_duration;       // Green light duration in seconds
    reg [7:0] yellow_duration;      // Yellow light duration in seconds
    reg [7:0] red_holding;          // Red holding time in seconds
    reg [1:0] sim_state;            // 0=Stop, 1=Play, 2=Pause

    // Menu item indices
    parameter MENU_SETTING_HEADER = 4'd0;
    parameter MENU_GREEN_DUR = 4'd1;
    parameter MENU_YELLOW_DUR = 4'd2;
    parameter MENU_RED_HOLD = 4'd3;
    parameter MENU_BLANK = 4'd4;
    parameter MENU_SIM_HEADER = 4'd5;
    parameter MENU_PLAY = 4'd6;
    parameter MENU_PAUSE = 4'd7;
    parameter MENU_STOP = 4'd8;

    // Initialize menu state
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            menu_sel <= MENU_GREEN_DUR;     // Start at first selectable item
            green_duration <= 8'd15;         // Default 15 seconds
            yellow_duration <= 8'd5;         // Default 5 seconds
            red_holding <= 8'd3;             // Default 3 seconds
            sim_state <= 2'd0;               // Default stopped
        end else begin
            // Handle up button - move up in menu (skip headers and blank)
            if (btn_pressed[0]) begin  // btn_up
                case (menu_sel)
                    MENU_GREEN_DUR:  menu_sel <= MENU_STOP;
                    MENU_YELLOW_DUR: menu_sel <= MENU_GREEN_DUR;
                    MENU_RED_HOLD:   menu_sel <= MENU_YELLOW_DUR;
                    MENU_PLAY:       menu_sel <= MENU_RED_HOLD;
                    MENU_PAUSE:      menu_sel <= MENU_PLAY;
                    MENU_STOP:       menu_sel <= MENU_PAUSE;
                    default:         menu_sel <= MENU_GREEN_DUR;
                endcase
            end

            // Handle down button - move down in menu (skip headers and blank)
            if (btn_pressed[1]) begin  // btn_down
                case (menu_sel)
                    MENU_GREEN_DUR:  menu_sel <= MENU_YELLOW_DUR;
                    MENU_YELLOW_DUR: menu_sel <= MENU_RED_HOLD;
                    MENU_RED_HOLD:   menu_sel <= MENU_PLAY;
                    MENU_PLAY:       menu_sel <= MENU_PAUSE;
                    MENU_PAUSE:      menu_sel <= MENU_STOP;
                    MENU_STOP:       menu_sel <= MENU_GREEN_DUR;
                    default:         menu_sel <= MENU_GREEN_DUR;
                endcase
            end

            // Handle left button - decrease values
            if (btn_pressed[2]) begin  // btn_left
                case (menu_sel)
                    MENU_GREEN_DUR:  if (green_duration > 1)  green_duration <= green_duration - 1;
                    MENU_YELLOW_DUR: if (yellow_duration > 1) yellow_duration <= yellow_duration - 1;
                    MENU_RED_HOLD:   if (red_holding > 1)     red_holding <= red_holding - 1;
                endcase
            end

            // Handle right button - increase values
            if (btn_pressed[3]) begin  // btn_right
                case (menu_sel)
                    MENU_GREEN_DUR:  if (green_duration < 99)  green_duration <= green_duration + 1;
                    MENU_YELLOW_DUR: if (yellow_duration < 99) yellow_duration <= yellow_duration + 1;
                    MENU_RED_HOLD:   if (red_holding < 99)     red_holding <= red_holding + 1;
                endcase
            end

            // Handle center button - select action
            if (btn_pressed[4]) begin  // btn_center
                case (menu_sel)
                    MENU_PLAY:  sim_state <= 2'd1;  // Play
                    MENU_PAUSE: sim_state <= 2'd2;  // Pause
                    MENU_STOP:  sim_state <= 2'd0;  // Stop
                endcase
            end
        end
    end
    
    // Text display parameters
    parameter TEXT_X = 20;
    parameter TEXT_Y = 20;
    parameter CHAR_WIDTH = 9;   // 8 pixels + 1 spacing
    parameter CHAR_HEIGHT = 8;
    parameter LINE_HEIGHT = 12; // Lines are 12 pixels apart

    // Menu display parameters
    parameter MENU_X = 300;
    parameter MENU_Y = 50;
    
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
    wire [2:0] text_char_row;   // Row within character for title text
    wire text_pixel;

    assign in_text_region = (x >= TEXT_X) &&
                           (x < TEXT_X + TEXT_LENGTH * CHAR_WIDTH) &&
                           (y >= TEXT_Y) &&
                           (y < TEXT_Y + CHAR_HEIGHT);

    assign char_index = (x - TEXT_X) / CHAR_WIDTH;
    assign pixel_col = (x - TEXT_X) % CHAR_WIDTH;
    assign text_char_row = y - TEXT_Y;
    
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

    // Extract the pixel at current column (only if within 8-pixel font width)
    assign text_pixel = (pixel_col < 8) ? font_pixels[7 - pixel_col] : 1'b0;

    // ========================================================================
    // MENU TEXT RENDERING
    // ========================================================================
    wire in_menu_region;
    wire [3:0] menu_line;           // Which menu line (0-8)
    wire [5:0] menu_char_pos;       // Character position in current line
    wire [2:0] menu_pixel_col;      // Pixel column within character
    wire [2:0] menu_char_row;       // Row within character
    wire menu_text_pixel;

    // Menu dimensions
    parameter MENU_MAX_CHARS = 30;  // Maximum characters per line
    parameter MENU_NUM_LINES = 9;   // Number of menu lines

    // Calculate menu region
    wire [3:0] menu_line_offset;
    assign menu_line_offset = (y - MENU_Y) % LINE_HEIGHT;

    assign in_menu_region = (x >= MENU_X) &&
                           (x < MENU_X + MENU_MAX_CHARS * CHAR_WIDTH) &&
                           (y >= MENU_Y) &&
                           (y < MENU_Y + MENU_NUM_LINES * LINE_HEIGHT) &&
                           (menu_line_offset < CHAR_HEIGHT);  // Only render in first 8 pixels of each line

    assign menu_line = (y - MENU_Y) / LINE_HEIGHT;
    assign menu_char_pos = (x - MENU_X) / CHAR_WIDTH;
    assign menu_pixel_col = (x - MENU_X) % CHAR_WIDTH;
    assign menu_char_row = menu_line_offset[2:0];  // Only use first 8 pixels (0-7)

    // Convert number to two-digit character codes
    function [5:0] digit_to_char;
        input [3:0] digit;
        begin
            digit_to_char = 6'd27 + digit;  // 0-9 are codes 27-36
        end
    endfunction

    // Extract tens and ones digits
    wire [3:0] green_tens = green_duration / 10;
    wire [3:0] green_ones = green_duration % 10;
    wire [3:0] yellow_tens = yellow_duration / 10;
    wire [3:0] yellow_ones = yellow_duration % 10;
    wire [3:0] red_tens = red_holding / 10;
    wire [3:0] red_ones = red_holding % 10;

    // Character lookup for menu text
    reg [5:0] menu_char_code;
    always @(*) begin
        menu_char_code = 6'd0;  // Default space

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

            // Line 1: "> Green duration    15 sec" or "  Green duration..."
            4'd1: begin
                case (menu_char_pos)
                    6'd0:  menu_char_code = (menu_sel == MENU_GREEN_DUR) ? 6'd37 : 6'd0; // > or space
                    6'd1:  menu_char_code = 6'd0;  // Space
                    6'd2:  menu_char_code = 6'd7;  // G
                    6'd3:  menu_char_code = 6'd18; // R
                    6'd4:  menu_char_code = 6'd5;  // E
                    6'd5:  menu_char_code = 6'd5;  // E
                    6'd6:  menu_char_code = 6'd14; // N
                    6'd7:  menu_char_code = 6'd0;  // Space
                    6'd8:  menu_char_code = 6'd4;  // D
                    6'd9:  menu_char_code = 6'd21; // U
                    6'd10: menu_char_code = 6'd18; // R
                    6'd11: menu_char_code = 6'd1;  // A
                    6'd12: menu_char_code = 6'd20; // T
                    6'd13: menu_char_code = 6'd9;  // I
                    6'd14: menu_char_code = 6'd15; // O
                    6'd15: menu_char_code = 6'd14; // N
                    6'd16: menu_char_code = 6'd0;  // Space
                    6'd17: menu_char_code = 6'd0;  // Space
                    6'd18: menu_char_code = 6'd0;  // Space
                    6'd19: menu_char_code = 6'd0;  // Space
                    6'd20: menu_char_code = digit_to_char(green_tens);  // Tens digit
                    6'd21: menu_char_code = digit_to_char(green_ones);  // Ones digit
                    6'd22: menu_char_code = 6'd0;  // Space
                    6'd23: menu_char_code = 6'd19; // S
                    6'd24: menu_char_code = 6'd5;  // E
                    6'd25: menu_char_code = 6'd3;  // C
                    default: menu_char_code = 6'd0;
                endcase
            end

            // Line 2: "  Yellow duration    5 sec"
            4'd2: begin
                case (menu_char_pos)
                    6'd0:  menu_char_code = (menu_sel == MENU_YELLOW_DUR) ? 6'd37 : 6'd0;
                    6'd1:  menu_char_code = 6'd0;  // Space
                    6'd2:  menu_char_code = 6'd25; // Y
                    6'd3:  menu_char_code = 6'd5;  // E
                    6'd4:  menu_char_code = 6'd12; // L
                    6'd5:  menu_char_code = 6'd12; // L
                    6'd6:  menu_char_code = 6'd15; // O
                    6'd7:  menu_char_code = 6'd23; // W
                    6'd8:  menu_char_code = 6'd0;  // Space
                    6'd9:  menu_char_code = 6'd4;  // D
                    6'd10: menu_char_code = 6'd21; // U
                    6'd11: menu_char_code = 6'd18; // R
                    6'd12: menu_char_code = 6'd1;  // A
                    6'd13: menu_char_code = 6'd20; // T
                    6'd14: menu_char_code = 6'd9;  // I
                    6'd15: menu_char_code = 6'd15; // O
                    6'd16: menu_char_code = 6'd14; // N
                    6'd17: menu_char_code = 6'd0;  // Space
                    6'd18: menu_char_code = 6'd0;  // Space
                    6'd19: menu_char_code = 6'd0;  // Space
                    6'd20: menu_char_code = digit_to_char(yellow_tens);
                    6'd21: menu_char_code = digit_to_char(yellow_ones);
                    6'd22: menu_char_code = 6'd0;  // Space
                    6'd23: menu_char_code = 6'd19; // S
                    6'd24: menu_char_code = 6'd5;  // E
                    6'd25: menu_char_code = 6'd3;  // C
                    default: menu_char_code = 6'd0;
                endcase
            end

            // Line 3: "  Red Holding        3 sec"
            4'd3: begin
                case (menu_char_pos)
                    6'd0:  menu_char_code = (menu_sel == MENU_RED_HOLD) ? 6'd37 : 6'd0;
                    6'd1:  menu_char_code = 6'd0;  // Space
                    6'd2:  menu_char_code = 6'd18; // R
                    6'd3:  menu_char_code = 6'd5;  // E
                    6'd4:  menu_char_code = 6'd4;  // D
                    6'd5:  menu_char_code = 6'd0;  // Space
                    6'd6:  menu_char_code = 6'd8;  // H
                    6'd7:  menu_char_code = 6'd15; // O
                    6'd8:  menu_char_code = 6'd12; // L
                    6'd9:  menu_char_code = 6'd4;  // D
                    6'd10: menu_char_code = 6'd9;  // I
                    6'd11: menu_char_code = 6'd14; // N
                    6'd12: menu_char_code = 6'd7;  // G
                    6'd13: menu_char_code = 6'd0;  // Space
                    6'd14: menu_char_code = 6'd0;  // Space
                    6'd15: menu_char_code = 6'd0;  // Space
                    6'd16: menu_char_code = 6'd0;  // Space
                    6'd17: menu_char_code = 6'd0;  // Space
                    6'd18: menu_char_code = 6'd0;  // Space
                    6'd19: menu_char_code = 6'd0;  // Space
                    6'd20: menu_char_code = digit_to_char(red_tens);
                    6'd21: menu_char_code = digit_to_char(red_ones);
                    6'd22: menu_char_code = 6'd0;  // Space
                    6'd23: menu_char_code = 6'd19; // S
                    6'd24: menu_char_code = 6'd5;  // E
                    6'd25: menu_char_code = 6'd3;  // C
                    default: menu_char_code = 6'd0;
                endcase
            end

            // Line 4: Blank line
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

            // Line 6: "  Play"
            4'd6: begin
                case (menu_char_pos)
                    6'd0:  menu_char_code = (menu_sel == MENU_PLAY) ? 6'd37 : 6'd0;
                    6'd1:  menu_char_code = 6'd0;  // Space
                    6'd2:  menu_char_code = 6'd16; // P
                    6'd3:  menu_char_code = 6'd12; // L
                    6'd4:  menu_char_code = 6'd1;  // A
                    6'd5:  menu_char_code = 6'd25; // Y
                    default: menu_char_code = 6'd0;
                endcase
            end

            // Line 7: "  Pause"
            4'd7: begin
                case (menu_char_pos)
                    6'd0:  menu_char_code = (menu_sel == MENU_PAUSE) ? 6'd37 : 6'd0;
                    6'd1:  menu_char_code = 6'd0;  // Space
                    6'd2:  menu_char_code = 6'd16; // P
                    6'd3:  menu_char_code = 6'd1;  // A
                    6'd4:  menu_char_code = 6'd21; // U
                    6'd5:  menu_char_code = 6'd19; // S
                    6'd6:  menu_char_code = 6'd5;  // E
                    default: menu_char_code = 6'd0;
                endcase
            end

            // Line 8: "  Stop"
            4'd8: begin
                case (menu_char_pos)
                    6'd0:  menu_char_code = (menu_sel == MENU_STOP) ? 6'd37 : 6'd0;
                    6'd1:  menu_char_code = 6'd0;  // Space
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

    // Use the same font ROM, but multiplex the input
    wire [5:0] final_char_code;
    wire [2:0] final_char_row;

    assign final_char_code = in_menu_region ? menu_char_code : text_char_code;
    assign final_char_row = in_menu_region ? menu_char_row : text_char_row;

    assign char_code = final_char_code;
    assign char_row = final_char_row;

    // Extract menu pixel
    assign menu_text_pixel = (menu_pixel_col < 8) ? font_pixels[7 - menu_pixel_col] : 1'b0;
    
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
            // White text (title)
            rgb_r = 4'b1111;
            rgb_g = 4'b1111;
            rgb_b = 4'b1111;
        end else if (in_menu_region && menu_text_pixel) begin
            // White text (menu)
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