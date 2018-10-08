`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    11:21:00 04/10/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #7 Project
// Module Name:    Digitizer_Module
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    Digitizer Module
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module Digitizer_Module
#(
	parameter CLK_RATE_HZ = 18432000,  // Hz
	parameter SAMPLE_RATE_HZ = 48000,  // Hz
	parameter SAMPLE_DATA_WIDTH = 16,
	parameter SCALED_DATA_WIDTH = 9,
	parameter FRAME_SAMPLES = 480,
	parameter PRETRIG_SAMPLES = 240
)
(
	// Control Signals
	input DIGITIZER_ENABLE,
	
	// DAC Sample Data Signals
	input  [SAMPLE_DATA_WIDTH-1:0] DAC_LCHAN_DATA,
	input  [SAMPLE_DATA_WIDTH-1:0] DAC_RCHAN_DATA,
	
	// LCD Waveform Buffer Signals
	output                         LCD_FRAME_START,
	output                         LCD_FRAME_DONE,
	output                         LCD_DATA_WR,
	output [SCALED_DATA_WIDTH-1:0] LCD_LCHAN_DATA,
	output [SCALED_DATA_WIDTH-1:0] LCD_RCHAN_DATA,

	// System Signals
	input CLK,
	input RESET
);


	//
	// Convert Waveform Data into LCD Scaled Data
	//
	wire [SCALED_DATA_WIDTH-1:0] scaled_data_lchan;
	wire [SCALED_DATA_WIDTH-1:0] scaled_data_rchan;
	
	LCD_Sample_Data_Scaler
	#(
		.SAMPLE_WIDTH( SAMPLE_DATA_WIDTH ),
		.SCALED_WIDTH( SCALED_DATA_WIDTH )
	)
	sample_scaler_lchan
	(
		// Input Signals
		.SAMPLE_DATA( DAC_LCHAN_DATA ),
		
		// Output Signals
		.LCD_SCALED_DATA( scaled_data_lchan )
	);

	LCD_Sample_Data_Scaler
	#(
		.SAMPLE_WIDTH( SAMPLE_DATA_WIDTH ),
		.SCALED_WIDTH( SCALED_DATA_WIDTH )
	)
	sample_scaler_rchan
	(
		// Input Signals
		.SAMPLE_DATA( DAC_RCHAN_DATA ),
		
		// Output Signals
		.LCD_SCALED_DATA( scaled_data_rchan )
	);

	
	//
	// Digitizer Frame Rate Timer
	//
	wire frame_trig;

	LCD_Sample_Timer
	#(
		.CLK_RATE_HZ( CLK_RATE_HZ ),
		.SAMPLE_RATE_HZ( 500000000 )
	)
	frame_rate_timer
	(
		// Timer Signals
		.TIMER_TICK( frame_trig ),
		
		// System Signals
		.CLK( CLK )
	);


	//
	// Digitizer Sample Rate Timer
	//
	wire sample_trig;

	LCD_Sample_Timer
	#(
		.CLK_RATE_HZ( CLK_RATE_HZ ),
		.SAMPLE_RATE_HZ( SAMPLE_RATE_HZ )
	)
	sample_rate_timer
	(
		// Timer Signals
		.TIMER_TICK( sample_trig ),
		
		// System Signals
		.CLK( CLK )
	);


	//
	// Digitizer Zero Cross Detector
	//	
	wire dac_rchan_zc;
	
	Digitizer_ZeroCross_Detector
	#(
		.DATA_WIDTH( SAMPLE_DATA_WIDTH )
	)
	trigger_zc_detector
	(
		// Sample Data Signals
		.SAMPLE_TRIG( sample_trig ),
		.SAMPLE_DATA( DAC_RCHAN_DATA ),
		.SAMPLE_ZC( dac_rchan_zc ),
		
		// System Signals
		.CLK( CLK )
	);
	
	
	//
	// Digitizer Trigger Controller
	//	
	wire sample_buffer_enable;
	wire sample_buffer_pretrig;
	wire sample_buffer_trigged;
	wire frame_update_start;
	wire frame_update_done;
	
	Digitizer_Trigger_Controller
	#(
		.CLK_RATE_HZ( CLK_RATE_HZ ),
		.PRETRIG_SAMPLES( PRETRIG_SAMPLES ),
		.FRAME_SAMPLES( FRAME_SAMPLES )
	)
	trigger_controller
	(
		// Digitizer Control Signals
		.FRAME_ARM( DIGITIZER_ENABLE /* | frame_trig */ ),
		.FRAME_TRIG( dac_rchan_zc ),
		.SAMPLE_TRIG( sample_trig ),
		
		// Data Buffer Signals
		.SAMPLE_BUFFER_ENABLE( sample_buffer_enable ),
		.SAMPLE_BUFFER_PRETRIG( sample_buffer_pretrig ),
		.SAMPLE_BUFFER_TRIGGED( sample_buffer_trigged ),

		// LCD Frame Update Signals
		.LCD_UPDATE_START( frame_update_start ),
		.LCD_UPDATE_DONE( frame_update_done ),
		
		// System Signals
		.CLK( CLK ),
		.RESET( RESET )
	);
	
	
	//
	// Digitizer Data Buffer
	//
	wire                         frame_data_read;
	wire [SCALED_DATA_WIDTH-1:0] frame_data_lchan;
	wire [SCALED_DATA_WIDTH-1:0] frame_data_rchan;
	
	Digitizer_Sample_Buffer
	#(
		.DATA_WIDTH( SCALED_DATA_WIDTH * 2 ),
		.BUFFER_SIZE( FRAME_SAMPLES )
	)
	digitizer_sample_buffer
	(
		// Sample Control Signals
		.BUFFER_ENABLE( sample_buffer_enable ),
		.BUFFER_PRETRIG( sample_buffer_pretrig ),
		.BUFFER_TRIGGED( sample_buffer_trigged ),
		.SAMPLE_TRIG( sample_trig ),
		.SAMPLE_DATA( { scaled_data_lchan, scaled_data_rchan } ),

		// Sample Read Port Signals
		.BUFFER_READ( frame_data_read ),
		.BUFFER_DATA( { frame_data_lchan, frame_data_rchan } ),

		// System Signals
		.CLK( CLK ),
		.RESET( RESET )
	);
	
	
	//
	// Captured Frame Output Controller
	//
	Digitizer_LCD_Frame_Updater
	#(
		.DATA_WIDTH( SCALED_DATA_WIDTH ),
		.FRAME_SAMPLES( FRAME_SAMPLES )
	)
	lcd_frame_updater
	(
		// Frame Update Control Signals
		.FRAME_UPDATE_START( frame_update_start ),
		.FRAME_UPDATE_DONE( frame_update_done ),

		// Digitizer Sample Buffer Signals
		.BUFFER_DATA_NEXT( frame_data_read ),
		.BUFFER_LCHAN_DATA( frame_data_lchan ),
		.BUFFER_RCHAN_DATA( frame_data_rchan ),
		
		// LCD Frame Interface Signals
		.LCD_FRAME_START( LCD_FRAME_START ),
		.LCD_FRAME_DONE( LCD_FRAME_DONE ),
		.LCD_DATA_WR( LCD_DATA_WR ),
		.LCD_LCHAN_DATA( LCD_LCHAN_DATA ),
		.LCD_RCHAN_DATA( LCD_RCHAN_DATA ),

		// System Signals
		.CLK( CLK ),
		.RESET( RESET )
	);
	
endmodule
