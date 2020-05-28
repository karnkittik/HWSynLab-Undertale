`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2020 10:45:51 AM
// Design Name: 
// Module Name: vga_controller
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


module vga_controller(
    output h_sync,
    output v_sync,
    output [15:0] x,
    output [15:0] y,
    output end_of_line,
    output end_of_frame,
    output animate,
    input i_pix_stb,
    input clk
);

    parameter H_PW      = 96;
    parameter H_BP      = 48;
    parameter H_DISP    = 640;
    parameter H_FP      = 16;
    parameter V_PW      = 2;
    parameter V_BP      = 33;
    parameter V_DISP    = 480;
    parameter V_FP      = 10;
    
    reg [15:0] h_count;
    reg [15:0] v_count;
    
    initial
    begin
        h_count = 0;
        v_count = 0;
    end
    
    assign animate = ((v_count == V_DISP-1)&(h_count == H_PW+H_BP+H_DISP+H_FP));
    
    assign h_sync = h_count >= H_PW;
    assign v_sync = v_count >= V_PW;
    
    assign x = h_count >= H_PW + H_BP && h_count < H_PW + H_BP + H_DISP ? h_count - H_PW - H_BP : 0;
    assign y = v_count >= V_PW + V_BP && v_count < V_PW + V_BP + V_DISP ? v_count - V_PW - V_BP : 0;
    
    assign end_of_line = (h_count == H_PW + H_BP + H_DISP + H_FP - 1);
    assign end_of_frame = (v_count == V_PW + V_BP + V_DISP + V_FP - 1);
    
    always @(posedge clk)
    begin
        if(i_pix_stb)
        begin
            if (h_count < H_FP + H_PW + H_BP + H_DISP - 1) h_count = h_count + 1;
            else
            begin
                h_count = 0;
                if (v_count < V_DISP + V_FP + V_PW + V_BP - 1) v_count = v_count + 1;
                else v_count = 0;
            end
        end    
    end
    
endmodule
