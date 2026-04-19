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

    logic [11:0] mouse_xpos;
    logic [11:0] mouse_ypos;

    MouseCtl u_mouse_ctl (
        .clk(clk100MHz),
        .rst(!rst_n), 
        .xpos(mouse_xpos),
        .ypos(mouse_ypos),
        .zpos(),  
        .left(),   
        .middle(),
        .right(),
        .new_event(),
        .value(12'b0), 
        .setx(1'b0),
        .sety(1'b0),
        .setmax_x(1'b0),
        .setmax_y(1'b0),
        .ps2_clk(PS2Clk),
        .ps2_data(PS2Data)
    );

    logic [11:0] xpos_sync1, xpos_sync2;
    logic [11:0] ypos_sync1, ypos_sync2;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            xpos_sync1 <= 12'b0;
            xpos_sync2 <= 12'b0;
            ypos_sync1 <= 12'b0;
            ypos_sync2 <= 12'b0;
        end else begin
            xpos_sync1 <= mouse_xpos;
            ypos_sync1 <= mouse_ypos;
            
            xpos_sync2 <= xpos_sync1;
            ypos_sync2 <= ypos_sync1;
        end
    end


    draw_rect u_draw_rect (
        .clk        (clk),
        .rst_n      (rst_n),
        .xpos       (xpos_sync2),
        .ypos       (ypos_sync2),
        .vga_in(vga_bg),
        .vga_out(vga_rect)
    );


endmodule
