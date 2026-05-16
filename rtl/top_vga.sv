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

 module top_vga (
    input  logic clk,
    input  logic rst_n,
    inout  wire PS2Clk,
    inout  wire PS2Data,
    input  wire clk100MHz,
    output logic vs,
    output logic hs,
    output logic [3:0] r,
    output logic [3:0] g,
    output logic [3:0] b
);

timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;

/**
 * Local variables and signals
 */

// POPRAWKA 1: Interfejsy układają się w łańcuch:
// tim -> bg -> rect (gracz) -> falling_out (przeciwnik) -> mouse -> EKRAN
vga_if vga_tim(); 
vga_if vga_bg();
vga_if vga_rect();
vga_if vga_falling_out();
vga_if vga_mouse();
vga_if vga_score_out();

logic game_over_sig;


/**
 * Signals assignments
 */

assign vs = vga_mouse.vsync;
assign hs = vga_mouse.hsync;
assign {r,g,b} = game_over_sig ? 12'h000 : vga_mouse.rgb;

game_state_t current_state;

// Przeniosłem deklaracje sygnałów wyżej, żeby było czytelniej
logic [11:0] key_xpos;
logic [11:0] key_ypos;

logic [11:0] mouse_xpos;
logic [11:0] mouse_ypos;
logic        mouse_left;

logic [11:0] xpos_sync1, xpos_sync2;
logic [11:0] ypos_sync1, ypos_sync2;
logic        left_sync1, left_sync2;

logic [11:0] enemy_x;
logic [11:0] enemy_y;
logic        enemy_active;

logic space_pressed_sig;
logic [3:0] score_1, score_10, score_100;

/**
 * Submodules instances
 */

vga_timing u_vga_timing (
    .clk,
    .rst_n,
    .vcount (vga_tim.vcount),
    .vsync  (vga_tim.vsync),
    .vblnk  (vga_tim.vblnk),
    .hcount (vga_tim.hcount),
    .hsync  (vga_tim.hsync),
    .hblnk  (vga_tim.hblnk)
);

draw_bg u_draw_bg (
    .clk,
    .rst_n,
    .state   (current_state),
    .vga_in  (vga_tim),
    .vga_out (vga_bg)
);

logic player_color_sig;
logic enemy_color_sig;

keyboard_ctrl u_keyboard_ctrl (
    .clk,
    .rst_n      (rst_n),
    .ps2_clk    (PS2Clk),
    .ps2_data   (PS2Data),
    .vsync      (vga_tim.vsync),  
    .xpos       (key_xpos),
    .ypos       (key_ypos),
    .player_color  (player_color_sig),
    .space_pressed (space_pressed_sig)
);

MouseCtl u_mouse_ctl (
    .clk,
    .rst(!rst_n), 
    .xpos(mouse_xpos),
    .ypos(mouse_ypos),
    .zpos(),  
    .left(mouse_left), 
    .middle(),
    .right(),
    .new_event(),
    .value(12'b0), 
    .setx(1'b0),
    .sety(1'b0),
    .setmax_x(1'b0),
    .setmax_y(1'b0),
    .ps2_clk(PS2Clk),     // Pamiętaj, co mówiliśmy o Hubach! ;)
    .ps2_data(PS2Data)
);

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        xpos_sync1 <= 12'b0;
        xpos_sync2 <= 12'b0;
        ypos_sync1 <= 12'b0;
        ypos_sync2 <= 12'b0;
        left_sync1 <= 1'b0;
        left_sync2 <= 1'b0;
    end else begin
        xpos_sync1 <= mouse_xpos;
        ypos_sync1 <= mouse_ypos;
        left_sync1 <= mouse_left;
        
        xpos_sync2 <= xpos_sync1;
        ypos_sync2 <= ypos_sync1;
        left_sync2 <= left_sync1;
    end
end

draw_rect u_draw_rect (
    .clk,
    .rst_n            (rst_n),
    .enable           (current_state == STATE_GRA),
    .xpos             (key_xpos),
    .ypos             (key_ypos),
    .player_color_bit (player_color_sig),
    .vga_in           (vga_bg),
    .vga_out          (vga_rect)
);

draw_falling_block u_draw_falling (
    .clk,
    .rst_n      (rst_n),
    .xpos       (enemy_x),
    .ypos       (enemy_y),
    .active     (enemy_active && current_state == STATE_GRA), // Dodatkowe zabezp. rysowania
    .block_color (enemy_color_sig),
    .vga_in     (vga_rect),
    .vga_out    (vga_falling_out)
);

draw_mouse u_draw_mouse (
    .clk,
    .rst_n      (rst_n),
    .enable     (current_state == STATE_MENU),
    .xpos       (xpos_sync2), 
    .ypos       (ypos_sync2),
    .vga_in     (vga_score_out), 
    .vga_out    (vga_mouse)
);

// Logika zmiany stanu gry
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= STATE_MENU;
    end else begin
        if (current_state == STATE_MENU) begin
            if (left_sync2 && (xpos_sync2 >= 300 && xpos_sync2 <= 500) && 
              (ypos_sync2 >= 250 && ypos_sync2 <= 350)) begin
                current_state <= STATE_GRA;
            end
        end
    end
end

// Logika spadania przeciwnika
falling_block_ctrl u_enemy_logic (
    .clk,
    .rst_n       (rst_n),
    .vsync       (vga_tim.vsync),
    .enable      (current_state == STATE_GRA),
    .player_x    (key_xpos), // Podłączamy pozycję gracza z klawiatury
    .player_y    (key_ypos), // Podłączamy pozycję gracza z klawiatury
    .player_color(player_color_sig),
    .space_pressed(space_pressed_sig),
    .block_x     (enemy_x),
    .block_y     (enemy_y),
    .block_active(enemy_active),
    .block_color (enemy_color_sig),
    .score_ones   (score_1),           // <-- BRAKOWAŁO TEGO GNIAZDKA
    .score_tens   (score_10),          // <-- BRAKOWAŁO TEGO GNIAZDKA
    .score_hunds  (score_100),
    .game_over    (game_over_sig)
);

draw_score u_draw_score (
    .clk,
    .rst_n       (rst_n),
    .score_ones  (score_1),
    .score_tens  (score_10),
    .score_hunds (score_100),
    .vga_in      (vga_falling_out), // Wchodzi to, co z przeciwnika
    .vga_out     (vga_score_out)    // Wychodzi z nałożonymi napisami
);

endmodule