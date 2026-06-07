module falling_block_ctrl #(
    parameter MAX_ONSCREEN = 8
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

    logic vsync_prev;
    logic enable_prev;
    logic start_new_game;

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
        beatmap[0] = {16'd1277, 11'd600, 4'd10, 1'b0};
        beatmap[1] = {16'd1301, 11'd800, 4'd10, 1'b1};
        beatmap[2] = {16'd1333, 11'd800, 4'd10, 1'b1};
        beatmap[3] = {16'd1382, 11'd600, 4'd10, 1'b0};
        beatmap[4] = {16'd1398, 11'd600, 4'd10, 1'b0};
        beatmap[5] = {16'd1414, 11'd800, 4'd10, 1'b1};
        beatmap[6] = {16'd1438, 11'd800, 4'd10, 1'b1};
        beatmap[7] = {16'd1454, 11'd600, 4'd10, 1'b0};
        beatmap[8] = {16'd1510, 11'd600, 4'd10, 1'b0};
        beatmap[9] = {16'd1526, 11'd600, 4'd10, 1'b0};
        beatmap[10] = {16'd1542, 11'd800, 4'd10, 1'b1};
        beatmap[11] = {16'd1566, 11'd800, 4'd10, 1'b1};
        beatmap[12] = {16'd1607, 11'd600, 4'd10, 1'b0};
        beatmap[13] = {16'd1639, 11'd600, 4'd10, 1'b0};
        beatmap[14] = {16'd1655, 11'd600, 4'd10, 1'b0};
        beatmap[15] = {16'd1687, 11'd800, 4'd10, 1'b1};
        beatmap[16] = {16'd1759, 11'd600, 4'd10, 1'b0};
        beatmap[17] = {16'd1783, 11'd800, 4'd10, 1'b1};
        beatmap[18] = {16'd1799, 11'd800, 4'd10, 1'b1};
        beatmap[19] = {16'd1824, 11'd800, 4'd10, 1'b1};
        beatmap[20] = {16'd1848, 11'd800, 4'd10, 1'b1};
        beatmap[21] = {16'd1896, 11'd600, 4'd10, 1'b0};
        beatmap[22] = {16'd1912, 11'd800, 4'd10, 1'b1};
        beatmap[23] = {16'd1928, 11'd800, 4'd10, 1'b1};
        beatmap[24] = {16'd1944, 11'd600, 4'd10, 1'b0};
        beatmap[25] = {16'd1976, 11'd800, 4'd10, 1'b1};
        beatmap[26] = {16'd2000, 11'd800, 4'd10, 1'b1};
        beatmap[27] = {16'd2033, 11'd600, 4'd10, 1'b0};
        beatmap[28] = {16'd2049, 11'd800, 4'd10, 1'b1};
        beatmap[29] = {16'd2097, 11'd600, 4'd10, 1'b0};
        beatmap[30] = {16'd2121, 11'd600, 4'd10, 1'b0};
        beatmap[31] = {16'd2153, 11'd800, 4'd10, 1'b1};
        beatmap[32] = {16'd2185, 11'd800, 4'd10, 1'b1};
        beatmap[33] = {16'd2330, 11'd400, 4'd10, 1'b1};
        beatmap[34] = {16'd2346, 11'd400, 4'd10, 1'b1};
        beatmap[35] = {16'd2362, 11'd400, 4'd10, 1'b1};
        beatmap[36] = {16'd2394, 11'd400, 4'd10, 1'b1};
        beatmap[37] = {16'd2426, 11'd400, 4'd10, 1'b1};
        beatmap[38] = {16'd2442, 11'd400, 4'd10, 1'b1};
        beatmap[39] = {16'd2458, 11'd400, 4'd10, 1'b1};
        beatmap[40] = {16'd2474, 11'd400, 4'd10, 1'b1};
        beatmap[41] = {16'd2491, 11'd400, 4'd10, 1'b1};
        beatmap[42] = {16'd2515, 11'd400, 4'd10, 1'b1};
        beatmap[43] = {16'd2571, 11'd400, 4'd10, 1'b1};
        beatmap[44] = {16'd2587, 11'd400, 4'd10, 1'b1};
        beatmap[45] = {16'd2603, 11'd400, 4'd10, 1'b1};
        beatmap[46] = {16'd2619, 11'd400, 4'd10, 1'b1};
        beatmap[47] = {16'd2651, 11'd400, 4'd10, 1'b1};
        beatmap[48] = {16'd2667, 11'd400, 4'd10, 1'b1};
        beatmap[49] = {16'd2683, 11'd400, 4'd10, 1'b1};
        beatmap[50] = {16'd2708, 11'd400, 4'd10, 1'b1};
        beatmap[51] = {16'd2844, 11'd600, 4'd10, 1'b0};
        beatmap[52] = {16'd2860, 11'd600, 4'd10, 1'b0};
        beatmap[53] = {16'd2876, 11'd800, 4'd10, 1'b1};
        beatmap[54] = {16'd2908, 11'd600, 4'd10, 1'b0};
        beatmap[55] = {16'd2941, 11'd600, 4'd10, 1'b0};
        beatmap[56] = {16'd2957, 11'd800, 4'd10, 1'b1};
        beatmap[57] = {16'd2981, 11'd800, 4'd10, 1'b1};
        beatmap[58] = {16'd3005, 11'd800, 4'd10, 1'b1};
        beatmap[59] = {16'd3069, 11'd800, 4'd10, 1'b1};
        beatmap[60] = {16'd3085, 11'd800, 4'd10, 1'b1};
        beatmap[61] = {16'd3117, 11'd800, 4'd10, 1'b1};
        beatmap[62] = {16'd3133, 11'd600, 4'd10, 1'b0};
        beatmap[63] = {16'd3149, 11'd800, 4'd10, 1'b1};
        beatmap[64] = {16'd3182, 11'd600, 4'd10, 1'b0};
        beatmap[65] = {16'd3198, 11'd600, 4'd10, 1'b0};
        beatmap[66] = {16'd3230, 11'd600, 4'd10, 1'b0};
        beatmap[67] = {16'd3278, 11'd600, 4'd10, 1'b0};
        beatmap[68] = {16'd3310, 11'd800, 4'd10, 1'b1};
        beatmap[69] = {16'd3326, 11'd600, 4'd10, 1'b0};
        beatmap[70] = {16'd3358, 11'd800, 4'd10, 1'b1};
        beatmap[71] = {16'd3487, 11'd400, 4'd10, 1'b1};
        beatmap[72] = {16'd3519, 11'd600, 4'd10, 1'b0};
        beatmap[73] = {16'd3567, 11'd600, 4'd10, 1'b0};
        beatmap[74] = {16'd3583, 11'd800, 4'd10, 1'b1};
        beatmap[75] = {16'd3599, 11'd800, 4'd10, 1'b1};
        beatmap[76] = {16'd3632, 11'd800, 4'd10, 1'b1};
        beatmap[77] = {16'd3648, 11'd600, 4'd10, 1'b0};
        beatmap[78] = {16'd3664, 11'd800, 4'd10, 1'b1};
        beatmap[79] = {16'd3696, 11'd600, 4'd10, 1'b0};
        beatmap[80] = {16'd3712, 11'd600, 4'd10, 1'b0};
        beatmap[81] = {16'd3744, 11'd600, 4'd10, 1'b0};
        beatmap[82] = {16'd3792, 11'd600, 4'd10, 1'b0};
        beatmap[83] = {16'd3824, 11'd800, 4'd10, 1'b1};
        beatmap[84] = {16'd3841, 11'd600, 4'd10, 1'b0};
        beatmap[85] = {16'd3873, 11'd800, 4'd10, 1'b1};
        beatmap[86] = {16'd4114, 11'd600, 4'd10, 1'b0};
        beatmap[87] = {16'd4130, 11'd600, 4'd10, 1'b0};
        beatmap[88] = {16'd4242, 11'd600, 4'd10, 1'b0};
        beatmap[89] = {16'd4258, 11'd600, 4'd10, 1'b0};
        beatmap[90] = {16'd4274, 11'd600, 4'd10, 1'b0};
        beatmap[91] = {16'd4291, 11'd600, 4'd10, 1'b0};
        beatmap[92] = {16'd4307, 11'd600, 4'd10, 1'b0};
        beatmap[93] = {16'd4323, 11'd600, 4'd10, 1'b0};
        beatmap[94] = {16'd4339, 11'd600, 4'd10, 1'b0};
        beatmap[95] = {16'd4355, 11'd600, 4'd10, 1'b0};
        beatmap[96] = {16'd4379, 11'd600, 4'd10, 1'b0};
        beatmap[97] = {16'd4499, 11'd600, 4'd10, 1'b0};
        beatmap[98] = {16'd4516, 11'd600, 4'd10, 1'b0};
        beatmap[99] = {16'd4532, 11'd600, 4'd10, 1'b0};
        beatmap[100] = {16'd4548, 11'd600, 4'd10, 1'b0};
        beatmap[101] = {16'd4564, 11'd600, 4'd10, 1'b0};
        beatmap[102] = {16'd4580, 11'd800, 4'd10, 1'b1};
        beatmap[103] = {16'd4596, 11'd800, 4'd10, 1'b1};
        beatmap[104] = {16'd4612, 11'd800, 4'd10, 1'b1};
        beatmap[105] = {16'd4692, 11'd600, 4'd10, 1'b0};
        beatmap[106] = {16'd4708, 11'd800, 4'd10, 1'b1};
        beatmap[107] = {16'd4724, 11'd800, 4'd10, 1'b1};
        beatmap[108] = {16'd4741, 11'd800, 4'd10, 1'b1};
        beatmap[109] = {16'd4821, 11'd600, 4'd10, 1'b0};
        beatmap[110] = {16'd4837, 11'd800, 4'd10, 1'b1};
        beatmap[111] = {16'd4853, 11'd800, 4'd10, 1'b1};
        beatmap[112] = {16'd4869, 11'd800, 4'd10, 1'b1};
        beatmap[113] = {16'd5126, 11'd800, 4'd10, 1'b1};
        beatmap[114] = {16'd5142, 11'd800, 4'd10, 1'b1};
        beatmap[115] = {16'd5174, 11'd800, 4'd10, 1'b1};
        beatmap[116] = {16'd5191, 11'd600, 4'd10, 1'b0};
        beatmap[117] = {16'd5207, 11'd800, 4'd10, 1'b1};
        beatmap[118] = {16'd5239, 11'd600, 4'd10, 1'b0};
        beatmap[119] = {16'd5255, 11'd600, 4'd10, 1'b0};
        beatmap[120] = {16'd5287, 11'd600, 4'd10, 1'b0};
        beatmap[121] = {16'd5335, 11'd600, 4'd10, 1'b0};
        beatmap[122] = {16'd5367, 11'd800, 4'd10, 1'b1};
        beatmap[123] = {16'd5383, 11'd600, 4'd10, 1'b0};
        beatmap[124] = {16'd5416, 11'd800, 4'd10, 1'b1};
        beatmap[125] = {16'd5480, 11'd400, 4'd10, 1'b1};
        beatmap[126] = {16'd5496, 11'd400, 4'd10, 1'b1};
        beatmap[127] = {16'd5512, 11'd600, 4'd10, 1'b0};
        beatmap[128] = {16'd5544, 11'd400, 4'd10, 1'b1};
        beatmap[129] = {16'd5560, 11'd400, 4'd10, 1'b1};
        beatmap[130] = {16'd5624, 11'd600, 4'd10, 1'b0};
        beatmap[131] = {16'd5641, 11'd800, 4'd10, 1'b1};
        beatmap[132] = {16'd5657, 11'd800, 4'd10, 1'b1};
        beatmap[133] = {16'd5689, 11'd800, 4'd10, 1'b1};
        beatmap[134] = {16'd5705, 11'd600, 4'd10, 1'b0};
        beatmap[135] = {16'd5721, 11'd800, 4'd10, 1'b1};
        beatmap[136] = {16'd5753, 11'd600, 4'd10, 1'b0};
        beatmap[137] = {16'd5769, 11'd600, 4'd10, 1'b0};
        beatmap[138] = {16'd5801, 11'd600, 4'd10, 1'b0};
        beatmap[139] = {16'd5849, 11'd600, 4'd10, 1'b0};
        beatmap[140] = {16'd5882, 11'd800, 4'd10, 1'b1};
        beatmap[141] = {16'd5898, 11'd600, 4'd10, 1'b0};
        beatmap[142] = {16'd5930, 11'd800, 4'd10, 1'b1};
    end

    logic [15:0] global_frame_counter;
    logic [9:0]  block_index;
    logic [MAX_ONSCREEN-1:0][3:0] block_speed;

    logic [MAX_ONSCREEN-1:0] collision_physical;
    logic [MAX_ONSCREEN-1:0] perfect_zone;
    logic [MAX_ONSCREEN-1:0] good_zone;

    for (genvar i = 0; i < MAX_ONSCREEN; i++) begin : gen_collisions
        assign collision_physical = (player_x < (block_x[i] + ENEMY_SIZE))  &&
                                    ((player_x + PLAYER_SIZE) > block_x[i]) &&
                                    (player_y < (block_y[i] + ENEMY_SIZE))  &&
                                    ((player_y + PLAYER_SIZE) > block_y[i]);
        logic [11:0] block_bottom;
        assign block_bottom = block_y[i] + ENEMY_SIZE;

        logic [11:0] edge_dist_y; 
        assign edge_dist_y = (player_y > block_bottom) ? (player_y - block_bottom) : (block_bottom - player_y);
        
        assign perfect_zone[i] = collision_physical[i] && (edge_dist_y <= 12'd12); 
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
                
                if (space_pulse && target_hit_valid) begin
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
