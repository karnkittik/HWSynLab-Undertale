`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2020 07:05:47 PM
// Design Name: 
// Module Name: uart_transmitter
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


module uart_transmitter
#(
    parameter CLK_RATE = 100000000,
    parameter BAUD_RATE = 9600
)
(
    output reg tx,
    output reg idle,
    input [7:0] data,
    input transmit,
    input clk
);
    
    reg [3:0] state;
    reg [31:0] count;
    
    initial
    begin
        tx = 1;
        idle = 1;
        state = 0;
        count = 0;
    end
    
    always @(posedge clk)
    begin
    
        if (state == 0 && transmit == 1)
        begin
            idle = 0;
            count = 0;
            state = 1;
        end
        else if (state > 0)
        begin
            
            if (count < CLK_RATE / BAUD_RATE - 1) count = count + 1;
            else
            begin
            
                if (state == 1) tx = 0;
                else if (state >= 2 && state < 10) tx = data[state-2];
                else if (state == 10) tx = 1;
                else if (state == 11) idle = 1;
                
                count = 0;
                
                if (state < 11) state = state + 1;
                else state = 0;
                
            end
            
        end
        
    end
    
endmodule
