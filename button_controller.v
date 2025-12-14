`timescale 1ns / 1ps

module button_controller(
    input wire clk,
    input wire reset,
    input wire btn_up,
    input wire btn_down,
    input wire btn_left,
    input wire btn_right,
    input wire btn_center,
    output wire btn_up_pressed,
    output wire btn_down_pressed,
    output wire btn_left_pressed,
    output wire btn_right_pressed,
    output wire btn_center_pressed
);

    // Button debouncing
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

    // Output individual button press signals
    assign btn_up_pressed = btn_pressed[0];
    assign btn_down_pressed = btn_pressed[1];
    assign btn_left_pressed = btn_pressed[2];
    assign btn_right_pressed = btn_pressed[3];
    assign btn_center_pressed = btn_pressed[4];

endmodule
