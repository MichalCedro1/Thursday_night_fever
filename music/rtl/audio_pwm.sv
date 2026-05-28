module audio_pwm (
    input  logic clk,
    input  logic rst_n,
    input  logic [2:0] mix_in,
    output logic pwm_out
);
    logic [5:0] counter;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            pwm_out <= 0;
        end else begin
            if (counter >= 30) begin
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end

            if (mix_in > counter)
                pwm_out <= 1'b1;
            else
                pwm_out <= 1'b0;
        end
    end
endmodule