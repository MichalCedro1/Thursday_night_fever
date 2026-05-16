module falling_block_ctrl (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        vsync,
    input  logic        enable,
    
    input  logic [11:0] player_x,
    input  logic [11:0] player_y,
    input  logic        player_color,
    input  logic        space_pressed,
    
    output logic [11:0] block_x,
    output logic [11:0] block_y,
    output logic        block_active,
    output logic        block_color,
    
    output logic [3:0]  score_ones,
    output logic [3:0]  score_tens,
    output logic [3:0]  score_hunds,
    output logic        game_over // NOWY SYGNAŁ: Koniec gry
);

    localparam PLAYER_SIZE = 12'd100; 
    localparam ENEMY_SIZE  = 12'd60;
    localparam TOTAL_BLOCKS = 4'd10; // Mamy 10 bloków na całą grę

    logic vsync_prev;
    logic [9:0] wait_counter;
    logic [3:0] block_index;
    logic [3:0] current_speed;

    // --- BEATMAPA (Playlista) ---
    // Format: { Oczekiwanie (10 bit), X_pos (11 bit), Prędkość (4 bit), Kolor (1 bit) }
    // Razem 26 bitów. Prędkość rośnie, a czas oczekiwania maleje!
    logic [25:0] beatmap [0:9];
    
    always_comb begin
        // Początek: Wolno, dużo czasu na przygotowanie (60 ramek = 1 sekunda)
        beatmap[0] = {10'd60, 11'd200, 4'd4, 1'b0}; // Czerwony
        beatmap[1] = {10'd50, 11'd400, 4'd4, 1'b1}; // Niebieski
        // Środek: Szybciej
        beatmap[2] = {10'd40, 11'd600, 4'd6, 1'b0}; 
        beatmap[3] = {10'd35, 11'd800, 4'd6, 1'b1};
        beatmap[4] = {10'd30, 11'd300, 4'd7, 1'b0};
        beatmap[5] = {10'd25, 11'd500, 4'd7, 1'b1};
        // Koniec: Szybkie tempo, klocki lecą zaraz po sobie
        beatmap[6] = {10'd20, 11'd700, 4'd9, 1'b0};
        beatmap[7] = {10'd15, 11'd200, 4'd9, 1'b1};
        beatmap[8] = {10'd10, 11'd400, 4'd12, 1'b0};
        beatmap[9] = {10'd10, 11'd600, 4'd15, 1'b1}; // Finałowy boss
    end

    // Kolizja
    logic collision_physical;
    assign collision_physical = (player_x < (block_x + ENEMY_SIZE))  &&
                                ((player_x + PLAYER_SIZE) > block_x) &&
                                (player_y < (block_y + ENEMY_SIZE))  &&
                                ((player_y + PLAYER_SIZE) > block_y);

    logic collision_matched;
    assign collision_matched = collision_physical && (player_color == block_color) && space_pressed;

    always_ff @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin
            vsync_prev    <= 1'b0;
            wait_counter  <= '0;
            block_index   <= '0;
            current_speed <= '0;
            block_active  <= 1'b0;
            block_x       <= '0;
            block_y       <= '0;
            block_color   <= 1'b0;
            score_ones    <= '0;
            score_tens    <= '0;
            score_hunds   <= '0;
            game_over     <= 1'b0;
        end else begin
            vsync_prev <= vsync;
            
            if (enable && !game_over) begin
                // Zniszczenie bloku
                if (block_active && collision_matched) begin
                    block_active <= 1'b0;
                    wait_counter <= '0; 
                    
                    // Zliczanie punktów BCD (zostaje bez zmian)
                    if (score_ones == 4'd9) begin
                        score_ones <= 4'd0;
                        if (score_tens == 4'd9) begin
                            score_tens <= 4'd0;
                            if (score_hunds != 4'd9) score_hunds <= score_hunds + 1'b1;
                        end else begin
                            score_tens <= score_tens + 1'b1;
                        end
                    end else begin
                        score_ones <= score_ones + 1'b1;
                    end
                end

                if (vsync && !vsync_prev) begin
                    if (!block_active) begin
                        // Jeśli zrzuciliśmy już 10 bloków -> KONIEC GRY
                        if (block_index == TOTAL_BLOCKS) begin
                            game_over <= 1'b1;
                        end else begin
                            // Czekamy określoną z bitmapy liczbę ramek przed zrzuceniem kolejnego
                            if (wait_counter == beatmap[block_index][25:16]) begin
                                block_active  <= 1'b1;
                                block_y       <= 12'd0; 
                                block_x       <= beatmap[block_index][15:5]; // X pos
                                current_speed <= beatmap[block_index][4:1];  // Prędkość
                                block_color   <= beatmap[block_index][0];    // Kolor
                                
                                block_index   <= block_index + 1'b1; // Przechodzimy do następnego
                            end else begin
                                wait_counter <= wait_counter + 1'b1;
                            end
                        end
                    end else begin
                        // Klocek spada ze swoją zdefiniowaną prędkością
                        block_y <= block_y + current_speed;
                        
                        // Uciekł poza ekran (przyjęto 768 z nowej rozdzielczości)
                        if (block_y > 12'd768) begin
                            block_active  <= 1'b0;
                            wait_counter  <= '0;
                        end
                    end
                end
            end else if (!enable) begin
                // Reset stanu podczas przebywania w menu
                block_active  <= 1'b0;
                wait_counter  <= '0;
                block_index   <= '0;
                game_over     <= 1'b0;
            end
        end
    end
endmodule