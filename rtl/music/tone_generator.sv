module tone_generator (
    input logic clk,
    input logic rst_n,
    music_if.tone_gen bus,
    output logic speaker
);

    logic [31:0] counter;
    logic [31:0] counter_nxt;
    logic speaker_nxt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            speaker <= 1'b0;
        end else begin
            counter <= counter_nxt;
            speaker <= speaker_nxt;
        end
    end

    always_comb begin
        counter_nxt = counter;
        speaker_nxt = speaker;

        if (bus.note_divider == 0) begin
            counter_nxt = 0;
            speaker_nxt = 0;
        end else begin
            if (counter>= bus.note_divider - 1) begin
                counter_nxt = 0;
                speaker_nxt = ~speaker;
            end else begin
                counter_nxt = counter + 1;
            end
        end
    end

endmodule
            