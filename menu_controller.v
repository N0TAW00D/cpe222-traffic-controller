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
    output reg [7:0] n_duration,
    output reg [7:0] s_duration,
    output reg [7:0] w_duration,
    output reg [7:0] e_duration,
    output reg [7:0] yellow_duration,
    output reg [7:0] red_holding,
    output reg [1:0] sim_state
);

    // Menu item indices
    parameter MENU_SETTING_HEADER = 4'd0;
    parameter MENU_N_DUR = 4'd1;
    parameter MENU_S_DUR = 4'd2;
    parameter MENU_W_DUR = 4'd3;
    parameter MENU_E_DUR = 4'd4;
    parameter MENU_YELLOW_DUR = 4'd5;
    parameter MENU_RED_HOLD = 4'd6;
    parameter MENU_BLANK = 4'd7;
    parameter MENU_SIM_HEADER = 4'd8;
    parameter MENU_PLAY = 4'd9;
    parameter MENU_PAUSE = 4'd10;
    parameter MENU_STOP = 4'd11;

    // Simulation states
    parameter SIM_STOP = 2'd0;
    parameter SIM_PLAY = 2'd1;
    parameter SIM_PAUSE = 2'd2;

    // Menu state management
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            menu_sel <= MENU_N_DUR;     // Start at first selectable item
            n_duration <= 8'd15;         // Default 15 seconds
            s_duration <= 8'd15;         // Default 15 seconds
            w_duration <= 8'd15;         // Default 15 seconds
            e_duration <= 8'd15;         // Default 15 seconds
            yellow_duration <= 8'd5;         // Default 5 seconds
            red_holding <= 8'd3;             // Default 3 seconds
            sim_state <= SIM_STOP;           // Default stopped
        end else begin
            // Handle up button - move up in menu (skip headers and blank)
            if (btn_up_pressed) begin
                case (menu_sel)
                    MENU_N_DUR:      menu_sel <= MENU_STOP;
                    MENU_S_DUR:      menu_sel <= MENU_N_DUR;
                    MENU_W_DUR:      menu_sel <= MENU_S_DUR;
                    MENU_E_DUR:      menu_sel <= MENU_W_DUR;
                    MENU_YELLOW_DUR: menu_sel <= MENU_E_DUR;
                    MENU_RED_HOLD:   menu_sel <= MENU_YELLOW_DUR;
                    MENU_PLAY:       menu_sel <= MENU_RED_HOLD;
                    MENU_PAUSE:      menu_sel <= MENU_PLAY;
                    MENU_STOP:       menu_sel <= MENU_PAUSE;
                    default:         menu_sel <= MENU_N_DUR;
                endcase
            end

            // Handle down button - move down in menu (skip headers and blank)
            if (btn_down_pressed) begin
                case (menu_sel)
                    MENU_N_DUR:      menu_sel <= MENU_S_DUR;
                    MENU_S_DUR:      menu_sel <= MENU_W_DUR;
                    MENU_W_DUR:      menu_sel <= MENU_E_DUR;
                    MENU_E_DUR:      menu_sel <= MENU_YELLOW_DUR;
                    MENU_YELLOW_DUR: menu_sel <= MENU_RED_HOLD;
                    MENU_RED_HOLD:   menu_sel <= MENU_PLAY;
                    MENU_PLAY:       menu_sel <= MENU_PAUSE;
                    MENU_PAUSE:      menu_sel <= MENU_STOP;
                    MENU_STOP:       menu_sel <= MENU_N_DUR;
                    default:         menu_sel <= MENU_N_DUR;
                endcase
            end

            // Handle left button - decrease values
            if (btn_left_pressed) begin
                case (menu_sel)
                    MENU_N_DUR:      if (n_duration > 1) n_duration <= n_duration - 1;
                    MENU_S_DUR:      if (s_duration > 1) s_duration <= s_duration - 1;
                    MENU_W_DUR:      if (w_duration > 1) w_duration <= w_duration - 1;
                    MENU_E_DUR:      if (e_duration > 1) e_duration <= e_duration - 1;
                    MENU_YELLOW_DUR: if (yellow_duration > 1) yellow_duration <= yellow_duration - 1;
                    MENU_RED_HOLD:   if (red_holding > 1)     red_holding <= red_holding - 1;
                endcase
            end

            // Handle right button - increase values
            if (btn_right_pressed) begin
                case (menu_sel)
                    MENU_N_DUR:      if (n_duration < 99) n_duration <= n_duration + 1;
                    MENU_S_DUR:      if (s_duration < 99) s_duration <= s_duration + 1;
                    MENU_W_DUR:      if (w_duration < 99) w_duration <= w_duration + 1;
                    MENU_E_DUR:      if (e_duration < 99) e_duration <= e_duration + 1;
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
