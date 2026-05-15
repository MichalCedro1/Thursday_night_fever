module music_controller (
    input logic clk,
    input logic rst_n,
    music_if.controller bus
);

    logic [31:0] timer;
    logic [15:0] current_address;
    logic [1:0] last_song_id;

    logic [31:0] timer_nxt;
    logic [15:0] current_address_nxt;
    logic [1:0] last_song_id_nxt;

    assign bus.address = current_address;

    always_comb begin
        timer_nxt = timer;
        current_address_nxt = current_address;
        last_song_id_nxt = bus.song_id;

        if(bus.song_id != last_song_id) begin
            timer_nxt = 0;
            current_address_nxt = 0;

        end else if (bus.duration > 0) begin
            if (timer >= bus.duration - 1) begin
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
            last_song_id <= 0;
        end else begin
            timer <= timer_nxt;
            current_address <= current_address_nxt;
            last_song_id <= last_song_id_nxt;
            end
    end

endmodule
