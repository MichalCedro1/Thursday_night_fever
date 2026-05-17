`timescale 1ns / 1ps

module keyboard_ctrl_tb;
    logic clk;
    logic rst_n;
    logic ps2_clk;
    logic ps2_data;
    logic vsync;
    logic [11:0] xpos;
    logic [11:0] ypos;

    keyboard_ctrl uut (
        .clk(clk),
        .rst_n(rst_n),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .vsync(vsync),
        .xpos(xpos),
        .ypos(ypos)
    );

    // Generacja zegara głównego (np. 50 MHz -> okres 20 ns)
    always #10 clk = ~clk;

    // Generacja sygnału vsync (symulacja odświeżania ekranu np. 60Hz)
    // W symulacji przyspieszymy to, by test nie trwał w nieskończoność
    always begin
        #1000000; // Czekaj 1 ms
        vsync = 1'b1;
        #20000;   // Impuls vsync trwa 20 us
        vsync = 1'b0;
    end

    // Zadanie do wysyłania pojedynczego bajtu PS/2
    task send_ps2_byte(input logic [7:0] data);
        logic parity;
        integer i;
        
        // Obliczenie nieparzystości (Odd Parity)
        parity = ~(^data); 

        // --- Bit Startu (0) ---
        ps2_data = 1'b0;
        #20000; ps2_clk = 1'b0; // Odczekaj i opuść zegar
        #20000; ps2_clk = 1'b1; // Podnieś zegar

        // --- 8 Bitów Danych (LSB First) ---
        for (i = 0; i < 8; i++) begin
            ps2_data = data[i];
            #20000; ps2_clk = 1'b0; 
            #20000; ps2_clk = 1'b1;
        end

        // --- Bit Parzystości ---
        ps2_data = parity;
        #20000; ps2_clk = 1'b0; 
        #20000; ps2_clk = 1'b1;

        // --- Bit Stopu (1) ---
        ps2_data = 1'b1;
        #20000; ps2_clk = 1'b0; 
        #20000; ps2_clk = 1'b1;

        // Przerwa między kolejnymi bajtami
        #50000;
    endtask

    // Główny blok stymulacyjny
    initial begin
        // Inicjalizacja sygnałów
        clk = 0;
        rst_n = 0;
        ps2_clk = 1; // Linia PS/2 w stanie spoczynku jest w stanie wysokim
        ps2_data = 1;
        vsync = 0;

        $display("Rozpoczęcie symulacji...");

        // Zwolnienie resetu po krótkim czasie
        #100;
        rst_n = 1;
        
        // Czekamy na ustabilizowanie układu
        #200000;

        // ---------------------------------------------------------
        // TEST 1: Wciśnięcie i trzymanie klawisza 'A' (Lewo)
        // Klawiatura wysyła kod 'Make' dla A: 0x1C
        // ---------------------------------------------------------
        $display("[%0t] Wcisniecie klawisza 'A' (0x1C)", $time);
        send_ps2_byte(8'h1C);
        
        // Czekamy przez kilka impulsów vsync, aby zobaczyć ruch w lewo
        // xpos powinno maleć z początkowych 350
        #3500000; 

        // ---------------------------------------------------------
        // TEST 2: Puszczenie klawisza 'A'
        // Klawiatura wysyła kod 'Break': 0xF0, a potem 0x1C
        // ---------------------------------------------------------
        $display("[%0t] Puszczenie klawisza 'A' (0xF0, 0x1C)", $time);
        send_ps2_byte(8'hF0);
        send_ps2_byte(8'h1C);

        // Czekamy na vsync, pozycja xpos nie powinna się już zmieniać
        #2500000;

        // ---------------------------------------------------------
        // TEST 3: Wciśnięcie i trzymanie klawisza 'D' (Prawo)
        // Klawiatura wysyła kod 'Make' dla D: 0x23
        // ---------------------------------------------------------
        $display("[%0t] Wcisniecie klawisza 'D' (0x23)", $time);
        send_ps2_byte(8'h23);

        // Czekamy przez kilka impulsów vsync, aby zobaczyć ruch w prawo
        #3500000;

        // ---------------------------------------------------------
        // TEST 4: Puszczenie klawisza 'D'
        // Klawiatura wysyła kod 'Break': 0xF0, a potem 0x23
        // ---------------------------------------------------------
        $display("[%0t] Puszczenie klawisza 'D' (0xF0, 0x23)", $time);
        send_ps2_byte(8'hF0);
        send_ps2_byte(8'h23);

        #2500000;

        $display("Koniec symulacji.");
        $finish;
    end

    // Monitorowanie zmiany pozycji X i wyświetlanie ich w konsoli
    always @(xpos) begin
        if (rst_n) // Ignorujemy zmiany podczas resetu
            $display("[%0t] VSYNC: Nowa pozycja X = %0d", $time, xpos);
    end

endmodule