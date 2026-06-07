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

    logic wait_for_release;

    logic game_over_prev;
    wire  game_over_edge = game_over_flag && !game_over_prev;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= STATE_MENU;
            wait_for_release <= 1'b0;
            game_over_prev   <= 1'b0;
        end else begin
            game_over_prev <= game_over_flag;

            if (wait_for_release) begin
                if (!launch_game) begin
                    wait_for_release <= 1'b0;
                end
            end
            else begin

            case (current_state)
                STATE_MENU: begin
                    if (launch_game) begin
                        current_state <= STATE_GRA;
                        wait_for_release <= 1'b1;
                    end
                end
                
                STATE_GRA: begin
                    if (game_over_flag) begin
                        current_state <= STATE_GAMEOVER;
                        
                        if (launch_game) begin
                            wait_for_release <= 1'b1;
                        end
                    end
                end
                
                STATE_GAMEOVER: begin
                    if (launch_game) begin
                        current_state <= STATE_MENU;
                        wait_for_release <= 1'b1; 
                    end
                end
                
                default: begin
                    current_state <= STATE_MENU;
                end
                
                
            endcase
            end
        end
    end
endmodule