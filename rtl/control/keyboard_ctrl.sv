module keyboard_ctrl (
    input  logic clk, 
    input  logic rst_n,     
    input  logic ps2_clk, 
    input  logic ps2_data,   
    input  logic vsync, 
    output logic [11:0] xpos,
    output logic [11:0] ypos,
    output logic        space_pressed,
    output logic        player_color,
    output logic [1:0]  current_song_id
);

// 1. Synchronizacja sygnałów wejściowych (przeciwdziałanie metastabilności)
logic [1:0] clk_sync;
logic [2:0] ps2_data_sync;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        clk_sync      <= 2'b11;
        ps2_data_sync <= 3'b111;
    end else begin
        clk_sync      <= {clk_sync[0], ps2_clk};
        ps2_data_sync <= {ps2_data_sync[1:0], ps2_data};
    end
end

// 2. Filtr cyfrowy (Debouncer) oparty na timerze
logic [9:0] filter_cnt;
logic ps2_clk_clean;
logic ps2_clk_clean_prev;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        filter_cnt         <= '0;
        ps2_clk_clean      <= 1'b1;
        ps2_clk_clean_prev <= 1'b1;
    end else begin
        ps2_clk_clean_prev <= ps2_clk_clean;

        if (clk_sync[1] != ps2_clk_clean) begin
            filter_cnt <= filter_cnt + 1'b1;
            
            if (filter_cnt == 10'd500) begin
                ps2_clk_clean <= clk_sync[1];
                filter_cnt    <= '0;
            end
        end else begin
            filter_cnt <= '0;
        end
    end
end

logic ps2_clk_fall;
assign ps2_clk_fall = (ps2_clk_clean_prev == 1'b1) && (ps2_clk_clean == 1'b0);
    // 3. Timeout i odczyt
    logic [19:0] idle_cnt;

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
            idle_cnt <= '0;
        end else begin
            scan_code_ready <= 1'b0;
            
            if (ps2_clk_fall) begin
                idle_cnt <= '0;
                shift_reg <= {ps2_data_sync[2], shift_reg[10:1]};
                
                if (bit_cnt == 4'd10) begin
                    if (shift_reg[1] == 1'b0 && ps2_data_sync[2] == 1'b1) begin
                        scan_code <= shift_reg[9:2];
                        scan_code_ready <= 1'b1;
                    end
                    bit_cnt <= '0;
                end else begin
                    bit_cnt <= bit_cnt + 1'b1;
                end
            end else begin
                if (idle_cnt != 20'hFFFFF) begin
                    idle_cnt <= idle_cnt + 1'b1;
                end else begin
                    bit_cnt <= '0; 
                end
            end
        end
    end

// 4. Logika wciskania (Zmieniona na ruch ciągły)
logic is_break;
logic is_extended;
logic a_pressed;
logic d_pressed;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        is_break        <= 1'b0;
        is_extended     <= 1'b0;
        a_pressed       <= 1'b0;
        d_pressed       <= 1'b0;
        space_pressed   <= 1'b0;
        current_song_id <= 2'b00;
    end else begin
        space_pressed <= 1'b0; 

        if (scan_code_ready) begin
            if (scan_code == 8'hE0) begin
                is_extended <= 1'b1;
            end else if (scan_code == 8'hF0) begin
                is_break <= 1'b1;
            end else begin
                if (scan_code == 8'h1C || (scan_code == 8'h6B && is_extended)) begin
                    if (!is_break) begin
                        a_pressed <= 1'b1; 
                        d_pressed <= 1'b0; 
                    end
                end else if (scan_code == 8'h23 || (scan_code == 8'h74 && is_extended)) begin
                    if (!is_break) begin
                        d_pressed <= 1'b1;
                        a_pressed <= 1'b0; 
                    end
                end else if (scan_code == 8'h29) begin 
                    if (!is_break) space_pressed <= 1'b1; 
                end else if (scan_code == 8'h16) begin 
                    if (!is_break) current_song_id <= 2'b00;
                end else if (scan_code == 8'h1E) begin 
                    if (!is_break) current_song_id <= 2'b01;
                end else if (scan_code == 8'h26) begin 
                    if (!is_break) current_song_id <= 2'b10;
                end
                is_break    <= 1'b0;
                is_extended <= 1'b0;
            end
        end
    end
end
    // 5. Poruszanie kwadratem
    logic vsync_prev;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vsync_prev <= 1'b0;
            xpos <= 12'd350; 
            ypos <= 12'd468;
        end else begin
            vsync_prev <= vsync;
            
            if (vsync && !vsync_prev) begin
                if (a_pressed && (xpos >= 12'd12)) begin
                    xpos <= xpos - 12'd12;
                end else if (d_pressed && (xpos <= 12'd912)) begin
                    xpos <= xpos + 12'd12;
                end
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            player_color <= 1'b0;
        end else begin
            if (a_pressed)      player_color <= 1'b0; 
            else if (d_pressed) player_color <= 1'b1; 
        end
    end
endmodule