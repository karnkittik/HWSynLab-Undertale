//---------------------------------------------------
// MonsterRom Module - Single Port ROM : Digilent Basys 3               
// MonsterInvaders Tutorial 2 : Onboard clock 100MHz
// VGA Resolution 640x480 @ 60Hz : Pixel Clock 25MHz
//---------------------------------------------------
`timescale 1ns / 1ps

// Setup MonsterRom Module
module MonsterRom(
    input wire [9:0] i_addr, // (9:0) or 2^10 or 1024, need 34 x 27 = 918
    input wire i_clk2,
    output reg [7:0] o_data // (7:0) 8 bit pixel value from Monster.mem
    );

    (*ROM_STYLE="block"*) reg [7:0] memory_array [0:1289]; // 8 bit values for 918 pixels of Monster (34 x 27)

    initial begin
            $readmemh("Monster.mem", memory_array);
    end

    always @ (posedge i_clk2)
            o_data <= memory_array[i_addr];     
endmodule
