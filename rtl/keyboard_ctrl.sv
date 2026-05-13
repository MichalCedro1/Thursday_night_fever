module keyboard_ctrl (
    input  logic clk, 
    input  logic rst_n,     
    input  logic ps2_clk, 
    input  logic ps2_data,   
    input  logic vsync, 
    output logic [11:0] xpos,
    output logic [11:0] ypos
);

    logic [2:0] ps2_clk_sync;
    logic [1:0] ps2_data_sync;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ps2_clk_sync  <= 3'b111;
            ps2_data_sync <= 2'b11;
        end else begin
            ps2_clk_sync  <= {ps2_clk_sync[1:0], ps2_clk};
            ps2_data_sync <= {ps2_data_sync[0], ps2_data};
        end
    end

    logic ps2_clk_fall;
    assign ps2_clk_fall = (ps2_clk_sync[2:1] == 2'b10);

    logic [3:0] bit_cnt;
    logic [10:0] shift_reg;
    logic [7:0] scan_code;
    logic scan_code_ready;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_cnt <= '0;
            shift_reg <= '0;
            scan_code_ready <= 1'b0;
            scan_code <= '0;
        end else begin
            scan_code_ready <= 1'b0;
            
            if (ps2_clk_fall) begin
                shift_reg <= {ps2_data_sync[1], shift_reg[10:1]};
                
                if (bit_cnt == 4'd10) begin
                    scan_code <= shift_reg[9:2];
                    scan_code_ready <= 1'b1;
                    bit_cnt <= '0;
                end else begin
                    bit_cnt <= bit_cnt + 1'b1;
                end
            end
        end
    end

    logic is_break;
    logic a_pressed;
    logic d_pressed;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            is_break  <= 1'b0;
            a_pressed <= 1'b0;
            d_pressed <= 1'b0;
        end else if (scan_code_ready) begin
            if (scan_code == 8'hF0) begin
                is_break <= 1'b1;
            end else begin
                if (scan_code == 8'h1C) begin
                    a_pressed <= !is_break; 
                end else if (scan_code == 8'h23) begin
                    d_pressed <= !is_break;
                end
                is_break <= 1'b0; 
            end
        end
    end

    logic vsync_prev;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vsync_prev <= 1'b0;
            xpos <= 12'd350; 
            ypos <= 12'd250; 
        end else begin
            vsync_prev <= vsync;
            
            if (vsync && !vsync_prev) begin
                
                if (a_pressed && (xpos > 12'd0)) begin
                    xpos <= xpos - 12'd5;
                end
                
                if (d_pressed && (xpos < 12'd700)) begin
                    xpos <= xpos + 12'd5;
                end
                
            end
        end
    end

endmodule