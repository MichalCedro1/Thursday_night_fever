module draw_rect (
    input  logic        clk,
    input  logic        rst_n,
    
    vga_if.in  vga_in,
    vga_if.out vga_out
);

    localparam RECT_X      = 11'd200;
    localparam RECT_Y      = 11'd150;
    localparam RECT_WIDTH  = 11'd100;
    localparam RECT_HEIGHT = 11'd100;
    localparam RECT_COLOR  = 12'hf00;


    always_ff @(posedge clk) begin
        if (!rst_n) begin
            vga_out.hcount <= 11'b0;
            vga_out.hsync  <= 1'b0;
            vga_out.hblnk <= 1'b0;
            vga_out.vcount <= 11'b0;
            vga_out.vsync  <= 1'b0;
            vga_out.vblnk  <= 1'b0;
            vga_out.rgb   <= 12'b0;
        end else begin
            vga_out.hcount <= vga_in.hcount;
            vga_out.hsync  <= vga_in.hsync;
            vga_out.hblnk  <= vga_in.hblnk;
            vga_out.vcount <= vga_in.vcount;
            vga_out.vsync  <= vga_in.vsync;
            vga_out.vblnk  <= vga_in.vblnk;

            if ((vga_in.hcount >= RECT_X) && (vga_in.hcount < RECT_X + RECT_WIDTH) &&
                (vga_in.vcount >= RECT_Y) && (vga_in.vcount < RECT_Y + RECT_HEIGHT)) begin
                
                vga_out.rgb <= RECT_COLOR;
            end else begin
                vga_out.rgb <= vga_in.rgb;
            end
        end
    end

endmodule