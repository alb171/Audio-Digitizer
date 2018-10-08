`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    11:21:00 04/10/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #7 Project
// Module Name:    Audio_Stream_Digitizer_Module
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    Audio Stream Digitizer Module
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module Audio_Stream_Digitizer_Module
#(
	parameter CLK_RATE_HZ = 18432000,  // Hz
	parameter DATA_WIDTH = 16,
	parameter FRAME_SAMPLES = 512
)
(
	// Control Signals
	input                   ENABLE,

	// Audio ACD Sample Data Signals
	input                   ADC_CHAN_TRIG,
	input  [DATA_WIDTH-1:0] ADC_CHAN_DATA,
	
	// FFT Frame Source Signals
	input                   FRAME_READY,
	output                  FRAME_VALID,
	output                  FRAME_START,
	output                  FRAME_END,
	output [DATA_WIDTH-1:0] FRAME_DATA,
	
	// System Signals
	input CLK,
	input RESET
);


	//
	// Digitizer Data Buffer
	//
	wire                  buffer_ready;
	wire                  buffer_read;
	wire [DATA_WIDTH-1:0] buffer_data;
	
	Audio_Stream_Digitizer_Sample_Buffer
	#(
		.DATA_WIDTH( DATA_WIDTH ),
		.FRAME_SIZE( FRAME_SAMPLES ),
		.BUFFER_SIZE( FRAME_SAMPLES * 2 )
	)
	sample_buffer
	(
		// Sample Control Signals
		.BUFFER_ENABLE( ENABLE ),
		.SAMPLE_TRIG( ADC_CHAN_TRIG ),
		.SAMPLE_DATA( ADC_CHAN_DATA ),

		// Sample Read Port Signals
		.BUFFER_READY( buffer_ready ),
		.BUFFER_READ( buffer_read ),
		.BUFFER_DATA( buffer_data ),

		// System Signals
		.CLK( CLK ),
		.RESET( RESET )
	);

	
	//
	// FFT Frame Output Controller
	//
	Audio_Stream_Digitizer_FFT_Framer
	#(
		.DATA_WIDTH( DATA_WIDTH ),
		.FRAME_SAMPLES( FRAME_SAMPLES )
	)
	sample_framer
	(
		// Digitizer Sample Buffer Signals
		.BUFFER_READY( buffer_ready ),
		.BUFFER_READ( buffer_read ),
		.BUFFER_DATA( buffer_data ),
		
		// Frame Buffer Signals
		.FRAME_READY( FRAME_READY ),
		.FRAME_VALID( FRAME_VALID ),
		.FRAME_START( FRAME_START ),
		.FRAME_END( FRAME_END ),
		.FRAME_DATA( FRAME_DATA ),

		// System Signals
		.CLK( CLK ),
		.RESET( RESET )
	);

endmodule
