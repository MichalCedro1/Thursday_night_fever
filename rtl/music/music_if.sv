interface music_if(
    logic [1:0] song_id
);
    logic [15:0] address;
    logic [31:0] note_divider;
    logic [31:0] duration;
    
    modport rom (
        input address,
        input song_id,
        output note_divider,
        output duration
    );

    modport tone_gen (
        input note_divider
    );

    modport controller (
        input duration,
        input song_id,
        output address
    );

endinterface
