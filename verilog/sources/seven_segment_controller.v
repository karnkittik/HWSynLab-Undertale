`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/10/2020 09:02:23 PM
// Design Name: 
// Module Name: seven_segment_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module seven_segment_controller (
    output reg [3:0] num,
    output reg dot,
    output reg [3:0] dgt,
    input [3:0] num0,
    input [3:0] num1,
    input [3:0] num2,
    input [3:0] num3,
    input dot0,
    input dot1,
    input dot2,
    input dot3,
    input [3:0] dgt_en,
    input clk
);
    
    reg [1:0] state;
    
    initial
    begin
        dgt = 0;
        state = 0;
    end
    
    always @(posedge clk)
    begin
    
        case (state)
            0 : begin
                num = num0;
                dot = dot0;
                dgt = (dgt_en[0] == 1) ? 4'b0001 : 4'b0000;
            end
            1 : begin
                num = num1;
                dot = dot1;
                dgt = (dgt_en[1] == 1) ? 4'b0010 : 4'b0000;
            end
            2 : begin
                num = num2;
                dot = dot2;
                dgt = (dgt_en[2] == 1) ? 4'b0100 : 4'b0000;
            end
            3 : begin
                num = num3;
                dot = dot3;
                dgt = (dgt_en[3] == 1) ? 4'b1000 : 4'b0000;
            end
        endcase
        
        state = state + 1;
        
    end
    
endmodule
