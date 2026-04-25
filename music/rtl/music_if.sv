interface music_if;
    logic [9:0] address;
    logic [31:0] note_divider;
    logic [31:0] duration;

    modport rom (
        input address,
        output note_divider,
        output duration
    );

    modport tone_gen (
        input note_divider
    );

    modport controller (
        input duration,
        output address
    );

endinterface
