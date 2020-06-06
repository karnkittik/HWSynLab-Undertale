`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/16/2020 08:55:43 PM
// Design Name: 
// Module Name: singlePulser
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


module singlePulser(
    output reg out,
    input wire clk,
    input wire in
    );
    
    reg st = 0;
    initial
    begin
        out = 0;
    end
    always @(posedge clk)
    begin
        out = 0;
        case({st,in})
            2'b00: 
            begin
                st = 0;
            end
            2'b01: 
            begin
                st = 1;
                out = 1;
            end
            2'b10: 
            begin
                st = 0;
            end
            2'b11:
            begin
                st = 1;
            end
        endcase
    end
    
endmodule
