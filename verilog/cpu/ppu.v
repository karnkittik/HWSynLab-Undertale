`timescale 1ns / 1ps

`define H_PW   96
`define H_BP   48
`define H_DISP 640
`define H_FP   16
`define V_PW   2
`define V_BP   33
`define V_DISP 480
`define V_FP   10

module ppu(
    addr,
    data,
    select,
    read,
    write,
    colorr,
    colorg,
    colorb,
    hsync,
    vsync,
    ppux,
    ppuy,
    animate,
    active,
    pix_stb,
    clock
);
    
    input  [15:0] addr;
    inout  [7:0] data;
    input  select;
    input  read;
    input  write;
    output [3:0] colorr;
    output [3:0] colorg;
    output [3:0] colorb;
    output hsync;
    output vsync;
    output [15:0] ppux;
    output [15:0] ppuy;
    output animate;
    output active;
    output pix_stb;
    input  clock;
    
    reg [3:0] colorr;
    reg [3:0] colorg;
    reg [3:0] colorb;
    reg hsync;
    reg vsync;
    
    reg count;
    reg [9:0] hcount;
    reg [9:0] vcount;
    reg [6:0] state;
    
    assign pix_stb = count == 0;
    assign animate = (hcount == 0) && (vcount == 0);
    assign active = (hcount >= `H_PW + `H_BP && hcount < `H_PW + `H_BP + `H_DISP) &&
                    (vcount >= `V_PW + `V_BP && vcount < `V_PW + `V_BP + `V_DISP);
    assign ppux = hcount - `H_PW - `H_BP;
    assign ppuy = vcount - `V_PW - `V_BP;
    
    reg [7:0] paletteidx;
    
    wire render;
    reg [5:0] ppuspace;
    reg [23:0] framecounter;
    
    reg [9:0] rendx0, rendx1, rendx2, rendx3, rendx4, rendx5, rendx6, rendx7;
    reg [9:0] rendy0, rendy1, rendy2, rendy3, rendy4, rendy5, rendy6, rendy7;
    
    reg [9:0] shiftx0, shiftx1, shiftx2, shiftx3, shiftx4, shiftx5, shiftx6, shiftx7;
    reg [9:0] shifty0, shifty1, shifty2, shifty3, shifty4, shifty5, shifty6, shifty7;
    
    reg [11:0] nameidx0, nameidx1, nameidx2, nameidx3, nameidx4, nameidx5, nameidx6, nameidx7;
    reg [10:0] attridx0, attridx1, attridx2, attridx3, attridx4, attridx5, attridx6, attridx7;
    reg [14:0] ptrnidx0, ptrnidx1;
    reg [11:0] ptrnidx2, ptrnidx3, ptrnidx4, ptrnidx5, ptrnidx6, ptrnidx7;
    
    wire [11:0] nameaddr0, nameaddr1, nameaddr2, nameaddr3, nameaddr4, nameaddr5, nameaddr6, nameaddr7;
    wire [7:0]  namedata0, namedata1, namedata2, namedata3, namedata4, namedata5, namedata6, namedata7;
    wire namesel0, namesel1, namesel2, namesel3, namesel4, namesel5, namesel6, namesel7;
    
    wire [10:0] attraddr0, attraddr1, attraddr2, attraddr3, attraddr4, attraddr5, attraddr6, attraddr7;
    wire [7:0]  attrdata0, attrdata1, attrdata2, attrdata3, attrdata4, attrdata5, attrdata6, attrdata7;
    wire attrsel0, attrsel1, attrsel2, attrsel3, attrsel4, attrsel5, attrsel6, attrsel7;
    
    wire [14:0] ptrnaddr0, ptrnaddr1;
    wire [11:0] ptrnaddr2, ptrnaddr3, ptrnaddr4, ptrnaddr5, ptrnaddr6, ptrnaddr7;
    wire [7:0]  ptrndata0, ptrndata1, ptrndata2, ptrndata3, ptrndata4, ptrndata5, ptrndata6, ptrndata7;
    wire ptrnsel0, ptrnsel1, ptrnsel2, ptrnsel3, ptrnsel4, ptrnsel5, ptrnsel6, ptrnsel7;
    
    
    nametable name0(nameaddr0, data, namedata0, render, namesel0, read, write, clock);
    nametable name1(nameaddr1, data, namedata1, render, namesel1, read, write, clock);
    nametable name2(nameaddr2, data, namedata2, render, namesel2, read, write, clock);
    nametable name3(nameaddr3, data, namedata3, render, namesel3, read, write, clock);
    nametable name4(nameaddr4, data, namedata4, render, namesel4, read, write, clock);
    nametable name5(nameaddr5, data, namedata5, render, namesel5, read, write, clock);
    nametable name6(nameaddr6, data, namedata6, render, namesel6, read, write, clock);
    nametable name7(nameaddr7, data, namedata7, render, namesel7, read, write, clock);
    
    attrtable attr0(attraddr0, data, attrdata0, render, attrsel0, read, write, clock);
    attrtable attr1(attraddr1, data, attrdata1, render, attrsel1, read, write, clock);
    attrtable attr2(attraddr2, data, attrdata2, render, attrsel2, read, write, clock);
    attrtable attr3(attraddr3, data, attrdata3, render, attrsel3, read, write, clock);
    attrtable attr4(attraddr4, data, attrdata4, render, attrsel4, read, write, clock);
    attrtable attr5(attraddr5, data, attrdata5, render, attrsel5, read, write, clock);
    attrtable attr6(attraddr6, data, attrdata6, render, attrsel6, read, write, clock);
    attrtable attr7(attraddr7, data, attrdata7, render, attrsel7, read, write, clock);
    
    ptrntable ptrn0(ptrnaddr0, data, ptrndata0, render, ptrnsel0, read, write, clock);
    ptrntable ptrn1(ptrnaddr1, data, ptrndata1, render, ptrnsel1, read, write, clock);
    nametable ptrn2(ptrnaddr2, data, ptrndata2, render, ptrnsel2, read, write, clock);
    nametable ptrn3(ptrnaddr3, data, ptrndata3, render, ptrnsel3, read, write, clock);
    nametable ptrn4(ptrnaddr4, data, ptrndata4, render, ptrnsel4, read, write, clock);
    nametable ptrn5(ptrnaddr5, data, ptrndata5, render, ptrnsel5, read, write, clock);
    nametable ptrn6(ptrnaddr6, data, ptrndata6, render, ptrnsel6, read, write, clock);
    nametable ptrn7(ptrnaddr7, data, ptrndata7, render, ptrnsel7, read, write, clock);
    
    // palette
    wire [7:0] paletteaddr;
    wire [7:0] paletterdata;
    wire palettersel;
    palette paletter(paletteaddr, data, paletterdata, render, palettersel, read, write, clock);
    wire [7:0] palettegdata;
    wire palettegsel;
    palette paletteg(paletteaddr, data, palettegdata, render, palettegsel, read, write, clock);
    wire [7:0] palettebdata;
    wire palettebsel;
    palette paletteb(paletteaddr, data, palettebdata, render, palettebsel, read, write, clock);
    
    
    always @(posedge render) framecounter <= framecounter + 1;
    assign render = vcount >= `V_PW + `V_BP - 1 && vcount < `V_PW + `V_BP + `V_DISP;
    
    
    wire ppuiosel;
    reg [7:0] ppuiodatao;
    assign data = (ppuiosel & read) ? ppuiodatao : 8'bz;
    always @(negedge clock) if (ppuiosel) case (addr[11:0])
    
        12'h000: ppuiodatao <= {state, render};
        
        12'h001: ppuiodatao <= framecounter[7:0];
        12'h002: ppuiodatao <= framecounter[15:8];
        12'h003: ppuiodatao <= framecounter[23:16];
        
        12'h004: begin
            if (write) ppuspace <= data[5:0];
            ppuiodatao <= {2'b0, ppuspace};
        end
        
        12'h008: ppuiodatao <= hcount[7:0];
        12'h009: ppuiodatao <= hcount[9:8];
        12'h00A: ppuiodatao <= vcount[7:0];
        12'h00B: ppuiodatao <= vcount[9:8];
        
        12'h010: begin
            if (write) shiftx0[7:0] <= data;
            ppuiodatao <= shiftx0[7:0];
        end
        12'h011: begin
            if (write) shiftx0[9:8] <= data[1:0];
            ppuiodatao <= {6'b0, shiftx0[9:8]};
        end
        12'h012: begin
            if (write) shifty0[7:0] <= data;
            ppuiodatao <= shifty0[7:0];
        end
        12'h013: begin
            if (write) shifty0[9:8] <= data[1:0];
            ppuiodatao <= {6'b0, shifty0[9:8]};
        end
        
        12'h014: begin
            if (write) shiftx1[7:0] <= data;
            ppuiodatao <= shiftx1[7:0];
        end
        12'h015: begin
            if (write) shiftx1[9:8] <= data[1:0];
            ppuiodatao <= {6'b0, shiftx1[9:8]};
        end
        12'h016: begin
            if (write) shifty1[7:0] <= data;
            ppuiodatao <= shifty1[7:0];
        end
        12'h017: begin
            if (write) shifty1[9:8] <= data[1:0];
            ppuiodatao <= {6'b0, shifty1[9:8]};
        end
        
        12'h018: begin
            if (write) shiftx2[7:0] <= data;
            ppuiodatao <= shiftx2[7:0];
        end
        12'h019: begin
            if (write) shiftx2[9:8] <= data[1:0];
            ppuiodatao <= {6'b0, shiftx2[9:8]};
        end
        12'h01A: begin
            if (write) shifty2[7:0] <= data;
            ppuiodatao <= shifty2[7:0];
        end
        12'h01B: begin
            if (write) shifty2[9:8] <= data[1:0];
            ppuiodatao <= {6'b0, shifty2[9:8]};
        end
        
        12'h01C: begin
            if (write) shiftx3[7:0] <= data;
            ppuiodatao <= shiftx3[7:0];
        end
        12'h01D: begin
            if (write) shiftx3[9:8] <= data[1:0];
            ppuiodatao <= {6'b0, shiftx3[9:8]};
        end
        12'h01E: begin
            if (write) shifty3[7:0] <= data;
            ppuiodatao <= shifty3[7:0];
        end
        12'h01F: begin
            if (write) shifty3[9:8] <= data[1:0];
            ppuiodatao <= {6'b0, shifty3[9:8]};
        end
        
        12'h020: begin
            if (write) shiftx4[7:0] <= data;
            ppuiodatao <= shiftx4[7:0];
        end
        12'h021: begin
            if (write) shiftx4[9:8] <= data[1:0];
            ppuiodatao <= {6'b0, shiftx4[9:8]};
        end
        12'h022: begin
            if (write) shifty4[7:0] <= data;
            ppuiodatao <= shifty4[7:0];
        end
        12'h023: begin
            if (write) shifty4[9:8] <= data[1:0];
            ppuiodatao <= {6'b0, shifty4[9:8]};
        end
        
        12'h024: begin
            if (write) shiftx5[7:0] <= data;
            ppuiodatao <= shiftx5[7:0];
        end
        12'h025: begin
            if (write) shiftx5[9:8] <= data[1:0];
            ppuiodatao <= {6'b0, shiftx5[9:8]};
        end
        12'h026: begin
            if (write) shifty5[7:0] <= data;
            ppuiodatao <= shifty5[7:0];
        end
        12'h027: begin
            if (write) shifty5[9:8] <= data[1:0];
            ppuiodatao <= {6'b0, shifty5[9:8]};
        end
        
        12'h028: begin
            if (write) shiftx6[7:0] <= data;
            ppuiodatao <= shiftx6[7:0];
        end
        12'h029: begin
            if (write) shiftx6[9:8] <= data[1:0];
            ppuiodatao <= {6'b0, shiftx6[9:8]};
        end
        12'h02A: begin
            if (write) shifty6[7:0] <= data;
            ppuiodatao <= shifty6[7:0];
        end
        12'h02B: begin
            if (write) shifty6[9:8] <= data[1:0];
            ppuiodatao <= {6'b0, shifty6[9:8]};
        end
        
        12'h02C: begin
            if (write) shiftx7[7:0] <= data;
            ppuiodatao <= shiftx7[7:0];
        end
        12'h02D: begin
            if (write) shiftx7[9:8] <= data[1:0];
            ppuiodatao <= {6'b0, shiftx7[9:8]};
        end
        12'h02E: begin
            if (write) shifty7[7:0] <= data;
            ppuiodatao <= shifty7[7:0];
        end
        12'h02F: begin
            if (write) shifty7[9:8] <= data[1:0];
            ppuiodatao <= {6'b0, shifty7[9:8]};
        end
        
    endcase
    
    // address
    assign nameaddr0  = render ? nameidx0 : addr[11:0];
    assign nameaddr1  = render ? nameidx1 : addr[11:0];
    assign nameaddr2  = render ? nameidx2 : addr[11:0];
    assign nameaddr3  = render ? nameidx3 : addr[11:0];
    assign nameaddr4  = render ? nameidx4 : addr[11:0];
    assign nameaddr5  = render ? nameidx5 : addr[11:0];
    assign nameaddr6  = render ? nameidx6 : addr[11:0];
    assign nameaddr7  = render ? nameidx7 : addr[11:0];
    
    assign attraddr0  = render ? attridx0 : addr[10:0];
    assign attraddr1  = render ? attridx1 : addr[10:0];
    assign attraddr2  = render ? attridx2 : addr[10:0];
    assign attraddr3  = render ? attridx3 : addr[10:0];
    assign attraddr4  = render ? attridx4 : addr[10:0];
    assign attraddr5  = render ? attridx5 : addr[10:0];
    assign attraddr6  = render ? attridx6 : addr[10:0];
    assign attraddr7  = render ? attridx7 : addr[10:0];
    
    assign ptrnaddr0  = render ? ptrnidx0 : ((ppuspace & 7) << 12) | (addr[11:0]);
    assign ptrnaddr1  = render ? ptrnidx1 : ((ppuspace & 7) << 12) | (addr[11:0]);
    assign ptrnaddr2  = render ? ptrnidx2 : (addr[11:0]);
    assign ptrnaddr3  = render ? ptrnidx3 : (addr[11:0]);
    assign ptrnaddr4  = render ? ptrnidx4 : (addr[11:0]);
    assign ptrnaddr5  = render ? ptrnidx5 : (addr[11:0]);
    assign ptrnaddr6  = render ? ptrnidx6 : (addr[11:0]);
    assign ptrnaddr7  = render ? ptrnidx7 : (addr[11:0]);
    
    assign paletteaddr = render ? paletteidx : addr[7:0];
    
    // select
    assign namesel0   = (select == 1 && addr[15:12] == 4 && ppuspace == 0);
    assign namesel1   = (select == 1 && addr[15:12] == 4 && ppuspace == 1);
    assign namesel2   = (select == 1 && addr[15:12] == 4 && ppuspace == 2);
    assign namesel3   = (select == 1 && addr[15:12] == 4 && ppuspace == 3);
    assign namesel4   = (select == 1 && addr[15:12] == 4 && ppuspace == 4);
    assign namesel5   = (select == 1 && addr[15:12] == 4 && ppuspace == 5);
    assign namesel6   = (select == 1 && addr[15:12] == 4 && ppuspace == 6);
    assign namesel7   = (select == 1 && addr[15:12] == 4 && ppuspace == 7);
    
    assign attrsel0   = (select == 1 && addr[15:12] == 4 && ppuspace == 8);
    assign attrsel1   = (select == 1 && addr[15:12] == 4 && ppuspace == 9);
    assign attrsel2   = (select == 1 && addr[15:12] == 4 && ppuspace == 10);
    assign attrsel3   = (select == 1 && addr[15:12] == 4 && ppuspace == 11);
    assign attrsel4   = (select == 1 && addr[15:12] == 4 && ppuspace == 12);
    assign attrsel5   = (select == 1 && addr[15:12] == 4 && ppuspace == 13);
    assign attrsel6   = (select == 1 && addr[15:12] == 4 && ppuspace == 14);
    assign attrsel7   = (select == 1 && addr[15:12] == 4 && ppuspace == 15);
    
    assign ptrnsel0   = (select == 1 && addr[15:12] == 4 && ppuspace >= 16 && ppuspace < 24);
    assign ptrnsel1   = (select == 1 && addr[15:12] == 4 && ppuspace >= 24 && ppuspace < 32);
    assign ptrnsel2   = (select == 1 && addr[15:12] == 4 && ppuspace == 34);
    assign ptrnsel3   = (select == 1 && addr[15:12] == 4 && ppuspace == 35);
    assign ptrnsel4   = (select == 1 && addr[15:12] == 4 && ppuspace == 36);
    assign ptrnsel5   = (select == 1 && addr[15:12] == 4 && ppuspace == 37);
    assign ptrnsel6   = (select == 1 && addr[15:12] == 4 && ppuspace == 38);
    assign ptrnsel7   = (select == 1 && addr[15:12] == 4 && ppuspace == 39);
    
    assign palettersel = (select == 1 && addr[15:12] == 4 && ppuspace == 61);
    assign palettegsel = (select == 1 && addr[15:12] == 4 && ppuspace == 62);
    assign palettebsel = (select == 1 && addr[15:12] == 4 && ppuspace == 63);
    
    assign ppuiosel    = select == 1 && addr[15:12] == 5;
    
    
    
    always @(posedge clock) case (state)
        0: begin
            if (vcount == `V_PW + `V_BP) state <= 3;
        end
        3: begin
            if (count == 1 && hcount + 3 == `H_PW + `H_BP) state <= 4;
        end
        4: begin
            nameidx0 <= (((rendy0 >> 4) & 63) << 6) | (((rendx0 + 2) >> 4) & 63);
            nameidx1 <= (((rendy1 >> 4) & 63) << 6) | (((rendx1 + 2) >> 4) & 63);
            nameidx2 <= (((rendy2 >> 4) & 63) << 6) | (((rendx2 + 2) >> 4) & 63);
            nameidx3 <= (((rendy3 >> 4) & 63) << 6) | (((rendx3 + 2) >> 4) & 63);
            nameidx4 <= (((rendy4 >> 4) & 63) << 6) | (((rendx4 + 2) >> 4) & 63);
            nameidx5 <= (((rendy5 >> 4) & 63) << 6) | (((rendx5 + 2) >> 4) & 63);
            nameidx6 <= (((rendy6 >> 4) & 63) << 6) | (((rendx6 + 2) >> 4) & 63);
            nameidx7 <= (((rendy7 >> 4) & 63) << 6) | (((rendx7 + 2) >> 4) & 63);
            
            state <= 5;
        end
        5: begin
            attridx0 <= (((rendy0 >> 4) & 63) << 5) | (((rendx0 + 2) >> 5) & 31);
            attridx1 <= (((rendy1 >> 4) & 63) << 5) | (((rendx1 + 2) >> 5) & 31);
            attridx2 <= (((rendy2 >> 4) & 63) << 5) | (((rendx2 + 2) >> 5) & 31);
            attridx3 <= (((rendy3 >> 4) & 63) << 5) | (((rendx3 + 2) >> 5) & 31);
            attridx4 <= (((rendy4 >> 4) & 63) << 5) | (((rendx4 + 2) >> 5) & 31);
            attridx5 <= (((rendy5 >> 4) & 63) << 5) | (((rendx5 + 2) >> 5) & 31);
            attridx6 <= (((rendy6 >> 4) & 63) << 5) | (((rendx6 + 2) >> 5) & 31);
            attridx7 <= (((rendy7 >> 4) & 63) << 5) | (((rendx7 + 2) >> 5) & 31);
            
            ptrnidx0 <= (namedata0 << 7) | ((rendy0 & 15) << 3) | (((rendx0 + 2) >> 1) & 7);
            ptrnidx1 <= (namedata1 << 7) | ((rendy1 & 15) << 3) | (((rendx1 + 2) >> 1) & 7);
            ptrnidx2 <= (namedata2 << 7) | ((rendy2 & 15) << 3) | (((rendx2 + 2) >> 1) & 7);
            ptrnidx3 <= (namedata3 << 7) | ((rendy3 & 15) << 3) | (((rendx3 + 2) >> 1) & 7);
            ptrnidx4 <= (namedata4 << 7) | ((rendy4 & 15) << 3) | (((rendx4 + 2) >> 1) & 7);
            ptrnidx5 <= (namedata5 << 7) | ((rendy5 & 15) << 3) | (((rendx5 + 2) >> 1) & 7);
            ptrnidx6 <= (namedata6 << 7) | ((rendy6 & 15) << 3) | (((rendx6 + 2) >> 1) & 7);
            ptrnidx7 <= (namedata7 << 7) | ((rendy7 & 15) << 3) | (((rendx7 + 2) >> 1) & 7);
            
            state <= 6;
        end
        6: begin
            if      (((rendx7 + 1) & 1) == 1 && ptrndata7[7:4] > 0)
                paletteidx <= (((((rendx7 + 1) >> 4) & 1) ? attrdata7[7:4] : attrdata7[3:0]) << 4) | ptrndata7[7:4]; 
            else if (((rendx7 + 1) & 1) == 0 && ptrndata7[3:0] > 0)
                paletteidx <= (((((rendx7 + 1) >> 4) & 1) ? attrdata7[7:4] : attrdata7[3:0]) << 4) | ptrndata7[3:0];
            else if (((rendx6 + 1) & 1) == 1 && ptrndata6[7:4] > 0)
                paletteidx <= (((((rendx6 + 1) >> 4) & 1) ? attrdata6[7:4] : attrdata6[3:0]) << 4) | ptrndata6[7:4]; 
            else if (((rendx6 + 1) & 1) == 0 && ptrndata6[3:0] > 0)
                paletteidx <= (((((rendx6 + 1) >> 4) & 1) ? attrdata6[7:4] : attrdata6[3:0]) << 4) | ptrndata6[3:0];
            else if (((rendx5 + 1) & 1) == 1 && ptrndata5[7:4] > 0)
                paletteidx <= (((((rendx5 + 1) >> 4) & 1) ? attrdata5[7:4] : attrdata5[3:0]) << 4) | ptrndata5[7:4]; 
            else if (((rendx5 + 1) & 1) == 0 && ptrndata5[3:0] > 0)
                paletteidx <= (((((rendx5 + 1) >> 4) & 1) ? attrdata5[7:4] : attrdata5[3:0]) << 4) | ptrndata5[3:0];
            else if (((rendx4 + 1) & 1) == 1 && ptrndata4[7:4] > 0)
                paletteidx <= (((((rendx4 + 1) >> 4) & 1) ? attrdata4[7:4] : attrdata4[3:0]) << 4) | ptrndata4[7:4]; 
            else if (((rendx4 + 1) & 1) == 0 && ptrndata4[3:0] > 0)
                paletteidx <= (((((rendx4 + 1) >> 4) & 1) ? attrdata4[7:4] : attrdata4[3:0]) << 4) | ptrndata4[3:0];
            else if (((rendx3 + 1) & 1) == 1 && ptrndata3[7:4] > 0)
                paletteidx <= (((((rendx3 + 1) >> 4) & 1) ? attrdata3[7:4] : attrdata3[3:0]) << 4) | ptrndata3[7:4]; 
            else if (((rendx3 + 1) & 1) == 0 && ptrndata3[3:0] > 0)
                paletteidx <= (((((rendx3 + 1) >> 4) & 1) ? attrdata3[7:4] : attrdata3[3:0]) << 4) | ptrndata3[3:0];
            else if (((rendx2 + 1) & 1) == 1 && ptrndata2[7:4] > 0)
                paletteidx <= (((((rendx2 + 1) >> 4) & 1) ? attrdata2[7:4] : attrdata2[3:0]) << 4) | ptrndata2[7:4]; 
            else if (((rendx2 + 1) & 1) == 0 && ptrndata2[3:0] > 0)
                paletteidx <= (((((rendx2 + 1) >> 4) & 1) ? attrdata2[7:4] : attrdata2[3:0]) << 4) | ptrndata2[3:0];
            else if (((rendx1 + 1) & 1) == 1 && ptrndata1[7:4] > 0)
                paletteidx <= (((((rendx1 + 1) >> 4) & 1) ? attrdata1[7:4] : attrdata1[3:0]) << 4) | ptrndata1[7:4]; 
            else if (((rendx1 + 1) & 1) == 0 && ptrndata1[3:0] > 0)
                paletteidx <= (((((rendx1 + 1) >> 4) & 1) ? attrdata1[7:4] : attrdata1[3:0]) << 4) | ptrndata1[3:0];
            else if (((rendx0 + 1) & 1) == 1)
                paletteidx <= (((((rendx0 + 1) >> 4) & 1) ? attrdata0[7:4] : attrdata0[3:0]) << 4) | ptrndata0[7:4]; 
            else
                paletteidx <= (((((rendx0 + 1) >> 4) & 1) ? attrdata0[7:4] : attrdata0[3:0]) << 4) | ptrndata0[3:0];
            
            nameidx0 <= (((rendy0 >> 4) & 63) << 6) | (((rendx0 + 2) >> 4) & 63);
            nameidx1 <= (((rendy1 >> 4) & 63) << 6) | (((rendx1 + 2) >> 4) & 63);
            nameidx2 <= (((rendy2 >> 4) & 63) << 6) | (((rendx2 + 2) >> 4) & 63);
            nameidx3 <= (((rendy3 >> 4) & 63) << 6) | (((rendx3 + 2) >> 4) & 63);
            nameidx4 <= (((rendy4 >> 4) & 63) << 6) | (((rendx4 + 2) >> 4) & 63);
            nameidx5 <= (((rendy5 >> 4) & 63) << 6) | (((rendx5 + 2) >> 4) & 63);
            nameidx6 <= (((rendy6 >> 4) & 63) << 6) | (((rendx6 + 2) >> 4) & 63);
            nameidx7 <= (((rendy7 >> 4) & 63) << 6) | (((rendx7 + 2) >> 4) & 63);
            
            state <= 7;
        end
        7: begin
            colorr <= paletterdata[7:4];
            colorg <= palettegdata[7:4];
            colorb <= palettebdata[7:4];
            
            attridx0 <= (((rendy0 >> 4) & 63) << 5) | (((rendx0 + 2) >> 5) & 31);
            attridx1 <= (((rendy1 >> 4) & 63) << 5) | (((rendx1 + 2) >> 5) & 31);
            attridx2 <= (((rendy2 >> 4) & 63) << 5) | (((rendx2 + 2) >> 5) & 31);
            attridx3 <= (((rendy3 >> 4) & 63) << 5) | (((rendx3 + 2) >> 5) & 31);
            attridx4 <= (((rendy4 >> 4) & 63) << 5) | (((rendx4 + 2) >> 5) & 31);
            attridx5 <= (((rendy5 >> 4) & 63) << 5) | (((rendx5 + 2) >> 5) & 31);
            attridx6 <= (((rendy6 >> 4) & 63) << 5) | (((rendx6 + 2) >> 5) & 31);
            attridx7 <= (((rendy7 >> 4) & 63) << 5) | (((rendx7 + 2) >> 5) & 31);
            
            ptrnidx0 <= (namedata0 << 7) | ((rendy0 & 15) << 3) | (((rendx0 + 2) >> 1) & 7);
            ptrnidx1 <= (namedata1 << 7) | ((rendy1 & 15) << 3) | (((rendx1 + 2) >> 1) & 7);
            ptrnidx2 <= (namedata2 << 7) | ((rendy2 & 15) << 3) | (((rendx2 + 2) >> 1) & 7);
            ptrnidx3 <= (namedata3 << 7) | ((rendy3 & 15) << 3) | (((rendx3 + 2) >> 1) & 7);
            ptrnidx4 <= (namedata4 << 7) | ((rendy4 & 15) << 3) | (((rendx4 + 2) >> 1) & 7);
            ptrnidx5 <= (namedata5 << 7) | ((rendy5 & 15) << 3) | (((rendx5 + 2) >> 1) & 7);
            ptrnidx6 <= (namedata6 << 7) | ((rendy6 & 15) << 3) | (((rendx6 + 2) >> 1) & 7);
            ptrnidx7 <= (namedata7 << 7) | ((rendy7 & 15) << 3) | (((rendx7 + 2) >> 1) & 7);
            
            if (hcount + 3 < `H_PW + `H_BP + `H_DISP) state <= 6;
            else state <= 8;
        end
        8: begin
            if      (((rendx7 + 1) & 1) == 1 && ptrndata7[7:4] > 0)
                paletteidx <= (((((rendx7 + 1) >> 4) & 1) ? attrdata7[7:4] : attrdata7[3:0]) << 4) | ptrndata7[7:4]; 
            else if (((rendx7 + 1) & 1) == 0 && ptrndata7[3:0] > 0)
                paletteidx <= (((((rendx7 + 1) >> 4) & 1) ? attrdata7[7:4] : attrdata7[3:0]) << 4) | ptrndata7[3:0];
            else if (((rendx6 + 1) & 1) == 1 && ptrndata6[7:4] > 0)
                paletteidx <= (((((rendx6 + 1) >> 4) & 1) ? attrdata6[7:4] : attrdata6[3:0]) << 4) | ptrndata6[7:4]; 
            else if (((rendx6 + 1) & 1) == 0 && ptrndata6[3:0] > 0)
                paletteidx <= (((((rendx6 + 1) >> 4) & 1) ? attrdata6[7:4] : attrdata6[3:0]) << 4) | ptrndata6[3:0];
            else if (((rendx5 + 1) & 1) == 1 && ptrndata5[7:4] > 0)
                paletteidx <= (((((rendx5 + 1) >> 4) & 1) ? attrdata5[7:4] : attrdata5[3:0]) << 4) | ptrndata5[7:4]; 
            else if (((rendx5 + 1) & 1) == 0 && ptrndata5[3:0] > 0)
                paletteidx <= (((((rendx5 + 1) >> 4) & 1) ? attrdata5[7:4] : attrdata5[3:0]) << 4) | ptrndata5[3:0];
            else if (((rendx4 + 1) & 1) == 1 && ptrndata4[7:4] > 0)
                paletteidx <= (((((rendx4 + 1) >> 4) & 1) ? attrdata4[7:4] : attrdata4[3:0]) << 4) | ptrndata4[7:4]; 
            else if (((rendx4 + 1) & 1) == 0 && ptrndata4[3:0] > 0)
                paletteidx <= (((((rendx4 + 1) >> 4) & 1) ? attrdata4[7:4] : attrdata4[3:0]) << 4) | ptrndata4[3:0];
            else if (((rendx3 + 1) & 1) == 1 && ptrndata3[7:4] > 0)
                paletteidx <= (((((rendx3 + 1) >> 4) & 1) ? attrdata3[7:4] : attrdata3[3:0]) << 4) | ptrndata3[7:4]; 
            else if (((rendx3 + 1) & 1) == 0 && ptrndata3[3:0] > 0)
                paletteidx <= (((((rendx3 + 1) >> 4) & 1) ? attrdata3[7:4] : attrdata3[3:0]) << 4) | ptrndata3[3:0];
            else if (((rendx2 + 1) & 1) == 1 && ptrndata2[7:4] > 0)
                paletteidx <= (((((rendx2 + 1) >> 4) & 1) ? attrdata2[7:4] : attrdata2[3:0]) << 4) | ptrndata2[7:4]; 
            else if (((rendx2 + 1) & 1) == 0 && ptrndata2[3:0] > 0)
                paletteidx <= (((((rendx2 + 1) >> 4) & 1) ? attrdata2[7:4] : attrdata2[3:0]) << 4) | ptrndata2[3:0];
            else if (((rendx1 + 1) & 1) == 1 && ptrndata1[7:4] > 0)
                paletteidx <= (((((rendx1 + 1) >> 4) & 1) ? attrdata1[7:4] : attrdata1[3:0]) << 4) | ptrndata1[7:4]; 
            else if (((rendx1 + 1) & 1) == 0 && ptrndata1[3:0] > 0)
                paletteidx <= (((((rendx1 + 1) >> 4) & 1) ? attrdata1[7:4] : attrdata1[3:0]) << 4) | ptrndata1[3:0];
            else if (((rendx0 + 1) & 1) == 1)
                paletteidx <= (((((rendx0 + 1) >> 4) & 1) ? attrdata0[7:4] : attrdata0[3:0]) << 4) | ptrndata0[7:4]; 
            else
                paletteidx <= (((((rendx0 + 1) >> 4) & 1) ? attrdata0[7:4] : attrdata0[3:0]) << 4) | ptrndata0[3:0];
                
            state <= 9;
        end
        9: begin
            colorr <= paletterdata[7:4];
            colorg <= palettegdata[7:4];
            colorb <= palettebdata[7:4];
            state <= 10;
        end
        10: begin
            if (count == 1) begin
                colorr <= 0;
                colorg <= 0;
                colorb <= 0;
                if (vcount + 1 < `V_PW + `V_BP + `V_DISP) state <= 3;
                else state <= 0;
            end
        end
    endcase
    
    
    
    // sync
    always @(posedge clock) begin
        
        count <= count + 1;
        
        if (count == 1) begin
        
            if (hcount < `H_PW + `H_BP + `H_DISP + `H_FP - 1) begin
            
                hcount <= hcount + 1;
                rendx0 <= hcount + 1 + shiftx0 - (`H_PW + `H_BP);
                rendx1 <= hcount + 1 + shiftx1 - (`H_PW + `H_BP);
                rendx2 <= hcount + 1 + shiftx2 - (`H_PW + `H_BP);
                rendx3 <= hcount + 1 + shiftx3 - (`H_PW + `H_BP);
                rendx4 <= hcount + 1 + shiftx4 - (`H_PW + `H_BP);
                rendx5 <= hcount + 1 + shiftx5 - (`H_PW + `H_BP);
                rendx6 <= hcount + 1 + shiftx6 - (`H_PW + `H_BP);
                rendx7 <= hcount + 1 + shiftx7 - (`H_PW + `H_BP);
                hsync <= hcount + 1 > `H_PW;
                
            end else begin
            
                hcount <= 0;
                rendx0 <= shiftx0 - (`H_PW + `H_BP);
                rendx1 <= shiftx1 - (`H_PW + `H_BP);
                rendx2 <= shiftx2 - (`H_PW + `H_BP);
                rendx3 <= shiftx3 - (`H_PW + `H_BP);
                rendx4 <= shiftx4 - (`H_PW + `H_BP);
                rendx5 <= shiftx5 - (`H_PW + `H_BP);
                rendx6 <= shiftx6 - (`H_PW + `H_BP);
                rendx7 <= shiftx7 - (`H_PW + `H_BP);
                hsync <= 0;
                
                if (vcount < `V_PW + `V_BP + `V_DISP + `V_FP - 1) begin
                
                    vcount <= vcount + 1;
                    rendy0 <= vcount + 1 + shifty0 - (`V_PW + `V_BP);
                    rendy1 <= vcount + 1 + shifty1 - (`V_PW + `V_BP);
                    rendy2 <= vcount + 1 + shifty2 - (`V_PW + `V_BP);
                    rendy3 <= vcount + 1 + shifty3 - (`V_PW + `V_BP);
                    rendy4 <= vcount + 1 + shifty4 - (`V_PW + `V_BP);
                    rendy5 <= vcount + 1 + shifty5 - (`V_PW + `V_BP);
                    rendy6 <= vcount + 1 + shifty6 - (`V_PW + `V_BP);
                    rendy7 <= vcount + 1 + shifty7 - (`V_PW + `V_BP);
                    vsync <= vcount + 1 > `V_PW;
                    
                end else begin
                
                    vcount <= 0;
                    rendy0 <= shifty0 - (`V_PW + `V_BP);
                    rendy1 <= shifty1 - (`V_PW + `V_BP);
                    rendy2 <= shifty2 - (`V_PW + `V_BP);
                    rendy3 <= shifty3 - (`V_PW + `V_BP);
                    rendy4 <= shifty4 - (`V_PW + `V_BP);
                    rendy5 <= shifty5 - (`V_PW + `V_BP);
                    rendy6 <= shifty6 - (`V_PW + `V_BP);
                    rendy7 <= shifty7 - (`V_PW + `V_BP);
                    vsync <= 0;
                    
                end
                
            end
            
        end
        
    end

endmodule



module nametable(
    addr,
    data,
    datao,
    render,
    select,
    read,
    write,
    clock
);
    
    input  [11:0] addr;
    inout  [7:0] data;
    output [7:0] datao;
    input  render;
    input  select;
    input  read;
    input  write;
    
    input  clock;
    
    reg [7:0] namemem [4095:0];
    reg [7:0] datao;
    
    always @(negedge clock) begin
        if (~render & select & write) namemem[addr] <= data;
        datao <= namemem[addr];
    end
    
    assign data = (~render & select & read) ? datao : 8'bz;

endmodule

module attrtable(
    addr,
    data,
    datao,
    render,
    select,
    read,
    write,
    clock
);
    
    input  [10:0] addr;
    inout  [7:0] data;
    output [7:0] datao;
    input  render;
    input  select;
    input  read;
    input  write;
    
    input  clock;
    
    reg [7:0] attrmem [2047:0];
    reg [7:0] datao;
    
    always @(negedge clock) begin
        if (~render & select & write) attrmem[addr] <= data;
        datao <= attrmem[addr];
    end
    
    assign data = (~render & select & read) ? datao : 8'bz;

endmodule

module ptrntable(
    addr,
    data,
    datao,
    render,
    select,
    read,
    write,
    clock
);
    
    input  [14:0] addr;
    inout  [7:0] data;
    output [7:0] datao;
    input  render;
    input  select;
    input  read;
    input  write;
    
    input  clock;
    
    reg [7:0] ptrnmem [32767:0];
    reg [7:0] datao;
    
    always @(negedge clock) begin
        if (~render & select & write) ptrnmem[addr] <= data;
        datao <= ptrnmem[addr];
    end
    
    assign data = (~render & select & read) ? datao : 8'bz;

endmodule

module palette(
    addr,
    data,
    datao,
    render,
    select,
    read,
    write,
    clock
);
    
    input  [7:0] addr;
    inout  [7:0] data;
    output [7:0] datao;
    input  render;
    input  select;
    input  read;
    input  write;
    
    input  clock;
    
    reg [7:0] palettemem [255:0];
    reg [7:0] datao;
    
    always @(negedge clock) begin
        if (~render & select & write) palettemem[addr] <= data;
        datao <= palettemem[addr];
    end
    
    assign data = (~render & select & read) ? datao : 8'bz;

endmodule