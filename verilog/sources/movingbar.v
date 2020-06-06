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


module movingbar #(
    X_ENABLE = 0, // x-axis movement: 0 is disable, 1 is enable
    // Y_ENABLE = 0, // y-axis movement: 0 is disable, 1 is enable
    IX_DIR = 1, // horizontal direction: 1 is right, 0 is left
    // IY_DIR = 0, // vertical direction: 1 is right, 0 is left
    F_WIDTH = 440, // width of fighting box
    F_HEIGHT = 150, // height of fighting box
    FX = 100, // coordinate x of fighting box
    FY = 230, // coordinate y of fighting box
    D_WIDTH = 640, // width of display
    D_HEIGHT = 480, // height of display
    R = 2, // initial radius of ball
    I_X = 15, // initial x of bar
    VELOCITY = 1 // initial velocity
    )
    (
    input wire i_clk, // base clock
    input wire i_ani_stb, // animation clock: pixel clock is 1 pix/frame
    input wire i_animate, // animate when input is high
    input wire i_space_key,
    input wire i_active,
    output wire [15:0] o_cx,
    output wire [15:0] o_cy,
    output wire [15:0] o_r,
    output wire [15:0] o_h,
    output wire o_stop
    );
    
    reg [15:0] x = I_X+FX;
    reg x_dir = IX_DIR;
    reg stop = 0;
    
    assign o_cx = x;
    assign o_cy = FY ;
    assign o_r = R;
    assign o_h = F_HEIGHT;
    assign o_stop = stop;
    
    always @(posedge i_clk)
    begin
        if (i_space_key == 1) stop <= 1;
    end
    
    always @(posedge i_clk)
    begin
        if(i_active==0)
        begin
            x <= I_X+FX;
        end
        else
        begin
            if(i_animate && i_ani_stb)
            begin
                x <= x+VELOCITY;
                if(x > FX+F_WIDTH-R) 
                begin
                    stop <= 1;
                end
            end
        end
    end
    
endmodule
