`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/28/2020 01:51:46 PM
// Design Name: 
// Module Name: ball
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


module ball #(
    IX_DIR = 1, // horizontal direction: 1 is right, 0 is left
    IY_DIR = 0, // vertical direction: 1 is right, 0 is left
    F_WIDTH = 150, // width of fighting box
    F_HEIGHT = 150, // height of fighting box
    FX = 245, // coordinate x of fighting box
    FY = 230, // coordinate y of fighting box
    D_WIDTH = 640, // width of display
    D_HEIGHT = 480, // height of display
    R = 5, // initial radius of ball
    C_X = 5, // initial x center of ball
    C_Y = 5 // initial y center of ball
    )
    (
    input wire i_clk, // base clock
    input wire i_ani_stb, // animation clock: pixel clock is 1 pix/frame
    input wire i_animate, // animate when input is high
    output wire [15:0] o_cx,
    output wire [15:0] o_cy,
    output wire [15:0] o_r
    );
    
    reg [15:0] x = C_X+FX;
    reg [15:0] y = C_Y+FY;
    reg x_dir = IX_DIR;
    reg y_dir = IY_DIR;
    
    assign o_cx = x;
    assign o_cy = y;
    assign o_r = R;
    
    always @(posedge i_clk)
    begin
        if(i_animate && i_ani_stb)
        begin
            x <= (x_dir)? x+1:x-1;
            y <= (y_dir)? y+1:y-1;
            
            if(x < FX+R) x_dir <= 1; // left edge->change direction to right
            if(x > FX+F_WIDTH-R) x_dir <= 0; // right edge->change direction to left
            if(y < FY+R) y_dir <= 1; // top edge->change direction to down
            if(y > FY+F_HEIGHT-R) y_dir <= 0; // bottom edge->change direction to up
            
        end
    end
    
endmodule
