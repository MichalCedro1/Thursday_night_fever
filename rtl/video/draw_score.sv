module draw_score #(
    parameter X_POS = 16,
    parameter Y_POS = 16  
)(
    input logic clk,
    input logic rst_n,

    input logic game_active,
    
    input logic [3:0]  score_ones,
    input logic [3:0]  score_tens,
    input logic [3:0]  score_hunds,
    input logic [11:0] text_color,
    
    vga_if.in  vga_in,
    vga_if.out vga_out
);

    logic [10:0] font_addr;
    logic [7:0]  font_pixels;
    logic [6:0]  char_code;
    logic [11:0] rgb_nxt;
    logic pixel_bit;

    always_comb begin
        if      (vga_in.hcount < X_POS + 8)  char_code = 7'h30 + score_hunds; 
        else if (vga_in.hcount < X_POS + 16) char_code = 7'h30 + score_tens;  
        else                                 char_code = 7'h30 + score_ones;  
    end

    font_rom u_font (
        .clk              (clk),
        .addr             (font_addr),
        .char_line_pixels (font_pixels)
    );

    assign pixel_bit = font_pixels[3'd7 - vga_delayed.hcount[2:0]];

    logic is_score_area;
    assign is_score_area = (vga_delayed.hcount >= X_POS && vga_delayed.hcount < X_POS + 24) &&
                           (vga_delayed.vcount >= Y_POS && vga_delayed.vcount < Y_POS + 16);

    always_comb begin
        rgb_nxt = vga_delayed.rgb;
        if (is_score_area && pixel_bit && game_active) begin
            rgb_nxt = text_color;
        end
    end

    assign font_addr = {char_code, vga_in.vcount[3:0]};

    vga_if vga_delayed();

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vga_delayed.hcount <= '0; vga_delayed.vcount <= '0;
            vga_delayed.vsync  <= '0; vga_delayed.hsync  <= '0;
            vga_delayed.vblnk  <= '0; vga_delayed.hblnk  <= '0;
            vga_delayed.rgb    <= '0;
        end else begin
            vga_delayed.hcount <= vga_in.hcount; vga_delayed.vcount <= vga_in.vcount;
            vga_delayed.vsync  <= vga_in.vsync;  vga_delayed.hsync  <= vga_in.hsync;
            vga_delayed.vblnk  <= vga_in.vblnk;  vga_delayed.hblnk  <= vga_in.hblnk;
            vga_delayed.rgb    <= vga_in.rgb;
        end
    end


    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vga_out.hcount <= '0; vga_out.vcount <= '0;
            vga_out.vsync  <= '0; vga_out.hsync  <= '0;
            vga_out.vblnk  <= '0; vga_out.hblnk  <= '0;
            vga_out.rgb    <= '0;
        end else begin
            vga_out.hcount <= vga_delayed.hcount; vga_out.vcount <= vga_delayed.vcount;
            vga_out.vsync  <= vga_delayed.vsync;  vga_out.hsync  <= vga_delayed.hsync;
            vga_out.vblnk  <= vga_delayed.vblnk;  vga_out.hblnk  <= vga_delayed.hblnk;
            vga_out.rgb    <= rgb_nxt;
        end
    end

endmodule