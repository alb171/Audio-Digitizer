`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    12:36:00 02/18/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #4 Project
// Module Name:    DDS_Audio_Mixer_Module
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    DDS Audio Mixer Module
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module DDS_Audio_Mixer_Module
#(
	parameter CLK_RATE_HZ = 18432000, // Hz 
	parameter WF_INIT_FILE = "dds_sine_waveform.dat",
	parameter WF_ADDR_WIDTH = 11,
	parameter WF_DATA_WIDTH = 16
)
(
	// Control Signals
	input ENABLE_1KHZ,
	input ENABLE_3KHZ,
	input ENABLE_5KHZ,
	input ENABLE_7KHZ,
	input ENABLE_10KHZ,

	// DAC Output Signals
	output reg [WF_DATA_WIDTH-1:0] DAC_MIXER_OUTPUT,
	
	// System Signals
	input CLK,
	input RESET
);

	// Include Standard Functions header file (needed for pow2())
	`include "StdFunctions.vh"

	localparam PHASE_ACC_WIDTH = 28;
	localparam PHASE_ACC_UPDATE_RATE = 48000 * 4; // Hz

	// Function to compute tuning word
	function reg [PHASE_ACC_WIDTH-1:0] DDS_Freq_Calc;
		input integer dds_freq;
		integer f;
	begin
		f = (1.0 * dds_freq * pow2(PHASE_ACC_WIDTH)) / PHASE_ACC_UPDATE_RATE;
		DDS_Freq_Calc = f[PHASE_ACC_WIDTH-1:0];
	end
	endfunction
	
	
	// NOTE: Quartus (or Verilog-2001?) doesn't allow parameter array initialization 
	//       so DDS_FREQ_LIST uses a nasty workaround by packing a vector then 
	//       parsing out the values in the generate loop.
	
	localparam DDS_NUM = 5;
	localparam [32*DDS_NUM-1:0] DDS_FREQ_LIST = { 32'd10000, 32'd7000, 32'd5000, 32'd3000, 32'd1000 };
	
	wire [DDS_NUM-1:0] dac_enable_list = { ENABLE_10KHZ, ENABLE_7KHZ, ENABLE_5KHZ, ENABLE_3KHZ, ENABLE_1KHZ };
	wire [WF_DATA_WIDTH-1:0] dac_output_array [DDS_NUM-1:0];
	
	// NOTE: Array elements can't be sectioned so they have to be pulled
	//       into vectors before being used by the mixer.
	wire [WF_DATA_WIDTH-1:0] dac_1k_output = dac_output_array[0];
	wire [WF_DATA_WIDTH-1:0] dac_3k_output = dac_output_array[1];
	wire [WF_DATA_WIDTH-1:0] dac_5k_output = dac_output_array[2];
	wire [WF_DATA_WIDTH-1:0] dac_7k_output = dac_output_array[3];
	wire [WF_DATA_WIDTH-1:0] dac_10k_output = dac_output_array[4];
	
	genvar i;
	generate
	begin
	
		for(i = 0; i < DDS_NUM; i=i+1)
		begin : dds_gen_loop

			DDS_Module
			#(
				.CLK_RATE_HZ( CLK_RATE_HZ ),
				.PHASE_ACC_WIDTH( PHASE_ACC_WIDTH ),
				.PHASE_ACC_UPDATE_RATE( PHASE_ACC_UPDATE_RATE ),
				.WF_ADDR_WIDTH( WF_ADDR_WIDTH ),
				.WF_DATA_WIDTH( WF_DATA_WIDTH ),
				.WF_INIT_FILE( WF_INIT_FILE )
			)
			dds_sine_generator
			(
				// Control Signals
				.ENABLE_OUTPUT_A( dac_enable_list[i] ),
				.ENABLE_OUTPUT_B( 1'b1 ),
				
				// DDS Configuration Signals
				.DDS_TUNING_WORD( DDS_Freq_Calc(DDS_FREQ_LIST[32*i +: 32]) ),
				.DDS_FREQ_MULT_A( 3'h0 ),
				.DDS_FREQ_MULT_B( 3'h0 ),
				.DDS_PHASE_SEL_A( 2'h0 ),
				.DDS_PHASE_SEL_B( 2'h0 ),
				
				// Output Signals
				.DAC_OUTPUT_A( dac_output_array[i] ),
				.DAC_OUTPUT_B(  ),

				// System Signals
				.CLK( CLK ),
				.RESET( RESET )
			);
		
		end
		
	end
	endgenerate
	

	//
	// Waveform Mixer
	//
	localparam EXT_BITS = 3;  // Extension Bits
	localparam DAC_SUM_WIDTH = WF_DATA_WIDTH + EXT_BITS;  // Needs to be large enough to hold full scale values for summation
		
	// Sign extend the DAC values to match summation register size
	wire signed [DAC_SUM_WIDTH-1:0] dac_1k_output_ext = { {EXT_BITS{dac_1k_output[WF_DATA_WIDTH-1]}}, dac_1k_output };
	wire signed [DAC_SUM_WIDTH-1:0] dac_3k_output_ext = { {EXT_BITS{dac_3k_output[WF_DATA_WIDTH-1]}}, dac_3k_output };
	wire signed [DAC_SUM_WIDTH-1:0] dac_5k_output_ext = { {EXT_BITS{dac_5k_output[WF_DATA_WIDTH-1]}}, dac_5k_output };
	wire signed [DAC_SUM_WIDTH-1:0] dac_7k_output_ext = { {EXT_BITS{dac_7k_output[WF_DATA_WIDTH-1]}}, dac_7k_output };
	wire signed [DAC_SUM_WIDTH-1:0] dac_10k_output_ext = { {EXT_BITS{dac_10k_output[WF_DATA_WIDTH-1]}}, dac_10k_output };
	
	//
	// Multiply a gain factor depending on the number of components enabled
	//
	// Real to Fixed-Point Converter: https://planetcalc.com/862/
	//
	localparam GAIN_WIDTH = 16;  // Q6.10 fixed-point, signed
	localparam GAIN_FRACT = 10;
	
	wire signed [GAIN_WIDTH-1:0] dac_gain;
	
	DROM_Nx32
	#(
		.WIDTH( GAIN_WIDTH ),
		.REGOUT( 1 ),
		
		// Gain: x1.0000
		.INIT_00( 16'h0400 ),
		
		// Gain: x16.0000
		.INIT_01( 16'h4000 ),
		.INIT_02( 16'h4000 ),
		.INIT_04( 16'h4000 ),
		.INIT_08( 16'h4000 ),
		.INIT_10( 16'h4000 ),
		
		// Gain: x8.0000
		.INIT_03( 16'h2000 ),
		.INIT_05( 16'h2000 ),
		.INIT_06( 16'h2000 ),
		.INIT_09( 16'h2000 ),
		.INIT_0A( 16'h2000 ),
		.INIT_0C( 16'h2000 ),
		.INIT_11( 16'h2000 ),
		.INIT_12( 16'h2000 ),
		.INIT_14( 16'h2000 ),
		.INIT_18( 16'h2000 ),
		
		// Gain: x5.3334
		.INIT_07( 16'h1555 ),
		.INIT_0B( 16'h1555 ),
		.INIT_0D( 16'h1555 ),
		.INIT_0E( 16'h1555 ),
		.INIT_13( 16'h1555 ),
		.INIT_15( 16'h1555 ),
		.INIT_16( 16'h1555 ),
		.INIT_19( 16'h1555 ),
		.INIT_1A( 16'h1555 ),
		.INIT_1C( 16'h1555 ),
		
		// Gain: x4.0000
		.INIT_0F( 16'h1000 ),
		.INIT_17( 16'h1000 ),
		.INIT_1B( 16'h1000 ),
		.INIT_1D( 16'h1000 ),
		.INIT_1E( 16'h1000 ),
		
		// Gain: x3.2000
		.INIT_1F( 16'h0CCC )
	)
	gain_lut
	(
		// Read Port Signals
		.ADDR( dac_enable_list ),
		.DATA_OUT( dac_gain ),
		.CLK( CLK )
	);
	
	//
	// Sum the DAC values together and multiply by the gain to create the composite waveform
	//
	localparam DAC_MULT_WIDTH = DAC_SUM_WIDTH + GAIN_WIDTH;
	
	wire signed  [DAC_SUM_WIDTH-1:0] dac_sum_output;
	wire signed [DAC_MULT_WIDTH-1:0] dac_gain_output;
	
	assign dac_sum_output = dac_1k_output_ext + dac_3k_output_ext + dac_5k_output_ext + dac_7k_output_ext + dac_10k_output_ext;
	assign dac_gain_output = dac_sum_output * dac_gain;
	
	
	// Output Register (truncate LSB)
	always @(posedge CLK, posedge RESET)
	begin
		if (RESET)
			DAC_MIXER_OUTPUT <= {WF_DATA_WIDTH{1'b0}};
		else
			DAC_MIXER_OUTPUT <= dac_gain_output[DAC_SUM_WIDTH+GAIN_FRACT -: WF_DATA_WIDTH];
	end
		
endmodule
