module game_fsm 
    import vga_pkg::*;
(
    input  logic clk,
    input  logic rst_n,
    input  logic mouse_left_click,
    input  logic launch_game,
    input  logic game_over_flag,  
    input  logic [11:0] mouse_x,
    input  logic [11:0] mouse_y,
    output game_state_t current_state
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= STATE_MENU;
        end else begin
            case (current_state)
                STATE_MENU: begin
                    if (launch_game) begin
                        current_state <= STATE_GRA;
                    end
                end
                STATE_GRA: begin
                    if (game_over_flag) begin
                        current_state <= STATE_GAMEOVER;
                    end
                end
                STATE_GAMEOVER: begin
                    if (launch_game) 
                        current_state <= STATE_MENU;
                end
                
                default: current_state <= STATE_MENU;
            endcase
        end
    end
endmodule