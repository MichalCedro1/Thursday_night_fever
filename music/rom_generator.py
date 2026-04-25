CLOCK_FREQ = 100_000_000
BPM = 120

# [Hz]
NOTES = {
    "PAUSE": 0.0,
    "C4": 261.63, "C#4": 277.18, "D4": 293.66, "D#4": 311.13,
    "E4": 329.63, "F4": 349.23,  "F#4": 369.99, "G4": 392.00,
    "G#4": 415.30, "A4": 440.00,  "A#4": 466.16, "B4": 493.88,
    "C5": 523.25, "C#5": 554.37, "D5": 587.33, "D#5": 622.25,
    "E5": 659.25, "F5": 698.46,  "F#5": 739.99, "G5": 783.99,
    "G#5": 830.61, "A5": 880.00,  "A#5": 932.33, "B5": 987.77
}

NOTE_TYPES = {
    "whole": 1.0,         # Cała nuta
    "half": 0.5,          # Półnuta
    "quarter": 0.25,      # Ćwierćnuta
    "eighth": 0.125,      # Ósemka
    "sixteenth": 0.0625   # Szesnastka
}

melody = [
    ("B3", "half"),
    ("B3", "quarter"),
    ("B3", "quarter"),
    ("PAUSE", "quarter"),
    ("B3", "quarter"),
    ("B3", "quarter"),
    ("PAUSE", "whole"),
    ("F#3", "half"),
    ("Ab3", "half"),
    ("B3", "quarter"),
    ("PAUSE", "quarter"),
    ("B3", "quarter"),
    ("B3", "quarter"),
    ("PAUSE", "quarter"),
    ("B3", "quarter"),
    ("Db4", "quarter"),
    ("PAUSE", "whole"),
    ("F#3", "half"),
    ("Ab3", "half"),
    ("B3", "quarter"),
    ("PAUSE", "quarter"),
    ("B3", "quarter"),
    ("B3", "quarter"),
    ("PAUSE", "quarter"),
    ("B3", "quarter"),
    ("Ab3", "half"),
    ("PAUSE", "half"),
    ("A3", "quarter"),
    ("A3", "quarter"),
    ("A3", "quarter"),
    ("PAUSE", "half"),
    ("B3", "half"),
    ("B3", "half"),
    ("PAUSE", "whole"),


    ("Ab3", "half"),
    ("B3", "quarter"),
    ("PAUSE", "quarter"),
    ("D4", "half"),
    ("Db4", "quarter"),
    ("PAUSE", "quarter"),
    ("B3", "quarter"),
    ("B3", "half"),
    ("PAUSE", "half"),
    ("Ab3", "half"),
    ("B3", "quarter"),
    ("PAUSE", "quarter"),
    ("B3", "quarter"),
    ("PAUSE", "quarter"),
    ("B3", "quarter"),
    ("B3", "quarter"),
    ("PAUSE", "quarter"),
    ("Db4", "quarter"),
    ("B3", "quarter"),
    ("Ab3", "half"),
    ("PAUSE", "half"),
    ("Ab3", "half"),
    ("B3", "quarter"),
    ("B3", "quarter"),
    ("PAUSE", "half"),
    ("B3", "half"),
    ("Ab3", "half"),
    ("PAUSE", "quarter"),
    ("Ab3", "quarter"),
    ("B3", "quarter"),
    ("PAUSE", "quarter"),
    ("B3", "quarter"),
    ("PAUSE", "quarter"),
    ("B3", "quarter"),
    ("PAUSE", "half"),
    ("PAUSE", "quarter"),

    ("B3", "half"),
    ("Bb3", "quarter"),
    ("PAUSE", "half"),

    ("Eb3", "half"),
    ("F#3", "half"),
    ("Ab3", "quarter"),
    ("B3", "half"),
    ("B3", "quarter"),
    ("Ab3", "half"),
    ("PAUSE", "quarter"),
    ("F#3", "quarter"),
    ("PAUSE", "quarter"),
    ("Ab3", "half"),
    ("F#3", "half"),
    ("Eb3", "half"),
    ("PAUSE", "quarter"),
    ("Ab3", "half"),
    ("F#3", "quarter"),
    ("Eb3", "half"),
    ("PAUSE", "half"),
    ("Eb3", "half"),
    ("F#3", "half"),
    ("Ab3", "half"),
    ("B3", "half"),
    ("B3", "quarter"),
    ("Ab3", "quarter"),
    ("PAUSE", "quarter"),
    ("F#3", "half"),
    ("Ab3", "quarter"),
    ("F#3", "quarter"),
    ("Eb3", "half"),
    ("Eb3", "quarter"),
    ("PAUSE", "whole"),
    ("PAUSE", "quarter"),

    ("Eb4", "half"),
    ("F#4", "half"),
    ("Ab4", "quarter"),
    ("B4", "half"),
    ("B4", "quarter"),
    ("Ab4", "half"),
    ("PAUSE", "quarter"),
    ("F#4", "quarter"),
    ("Ab4", "quarter"),
    ("B4", "half"),
    ("B4", "quarter"),
    ("B4", "quarter"),
    ("PAUSE", "quarter"),
    ("C5", "quarter"),
]


def generate_sv_rom():
    # Obliczanie czasu trwania całej nuty w sekundach na podstawie BPM
    # 1 ćwierćnuta = 60 / BPM sekund -> cała nuta = 4 * (60 / BPM)
    whole_note_sec = 240.0 / BPM
    
    print("case (bus.address)")
    
    for address, (note, n_type) in enumerate(melody):
        # 1. Obliczanie DURATION (liczba cykli zegara)
        time_sec = NOTE_TYPES[n_type] * whole_note_sec
        duration_cycles = int(time_sec * CLOCK_FREQ)
        
        # 2. Obliczanie NOTE_DIVIDER (liczba cykli na połowę okresu fali)
        freq = NOTES.get(note, 0.0)
        if freq == 0.0:
            divider = 0  # Pauza
        else:
            # Głośnik zmienia stan 2 razy na pełen cykl fali (góra/dół), 
            # stąd dzielimy przez (2 * freq)
            divider = int(CLOCK_FREQ / (2 * freq))
            
        # 3. Formatowanie wyjścia do SystemVerilog
        sv_line = f"    10'd{address}: begin bus.note_divider = 32'd{divider:<6}; bus.duration = 32'd{duration_cycles:<8}; end // {note} ({n_type})"
        print(sv_line)
        
    print(f"    default: begin bus.note_divider = 32'd0; bus.duration = 32'd0; end")
    print("endcase")

if __name__ == "__main__":
    generate_sv_rom()