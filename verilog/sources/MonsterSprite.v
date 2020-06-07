//--------------------------------------------------
// MonsterSprite Module : Digilent Basys 3               
// MonsterInvaders Tutorial 2 : Onboard clock 100MHz
// VGA Resolution 640x480 @ 60Hz : Pixel Clock 25MHz
//--------------------------------------------------
`timescale 1ns / 1ps

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
    reg [9:0] address; // 2^10 or 1024, need 34 x 27 = 918
    MonsterRom MonsterVRom (.i_addr(address),.i_clk2(i_clk),.o_data(dataout));
    
    // setup character positions and sizes
    reg [9:0] MonsterX = 300; // Monster X start position
    reg [8:0] MonsterY = 100; // Monster Y start position
    localparam MonsterWidth = 26; // Monster width in pixels 34
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