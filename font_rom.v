`timescale 1ns / 1ps

module font_rom(
    input wire clk,
    input wire [5:0] char_code,
    input wire [2:0] row,
    output reg [7:0] pixels
);

    always @(posedge clk) begin
        case (char_code)
            6'd0: pixels = 8'b00000000;

            6'd1: case (row)
                3'd0: pixels = 8'b00111100;
                3'd1: pixels = 8'b01100110;
                3'd2: pixels = 8'b01100110;
                3'd3: pixels = 8'b01111110;
                3'd4: pixels = 8'b01100110;
                3'd5: pixels = 8'b01100110;
                3'd6: pixels = 8'b01100110;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd2: case (row)
                3'd0: pixels = 8'b01111100;
                3'd1: pixels = 8'b01100110;
                3'd2: pixels = 8'b01100110;
                3'd3: pixels = 8'b01111100;
                3'd4: pixels = 8'b01100110;
                3'd5: pixels = 8'b01100110;
                3'd6: pixels = 8'b01111100;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd3: case (row)
                3'd0: pixels = 8'b00111100;
                3'd1: pixels = 8'b01100110;
                3'd2: pixels = 8'b01100000;
                3'd3: pixels = 8'b01100000;
                3'd4: pixels = 8'b01100000;
                3'd5: pixels = 8'b01100110;
                3'd6: pixels = 8'b00111100;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd4: case (row)
                3'd0: pixels = 8'b01111000;
                3'd1: pixels = 8'b01101100;
                3'd2: pixels = 8'b01100110;
                3'd3: pixels = 8'b01100110;
                3'd4: pixels = 8'b01100110;
                3'd5: pixels = 8'b01101100;
                3'd6: pixels = 8'b01111000;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd5: case (row)
                3'd0: pixels = 8'b01111110;
                3'd1: pixels = 8'b01100000;
                3'd2: pixels = 8'b01100000;
                3'd3: pixels = 8'b01111100;
                3'd4: pixels = 8'b01100000;
                3'd5: pixels = 8'b01100000;
                3'd6: pixels = 8'b01111110;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd6: case (row)
                3'd0: pixels = 8'b01111110;
                3'd1: pixels = 8'b01100000;
                3'd2: pixels = 8'b01100000;
                3'd3: pixels = 8'b01111100;
                3'd4: pixels = 8'b01100000;
                3'd5: pixels = 8'b01100000;
                3'd6: pixels = 8'b01100000;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd7: case (row)
                3'd0: pixels = 8'b00111100;
                3'd1: pixels = 8'b01100110;
                3'd2: pixels = 8'b01100000;
                3'd3: pixels = 8'b01101110;
                3'd4: pixels = 8'b01100110;
                3'd5: pixels = 8'b01100110;
                3'd6: pixels = 8'b00111100;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd8: case (row)
                3'd0: pixels = 8'b01100110;
                3'd1: pixels = 8'b01100110;
                3'd2: pixels = 8'b01100110;
                3'd3: pixels = 8'b01111110;
                3'd4: pixels = 8'b01100110;
                3'd5: pixels = 8'b01100110;
                3'd6: pixels = 8'b01100110;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd9: case (row)
                3'd0: pixels = 8'b00111100;
                3'd1: pixels = 8'b00011000;
                3'd2: pixels = 8'b00011000;
                3'd3: pixels = 8'b00011000;
                3'd4: pixels = 8'b00011000;
                3'd5: pixels = 8'b00011000;
                3'd6: pixels = 8'b00111100;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd10: case (row)
                3'd0: pixels = 8'b00011110;
                3'd1: pixels = 8'b00001100;
                3'd2: pixels = 8'b00001100;
                3'd3: pixels = 8'b00001100;
                3'd4: pixels = 8'b01001100;
                3'd5: pixels = 8'b01001100;
                3'd6: pixels = 8'b00111000;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd11: case (row)
                3'd0: pixels = 8'b01100110;
                3'd1: pixels = 8'b01101100;
                3'd2: pixels = 8'b01111000;
                3'd3: pixels = 8'b01110000;
                3'd4: pixels = 8'b01111000;
                3'd5: pixels = 8'b01101100;
                3'd6: pixels = 8'b01100110;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd12: case (row)
                3'd0: pixels = 8'b01100000;
                3'd1: pixels = 8'b01100000;
                3'd2: pixels = 8'b01100000;
                3'd3: pixels = 8'b01100000;
                3'd4: pixels = 8'b01100000;
                3'd5: pixels = 8'b01100000;
                3'd6: pixels = 8'b01111110;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd13: case (row)
                3'd0: pixels = 8'b01100011;
                3'd1: pixels = 8'b01110111;
                3'd2: pixels = 8'b01111111;
                3'd3: pixels = 8'b01101011;
                3'd4: pixels = 8'b01100011;
                3'd5: pixels = 8'b01100011;
                3'd6: pixels = 8'b01100011;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd14: case (row)
                3'd0: pixels = 8'b01100010;
                3'd1: pixels = 8'b01110010;
                3'd2: pixels = 8'b01111010;
                3'd3: pixels = 8'b01101110;
                3'd4: pixels = 8'b01100110;
                3'd5: pixels = 8'b01100010;
                3'd6: pixels = 8'b01100010;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd15: case (row)
                3'd0: pixels = 8'b00111100;
                3'd1: pixels = 8'b01100110;
                3'd2: pixels = 8'b01100110;
                3'd3: pixels = 8'b01100110;
                3'd4: pixels = 8'b01100110;
                3'd5: pixels = 8'b01100110;
                3'd6: pixels = 8'b00111100;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd16: case (row)
                3'd0: pixels = 8'b01111100;
                3'd1: pixels = 8'b01100110;
                3'd2: pixels = 8'b01100110;
                3'd3: pixels = 8'b01111100;
                3'd4: pixels = 8'b01100000;
                3'd5: pixels = 8'b01100000;
                3'd6: pixels = 8'b01100000;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd17: case (row)
                3'd0: pixels = 8'b00111100;
                3'd1: pixels = 8'b01100110;
                3'd2: pixels = 8'b01100110;
                3'd3: pixels = 8'b01100110;
                3'd4: pixels = 8'b01100110;
                3'd5: pixels = 8'b00111100;
                3'd6: pixels = 8'b00001110;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd18: case (row)
                3'd0: pixels = 8'b01111100;
                3'd1: pixels = 8'b01100110;
                3'd2: pixels = 8'b01100110;
                3'd3: pixels = 8'b01111100;
                3'd4: pixels = 8'b01111000;
                3'd5: pixels = 8'b01101100;
                3'd6: pixels = 8'b01100110;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd19: case (row)
                3'd0: pixels = 8'b00111100;
                3'd1: pixels = 8'b01100110;
                3'd2: pixels = 8'b01100000;
                3'd3: pixels = 8'b00111100;
                3'd4: pixels = 8'b00000110;
                3'd5: pixels = 8'b01100110;
                3'd6: pixels = 8'b00111100;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd20: case (row)
                3'd0: pixels = 8'b01111110;
                3'd1: pixels = 8'b00011000;
                3'd2: pixels = 8'b00011000;
                3'd3: pixels = 8'b00011000;
                3'd4: pixels = 8'b00011000;
                3'd5: pixels = 8'b00011000;
                3'd6: pixels = 8'b00011000;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd21: case (row)
                3'd0: pixels = 8'b01100110;
                3'd1: pixels = 8'b01100110;
                3'd2: pixels = 8'b01100110;
                3'd3: pixels = 8'b01100110;
                3'd4: pixels = 8'b01100110;
                3'd5: pixels = 8'b01100110;
                3'd6: pixels = 8'b00111100;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd22: case (row)
                3'd0: pixels = 8'b01100110;
                3'd1: pixels = 8'b01100110;
                3'd2: pixels = 8'b01100110;
                3'd3: pixels = 8'b01100110;
                3'd4: pixels = 8'b01100110;
                3'd5: pixels = 8'b00111100;
                3'd6: pixels = 8'b00011000;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd23: case (row)
                3'd0: pixels = 8'b01100011;
                3'd1: pixels = 8'b01100011;
                3'd2: pixels = 8'b01100011;
                3'd3: pixels = 8'b01101011;
                3'd4: pixels = 8'b01111111;
                3'd5: pixels = 8'b01110111;
                3'd6: pixels = 8'b01100011;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd24: case (row)
                3'd0: pixels = 8'b01100110;
                3'd1: pixels = 8'b01100110;
                3'd2: pixels = 8'b00111100;
                3'd3: pixels = 8'b00011000;
                3'd4: pixels = 8'b00111100;
                3'd5: pixels = 8'b01100110;
                3'd6: pixels = 8'b01100110;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd25: case (row)
                3'd0: pixels = 8'b01100110;
                3'd1: pixels = 8'b01100110;
                3'd2: pixels = 8'b01100110;
                3'd3: pixels = 8'b00111100;
                3'd4: pixels = 8'b00011000;
                3'd5: pixels = 8'b00011000;
                3'd6: pixels = 8'b00011000;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd26: case (row)
                3'd0: pixels = 8'b01111110;
                3'd1: pixels = 8'b00000110;
                3'd2: pixels = 8'b00001100;
                3'd3: pixels = 8'b00011000;
                3'd4: pixels = 8'b00110000;
                3'd5: pixels = 8'b01100000;
                3'd6: pixels = 8'b01111110;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd27: case (row)
                3'd0: pixels = 8'b00111100;
                3'd1: pixels = 8'b01100110;
                3'd2: pixels = 8'b01101110;
                3'd3: pixels = 8'b01110110;
                3'd4: pixels = 8'b01100110;
                3'd5: pixels = 8'b01100110;
                3'd6: pixels = 8'b00111100;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd28: case (row)
                3'd0: pixels = 8'b00011000;
                3'd1: pixels = 8'b00111000;
                3'd2: pixels = 8'b00011000;
                3'd3: pixels = 8'b00011000;
                3'd4: pixels = 8'b00011000;
                3'd5: pixels = 8'b00011000;
                3'd6: pixels = 8'b01111110;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd29: case (row)
                3'd0: pixels = 8'b00111100;
                3'd1: pixels = 8'b01100110;
                3'd2: pixels = 8'b00000110;
                3'd3: pixels = 8'b00001100;
                3'd4: pixels = 8'b00110000;
                3'd5: pixels = 8'b01100000;
                3'd6: pixels = 8'b01111110;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd30: case (row)
                3'd0: pixels = 8'b00111100;
                3'd1: pixels = 8'b01100110;
                3'd2: pixels = 8'b00000110;
                3'd3: pixels = 8'b00011100;
                3'd4: pixels = 8'b00000110;
                3'd5: pixels = 8'b01100110;
                3'd6: pixels = 8'b00111100;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd31: case (row)
                3'd0: pixels = 8'b00001100;
                3'd1: pixels = 8'b00011100;
                3'd2: pixels = 8'b00111100;
                3'd3: pixels = 8'b01101100;
                3'd4: pixels = 8'b01111110;
                3'd5: pixels = 8'b00001100;
                3'd6: pixels = 8'b00001100;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd32: case (row)
                3'd0: pixels = 8'b01111110;
                3'd1: pixels = 8'b01100000;
                3'd2: pixels = 8'b01111100;
                3'd3: pixels = 8'b00000110;
                3'd4: pixels = 8'b00000110;
                3'd5: pixels = 8'b01100110;
                3'd6: pixels = 8'b00111100;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd33: case (row)
                3'd0: pixels = 8'b00111100;
                3'd1: pixels = 8'b01100000;
                3'd2: pixels = 8'b01100000;
                3'd3: pixels = 8'b01111100;
                3'd4: pixels = 8'b01100110;
                3'd5: pixels = 8'b01100110;
                3'd6: pixels = 8'b00111100;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd34: case (row)
                3'd0: pixels = 8'b01111110;
                3'd1: pixels = 8'b00000110;
                3'd2: pixels = 8'b00001100;
                3'd3: pixels = 8'b00011000;
                3'd4: pixels = 8'b00110000;
                3'd5: pixels = 8'b00110000;
                3'd6: pixels = 8'b00110000;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd35: case (row)
                3'd0: pixels = 8'b00111100;
                3'd1: pixels = 8'b01100110;
                3'd2: pixels = 8'b01100110;
                3'd3: pixels = 8'b00111100;
                3'd4: pixels = 8'b01100110;
                3'd5: pixels = 8'b01100110;
                3'd6: pixels = 8'b00111100;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd36: case (row)
                3'd0: pixels = 8'b00111100;
                3'd1: pixels = 8'b01100110;
                3'd2: pixels = 8'b01100110;
                3'd3: pixels = 8'b00111110;
                3'd4: pixels = 8'b00000110;
                3'd5: pixels = 8'b00000110;
                3'd6: pixels = 8'b00111100;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd37: case (row)
                3'd0: pixels = 8'b00000000;
                3'd1: pixels = 8'b01000000;
                3'd2: pixels = 8'b00100000;
                3'd3: pixels = 8'b00010000;
                3'd4: pixels = 8'b00100000;
                3'd5: pixels = 8'b01000000;
                3'd6: pixels = 8'b00000000;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd38: case (row)
                3'd0: pixels = 8'b00000000;
                3'd1: pixels = 8'b00000000;
                3'd2: pixels = 8'b00011000;
                3'd3: pixels = 8'b00000000;
                3'd4: pixels = 8'b00000000;
                3'd5: pixels = 8'b00011000;
                3'd6: pixels = 8'b00000000;
                3'd7: pixels = 8'b00000000;
            endcase

            6'd39: case (row)
                3'd0: pixels = 8'b00000000;
                3'd1: pixels = 8'b00000000;
                3'd2: pixels = 8'b00000000;
                3'd3: pixels = 8'b01111110;
                3'd4: pixels = 8'b00000000;
                3'd5: pixels = 8'b00000000;
                3'd6: pixels = 8'b00000000;
                3'd7: pixels = 8'b00000000;
            endcase

            default: pixels = 8'b00000000;
        endcase
    end

endmodule