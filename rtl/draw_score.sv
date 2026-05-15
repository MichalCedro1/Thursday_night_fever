module draw_score (
    input logic clk,
    input logic rst_n,
    
    input logic [3:0] score_ones,
    input logic [3:0] score_tens,
    input logic [3:0] score_hunds,
    
    vga_if.in  vga_in,
    vga_if.out vga_out
);

    logic [10:0] font_addr;
    logic [7:0]  font_pixels;
    logic [6:0]  char_code;

    // Obszar wyniku w lewym górnym rogu (3 cyfry po 8 pikseli szerokości)
    // X = od 16 do 39. Y = od 16 do 31 (wysokość 16px)
    always_comb begin
        if      (vga_in.hcount < 24) char_code = 7'h30 + score_hunds; // Setki
        else if (vga_in.hcount < 32) char_code = 7'h30 + score_tens;  // Dziesiątki
        else                         char_code = 7'h30 + score_ones;  // Jedności
    end

    // Adres dla ROM: {znak ASCII [6:0], linijka Y znaku [3:0]}
    assign font_addr = {char_code, vga_in.vcount[3:0]};

    // Instancja Twojej pamięci ROM z czcionkami
    font_rom u_font (
        .clk              (clk),
        .addr             (font_addr),
        .char_line_pixels (font_pixels)
    );

    // KRYTYCZNE: font_rom wprowadza opóźnienie 1 cyklu zegara.
    // Musimy opóźnić interfejs VGA, żeby współrzędne czekały na piksele z pamięci!
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

    logic pixel_bit;
    // Wybieramy konkretny bit z 8-bitowej linijki (odwracamy, bo piksel 7 to lewy brzeg litery)
    assign pixel_bit = font_pixels[ 3'd7 - vga_delayed.hcount[2:0] ];

    logic is_score_area;
    assign is_score_area = (vga_delayed.hcount >= 16 && vga_delayed.hcount < 40) &&
                           (vga_delayed.vcount >= 16 && vga_delayed.vcount < 32);

    logic [11:0] rgb_nxt;
    always_comb begin
        rgb_nxt = vga_delayed.rgb;
        // Jeśli jesteśmy w obszarze wyniku i piksel litery to '1', pomaluj go na biało
        if (is_score_area && pixel_bit) begin
            rgb_nxt = 12'hFFF; 
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