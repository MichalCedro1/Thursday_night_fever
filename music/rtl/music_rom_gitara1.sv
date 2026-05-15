module music_rom_gitara1 (
    music_if.rom bus
);

    always_comb begin
        bus.note_divider = 0;
        bus.duration = 0;

        case (bus.address)
            16'd0   : begin bus.note_divider = 32'd0       ; bus.duration = 32'd2142856000; end
            16'd1   : begin bus.note_divider = 32'd404953  ; bus.duration = 32'd214173992 ; end
            16'd2   : begin bus.note_divider = 32'd454545  ; bus.duration = 32'd214173992 ; end
            16'd3   : begin bus.note_divider = 32'd606745  ; bus.duration = 32'd214173992 ; end
            16'd4   : begin bus.note_divider = 32'd404953  ; bus.duration = 32'd214173992 ; end
            16'd5   : begin bus.note_divider = 32'd404953  ; bus.duration = 32'd214173992 ; end
            16'd6   : begin bus.note_divider = 32'd360772  ; bus.duration = 32'd214173992 ; end
            16'd7   : begin bus.note_divider = 32'd606745  ; bus.duration = 32'd107031192 ; end
            16'd8   : begin bus.note_divider = 32'd454545  ; bus.duration = 32'd107031192 ; end
            16'd9   : begin bus.note_divider = 32'd404953  ; bus.duration = 32'd214173992 ; end
            16'd10  : begin bus.note_divider = 32'd0       ; bus.duration = 32'd3000110007; end
            16'd11  : begin bus.note_divider = 32'd540548  ; bus.duration = 32'd214173992 ; end
            16'd12  : begin bus.note_divider = 32'd360772  ; bus.duration = 32'd214173992 ; end
            16'd13  : begin bus.note_divider = 32'd540548  ; bus.duration = 32'd214173992 ; end
            16'd14  : begin bus.note_divider = 32'd360772  ; bus.duration = 32'd214173992 ; end
            16'd15  : begin bus.note_divider = 32'd540548  ; bus.duration = 32'd107031192 ; end
            16'd16  : begin bus.note_divider = 32'd360772  ; bus.duration = 32'd107031192 ; end
            16'd17  : begin bus.note_divider = 32'd540548  ; bus.duration = 32'd107031192 ; end
            16'd18  : begin bus.note_divider = 32'd360772  ; bus.duration = 32'd107031192 ; end
            16'd19  : begin bus.note_divider = 32'd540548  ; bus.duration = 32'd214173992 ; end
            16'd20  : begin bus.note_divider = 32'd721545  ; bus.duration = 32'd214173992 ; end
            16'd21  : begin bus.note_divider = 32'd0       ; bus.duration = 32'd1714396407; end
            16'd22  : begin bus.note_divider = 32'd404953  ; bus.duration = 32'd214173992 ; end
            16'd23  : begin bus.note_divider = 32'd454545  ; bus.duration = 32'd214173992 ; end
            16'd24  : begin bus.note_divider = 32'd606745  ; bus.duration = 32'd214173992 ; end
            16'd25  : begin bus.note_divider = 32'd404953  ; bus.duration = 32'd214173992 ; end
            16'd26  : begin bus.note_divider = 32'd404953  ; bus.duration = 32'd214173992 ; end
            16'd27  : begin bus.note_divider = 32'd360772  ; bus.duration = 32'd214173992 ; end
            16'd28  : begin bus.note_divider = 32'd606745  ; bus.duration = 32'd107031192 ; end
            16'd29  : begin bus.note_divider = 32'd454545  ; bus.duration = 32'd107031192 ; end
            16'd30  : begin bus.note_divider = 32'd404953  ; bus.duration = 32'd214173992 ; end
            16'd31  : begin bus.note_divider = 32'd0       ; bus.duration = 32'd3000110007; end
            16'd32  : begin bus.note_divider = 32'd540548  ; bus.duration = 32'd214173992 ; end
            16'd33  : begin bus.note_divider = 32'd360772  ; bus.duration = 32'd214173992 ; end
            16'd34  : begin bus.note_divider = 32'd540548  ; bus.duration = 32'd214173992 ; end
            16'd35  : begin bus.note_divider = 32'd360772  ; bus.duration = 32'd214173992 ; end
            16'd36  : begin bus.note_divider = 32'd540548  ; bus.duration = 32'd107031192 ; end
            16'd37  : begin bus.note_divider = 32'd360772  ; bus.duration = 32'd107031192 ; end
            16'd38  : begin bus.note_divider = 32'd540548  ; bus.duration = 32'd107031192 ; end
            16'd39  : begin bus.note_divider = 32'd360772  ; bus.duration = 32'd107031192 ; end
            16'd40  : begin bus.note_divider = 32'd540548  ; bus.duration = 32'd214173992 ; end
            16'd41  : begin bus.note_divider = 32'd721545  ; bus.duration = 32'd214173992 ; end
            16'd42  : begin bus.note_divider = 32'd0       ; bus.duration = 32'd3428681207; end
            16'd43  : begin bus.note_divider = 32'd404953  ; bus.duration = 32'd214173992 ; end
            16'd44  : begin bus.note_divider = 32'd454545  ; bus.duration = 32'd214173992 ; end
            16'd45  : begin bus.note_divider = 32'd606745  ; bus.duration = 32'd214173992 ; end
            16'd46  : begin bus.note_divider = 32'd404953  ; bus.duration = 32'd214173992 ; end
            16'd47  : begin bus.note_divider = 32'd404953  ; bus.duration = 32'd214173992 ; end
            16'd48  : begin bus.note_divider = 32'd360772  ; bus.duration = 32'd214173992 ; end
            16'd49  : begin bus.note_divider = 32'd606745  ; bus.duration = 32'd107031192 ; end
            16'd50  : begin bus.note_divider = 32'd454545  ; bus.duration = 32'd107031192 ; end
            16'd51  : begin bus.note_divider = 32'd404953  ; bus.duration = 32'd214173992 ; end
            default: begin bus.note_divider = 32'd0; bus.duration = 32'd0; end
        endcase
    end
endmodule
