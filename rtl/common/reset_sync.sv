module reset_sync (
    input  logic clk,
    input  logic async_rst_n,
    output logic sync_rst_n
);

    logic [1:0] sync_reg;

    always_ff @(posedge clk or negedge async_rst_n) begin
        if (!async_rst_n) begin
            sync_reg <= 2'b00;
        end else begin
            sync_reg <= {sync_reg[0], 1'b1};
        end
    end

    assign sync_rst_n = sync_reg[1];

endmodule