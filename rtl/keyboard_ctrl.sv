module keyboard_ctrl (
    input  logic clk,        // Zegar systemowy (ten sam co dla VGA, np. 40 MHz)
    input  logic rst_n,      // Reset
    input  logic ps2_clk,    // Zegar z klawiatury
    input  logic ps2_data,   // Dane z klawiatury
    input  logic vsync,      // Sygnał VSYNC do synchronizacji płynnego ruchu
    output logic [11:0] xpos,
    output logic [11:0] ypos
);

    // --------------------------------------------------------
    // 1. Synchronizacja sygnałów PS/2 (ochrona przed metastabilnością)
    // --------------------------------------------------------
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

    // Wykrycie zbocza opadającego zegara PS/2
    logic ps2_clk_fall;
    assign ps2_clk_fall = (ps2_clk_sync[2:1] == 2'b10);

    // --------------------------------------------------------
    // 2. Odbiornik PS/2 (Rejestr przesuwny)
    // --------------------------------------------------------
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
            scan_code_ready <= 1'b0; // Domyślnie impuls trwa 1 takt
            
            if (ps2_clk_fall) begin
                shift_reg <= {ps2_data_sync[1], shift_reg[10:1]};
                
                if (bit_cnt == 4'd10) begin
                    scan_code <= shift_reg[9:2]; // Wyciągnięcie 8 bitów danych
                    scan_code_ready <= 1'b1;
                    bit_cnt <= '0;
                end else begin
                    bit_cnt <= bit_cnt + 1'b1;
                end
            end
        end
    end

    // --------------------------------------------------------
    // 3. Logika wciśniętych klawiszy (A = 1C, D = 23, Break = F0)
    // --------------------------------------------------------
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
                is_break <= 1'b1; // Otrzymano kod puszczenia klawisza
            end else begin
                // Aktualizacja stanu klawiszy
                if (scan_code == 8'h1C) begin
                    a_pressed <= !is_break; 
                end else if (scan_code == 8'h23) begin
                    d_pressed <= !is_break;
                end
                is_break <= 1'b0; // Reset flagi "break" po przetworzeniu klawisza
            end
        end
    end

    // --------------------------------------------------------
    // 4. Logika ruchu kwadratu (Aktualizacja raz na klatkę obrazu)
    // --------------------------------------------------------
    logic vsync_prev;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vsync_prev <= 1'b0;
            // Start na środku ekranu (wymiary ekranu 800x600, kwadratu 100x100)
            xpos <= 12'd350; 
            ypos <= 12'd250; 
        end else begin
            vsync_prev <= vsync;
            
            // Reagujemy tylko na zbocze narastające VSYNC (początek nowej klatki)
            if (vsync && !vsync_prev) begin
                
                // Jeśli wciśnięto 'A' i kwadrat nie dotyka lewej krawędzi
                if (a_pressed && (xpos > 12'd0)) begin
                    xpos <= xpos - 12'd5; // Prędkość: 5 pikseli na klatkę
                end
                
                // Jeśli wciśnięto 'D' i kwadrat nie dotyka prawej krawędzi (800 - 100 = 700)
                if (d_pressed && (xpos < 12'd700)) begin
                    xpos <= xpos + 12'd5;
                end
                
            end
        end
    end

endmodule