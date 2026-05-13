`timescale 1ns / 1ps

module draw_mouse (
    input  wire clk,
    input  wire rst_n,
    input  wire enable,
    input  wire [11:0] xpos,
    input  wire [11:0] ypos,
    vga_if.in  vga_in,
    vga_if.out vga_out
);

    wire [11:0] mouse_rgb_out;
    wire blank;

    assign blank = vga_in.hblnk || vga_in.vblnk;

    MouseDisplay u_mouse_display (
        .pixel_clk(clk),
        .xpos(xpos),
        .ypos(ypos),
        .hcount(vga_in.hcount[10:0]),
        .vcount(vga_in.vcount[10:0]),
        .blank(blank),
        .rgb_in(vga_in.rgb),
        .rgb_out(mouse_rgb_out),
        .enable_mouse_display_out() 
    );

    always_ff @(posedge clk or negedge rst_n) begin
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
            
            vga_out.rgb    <= mouse_rgb_out;

            if (enable)
                vga_out.rgb <= mouse_rgb_out;
            else
                vga_out.rgb <= vga_in.rgb;
        end
    end

endmodule