module highscore_board (
    input  logic clk,
    input  logic rst_n,
    
    input  logic [3:0] score_ones,
    input  logic [3:0] score_tens,
    input  logic [3:0] score_hunds,
    
    input  logic [3:0] opp_score_ones,
    input  logic [3:0] opp_score_tens,
    input  logic [3:0] opp_score_hunds,
    
    input  logic show_board,
    vga_if.in  vga_in,
    vga_if.out vga_out
);

    logic [11:0] top1, top2, top3;
    logic [11:0] next_t1, next_t2, next_t3; // Nowe sygnały do obliczania kolejnego stanu
    logic [11:0] current_score, opp_current_score;
    logic [11:0] s_max, s_min;
    logic prev_show_board;

    assign current_score = {score_hunds, score_tens, score_ones};
    assign opp_current_score = {opp_score_hunds, opp_score_tens, opp_score_ones};

    assign s_max = (current_score > opp_current_score) ? current_score : opp_current_score;
    assign s_min = (current_score > opp_current_score) ? opp_current_score : current_score;

    // --- LOGIKA UNIKALNOŚCI ---
    logic valid_max, valid_min;
    
    // valid_max: Czy s_max jest unikalne (nie ma go w top3) i większe od zera?
    assign valid_max = (s_max > 0) && (s_max != top1) && (s_max != top2) && (s_max != top3);
    
    // valid_min: Czy s_min jest unikalne, większe od zera i co najważniejsze: RÓŻNE od s_max?
    assign valid_min = (s_min > 0) && (s_min != top1) && (s_min != top2) && (s_min != top3) && (s_min != s_max);

    // --- BLOK KOMBINACYJNY (Wyliczanie nowych wyników) ---
    always_comb begin
        // Domyślnie wartości pozostają bez zmian
        next_t1 = top1;
        next_t2 = top2;
        next_t3 = top3;

        // 1. Sprawdzamy, czy s_max trafia na podium
        if (valid_max) begin
            if (s_max > top1) begin
                next_t1 = s_max;
                next_t2 = top1;
                next_t3 = top2;
            end else if (s_max > top2) begin
                next_t2 = s_max;
                next_t3 = top2;
            end else if (s_max > top3) begin
                next_t3 = s_max;
            end
        end

        // 2. Sprawdzamy, czy s_min trafia na podium
        // UWAGA: Używamy już next_t1, next_t2, next_t3, bo s_max mogło przesunąć wyniki!
        if (valid_min) begin
            if (s_min > next_t1) begin
                next_t3 = next_t2;
                next_t2 = next_t1;
                next_t1 = s_min;
            end else if (s_min > next_t2) begin
                next_t3 = next_t2;
                next_t2 = s_min;
            end else if (s_min > next_t3) begin
                next_t3 = s_min;
            end
        end
    end

    // --- BLOK SEKWENCYJNY (Zapis do rejestrów) ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            top1 <= '0; 
            top2 <= '0; 
            top3 <= '0;
            prev_show_board <= 1'b0;
        end else begin
            prev_show_board <= show_board;

            // Zaktualizuj tablicę przy zboczu narastającym show_board
            if (show_board && !prev_show_board) begin
                top1 <= next_t1;
                top2 <= next_t2;
                top3 <= next_t3;
            end
        end
    end

    // --- WYŚWIETLANIE VGA (Bez zmian) ---
    vga_if vga_header();
    vga_if vga_t1();
    vga_if vga_t2();

    draw_text_line #( .X_POS(432), .Y_POS(350), .TEXT_LEN(10), .TEXT_CONTENT("HIGHSCORES"), .SCALE(2) ) draw_header (
        .clk(clk), .rst_n(rst_n), .enable(show_board), .color(12'hFF0),
        .vga_in(vga_in), .vga_out(vga_header)
    );

    draw_score #( .X_POS(504), .Y_POS(448) ) draw_t1 (
        .clk(clk), .rst_n(rst_n), .game_active(show_board),
        .score_ones(top1[3:0]), .score_tens(top1[7:4]), .score_hunds(top1[11:8]),
        .text_color(12'hFF0), .vga_in(vga_header), .vga_out(vga_t1)
    );

    draw_score #( .X_POS(504), .Y_POS(480) ) draw_t2 (
        .clk(clk), .rst_n(rst_n), .game_active(show_board),
        .score_ones(top2[3:0]), .score_tens(top2[7:4]), .score_hunds(top2[11:8]),
        .text_color(12'hCCC), .vga_in(vga_t1), .vga_out(vga_t2)
    );

    draw_score #( .X_POS(504), .Y_POS(512) ) draw_t3 (
        .clk(clk), .rst_n(rst_n), .game_active(show_board),
        .score_ones(top3[3:0]), .score_tens(top3[7:4]), .score_hunds(top3[11:8]),
        .text_color(12'hD73), .vga_in(vga_t2), .vga_out(vga_out)
    );

