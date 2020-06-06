//--------------------------------------------------
// BeeSprite Module : Digilent Basys 3               
// BeeInvaders Tutorial 2 : Onboard clock 100MHz
// VGA Resolution 640x480 @ 60Hz : Pixel Clock 25MHz
//--------------------------------------------------
`timescale 1ns / 1ps

// Setup BeeSprite Module
module BeeSprite(
    input wire i_clk,
    input wire [9:0] xx, 
    input wire [9:0] yy,
    input wire aactive,
    output reg [1:0] BSpriteOn, // 1=on, 0=off
    output wire [7:0] dataout
    );

    // instantiate BeeRom code
    reg [9:0] address; // 2^10 or 1024, need 34 x 27 = 918
    BeeRom BeeVRom (.i_addr(address),.i_clk2(i_clk),.o_data(dataout));
    
    // setup character positions and sizes
    reg [9:0] BeeX = 300; // Bee X start position
    reg [8:0] BeeY = 100; // Bee Y start position
    localparam BeeWidth = 26; // Bee width in pixels 34
    localparam BeeHeight = 37; // Bee height in pixels 27
    
    // check if xx,yy are within the confines of the Bee character
    always @ (posedge i_clk)
    begin
        if (aactive)
            begin
                if (xx==BeeX-1 && yy==BeeY)
                    begin
                        address <= 0;
                        BSpriteOn <=1;
                    end
                if ((xx>BeeX-1) && (xx<BeeX+BeeWidth) && (yy>BeeY-1) && (yy<BeeY+BeeHeight))
                    begin
                        address <= (xx-BeeX) + ((yy-BeeY)*BeeWidth);
                        BSpriteOn <=1;
                    end
                else
                    BSpriteOn <=0;
            end
    end
endmodule