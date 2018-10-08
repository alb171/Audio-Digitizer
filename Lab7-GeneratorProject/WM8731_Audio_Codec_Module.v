`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    12:36:00 02/18/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #4 Project
// Module Name:    WM8731_Audio_Codec_Module
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    WM8731 Audio Codec Module
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module WM8731_Audio_Codec_Module
#(
	parameter CLK_RATE_HZ = 50000000,  // Hz
	parameter I2C_BUS_RATE = 400, // kHz
	parameter DAC_DATA_WIDTH = 16,
	parameter POWER_ON_DELAY = 1000000 // ns
)
(
	// DAC Channel Data Signals
	input  [DAC_DATA_WIDTH-1:0] DAC_RCHAN_DATA,
	input  [DAC_DATA_WIDTH-1:0] DAC_LCHAN_DATA,
	output                      DAC_RCHAN_TRIG,
	output                      DAC_LCHAN_TRIG,
	
	// ADC Data Channels
	output                      ADC_RCHAN_READY,
	output [DAC_DATA_WIDTH-1:0] ADC_RCHAN_DATA,
	output                      ADC_LCHAN_READY,
	output [DAC_DATA_WIDTH-1:0] ADC_LCHAN_DATA,
	
	// WM8731 I2C Configuration Bus Signals
	output I2C_SCLK,
	inout  I2C_SDAT,
	
	// WM8731 Audio Bus Signals
	output AUD_XCK,
	output AUD_BCLK,
	output AUD_DACLRCK,
	output AUD_DACDAT,
	output AUD_ADCLRCK,
	input  AUD_ADCDAT,
	
	// Logic Analyzer Debug Signals
	output LAD_I2C_SCLK,
	output LAD_I2C_SDAT,
	output LAD_AUD_BCLK,
	output LAD_AUD_DACLRCK,
	output LAD_AUD_DACDAT,
	output LAD_AUD_ADCLRCK,
	output LAD_AUD_ADCDAT,
	
	// System Signals
	input CLK,
	input RESET
);
	
	
	//
	// WM8731 Audio Codec Startup Configuration 
	//
	wire  config_complete;

	WM8731_Audio_Codec_Configurator
	#(
		.CLK_RATE_HZ( CLK_RATE_HZ ),
		.I2C_BUS_RATE( I2C_BUS_RATE ),
		.POWER_ON_DELAY( POWER_ON_DELAY )
	)
	audio_codec_configurator
	(
		// Status Signals
		.CONFIG_COMPLETE( config_complete ),
		
		// WM8731 I2C Configuration Bus Signals
		.I2C_SCLK( I2C_SCLK ),
		.I2C_SDAT( I2C_SDAT ),

		// Logic Analyzer Debug Signals
		.LAD_I2C_SCLK( LAD_I2C_SCLK ),
		.LAD_I2C_SDAT( LAD_I2C_SDAT ),
	
		// System Signals
		.CLK( CLK ),
		.RESET( RESET )
	);
	
	
	//
	// WM8731 Reference Clock
	//
	assign AUD_XCK = CLK;
	
	
	//
	// WM8731 Audio Codec Transceiver
	//
	WM8731_Audio_Codec_Transceiver	
	#(
		.CLK_RATE_HZ( CLK_RATE_HZ ),
		.SAMPLE_RATE( 48000 ), // Hz
		.SAMPLE_BITS( DAC_DATA_WIDTH ),
		.SAMPLE_CHANS( 2 )
	)
	audio_dac
	(
		// Control Signals
		.ENABLE( config_complete ),
		
		// DAC Data Channels
		.DAC_RCHAN_DATA( DAC_RCHAN_DATA ),
		.DAC_LCHAN_DATA( DAC_LCHAN_DATA ),
		.DAC_RCHAN_TRIG( DAC_RCHAN_TRIG ),
		.DAC_LCHAN_TRIG( DAC_LCHAN_TRIG ),
		
		// ADC Data Channels
		.ADC_RCHAN_READY( ADC_RCHAN_READY ),
		.ADC_RCHAN_DATA( ADC_RCHAN_DATA ),
		.ADC_LCHAN_READY( ADC_LCHAN_READY ),
		.ADC_LCHAN_DATA( ADC_LCHAN_DATA ),	
		
		// DAC Codec Signals
		.AUD_BCLK( AUD_BCLK ),
		.AUD_DACLRCK( AUD_DACLRCK ),
		.AUD_DACDAT( AUD_DACDAT ),
		.AUD_ADCLRCK( AUD_ADCLRCK ),
		.AUD_ADCDAT( AUD_ADCDAT ),
		
		// Logic Analyzer Debug Signals
		.LAD_AUD_BCLK( LAD_AUD_BCLK ),
		.LAD_AUD_DACLRCK( LAD_AUD_DACLRCK ),
		.LAD_AUD_DACDAT( LAD_AUD_DACDAT ),
		.LAD_AUD_ADCLRCK( LAD_AUD_ADCLRCK ),
		.LAD_AUD_ADCDAT( LAD_AUD_ADCDAT ),
		
		// System Signals
		.CLK( CLK ),
		.RESET( RESET )
	);

endmodule
