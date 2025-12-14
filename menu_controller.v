`timescale 1ns / 1ps

module menu_controller(
    input wire clk,
    input wire reset,
    input wire btn_up_pressed,
    input wire btn_down_pressed,
    input wire btn_left_pressed,
    input wire btn_right_pressed,
    input wire btn_center_pressed,
    output reg [3:0] menu_sel,
    output reg [7:0] green_duration,
    output reg [7:0] yellow_duration,
    output reg [7:0] red_holding,
    output reg [1:0] sim_state
);

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

    // Simulation states
    parameter SIM_STOP = 2'd0;
    parameter SIM_PLAY = 2'd1;
    parameter SIM_PAUSE = 2'd2;

    // Menu state management
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            menu_sel <= MENU_GREEN_DUR;     // Start at first selectable item
            green_duration <= 8'd15;         // Default 15 seconds
            yellow_duration <= 8'd5;         // Default 5 seconds
            red_holding <= 8'd3;             // Default 3 seconds
            sim_state <= SIM_STOP;           // Default stopped
        end else begin
            // Handle up button - move up in menu (skip headers and blank)
            if (btn_up_pressed) begin
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
            if (btn_down_pressed) begin
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
            if (btn_left_pressed) begin
                case (menu_sel)
                    MENU_GREEN_DUR:  if (green_duration > 1)  green_duration <= green_duration - 1;
                    MENU_YELLOW_DUR: if (yellow_duration > 1) yellow_duration <= yellow_duration - 1;
                    MENU_RED_HOLD:   if (red_holding > 1)     red_holding <= red_holding - 1;
                endcase
            end

            // Handle right button - increase values
            if (btn_right_pressed) begin
                case (menu_sel)
                    MENU_GREEN_DUR:  if (green_duration < 99)  green_duration <= green_duration + 1;
                    MENU_YELLOW_DUR: if (yellow_duration < 99) yellow_duration <= yellow_duration + 1;
                    MENU_RED_HOLD:   if (red_holding < 99)     red_holding <= red_holding + 1;
                endcase
            end

            // Handle center button - select action
            if (btn_center_pressed) begin
                case (menu_sel)
                    MENU_PLAY:  sim_state <= SIM_PLAY;   // Play
                    MENU_PAUSE: sim_state <= SIM_PAUSE;  // Pause
                    MENU_STOP:  sim_state <= SIM_STOP;   // Stop
                endcase
            end
        end
    end

endmodule
