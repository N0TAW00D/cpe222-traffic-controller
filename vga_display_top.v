`timescale 1ns / 1ps

module vga_display_top(
    input wire clk,              // 100MHz system clock
    input wire reset,            // SW15 - rightmost switch
    input wire btn_up,           // Button for menu navigation up
    input wire btn_down,         // Button for menu navigation down
    input wire btn_left,         // Button for decrease value
    input wire btn_right,        // Button for increase value
    input wire btn_center,       // Button for enter/select
    input wire [14:0] switches,  // Switches SW0-SW14 for traffic light control
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
    // BUTTON CONTROLLER
    // ========================================================================
    wire btn_up_pressed, btn_down_pressed, btn_left_pressed;
    wire btn_right_pressed, btn_center_pressed;

    button_controller btn_ctrl(
        .clk(clk),
        .reset(reset),
        .btn_up(btn_up),
        .btn_down(btn_down),
        .btn_left(btn_left),
        .btn_right(btn_right),
        .btn_center(btn_center),
        .btn_up_pressed(btn_up_pressed),
        .btn_down_pressed(btn_down_pressed),
        .btn_left_pressed(btn_left_pressed),
        .btn_right_pressed(btn_right_pressed),
        .btn_center_pressed(btn_center_pressed)
    );

    // ========================================================================
    // MENU CONTROLLER
    // ========================================================================
    wire [3:0] menu_sel;
    wire [7:0] green_duration, yellow_duration, red_holding;
    wire [1:0] sim_state;

    menu_controller menu_ctrl(
        .clk(clk),
        .reset(reset),
        .btn_up_pressed(btn_up_pressed),
        .btn_down_pressed(btn_down_pressed),
        .btn_left_pressed(btn_left_pressed),
        .btn_right_pressed(btn_right_pressed),
        .btn_center_pressed(btn_center_pressed),
        .menu_sel(menu_sel),
        .green_duration(green_duration),
        .yellow_duration(yellow_duration),
        .red_holding(red_holding),
        .sim_state(sim_state)
    );

    // ========================================================================
    // TRAFFIC LIGHT CONTROL
    // ========================================================================
    wire N_red, N_yellow, N_green;
    wire E_red, E_yellow, E_green;
    wire S_red, S_yellow, S_green;
    wire W_red, W_yellow, W_green;
    wire [7:0] countdown_sec;
    wire [1:0] active_direction;

    // SW15 is used for reset, so tie switches[15] to reset value
    wire [15:0] switches_internal;
    assign switches_internal = {reset, switches[14:0]};

    // Decode mode from switches
    wire mode_auto = ~switches[0];  // 0=auto, 1=manual
    wire manual_yellow_transition;

    traffic_light_control tl_ctrl(
        .clk(clk),
        .rst(reset),
        .switches(switches_internal),
        .green_duration(green_duration),
        .yellow_duration(yellow_duration),
        .red_holding(red_holding),
        .N_red(N_red),
        .N_yellow(N_yellow),
        .N_green(N_green),
        .E_red(E_red),
        .E_yellow(E_yellow),
        .E_green(E_green),
        .S_red(S_red),
        .S_yellow(S_yellow),
        .S_green(S_green),
        .W_red(W_red),
        .W_yellow(W_yellow),
        .W_green(W_green),
        .countdown_sec(countdown_sec),
        .active_direction(active_direction),
        .manual_yellow_transition(manual_yellow_transition)
    );

    // ========================================================================
    // FONT ROM
    // ========================================================================
    wire [5:0] char_code;
    wire [2:0] char_row;
    wire [7:0] font_pixels;

    font_rom font(
        .clk(clk),
        .char_code(char_code),
        .row(char_row),
        .pixels(font_pixels)
    );

    // ========================================================================
    // TEXT RENDERER
    // ========================================================================
    wire text_pixel;

    text_renderer txt_render(
        .clk(clk),
        .x(x),
        .y(y),
        .menu_sel(menu_sel),
        .green_duration(green_duration),
        .yellow_duration(yellow_duration),
        .red_holding(red_holding),
        .countdown_sec(countdown_sec),
        .active_direction(active_direction),
        .mode_auto(mode_auto),
        .font_pixels(font_pixels),
        .text_pixel(text_pixel),
        .char_code(char_code),
        .char_row(char_row)
    );

    // ========================================================================
    // TRAFFIC LIGHT SHAPES
    // ========================================================================
    wire shape_active;
    wire [3:0] shape_r, shape_g, shape_b;

    traffic_light_shapes shapes(
        .x(x),
        .y(y),
        .N_red(N_red),
        .N_yellow(N_yellow),
        .N_green(N_green),
        .E_red(E_red),
        .E_yellow(E_yellow),
        .E_green(E_green),
        .S_red(S_red),
        .S_yellow(S_yellow),
        .S_green(S_green),
        .W_red(W_red),
        .W_yellow(W_yellow),
        .W_green(W_green),
        .shape_active(shape_active),
        .shape_r(shape_r),
        .shape_g(shape_g),
        .shape_b(shape_b)
    );

    // ========================================================================
    // RGB OUTPUT LOGIC
    // ========================================================================
    reg [3:0] rgb_r, rgb_g, rgb_b;

    always @(*) begin
        if (!video_on) begin
            // Blanking period - output black
            rgb_r = 4'b0000;
            rgb_g = 4'b0000;
            rgb_b = 4'b0000;
        end else if (text_pixel) begin
            // White text (title and menu)
            rgb_r = 4'b1111;
            rgb_g = 4'b1111;
            rgb_b = 4'b1111;
        end else if (shape_active) begin
            // Traffic light shapes
            rgb_r = shape_r;
            rgb_g = shape_g;
            rgb_b = shape_b;
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
