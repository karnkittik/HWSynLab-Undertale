`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/05/2020 02:31:27 PM
// Design Name: 
// Module Name: MonsterRom
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

// Setup MonsterRom Module
module MonsterRom(
    input wire [9:0] i_addr, // (9:0) or 2^10 or 1024, need 26 x 37 = 962
    input wire i_clk2,
    output reg [7:0] o_data // (7:0) 8 bit pixel value from Monster.mem
    );

    (*ROM_STYLE="block"*) reg [7:0] memory_array [0:961]; // 8 bit values for 962 pixels of Monster (26 x 37)

    initial begin
            $readmemh("Monster.mem", memory_array);
    end

    always @ (posedge i_clk2)
            o_data <= memory_array[i_addr];     
endmodule
