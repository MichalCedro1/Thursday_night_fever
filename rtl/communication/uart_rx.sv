module uart_rx #(
    parameter CLK_FREQ  = 65_000_000,
    parameter BAUD_RATE = 115200
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic       rx,    
    output logic [7:0] rx_data,  
    output logic       rx_ready 
);

    localparam BIT_TICK = CLK_FREQ / BAUD_RATE;
    localparam HALF_TICK = BIT_TICK / 2;
    
    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state;
    
    logic [15:0] clk_cnt;
    logic [2:0]  bit_idx;

    logic rx_sync1, rx_sync2;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) {rx_sync1, rx_sync2} <= 2'b11;
        else        {rx_sync1, rx_sync2} <= {rx_sync2, rx};
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= IDLE;
            rx_ready <= 1'b0;
            rx_data  <= '0;
            clk_cnt  <= '0;
            bit_idx  <= '0;
        end else begin
            rx_ready <= 1'b0;
            
            case (state)
                IDLE: begin
                    if (rx_sync1 == 1'b0) begin 
                        clk_cnt <= '0;
                        state   <= START;
                    end
                end
                
                START: begin
                    if (clk_cnt == HALF_TICK - 1) begin
                        if (rx_sync1 == 1'b0) begin
                            clk_cnt <= '0;
                            bit_idx <= '0;
                            state   <= DATA;
                        end else begin
                            state   <= IDLE;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end
                
                DATA: begin
                    if (clk_cnt == BIT_TICK - 1) begin
                        clk_cnt <= '0;
                        rx_data[bit_idx] <= rx_sync1;
                        
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
                    if (clk_cnt == BIT_TICK - 1) begin
                        rx_ready <= 1'b1;
                        state    <= IDLE;
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end
            endcase
        end
    end
endmodule