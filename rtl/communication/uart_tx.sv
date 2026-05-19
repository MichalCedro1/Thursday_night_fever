module uart_tx #(
    parameter CLK_FREQ  = 65_000_000,
    parameter BAUD_RATE = 115200
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic [7:0] tx_data, 
    input  logic       tx_start, 
    output logic       tx,   
    output logic       tx_busy 
);

    localparam BIT_TICK = CLK_FREQ / BAUD_RATE;
    
    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state;
    
    logic [15:0] clk_cnt;
    logic [2:0]  bit_idx;
    logic [7:0]  data_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= IDLE;
            tx       <= 1'b1;
            tx_busy  <= 1'b0;
            clk_cnt  <= '0;
            bit_idx  <= '0;
            data_reg <= '0;
        end else begin
            case (state)
                IDLE: begin
                    tx      <= 1'b1;
                    tx_busy <= 1'b0;
                    if (tx_start) begin
                        data_reg <= tx_data;
                        tx_busy  <= 1'b1;
                        clk_cnt  <= '0;
                        state    <= START;
                    end
                end
                
                START: begin
                    tx <= 1'b0;
                    if (clk_cnt == BIT_TICK - 1) begin
                        clk_cnt <= '0;
                        bit_idx <= '0;
                        state   <= DATA;
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end
                
                DATA: begin
                    tx <= data_reg[bit_idx];
                    if (clk_cnt == BIT_TICK - 1) begin
                        clk_cnt <= '0;
                        if (bit_idx == 3'd7) begin
                            state <= STOP;
                        end else begin
                            bit_idx <= bit_idx + 1'b1;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end
                
                STOP: begin
                    tx <= 1'b1;
                    if (clk_cnt == BIT_TICK - 1) begin
                        state <= IDLE;
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end
            endcase
        end
    end
endmodule