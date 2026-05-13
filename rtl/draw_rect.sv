module draw_rect (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        enable,  
    input  logic [11:0] xpos,
    input  logic [11:0] ypos,
    
    vga_if.in  vga_in,
    vga_if.out vga_out
);

    localparam RECT_WIDTH  = 11'd100;
    localparam RECT_HEIGHT = 11'd100;

    logic [11:0] xpos_prev;   
    logic [11:0] current_color; 
    logic vsync_prev;        

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            xpos_prev     <= 12'd350; 
            current_color <= 12'hf00; 
            vsync_prev    <= 1'b0;
        end else begin
            vsync_prev <= vga_in.vsync;
            

            if (vga_in.vsync && !vsync_prev) begin
                
                if (xpos > xpos_prev) begin
                    current_color <= 12'h00f; 
                end else if (xpos < xpos_prev) begin
                    current_color <= 12'hf00; 
                end
                
                xpos_prev <= xpos;
            end
        end
    end

    logic [11:0] rgb_nxt;

    always_comb begin
        rgb_nxt = vga_in.rgb;
        
        if (enable) begin
            if ((vga_in.hcount >= xpos) && (vga_in.hcount < (xpos + RECT_WIDTH)) &&
                (vga_in.vcount >= ypos) && (vga_in.vcount < (ypos + RECT_HEIGHT))) begin
                
                rgb_nxt = current_color; 
                
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