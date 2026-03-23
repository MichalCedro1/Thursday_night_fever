/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Draw background.
 */

module draw_bg (
        input  logic clk,
        input  logic rst_n,

        input  logic [10:0] vcount_in,
        input  logic        vsync_in,
        input  logic        vblnk_in,
        input  logic [10:0] hcount_in,
        input  logic        hsync_in,
        input  logic        hblnk_in,

        output logic [10:0] vcount_out,
        output logic        vsync_out,
        output logic        vblnk_out,
        output logic [10:0] hcount_out,
        output logic        hsync_out,
        output logic        hblnk_out,

        output logic [11:0] rgb_out
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
            vcount_out <= '0;
            vsync_out  <= '0;
            vblnk_out  <= '0;
            hcount_out <= '0;
            hsync_out  <= '0;
            hblnk_out  <= '0;
            rgb_out    <= '0;
        end else begin
            vcount_out <= vcount_in;
            vsync_out  <= vsync_in;
            vblnk_out  <= vblnk_in;
            hcount_out <= hcount_in;
            hsync_out  <= hsync_in;
            hblnk_out  <= hblnk_in;
            rgb_out    <= rgb_nxt;
        end
    end

    always_comb begin : bg_comb_blk
        if (vblnk_in || hblnk_in) begin             // Blanking region:
            rgb_nxt = 12'h0_0_0;                    // - make it it black.
        end else begin                              // Active region:
            if ((hcount_in >= 270 && hcount_in <= 284 && vcount_in >= 250 && vcount_in <= 349) ||
                (hcount_in >= 330 && hcount_in <= 344 && vcount_in >= 250 && vcount_in <= 349) || 
                (hcount_in >= 285 && hcount_in <= 299 && vcount_in >= 270 && vcount_in <= 309) || 
                (hcount_in >= 315 && hcount_in <= 329 && vcount_in >= 270 && vcount_in <= 309) || 
                (hcount_in >= 300 && hcount_in <= 314 && vcount_in >= 290 && vcount_in <= 329))  
                rgb_nxt = 12'h4_e_d;

            else if ((hcount_in >= 350 && hcount_in <= 389 && vcount_in >= 270 && vcount_in <= 279) || 
                (hcount_in >= 350 && hcount_in <= 389 && vcount_in >= 320 && vcount_in <= 329) || 
                (hcount_in >= 350 && hcount_in <= 359 && vcount_in >= 270 && vcount_in <= 329))  
                rgb_nxt = 12'h4_e_d;

            else if ((hcount_in >= 410 && hcount_in <= 449 && vcount_in >= 270 && vcount_in <= 279) || 
                (hcount_in >= 410 && hcount_in <= 449 && vcount_in >= 320 && vcount_in <= 329) || 
                (hcount_in >= 410 && hcount_in <= 419 && vcount_in >= 270 && vcount_in <= 329) || 
                (hcount_in >= 440 && hcount_in <= 449 && vcount_in >= 300 && vcount_in <= 329) || 
                (hcount_in >= 430 && hcount_in <= 449 && vcount_in >= 300 && vcount_in <= 309))   
                rgb_nxt = 12'hf_0_f;

            else if ((hcount_in >= 470 && hcount_in <= 509 && vcount_in >= 270 && vcount_in <= 279) || 
                (hcount_in >= 470 && hcount_in <= 509 && vcount_in >= 320 && vcount_in <= 329) || 
                (hcount_in >= 470 && hcount_in <= 479 && vcount_in >= 270 && vcount_in <= 329)) 
                rgb_nxt = 12'hf_0_f;

            else                                   
                rgb_nxt = 12'hf_c_c;              
        end
    end

endmodule
