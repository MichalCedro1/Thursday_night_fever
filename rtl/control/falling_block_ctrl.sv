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
    output logic        game_over
);

    localparam PLAYER_SIZE = 12'd100; 
    localparam ENEMY_SIZE  = 12'd70;
    localparam TOTAL_BLOCKS = 4'd10;

    logic vsync_prev;
    logic [9:0] wait_counter;
    logic [3:0] block_index;
    logic [3:0] current_speed;

    logic enable_prev;
    logic start_new_game;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            enable_prev <= 1'b0;
        end else begin
            enable_prev <= enable;
        end
    end

    assign start_new_game = enable && !enable_prev;

    logic [25:0] beatmap [0:9];
    
    always_comb begin
        beatmap[0] = {10'd60, 11'd200, 4'd4, 1'b0};
        beatmap[1] = {10'd50, 11'd400, 4'd4, 1'b1};
        beatmap[2] = {10'd40, 11'd600, 4'd6, 1'b0}; 
        beatmap[3] = {10'd35, 11'd800, 4'd6, 1'b1};
        beatmap[4] = {10'd30, 11'd300, 4'd7, 1'b0};
        beatmap[5] = {10'd25, 11'd500, 4'd7, 1'b1};
        beatmap[6] = {10'd20, 11'd700, 4'd9, 1'b0};
        beatmap[7] = {10'd15, 11'd200, 4'd9, 1'b1};
        beatmap[8] = {10'd10, 11'd400, 4'd10, 1'b0};
        beatmap[9] = {10'd10, 11'd600, 4'd10, 1'b1};
    end

    logic collision_physical;
    assign collision_physical = (player_x < (block_x + ENEMY_SIZE))  &&
                                ((player_x + PLAYER_SIZE) > block_x) &&
                                (player_y < (block_y + ENEMY_SIZE))  &&
                                ((player_y + PLAYER_SIZE) > block_y);

    logic action_triggered;
    assign action_triggered = (player_color == block_color) && space_pressed;

    logic [11:0] player_center_x, block_center_x;
    assign player_center_x = player_x + (PLAYER_SIZE >> 1); 
    assign block_center_x  = block_x + (ENEMY_SIZE >> 1);   

    logic [11:0] dist_x;
    assign dist_x = (player_center_x > block_center_x) ? (player_center_x - block_center_x) : (block_center_x - player_center_x);
    
    logic [11:0] block_bottom;
    assign block_bottom = block_y + ENEMY_SIZE;

    logic [11:0] edge_dist_y; 
    assign edge_dist_y = (player_y > block_bottom) ? (player_y - block_bottom) : (block_bottom - player_y);

    logic perfect_zone, good_zone;
    
    assign perfect_zone = collision_physical && (edge_dist_y <= 12'd12); 
    
    assign good_zone    = collision_physical && !perfect_zone;

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

            if (start_new_game) begin
                wait_counter  <= '0;
                block_index   <= '0;
                current_speed <= '0;
                block_active  <= 1'b0;
                block_x       <= '0;
                block_y       <= '0;
                game_over     <= 1'b0;
                score_ones    <= '0;
                score_tens    <= '0;
                score_hunds   <= '0;
            end
            
            if (enable && !game_over) begin
                if (block_active && space_pressed) begin                 
                    if (player_color == block_color) begin
                        if (perfect_zone) begin
                            block_active <= 1'b0;
                            wait_counter <= '0; 
                            
                            if (score_ones >= 4'd8) begin
                                score_ones <= score_ones + 4'd2 - 4'd10;
                                if (score_tens == 4'd9) begin
                                    score_tens <= 4'd0;
                                    if (score_hunds != 4'd9) score_hunds <= score_hunds + 1'b1;
                                end else begin
                                    score_tens <= score_tens + 1'b1;
                                end
                            end else begin
                                score_ones <= score_ones + 4'd2;
                            end

                        end else if (good_zone) begin
                            block_active <= 1'b0;
                            wait_counter <= '0; 
                            
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

                        end else begin
                            // --- MISS: Zły timing (Pudło w powietrze) ---
                            // Gracz miał dobry kolor, ale wcisnął spację gdy klocek był za daleko.
                            // [MIEJSCE NA DODANIE KARY - np. odjęcie punktu / życia]
                        end

                    end else if (good_zone || perfect_zone) begin
                        // --- MISS: Zły kolor! ---
                        // Gracz wcisnął spację idealnie w tempo, ale miał ustawiony zły kolor.
                        // [MIEJSCE NA DODANIE KARY - np. odjęcie punktu / utrata życia]
                    end
                end

                if (vsync && !vsync_prev) begin
                    if (!block_active) begin
                        if (block_index == TOTAL_BLOCKS) begin
                            game_over <= 1'b1;
                        end else begin
                            if (wait_counter == beatmap[block_index][25:16]) begin
                                block_active  <= 1'b1;
                                block_y       <= 12'd0; 
                                block_x       <= beatmap[block_index][15:5]; 
                                current_speed <= beatmap[block_index][4:1];  
                                block_color   <= beatmap[block_index][0];    
                                
                                block_index   <= block_index + 1'b1; 
                            end else begin
                                wait_counter <= wait_counter + 1'b1;
                            end
                        end
                    end else begin
                        block_y <= block_y + current_speed;
                        
                        if (block_y > 12'd768) begin
                            block_active  <= 1'b0;
                            wait_counter  <= '0;
                        end
                    end
                end

            end else if (!enable) begin
                block_active  <= 1'b0;
                if (game_over) begin
                    if (space_pressed) game_over <= 1'b0;
                end else begin
                    wait_counter  <= '0;
                    block_index   <= '0;
                    current_speed <= '0;
                    block_x       <= '0;
                    block_y       <= '0;
                    score_ones    <= '0;
                    score_tens    <= '0;
                    score_hunds   <= '0;
                end
            end
        end
    end
    
endmodule