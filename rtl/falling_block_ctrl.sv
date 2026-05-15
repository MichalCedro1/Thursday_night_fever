module falling_block_ctrl (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        vsync,
    input  logic        enable,
    
    input  logic [11:0] player_x,
    input  logic [11:0] player_y,
    input  logic        player_color,
    input  logic        space_pressed, // To jest teraz czysty impuls "strzału"
    
    output logic [11:0] block_x,
    output logic [11:0] block_y,
    output logic        block_active,
    output logic        block_color,
    
    output logic [3:0]  score_ones,
    output logic [3:0]  score_tens,
    output logic [3:0]  score_hunds
);

    localparam PLAYER_SIZE = 12'd100; 
    localparam ENEMY_SIZE  = 12'd60;

    logic vsync_prev;
    logic [5:0] frame_counter;
    
    // Sprawdzanie fizycznego nakładania się
    logic collision_physical;
    assign collision_physical = (player_x < (block_x + ENEMY_SIZE))  &&
                                ((player_x + PLAYER_SIZE) > block_x) &&
                                (player_y < (block_y + ENEMY_SIZE))  &&
                                ((player_y + PLAYER_SIZE) > block_y);

    // KRYTYCZNE: Zniknęła detekcja zbocza, bierzemy space_pressed bezpośrednio!
    logic collision_matched;
    assign collision_matched = collision_physical && (player_color == block_color) && space_pressed;


    // Maszyna losująca
    logic [9:0] lfsr;
    logic lfsr_feedback;
    assign lfsr_feedback = lfsr[9] ^ lfsr[6]; 

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) lfsr <= 10'd1;
        else        lfsr <= {lfsr[8:0], lfsr_feedback};
    end

    // Logika spadania i liczenia punktów
    always_ff @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin
            vsync_prev    <= 1'b0;
            frame_counter <= '0;
            block_active  <= 1'b0;
            block_x       <= 12'd350;
            block_y       <= '0;
            block_color   <= 1'b0;
            score_ones    <= '0;
            score_tens    <= '0;
            score_hunds   <= '0;
        end else begin
            vsync_prev <= vsync;
            
            if (enable) begin
                // Jeśli wykryto poprawny "STRZAŁ" w wroga
                if (block_active && collision_matched) begin
                    block_active  <= 1'b0;
                    frame_counter <= '0; 
                    
                    // Zliczanie punktów BCD
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
                        if (frame_counter == 6'd59) begin
                            block_active <= 1'b1;
                            block_y      <= 12'd0; 
                            block_x      <= ((lfsr * 22'd900) >> 10) + 12'd20;
                            block_color  <= lfsr[0]; 
                        end else begin
                            frame_counter <= frame_counter + 1'b1;
                        end
                    end else begin
                        block_y <= block_y + 12'd4;
                        if (block_y > 12'd780) begin
                            block_active  <= 1'b0;
                            frame_counter <= '0;
                        end
                    end
                end
            end else begin
                block_active  <= 1'b0;
                frame_counter <= '0;
            end
        end
    end

endmodule