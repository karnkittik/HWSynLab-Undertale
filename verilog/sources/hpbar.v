`timescale 1ns / 1ps

module hpbar #(
    F_WIDTH = 300, // width of bar
    F_HEIGHT = 16, // height of bar
    FX = 240, // coordinate x of bar
    FY = 400 // coordinate y of bar
    )
    (
    input wire i_clk,
    input wire [15:0] i_total_hp,
    input wire [15:0] i_remain_hp,
    output wire [15:0] o_lt_x,
    output wire [15:0] o_lt_y,
    output wire [15:0] o_br_x,
    output wire [15:0] o_br_y
    );
    
    reg [15:0] lt_x = FX;
    reg [15:0] lt_y = FY;
    reg [15:0] br_x = FX;
    reg [15:0] br_y = FY+F_HEIGHT;
   
    assign o_lt_x = lt_x;
    assign o_lt_y = lt_y;
    assign o_br_x = 16'd0 + FX + (F_WIDTH*i_remain_hp/i_total_hp);
    assign o_br_y = br_y;

endmodule
