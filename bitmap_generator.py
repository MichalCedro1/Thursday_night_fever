from PIL import Image

# 1. Podaj nazwę swojego pliku. Może to być .png, .jpg, lub .bmp
PLIK_WEJSCIOWY = 'strzalka-lewo.png' 
PLIK_WYJSCIOWY = 'strzalka-lewo.hex'

# Docelowe wymiary dla FPGA
SZEROKOSC = 70
WYSOKOSC = 70

try:
    # Wczytanie oryginalnego obrazu
    img = Image.open(PLIK_WEJSCIOWY)
    
    # Przeskalowanie obrazu do wymiarów 110x110 i konwersja na czyste RGB (pozbywa się ew. przezroczystości)
    img_resized = img.resize((SZEROKOSC, WYSOKOSC)).convert('RGB')
    
    # Otwarcie pliku wynikowego do zapisu
    with open(PLIK_WYJSCIOWY, 'w') as plik_hex:
        for y in range(WYSOKOSC):
            for x in range(SZEROKOSC):
                r, g, b = img_resized.getpixel((x, y))
                
                # Konwersja na format 12-bitowy (po 4 bity na każdy kanał koloru)
                r_4bit = r >> 4
                g_4bit = g >> 4
                b_4bit = b >> 4
                
                # Złożenie 12-bitowej wartości (np. czysty zielony to 0F0)
                kolor_hex = (r_4bit << 8) | (g_4bit << 4) | b_4bit
                
                # Zapisanie heksadecymalnej wartości do pliku (jeden piksel na linię)
                plik_hex.write(f"{kolor_hex:03X}\n")
                
    liczba_pikseli = SZEROKOSC * WYSOKOSC
    print(f"Sukces! Obraz przeskalowano do {SZEROKOSC}x{WYSOKOSC}.")
    print(f"Zapisano {liczba_pikseli} pikseli do pliku: {PLIK_WYJSCIOWY}")

except FileNotFoundError:
    print(f"BŁĄD: Nie mogę znaleźć pliku '{PLIK_WEJSCIOWY}'.")
    print("Upewnij się, że obrazek leży w tym samym folderze co ten skrypt.")