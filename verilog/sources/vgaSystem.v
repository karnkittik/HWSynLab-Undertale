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
// References
// https://github.com/AdrianFPGA/basys3
// https://timetoexplore.net/blog/arty-fpga-vga-verilog-01
// https://timetoexplore.net/blog/arty-fpga-vga-verilog-02
// https://timetoexplore.net/blog/arty-fpga-vga-verilog-03

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
    input clk
);
    
    parameter WIDTH = 640;
    parameter HEIGHT = 480;
    
    wire [9:0] screen_width = WIDTH;
    wire [8:0] screen_height = HEIGHT;
    wire [15:0] vga_x;
    wire [15:0] vga_y;
    wire vga_endline;
    wire vga_endframe;
    wire animate;
    wire active;
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
        .animate(animate),
        .active(active)
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
    
    reg [7:0] font [96*16-1:0];
    reg [7:0] name [15*40-1:0];
    reg [7:0] menu_t [15*40-1:0];

    initial begin
        $readmemb("name.mem", name, 0, 5 * 40 - 1);
        $readmemb("menu.mem", menu_t, 0, 5 * 40 - 1);
        $readmemb("font.mem", font, 0, 96 * 16 - 1);
    end
    
    // Home Screen
    wire [9:0] row_h;
    wire [9:0] col_h;
    wire [9:0] y_h;
    wire [9:0] x_h;
    wire [7:0] chr_h;
    wire pix_h;
    
    assign row_h = vga_y >> 5;
    assign col_h = vga_x >> 4;
    assign y_h = (vga_y >> 1) & 15;
    assign x_h = (vga_x >> 1) & 7;
    assign chr_h = name[row_h*40+col_h];
    assign pix_h = font[(chr_h-32)*16+y_h] [7-x_h];

    wire [3:0] home;
    assign home = pix_h ? 4'b1111 : 4'b0000;
        
    // Face the monster
    wire [3:0] face_monster;
    assign face_monster [3:0] = 4'b1111;
    
    wire [9:0] row_m;
    wire [9:0] col_m;
    wire [9:0] y_m;
    wire [9:0] x_m;
    wire [7:0] chr_m;
    wire pix_m;
    
    assign row_m = vga_y >> 5;
    assign col_m = vga_x >> 4;
    assign y_m = (vga_y >> 1) & 15;
    assign x_m = (vga_x >> 1) & 7;
    assign chr_m = menu_t[row_m*40+col_m];
    assign pix_m = font[(chr_m-32)*16+y_m] [7-x_m];

    wire [3:0] menu;
    assign menu = pix_m ? 4'b1111 : 4'b0000;
    
    // cursor
    //0 = FIGHT, 1 = ACT, 2 = ITEM, 3 = MERCY
    reg [1:0] cursor_position = 2'd0; 
    reg cursor_position_rst = 0;
    always @(posedge clk)
    begin
        if(cursor_position_rst==1) cursor_position <= 2'd0;
        else if(A_KEY==1 && cursor_position!=2'd0) cursor_position <= cursor_position-1;
        else if(D_KEY==1 && cursor_position!=2'd3) cursor_position <= cursor_position+1;
    end
    wire [15:0] cursor_position_x;
    wire [15:0] cursor_position_y;
    wire [15:0] cursor_radius;
    cursor Cursor(
        .i_cursor_position(cursor_position),
        .o_cx(cursor_position_x),
        .o_cy(cursor_position_y),
        .o_cr(cursor_radius)
    );
    wire [3:0] cursor;
    assign cursor = 
        ( (( (vga_y >= -(2*vga_x) + cursor_position_y + (2*(cursor_position_x - cursor_radius))) 
        & (vga_y >=   vga_x - cursor_position_x + cursor_position_y - (cursor_radius/2)) 
        & (vga_x <= cursor_position_x))
        | ( (vga_y >=  (2*vga_x) + cursor_position_y - (2*(cursor_position_x + cursor_radius))) 
        & (vga_y >= - vga_x + cursor_position_x + cursor_position_y - (cursor_radius/2)) 
        & (vga_x >= cursor_position_x)))
        & (vga_y <= - vga_x + cursor_position_x + cursor_position_y + cursor_radius)
        & (vga_y <=   vga_x - cursor_position_x + cursor_position_y + cursor_radius)) ? 4'b1111 : 4'b0000;

    // ball a
    wire [15:0] ball_a_x;
    wire [15:0] ball_a_y;
    wire [15:0] ball_a_radius;
    reg [15:0] ball_a_damage = 16'd50;
    reg ball_a_rst = 0;
    ball #(.R(5), .X_ENABLE(1), .Y_ENABLE(0), .VELOCITY(2), .C_X(10), .C_Y(20) ) ball_a(
        .i_clk(clk),
        .i_ani_stb(pix_stb),
        .i_animate(animate),
        .i_rst(ball_a_rst),
        .o_cx(ball_a_x),
        .o_cy(ball_a_y),
        .o_r(ball_a_radius)
    );
    wire [3:0] b_a;
    wire [31:0] sq_b_a_x = (vga_x - ball_a_x) * (vga_x - ball_a_x);
    wire [31:0] sq_b_a_y = (vga_y - ball_a_y) * (vga_y - ball_a_y);
    wire [31:0] sq_r_a = ball_a_radius * ball_a_radius;
    assign b_a = 
        (sq_b_a_x + sq_b_a_y <= sq_r_a) ? 4'b1111 : 4'b0000;
    // ball b
    wire [15:0] ball_b_x;
    wire [15:0] ball_b_y;
    wire [15:0] ball_b_radius;
    reg [15:0] ball_b_damage = 16'd80;
    reg ball_b_rst = 0;
    ball #(.R(10), .X_ENABLE(0), .Y_ENABLE(1), .VELOCITY(3), .C_X(20), .C_Y(10) ) ball_b(
        .i_clk(clk),
        .i_ani_stb(pix_stb),
        .i_animate(animate),
        .i_rst(ball_b_rst),
        .o_cx(ball_b_x),
        .o_cy(ball_b_y),
        .o_r(ball_b_radius)
    );
    wire [3:0] b_b;
    wire [31:0] sq_b_b_x = (vga_x - ball_b_x) * (vga_x - ball_b_x);
    wire [31:0] sq_b_b_y = (vga_y - ball_b_y) * (vga_y - ball_b_y);
    wire [31:0] sq_r_b = ball_b_radius * ball_b_radius;
    assign b_b = 
        (sq_b_b_x + sq_b_b_y <= sq_r_b) ? 4'b1111 : 4'b0000;
        
    // ball c
    wire [15:0] ball_c_x;
    wire [15:0] ball_c_y;
    wire [15:0] ball_c_radius;
    reg [15:0] ball_c_damage = 16'd0;
    reg ball_c_rst = 0;
    ball #(.R(10), .X_ENABLE(0), .Y_ENABLE(0), .VELOCITY(3), .C_X(100), .C_Y(60) ) ball_c(
        .i_clk(clk),
        .i_ani_stb(pix_stb),
        .i_animate(animate),
        .i_rst(ball_c_rst),
        .o_cx(ball_c_x),
        .o_cy(ball_c_y),
        .o_r(ball_c_radius)
    );
    wire [3:0] b_c;
    wire [31:0] sq_b_c_x = (vga_x - ball_c_x) * (vga_x - ball_c_x);
    wire [31:0] sq_b_c_y = (vga_y - ball_c_y) * (vga_y - ball_c_y);
    wire [31:0] sq_r_c = ball_c_radius * ball_c_radius;
    
    assign b_c = 
        ( (vga_y >= - vga_x + ball_c_x + ball_c_y - ball_c_radius) 
        & (vga_y >=   vga_x - ball_c_x + ball_c_y - ball_c_radius)
        & (vga_y <= - vga_x + ball_c_x + ball_c_y + ball_c_radius)
        & (vga_y <=   vga_x - ball_c_x + ball_c_y + ball_c_radius)) ? 4'b1010 : 4'b0000;
        
    // ball g
    wire [15:0] ball_g_x;
    wire [15:0] ball_g_y;
    wire [15:0] ball_g_radius;
    reg [15:0] ball_g_heal = 16'd50;
    reg ball_g_rst = 0;
    ball #(.R(8), .X_ENABLE(1), .Y_ENABLE(1), .VELOCITY(3), .C_X(0), .C_Y(75) ) ball_g(
        .i_clk(clk),
        .i_ani_stb(pix_stb),
        .i_animate(animate),
        .i_rst(ball_g_rst),
        .o_cx(ball_g_x),
        .o_cy(ball_g_y),
        .o_r(ball_g_radius)
    );
    wire [3:0] b_g;
    wire [31:0] sq_b_g_x = (vga_x - ball_g_x) * (vga_x - ball_g_x);
    wire [31:0] sq_b_g_y = (vga_y - ball_g_y) * (vga_y - ball_g_y);
    wire [31:0] sq_r_g = (ball_g_radius-2) * (ball_g_radius-5);
    assign b_g = 
        ( (vga_y >= - vga_x + ball_g_x + ball_g_y - ball_g_radius) 
        & (vga_y >=   vga_x - ball_g_x + ball_g_y - ball_g_radius)
        & (vga_y <= - vga_x + ball_g_x + ball_g_y + ball_g_radius)
        & (vga_y <=   vga_x - ball_g_x + ball_g_y + ball_g_radius)
        & ~(sq_b_g_x + sq_b_g_y <= sq_r_g)) ? 4'b1111 : 4'b0000;
        
     // heart
     wire [15:0] heart_x;
     wire [15:0] heart_y;
     wire [15:0] h_x;
     wire [15:0] h_y;
     wire [15:0] h_radius;
     reg heart_rst = 0;
     heart #(.R(13), .X_ENABLE(1), .Y_ENABLE(1), .VELOCITY(2), .C_X(75), .C_Y(75)) Heart(
         .i_clk(clk),
         .i_rst(heart_rst),
         .i_w_key(W_KEY),
         .i_a_key(A_KEY),
         .i_s_key(S_KEY),
         .i_d_key(D_KEY),
         .o_cx(h_x),
         .o_cy(h_y),
         .o_r(h_radius)
     );
     wire [3:0] heart;
     wire [31:0] sq_h_x = (vga_x - h_x) * (vga_x - h_x);
     wire [31:0] sq_h_y = (vga_y - h_y) * (vga_y - h_y);
     wire [31:0] sq_h_r = h_radius * h_radius;

    assign heart = 
        ( (( (vga_y >= -(2*vga_x) + h_y + (2*(h_x - h_radius))) 
        & (vga_y >=   vga_x - h_x + h_y - (h_radius/2)) 
        & (vga_x <= h_x))
        | ( (vga_y >=  (2*vga_x) + h_y - (2*(h_x + h_radius))) 
        & (vga_y >= - vga_x + h_x + h_y - (h_radius/2)) 
        & (vga_x >= h_x)))
        & (vga_y <= - vga_x + h_x + h_y + h_radius)
        & (vga_y <=   vga_x - h_x + h_y + h_radius)) ? 4'b1111 : 4'b0000;
        
    // player bar
    reg [15:0] player_total_hp = 16'd200;
    reg [15:0] player_remain_hp = 16'd200;
    reg [15:0] player_damage;
    wire [15:0] lt_x_player_hp_bar;
    wire [15:0] lt_y_player_hp_bar;
    wire [15:0] br_x_player_hp_bar;
    wire [15:0] br_y_player_hp_bar;
    wire [15:0] player_hp_bar_width;
    wire [15:0] player_hp_bar_height;
    hpbar #(.FX(50), .FY(400), .F_HEIGHT(12), .F_WIDTH(500)) Player_hp_bar(
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

    // monster bar
    reg [15:0] monster_total_hp = 16'd200;
    reg [15:0] monster_remain_hp = 16'd200;
    wire [15:0] lt_x_monster_hp_bar;
    wire [15:0] lt_y_monster_hp_bar;
    wire [15:0] br_x_monster_hp_bar;
    wire [15:0] br_y_monster_hp_bar;
    wire [15:0] monster_hp_bar_width;
    wire [15:0] monster_hp_bar_height;
    hpbar #(.FX(50), .FY(420), .F_HEIGHT(8), .F_WIDTH(500)) Monster_hp_bar(
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
    wire movingbar_overtime;
    reg movingbar_rst = 0;
    wire sp_movingbar_rst;
    singlePulser Movingbar_rst(.in(movingbar_rst), .clk(clk), .out(sp_movingbar_rst));
    
    movingbar #(.R(2), .VELOCITY(8), .I_X(15)) Moving_Bar(
        .i_clk(clk),
        .i_ani_stb(pix_stb),
        .i_animate(animate),
        .i_rst(sp_movingbar_rst),
        .o_cx(movingBar_x),
        .o_cy(movingBar_y),
        .o_r(movingBar_radius),
        .o_h(movingBar_height),
        .o_overtime(movingbar_overtime)
    );
    wire [3:0] movingBar;
    assign movingBar = 
        ((vga_x >= movingBar_x - movingBar_radius)
        & (vga_x <= movingBar_x + movingBar_radius)
        & (vga_y >= movingBar_y) & (vga_y <= movingBar_y + 150)) ? 4'b0111 : 4'b0000;
        
    // instantiate MonsterSprite code
    wire [1:0] MonsterSpriteOn;
    wire [1:0] MSpriteOn; // 1=on, 0=off
    wire [7:0] dout; // pixel value from Monster.mem
    MonsterSprite MonsterDisplay (.i_clk(clk),.xx(vga_x),.yy(vga_y),.aactive(active),
                          .MSpriteOn(MonsterSpriteOn),.dataout(dout));
  
    // load colour palette
    reg [7:0] palette [0:191]; // 8 bit values from the 192 hex entries in the colour palette
    reg [7:0] COL = 0; // background colour palette value
    initial begin
        $readmemh("Pal24bitMonster.mem", palette); // load 192 hex values into "palette"
    end
    
    //draw a monster
    wire [3:0] monsterRed;
    wire [3:0] monsterGreen;
    wire [3:0] monsterBlue;
    assign monsterRed[3:0] = (active & MonsterSpriteOn) ? (palette[(dout*3)])>>4 : 4'b0000;
    assign monsterGreen[3:0] = (active & MonsterSpriteOn) ? (palette[(dout*3)+1])>>4 : 4'b0000;
    assign monsterBlue[3:0] = (active & MonsterSpriteOn) ? (palette[(dout*3)+2])>>4 : 4'b0000;
    
    // state
    reg [15:0] state = 16'h000F; 
    
    // RGB
    reg [3:0] reg_vgaRed = 4'b0000;
    reg [3:0] reg_vgaGreen = 4'b0000;
    reg [3:0] reg_vgaBlue = 4'b0000;
    assign vgaRed[3:0] = reg_vgaRed;
    assign vgaGreen[3:0] = reg_vgaGreen;
    assign vgaBlue[3:0] = reg_vgaBlue;
    
    // timer
    reg [47:0] cnt2 = 0;
    parameter seconds = 6; // 6 seconds timer
    reg [47:0] timer = 47'd100000000*seconds;
    
    //collision
    reg ball_a_heart = 0;
    reg ball_b_heart = 0;
    reg ball_g_heart = 0;
    
    //main
    always @(posedge clk)
    begin
        case(state)
            16'h0000: begin // HOME SCREEN
                // component to render
                reg_vgaRed <= home;
                reg_vgaGreen <= home;
                reg_vgaBlue <= home;
                if(ENTER_KEY==1) state <= 16'h001F;
            end
            16'h0010: begin // FACE THE MONSTER
                // component to render
                reg_vgaRed <= monsterRed 
                | menu
                | cursor;
                reg_vgaGreen <= monsterGreen
                | menu;
                reg_vgaBlue <= monsterBlue
                | menu;
                // if player select FIGHT
                if(cursor_position==2'd0 && ENTER_KEY==1) state <= 16'h002F;
                if(cursor_position==2'd3 && ENTER_KEY==1) state <= 16'h000F;
            end
            16'h0020: begin // PLAYER ATTACKS MONSTER
                // component to render
                reg_vgaRed <= movingBar 
                | frameFight 
                | scoreBarYellow 
                | scoreBarOrange
                | (scoreBarBlue & 4'b1000)
                | monster_hp_bar
                | monsterRed;
                
                reg_vgaGreen <= frameFight 
                | scoreBarYellow 
                | scoreBarGreen 
                | player_hp_bar
                | (scoreBarOrange & 4'b1010)
                | (scoreBarBlue & 4'b1100)
                | monsterGreen;
                
                reg_vgaBlue <= frameFight
                | (scoreBarBlue & 4'b1111)
                | monsterBlue;
                
                if(SPACE_KEY==1)
                begin
                    if(movingBar_x >= 305 & movingBar_x <= 325) player_damage = 16'd100;
                    else if(movingBar_x >= 220 & movingBar_x <= 395) player_damage = 16'd50;
                    else if(movingBar_x >= 160 & movingBar_x <= 455) player_damage = 16'd10;
                    else if(movingBar_x >= 115 & movingBar_x <= 500) player_damage = 16'd5;
                    else player_damage = 16'd0;
                    if(monster_remain_hp <= player_damage) state <= 16'h000F;
                    else 
                    begin
                        monster_remain_hp <= monster_remain_hp - player_damage;
                        state <= 16'h003F;
                    end 
                end
                // if moving bar is gone, next state: MONSTER ATTACKS PLAYER
                if(movingbar_overtime==1) state <= 16'h003F; // go to MONSTER ATTACKS PLAYER
            end
            16'h0030: begin // MONSTER ATTACKS PLAYER
                //collision
                if((b_a==4'b1111) && (heart==4'b1111) && (ball_a_heart==0)) 
                begin
                    ball_a_heart <= 1;
                    if(player_remain_hp <= ball_a_damage) state <= 16'h000F; // PLAYER DIED -> back to HOME SCREEN
                    else player_remain_hp <= player_remain_hp - ball_a_damage;
                end
                if((b_b==4'b1111) && (heart==4'b1111) && (ball_b_heart==0)) 
                begin
                    ball_b_heart <= 1;
                    if(player_remain_hp <= ball_b_damage) state <= 16'h000F; // PLAYER DIED -> back to HOME SCREEN
                    else player_remain_hp <= player_remain_hp - ball_b_damage;
                end
                if((b_g==4'b1111) && (heart==4'b1111) && (ball_g_heart==0)) 
                begin
                    ball_g_heart <= 1;
                    if(player_remain_hp <= player_total_hp - ball_g_heal) 
                        player_remain_hp <= player_remain_hp + ball_g_heal; // PLAYER DIED -> back to HOME SCREEN
                    else player_remain_hp <= player_total_hp;
                end
                // component to render
                reg_vgaRed <= (~ball_a_heart ? b_a : 4'b0000)  
                | (~ball_b_heart ? b_b : 4'b0000) 
                | (b_c & ~heart)   
                | heart 
                | frameEscape 
                | monster_hp_bar
                | monsterRed;
                reg_vgaGreen <= (~ball_a_heart ? b_a : 4'b0000)  
                | (~ball_b_heart ? b_b : 4'b0000)  
                | (~ball_g_heart ? b_g : 4'b0000)  
                | (b_c & ~heart)    
                | frameEscape 
                | player_hp_bar
                | monsterGreen;
                reg_vgaBlue <= (~ball_a_heart ? b_a : 4'b0000)  
                | (~ball_b_heart ? b_b : 4'b0000) 
                | (b_c & ~heart)  
                | frameEscape
                | monsterBlue;
                
                // after 6 seconds, next state: FACE THE MONSTER
                if(cnt2 == timer) 
                begin
                    cnt2 <= 0;
                    state <= 16'h001F;
                end
                else cnt2 <= cnt2 + 1;
            end
            
            //reset states
            16'h000F: begin
                //begin reset
                player_remain_hp <= player_total_hp;
                monster_remain_hp <= monster_total_hp;
                //////////////
                state <= 16'h000E;
            end
            16'h000E: begin
                //end reset
                //////////////
                state <= 16'h0000;
            end
            16'h001F: begin
                //begin reset
                cursor_position_rst <= 1;
                //////////////
                state <= 16'h001E;
            end
            16'h001E: begin
                //end reset
                cursor_position_rst <= 0;
                //////////////
                state <= 16'h0010;
            end
            16'h002F: begin
                //begin reset
                movingbar_rst <= 1;
                //////////////
                state <= 16'h002E;
            end
            16'h002E: begin
                //end reset
                movingbar_rst <= 0;
                //////////////
                state <= 16'h0020;
            end
            16'h003F: begin
                //begin reset
                ball_a_heart <= 0;
                ball_b_heart <= 0;
                ball_g_heart <= 0;
                ball_a_rst <= 1;
                ball_b_rst <= 1;
                ball_c_rst <= 1;
                ball_g_rst <= 1;
                heart_rst <= 1;
                //////////////
                state <= 16'h003E;
            end
            16'h003E: begin
                //end reset
                ball_a_rst <= 0;
                ball_b_rst <= 0;
                ball_c_rst <= 0;
                ball_g_rst <= 0;
                heart_rst <= 0;
                //////////////
                state <= 16'h0030;
            end
        endcase
    end
    
endmodule