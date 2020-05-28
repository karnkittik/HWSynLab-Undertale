`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2020 07:58:30 PM
// Design Name: 
// Module Name: clock_divider
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


module clock_divider (
    output reg clk_div,
    input clk,
    input [31:0] div
);
    
    reg [31:0] count;
    
    initial
    begin
        clk_div = 0;
        count = 0;
    end
    
    always @(posedge clk)
    begin
    
        if (count < div - 1) count = count + 1;
        else
        begin
            clk_div = ~clk_div;
            count = 0;
        end
        
    end
    
endmodule
