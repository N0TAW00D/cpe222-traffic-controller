`timescale 1ns / 1ps

module font_rom(
    input wire clk,
    input wire [5:0] char_code,  // Character code (0-36: space, A-Z, 0-9)
    input wire [2:0] row,         // Row within character (0-7)
    output reg [7:0] pixels       // 8 pixels for this row
);

    always @(posedge clk) begin
        case (char_code)
            // Space (0)
            6'd0: pixels = 8'b00000000;
            
            // A (1)
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
            
            // B (2)
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
            
            // C (3)
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
            
            // D (4)
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
            
            // E (5)
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
            
            // F (6)
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
            
            // G (7)
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
            
            // H (8)
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
            
            // I (9)
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
            
            // J (10)
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
            
            // K (11)
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
            
            // L (12)
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
            
            // M (13)
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
            
            // N (14)
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
            
            // O (15)
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
            
            // P (16)
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
            
            // Q (17)
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
            
            // R (18)
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
            
            // S (19)
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
            
            // T (20)
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
            
            // U (21)
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
            
            // V (22)
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
            
            // W (23)
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
            
            // X (24)
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
            
            // Y (25)
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
            
            // Z (26)
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
            
            // 0 (27)
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
            
            // 1 (28)
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
            
            // 2 (29)
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
            
            // 3 (30)
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
            
            // 4 (31)
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
            
            // 5 (32)
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
            
            // 6 (33)
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
            
            // 7 (34)
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
            
            // 8 (35)
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
            
            // 9 (36)
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

            // > (37)
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

            // : (38)
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

            default: pixels = 8'b00000000;
        endcase
    end

endmodule