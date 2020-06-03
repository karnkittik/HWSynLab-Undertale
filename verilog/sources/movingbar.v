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
    input wire i_rx_receive,
    input wire [7:0] i_rx_data,
    output wire [15:0] o_cx,
    output wire [15:0] o_cy,
    output wire [15:0] o_r,
    output wire [15:0] o_h,
    output reg done,
    output reg o_tx_transmit,
    output reg [7:0] o_tx_data
    );
    
    reg [15:0] x = I_X+FX;
    // reg [15:0] y = C_Y+FY;
    reg x_dir = IX_DIR;
    // reg y_dir = IY_DIR;
    
    assign o_cx = x;
    assign o_cy = FY ;
    assign o_r = R;
    assign o_h = F_HEIGHT;
    reg done = 0;
    
    always @(posedge i_clk)
    begin
        if(i_animate && i_ani_stb && (~done))
        begin
            if(X_ENABLE) 
            begin
                x <= x_dir? x+VELOCITY:x-VELOCITY;
            end
            // if(Y_ENABLE)
            // begin
            //     y <= y_dir? y+VELOCITY:y-VELOCITY;
            // end
            
            if(x < FX+R) 
            begin
                x_dir <= 1; // left edge->change direction to right
                x <= FX+R;
            end
            if(x > FX+F_WIDTH-R) 
            begin
                x_dir <= 0; // right edge->change direction to left
                x <= FX+F_WIDTH-R;
            end
            // if(y < FY+R) 
            // begin
            //     y_dir <= 1; // top edge->change direction to down
            //     y <= FY+R;
            // end
            // if(y > FY+F_HEIGHT-R) 
            // begin
            //     y_dir <= 0; // bottom edge->change direction to up
            //     y <= FY+F_HEIGHT-R;
            // end
            if (i_rx_receive == 1)
            begin
    //            counter = counter + 1;
                case (i_rx_data)
                    8'h20: begin 
                        // if(y-VELOCITY >= FY+R) y <= y-VELOCITY;
                        o_tx_transmit = 1;
                        o_tx_data = 8'h20;
                        done = 1;
                    end
                endcase     
            end
            else 
            begin
                o_tx_transmit = 0;
            end
        end
    end
    
endmodule
