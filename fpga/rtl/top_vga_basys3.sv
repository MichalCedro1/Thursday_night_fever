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
        inout  wire PS2Clk,
        inout  wire PS2Data,
        output wire Vsync,
        output wire Hsync,
        output wire [3:0] vgaRed,
        output wire [3:0] vgaGreen,
        output wire [3:0] vgaBlue,
        output wire JA1,
        output wire speaker,
        output wire amp_en
    );

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local variables and signals
     */

   // wire clk_in, clk_fb, clk_ss, clk_out;
    wire locked;
    wire pclk;
    wire pclk_mirror;
    wire clk_100MHz;

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

    clk_wiz_0_clk_wiz u_clk_wiz (
        .clk(clk),              // Wejście głównego zegara z płytki
        .clk100MHz(clk_100MHz), // Wyjście zegara 100 MHz
        .clk40MHz(pclk),        // Wyjście zegara 40 MHz (podłączone bezpośrednio do pclk)
        .locked(locked)         // Wyjście statusu
    );
    
    ODDR pclk_oddr (
        .Q(pclk_mirror),
        .C(pclk),
        .CE(1'b1),
        .D1(1'b1),
        .D2(1'b0),
        .R(1'b0),
        .S(1'b0)
    );


    /**
     *  Project functional top module
     */

    top_vga u_top_vga (
        .clk(pclk),
        .rst_n(!btnC),
        .clk100MHz(clk_100MHz),
        .PS2Clk(PS2Clk),
        .PS2Data(PS2Data),
        .r(vgaRed),
        .g(vgaGreen),
        .b(vgaBlue),
        .hs(Hsync),
        .vs(Vsync)
    );

    //Polifonia

    assign amp_en = 1'b1;

    music_if m_if_1();
    music_if m_if_2();
    music_if m_if_3();
    music_if m_if_4();

    assign m_if_1.song_id = 2'b00;
    assign m_if_2.song_id = 2'b00;
    assign m_if_3.song_id = 2'b00;
    assign m_if_4.song_id = 2'b00;

    logic spk1, spk2, spk3, spk4;

    music_rom_melodia u_rom_1 (.bus(m_if_1.rom));
    music_controller u_ctrl_1 (.clk(clk_100MHz), .rst_n(!btnC), .bus(m_if_1.controller));
    tone_generator u_tone_1 (.clk(clk_100MHz), .rst_n(!btnC), .bus(m_if_1.tone_gen), .speaker(spk1));

    music_rom_bas u_rom_2 (.bus(m_if_2.rom));
    music_controller u_ctrl_2 (.clk(clk_100MHz), .rst_n(!btnC), .bus(m_if_2.controller));
    tone_generator u_tone_2 (.clk(clk_100MHz), .rst_n(!btnC), .bus(m_if_2.tone_gen), .speaker(spk2));

    music_rom_tlo u_rom_3 (.bus(m_if_3.rom));
    music_controller u_ctrl_3 (.clk(clk_100MHz), .rst_n(!btnC), .bus(m_if_3.controller));
    tone_generator u_tone_3 (.clk(clk_100MHz), .rst_n(!btnC), .bus(m_if_3.tone_gen), .speaker(spk3));

    music_rom_gitara1 u_rom_4 (.bus(m_if_4.rom));
    music_controller u_ctrl_4 (.clk(clk_100MHz), .rst_n(!btnC), .bus(m_if_4.controller));
    tone_generator u_tone_4 (.clk(clk_100MHz), .rst_n(!btnC), .bus(m_if_4.tone_gen), .speaker(spk4));

    logic [2:0] audio_mix;

    assign audio_mix = spk1 + spk2 + spk3 + spk4;

    audio_pwm u_mixer (
        .clk(clk_100MHz),
        .rst_n(!btnC),
        .mix_in(audio_mix),
        .pwm_out(speaker)
    );

endmodule
