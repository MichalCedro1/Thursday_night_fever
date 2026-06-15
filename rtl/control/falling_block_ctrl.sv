module falling_block_ctrl #(
    parameter MAX_ONSCREEN = 1
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        vsync,
    input  logic        enable,
    
    input  logic [11:0] player_x,
    input  logic [11:0] player_y,
    input  logic        player_color,
    input  logic        space_pressed,
    
    output logic [MAX_ONSCREEN-1:0][11:0] block_x,
    output logic [MAX_ONSCREEN-1:0][11:0] block_y,
    output logic [MAX_ONSCREEN-1:0] block_active,
    output logic [MAX_ONSCREEN-1:0] block_color,
    
    output logic [3:0]  score_ones,
    output logic [3:0]  score_tens,
    output logic [3:0]  score_hunds,
    output logic        game_over
);

    localparam PLAYER_SIZE = 12'd100; 
    localparam ENEMY_SIZE  = 12'd70;
    localparam TOTAL_BLOCKS = 10'd43;
    localparam HIT_COOLDOWN = 6'd15;
    localparam PENALTY_TIME = 6'd60;

    logic vsync_prev;
    logic enable_prev;
    logic start_new_game;
    logic [5:0] space_cooldown;

    logic space_prev, space_pulse;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) space_prev <= 1'b0;
        else        space_prev <= space_pressed;
    end
    
    assign space_pulse = space_pressed && !space_prev;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            enable_prev <= 1'b0;
        end else begin
            enable_prev <= enable;
        end
    end

    assign start_new_game = enable && !enable_prev;

    logic [31:0] beatmap [0:42];
    always_comb begin
        beatmap[0]  = {16'd1254, 11'd350, 4'd10, 1'b0};
        beatmap[1]  = {16'd1278, 11'd500, 4'd10, 1'b1};
        beatmap[2]  = {16'd1310, 11'd650, 4'd10, 1'b0};
        beatmap[3]  = {16'd1359, 11'd800, 4'd10, 1'b1};
        beatmap[4]  = {16'd1391, 11'd650, 4'd10, 1'b1};
        beatmap[5]  = {16'd1431, 11'd500, 4'd10, 1'b0};
        beatmap[6]  = {16'd1487, 11'd350, 4'd10, 1'b0};
        beatmap[7]  = {16'd1519, 11'd200, 4'd10, 1'b1};
        beatmap[8]  = {16'd1543, 11'd350, 4'd10, 1'b0};
        beatmap[9]  = {16'd1584, 11'd500, 4'd10, 1'b1};
        beatmap[10] = {16'd1632, 11'd650, 4'd10, 1'b0};
        beatmap[11] = {16'd1664, 11'd800, 4'd10, 1'b1};
        beatmap[12] = {16'd1736, 11'd650, 4'd10, 1'b1};
        beatmap[13] = {16'd1776, 11'd500, 4'd10, 1'b1};
        beatmap[14] = {16'd1801, 11'd350, 4'd10, 1'b0};
        beatmap[15] = {16'd1825, 11'd200, 4'd10, 1'b1};
        beatmap[16] = {16'd1889, 11'd350, 4'd10, 1'b0};
        beatmap[17] = {16'd1953, 11'd500, 4'd10, 1'b1};
        beatmap[18] = {16'd2010, 11'd650, 4'd10, 1'b0};
        beatmap[19] = {16'd2074, 11'd500, 4'd10, 1'b1};
        beatmap[20] = {16'd2130, 11'd350, 4'd10, 1'b1};
        beatmap[21] = {16'd2307, 11'd200, 4'd10, 1'b1};
        beatmap[22] = {16'd2371, 11'd350, 4'd10, 1'b0};
        beatmap[23] = {16'd2435, 11'd500, 4'd10, 1'b1};
        beatmap[24] = {16'd2492, 11'd650, 4'd10, 1'b0};
        beatmap[25] = {16'd2564, 11'd800, 4'd10, 1'b1};
        beatmap[26] = {16'd2628, 11'd650, 4'd10, 1'b0};
        beatmap[27] = {16'd2821, 11'd500, 4'd10, 1'b1};
        beatmap[28] = {16'd2853, 11'd350, 4'd10, 1'b0};
        beatmap[29] = {16'd2918, 11'd200, 4'd10, 1'b1};
        beatmap[30] = {16'd2958, 11'd350, 4'd10, 1'b0};
        beatmap[31] = {16'd3046, 11'd500, 4'd10, 1'b0};
        beatmap[32] = {16'd3094, 11'd650, 4'd10, 1'b0};
        beatmap[33] = {16'd3159, 11'd800, 4'd10, 1'b0};
        beatmap[34] = {16'd3207, 11'd650, 4'd10, 1'b1};
        beatmap[35] = {16'd3287, 11'd500, 4'd10, 1'b1};
        beatmap[36] = {16'd3335, 11'd350, 4'd10, 1'b0};
        beatmap[37] = {16'd3464, 11'd200, 4'd10, 1'b1};
        beatmap[38] = {16'd3560, 11'd350, 4'd10, 1'b0};
        beatmap[39] = {16'd3609, 11'd500, 4'd10, 1'b1};
        beatmap[40] = {16'd3721, 11'd650, 4'd10, 1'b0};
        beatmap[41] = {16'd3801, 11'd800, 4'd10, 1'b1};
        beatmap[42] = {16'd3850, 11'd650, 4'd10, 1'b0};
    end

    logic [15:0] global_frame_counter;
    logic [9:0]  block_index;
    logic [MAX_ONSCREEN-1:0][3:0] block_speed;

    logic [MAX_ONSCREEN-1:0] collision_physical;
    logic [MAX_ONSCREEN-1:0] perfect_zone;
    logic [MAX_ONSCREEN-1:0] good_zone;

    for (genvar i = 0; i < MAX_ONSCREEN; i++) begin : gen_collisions
        assign collision_physical[i] = (player_x < (block_x[i] + ENEMY_SIZE))  &&
                                    ((player_x + PLAYER_SIZE) > block_x[i]) &&
                                    (player_y < (block_y[i] + ENEMY_SIZE))  &&
                                    ((player_y + PLAYER_SIZE) > block_y[i]);

        logic [11:0] player_center_x, block_center_x;
        assign player_center_x = player_x + (PLAYER_SIZE >> 1); 
        assign block_center_x  = block_x[i] + (ENEMY_SIZE >> 1);   

        logic [11:0] dist_x;
        assign dist_x = (player_center_x > block_center_x) ? (player_center_x - block_center_x) : (block_center_x - player_center_x);

        logic [11:0] block_bottom;
        assign block_bottom = block_y[i] + ENEMY_SIZE;

        logic [11:0] edge_dist_y; 
        assign edge_dist_y = (player_y > block_bottom) ? (player_y - block_bottom) : (block_bottom - player_y);
        
        assign perfect_zone[i] = collision_physical[i] && (edge_dist_y <= 12'd12) && (dist_x <= 12'd20); 
        assign good_zone[i]    = collision_physical[i] && !perfect_zone[i];
    end

    logic [2:0] free_slot;
    logic       slot_found;
    always_comb begin
        free_slot  = '0;
        slot_found = 1'b0;
        for (int i = 0; i < MAX_ONSCREEN; i++) begin
            if (!block_active[i] && !slot_found) begin
                free_slot  = i[2:0];
                slot_found = 1'b1;
            end
        end
    end

    logic [2:0] target_hit_idx;
    logic       target_hit_valid;
    logic       is_perfect_hit;
    logic       is_good_hit;

    always_comb begin
        target_hit_idx   = '0;
        target_hit_valid = 1'b0;
        is_perfect_hit   = 1'b0;
        is_good_hit      = 1'b0;

        for (int i = 0; i < MAX_ONSCREEN; i++) begin
            if (block_active[i] && !target_hit_valid) begin
                if (perfect_zone[i] && player_color == block_color[i]) begin
                    target_hit_idx   = i[2:0];
                    target_hit_valid = 1'b1;
                    is_perfect_hit   = 1'b1;
                end else if (good_zone[i] && player_color == block_color[i]) begin
                    target_hit_idx   = i[2:0];
                    target_hit_valid = 1'b1;
                    is_good_hit      = 1'b1;
                end
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin
            vsync_prev           <= 1'b0;
            global_frame_counter <= '0;
            block_index          <= '0;
            block_active         <= '0;
            block_x              <= '0;
            block_y              <= '0;
            block_color          <= '0;
            block_speed          <= '0;
            score_ones           <= '0;
            score_tens           <= '0;
            score_hunds          <= '0;
            game_over            <= 1'b0;
            space_cooldown       <= '0;
        end else begin
            vsync_prev <= vsync;

            if (start_new_game) begin
                global_frame_counter <= '0;
                block_index          <= '0;
                block_active         <= '0;
                game_over            <= 1'b0;
                score_ones           <= '0;
                score_tens           <= '0;
                score_hunds          <= '0;
            end
            
            if (enable && !game_over) begin
                
                if (vsync && !vsync_prev && space_cooldown > 0) begin
                    space_cooldown <= space_cooldown - 1'b1;
                end

                if (space_pulse && space_cooldown == 0) begin
                    
                    if (target_hit_valid) begin
                        space_cooldown <= HIT_COOLDOWN;
                        
                        block_active[target_hit_idx] <= 1'b0;
                        
                        if (is_perfect_hit) begin
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
                        end else if (is_good_hit) begin
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
                        
                    end else begin
                        space_cooldown <= PENALTY_TIME;
                        

                        if (score_ones > 4'd0) begin
                            score_ones <= score_ones - 1'b1;
                        end else if (score_tens > 4'd0) begin
                            score_tens <= score_tens - 1'b1;
                            score_ones <= 4'd9;
                        end else if (score_hunds > 4'd0) begin
                            score_hunds <= score_hunds - 1'b1;
                            score_tens <= 4'd9;
                            score_ones <= 4'd9;
                        end
                    end
                end

                if (block_index < TOTAL_BLOCKS) begin
                    if (global_frame_counter >= beatmap[block_index][31:16]) begin
                        if (slot_found) begin
                            block_active[free_slot] <= 1'b1;
                            block_y[free_slot]      <= 12'd0; 
                            block_x[free_slot]      <= {1'b0, beatmap[block_index][15:5]};
                            block_speed[free_slot]  <= beatmap[block_index][4:1];  
                            block_color[free_slot]  <= beatmap[block_index][0];    
                            
                            block_index <= block_index + 1'b1; 
                        end
                    end
                end else if (block_active == '0) begin
                    game_over <= 1'b1;
                end

                if (vsync && !vsync_prev) begin
                    global_frame_counter <= global_frame_counter + 1'b1;

                    for (int i = 0; i < MAX_ONSCREEN; i++) begin
                        if (block_active[i]) begin
                            block_y[i] <= block_y[i] + block_speed[i];
                            
                            if (block_y[i] > 12'd768) begin
                                block_active[i] <= 1'b0;
                            end
                        end
                    end
                end

            end  else if (!enable) begin
                block_active  <= '0;
            end
        end
    end
    
endmodule
