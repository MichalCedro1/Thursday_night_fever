module game_fsm 
    import vga_pkg::*;
(
    input  logic clk,
    input  logic rst_n,
    input  logic mouse_left_click,
    input  logic [11:0] mouse_x,
    input  logic [11:0] mouse_y,
    output game_state_t current_state
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= STATE_MENU;
        end else begin
            if (current_state == STATE_MENU) begin
                // Logika kliknięcia w przycisk START
                if (mouse_left_click && (mouse_x >= 300 && mouse_x <= 500) && 
                   (mouse_y >= 250 && mouse_y <= 350)) begin
                    current_state <= STATE_GRA;
                end
            end
        end
    end
endmodule