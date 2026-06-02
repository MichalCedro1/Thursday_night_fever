module highscore_board (
    input  logic clk,
    input  logic rst_n,
    input  logic game_over_sig,
    input  logic [3:0] score_ones,
    input  logic [3:0] score_tens,
    input  logic [3:0] score_hunds,
    input  logic show_board,
    vga_if.in  vga_in,
    vga_if.out vga_out
);

    logic [11:0] top1, top2, top3;
    logic [11:0] current_score;
    logic prev_game_over;

    assign current_score = {score_hunds, score_tens, score_ones};

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            top1 <= '0; top2 <= '0; top3 <= '0;
            prev_game_over <= 0;
        end else begin
            prev_game_over <= game_over_sig;
            if (game_over_sig && !prev_game_over) begin
                if (current_score > top1) begin
                    top1 <= current_score; top2 <= top1; top3 <= top2;
                end else if (current_score > top2) begin
                    top2 <= current_score; top3 <= top2;
                end else if (current_score > top3) begin
                    top3 <= current_score;
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