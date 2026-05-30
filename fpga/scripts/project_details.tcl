# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Piotr Kaczmarczyk
#
# Description:
# Project detiles required for generate_bitstream.tcl
# Make sure that project_name, top_module and target are correct.
# Provide paths to all the files required for synthesis and implementation.
# Depending on the file type, it should be added in the corresponding section.
# If the project does not use files of some type, leave the corresponding section commented out.

#-----------------------------------------------------#
#                   Project details                   #
#-----------------------------------------------------#
# Project name                                  -- EDIT
set project_name vga_project

# Top module name                               -- EDIT
set top_module top_vga_basys3

# FPGA device
set target xc7a35tcpg236-1

#-----------------------------------------------------#
#                    Design sources                   #
#-----------------------------------------------------#
# Specify .xdc files location                   -- EDIT
set xdc_files {
    constraints/top_vga_basys3.xdc
}

# Specify SystemVerilog design files location   -- EDIT
set sv_files {
    ../rtl/common/vga_pkg.sv
    ../rtl/common/vga_if.sv
    ../rtl/video/vga_timing.sv
    ../rtl/control/keyboard_ctrl.sv
    ../rtl/video/draw_bg.sv
    ../rtl/video/draw_rect.sv 
    ../rtl/top_rtl/top_vga.sv
    ../rtl/video/draw_falling_block.sv
    ../rtl/control/falling_block_ctrl.sv
    ../rtl/video/draw_score.sv
    ../rtl/video/highscore_board.sv
    ../rtl/video/draw_text_line.sv
    ../rtl/communication/uart_rx.sv
    ../rtl/communication/uart_tx.sv
    ../rtl/control/multiplayer_ctrl.sv
    ../rtl/memory/font_rom.sv
    ../rtl/control/game_fsm.sv
    ../rtl/common/reset_sync.sv
    rtl/top_vga_basys3.sv
    
    ../music/rtl/music_if.sv
    ../music/rtl/music_controller.sv
    ../music/rtl/tone_generator.sv
    ../music/rtl/audio_pwm.sv

    ../music/rom/music_rom_melodia.sv
    ../music/rom/music_rom_bas.sv
}

# Specify Verilog design files location         -- EDIT
set verilog_files {
    ../fpga/clk_wiz_0_clk_wiz.v
    ../fpga/clk_wiz_0.v
}

# Specify VHDL design files location            -- EDIT
#set vhdl_files {
#    ../rtl/MouseCtl.vhd
#   ../rtl/Ps2Interface.vhd
#  ../rtl/MouseDisplay.vhd
# }

# Specify files for a memory initialization     -- EDIT
# set mem_files {
#    path/to/file.data
# }
