import mido
import sys

# --- 1. USTAWIENIA GŁÓWNE ---
PLIK_MIDI = 'music/FeverNight/melodia.mid'  # Podaj ścieżkę do swojego pliku MIDI
FPS = 60                          # Odświeżanie gry (60 klatek na sekundę)
SPEED = 10                        # Prędkość spadania klocków (zgodnie z Twoim SV)

# --- 2. FIZYKA GRY I TIMING (NOWE) ---
# Na jakiej wysokości (Y) mniej więcej znajduje się czubek głowy gracza?
# Zakładam 600 (czyli blisko dołu ekranu 768px). Dostosuj to do swojej gry!
PLAYER_Y = 300                    

# Obliczamy ile klatek klocek leci z góry (Y=0) do gracza (Y=PLAYER_Y)
FRAMES_TO_FALL = int(PLAYER_Y / SPEED)

# --- 3. USTAWIENIA 4 KOLUMN (Pełna szerokość 1024px) ---
# Rozsunęliśmy je równomiernie na całą szerokość ekranu
X_COL_1 = 100  # Skrajnie lewa
X_COL_2 = 350  # Środkowo-lewa
X_COL_3 = 600  # Środkowo-prawa
X_COL_4 = 850  # Skrajnie prawa

MIN_FRAMES_BETWEEN_NOTES = 15     # Minimalny odstęp (trudność)

def generate_beatmap(midi_path):
    try:
        mid = mido.MidiFile(midi_path)
    except FileNotFoundError:
        print(f"Błąd: Nie znaleziono pliku '{midi_path}'.")
        sys.exit(1)

    raw_notes = []
    current_time_sec = 0.0
    
    # Krok 1: Wyciągnięcie wszystkich nut
    for msg in mid:
        current_time_sec += msg.time
        if msg.type == 'note_on' and msg.velocity > 0:
            raw_notes.append({
                'time': current_time_sec, 
                'pitch': msg.note
            })
            
    if not raw_notes:
        print("Błąd: Plik MIDI nie zawiera żadnych standardowych nut!")
        return

    # Krok 2: Filtrowanie trudności i obliczanie absolutnych klatek UDERZENIA (Hit)
    filtered_notes = []
    last_hit_frame = -9999

    for note in raw_notes:
        hit_frame = int(note['time'] * FPS)
        
        frames_since_last = hit_frame - last_hit_frame
        if frames_since_last >= MIN_FRAMES_BETWEEN_NOTES:
            filtered_notes.append({
                'hit_frame': hit_frame, 
                'pitch': note['pitch']
            })
            last_hit_frame = hit_frame

    # Krok 3: Generowanie formatu SystemVerilog z odpowiednim wyprzedzeniem (Spawn)
    print(f"// --- WYGENEROWANA BEATMAPA (POPRAWIONY TIMING I SZEROKOŚĆ) ---")
    
    valid_blocks = 0
    verilog_lines = []
    
    for note in filtered_notes:
        # Przesuwamy czas w tył! Klocek musi się pojawić ZANIM uderzy bit muzyki.
        spawn_frame = note['hit_frame'] - FRAMES_TO_FALL
        
        # Jeśli pierwsza nuta w piosence jest za szybko (nie ma czasu na lot), pomijamy ją
        if spawn_frame < 0:
            continue
            
        spawn_frame = min(spawn_frame, 65535) # Zabezpieczenie rejestru 16-bit
        
        # Szerokie rozstawienie na 4 kolumny
        if note['pitch'] < 50:
            block_x = X_COL_1
            block_color = 0 
        elif note['pitch'] < 60:
            block_x = X_COL_2
            block_color = 1 
        elif note['pitch'] < 70:
            block_x = X_COL_3
            block_color = 0 
        else:
            block_x = X_COL_4
            block_color = 1 
            
        verilog_lines.append(f"    beatmap[{valid_blocks}] = {{16'd{spawn_frame}, 11'd{block_x}, 4'd{SPEED}, 1'b{block_color}}};")
        valid_blocks += 1

    if valid_blocks == 0:
        print("Błąd: Wszystkie nuty zostały usunięte! Piosenka zaczyna się zbyt szybko.")
        return

    print(f"// Użyto nut: {valid_blocks}")
    print(f"logic [31:0] beatmap [0:{valid_blocks-1}];")
    print("always_comb begin")
    for line in verilog_lines:
        print(line)
    print("end")
    print(f"\n// PAMIĘTAJ: Zmień TOTAL_BLOCKS w SystemVerilog na: 10'd{valid_blocks};")

if __name__ == '__main__':
    generate_beatmap(PLIK_MIDI)