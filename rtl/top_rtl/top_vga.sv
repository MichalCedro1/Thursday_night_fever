/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk
 *
 * Description:
 * The project top module.
 */

 /**
 * Ostateczna wersja MVP
 * The project top module.
 */

 module top_vga (
    input  logic clk,       
    input  logic rst_n,  
    inout  wire  PS2Clk,
    inout  wire  PS2Data,
    input  logic uart_rx_pin,
    output logic uart_tx_pin,
    output logic vs,
    output logic hs,
    output logic [3:0] r,
    output logic [3:0] g,
    output logic [3:0] b,
    output logic [1:0] current_song_id
);
    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;

    logic rst_n_65;
    reset_sync u_rst_sync_65 (
        .clk(clk),
        .async_rst_n(rst_n),
        .sync_rst_n(rst_n_65)
    );

    /**
     * Sygnały i interfejsy
     */
    game_state_t current_state;
    logic        game_over_sig;
    logic [11:0] key_xpos, key_ypos;
    logic [11:0] enemy_x, enemy_y;
    logic        enemy_active;
    logic        space_pressed_sig;
    logic [3:0]  score_1, score_10, score_100;
    logic        player_color_sig, enemy_color_sig;
    logic        launch_game_sig;

    vga_if vga_tim(); 
    vga_if vga_bg();
    vga_if vga_rect();
    vga_if vga_falling_out();
    vga_if vga_game_over();
    vga_if vga_score_out();

    /**
     * Wyjścia na ekran
     */
    assign vs = vga_score_out.vsync;
    assign hs = vga_score_out.hsync;
    assign {r,g,b} = vga_score_out.rgb;

    assign vga_game_over.hcount = vga_falling_out.hcount;
    assign vga_game_over.hsync  = vga_falling_out.hsync;
    assign vga_game_over.hblnk  = vga_falling_out.hblnk;
    assign vga_game_over.vcount = vga_falling_out.vcount;
    assign vga_game_over.vsync  = vga_falling_out.vsync;
    assign vga_game_over.vblnk  = vga_falling_out.vblnk;

    assign vga_game_over.rgb    = game_over_sig ? 12'h000 : vga_falling_out.rgb;

    /**
     * Instancje modułów
     */
    vga_timing u_vga_timing (
        .clk    (clk),
        .rst_n  (rst_n_65),
        .vcount (vga_tim.vcount),
        .vsync  (vga_tim.vsync),
        .vblnk  (vga_tim.vblnk),
        .hcount (vga_tim.hcount),
        .hsync  (vga_tim.hsync),
        .hblnk  (vga_tim.hblnk)
    );

    game_fsm u_state_machine (
        .clk              (clk),
        .rst_n            (rst_n_65),
        .mouse_left_click (space_pressed_sig),
        .launch_game      (launch_game_sig),
        .mouse_x          (12'd400),          
        .mouse_y          (12'd300),          
        .current_state    (current_state)
    );

    draw_bg u_draw_bg (
        .clk     (clk),
        .rst_n   (rst_n_65),
        .state   (current_state),
        .vga_in  (vga_tim),
        .vga_out (vga_bg)
    );

    keyboard_ctrl u_keyboard_ctrl (
        .clk           (clk),
        .rst_n         (rst_n_65),
        .ps2_clk       (PS2Clk),
        .ps2_data      (PS2Data),
        .vsync         (vga_tim.vsync),  
        .xpos          (key_xpos),
        .ypos          (key_ypos),
        .player_color  (player_color_sig),
        .space_pressed (space_pressed_sig),
        .current_song_id(current_song_id)
    );

    draw_rect u_draw_rect (
        .clk              (clk),
        .rst_n            (rst_n_65),
        .enable           (current_state == STATE_GRA),
        .xpos             (key_xpos),
        .ypos             (key_ypos),
        .player_color_bit (player_color_sig),
        .vga_in           (vga_bg),
        .vga_out          (vga_rect)
    );

    draw_falling_block u_draw_falling (
        .clk         (clk),
        .rst_n       (rst_n_65),
        .xpos        (enemy_x),
        .ypos        (enemy_y),
        .active      (enemy_active && current_state == STATE_GRA),
        .block_color (enemy_color_sig),
        .vga_in      (vga_rect),
        .vga_out     (vga_falling_out)
    );

    falling_block_ctrl u_enemy_logic (
        .clk          (clk),
        .rst_n        (rst_n_65),
        .vsync        (vga_tim.vsync),
        .enable       (current_state == STATE_GRA),
        .player_x     (key_xpos),
        .player_y     (key_ypos),
        .player_color (player_color_sig),
        .space_pressed(space_pressed_sig),
        .block_x      (enemy_x),
        .block_y      (enemy_y),
        .block_active (enemy_active),
        .block_color  (enemy_color_sig),
        .score_ones   (score_1),           
        .score_tens   (score_10),          
        .score_hunds  (score_100),
        .game_over    (game_over_sig)
    );

    logic [7:0] tx_data, rx_data;
    logic tx_start, tx_busy, rx_ready;

    uart_tx u_tx (.clk(clk), .rst_n(rst_n_65), .tx_data(tx_data), .tx_start(tx_start), .tx(uart_tx_pin), .tx_busy(tx_busy));
    uart_rx u_rx (.clk(clk), .rst_n(rst_n_65), .rx(uart_rx_pin), .rx_data(rx_data), .rx_ready(rx_ready));

    logic [3:0] opp_1, opp_10, opp_100;
    logic opp_ready;
    logic [1:0] match_result;

    multiplayer_ctrl u_mp_ctrl (
    .clk(clk), .rst_n(rst_n_65), 
    .game_enable(current_state == STATE_GRA),
    .game_over(game_over_sig),
    .my_score_ones(score_1), .my_score_tens(score_10), .my_score_hunds(score_100),
    .space_pressed(space_pressed_sig),     
    .rx_data(rx_data), .rx_ready(rx_ready), 
    .tx_data(tx_data), .tx_start(tx_start), .tx_busy(tx_busy),
    .opp_score_ones(opp_1), .opp_score_tens(opp_10), .opp_score_hunds(opp_100),
    .opp_score_ready(opp_ready), .match_result(match_result),
    .launch_game(launch_game_sig)        
);

    logic [11:0] my_final_color;
    always_comb begin
        if (!game_over_sig)        my_final_color = 12'hFFF; 
        else if (match_result==1)  my_final_color = 12'h0F0; 
        else if (match_result==2)  my_final_color = 12'hF00; 
        else                       my_final_color = 12'hFF0;
    end

    vga_if vga_my_score_out();
    draw_score #( .X_POS(16), .Y_POS(16) ) u_draw_my_score (
        .clk(clk), .rst_n(rst_n_65),
        .score_ones(score_1), .score_tens(score_10), .score_hunds(score_100),
        .text_color(my_final_color), .vga_in(vga_game_over), .vga_out(vga_my_score_out)
    );


    draw_score #( .X_POS(512), .Y_POS(16) ) u_draw_opp_score (
        .clk(clk), .rst_n(rst_n_65),
        .score_ones(opp_1), .score_tens(opp_10), .score_hunds(opp_100),
        .text_color(12'hFFF), 
        .vga_in(vga_my_score_out), .vga_out(vga_score_out)
    );

endmodule