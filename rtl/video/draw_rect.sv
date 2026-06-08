module draw_rect (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        enable,  
    input  logic [11:0] xpos,
    input  logic [11:0] ypos,
    input  logic        player_color_bit, 
    input  logic        char_select,
    
    vga_if.in  vga_in,
    vga_if.out vga_out
);

    localparam RECT_WIDTH  = 11'd150;
    localparam RECT_HEIGHT = 11'd300;

    (* rom_style = "block" *) logic [11:0] rom_player_g [0:44999]; // Gabrysia
    (* rom_style = "block" *) logic [11:0] rom_player_m [0:44999]; // Michał

    initial begin
        $readmemh("gabrysia.hex", rom_player_g);
        $readmemh("michal.hex", rom_player_m);
    end

    logic [11:0] x_offset;
    logic [11:0] y_offset;
    logic [11:0] mapped_x;
    logic [15:0] pixel_addr;
    assign x_offset = vga_in.hcount - xpos;
    assign y_offset = vga_in.vcount - ypos;
    assign mapped_x = player_color_bit ? x_offset : (RECT_WIDTH - 1'b1 - x_offset);

    // ETAP 1: Pipeline obliczeń (DSP) i opóźnienie sygnałów VGA
    logic [10:0] hcount_pipe, vcount_pipe;
    logic vsync_pipe, hsync_pipe, vblnk_pipe, hblnk_pipe;
    logic [11:0] rgb_pipe;
    logic enable_pipe;
    logic char_select_pipe;

    always_ff @(posedge clk) begin
        pixel_addr  <= y_offset * RECT_WIDTH + mapped_x;
        char_select_pipe  <= char_select;
        
        hcount_pipe <= vga_in.hcount;
        vcount_pipe <= vga_in.vcount;
        vsync_pipe  <= vga_in.vsync;
        hsync_pipe  <= vga_in.hsync;
        vblnk_pipe  <= vga_in.vblnk;
        hblnk_pipe  <= vga_in.hblnk;
        rgb_pipe    <= vga_in.rgb;
        
        enable_pipe <= enable && 
                       (vga_in.hcount >= xpos) && (vga_in.hcount < (xpos + RECT_WIDTH)) &&
                       (vga_in.vcount >= ypos) && (vga_in.vcount < (ypos + RECT_HEIGHT));
    end

    // ETAP 2: Odczyt z pamięci 
    logic [11:0] rgb_nxt;
    logic [11:0] sprite_pixel;

    always_comb begin
        rgb_nxt = rgb_pipe;
        sprite_pixel = char_select_pipe ? rom_player_m[pixel_addr] : rom_player_g[pixel_addr]; 
        
        if (enable_pipe) begin
            if (sprite_pixel != 12'h000) begin
                rgb_nxt = sprite_pixel;
            end 
        end
    end

    // ETAP 3: Rejestr wyjściowy sygnału VGA
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vga_out.hcount <= '0; vga_out.vcount <= '0;
            vga_out.vsync  <= '0; vga_out.hsync  <= '0;
            vga_out.vblnk  <= '0; vga_out.hblnk  <= '0;
            vga_out.rgb    <= '0; 
        end else begin
            vga_out.hcount <= hcount_pipe; vga_out.vcount <= vcount_pipe;
            vga_out.vsync  <= vsync_pipe;  vga_out.hsync  <= hsync_pipe;
            vga_out.vblnk  <= vblnk_pipe;  vga_out.hblnk  <= hblnk_pipe;
            vga_out.rgb    <= rgb_nxt; 
        end
    end
endmodule
