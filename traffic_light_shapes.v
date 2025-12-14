`timescale 1ns / 1ps

module traffic_light_shapes(
    input wire [9:0] x,
    input wire [9:0] y,
    output wire shape_active,
    output wire [3:0] shape_r,
    output wire [3:0] shape_g,
    output wire [3:0] shape_b
);

    // White shape components
    wire top_square4;
    wire nd_square1;
    wire th_square2;
    wire bot_square2;
    wire white_main_sections;
    wire top_row_main, row3_bars, bot_row_main;

    // Colored squares
    wire blue_square, yellow_square;

    // =======================================================================
    // TOP ROW - Main sections
    assign top_row_main = ((x >= 50) && (x < 120) && (y >= 50) && (y < 120)) ||
                          ((x >= 150) && (x < 160) && (y >= 50) && (y < 120)) ||
                          ((x >= 190) && (x < 260) && (y >= 50) && (y < 120));

    // TOP ROW - Independent connectors
    assign top_square4 = (x >= 170) && (x < 180) && (y >= 110) && (y < 120);

    // =======================================================================
    // ROW 2 - Independent connectors
    assign nd_square1 = (x >= 110) && (x < 120) && (y >= 130) && (y < 140);

    // =======================================================================
    // ROW 3 - Horizontal bars
    assign row3_bars = ((x >= 50) && (x < 120) && (y >= 150) && (y < 160)) ||
                       ((x >= 190) && (x < 260) && (y >= 150) && (y < 160));

    // =======================================================================
    // ROW 4 - Independent connectors
    assign th_square2 = (x >= 190) && (x < 200) && (y >= 170) && (y < 180);

    // =======================================================================
    // BOTTOM ROW - Main sections
    assign bot_row_main = ((x >= 50) && (x < 120) && (y >= 190) && (y < 260)) ||
                          ((x >= 150) && (x < 160) && (y >= 190) && (y < 260)) ||
                          ((x >= 190) && (x < 260) && (y >= 190) && (y < 260));

    // BOTTOM ROW - Independent connectors
    assign bot_square2 = (x >= 130) && (x < 140) && (y >= 190) && (y < 200);

    // =======================================================================
    // Combine all white shape sections
    assign white_main_sections = top_row_main || row3_bars || bot_row_main;

    // =======================================================================
    // Colored squares
    assign blue_square = (x >= 50) && (x < 130) && (y >= 350) && (y < 430);
    assign yellow_square = (x >= 500) && (x < 580) && (y >= 350) && (y < 430);

    // =======================================================================
    // Shape active signal
    wire white_shape;
    assign white_shape = white_main_sections ||
                        top_square4 ||
                        nd_square1 ||
                        th_square2 ||
                        bot_square2;

    assign shape_active = white_shape || blue_square || yellow_square;

    // =======================================================================
    // RGB output
    assign shape_r = white_shape ? 4'b1111 :
                    (yellow_square ? 4'b1111 : 4'b0000);

    assign shape_g = white_shape ? 4'b1111 :
                    (yellow_square ? 4'b1111 : 4'b0000);

    assign shape_b = white_shape ? 4'b1111 :
                    (blue_square ? 4'b1111 : 4'b0000);

endmodule
