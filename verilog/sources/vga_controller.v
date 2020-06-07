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
// References
// https://timetoexplore.net/blog/arty-fpga-vga-verilog-01

module vga_controller(
    output h_sync,
    output v_sync,
    output [15:0] x,
    output [15:0] y,
    output end_of_line,
    output end_of_frame,
    output animate,
    output active,
    input i_pix_stb,
    input clk
);

    parameter HS_STA = 16;              // horizontal sync start
    parameter HS_END = 16 + 96;         // horizontal sync end
    parameter HA_STA = 16 + 96 + 48;    // horizontal active pixel start
    parameter VS_STA = 480 + 10;        // vertical sync start
    parameter VS_END = 480 + 10 + 2;    // vertical sync end
    parameter VA_END = 480;             // vertical active pixel end
    parameter LINE   = 800;             // complete line (pixels)
    parameter SCREEN = 525;             // complete screen (lines)
    parameter VACTIVESTART = 10 + 2 + 33;
    reg [15:0] h_count;
    reg [15:0] v_count;
    
    initial
    begin
        h_count = 0;
        v_count = 0;
    end
    
    assign h_sync = ~((h_count >= HS_STA) & (h_count < HS_END));
    assign v_sync = ~((v_count >= VS_STA) & (v_count < VS_END));
    
    assign x = (h_count < HA_STA) ? 0 : (h_count - HA_STA);
    assign y = (v_count >= VA_END) ? (VA_END - 1) : (v_count);
    assign active = ~((h_count< HA_STA) | (v_count < VACTIVESTART));
    assign animate = ((v_count == VA_END - 1) & (h_count == LINE));
    
    always @(posedge clk)
    begin
        if(i_pix_stb)
        begin
            if (h_count == LINE)  // end of line
            begin
                h_count <= 0;
                v_count <= v_count + 1;
            end
            else 
                h_count <= h_count + 1;

            if (v_count == SCREEN)  // end of screen
                v_count <= 0;
        end    
    end
    
endmodule
