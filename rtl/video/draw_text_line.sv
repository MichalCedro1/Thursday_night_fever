module draw_text_line #(
    parameter X_POS = 100,
    parameter Y_POS = 100,
    parameter TEXT_LEN = 10,
    parameter [8*TEXT_LEN-1:0] TEXT_CONTENT = "          ",
    parameter SCALE = 1
)(
    input  logic clk,
    input  logic rst_n,
    input  logic enable,
    input  logic [11:0] color,
    vga_if.in  vga_in,
    vga_if.out vga_out
);

    logic [10:0] font_addr;
    logic [7:0]  font_pixels;
    logic [7:0]  char_code;
    logic [11:0] rgb_nxt;
    logic pixel_bit;

    logic [11:0] x_offset_in, y_offset_in;
    logic [11:0] x_offset_del, y_offset_del;
    logic [7:0]  char_idx;
    logic [11:0] scaled_x_in, scaled_y_in;
    logic [11:0] scaled_x_del;

    assign x_offset_in = vga_in.hcount - X_POS;
    assign y_offset_in = vga_in.vcount - Y_POS;

    always_comb begin
        if (SCALE == 4) begin
            scaled_x_in = {2'b00, x_offset_in[11:2]};
            scaled_y_in = {2'b00, y_offset_in[11:2]};
        end else if (SCALE == 2) begin
            scaled_x_in = {1'b0, x_offset_in[11:1]};
            scaled_y_in = {1'b0, y_offset_in[11:1]};
        end else begin
            scaled_x_in = x_offset_in;
            scaled_y_in = y_offset_in;
        end
    end

    assign char_idx = scaled_x_in[11:3];

    always_comb begin
        if (char_idx < TEXT_LEN) begin
            char_code = TEXT_CONTENT >> (8 * (TEXT_LEN - 1 - char_idx));
        end else begin
            char_code = 8'h20;
        end
    end

    font_rom u_font (
        .clk (clk),
        .addr (font_addr),
        .char_line_pixels (font_pixels)
    );

    assign font_addr = {char_code[6:0], scaled_y_in[3:0]};

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

    assign x_offset_del = vga_delayed.hcount - X_POS;
    assign y_offset_del = vga_delayed.vcount - Y_POS;

    always_comb begin
        if (SCALE == 4)      
        scaled_x_del = {2'b00, x_offset_del[11:2]};
        else if (SCALE == 2) 
        scaled_x_del = {1'b0, x_offset_del[11:1]};
        else                 
        scaled_x_del = x_offset_del;
    end

    assign pixel_bit = font_pixels[3'd7 - scaled_x_del[2:0]];

    logic is_text_area;
    assign is_text_area = (vga_delayed.hcount >= X_POS && vga_delayed.hcount < X_POS + (TEXT_LEN * 8*SCALE)) &&
                          (vga_delayed.vcount >= Y_POS && vga_delayed.vcount < Y_POS + (16*SCALE));

    always_comb begin
        rgb_nxt = vga_delayed.rgb;
        if (enable && is_text_area && pixel_bit) begin
            rgb_nxt = color;
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