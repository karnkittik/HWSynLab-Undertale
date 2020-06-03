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
    input RsRx,
    //input [15:0] sw,
    //input btnC,
    //input btnU,
    //input btnL,
    //input btnR,
    //input btnD,
    input clk
);
    
    parameter WIDTH = 640;
    parameter HEIGHT = 480;
    parameter FX = 245; // coordinate x of fighting box
    parameter FY = 230; // coordinate y of fighting box
    parameter F_WIDTH = 150; // width of fighting box
    parameter F_HEIGHT = 150; // height of fighting box
    
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
    wire [7:0] tx_data;
    wire tx_transmit;
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
    
    wire [15:0] ball_a_x;
    wire [15:0] ball_a_y;
    wire [15:0] ball_a_radius;
    
    wire [15:0] ball_b_x;
    wire [15:0] ball_b_y;
    wire [15:0] ball_b_radius;
    
    wire [15:0] ball_c_x;
    wire [15:0] ball_c_y;
    wire [15:0] ball_c_radius;
    
    wire [15:0] heart_x;
    wire [15:0] heart_y;
    wire [15:0] h_x;
    wire [15:0] h_y;
    wire [15:0] h_radius;
//    wire [11:0] color;
    
    // debug
    wire [15:0] counter;
    
    ball #(.R(5), .X_ENABLE(1), .Y_ENABLE(0), .VELOCITY(2), .C_X(10), .C_Y(20) ) ball_a(
        .i_clk(clk),
        .i_ani_stb(pix_stb),
        .i_animate(animate),
        .o_cx(ball_a_x),
        .o_cy(ball_a_y),
        .o_r(ball_a_radius)
//        .led(counter)
    );
    
    ball #(.R(5), .X_ENABLE(0), .Y_ENABLE(1), .VELOCITY(3), .C_X(20), .C_Y(10) ) ball_b(
        .i_clk(clk),
        .i_ani_stb(pix_stb),
        .i_animate(animate),
        .o_cx(ball_b_x),
        .o_cy(ball_b_y),
        .o_r(ball_b_radius)
//        .led(counter)
    );
    
    heart #(.R(10), .X_ENABLE(1), .Y_ENABLE(1), .VELOCITY(2), .C_X(75), .C_Y(75)) Heart(
        .i_clk(clk),
        .i_ani_stb(pix_stb),
        .i_animate(animate),
        .i_rx_receive(rx_receive),
        .i_rx_data(rx_data),
        .o_cx(h_x),
        .o_cy(h_y),
        .o_r(h_radius),
        .o_tx_transmit(tx_transmit),
        .o_tx_data(tx_data),
        .led(counter)
    );
    
    wire [3:0] b_a;
    wire [3:0] b_b;
    wire [3:0] heart;
    wire [3:0] frame;
    // ball a
    wire [20:0] sq_b_a_x = (vga_x - ball_a_x) * (vga_x - ball_a_x);
    wire [20:0] sq_b_a_y = (vga_y - ball_a_y) * (vga_y - ball_a_y);
    wire [20:0] sq_r_a = ball_a_radius * ball_a_radius;
    // ball b
    wire [20:0] sq_b_b_x = (vga_x - ball_b_x) * (vga_x - ball_b_x);
    wire [20:0] sq_b_b_y = (vga_y - ball_b_y) * (vga_y - ball_b_y);
    wire [20:0] sq_r_b = ball_b_radius * ball_b_radius;
    // heart
    wire [20:0] sq_h_x = (vga_x - h_x) * (vga_x - h_x);
    wire [20:0] sq_h_y = (vga_y - h_y) * (vga_y - h_y);
    wire [20:0] sq_h_r = h_radius * h_radius;
   
    // heart equation BUT dose not work
//    wire [31:0] sq_h_x = (vga_x - h_x) * (vga_x - h_x);
//    wire [31:0] sq_h_y = (vga_y - h_y) * (vga_y - h_y);
//    wire [127:0] cu_h_y = (vga_y - h_y) * (vga_y - h_y) * (vga_y - h_y);
//    wire [31:0] sq_h_r = h_radius * h_radius;
//    wire [127:0] cu_h_t1 = (sq_h_x + sq_h_y - sq_h_r) * (sq_h_x + sq_h_y - sq_h_r) * (sq_h_x + sq_h_y - sq_h_r);
//    wire [127:0] cu_h_t2 = sq_h_x * cu_h_y;
    wire [3:0] offset = 5;
    assign b_a = 
        (sq_b_a_x + sq_b_a_y <= sq_r_a) ? 4'b1111 : 4'b0000;
    assign b_b = 
        (sq_b_b_x + sq_b_b_y <= sq_r_b) ? 4'b1111 : 4'b0000;
    assign heart = 
        (sq_h_x + sq_h_y <= sq_h_r) ? 4'b1111 : 4'b0000;
//    assign heart = 
//        (cu_h_t1 <= cu_h_t2) ? 4'b1111 : 4'b0000;
    assign frame =
       ((vga_x <= 245 + 150 + offset)&(vga_x >= 245 - offset)
       &(vga_y <= 230 + 150 + offset)&(vga_y >= 230 - offset))&
       (~((vga_x <= 245 + 150 )&(vga_x >= 245)
       &(vga_y <= 230 + 150)&(vga_y >= 230))) ? 4'b1111 : 4'b0000;
    assign vgaRed[3:0] = b_a | b_b | heart |frame ;
    assign vgaGreen[3:0] = b_a | b_b | frame;
    assign vgaBlue[3:0] = b_a | b_b | frame;
    assign led = counter;
    
endmodule
