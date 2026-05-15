module music_player_top (
    input logic clk,
    input logic rst_n,
    input logic [1:0] song_id,
    output logic speakerdasw
);

    music_if m_if();

    assign m_if.song_id = song_id;

    music_rom u_rom (
        .bus(m_if.rom)
    );

    music_controller u_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .bus(m_if.controller)
    );

    tone_generator u_tone (
        .clk(clk),
        .bus(m_if.tone_gen),
        .speaker(speaker)
    );

endmodule
