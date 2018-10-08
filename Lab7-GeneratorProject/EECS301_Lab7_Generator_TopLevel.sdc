## Generated SDC file "EECS301_Lab7_Generator_TopLevel.sdc"

## Copyright (C) 1991-2015 Altera Corporation. All rights reserved.
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, the Altera Quartus II License Agreement,
## the Altera MegaCore Function License Agreement, or other 
## applicable license agreement, including, without limitation, 
## that your use is for the sole purpose of programming logic 
## devices manufactured by Altera and sold by Altera or its 
## authorized distributors.  Please refer to the applicable 
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 15.0.2 Build 153 07/15/2015 SJ Web Edition"

## DATE    "Sun Apr 09 14:11:07 2017"

##
## DEVICE  "5CSEMA5F31C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {CLOCK_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK_50}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {sys_clk_manager|aud_clk_pll|audiocodec_clock_generator_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]} -source [get_pins {sys_clk_manager|aud_clk_pll|audiocodec_clock_generator_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50.000 -multiply_by 519 -divide_by 64 -master_clock {CLOCK_50} [get_pins {sys_clk_manager|aud_clk_pll|audiocodec_clock_generator_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]}] 
create_generated_clock -name {aud_clk} -source [get_pins {sys_clk_manager|aud_clk_pll|audiocodec_clock_generator_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|vco0ph[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 22 -master_clock {sys_clk_manager|aud_clk_pll|audiocodec_clock_generator_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]} [get_pins {sys_clk_manager|aud_clk_pll|audiocodec_clock_generator_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 
create_generated_clock -name {sys_clk_manager|lcd_clk_pll|lcd_clock_generator_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]} -source [get_pins {sys_clk_manager|lcd_clk_pll|lcd_clock_generator_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50.000 -multiply_by 36 -divide_by 5 -master_clock {CLOCK_50} [get_pins {sys_clk_manager|lcd_clk_pll|lcd_clock_generator_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]}] 
create_generated_clock -name {lcd_clk} -source [get_pins {sys_clk_manager|lcd_clk_pll|lcd_clock_generator_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|vco0ph[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 20 -master_clock {sys_clk_manager|lcd_clk_pll|lcd_clock_generator_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]} [get_pins {sys_clk_manager|lcd_clk_pll|lcd_clock_generator_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {lcd_clk}] -rise_to [get_clocks {lcd_clk}] -setup 0.120  
set_clock_uncertainty -rise_from [get_clocks {lcd_clk}] -rise_to [get_clocks {lcd_clk}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {lcd_clk}] -fall_to [get_clocks {lcd_clk}] -setup 0.120  
set_clock_uncertainty -rise_from [get_clocks {lcd_clk}] -fall_to [get_clocks {lcd_clk}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {lcd_clk}] -rise_to [get_clocks {lcd_clk}] -setup 0.120  
set_clock_uncertainty -fall_from [get_clocks {lcd_clk}] -rise_to [get_clocks {lcd_clk}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {lcd_clk}] -fall_to [get_clocks {lcd_clk}] -setup 0.120  
set_clock_uncertainty -fall_from [get_clocks {lcd_clk}] -fall_to [get_clocks {lcd_clk}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {aud_clk}] -rise_to [get_clocks {aud_clk}] -setup 0.200  
set_clock_uncertainty -rise_from [get_clocks {aud_clk}] -rise_to [get_clocks {aud_clk}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {aud_clk}] -fall_to [get_clocks {aud_clk}] -setup 0.200  
set_clock_uncertainty -rise_from [get_clocks {aud_clk}] -fall_to [get_clocks {aud_clk}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {aud_clk}] -rise_to [get_clocks {aud_clk}] -setup 0.200  
set_clock_uncertainty -fall_from [get_clocks {aud_clk}] -rise_to [get_clocks {aud_clk}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {aud_clk}] -fall_to [get_clocks {aud_clk}] -setup 0.200  
set_clock_uncertainty -fall_from [get_clocks {aud_clk}] -fall_to [get_clocks {aud_clk}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {CLOCK_50}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {CLOCK_50}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {CLOCK_50}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {CLOCK_50}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {CLOCK_50}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {CLOCK_50}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {CLOCK_50}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {CLOCK_50}] -hold 0.060  


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {AUD_ADCDAT}]
set_input_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {FPGA_I2C_SDAT}]
set_input_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {SW[0]}]
set_input_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {SW[1]}]
set_input_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {SW[2]}]
set_input_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {SW[3]}]
set_input_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {SW[4]}]
set_input_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {SW[5]}]
set_input_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {SW[6]}]
set_input_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {SW[7]}]
set_input_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {SW[8]}]
set_input_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {SW[9]}]
set_input_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {KEY[0]}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {AUD_ADCLRCK}]
set_output_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {AUD_BCLK}]
set_output_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {AUD_DACDAT}]
set_output_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {AUD_DACLRCK}]
set_output_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {AUD_XCK}]
set_output_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {FPGA_I2C_SCLK}]
set_output_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {FPGA_I2C_SDAT}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_B0}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_B1}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_B2}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_B3}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_B4}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_B5}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_B6}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_B7}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_CK}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_DISP}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_G0}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_G1}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_G2}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_G3}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_G4}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_G5}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_G6}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_G7}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_HSYNC}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_R0}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_R1}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_R2}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_R3}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_R4}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_R5}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_R6}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_R7}]
set_output_delay -add_delay  -clock [get_clocks {lcd_clk}]  10.000 [get_ports {LCD_VSYNC}]
set_output_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {LEDR[0]}]
set_output_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {LEDR[1]}]
set_output_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {LEDR[2]}]
set_output_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {LEDR[3]}]
set_output_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {LEDR[4]}]
set_output_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {LEDR[5]}]
set_output_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {LEDR[6]}]
set_output_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {LEDR[7]}]
set_output_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {LEDR[8]}]
set_output_delay -add_delay  -clock [get_clocks {aud_clk}]  10.000 [get_ports {LEDR[9]}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

