`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/01/2020 11:33:42 PM
// Design Name: 
// Module Name: heart
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

module heart #(
    X_ENABLE = 0, // x-axis movement: 0 is disable, 1 is enable
    Y_ENABLE = 0, // y-axis movement: 0 is disable, 1 is enable
    F_WIDTH = 150, // width of fighting box
    F_HEIGHT = 150, // height of fighting box
    FX = 245, // coordinate x of fighting box
    FY = 230, // coordinate y of fighting box
    D_WIDTH = 640, // width of display
    D_HEIGHT = 480, // height of display
    R = 5, // initial radius of heart
    C_X = 5, // initial x center of heart
    C_Y = 5, // initial y center of heart
    VELOCITY = 5 // initial velocity
    )
    (
    input wire i_clk, // base clock
    input wire i_rst,
    input wire i_w_key,
    input wire i_a_key,
    input wire i_s_key,
    input wire i_d_key,
    output wire [15:0] o_cx,
    output wire [15:0] o_cy,
    output wire [15:0] o_r
    );
    
    reg [15:0] x = C_X+FX;
    reg [15:0] y = C_Y+FY;
    
    assign o_cx = x;
    assign o_cy = y;
    assign o_r = R;
    
    
    always @(posedge i_clk)
    begin
        if(i_rst==1)
        begin
            x = C_X+FX;
            y = C_Y+FY;
        end
        else
        begin
            if(i_w_key) begin
                if(y-VELOCITY >= FY+R) y <= y-VELOCITY;
            end
            if(i_a_key) begin
                if(x-VELOCITY >= FX+R) x <= x-VELOCITY;
            end
            if(i_s_key) begin
                if(y+VELOCITY <= FY+F_HEIGHT-R) y <= y+VELOCITY;
            end
            if(i_d_key) begin
                if(x+VELOCITY <= FX+F_WIDTH-R) x <= x+VELOCITY;
            end
        end
    end
    
endmodule