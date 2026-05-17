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
    output logic vs,
    output logic hs,
    output logic [3:0] r,
    output logic [3:0] g,
    output logic [3:0] b
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

    vga_if vga_tim(); 
    vga_if vga_bg();
    vga_if vga_rect();
    vga_if vga_falling_out();
    vga_if vga_score_out();

    /**
     * Wyjścia na ekran
     */
    assign vs = vga_score_out.vsync;
    assign hs = vga_score_out.hsync;
    assign {r,g,b} = game_over_sig ? 12'h000 : vga_score_out.rgb;

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
        .space_pressed (space_pressed_sig)
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

    draw_score u_draw_score (
        .clk         (clk),
        .rst_n       (rst_n_65),
        .score_ones  (score_1),
        .score_tens  (score_10),
        .score_hunds (score_100),
        .vga_in      (vga_falling_out), 
        .vga_out     (vga_score_out)    
    );

endmodule