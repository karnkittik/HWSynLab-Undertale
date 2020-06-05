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
    
    reg [31:0] cnt2;
    reg a_second_tick;
    assign led[15] = a_second_tick;
    always @(posedge clk)
        if(cnt2 == 32'd50000000) 
        begin
            a_second_tick <= ~a_second_tick;
            cnt2 <= 0;
        end
        else cnt2 <= cnt2 + 1;
        
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
    
    reg ENTER_KEY = 0;
    reg W_KEY = 0;
    reg A_KEY = 0;
    reg S_KEY = 0;
    reg D_KEY = 0;
    reg SPACE_KEY = 0;
    
    always @(posedge clk)
    begin
        if(rx_receive == 1)
        begin
            case (rx_data)
                8'h0d: begin // ENTER_KEY
                    tx_transmit <= 1;
                    tx_data <= 8'h0d;
                    ENTER_KEY <= 1;
                end
                8'h20: begin // SPACE_KEY
                    tx_transmit <= 1;
                    tx_data <= 8'h20;
                    SPACE_KEY <= 1;
                end
                8'h77: begin // W_KEY
                    tx_transmit <= 1;
                    tx_data <= 8'h77;
                    W_KEY <= 1;
                end
                8'h61: begin // A_KEY
                    tx_transmit <= 1;
                    tx_data <= 8'h61;
                    A_KEY <= 1;
                end
                8'h73: begin // S_KEY
                    tx_transmit <= 1;
                    tx_data <= 8'h73;
                    S_KEY <= 1;
                end
                8'h64: begin // D_KEY
                    tx_transmit <= 1;
                    tx_data <= 8'h64;
                    D_KEY <= 1;
                end
            endcase   
        end
        else 
        begin
            tx_transmit <= 0;
            {ENTER_KEY, W_KEY, A_KEY, S_KEY, D_KEY, SPACE_KEY} <= 6'b000000;
        end
    end
    
    // Home Screen
    wire home;
    assign home =
        ((vga_x >= 0) && (vga_x <= WIDTH) && (vga_y >=0) && (vga_y <= HEIGHT)) ? 4'b1111 : 4'b0000;
        
    // Face the monster
    wire face_monster;
    assign face_monster =
        ((vga_x >= 0) && (vga_x <= WIDTH) && (vga_y >=0) && (vga_y <= HEIGHT)) ? 4'b1111 : 4'b0000;
    
    // ball a
    wire [15:0] ball_a_x;
    wire [15:0] ball_a_y;
    wire [15:0] ball_a_radius;
    ball #(.R(5), .X_ENABLE(1), .Y_ENABLE(0), .VELOCITY(2), .C_X(10), .C_Y(20) ) ball_a(
        .i_clk(clk),
        .i_ani_stb(pix_stb),
        .i_animate(animate),
        .o_cx(ball_a_x),
        .o_cy(ball_a_y),
        .o_r(ball_a_radius)
    );
    wire [3:0] b_a;
    wire [20:0] sq_b_a_x = (vga_x - ball_a_x) * (vga_x - ball_a_x);
    wire [20:0] sq_b_a_y = (vga_y - ball_a_y) * (vga_y - ball_a_y);
    wire [20:0] sq_r_a = ball_a_radius * ball_a_radius;
    assign b_a = 
        (sq_b_a_x + sq_b_a_y <= sq_r_a) ? 4'b1111 : 4'b0000;

    // ball b
    wire [15:0] ball_b_x;
    wire [15:0] ball_b_y;
    wire [15:0] ball_b_radius;
    ball #(.R(5), .X_ENABLE(0), .Y_ENABLE(1), .VELOCITY(3), .C_X(20), .C_Y(10) ) ball_b(
        .i_clk(clk),
        .i_ani_stb(pix_stb),
        .i_animate(animate),
        .o_cx(ball_b_x),
        .o_cy(ball_b_y),
        .o_r(ball_b_radius)
    );
    wire [3:0] b_b;
    wire [20:0] sq_b_b_x = (vga_x - ball_b_x) * (vga_x - ball_b_x);
    wire [20:0] sq_b_b_y = (vga_y - ball_b_y) * (vga_y - ball_b_y);
    wire [20:0] sq_r_b = ball_b_radius * ball_b_radius;
    assign b_b = 
        (sq_b_b_x + sq_b_b_y <= sq_r_b) ? 4'b1111 : 4'b0000;

     // heart
     wire [15:0] heart_x;
     wire [15:0] heart_y;
     wire [15:0] h_x;
     wire [15:0] h_y;
     wire [15:0] h_radius;
     heart #(.R(10), .X_ENABLE(1), .Y_ENABLE(1), .VELOCITY(2), .C_X(75), .C_Y(75)) Heart(
         .i_clk(clk),
         .i_ani_stb(pix_stb),
         .i_animate(animate),
         .i_w_key(W_KEY),
         .i_a_key(A_KEY),
         .i_s_key(S_KEY),
         .i_d_key(D_KEY),
         .o_cx(h_x),
         .o_cy(h_y),
         .o_r(h_radius)
     );
     wire [3:0] heart;
     wire [20:0] sq_h_x = (vga_x - h_x) * (vga_x - h_x);
     wire [20:0] sq_h_y = (vga_y - h_y) * (vga_y - h_y);
     wire [20:0] sq_h_r = h_radius * h_radius;
     assign heart = 
         (sq_h_x + sq_h_y <= sq_h_r) ? 4'b1111 : 4'b0000;

     //player bar
    wire [14:0] player_total_hp = 16'd300;
    wire [15:0] player_remain_hp = 16'd150;
    wire [15:0] lt_x_player_hp_bar;
    wire [15:0] lt_y_player_hp_bar;
    wire [15:0] br_x_player_hp_bar;
    wire [15:0] br_y_player_hp_bar;
    wire [15:0] player_hp_bar_width;
    wire [15:0] player_hp_bar_height;
    hpbar #(.FX(50), .FY(400), .F_HEIGHT(12), .F_WIDTH(400)) Player_hp_bar(
    .i_clk(clk),
    .i_total_hp(player_total_hp),
    .i_remain_hp(player_remain_hp),
    .o_lt_x(lt_x_player_hp_bar),
    .o_lt_y(lt_y_player_hp_bar),
    .o_br_x(br_x_player_hp_bar),
    .o_br_y(br_y_player_hp_bar)
    );
    wire [3:0] player_hp_bar;
    assign player_hp_bar =
        ((vga_x>=lt_x_player_hp_bar) & (vga_x<=br_x_player_hp_bar) 
        & (vga_y>=lt_y_player_hp_bar) & (vga_y<=br_y_player_hp_bar)) ? 4'b1111 : 4'b0000;

    //monster bar
    wire [14:0] monster_total_hp = 16'd500;
    wire [15:0] monster_remain_hp = 16'd200;
    wire [15:0] lt_x_monster_hp_bar;
    wire [15:0] lt_y_monster_hp_bar;
    wire [15:0] br_x_monster_hp_bar;
    wire [15:0] br_y_monster_hp_bar;
    wire [15:0] monster_hp_bar_width;
    wire [15:0] monster_hp_bar_height;
    hpbar #(.FX(50), .FY(420), .F_HEIGHT(8), .F_WIDTH(250)) Monster_hp_bar(
    .i_clk(clk),
    .i_total_hp(monster_total_hp),
    .i_remain_hp(monster_remain_hp),
    .o_lt_x(lt_x_monster_hp_bar),
    .o_lt_y(lt_y_monster_hp_bar),
    .o_br_x(br_x_monster_hp_bar),
    .o_br_y(br_y_monster_hp_bar)
    );
    wire [3:0] monster_hp_bar;
    assign monster_hp_bar =
        ((vga_x>=lt_x_monster_hp_bar) & (vga_x<=br_x_monster_hp_bar) 
        & (vga_y>=lt_y_monster_hp_bar) & (vga_y<=br_y_monster_hp_bar)) ? 4'b1111 : 4'b0000;
    
    // escape frame
    wire [3:0] offsetEscape = 5;
    wire [3:0] frameEscape;
    assign frameEscape =
       ((vga_x <= 245 + 150 + offsetEscape)&(vga_x >= 245 - offsetEscape)
       &(vga_y <= 230 + 150 + offsetEscape)&(vga_y >= 230 - offsetEscape))&
       (~((vga_x <= 245 + 150 )&(vga_x >= 245)
       &(vga_y <= 230 + 150)&(vga_y >= 230))) ? 4'b1111 : 4'b0000;
    
    // fight frame
    wire [3:0] offsetFight = 5;
    wire [3:0] frameFight;
    assign frameFight =
       ((vga_x <= 100 + 440 + offsetFight)&(vga_x >= 100 - offsetFight)
       &(vga_y <= 230 + 150 + offsetFight)&(vga_y >= 230 - offsetFight))&
       (~((vga_x <= 100 + 440 )&(vga_x >= 100)
       &(vga_y <= 230 + 150)&(vga_y >= 230))) ? 4'b1111 : 4'b0000;

    // score bar
    wire [3:0] scoreBarGreen;
    assign scoreBarGreen = 
        ((vga_x >= 305) & (vga_x <= 305 + 20) 
        & (vga_y >= 230) & (vga_y <= 230 + 150)) ? 4'b1111 : 4'b0000;
    wire [3:0] scoreBarYellow;
    assign scoreBarYellow = 
        (((vga_x >= 220) & (vga_x <= 220 + 15) 
        & (vga_y >= 240) & (vga_y <= 240 + 130)) |
        ((vga_x >= 395) & (vga_x <= 395 + 15) 
        & (vga_y >= 240) & (vga_y <= 240 + 130))) ? 4'b1111 : 4'b0000;
    wire [3:0] scoreBarOrange;
    assign scoreBarOrange = 
        (((vga_x >= 160) & (vga_x <= 160 + 15) 
        & (vga_y >= 260) & (vga_y <= 260 + 90)) |
        ((vga_x >= 455) & (vga_x <= 455 + 15) 
        & (vga_y >= 260) & (vga_y <= 260 + 90))) ? 4'b1111 : 4'b0000;
    wire [3:0] scoreBarBlue;
    assign scoreBarBlue = 
        (((vga_x >= 115) & (vga_x <= 115 + 15) 
        & (vga_y >= 290) & (vga_y <= 290 + 30)) |
        ((vga_x >= 500) & (vga_x <= 500 + 15) 
        & (vga_y >= 290) & (vga_y <= 290 + 30))) ? 4'b1111 : 4'b0000;
  
    // moving bar
    wire [15:0] movingBar_x;
    wire [15:0] movingBar_y;
    wire [15:0] movingBar_radius;
    wire [15:0] movingBar_height;
    wire movingbar_stop = 1;
    reg movingbar_active = 0;
    movingbar #(.R(2), .VELOCITY(5), .I_X(15)) Moving_Bar(
        .i_clk(clk),
        .i_ani_stb(pix_stb),
        .i_animate(animate),
        .i_space_key(SPACE_KEY),
        .i_active(movingbar_active),
        .o_cx(movingBar_x),
        .o_cy(movingBar_y),
        .o_r(movingBar_radius),
        .o_h(movingBar_height),
        .o_stop(movingbar_stop)
    );
    wire [3:0] movingBar;
    assign movingBar = 
        ((vga_x >= movingBar_x - movingBar_radius)
        & (vga_x <= movingBar_x + movingBar_radius)
        & (vga_y >= movingBar_y) & (vga_y <= movingBar_y + 150)) ? 4'b0111 : 4'b0000;
        
    // state
    reg [15:0] state = 16'h00; 
    reg is_monster_dead = monster_remain_hp==0 ? 1 : 0;
    reg is_player_dead = player_remain_hp==0 ? 1 : 0;
    
    // RGB
    reg [3:0] reg_vgaRed = 4'b0000;
    reg [3:0] reg_vgaGreen = 4'b0000;
    reg [3:0] reg_vgaBlue = 4'b0000;
    assign vgaRed[3:0] = reg_vgaRed;
    assign vgaGreen[3:0] = reg_vgaGreen;
    assign vgaBlue[3:0] = reg_vgaBlue;
    
