import mido
import sys
import random

# --- 1. USTAWIENIA GŁÓWNE ---
PLIK_MIDI = 'music/NightFever/melodia.mid' 
PLIK_WYJSCIOWY = 'beatmap_generated.sv'
FPS = 60                          
SPEED = 10                        

# --- 2. USTAWIENIA FIZYKI (TUTAJ BYŁ BŁĄD TIMINGU) ---
# W Twoim module 'keyboard_ctrl.sv' ypos gracza = 468!
PLAYER_Y = 468                   
ENEMY_SIZE = 70 

# Idealne trafienie jest wtedy, gdy dół klocka (Y + ENEMY_SIZE) dotyka góry gracza.
# Musimy więc zrzucić klocek tak, aby jego "nos" dotarł do (468 - 70).
TARGET_BLOCK_Y = PLAYER_Y - ENEMY_SIZE # 398
FRAMES_TO_FALL = int(TARGET_BLOCK_Y / SPEED) # Zrzut zajmie około 39 klatek

# --- 3. USTAWIENIA ROZGRYWKI ---
KOLUMNY = [200, 350, 500, 650, 800] # Kolumny, po których spadają strzałki
MIN_FRAMES_BETWEEN_NOTES = 15       # Odstęp zapobiegający "spamowi" strzałek

def generate_beatmap(midi_path):
    print(f"Czytam plik: {midi_path}...")
    try:
        mid = mido.MidiFile(midi_path)
    except FileNotFoundError:
        print(f"Błąd: Nie znaleziono pliku '{midi_path}'.")
        sys.exit(1)

    raw_notes = []
    current_time_sec = 0.0
    
    # Krok 1: Zbieranie surowych nut
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

    # Krok 2: Filtracja (Anti-Spam)
    filtered_notes = []
    last_hit_frame = -9999

    for note in raw_notes:
        hit_frame = int(note['time'] * FPS)
        frames_since_last = hit_frame - last_hit_frame
        
        if frames_since_last >= MIN_FRAMES_BETWEEN_NOTES:
            filtered_notes.append({'hit_frame': hit_frame})
            last_hit_frame = hit_frame

    # Krok 3: Wyliczenie klatek wyrzutu (Spawn) i generowanie SV
    valid_blocks = 0
    verilog_lines = []
    
    for note in filtered_notes:
        # COFAMY CZAS! Strzałka wylatuje WCZEŚNIEJ, by trafić w rytm.
        spawn_frame = note['hit_frame'] - FRAMES_TO_FALL
        
        # Ignorujemy nuty, które grają zanim gra w ogóle by zdążyła zrzucić strzałkę
        if spawn_frame < 0:
            continue
            
        spawn_frame = min(spawn_frame, 65535) 
        
        # Losujemy dla dynamiki: X z puli KOLUMNY oraz wymóg koloru gracza (0 lub 1)
        block_x = random.choice(KOLUMNY)
        block_color = random.choice([0, 1])
            
        verilog_lines.append(f"        beatmap[{valid_blocks}] = {{16'd{spawn_frame}, 11'd{block_x}, 4'd{SPEED}, 1'b{block_color}}};")
        valid_blocks += 1

    if valid_blocks == 0:
        print("Błąd: Piosenka zaczyna się zbyt wcześnie lub nie ma nut.")
        return

    # Zapis do gotowego pliku
    with open(PLIK_WYJSCIOWY, 'w') as f:
        f.write(f"// Wygenerowano automatycznie. Opoznienie lotu: {FRAMES_TO_FALL} klatek.\n")
        f.write(f"localparam TOTAL_BLOCKS = 10'd{valid_blocks};\n\n")
        f.write(f"logic [31:0] beatmap [0:{valid_blocks-1}];\n")
        f.write("always_comb begin\n")
        for line in verilog_lines:
            f.write(line + "\n")
        f.write("end\n")

    print(f"SUKCES! Wygenerowano {valid_blocks} do pliku {PLIK_WYJSCIOWY}.")

if __name__ == '__main__':
    generate_beatmap(PLIK_MIDI)