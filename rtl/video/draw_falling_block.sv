module draw_falling_block (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [11:0] xpos,
    input  logic [11:0] ypos,
    input  logic        active,
    input  logic        block_color, // 0 = Czerwony, 1 = Niebieski
    
    vga_if.in  vga_in,
    vga_if.out vga_out
);

    localparam BLOCK_SIZE = 11'd60;

    logic [11:0] rgb_nxt;

    always_comb begin
        rgb_nxt = vga_in.rgb;
        
        if (active) begin
            if ((vga_in.hcount >= xpos) && (vga_in.hcount < (xpos + BLOCK_SIZE)) &&
                (vga_in.vcount >= ypos) && (vga_in.vcount < (ypos + BLOCK_SIZE))) begin
                
                // MUX koloru w locie: jeśli 1 to niebieski, jeśli 0 to czerwony
                rgb_nxt = block_color ? 12'h00f : 12'hf00; 
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vga_out.hcount <= 11'b0;
            vga_out.hsync  <= 1'b0;
            vga_out.hblnk  <= 1'b0;
            vga_out.vcount <= 11'b0;
            vga_out.vsync  <= 1'b0;
            vga_out.vblnk  <= 1'b0;
            vga_out.rgb    <= 12'b0; 
        end else begin
            vga_out.hcount <= vga_in.hcount;
            vga_out.hsync  <= vga_in.hsync;
            vga_out.hblnk  <= vga_in.hblnk;
            vga_out.vcount <= vga_in.vcount;
            vga_out.vsync  <= vga_in.vsync;
            vga_out.vblnk  <= vga_in.vblnk;
            
            vga_out.rgb    <= rgb_nxt; 
        end
    end

endmodule