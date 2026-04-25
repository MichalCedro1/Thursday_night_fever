module music_rom (
    music_if.rom bus
);

    always_comb begin
        bus.note_divider = 0;
        bus.duration = 0;

        case (bus.address)
            //[Adres] : begin bus.note_divider = [Dzielnik]; bus.duration = [Czas trwania]; end
            //musze najpierw napisac muzyke zeby wypelnic >:(
            default: begin bus.note_divider = 8'b0; bus_duration = 8'b0; end
        endcase
    end

endmodule
