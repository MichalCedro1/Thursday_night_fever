module keyboard_ctrl (
    input  logic clk, 
    input  logic rst_n,     
    input  logic ps2_clk, 
    input  logic ps2_data,   
    input  logic vsync, 
    output logic [11:0] xpos,
    output logic [11:0] ypos,
    output logic        space_pressed,
    output logic        player_color
);

    // 1. Filtr cyfrowy (Debouncer) dla linii zegara PS/2
    logic [7:0] clk_filter;
    logic ps2_clk_clean;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_filter <= 8'hFF;
            ps2_clk_clean <= 1'b1;
        end else begin
            clk_filter <= {clk_filter[6:0], ps2_clk};
            if (clk_filter == 8'hFF)
                ps2_clk_clean <= 1'b1;
            else if (clk_filter == 8'h00)
                ps2_clk_clean <= 1'b0;
        end
    end

    // 2. Synchronizacja i detekcja zbocza na OCZYSZCZONYM zegarze
    logic [2:0] ps2_clk_sync;
    logic [2:0] ps2_data_sync;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ps2_clk_sync  <= 3'b111;
            ps2_data_sync <= 3'b111;
        end else begin
            ps2_clk_sync  <= {ps2_clk_sync[1:0], ps2_clk_clean}; 
            ps2_data_sync <= {ps2_data_sync[1:0], ps2_data};
        end
    end

    logic ps2_clk_fall;
    assign ps2_clk_fall = (ps2_clk_sync[2:1] == 2'b10);

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

    // 4. Logika wciskania
    logic is_break;
    logic a_pressed;
    logic d_pressed;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            is_break      <= 1'b0;
            a_pressed     <= 1'b0;
            d_pressed     <= 1'b0;
            space_pressed <= 1'b0;
        end else begin
            // KASUJEMY impuls spacji co takt zegara!
            space_pressed <= 1'b0; 

            if (scan_code_ready) begin
                if (scan_code == 8'hF0) begin
                    is_break <= 1'b1;
                end else if (scan_code == 8'h1C) begin // Klawisz A
                    if (is_break) begin
                        a_pressed <= 1'b0;
                    end else begin
                        a_pressed <= 1'b1;
                        d_pressed <= 1'b0;
                    end
                    is_break <= 1'b0;
                end else if (scan_code == 8'h23) begin // Klawisz D
                    if (is_break) begin
                        d_pressed <= 1'b0;
                    end else begin
                        d_pressed <= 1'b1;
                        a_pressed <= 1'b0;
                    end
                    is_break <= 1'b0;
                end else if (scan_code == 8'h29) begin // KLAWISZ SPACJA
                    // JEŚLI JEST TO WCISNIĘCIE (MAKE), WYZWÓL 1-TAKTOWY IMPULS
                    if (!is_break) space_pressed <= 1'b1; 
                    is_break <= 1'b0;
                end else begin
                    is_break <= 1'b0;
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
            ypos <= 12'd500;
        end else begin
            vsync_prev <= vsync;
            
            if (vsync && !vsync_prev) begin
                if (a_pressed && (xpos > 12'd0)) begin
                    xpos <= xpos - 12'd5;
                end else if (d_pressed && (xpos < 12'd920)) begin
                    xpos <= xpos + 12'd5;
                end
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            player_color <= 1'b0; // Domyślnie czerwony
        end else begin
            if (a_pressed)      player_color <= 1'b0; // 'A' Czerwony
            else if (d_pressed) player_color <= 1'b1; // 'D' Niebieski
        end
    end
endmodule