endmodule
/*
module highscore_board (
    input  logic clk,
    input  logic rst_n,
    
    input  logic [3:0] score_ones,
    input  logic [3:0] score_tens,
    input  logic [3:0] score_hunds,
    
    input  logic [3:0] opp_score_ones,
    input  logic [3:0] opp_score_tens,
    input  logic [3:0] opp_score_hunds,
    
    input  logic show_board,
    vga_if.in  vga_in,
    vga_if.out vga_out
);

    logic [11:0] top1, top2, top3;
    logic [11:0] current_score, opp_current_score;
    logic [11:0] s_max, s_min;
    logic prev_show_board;

    assign current_score = {score_hunds, score_tens, score_ones};
    assign opp_current_score = {opp_score_hunds, opp_score_tens, opp_score_ones};

    assign s_max = (current_score > opp_current_score) ? current_score : opp_current_score;
    assign s_min = (current_score > opp_current_score) ? opp_current_score : current_score;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            top1 <= '0; top2 <= '0; top3 <= '0;
            prev_show_board <= 1'b0;
        end else begin
            prev_show_board <= show_board;

            if (show_board && !prev_show_board) begin
                if (s_max > top1) begin
                    top1 <= s_max;
                    if (s_min > top1) begin
                        top2 <= s_min;
                        top3 <= top1;
                    end else begin
                        top2 <= top1;
                        top3 <= (s_min > top2) ? s_min : top2;
                    end
                end else if (s_max > top2) begin
                    top2 <= s_max;
                    top3 <= (s_min > top2) ? s_min : top2;
                end else if (s_max > top3) begin
                    top3 <= s_max;
                end
            end
        end
    end

    vga_if vga_header();
    vga_if vga_t1();
    vga_if vga_t2();

    draw_text_line #( .X_POS(432), .Y_POS(350), .TEXT_LEN(10), .TEXT_CONTENT("HIGHSCORES"), .SCALE(2) ) draw_header (
        .clk(clk), .rst_n(rst_n), .enable(show_board), .color(12'hFF0),
        .vga_in(vga_in), .vga_out(vga_header)
    );

    draw_score #( .X_POS(504), .Y_POS(448) ) draw_t1 (
        .clk(clk), .rst_n(rst_n), .game_active(show_board),
        .score_ones(top1[3:0]), .score_tens(top1[7:4]), .score_hunds(top1[11:8]),
        .text_color(12'hFF0), .vga_in(vga_header), .vga_out(vga_t1)
    );

    draw_score #( .X_POS(504), .Y_POS(480) ) draw_t2 (
        .clk(clk), .rst_n(rst_n), .game_active(show_board),
        .score_ones(top2[3:0]), .score_tens(top2[7:4]), .score_hunds(top2[11:8]),
        .text_color(12'hCCC), .vga_in(vga_t1), .vga_out(vga_t2)
    );

    draw_score #( .X_POS(504), .Y_POS(512) ) draw_t3 (
        .clk(clk), .rst_n(rst_n), .game_active(show_board),
        .score_ones(top3[3:0]), .score_tens(top3[7:4]), .score_hunds(top3[11:8]),
        .text_color(12'hD73), .vga_in(vga_t2), .vga_out(vga_out)
    );

endmodule
*/