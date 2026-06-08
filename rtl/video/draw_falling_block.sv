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

    // ETAP 1: Pipeline obliczania adresu (sprzętowe mnożenie w DSP)
    logic [13:0] pixel_addr_pipe1;
    logic        in_bb_pipe1;
    logic        color_pipe1;
    
    logic [10:0] hcount_pipe1, vcount_pipe1;
    logic        hsync_pipe1, vsync_pipe1, hblnk_pipe1, vblnk_pipe1;
    logic [11:0] rgb_pipe1;

    always_ff @(posedge clk) begin
        pixel_addr_pipe1 <= ((vga_in.vcount - ypos) * BLOCK_SIZE) + (vga_in.hcount - xpos);
        
        in_bb_pipe1 <= active && 
                       (vga_in.hcount >= xpos) && (vga_in.hcount < (xpos + BLOCK_SIZE)) &&
                       (vga_in.vcount >= ypos) && (vga_in.vcount < (ypos + BLOCK_SIZE));
                       
        color_pipe1 <= block_color;

        hcount_pipe1 <= vga_in.hcount; vcount_pipe1 <= vga_in.vcount;
        hsync_pipe1  <= vga_in.hsync;  vsync_pipe1  <= vga_in.vsync;
        hblnk_pipe1  <= vga_in.hblnk;  vblnk_pipe1  <= vga_in.vblnk;
        rgb_pipe1    <= vga_in.rgb;
    end

    logic [11:0] rom_left_data, rom_right_data;
    logic        in_bb_pipe2;
    logic        color_pipe2;
    
    logic [10:0] hcount_pipe2, vcount_pipe2;
    logic        hsync_pipe2, vsync_pipe2, hblnk_pipe2, vblnk_pipe2;
    logic [11:0] rgb_pipe2;

    always_ff @(posedge clk) begin
        rom_left_data  <= rom_left[pixel_addr_pipe1];
        rom_right_data <= rom_right[pixel_addr_pipe1];
        
        in_bb_pipe2 <= in_bb_pipe1;
        color_pipe2 <= color_pipe1;
        
        hcount_pipe2 <= hcount_pipe1; vcount_pipe2 <= vcount_pipe1;
        hsync_pipe2  <= hsync_pipe1;  vsync_pipe2  <= vsync_pipe1;
        hblnk_pipe2  <= hblnk_pipe1;  vblnk_pipe2  <= vblnk_pipe1;
        rgb_pipe2    <= rgb_pipe1;
    end

    // ETAP 3: Złożenie pikseli z tłem
    logic [11:0] rgb_nxt;

    always_comb begin
        rgb_nxt = rgb_pipe2; 

        if (in_bb_pipe2) begin
            if (color_pipe2 == 1'b0) begin
                if (rom_left_data != 12'h000) rgb_nxt = rom_left_data;
            end else begin
                if (rom_right_data != 12'h000) rgb_nxt = rom_right_data;
            end
        end
    end

    // ETAP 4: Rejestr wyjściowy modułu
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vga_out.hcount <= '0; vga_out.hsync  <= '0; vga_out.hblnk  <= '0;
            vga_out.vcount <= '0; vga_out.vsync  <= '0; vga_out.vblnk  <= '0;
            vga_out.rgb    <= '0; 
        end else begin
            vga_out.hcount <= hcount_pipe2; vga_out.hsync  <= hsync_pipe2; vga_out.hblnk  <= hblnk_pipe2;
            vga_out.vcount <= vcount_pipe2; vga_out.vsync  <= vsync_pipe2; vga_out.vblnk  <= vblnk_pipe2;
            vga_out.rgb    <= rgb_nxt; 
        end
    end

endmodule