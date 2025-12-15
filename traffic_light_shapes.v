`timescale 1ns / 1ps

module traffic_light_shapes(
    input wire [9:0] x,
    input wire [9:0] y,
    // Traffic light control signals
    input wire N_red,
    input wire N_yellow,
    input wire N_green,
    input wire E_red,
    input wire E_yellow,
    input wire E_green,
    input wire S_red,
    input wire S_yellow,
    input wire S_green,
    input wire W_red,
    input wire W_yellow,
    input wire W_green,
    // Output signals
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
    assign blue_square = (x >= 50) && (x < 50) && (y >= 350) && (y < 350);
    assign yellow_square = (x >= 500) && (x < 500) && (y >= 350) && (y < 350);

    // =======================================================================
    // SMALL SQUARES AS TRAFFIC LIGHTS
    // CHECK LOGIC - Small square to direction mapping
    // =======================================================================
    // Small squares represent traffic lights for each direction:
    // top_square4 = North light (position: x=170-180, y=110-120)
    // nd_square1 = West light (position: x=110-120, y=130-140)
    // th_square2 = East light (position: x=190-200, y=170-180)
    // bot_square2 = South light (position: x=130-140, y=190-200)

    // Determine color for each small square based on traffic light state
    wire N_square_red = top_square4 && N_red;
    wire N_square_yellow = top_square4 && N_yellow;
    wire N_square_green = top_square4 && N_green;

    wire W_square_red = nd_square1 && W_red;
    wire W_square_yellow = nd_square1 && W_yellow;
    wire W_square_green = nd_square1 && W_green;

    wire E_square_red = th_square2 && E_red;
    wire E_square_yellow = th_square2 && E_yellow;
    wire E_square_green = th_square2 && E_green;

    wire S_square_red = bot_square2 && S_red;
    wire S_square_yellow = bot_square2 && S_yellow;
    wire S_square_green = bot_square2 && S_green;

    // Combined color signals for all traffic light squares
    wire is_red_light = N_square_red || W_square_red || E_square_red || S_square_red;
    wire is_yellow_light = N_square_yellow || W_square_yellow || E_square_yellow || S_square_yellow;
    wire is_green_light = N_square_green || W_square_green || E_square_green || S_square_green;

    // Check if any small square is a traffic light
    wire is_traffic_light_square = top_square4 || nd_square1 || th_square2 || bot_square2;

    // =======================================================================
    // Shape active signal
    wire white_shape;
    assign white_shape = white_main_sections;  // Only main sections are white, not the small squares

    assign shape_active = white_shape || blue_square || yellow_square || is_traffic_light_square;

    // =======================================================================
    // RGB output
    // CHECK LOGIC - Color output priority and RGB values
    // Priority: Traffic lights > white shapes > colored test squares > black
    assign shape_r = is_red_light ? 4'b1111 :        // Red light = full red
                    (is_yellow_light ? 4'b1111 :      // Yellow light = full red
                    (white_shape ? 4'b1111 :           // White shape = full red
                    (yellow_square ? 4'b1111 : 4'b0000))); // Yellow test square

    assign shape_g = is_yellow_light ? 4'b1111 :     // Yellow light = full green
                    (is_green_light ? 4'b1111 :       // Green light = full green
                    (white_shape ? 4'b1111 :           // White shape = full green
                    (yellow_square ? 4'b1111 : 4'b0000))); // Yellow test square

    assign shape_b = white_shape ? 4'b1111 :         // White shape = full blue
                    (blue_square ? 4'b1111 : 4'b0000);    // Blue test square

endmodule
