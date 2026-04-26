CLOCK_FREQ = 100_000_000
BPM = 400

# [Hz]
NOTES = {
    "PAUSE": 0,
    "Eb3": 156, "D#3": 156,
    "E3": 165,
    "F3": 175,
    "F#3": 185, "Gb3": 185,
    "G3": 196,
    "Ab3": 208, "G#3": 208,
    "A3": 220,
    "Bb3": 233, "A#3": 233,
    "B3": 247,
    "C4": 262,
    "Db4": 277, "C#4": 277,
    "D4": 294,
    "Eb4": 311, "D#4": 311,
    "E4": 330,
    "F4": 349,
    "F#4": 370, "Gb4": 370,
    "G4": 392,
    "Ab4": 415, "G#4": 415,
    "A4": 440,
    "Bb4": 466, "A#4": 466,
    "B4": 494,
    "C5": 523,
    "Db5": 554, "C#5": 554,
    "D5": 587,
    "Eb5": 622, "D#5": 622,
    "E5": 659,
    "F5": 698
}

NOTE_TYPES = {
    "whole": 1.0,         # Cała nuta
    "half": 0.5,          # Półnuta
    "quarter": 0.25,      # Ćwierćnuta
    "eighth": 0.125,      # Ósemka
    "sixteenth": 0.0625   # Szesnastka
}

# Night Fever
melody = [
    ("B3", "half")
    ("B3", "quarter")
    ("B3", "quarter")
    ("PAUSE", "quarter")
    ("B3", "quarter")
    ("B3", "quarter")
    ("PAUSE", "whole")
    ("F#3", "half")
    ("Ab3", "half")
    ("B3", "quarter")
    ("PAUSE", "quarter")
    ("B3", "quarter")
    ("B3", "quarter")
    ("PAUSE", "quarter")
    ("B3", "quarter")
    ("Db4", "quarter")
    ("PAUSE", "whole")
    ("F#3", "half")
    ("Ab3", "half")
    ("B3", "quarter")
    ("PAUSE", "quarter")
    ("B3", "quarter")
    ("B3", "quarter")
    ("PAUSE", "quarter")
    ("B3", "quarter")
    ("Ab3", "half")
    ("PAUSE", "half")
    ("A3", "quarter")
    ("A3", "quarter")
    ("A3", "quarter")
    ("PAUSE", "half")
    ("B3", "half")
    ("B3", "half")
    ("PAUSE", "whole")



    ("Ab3", "half")
    ("B3", "quarter")
    ("PAUSE", "quarter")
    ("D4", "half")
    ("Db4", "quarter")
    ("PAUSE", "quarter")
    ("B3", "quarter")
    ("B3", "half")
    ("PAUSE", "half")
    ("Ab3", "half")
    ("B3", "quarter")
    ("PAUSE", "quarter")
    ("B3", "quarter")
    ("PAUSE", "quarter")
    ("B3", "quarter")
    ("B3", "quarter")
    ("PAUSE", "quarter")
    ("Db4", "quarter")
    ("B3", "quarter")
    ("Ab3", "half")
    ("PAUSE", "half")
    

    ("Ab3", "half")
    ("B3", "quarter")
    ("B3", "quarter")
    ("PAUSE", "half")
    ("B3", "half")
    ("Ab3", "half")
    ("PAUSE", "quarter")
    ("Ab3", "quarter")
    ("B3", "quarter")
    ("PAUSE", "quarter")
    ("B3", "quarter")
    ("B3", "quarter")
    ("PAUSE", "whole")


    ("B3", "whole")
    ("Bb3", "quarter")
    ("PAUSE", "quarter")


    ("Eb3", "half")
    ("F#3", "half")
    ("Ab3", "half")
    ("B3", "whole")
    ("Ab3", "whole")
    ("F#3", "half")
    ("Ab3", "half")
    ("F#3", "half")
    ("Eb3", "half")
    ("Ab3", "whole")
    ("F#3", "whole")
    ("PAUSE", "quarter")
    ("Eb3", "half")
    ("F#3", "half")
    ("Ab3", "half")
    ("B3", "whole")
    ("Ab3", "half")
    ("F#3", "half")
    ("Ab3", "quarter")
    ("F#3", "quarter")
    ("Eb3", "whole")
    ("PAUSE", "whole")
    
    ("Eb4", "half")
    ("F#4", "half")
    ("Ab4", "quarter")
    ("B4", "half")
    ("B4", "quarter")
    ("Ab4", "half")
    ("PAUSE", "quarter")
    ("F#4", "quarter")
    ("Ab4", "quarter")
    ("B4", "half")
    ("B4", "quarter")
    ("B4", "quarter")
    ("PAUSE", "half")

    
    ("C5", "whole")
    ("PAUSE", "half")


    ("Db5", "quarter")
    ("PAUSE", "quarter")
    ("Db5", "half")
    ("PAUSE", "half")
    ("B4", "quarter")
    ("PAUSE", "quarter")
    ("Ab4", "quarter")
    ("PAUSE", "quarter")
    ("B4", "whole")
    ("Ab4", "quarter")
    ("PAUSE", "quarter")
    ("F#4", "half")
    ("PAUSE", "quarter")
    ("E4", "quarter")
    ("Db4", "half")

    ("PAUSE", "half")
    ("PAUSE", "quarter")
    ("Ab4", "quarter")
    ("B4", "half")
    ("PAUSE", "quarter")
    ("B4", "half")
    ("Ab4", "quarter")
    ("B4", "half")
    ("PAUSE", "quarter")
    ("Db5", "half")

    ("PAUSE", "whole")
    ("F#4", "whole")
    ("Ab4", "half")
    ("F#4", "half")
    ("E4", "half")
    ("Db4", "whole")
    ("PAUSE", "whole")


    ("Db5", "quarter")
    ("PAUSE", "quarter")
    ("Db5", "half")
    ("PAUSE", "half")
    ("B4", "quarter")
    ("PAUSE", "quarter")
    ("Ab4", "quarter")
    ("PAUSE", "quarter")
    ("B4", "whole")
    ("Ab4", "quarter")
    ("PAUSE", "quarter")
    ("F#4", "half")
    ("PAUSE", "quarter")
    ("E4", "quarter")
    ("Db4", "half")

    ("PAUSE", "half")
    ("PAUSE", "quarter")
    ("Ab4", "quarter")
    ("B4", "half")
    ("PAUSE", "quarter")
    ("B4", "half")
    ("Ab4", "quarter")
    ("B4", "half")
    ("PAUSE", "quarter")
    ("Db5", "half")

    ("PAUSE", "whole")
    ("F#4", "whole")
    ("Ab4", "half")
    ("F#4", "half")
    ("E4", "half")
    ("Db4", "whole")
    ("PAUSE", "whole")

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