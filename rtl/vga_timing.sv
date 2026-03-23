module vga_timing 
    import vga_pkg::*;
    (
        input  logic clk,
        input  logic rst_n,
        output logic [10:0] vcount,
        output logic vsync,
        output logic vblnk,
        output logic [10:0] hcount,
        output logic hsync,
        output logic hblnk
    );
    
    /* Local variables and signals */
    
    logic [10:0] vcount_nxt, hcount_nxt;
    logic vsync_nxt, vblnk_nxt, hsync_nxt, hblnk_nxt;
    
    /* Internal logic */
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vcount <= '0;
            hcount <= '0;
            vsync <= '0;
            vblnk <= '0;
            hsync <= '0;
            hblnk <= '0;
        end else begin
            vcount <= vcount_nxt;
            hcount <= hcount_nxt;
            vsync <= vsync_nxt;
            vblnk <= vblnk_nxt;
            hsync <= hsync_nxt;
            hblnk <= hblnk_nxt;
        end
    end
    
    always_comb begin
        hcount_nxt = hcount;
        vcount_nxt = vcount;
    
        if (hcount == HOR_TOTAL_TIME - 1) begin
            hcount_nxt = '0;
    
            if (vcount == VER_TOTAL_TIME - 1) begin
                vcount_nxt = '0;
            end else begin
            vcount_nxt = vcount + 1;
            end
    
        end else begin
            hcount_nxt = hcount + 1;
        end
    
    assign hsync_nxt = ((hcount >=  HOR_SYNC_START) && (hcount< HOR_SYNC_START + HOR_SYNC_TIME));
    assign hblnk_nxt = (hcount >= HOR_BLANK_START);
    assign vsync_nxt = ((vcount >= VER_SYNC_START) && (vcount < VER_SYNC_START + VER_SYNC_TIME));
    assign vblnk_nxt = (vcount >= VER_BLANK_START);
    
    end
    
    endmodule
    