module draw_falling_block (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [11:0] xpos,
    input  logic [11:0] ypos,
    input  logic        active,
    input  logic        block_color,
    
    vga_if.in  vga_in,
    vga_if.out vga_out
);

    localparam BLOCK_SIZE = 12'd70;

    (* rom_style = "block" *) logic [11:0] rom_left [0:4899]; 
    (* rom_style = "block" *) logic [11:0] rom_right [0:4899];

    initial begin
        $readmemh("strzalka-lewo.hex", rom_left);
        $readmemh("strzalka-prawo.hex", rom_right);
    end

    logic [13:0] pixel_addr;
    logic        in_bounding_box;
    
    always_comb begin
        in_bounding_box = active && 
                          (vga_in.hcount >= xpos) && (vga_in.hcount < (xpos + BLOCK_SIZE)) &&
                          (vga_in.vcount >= ypos) && (vga_in.vcount < (ypos + BLOCK_SIZE));
                          
        if (in_bounding_box) begin
            pixel_addr = ((vga_in.vcount - ypos) * BLOCK_SIZE) + (vga_in.hcount - xpos);
        end else begin
            pixel_addr = '0; 
        end
    end

    logic [11:0] rom_left_data, rom_right_data;
    
    logic [10:0] hcount_d, vcount_d;
    logic        hsync_d, vsync_d, hblnk_d, vblnk_d;
    logic [11:0] rgb_d;
    
    logic        in_bounding_box_d;
    logic        block_color_d;

    always_ff @(posedge clk) begin
        rom_left_data  <= rom_left[pixel_addr];
        rom_right_data <= rom_right[pixel_addr];
    end
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hcount_d <= '0; vcount_d <= '0;
            hsync_d  <= '0; vsync_d  <= '0;
            hblnk_d  <= '0; vblnk_d  <= '0;
            rgb_d    <= '0;
            in_bounding_box_d <= '0;
            block_color_d     <= '0;
        end else begin
            hcount_d <= vga_in.hcount;
            vcount_d <= vga_in.vcount;
            hsync_d  <= vga_in.hsync;
            vsync_d  <= vga_in.vsync;
            hblnk_d  <= vga_in.hblnk;
            vblnk_d  <= vga_in.vblnk;
            rgb_d    <= vga_in.rgb;
            
            in_bounding_box_d <= in_bounding_box;
            block_color_d     <= block_color;
        end
    end

    logic [11:0] rgb_nxt;

    always_comb begin
        rgb_nxt = rgb_d; 

        if (in_bounding_box_d) begin
            if (block_color_d == 1'b0) begin
                if (rom_left_data != 12'h000) rgb_nxt = rom_left_data;
            end else begin
                if (rom_right_data != 12'h000) rgb_nxt = rom_right_data;
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vga_out.hcount <= '0;
            vga_out.hsync  <= '0;
            vga_out.hblnk  <= '0;
            vga_out.vcount <= '0;
            vga_out.vsync  <= '0;
            vga_out.vblnk  <= '0;
            vga_out.rgb    <= '0; 
        end else begin
            vga_out.hcount <= hcount_d;
            vga_out.hsync  <= hsync_d;
            vga_out.hblnk  <= hblnk_d;
            vga_out.vcount <= vcount_d;
            vga_out.vsync  <= vsync_d;
            vga_out.vblnk  <= vblnk_d;
            vga_out.rgb    <= rgb_nxt; 
        end
    end

endmodule