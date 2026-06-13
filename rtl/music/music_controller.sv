module music_controller (
    input logic clk,
    input logic rst_n,
    input logic enable,
    input logic [31:0] duration,
    output logic [15:0] address
);

    logic [31:0] timer;
    logic [15:0] current_address;

    logic [31:0] timer_nxt;
    logic [15:0] current_address_nxt;

    assign address = current_address;

    always_comb begin
        timer_nxt = timer;
        current_address_nxt = current_address;
        
        if (!enable) begin
            timer_nxt = 0;
            current_address_nxt = 0;

        end else if (duration > 0) begin
            if (timer >= duration - 1) begin
                timer_nxt = 0;
                current_address_nxt = current_address +1;
            end else begin
                timer_nxt = timer + 1;
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            timer <= 0;
            current_address <= 0;
        end else begin
            timer <= timer_nxt;
            current_address <= current_address_nxt;
            end
    end

endmodule
