module music_player_top (
    input logic clk,
    input logic btnC,
    input  logic [1:0] sw,
    output logic speaker,
    output logic amp_en
);
    logic rst_sync_1, rst_n_safe;

    always_ff @(posedge clk) begin
        rst_sync_1 <= !btnC;
        rst_n_safe <= rst_sync_1;
    end

    assign amp_en = 1'b1;

    music_if m_if_1();
    music_if m_if_2();
    music_if m_if_3();

    assign m_if_1.song_id = sw;
    assign m_if_2.song_id = sw;
    assign m_if_3.song_id = sw;

    logic spk1, spk2, spk3;

    music_rom_melodia u_rom_1 (.bus(m_if_1.rom));
    music_controller  u_ctrl_1 (.clk(clk), .rst_n(rst_n_safe), .bus(m_if_1.controller));
    tone_generator    u_tone_1 (.clk(clk), .rst_n(rst_n_safe), .bus(m_if_1.tone_gen), .speaker(spk1));

    music_rom_bas    u_rom_2 (.bus(m_if_2.rom));
    music_controller u_ctrl_2 (.clk(clk), .rst_n(rst_n_safe), .bus(m_if_2.controller));
    tone_generator   u_tone_2 (.clk(clk), .rst_n(rst_n_safe), .bus(m_if_2.tone_gen), .speaker(spk2));

    music_rom_gitara1 u_rom_3 (.bus(m_if_3.rom));
    music_controller  u_ctrl_3 (.clk(clk), .rst_n(rst_n_safe), .bus(m_if_3.controller));
    tone_generator    u_tone_3 (.clk(clk), .rst_n(rst_n_safe), .bus(m_if_3.tone_gen), .speaker(spk3));

    logic [2:0] audio_mix;
    assign audio_mix = spk1 + spk2 + spk3;


    audio_pwm u_mixer (
        .clk(clk),
        .rst_n(rst_n_safe),
        .mix_in(audio_mix),
        .pwm_out(speaker)
    );

endmodule
