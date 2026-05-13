/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Draw background.
 */

module draw_bg 
    import vga_pkg::*;
    (
        input  logic clk,
        input  logic rst_n,
        input  game_state_t state,

        vga_if.in  vga_in,
        vga_if.out vga_out
    );

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;


    /**
     * Local variables and signals
     */

    logic [11:0] rgb_nxt;


    /**
     * Internal logic
     */

    always_ff @(posedge clk or negedge rst_n) begin : bg_ff_blk
        if (!rst_n) begin
            vga_out.vcount <= '0;
            vga_out.vsync  <= '0;
            vga_out.vblnk  <= '0;
            vga_out.hcount <= '0;
            vga_out.hsync  <= '0;
            vga_out.hblnk  <= '0;
            vga_out.rgb    <= '0;
        end else begin
            vga_out.vcount <= vga_in.vcount;
            vga_out.vsync  <= vga_in.vsync;
            vga_out.vblnk  <= vga_in.vblnk;
            vga_out.hcount <= vga_in.hcount;
            vga_out.hsync  <= vga_in.hsync;
            vga_out.hblnk  <= vga_in.hblnk;
            vga_out.rgb    <= rgb_nxt;
        end
    end

        always_comb begin : bg_comb_blk
            if (vga_in.vblnk || vga_in.hblnk) begin           
                rgb_nxt = 12'h0_0_0;                      
            end else begin   
                if (state == STATE_MENU) begin
                    if (vga_in.vcount == 0)                                 
                        rgb_nxt = 12'hf_f_0;                                
                    else if (vga_in.vcount == VER_PIXELS - 1)               
                        rgb_nxt = 12'hf_0_0;                                
                    else if (vga_in.hcount == 0)                            
                        rgb_nxt = 12'h0_f_0;                                
                    else if (vga_in.hcount == HOR_PIXELS - 1)               
                        rgb_nxt = 12'h0_0_f;
                    
                    else if ((vga_in.hcount >= 300 && vga_in.hcount <= 500) && 
                        (vga_in.vcount >= 250 && vga_in.vcount <= 350)) begin
                        rgb_nxt = 12'h0_f_0;
                    end else begin
                        rgb_nxt = 12'h2_2_2;
                    end

                end else begin
                
                    if (vga_in.vcount == 0)                                 
                        rgb_nxt = 12'hf_f_0;                                
                    else if (vga_in.vcount == VER_PIXELS - 1)               
                        rgb_nxt = 12'hf_0_0;                                
                    else if (vga_in.hcount == 0)                            
                        rgb_nxt = 12'h0_f_0;                                
                    else if (vga_in.hcount == HOR_PIXELS - 1)               
                        rgb_nxt = 12'h0_0_f;
                else                                   
                    rgb_nxt = 12'hf_c_c;
            end
        end
    end

endmodule
