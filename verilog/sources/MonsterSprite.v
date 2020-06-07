`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/05/2020 02:21:46 PM
// Design Name: 
// Module Name: MonsterSprite
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
// https://github.com/AdrianFPGA/basys3
// https://timetoexplore.net/blog/arty-fpga-vga-verilog-01
// https://timetoexplore.net/blog/arty-fpga-vga-verilog-02
// https://timetoexplore.net/blog/arty-fpga-vga-verilog-03

// Setup MonsterSprite Module
module MonsterSprite(
    input wire i_clk,
    input wire [9:0] xx, 
    input wire [9:0] yy,
    input wire aactive,
    output reg [1:0] MSpriteOn, // 1=on, 0=off
    output wire [7:0] dataout
    );

    // instantiate MonsterRom code
    reg [9:0] address; // 2^10 or 1024, need 26 x 37 = 962
    MonsterRom MonsterVRom (.i_addr(address),.i_clk2(i_clk),.o_data(dataout));
    
    // setup character positions and sizes
    reg [9:0] MonsterX = 300; // Monster X start position
    reg [8:0] MonsterY = 100; // Monster Y start position
    localparam MonsterWidth = 26; // Monster width in pixels 26
    localparam MonsterHeight = 37; // Monster height in pixels 27
    
    // check if xx,yy are within the confines of the Monster character
    always @ (posedge i_clk)
    begin
        if (aactive)
            begin
                if (xx==MonsterX-1 && yy==MonsterY)
                    begin
                        address <= 0;
                        MSpriteOn <=1;
                    end
                if ((xx>MonsterX-1) && (xx<MonsterX+MonsterWidth) && (yy>MonsterY-1) && (yy<MonsterY+MonsterHeight))
                    begin
                        address <= (xx-MonsterX) + ((yy-MonsterY)*MonsterWidth);
                        MSpriteOn <=1;
                    end
                else
                    MSpriteOn <=0;
            end
    end
endmodule