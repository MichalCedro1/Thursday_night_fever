import mido

# --- 1. USTAWIENIA GŁÓWNE ---
MIDI_FILE = 'music/NightFever/melodia.mid'  # Podaj ścieżkę do swojego pliku MIDI
FPS = 60                          # Częstotliwość odświeżania monitora/gry (VSYNC)
SPEED = 10                  # Prędkość spadania klocków (max 15, bo 4 bity)

# --- 2. USTAWIENIA 4 KOLUMN (Rozdzielczość 1024x768) ---
X_COL_1 = 200  # Skrajnie lewa
X_COL_2 = 400  # Środkowo-lewa
X_COL_3 = 600  # Środkowo-prawa
X_COL_4 = 800  # Skrajnie prawa

# --- 3. USTAWIENIA TRUDNOŚCI (BALANS GRY) ---
MIN_FRAMES_BETWEEN_NOTES = 15     # Minimalny odstęp między klockami w klatkach (15 klatek = 0.25s)

def generate_beatmap(midi_path):
    try:
        mid = mido.MidiFile(midi_path)
    except FileNotFoundError:
        print(f"Błąd: Nie znaleziono pliku '{midi_path}'.")
        return

    raw_notes = []
    current_time_sec = 0.0
    
    # Krok 1: Wyciągnięcie wciśnięć klawiszy z pliku MIDI
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

    # Krok 2: Filtrowanie trudności (usunięcie nut leżących zbyt blisko siebie)
    filtered_notes = []
    last_frame_used = -9999

    for note in raw_notes:
        abs_frame = int(note['time'] * FPS)
        
        frames_since_last = abs_frame - last_frame_used
        if frames_since_last >= MIN_FRAMES_BETWEEN_NOTES:
            filtered_notes.append({
                'frame': abs_frame, 
                'pitch': note['pitch']
            })
            last_frame_used = abs_frame

    total_blocks = len(filtered_notes)
    if total_blocks == 0:
        print("Błąd: Filtr trudności wyrzucił wszystkie nuty!")
        return

    # Krok 3: Generowanie kodu do SystemVeriloga
    print(f"// --- WYGENEROWANA BEATMAPA (4 KOLUMNY) ---")
    print(f"// Użyto nut: {total_blocks} z {len(raw_notes)}.")
    print(f"logic [31:0] beatmap [0:{total_blocks-1}];")
    print("always_comb begin")
    
    for i, note in enumerate(filtered_notes):
        frame = min(note['frame'], 65535) # Zabezpieczenie przed przepełnieniem rejestru
        
        # Przypisanie nuty do jednej z 4 kolumn na podstawie wysokości dźwięku (pitch)
        # Typowe dźwięki w MIDI mają wartości od 30 do 90.
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
            
        # Zapis zgodny z 32-bitowym systemem w module Veriloga
        print(f"    beatmap[{i}] = {{16'd{frame}, 11'd{block_x}, 4'd{SPEED}, 1'b{block_color}}};")
        
    print("end")
    print("\n// PAMIĘTAJ: Zmień parametr TOTAL_BLOCKS w module SystemVerilog na:")
    print(f"// localparam TOTAL_BLOCKS = 10'd{total_blocks};")

if __name__ == '__main__':
    generate_beatmap(MIDI_FILE)