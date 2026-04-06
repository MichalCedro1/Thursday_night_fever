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
        output logic vs,
        output logic hs,
        output logic [3:0] r,
        output logic [3:0] g,
        output logic [3:0] b
    );

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local variables and signals
     */


    vga_if vga_tim(); 
    vga_if vga_bg();
    vga_if vga_rect();
    /**
     * Signals assignments
     */
    assign vs = vga_rect.vsync;
    assign hs = vga_rect.hsync;
    assign {r,g,b} = vga_rect.rgb;


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
        
        .vga_in(vga_tim),
        .vga_out(vga_bg)
    );


    draw_rect u_draw_rect (
        .clk        (clk),
        .rst_n      (rst_n),

        .vga_in(vga_bg),
        .vga_out(vga_rect)
    );

endmodule
