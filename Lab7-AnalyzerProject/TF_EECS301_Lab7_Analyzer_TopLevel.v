`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    6:12:00 04/09/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #7 Project
// Module Name:    TF_EECS301_Lab7_Analyzer_TopLevel
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    EECS301 Lab7 Analyzer TopLevel Testbench
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module TF_EECS301_Lab7_Analyzer_TopLevel();

	//
	// Clock Emulation
	//
	reg CLOCK_50;
	
	initial
	begin
		CLOCK_50 <= 1'b0;
		forever #10 CLOCK_50 <= ~CLOCK_50;
	end
	
	
	//
	// Top Level Module Under Test
	//
	wire [9:0] LEDR;
	wire [9:0] SW = { 5'h01, 5'h01 };
	wire [0:0] KEY = 1'b0;
	wire       FPGA_I2C_SCLK;
	wire       FPGA_I2C_SDAT;
	wire       AUD_XCK;
	wire       AUD_BCLK;
	wire       AUD_DACLRCK;
	wire       AUD_DACDAT;
	wire       AUD_ADCLRCK;
	wire       AUD_ADCDAT = AUD_DACDAT;
	wire [7:0] LCD_R;
	wire [7:0] LCD_G;
	wire [7:0] LCD_B;
	wire       LCD_CK;
	wire       LCD_DISP;
	wire       LCD_HSYNC;
	wire       LCD_VSYNC;
	
	EECS301_Lab7_Analyzer_TopLevel
	#(
		.SIM_PATH( "../../../Lab7-Project-Solution-Generator/" ),
		.SW_DEBOUNCE_TIME( 1000 ),
		.WM8731_POWER_ON_DELAY( 1000 )
	)
	uut
	(
		// Clock Input Signals
		.CLOCK_50( CLOCK_50 ),

		// LED Status Signals
		.LEDR( LEDR ),

		// Switch Signals
		.SW( SW ),

		// Key Signals
		.KEY( KEY ),

		// I2C Bus Signals
		.FPGA_I2C_SCLK( FPGA_I2C_SCLK ),
		.FPGA_I2C_SDAT( FPGA_I2C_SDAT ),
		
		// Audio Codec Bus Signals
		.AUD_XCK( AUD_XCK ),
		.AUD_BCLK( AUD_BCLK ),
		.AUD_DACLRCK( AUD_DACLRCK ),
		.AUD_DACDAT( AUD_DACDAT ),
		.AUD_ADCLRCK( AUD_ADCLRCK ),
		.AUD_ADCDAT( AUD_ADCDAT ),

		// LCD Bus Signals (GPIO1)
		.LCD_R0( LCD_R[0] ),    // GPIO1_D1
		.LCD_R1( LCD_R[1] ),    // GPIO1_D3
		.LCD_R2( LCD_R[2] ),    // GPIO1_D4
		.LCD_R3( LCD_R[3] ),    // GPIO1_D5
		.LCD_R4( LCD_R[4] ),    // GPIO1_D6
		.LCD_R5( LCD_R[5] ),    // GPIO1_D7
		.LCD_R6( LCD_R[6] ),    // GPIO1_D8
		.LCD_R7( LCD_R[7] ),    // GPIO1_D9
		.LCD_G0( LCD_G[0] ),    // GPIO1_D10
		.LCD_G1( LCD_G[1] ),    // GPIO1_D11
		.LCD_G2( LCD_G[2] ),    // GPIO1_D12
		.LCD_G3( LCD_G[3] ),    // GPIO1_D13
		.LCD_G4( LCD_G[4] ),    // GPIO1_D14
		.LCD_G5( LCD_G[5] ),    // GPIO1_D15
		.LCD_G6( LCD_G[6] ),    // GPIO1_D17
		.LCD_G7( LCD_G[7] ),    // GPIO1_D19
		.LCD_B0( LCD_B[0] ),    // GPIO1_D20
		.LCD_B1( LCD_B[1] ),    // GPIO1_D21
		.LCD_B2( LCD_B[2] ),    // GPIO1_D22
		.LCD_B3( LCD_B[3] ),    // GPIO1_D23
		.LCD_B4( LCD_B[4] ),    // GPIO1_D24
		.LCD_B5( LCD_B[5] ),    // GPIO1_D25
		.LCD_B6( LCD_B[6] ),    // GPIO1_D26
		.LCD_B7( LCD_B[7] ),    // GPIO1_D27
		.LCD_CK( LCD_CK ),    // GPIO1_D28
		.LCD_DISP( LCD_DISP ),  // GPIO1_D29
		.LCD_HSYNC( LCD_HSYNC ), // GPIO1_D30
		.LCD_VSYNC( LCD_VSYNC )  // GPIO1_D31	
	);

	
	
	
	
	////////////////////////////////////////////////////////
	//
	// DAC Analog Output Emulation 
	//
	localparam DAC_DATA_WIDTH = 16;
	
	wire [DAC_DATA_WIDTH-1:0] dac_rchan_data;
	wire [DAC_DATA_WIDTH-1:0] dac_lchan_data;

	// Quick hack (TODO: add parser extract data from codec bus signals)
	//assign dac_rchan_data = uut.dac_rchan_data;
	//assign dac_lchan_data = uut.dac_lchan_data;
	
	// Debug Assignments
	assign dac_rchan_data = uut.audio_right_channel_mixer.dac_1k_output;
	assign dac_lchan_data = uut.dac_rchan_data;
	
	//
	// DAC Emulation
	//
	parameter real    DAC_FULL_SCALE = 4.0; // Voltage Full Scale (+/-2V)
	parameter integer DAC_RESOLUTION = DAC_DATA_WIDTH;  // DAC Resolution
	
	// Compute DAC LSB value
	parameter real DAC_LSB = DAC_FULL_SCALE / 2.0**DAC_RESOLUTION;
	
	
	real DAC_ANALOG_RCHAN_SIG;
	real DAC_ANALOG_LCHAN_SIG;

	always @*
	begin
	
		// Compute analog signal from two's comp DAC register

		DAC_ANALOG_RCHAN_SIG <= (dac_rchan_data[DAC_RESOLUTION-1] ? (~dac_rchan_data + 1'b1) * -1.0 : dac_rchan_data * 1.0) * DAC_LSB;

		DAC_ANALOG_LCHAN_SIG <= (dac_lchan_data[DAC_RESOLUTION-1] ? (~dac_lchan_data + 1'b1) * -1.0 : dac_lchan_data * 1.0) * DAC_LSB;
		
	end
		
endmodule
