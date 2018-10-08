`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    11:21:00 04/10/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #7 Project
// Module Name:    Audio_Stream_Spectrum_Analyzer
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    Audio Stream Digitizer Module
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module Audio_Stream_Spectrum_Analyzer
#(
	parameter CLK_RATE_HZ = 18432000,  // Hz
	parameter DATA_WIDTH = 16,
	parameter SCALED_WIDTH = 10,
	parameter FRAME_SAMPLES = 512
)
(
	// Control Signals
	input                     ENABLE,

	// Audio ACD Sample Data Signals
	input                     ADC_CHAN_TRIG,
	input    [DATA_WIDTH-1:0] ADC_CHAN_DATA,
	
	// Display Buffer Signals
	output                    LCD_FRAME_VALID,
	output                    LCD_FRAME_START,
	output                    LCD_FRAME_END,
	output [SCALED_WIDTH-1:0] LCD_FRAME_DATA,
	
	// System Signals
	input CLK,
	input RESET
);

	//
	// Audio Stream Digitizer
	//
	wire                  frame_ready;
	wire                  frame_valid;
	wire                  frame_start;
	wire                  frame_end;
	wire [DATA_WIDTH-1:0] frame_data;
	
	Audio_Stream_Digitizer_Module
	#(
		.CLK_RATE_HZ( CLK_RATE_HZ ),
		.DATA_WIDTH( DATA_WIDTH ),
		.FRAME_SAMPLES( FRAME_SAMPLES )
	)
	audio_stream_digitizer
	(
		// Control Signals
		.ENABLE( ENABLE ),

		// Audio ACD Sample Data Signals
		.ADC_CHAN_TRIG( ADC_CHAN_TRIG ),
		.ADC_CHAN_DATA( ADC_CHAN_DATA ),
		
		// FFT Frame Source Signals
		.FRAME_READY( frame_ready ),
		.FRAME_VALID( frame_valid ),
		.FRAME_START( frame_start ),
		.FRAME_END( frame_end ),
		.FRAME_DATA( frame_data ),
		
		// System Signals
		.CLK( CLK ),
		.RESET( RESET )
	);

	
	//
	// FFT Module
	//
	wire        fft_ready = 1'b1;
	wire        fft_valid;
	wire  [1:0] fft_error;
	wire        fft_sop;
	wire        fft_eop;
	wire [15:0] fft_data_real;
	wire [15:0] fft_data_imag;
	wire  [9:0] fft_fftpts_out;

	Audio_Stream_Digitizer_FFT audio_stream_fft
	(
		.clk( CLK ),
		.reset_n( ~RESET ),
		
		.sink_valid( frame_valid ),   //   sink.sink_valid
		.sink_ready( frame_ready ),   //       .sink_ready
		.sink_error( 2'h0 ),   //       .sink_error
		.sink_sop( frame_start ),     //       .sink_sop
		.sink_eop( frame_end ),     //       .sink_eop
		.sink_real( frame_data ),    //       .sink_real
		.sink_imag( 16'h0000 ),    //       .sink_imag
		.fftpts_in( 10'h200 ),    //       .fftpts_in
		.inverse( 1'b0 ),      //       .inverse
		
		.source_valid( fft_valid ), // source.source_valid
		.source_ready( fft_ready ), //       .source_ready
		.source_error( fft_error ), //       .source_error
		.source_sop( fft_sop ),   //       .source_sop
		.source_eop( fft_eop ),   //       .source_eop
		.source_real( fft_data_real ),  //       .source_real
		.source_imag( fft_data_imag ),  //       .source_imag
		.fftpts_out( fft_fftpts_out )    //       .fftpts_out
	);
	
	
	//
	// FFT Results Display Scaler
	//
	Audio_Stream_Digitizer_Display_Scaler
	#(
		.DATA_WIDTH( DATA_WIDTH )
	)
	audio_stream_display_scaler
	(
		// FFT Result Bus Signals
		.FFT_FRAME_READY( fft_ready ),
		.FFT_FRAME_VALID( fft_valid ),
		.FFT_FRAME_START( fft_sop ),
		.FFT_FRAME_END( fft_eop ),
		.FFT_FRAME_DATA_REAL( fft_data_real ),
		.FFT_FRAME_DATA_IMAG( fft_data_imag ),
		
		// Display Buffer Signals
		.LCD_FRAME_VALID( LCD_FRAME_VALID ),
		.LCD_FRAME_START( LCD_FRAME_START ),
		.LCD_FRAME_END( LCD_FRAME_END ),
		.LCD_FRAME_DATA( LCD_FRAME_DATA ),
		
		// System Signals
		.CLK( CLK ),
		.RESET( RESET )
	);
	
endmodule