//    assign vgaRed[3:0] =
//        movingBar 
//        | frameFight 
//        | scoreBarYellow 
//        | scoreBarOrange
//        | (scoreBarBlue & 4'b1000);//b_a | b_b | heart |frame | monster_hp_bar;
//    assign vgaGreen[3:0] =
//        frameFight 
//        | scoreBarYellow 
//        | scoreBarGreen 
//        | (scoreBarOrange & 4'b1010)
//        | (scoreBarBlue & 4'b1100); //b_a | b_b | frame | player_hp_bar;
//    assign vgaBlue[3:0] = 
//        frameFight
//        | (scoreBarBlue & 4'b1111); //b_a | b_b | frame;
    reg start_attack_timer = 0;
    reg [3:0] monster_attack_timer = 4'd0;
    
    always @(posedge a_second_tick)
    begin
        if(start_attack_timer==1) monster_attack_timer <= monster_attack_timer + 4'd1;
        else monster_attack_timer <= 0;
    end
    
    always @(posedge clk)
    begin
        case(state)
            16'h00: begin // HOME SCREEN
                // component to render
                reg_vgaRed <= home;
                reg_vgaGreen <= home;
                reg_vgaBlue <= home;
                // if ENTER, next state: MONSTER FOUND
                if(ENTER_KEY==1) state <= 16'h10;
            end
            16'h10: begin // FACE THE MONSTER
                // component to render
                reg_vgaRed <= face_monster;
                reg_vgaGreen <= face_monster;
                reg_vgaBlue <= face_monster;
                // if player select FIGHT
                if(ENTER_KEY==1) 
                begin
                    state <= 16'h20;
                    movingbar_active <= 1;
                end
            end
            16'h20: begin // PLAYER ATTACKS MONSTER
                // component to render
                reg_vgaRed <= movingBar 
                | frameFight 
                | scoreBarYellow 
                | scoreBarOrange
                | (scoreBarBlue & 4'b1000)
                | monster_hp_bar;
                
                reg_vgaGreen <= frameFight 
                | scoreBarYellow 
                | scoreBarGreen 
                | (scoreBarOrange & 4'b1010)
                | (scoreBarBlue & 4'b1100)
                | monster_hp_bar;
                
                reg_vgaBlue <= frameFight
                | (scoreBarBlue & 4'b1111)
                | monster_hp_bar;
                
                // if moving bar is gone, next state: MONSTER ATTACKS PLAYER
                if(is_monster_dead==1) 
                begin
                    movingbar_active <= 0;
                    state <= 16'h00; // back to HOME SCREEN
                end
                
                if(movingbar_stop==1) 
                begin
                    state <= 16'h30;
                    movingbar_active <= 0;
                end
            end
            16'h30: begin // MONSTER ATTACKS PLAYER
                // component to render
                reg_vgaRed <= b_a 
                | b_b 
                | heart 
                | frameEscape 
                | frameFight
                | monster_hp_bar;
                reg_vgaGreen <= b_a 
                | b_b 
                | frameEscape 
                | frameFight
                | player_hp_bar;
                reg_vgaBlue <= b_a 
                | b_b 
                | frameEscape 
                | frameFight;
                
                if(is_player_dead==1) state <= 16'h00; // back to HOME SCREEN
                // after 5 seconds, next state: FACE THE MONSTER
                start_attack_timer <= 1;
                if(monster_attack_timer==4'd6)
                begin
                    start_attack_timer <= 0;
                    state <= 16'h10;
                end
                
            end
        endcase
    end
   
    // heart equation BUT dose not work
//    wire [31:0] sq_h_x = (vga_x - h_x) * (vga_x - h_x);
//    wire [31:0] sq_h_y = (vga_y - h_y) * (vga_y - h_y);
//    wire [127:0] cu_h_y = (vga_y - h_y) * (vga_y - h_y) * (vga_y - h_y);
//    wire [31:0] sq_h_r = h_radius * h_radius;
//    wire [127:0] cu_h_t1 = (sq_h_x + sq_h_y - sq_h_r) * (sq_h_x + sq_h_y - sq_h_r) * (sq_h_x + sq_h_y - sq_h_r);
//    wire [127:0] cu_h_t2 = sq_h_x * cu_h_y;   
//    assign heart = 
//        (cu_h_t1 <= cu_h_t2) ? 4'b1111 : 4'b0000;
    // assign led = counter;
    
endmodule
