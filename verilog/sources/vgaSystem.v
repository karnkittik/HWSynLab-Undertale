`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2020 09:26:14 PM
// Design Name: 
// Module Name: vgaSystem
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


module vgaSystem(
    output [15:0] led,
    
    output [6:0] seg,
    output dp,
    output [3:0] an,
    
    output [3:0] vgaRed,
    output [3:0] vgaBlue,
    output [3:0] vgaGreen,
    output Hsync,
    output Vsync,
    
    output RsTx,
    
    //input [15:0] sw,
    
    //input btnC,
    //input btnU,
    //input btnL,
    //input btnR,
    //input btnD,
    
    input RsRx,
    
    input clk
);
    
    parameter WIDTH = 640;
    parameter HEIGHT = 480;
    
//    wire vga_clk;
//    clock_divider clock_divider_vga(vga_clk, clk, 2);
    wire [15:0] vga_x;
    wire [15:0] vga_y;
    wire vga_endline;
    wire vga_endframe;
    wire animate;
//    clock_divider clock_divider_draw(pix_stb, clk, 4);
    reg [15:0] cnt;
    reg pix_stb;
    always @(posedge clk)
        {pix_stb, cnt} <= cnt + 16'h4000;  // divide by 4: (2^16)/4 = 0x4000
    
    vga_controller vga_controller
    (
        .h_sync(Hsync),
        .v_sync(Vsync),
        .x(vga_x),
        .y(vga_y),
        .end_of_line(vga_endline),
        .end_of_frame(vga_endframe),
        .clk(clk),
        .i_pix_stb(pix_stb),
        .animate(animate)
    );
    
    wire tx_idle;
    reg [7:0] tx_data;
    reg tx_transmit;
    uart_transmitter uart_transmitter
    (
        .tx(RsTx),
        .idle(tx_idle),
        .data(tx_data),
        .transmit(tx_transmit),
        .clk(clk)
    );
    
    wire [7:0] rx_data;
    wire rx_idle;
    wire rx_receive;
    uart_receiver uart_receiver
    (
        .data(rx_data),
        .idle(rx_idle),
        .receive(rx_receive),
        .rx(RsRx),
        .clk(clk)
    );
    
    wire [15:0] circle_x;
    wire [15:0] circle_y;
    wire [15:0] radius;
    wire [11:0] color;
    
    ball #(.R(5)) ball_a(
        .i_clk(clk),
        .i_ani_stb(pix_stb),
        .i_animate(animate),
        .o_cx(circle_x),
        .o_cy(circle_y),
        .o_r(radius)
    );
    
    assign {vgaRed, vgaGreen, vgaBlue} = 
        (vga_x - circle_x) * (vga_x - circle_x) + (vga_y - circle_y) * (vga_y - circle_y) <= radius*radius ?
        12'hfff : 12'h000;
    
//    initial
//    begin
//        circle_x = WIDTH / 2;
//        circle_y = HEIGHT / 2;
//        color = 12'hfff;
//    end
    
//    always @(posedge clk)
//    begin
//        if (rx_receive == 1)
//        begin
//            case (rx_data)
//                8'h77 : begin
//                    circle_y = circle_y - 1;
//                    tx_data = 8'h57;
//                    tx_transmit = 1;
//                end
//                8'h61 : begin
//                    circle_x = circle_x - 1;
//                    tx_data = 8'h41;
//                    tx_transmit = 1;
//                end
//                8'h73 : begin
//                    circle_y = circle_y + 1;
//                    tx_data = 8'h53;
//                    tx_transmit = 1;
//                end
//                8'h64 : begin
//                    circle_x = circle_x + 1;
//                    tx_data = 8'h44;
//                    tx_transmit = 1;
//                end
//                8'h63 : begin
//                    color = 12'h0ff;
//                    tx_data = 8'h43;
//                    tx_transmit = 1;
//                end
//                8'h6d : begin
//                    color = 12'hf0f;
//                    tx_data = 8'h4d;
//                    tx_transmit = 1;
//                end
//                8'h79 : begin
//                    color = 12'hff0;
//                    tx_data = 8'h59;
//                    tx_transmit = 1;
//                end
//                8'h20 : begin
//                    color = 12'hfff;
//                    tx_data = 8'h5A;
//                    tx_transmit = 1;
//                end
//            endcase
//        end
//        else tx_transmit = 0;
        
//    end

    // debug

//    wire seg_clk;
//    clock_divider clock_divider_seg(seg_clk, clk, 50000);
    
//    wire [3:0] num;
//    wire dot;
//    wire [3:0] dgt;
//    reg [3:0] num0, num1, num2;
//    seven_segment_controller ssc(num, dot, dgt, color[3:0], color[7:4], color[11:8], 0, 0, 0, 0, 0, 7, seg_clk);
    
//    wire [6:0] dec;
//    binary_to_seven_segment bin_to_seg(dec, num);
    
//    assign seg = ~dec;
//    assign dp = ~dot;
//    assign an = ~dgt;
    
//    assign led = {circle_y[7:0], circle_x[7:0]};
    
endmodule
