module multiplayer_ctrl (
    input  logic       clk,
    input  logic       rst_n,
    
    input  logic       game_enable,
    input  logic       game_over,
    input  logic [3:0] my_score_ones,
    input  logic [3:0] my_score_tens,
    input  logic [3:0] my_score_hunds,
    
    input  logic       space_pressed, 
    
    input  logic [7:0] rx_data,
    input  logic       rx_ready,
    
    output logic [7:0] tx_data,
    output logic       tx_start,
    input  logic       tx_busy,
    
    output logic [3:0] opp_score_ones,
    output logic [3:0] opp_score_tens,
    output logic [3:0] opp_score_hunds,
    output logic       opp_score_ready,
    output logic [1:0] match_result,
    output logic       launch_game      
);

    enum logic [2:0] {TX_IDLE, TX_WAIT_H, TX_WAIT_T, TX_WAIT_O} tx_state;
    
    logic [11:0] prev_my_score;
    logic [11:0] current_my_score;
    assign current_my_score = {my_score_hunds, my_score_tens, my_score_ones};
    
    logic game_over_prev;
    logic local_ready;
    logic remote_ready;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_state        <= TX_IDLE;
            tx_start        <= 1'b0;
            tx_data         <= 8'h00;
            prev_my_score   <= '0;
            game_over_prev  <= 1'b0;
        end else begin
            game_over_prev <= game_over;
            tx_start       <= 1'b0;

            case (tx_state)
                TX_IDLE: begin
                    if (!game_enable) begin
                        prev_my_score <= '0;
                        
                        if (space_pressed && !tx_busy) begin
                            tx_data  <= 8'hD1;
                            tx_start <= 1'b1;
                        end
                    end else begin
                        if ((current_my_score != prev_my_score) || (game_over && !game_over_prev)) begin
                            prev_my_score <= current_my_score;
                            tx_data       <= {4'hA, my_score_hunds};
                            tx_start      <= 1'b1;
                            tx_state      <= TX_WAIT_H;
                        end
                    end
                end
                TX_WAIT_H: if (!tx_busy && !tx_start) begin
                    tx_data  <= {4'hB, my_score_tens};
                    tx_start <= 1'b1;
                    tx_state <= TX_WAIT_T;
                end
                TX_WAIT_T: if (!tx_busy && !tx_start) begin
                    tx_data  <= {4'hC, my_score_ones};
                    tx_start <= 1'b1;
                    tx_state <= TX_WAIT_O;
                end
                TX_WAIT_O: if (!tx_busy && !tx_start) begin
                    tx_state <= TX_IDLE;
                end
                default: tx_state <= TX_IDLE;
            endcase
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            opp_score_hunds <= '0;
            opp_score_tens  <= '0;
            opp_score_ones  <= '0;
            opp_score_ready <= 1'b0;
            local_ready     <= 1'b0;
            remote_ready    <= 1'b0;
            launch_game     <= 1'b0;
        end else begin
            if (!game_enable) begin
                opp_score_hunds <= '0;
                opp_score_tens  <= '0;
                opp_score_ones  <= '0;
                opp_score_ready <= 1'b0; 
                
                if (space_pressed) begin
                    local_ready <= 1'b1;
                end
                
                if (rx_ready && (rx_data == 8'hD1)) begin
                    remote_ready <= 1'b1;
                end
                
                if (local_ready && remote_ready) begin
                    launch_game  <= 1'b1;
                    local_ready  <= 1'b0;
                    remote_ready <= 1'b0;
                end else begin
                    launch_game  <= 1'b0;
                end
            end else begin
                local_ready  <= 1'b0;
                remote_ready <= 1'b0;
                launch_game  <= 1'b0;
                
                if (rx_ready) begin
                    case (rx_data[7:4])
                        4'hA: opp_score_hunds <= rx_data[3:0];
                        4'hB: opp_score_tens  <= rx_data[3:0];
                        4'hC: begin 
                            opp_score_ones  <= rx_data[3:0];
                            opp_score_ready <= 1'b1;
                        end
                    endcase
                end
            end
        end
    end

    logic [11:0] my_tot, opp_tot;
    assign my_tot  = {my_score_hunds, my_score_tens, my_score_ones};
    assign opp_tot = {opp_score_hunds, opp_score_tens, opp_score_ones};

    always_comb begin
        match_result = 2'd0;
        if (game_over && opp_score_ready) begin
            if (my_tot > opp_tot)       match_result = 2'd1; 
            else if (my_tot < opp_tot)  match_result = 2'd2; 
            else                        match_result = 2'd3; 
        end
    end
endmodule