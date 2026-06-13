import mido
import sys

PLIK_MIDI = 'music/NightFever/melodia.mid'          # Nazwa Twojego pliku MIDI
PLIK_WYJSCIOWY = 'music/rtl/music_melodia_bas.sv'          # Nazwa wygenerowanego pliku
NAZWA_MODULU = 'music_rom_melodia'               # Nazwa modułu w kodzie SV
CZESTOTLIWOSC_ZEGARA = 65_000_000

def midi_note_to_freq(note):
    """Konwertuje numer nuty MIDI na częstotliwość w Hz."""
    return 440.0 * (2.0 ** ((note - 69) / 12.0))

def generuj_rom():
    print(f"Otwieranie pliku {PLIK_MIDI}...")
    try:
        mid = mido.MidiFile(PLIK_MIDI)
    except FileNotFoundError:
        print(f"BŁĄD: Nie znaleziono pliku '{PLIK_MIDI}' w tym samym folderze.")
        sys.exit(1)

    nuty = []
    aktualna_nuta = None
    czas_od_ostatniego_zdarzenia = 0.0

    # Analiza zdarzeń MIDI (czas liczony jest w sekundach)
    for msg in mid:
        czas_od_ostatniego_zdarzenia += msg.time 

        is_note_on = msg.type == 'note_on' and msg.velocity > 0
        is_note_off = msg.type == 'note_off' or (msg.type == 'note_on' and msg.velocity == 0)

        if is_note_on:
            # Jeśli wcześniej była cisza, zapisz ją jako pauzę (note=0)
            if aktualna_nuta is None and czas_od_ostatniego_zdarzenia > 0:
                nuty.append({'note': 0, 'duration_sec': czas_od_ostatniego_zdarzenia})
            
            aktualna_nuta = msg.note
            czas_od_ostatniego_zdarzenia = 0.0

        elif is_note_off and aktualna_nuta == msg.note:
            # Zakończ granie obecnej nuty
            nuty.append({'note': aktualna_nuta, 'duration_sec': czas_od_ostatniego_zdarzenia})
            aktualna_nuta = None
            czas_od_ostatniego_zdarzenia = 0.0

    # Generowanie kodu SystemVerilog
    print("Generowanie pliku SystemVerilog...")
    with open(PLIK_WYJSCIOWY, 'w') as f:
        f.write(f"module {NAZWA_MODULU} (\n")
        f.write("    music_if.rom bus\n")
        f.write(");\n\n")
        f.write("    always_comb begin\n")
        f.write("        bus.note_divider = 0;\n")
        f.write("        bus.duration = 0;\n\n")
        f.write("        case (bus.address)\n")

        adres = 0
        for item in nuty:
            dur_sec = item['duration_sec']
            # Ignoruj mikrosekundowe trzaski i "brudy" z MIDI
            if dur_sec < 0.01: 
                continue

            # Oblicz czas trwania w cyklach zegara
            duration_cycles = int(dur_sec * CZESTOTLIWOSC_ZEGARA)

            if item['note'] == 0:
                divider = 0 # Cisza (pauza)
            else:
                freq = midi_note_to_freq(item['note'])
                divider = int(CZESTOTLIWOSC_ZEGARA / (2 * freq))

            # Zapis linii nuty (używamy 16-bitowego adresu dla długich piosenek)
            f.write(f"            16'd{adres:<4}: begin bus.note_divider = 32'd{divider:<8}; bus.duration = 32'd{duration_cycles:<10}; end\n")
            adres += 1

        f.write(f"            default: begin bus.note_divider = 32'd0; bus.duration = 32'd0; end\n")
        f.write("        endcase\n")
        f.write("    end\n")
        f.write("endmodule\n")

    print(f"SUKCES! Wygenerowano {adres} nut do pliku {PLIK_WYJSCIOWY}.")
    print("Pamiętaj, aby podmienić stary plik w swoim projekcie!")

if __name__ == '__main__':
    generuj_rom()