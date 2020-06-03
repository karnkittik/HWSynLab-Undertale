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
    input wire i_ani_stb, // animation clock: pixel clock is 1 pix/frame
    input wire i_animate, // animate when input is high
    input wire i_rx_receive,
    input wire [7:0] i_rx_data,
    output wire [15:0] o_cx,
    output wire [15:0] o_cy,
    output wire [15:0] o_r,
    output wire [15:0] led,
    output reg o_tx_transmit,
    output reg [7:0] o_tx_data
    );
    
    reg [15:0] x = C_X+FX;
    reg [15:0] y = C_Y+FY;
    
    assign o_cx = x;
    assign o_cy = y;
    assign o_r = R;
    
    // debug
    reg [15:0] counter = 0;
    assign led = counter;
    
    always @(posedge i_clk)
    begin
        if (i_rx_receive == 1)
        begin
//            counter = counter + 1;
            case (i_rx_data)
                8'h77: begin // w key; to top
                    if(y-VELOCITY >= FY+R) y <= y-VELOCITY;
                    o_tx_transmit = 1;
                    o_tx_data = 8'h77;
                end
                8'h61: begin // a key; to left
                    if(x-VELOCITY >= FX+R) x <= x-VELOCITY;
                    o_tx_transmit = 1;
                    o_tx_data = 8'h61;
                end
                8'h73: begin // s key; to bottom
                    if(y+VELOCITY <= FY+F_HEIGHT-R) y <= y+VELOCITY;
                    o_tx_transmit = 1;
                    o_tx_data = 8'h73;
                end
                8'h64: begin // d key; to right
                    if(x+VELOCITY <= FX+F_WIDTH-R) x <= x+VELOCITY;
                    o_tx_transmit = 1;
                    o_tx_data = 8'h64;
                end
            endcase     
        end
        else 
        begin
            o_tx_transmit = 0;
        end
        counter = counter + 1;
    end
    
endmodule