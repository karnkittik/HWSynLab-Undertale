`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/04/2020 09:50:23 PM
// Design Name: 
// Module Name: cursor
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


module cursor#(
    MY = 430, // coordinate y of cursor
    R = 10 // radius of cursor
    )
    (
    input wire [1:0] i_cursor_position,
    output wire [15:0] o_cx,
    output wire [15:0] o_cy,
    output wire [15:0] o_cr
    );

    wire [15:0] position [3:0];
    assign position[0] = 16'd65; //fight
    assign position[1] = 16'd205; //action
    assign position[2] = 16'd335; //item
    assign position[3] = 16'd480; //mercy
    
    assign o_cy = MY;
    assign o_cr = R;
    assign o_cx = position[i_cursor_position];
    
endmodule
