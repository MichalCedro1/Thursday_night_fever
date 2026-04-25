module music_controller (
    input logic clk,
    input logic rst_n,
    music_if.controller bus
);

    logic [31:0] timer;
    logic [9:0] current_address;

    assign bus.address = current_address;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            timer <= 0;
            current_address <= 0;
        end else begin
            if(bus.duration > 0) begin
                if (timer >= bus.duration - 1) begin
                    timer <= 0;
                    current_address <=current_address +1;
                end else begin
                    timer <= timer +1;
                end
            end
        end
    end

endmodule
