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
        if (vga_in.vblnk || vga_in.hblnk) begin             // Blanking region:
            rgb_nxt = 12'h0_0_0;                    // - make it it black.
        end else begin   
            if (vga_in.vcount == 0)                     // - top edge:
                rgb_nxt = 12'hf_f_0;                // - - make a yellow line.
            else if (vga_in.vcount == VER_PIXELS - 1)   // - bottom edge:
                rgb_nxt = 12'hf_0_0;                // - - make a red line.
            else if (vga_in.hcount == 0)                // - left edge:
                rgb_nxt = 12'h0_f_0;                // - - make a green line.
            else if (vga_in.hcount == HOR_PIXELS - 1)   // - right edge:
                rgb_nxt = 12'h0_0_f;                            // Active region:
                else if ((vga_in.hcount >= 270 && vga_in.hcount <= 284 && vga_in.vcount >= 250 && vga_in.vcount <= 349) ||
                (vga_in.hcount >= 330 && vga_in.hcount <= 344 && vga_in.vcount >= 250 && vga_in.vcount <= 349) || 
                (vga_in.hcount >= 285 && vga_in.hcount <= 299 && vga_in.vcount >= 270 && vga_in.vcount <= 309) || 
                (vga_in.hcount >= 315 && vga_in.hcount <= 329 && vga_in.vcount >= 270 && vga_in.vcount <= 309) || 
                (vga_in.hcount >= 300 && vga_in.hcount <= 314 && vga_in.vcount >= 290 && vga_in.vcount <= 329))  
                rgb_nxt = 12'h4_e_d;

            else if ((vga_in.hcount >= 350 && vga_in.hcount <= 389 && vga_in.vcount >= 270 && vga_in.vcount <= 279) || 
                (vga_in.hcount >= 350 && vga_in.hcount <= 389 && vga_in.vcount >= 320 && vga_in.vcount <= 329) || 
                (vga_in.hcount >= 350 && vga_in.hcount <= 359 && vga_in.vcount >= 270 && vga_in.vcount <= 329))  
                rgb_nxt = 12'h4_e_d;

            else if ((vga_in.hcount >= 410 && vga_in.hcount <= 449 && vga_in.vcount >= 270 && vga_in.vcount <= 279) || 
                (vga_in.hcount >= 410 && vga_in.hcount <= 449 && vga_in.vcount >= 320 && vga_in.vcount <= 329) || 
                (vga_in.hcount >= 410 && vga_in.hcount <= 419 && vga_in.vcount >= 270 && vga_in.vcount <= 329) || 
                (vga_in.hcount >= 440 && vga_in.hcount <= 449 && vga_in.vcount >= 300 && vga_in.vcount <= 329) || 
                (vga_in.hcount >= 430 && vga_in.hcount <= 449 && vga_in.vcount >= 300 && vga_in.vcount <= 309))   
                rgb_nxt = 12'hf_0_f;

            else if ((vga_in.vcount >= 470 && vga_in.vcount <= 509 && vga_in.hcount >= 270 && vga_in.hcount <= 279) || 
                (vga_in.vcount >= 470 && vga_in.vcount <= 509 && vga_in.hcount >= 320 && vga_in.hcount <= 329) || 
                (vga_in.vcount >= 470 && vga_in.vcount <= 479 && vga_in.hcount >= 270 && vga_in.hcount <= 329)|| 
                (vga_in.vcount >= 550 && vga_in.vcount <= 559 && vga_in.hcount >= 270 && vga_in.hcount <= 329)) 
                rgb_nxt = 12'hd_9_e;

            else if ((vga_in.vcount >= 300 && vga_in.vcount <= 360 && vga_in.hcount >= 250 && vga_in.hcount <= 259) || 
                (vga_in.vcount >= 300 && vga_in.vcount <= 360 && vga_in.hcount >= 461 && vga_in.hcount <= 470) || 
                (vga_in.vcount >= 360 && vga_in.vcount <= 369 && vga_in.hcount >= 250 && vga_in.hcount <= 470)) 
                rgb_nxt = COLOUR;

            else                                   
                rgb_nxt = 12'hf_c_c;
        end
    end

endmodule
