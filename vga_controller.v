`timescale 1ns / 1ps

module vga_controller(
    input wire clk,           // 100MHz system clock
    input wire reset,
    output reg hsync,
    output reg vsync,
    output wire video_on,
    output wire [9:0] x,
    output wire [9:0] y
);

    // VGA 640x480 @ 60Hz timing parameters (25MHz pixel clock)
    // Horizontal timing (pixels)
    parameter H_DISPLAY    = 640;  // Display area
    parameter H_FRONT      = 16;   // Front porch
    parameter H_SYNC       = 96;   // Sync pulse
    parameter H_BACK       = 48;   // Back porch
    parameter H_TOTAL      = 800;  // Total horizontal pixels
    
    // Vertical timing (lines)
    parameter V_DISPLAY    = 480;  // Display area
    parameter V_FRONT      = 10;   // Front porch
    parameter V_SYNC       = 2;    // Sync pulse
    parameter V_BACK       = 33;   // Back porch
    parameter V_TOTAL      = 525;  // Total vertical lines
    
    // Generate 25MHz pixel clock from 100MHz system clock
    reg [1:0] pixel_clk_count;
    reg pixel_clk;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pixel_clk_count <= 0;
            pixel_clk <= 0;
        end else begin
            pixel_clk_count <= pixel_clk_count + 1;
            if (pixel_clk_count == 1) begin
                pixel_clk <= ~pixel_clk;
                pixel_clk_count <= 0;
            end
        end
    end
    
    // Horizontal and vertical counters
    reg [9:0] h_count;
    reg [9:0] v_count;
    
    // Pixel counters
    always @(posedge pixel_clk or posedge reset) begin
        if (reset) begin
            h_count <= 0;
            v_count <= 0;
        end else begin
            if (h_count < H_TOTAL - 1) begin
                h_count <= h_count + 1;
            end else begin
                h_count <= 0;
                if (v_count < V_TOTAL - 1) begin
                    v_count <= v_count + 1;
                end else begin
                    v_count <= 0;
                end
            end
        end
    end
    
    // Horizontal sync signal (active low)
    always @(posedge pixel_clk or posedge reset) begin
        if (reset)
            hsync <= 1;
        else
            hsync <= (h_count >= (H_DISPLAY + H_FRONT)) && 
                     (h_count < (H_DISPLAY + H_FRONT + H_SYNC)) ? 0 : 1;
    end
    
    // Vertical sync signal (active low)
    always @(posedge pixel_clk or posedge reset) begin
        if (reset)
            vsync <= 1;
        else
            vsync <= (v_count >= (V_DISPLAY + V_FRONT)) && 
                     (v_count < (V_DISPLAY + V_FRONT + V_SYNC)) ? 0 : 1;
    end
    
    // Video on signal (in display area)
    assign video_on = (h_count < H_DISPLAY) && (v_count < V_DISPLAY);
    
    // Current pixel coordinates
    assign x = h_count;
    assign y = v_count;

endmodule