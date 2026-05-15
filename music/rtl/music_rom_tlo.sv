module music_rom_tlo (
    music_if.rom bus
);

    always_comb begin
        bus.note_divider = 0;
        bus.duration = 0;

        case (bus.address)
            16'd0   : begin bus.note_divider = 32'd0       ; bus.duration = 32'd428571200 ; end
            16'd1   : begin bus.note_divider = 32'd90193   ; bus.duration = 32'd53459792  ; end
            16'd2   : begin bus.note_divider = 32'd67568   ; bus.duration = 32'd53459792  ; end
            16'd3   : begin bus.note_divider = 32'd101238  ; bus.duration = 32'd214173992 ; end
            16'd4   : begin bus.note_divider = 32'd0       ; bus.duration = 32'd53683007  ; end
            16'd5   : begin bus.note_divider = 32'd67568   ; bus.duration = 32'd53459792  ; end
            16'd6   : begin bus.note_divider = 32'd75843   ; bus.duration = 32'd53459792  ; end
            16'd7   : begin bus.note_divider = 32'd90193   ; bus.duration = 32'd26674092  ; end
            16'd8   : begin bus.note_divider = 32'd90193   ; bus.duration = 32'd53459792  ; end
            16'd9   : begin bus.note_divider = 32'd67568   ; bus.duration = 32'd53459792  ; end
            16'd10  : begin bus.note_divider = 32'd101238  ; bus.duration = 32'd214173992 ; end
            16'd11  : begin bus.note_divider = 32'd0       ; bus.duration = 32'd53683007  ; end
            16'd12  : begin bus.note_divider = 32'd67568   ; bus.duration = 32'd53459792  ; end
            16'd13  : begin bus.note_divider = 32'd75843   ; bus.duration = 32'd53459792  ; end
            16'd14  : begin bus.note_divider = 32'd90193   ; bus.duration = 32'd26674092  ; end
            16'd15  : begin bus.note_divider = 32'd0       ; bus.duration = 32'd3000110007; end
            16'd16  : begin bus.note_divider = 32'd90193   ; bus.duration = 32'd53459792  ; end
            16'd17  : begin bus.note_divider = 32'd67568   ; bus.duration = 32'd53459792  ; end
            16'd18  : begin bus.note_divider = 32'd101238  ; bus.duration = 32'd214173992 ; end
            16'd19  : begin bus.note_divider = 32'd0       ; bus.duration = 32'd53683007  ; end
            16'd20  : begin bus.note_divider = 32'd67568   ; bus.duration = 32'd53459792  ; end
            16'd21  : begin bus.note_divider = 32'd75843   ; bus.duration = 32'd53459792  ; end
            16'd22  : begin bus.note_divider = 32'd90193   ; bus.duration = 32'd26674092  ; end
            16'd23  : begin bus.note_divider = 32'd90193   ; bus.duration = 32'd53459792  ; end
            16'd24  : begin bus.note_divider = 32'd67568   ; bus.duration = 32'd53459792  ; end
            16'd25  : begin bus.note_divider = 32'd101238  ; bus.duration = 32'd214173992 ; end
            16'd26  : begin bus.note_divider = 32'd0       ; bus.duration = 32'd53683007  ; end
            16'd27  : begin bus.note_divider = 32'd67568   ; bus.duration = 32'd53459792  ; end
            16'd28  : begin bus.note_divider = 32'd75843   ; bus.duration = 32'd53459792  ; end
            16'd29  : begin bus.note_divider = 32'd80353   ; bus.duration = 32'd26674092  ; end
            16'd30  : begin bus.note_divider = 32'd45096   ; bus.duration = 32'd428459592 ; end
            16'd31  : begin bus.note_divider = 32'd45096   ; bus.duration = 32'd428459592 ; end
            16'd32  : begin bus.note_divider = 32'd90193   ; bus.duration = 32'd107031192 ; end
            16'd33  : begin bus.note_divider = 32'd101238  ; bus.duration = 32'd107031192 ; end
            16'd34  : begin bus.note_divider = 32'd107258  ; bus.duration = 32'd107031192 ; end
            16'd35  : begin bus.note_divider = 32'd120393  ; bus.duration = 32'd107031192 ; end
            16'd36  : begin bus.note_divider = 32'd135137  ; bus.duration = 32'd214173992 ; end
            16'd37  : begin bus.note_divider = 32'd143172  ; bus.duration = 32'd214173992 ; end
            16'd38  : begin bus.note_divider = 32'd101238  ; bus.duration = 32'd160602592 ; end
            16'd39  : begin bus.note_divider = 32'd90193   ; bus.duration = 32'd53459792  ; end
            16'd40  : begin bus.note_divider = 32'd67568   ; bus.duration = 32'd53459792  ; end
            16'd41  : begin bus.note_divider = 32'd101238  ; bus.duration = 32'd214173992 ; end
            16'd42  : begin bus.note_divider = 32'd0       ; bus.duration = 32'd53683007  ; end
            16'd43  : begin bus.note_divider = 32'd67568   ; bus.duration = 32'd53459792  ; end
            16'd44  : begin bus.note_divider = 32'd75843   ; bus.duration = 32'd53459792  ; end
            16'd45  : begin bus.note_divider = 32'd90193   ; bus.duration = 32'd26674092  ; end
            16'd46  : begin bus.note_divider = 32'd90193   ; bus.duration = 32'd53459792  ; end
            16'd47  : begin bus.note_divider = 32'd67568   ; bus.duration = 32'd53459792  ; end
            16'd48  : begin bus.note_divider = 32'd101238  ; bus.duration = 32'd214173992 ; end
            16'd49  : begin bus.note_divider = 32'd0       ; bus.duration = 32'd53683007  ; end
            16'd50  : begin bus.note_divider = 32'd67568   ; bus.duration = 32'd53459792  ; end
            16'd51  : begin bus.note_divider = 32'd75843   ; bus.duration = 32'd53459792  ; end
            16'd52  : begin bus.note_divider = 32'd90193   ; bus.duration = 32'd26674092  ; end
            16'd53  : begin bus.note_divider = 32'd50619   ; bus.duration = 32'd428459592 ; end
            16'd54  : begin bus.note_divider = 32'd50619   ; bus.duration = 32'd428459592 ; end
            16'd55  : begin bus.note_divider = 32'd50619   ; bus.duration = 32'd428459592 ; end
            16'd56  : begin bus.note_divider = 32'd50619   ; bus.duration = 32'd214173992 ; end
            16'd57  : begin bus.note_divider = 32'd50619   ; bus.duration = 32'd133816892 ; end
            16'd58  : begin bus.note_divider = 32'd45096   ; bus.duration = 32'd26674092  ; end
            16'd59  : begin bus.note_divider = 32'd40176   ; bus.duration = 32'd26674092  ; end
            16'd60  : begin bus.note_divider = 32'd33784   ; bus.duration = 32'd26674092  ; end
            16'd61  : begin bus.note_divider = 32'd25309   ; bus.duration = 32'd267745392 ; end
            16'd62  : begin bus.note_divider = 32'd33784   ; bus.duration = 32'd53459792  ; end
            16'd63  : begin bus.note_divider = 32'd37921   ; bus.duration = 32'd53459792  ; end
            16'd64  : begin bus.note_divider = 32'd33784   ; bus.duration = 32'd53459792  ; end
            16'd65  : begin bus.note_divider = 32'd50619   ; bus.duration = 32'd214173992 ; end
            16'd66  : begin bus.note_divider = 32'd53629   ; bus.duration = 32'd107031192 ; end
            16'd67  : begin bus.note_divider = 32'd67568   ; bus.duration = 32'd107031192 ; end
            16'd68  : begin bus.note_divider = 32'd101238  ; bus.duration = 32'd321316792 ; end
            16'd69  : begin bus.note_divider = 32'd95556   ; bus.duration = 32'd107031192 ; end
            16'd70  : begin bus.note_divider = 32'd90193   ; bus.duration = 32'd53459792  ; end
            16'd71  : begin bus.note_divider = 32'd67568   ; bus.duration = 32'd53459792  ; end
            16'd72  : begin bus.note_divider = 32'd60196   ; bus.duration = 32'd53459792  ; end
            16'd73  : begin bus.note_divider = 32'd60196   ; bus.duration = 32'd80245492  ; end
            16'd74  : begin bus.note_divider = 32'd50619   ; bus.duration = 32'd53459792  ; end
            16'd75  : begin bus.note_divider = 32'd45096   ; bus.duration = 32'd160602592 ; end
            16'd76  : begin bus.note_divider = 32'd90193   ; bus.duration = 32'd53459792  ; end
            16'd77  : begin bus.note_divider = 32'd67568   ; bus.duration = 32'd53459792  ; end
            16'd78  : begin bus.note_divider = 32'd101238  ; bus.duration = 32'd214173992 ; end
            16'd79  : begin bus.note_divider = 32'd0       ; bus.duration = 32'd53683007  ; end
            16'd80  : begin bus.note_divider = 32'd67568   ; bus.duration = 32'd53459792  ; end
            16'd81  : begin bus.note_divider = 32'd75843   ; bus.duration = 32'd53459792  ; end
            16'd82  : begin bus.note_divider = 32'd101238  ; bus.duration = 32'd13281242  ; end
            16'd83  : begin bus.note_divider = 32'd95556   ; bus.duration = 32'd13281242  ; end
            16'd84  : begin bus.note_divider = 32'd45096   ; bus.duration = 32'd428459592 ; end
            16'd85  : begin bus.note_divider = 32'd75843   ; bus.duration = 32'd26674092  ; end
            16'd86  : begin bus.note_divider = 32'd60196   ; bus.duration = 32'd26674092  ; end
            16'd87  : begin bus.note_divider = 32'd50619   ; bus.duration = 32'd26674092  ; end
            16'd88  : begin bus.note_divider = 32'd45096   ; bus.duration = 32'd107031192 ; end
            16'd89  : begin bus.note_divider = 32'd60196   ; bus.duration = 32'd80245492  ; end
            16'd90  : begin bus.note_divider = 32'd45096   ; bus.duration = 32'd107031192 ; end
            16'd91  : begin bus.note_divider = 32'd37921   ; bus.duration = 32'd107031192 ; end
            16'd92  : begin bus.note_divider = 32'd33784   ; bus.duration = 32'd214173992 ; end
            16'd93  : begin bus.note_divider = 32'd35793   ; bus.duration = 32'd214173992 ; end
            16'd94  : begin bus.note_divider = 32'd101238  ; bus.duration = 32'd160602592 ; end
            16'd95  : begin bus.note_divider = 32'd90193   ; bus.duration = 32'd53459792  ; end
            16'd96  : begin bus.note_divider = 32'd67568   ; bus.duration = 32'd53459792  ; end
            16'd97  : begin bus.note_divider = 32'd101238  ; bus.duration = 32'd214173992 ; end
            16'd98  : begin bus.note_divider = 32'd0       ; bus.duration = 32'd53683007  ; end
            16'd99  : begin bus.note_divider = 32'd67568   ; bus.duration = 32'd53459792  ; end
            16'd100 : begin bus.note_divider = 32'd75843   ; bus.duration = 32'd53459792  ; end
            16'd101 : begin bus.note_divider = 32'd90193   ; bus.duration = 32'd26674092  ; end
            16'd102 : begin bus.note_divider = 32'd90193   ; bus.duration = 32'd53459792  ; end
            16'd103 : begin bus.note_divider = 32'd67568   ; bus.duration = 32'd53459792  ; end
            16'd104 : begin bus.note_divider = 32'd101238  ; bus.duration = 32'd214173992 ; end
            16'd105 : begin bus.note_divider = 32'd0       ; bus.duration = 32'd53683007  ; end
            16'd106 : begin bus.note_divider = 32'd67568   ; bus.duration = 32'd53459792  ; end
            16'd107 : begin bus.note_divider = 32'd75843   ; bus.duration = 32'd53459792  ; end
            16'd108 : begin bus.note_divider = 32'd90193   ; bus.duration = 32'd26674092  ; end
            16'd109 : begin bus.note_divider = 32'd90193   ; bus.duration = 32'd53459792  ; end
            16'd110 : begin bus.note_divider = 32'd67568   ; bus.duration = 32'd53459792  ; end
            16'd111 : begin bus.note_divider = 32'd101238  ; bus.duration = 32'd214173992 ; end
            16'd112 : begin bus.note_divider = 32'd0       ; bus.duration = 32'd53683007  ; end
            16'd113 : begin bus.note_divider = 32'd67568   ; bus.duration = 32'd53459792  ; end
            16'd114 : begin bus.note_divider = 32'd75843   ; bus.duration = 32'd53459792  ; end
            16'd115 : begin bus.note_divider = 32'd90193   ; bus.duration = 32'd26674092  ; end
            16'd116 : begin bus.note_divider = 32'd90193   ; bus.duration = 32'd53459792  ; end
            16'd117 : begin bus.note_divider = 32'd67568   ; bus.duration = 32'd53459792  ; end
            16'd118 : begin bus.note_divider = 32'd101238  ; bus.duration = 32'd214173992 ; end
            16'd119 : begin bus.note_divider = 32'd0       ; bus.duration = 32'd53683007  ; end
            16'd120 : begin bus.note_divider = 32'd67568   ; bus.duration = 32'd53459792  ; end
            16'd121 : begin bus.note_divider = 32'd75843   ; bus.duration = 32'd53459792  ; end
            16'd122 : begin bus.note_divider = 32'd90193   ; bus.duration = 32'd26674092  ; end
            16'd123 : begin bus.note_divider = 32'd50619   ; bus.duration = 32'd428459592 ; end
            16'd124 : begin bus.note_divider = 32'd50619   ; bus.duration = 32'd428459592 ; end
            16'd125 : begin bus.note_divider = 32'd50619   ; bus.duration = 32'd428459592 ; end
            16'd126 : begin bus.note_divider = 32'd50619   ; bus.duration = 32'd214173992 ; end
            16'd127 : begin bus.note_divider = 32'd50619   ; bus.duration = 32'd214173992 ; end
            default: begin bus.note_divider = 32'd0; bus.duration = 32'd0; end
        endcase
    end
endmodule
