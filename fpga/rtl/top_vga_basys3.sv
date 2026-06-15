/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk
 *
 * Description:
 * Top level synthesizable module including the project top and all the FPGA-referred modules.
 */

 module top_vga_basys3 (
    input  wire clk,
    input  wire btnC,
    input  wire sw0,
    input  wire PS2Clk,
    input  wire PS2Data,
    output wire Vsync,
    output wire Hsync,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue,
    output wire JA1,
    
    input  wire uart_rx_pin,
    output wire uart_tx_pin,
    
    output wire speaker,
    output wire amp_en
);

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local variables and signals
     */

     wire clk_65MHz;   
     wire pclk_mirror;

    //(* KEEP = "TRUE" *)
    //(* ASYNC_REG = "TRUE" *)
    //logic [7:0] safe_start = 0;
    // For details on synthesis attributes used above, see AMD Xilinx UG 901:
    // https://docs.xilinx.com/r/en-US/ug901-vivado-synthesis/Synthesis-Attributes


    /**
     * Signals assignments
     */

    assign JA1 = pclk_mirror;


    /**
     * FPGA submodules placement
     */
/*
    IBUF clk_ibuf (
        .I(clk),
        .O(clk_in)
    );

    MMCME2_BASE #(
        .CLKIN1_PERIOD(10.000),
        .CLKFBOUT_MULT_F(10.000),
        .CLKOUT0_DIVIDE_F(25.000)
    ) clk_in_mmcme2 (
        .CLKIN1(clk_in),
        .CLKOUT0(clk_out),
        .CLKOUT0B(),
        .CLKOUT1(),
        .CLKOUT1B(),
        .CLKOUT2(),
        .CLKOUT2B(),
        .CLKOUT3(),
        .CLKOUT3B(),
        .CLKOUT4(),
        .CLKOUT5(),
        .CLKOUT6(),
        .CLKFBOUT(clk_fb),
        .CLKFBOUTB(),
        .CLKFBIN(clk_fb),
        .LOCKED(locked),
        .PWRDWN(1'b0),
        .RST(1'b0)
    );

    BUFH clk_out_bufh (
        .I(clk_out),
        .O(clk_ss)
    );

    always_ff @(posedge clk_ss)
        safe_start <= {safe_start[6:0],locked};

    BUFGCE #(
        .SIM_DEVICE("7SERIES")
    ) clk_out_bufgce (
        .I(clk_out),
        .CE(safe_start[7]),
        .O(pclk)
    );

    // Mirror pclk on a pin for use by the testbench;
    // not functionally required for this design to work.
*/

    clk_wiz_0 u_clk_wiz (
        .clk_in1 (clk),       
        .clk_out1(clk_65MHz),
        .clk_out2(clk_100MHz)  
    );
    
    ODDR pclk_oddr (
        .Q(pclk_mirror),
        .C(clk_65MHz),        
        .CE(1'b1),
        .D1(1'b1),
        .D2(1'b0),
        .R(1'b0),
        .S(1'b0)
    );


    /**
     * Project functional top module
     */
    wire [1:0] current_song_id;
    wire game_active;
    
    top_vga u_top_vga (
        .clk(clk_65MHz),     
        .rst_n(!btnC),
        .sw0(sw0),
        .PS2Clk(PS2Clk),
        .PS2Data(PS2Data),
        
        .uart_rx_pin(uart_rx_pin),
        .uart_tx_pin(uart_tx_pin),
        
        .r(vgaRed),
        .g(vgaGreen),
        .b(vgaBlue),
        .hs(Hsync),
        .vs(Vsync),
        .current_song_id(current_song_id),
        .game_active(game_active)
    );


    assign amp_en = 1'b1;

    logic [15:0] addr_1;
    logic [31:0] duration_1;
    logic [31:0] note_divider_1;

    logic [15:0] addr_2;
    logic [31:0] duration_2;
    logic [31:0] note_divider_2;

    logic spk1, spk2;

    music_controller u_ctrl_1 (
        .clk(clk_65MHz), 
        .rst_n(!btnC), 
        .enable(game_active), 
        .duration(duration_1), 
        .address(addr_1)
    );

    music_rom_melodia u_rom_1 (
        .address(addr_1),
        .duration(duration_1),
        .note_divider(note_divider_1)
    );

    tone_generator u_tone_1 (
        .clk(clk_65MHz), 
        .rst_n(!btnC), 
        .note_divider(note_divider_1), 
        .speaker(spk1)
    );

    music_controller u_ctrl_2 (
        .clk(clk_65MHz), 
        .rst_n(!btnC), 
        .enable(game_active), 
        .duration(duration_2), 
        .address(addr_2)
    );

    music_rom_bas u_rom_2 (
        .address(addr_2),
        .duration(duration_2),
        .note_divider(note_divider_2)
    );

    tone_generator u_tone_2 (
        .clk(clk_65MHz), 
        .rst_n(!btnC), 
        .note_divider(note_divider_2), 
        .speaker(spk2)
    );


    logic [1:0] raw_mix;
    logic [5:0] audio_mix;
    
    assign raw_mix = spk1 + spk2;
    assign audio_mix = raw_mix * 12;

    audio_pwm u_mixer (
        .clk(clk_65MHz),
        .rst_n(!btnC),
        .mix_in(audio_mix),
        .pwm_out(speaker)
    );

endmodule
