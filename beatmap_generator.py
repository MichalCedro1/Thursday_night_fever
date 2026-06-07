import mido
import sys

# --- 1. USTAWIENIA GŁÓWNE ---
<<<<<<< HEAD
PLIK_MIDI = 'music/NightFever/melodia.mid' 
FPS = 60                          
SPEED = 10                        

# --- 2. USTAWIENIA FIZYKI (TUTAJ JEST KLUCZ DO PUNKTÓW) ---
# MUSISZ wpisać tutaj dokładne Y, na którym rysuje się Twój gracz!
PLAYER_Y = 300                   
ENEMY_SIZE = 70 # Zgodnie z Verilogiem

# Aby strzałka była idealnie na czubku głowy w rytm bitu, 
# odejmujemy jej własny rozmiar.
TARGET_BLOCK_Y = PLAYER_Y - ENEMY_SIZE
FRAMES_TO_FALL = int(TARGET_BLOCK_Y / SPEED)

# --- 3. USTAWIENIA 4 KOLUMN (Pełna szerokość 1024px) ---
# Jeśli Twój gracz skacze po sztywnych kolumnach, 
# MUSISZ tu wpisać dokładnie takie same wartości X!
X_COL_1 = 100  
X_COL_2 = 350  
X_COL_3 = 600  
X_COL_4 = 850  

MIN_FRAMES_BETWEEN_NOTES = 15     
=======
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
>>>>>>> f6b9b1e928563921f969042cabd2f37f88073ef0

def generate_beatmap(midi_path):
    try:
        mid = mido.MidiFile(midi_path)
    except FileNotFoundError:
        print(f"Błąd: Nie znaleziono pliku '{midi_path}'.")
        sys.exit(1)

    raw_notes = []
    current_time_sec = 0.0
    
<<<<<<< HEAD
=======
    # Krok 1: Wyciągnięcie wszystkich nut
>>>>>>> f6b9b1e928563921f969042cabd2f37f88073ef0
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

<<<<<<< HEAD
=======
    # Krok 2: Filtrowanie trudności i obliczanie absolutnych klatek UDERZENIA (Hit)
>>>>>>> f6b9b1e928563921f969042cabd2f37f88073ef0
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

<<<<<<< HEAD
    print(f"// --- WYGENEROWANA BEATMAPA (Z IDEALNYM TIMINGIEM) ---")
=======
    # Krok 3: Generowanie formatu SystemVerilog z odpowiednim wyprzedzeniem (Spawn)
    print(f"// --- WYGENEROWANA BEATMAPA (POPRAWIONY TIMING I SZEROKOŚĆ) ---")
>>>>>>> f6b9b1e928563921f969042cabd2f37f88073ef0
    
    valid_blocks = 0
    verilog_lines = []
    
    for note in filtered_notes:
<<<<<<< HEAD
        # Cofamy czas o lot klocka. Klocek spada zanim wejdzie bit.
        spawn_frame = note['hit_frame'] - FRAMES_TO_FALL
        
        if spawn_frame < 0:
            continue
            
        spawn_frame = min(spawn_frame, 65535) 
        
=======
        # Przesuwamy czas w tył! Klocek musi się pojawić ZANIM uderzy bit muzyki.
        spawn_frame = note['hit_frame'] - FRAMES_TO_FALL
        
        # Jeśli pierwsza nuta w piosence jest za szybko (nie ma czasu na lot), pomijamy ją
        if spawn_frame < 0:
            continue
            
        spawn_frame = min(spawn_frame, 65535) # Zabezpieczenie rejestru 16-bit
        
        # Szerokie rozstawienie na 4 kolumny
>>>>>>> f6b9b1e928563921f969042cabd2f37f88073ef0
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
<<<<<<< HEAD
        print("Błąd: Wszystkie nuty usunięte! Piosenka zaczyna się zbyt szybko.")
=======
        print("Błąd: Wszystkie nuty zostały usunięte! Piosenka zaczyna się zbyt szybko.")
>>>>>>> f6b9b1e928563921f969042cabd2f37f88073ef0
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