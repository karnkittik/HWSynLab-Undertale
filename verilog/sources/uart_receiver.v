`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2020 06:54:15 PM
// Design Name: 
// Module Name: uart_receiver
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


module uart_receiver
#(
    parameter CLK_RATE = 100000000,
    parameter BAUD_RATE = 9600
)
(
    output reg [7:0] data,
    output reg idle,
    output reg receive,
    input rx,
    input clk
);
    
    reg [3:0] state;
    reg [31:0] count;
    
    initial
    begin
        data = 0;
        idle = 1;
        state = 0;
        count = 0;
    end
    
    always @(posedge clk)
    begin
    
        if (state == 0)
        begin
        
            receive = 0;
            
            if (rx == 0)
            begin
                idle = 0;
                count = 0;
                state = 1;
            end
            
        end
        else if (state > 0)
        begin
            
            if (count == (CLK_RATE / BAUD_RATE) / 2 && state >= 2 && state < 10) data[state-2] = rx;
            
            if (count < CLK_RATE / BAUD_RATE - 1) count = count + 1;
            else
            begin
                
                if (state == 10)
                begin
                    idle = 1;
                    receive = 1;
                end
                
                count = 0;
                
                if (state < 10) state = state + 1;
                else state = 0;
                
            end
            
        end
        
    end
    
endmodule
