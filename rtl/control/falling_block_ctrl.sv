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
    localparam TOTAL_BLOCKS = 10'd143;
    localparam COOLDOWN_TIME = 6'd20;

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

    logic [31:0] beatmap [0:142];
    always_comb begin
        beatmap[0] = {16'd1254, 11'd600, 4'd10, 1'b0};
        beatmap[1] = {16'd1278, 11'd850, 4'd10, 1'b1};
        beatmap[2] = {16'd1310, 11'd850, 4'd10, 1'b1};
        beatmap[3] = {16'd1359, 11'd600, 4'd10, 1'b0};
        beatmap[4] = {16'd1375, 11'd600, 4'd10, 1'b0};
        beatmap[5] = {16'd1391, 11'd850, 4'd10, 1'b1};
        beatmap[6] = {16'd1415, 11'd850, 4'd10, 1'b1};
        beatmap[7] = {16'd1431, 11'd600, 4'd10, 1'b0};
        beatmap[8] = {16'd1487, 11'd600, 4'd10, 1'b0};
        beatmap[9] = {16'd1503, 11'd600, 4'd10, 1'b0};
        beatmap[10] = {16'd1519, 11'd850, 4'd10, 1'b1};
        beatmap[11] = {16'd1543, 11'd850, 4'd10, 1'b1};
        beatmap[12] = {16'd1584, 11'd600, 4'd10, 1'b0};
        beatmap[13] = {16'd1616, 11'd600, 4'd10, 1'b0};
        beatmap[14] = {16'd1632, 11'd600, 4'd10, 1'b0};
        beatmap[15] = {16'd1664, 11'd850, 4'd10, 1'b1};
        beatmap[16] = {16'd1736, 11'd600, 4'd10, 1'b0};
        beatmap[17] = {16'd1760, 11'd850, 4'd10, 1'b1};
        beatmap[18] = {16'd1776, 11'd850, 4'd10, 1'b1};
        beatmap[19] = {16'd1801, 11'd850, 4'd10, 1'b1};
        beatmap[20] = {16'd1825, 11'd850, 4'd10, 1'b1};
        beatmap[21] = {16'd1873, 11'd600, 4'd10, 1'b0};
        beatmap[22] = {16'd1889, 11'd850, 4'd10, 1'b1};
        beatmap[23] = {16'd1905, 11'd850, 4'd10, 1'b1};
        beatmap[24] = {16'd1921, 11'd600, 4'd10, 1'b0};
        beatmap[25] = {16'd1953, 11'd850, 4'd10, 1'b1};
        beatmap[26] = {16'd1977, 11'd850, 4'd10, 1'b1};
        beatmap[27] = {16'd2010, 11'd600, 4'd10, 1'b0};
        beatmap[28] = {16'd2026, 11'd850, 4'd10, 1'b1};
        beatmap[29] = {16'd2074, 11'd600, 4'd10, 1'b0};
        beatmap[30] = {16'd2098, 11'd600, 4'd10, 1'b0};
        beatmap[31] = {16'd2130, 11'd850, 4'd10, 1'b1};
        beatmap[32] = {16'd2162, 11'd850, 4'd10, 1'b1};
        beatmap[33] = {16'd2307, 11'd350, 4'd10, 1'b1};
        beatmap[34] = {16'd2323, 11'd350, 4'd10, 1'b1};
        beatmap[35] = {16'd2339, 11'd350, 4'd10, 1'b1};
        beatmap[36] = {16'd2371, 11'd350, 4'd10, 1'b1};
        beatmap[37] = {16'd2403, 11'd350, 4'd10, 1'b1};
        beatmap[38] = {16'd2419, 11'd350, 4'd10, 1'b1};
        beatmap[39] = {16'd2435, 11'd350, 4'd10, 1'b1};
        beatmap[40] = {16'd2451, 11'd350, 4'd10, 1'b1};
        beatmap[41] = {16'd2468, 11'd350, 4'd10, 1'b1};
        beatmap[42] = {16'd2492, 11'd350, 4'd10, 1'b1};
        beatmap[43] = {16'd2548, 11'd350, 4'd10, 1'b1};
        beatmap[44] = {16'd2564, 11'd350, 4'd10, 1'b1};
        beatmap[45] = {16'd2580, 11'd350, 4'd10, 1'b1};
        beatmap[46] = {16'd2596, 11'd350, 4'd10, 1'b1};
        beatmap[47] = {16'd2628, 11'd350, 4'd10, 1'b1};
        beatmap[48] = {16'd2644, 11'd350, 4'd10, 1'b1};
        beatmap[49] = {16'd2660, 11'd350, 4'd10, 1'b1};
        beatmap[50] = {16'd2685, 11'd350, 4'd10, 1'b1};
        beatmap[51] = {16'd2821, 11'd600, 4'd10, 1'b0};
        beatmap[52] = {16'd2837, 11'd600, 4'd10, 1'b0};
        beatmap[53] = {16'd2853, 11'd850, 4'd10, 1'b1};
        beatmap[54] = {16'd2885, 11'd600, 4'd10, 1'b0};
        beatmap[55] = {16'd2918, 11'd600, 4'd10, 1'b0};
        beatmap[56] = {16'd2934, 11'd850, 4'd10, 1'b1};
        beatmap[57] = {16'd2958, 11'd850, 4'd10, 1'b1};
        beatmap[58] = {16'd2982, 11'd850, 4'd10, 1'b1};
        beatmap[59] = {16'd3046, 11'd850, 4'd10, 1'b1};
        beatmap[60] = {16'd3062, 11'd850, 4'd10, 1'b1};
        beatmap[61] = {16'd3094, 11'd850, 4'd10, 1'b1};
        beatmap[62] = {16'd3110, 11'd600, 4'd10, 1'b0};
        beatmap[63] = {16'd3126, 11'd850, 4'd10, 1'b1};
        beatmap[64] = {16'd3159, 11'd600, 4'd10, 1'b0};
        beatmap[65] = {16'd3175, 11'd600, 4'd10, 1'b0};
        beatmap[66] = {16'd3207, 11'd600, 4'd10, 1'b0};
        beatmap[67] = {16'd3255, 11'd600, 4'd10, 1'b0};
        beatmap[68] = {16'd3287, 11'd850, 4'd10, 1'b1};
        beatmap[69] = {16'd3303, 11'd600, 4'd10, 1'b0};
        beatmap[70] = {16'd3335, 11'd850, 4'd10, 1'b1};
        beatmap[71] = {16'd3464, 11'd350, 4'd10, 1'b1};
        beatmap[72] = {16'd3496, 11'd600, 4'd10, 1'b0};
        beatmap[73] = {16'd3544, 11'd600, 4'd10, 1'b0};
        beatmap[74] = {16'd3560, 11'd850, 4'd10, 1'b1};
        beatmap[75] = {16'd3576, 11'd850, 4'd10, 1'b1};
        beatmap[76] = {16'd3609, 11'd850, 4'd10, 1'b1};
        beatmap[77] = {16'd3625, 11'd600, 4'd10, 1'b0};
        beatmap[78] = {16'd3641, 11'd850, 4'd10, 1'b1};
        beatmap[79] = {16'd3673, 11'd600, 4'd10, 1'b0};
        beatmap[80] = {16'd3689, 11'd600, 4'd10, 1'b0};
        beatmap[81] = {16'd3721, 11'd600, 4'd10, 1'b0};
        beatmap[82] = {16'd3769, 11'd600, 4'd10, 1'b0};
        beatmap[83] = {16'd3801, 11'd850, 4'd10, 1'b1};
        beatmap[84] = {16'd3818, 11'd600, 4'd10, 1'b0};
        beatmap[85] = {16'd3850, 11'd850, 4'd10, 1'b1};
        beatmap[86] = {16'd4091, 11'd600, 4'd10, 1'b0};
        beatmap[87] = {16'd4107, 11'd600, 4'd10, 1'b0};
        beatmap[88] = {16'd4219, 11'd600, 4'd10, 1'b0};
        beatmap[89] = {16'd4235, 11'd600, 4'd10, 1'b0};
        beatmap[90] = {16'd4251, 11'd600, 4'd10, 1'b0};
        beatmap[91] = {16'd4268, 11'd600, 4'd10, 1'b0};
        beatmap[92] = {16'd4284, 11'd600, 4'd10, 1'b0};
        beatmap[93] = {16'd4300, 11'd600, 4'd10, 1'b0};
        beatmap[94] = {16'd4316, 11'd600, 4'd10, 1'b0};
        beatmap[95] = {16'd4332, 11'd600, 4'd10, 1'b0};
        beatmap[96] = {16'd4356, 11'd600, 4'd10, 1'b0};
        beatmap[97] = {16'd4476, 11'd600, 4'd10, 1'b0};
        beatmap[98] = {16'd4493, 11'd600, 4'd10, 1'b0};
        beatmap[99] = {16'd4509, 11'd600, 4'd10, 1'b0};
        beatmap[100] = {16'd4525, 11'd600, 4'd10, 1'b0};
        beatmap[101] = {16'd4541, 11'd600, 4'd10, 1'b0};
        beatmap[102] = {16'd4557, 11'd850, 4'd10, 1'b1};
        beatmap[103] = {16'd4573, 11'd850, 4'd10, 1'b1};
        beatmap[104] = {16'd4589, 11'd850, 4'd10, 1'b1};
        beatmap[105] = {16'd4669, 11'd600, 4'd10, 1'b0};
        beatmap[106] = {16'd4685, 11'd850, 4'd10, 1'b1};
        beatmap[107] = {16'd4701, 11'd850, 4'd10, 1'b1};
        beatmap[108] = {16'd4718, 11'd850, 4'd10, 1'b1};
        beatmap[109] = {16'd4798, 11'd600, 4'd10, 1'b0};
        beatmap[110] = {16'd4814, 11'd850, 4'd10, 1'b1};
        beatmap[111] = {16'd4830, 11'd850, 4'd10, 1'b1};
        beatmap[112] = {16'd4846, 11'd850, 4'd10, 1'b1};
        beatmap[113] = {16'd5103, 11'd850, 4'd10, 1'b1};
        beatmap[114] = {16'd5119, 11'd850, 4'd10, 1'b1};
        beatmap[115] = {16'd5151, 11'd850, 4'd10, 1'b1};
        beatmap[116] = {16'd5168, 11'd600, 4'd10, 1'b0};
        beatmap[117] = {16'd5184, 11'd850, 4'd10, 1'b1};
        beatmap[118] = {16'd5216, 11'd600, 4'd10, 1'b0};
        beatmap[119] = {16'd5232, 11'd600, 4'd10, 1'b0};
        beatmap[120] = {16'd5264, 11'd600, 4'd10, 1'b0};
        beatmap[121] = {16'd5312, 11'd600, 4'd10, 1'b0};
        beatmap[122] = {16'd5344, 11'd850, 4'd10, 1'b1};
        beatmap[123] = {16'd5360, 11'd600, 4'd10, 1'b0};
        beatmap[124] = {16'd5393, 11'd850, 4'd10, 1'b1};
        beatmap[125] = {16'd5457, 11'd350, 4'd10, 1'b1};
        beatmap[126] = {16'd5473, 11'd350, 4'd10, 1'b1};
        beatmap[127] = {16'd5489, 11'd600, 4'd10, 1'b0};
        beatmap[128] = {16'd5521, 11'd350, 4'd10, 1'b1};
        beatmap[129] = {16'd5537, 11'd350, 4'd10, 1'b1};
        beatmap[130] = {16'd5601, 11'd600, 4'd10, 1'b0};
        beatmap[131] = {16'd5618, 11'd850, 4'd10, 1'b1};
        beatmap[132] = {16'd5634, 11'd850, 4'd10, 1'b1};
        beatmap[133] = {16'd5666, 11'd850, 4'd10, 1'b1};
        beatmap[134] = {16'd5682, 11'd600, 4'd10, 1'b0};
        beatmap[135] = {16'd5698, 11'd850, 4'd10, 1'b1};
        beatmap[136] = {16'd5730, 11'd600, 4'd10, 1'b0};
        beatmap[137] = {16'd5746, 11'd600, 4'd10, 1'b0};
        beatmap[138] = {16'd5778, 11'd600, 4'd10, 1'b0};
        beatmap[139] = {16'd5826, 11'd600, 4'd10, 1'b0};
        beatmap[140] = {16'd5859, 11'd850, 4'd10, 1'b1};
        beatmap[141] = {16'd5875, 11'd600, 4'd10, 1'b0};
        beatmap[142] = {16'd5907, 11'd850, 4'd10, 1'b1};
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
                    space_cooldown <= COOLDOWN_TIME;
                    
                    if (target_hit_valid) begin
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
                    end
                end

                if (block_index < TOTAL_BLOCKS) begin
                    if (global_frame_counter >= beatmap[block_index][31:16]) begin
                        if (slot_found) begin
                            block_active[free_slot] <= 1'b1;
                            block_y[free_slot]      <= 12'd0; 
                            block_x[free_slot]      <= beatmap[block_index][15:5]; 
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

            end else if (!enable) begin
                block_active  <= '0;
                if (game_over && space_pulse) begin
                    game_over <= 1'b0;
                end else if (!game_over) begin
                    global_frame_counter <= '0;
                    block_index   <= '0;
                    score_ones    <= '0;
                    score_tens    <= '0;
                    score_hunds   <= '0;
                end
            end
        end
    end
    
endmodule
