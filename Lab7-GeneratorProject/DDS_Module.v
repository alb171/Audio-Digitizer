`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    14:33:00 03/07/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #5 Project
// Module Name:    DDS_Module
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    Direct Digital Synthesis Module
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module DDS_Module
#(
	parameter CLK_RATE_HZ = 50000000, // Hz
	parameter PHASE_ACC_WIDTH = 24,
	parameter PHASE_ACC_UPDATE_RATE = 10000000, // Hz
	parameter WF_ADDR_WIDTH = 11,	
	parameter WF_DATA_WIDTH = 16,
	parameter WF_INIT_FILE = "dds_waveform_memory_init.dat"
)
(
	// Control Signals
	input  ENABLE_OUTPUT_A,
	input  ENABLE_OUTPUT_B,
	
	// DDS Configuration Signals
	input  [PHASE_ACC_WIDTH-1:0] DDS_TUNING_WORD,
	input                  [2:0] DDS_FREQ_MULT_A,
	input                  [2:0] DDS_FREQ_MULT_B,
	input                  [1:0] DDS_PHASE_SEL_A,
	input                  [1:0] DDS_PHASE_SEL_B,
	
	// Output Signals
	output reg [WF_DATA_WIDTH-1:0] DAC_OUTPUT_A,
	output reg [WF_DATA_WIDTH-1:0] DAC_OUTPUT_B,

	// System Signals
	input CLK,
	input RESET
);

	// Include Standard Functions header file (needed for pow2())
	`include "StdFunctions.vh"

	//
	// Simulation Function to Compute the frequency value for DDS_TUNING_WORD
	//
	function reg [PHASE_ACC_WIDTH-1:0] DDS_Freq_Calc;
		input integer dds_freq;
	begin
		DDS_Freq_Calc = (1.0* dds_freq * pow2(PHASE_ACC_WIDTH)) / PHASE_ACC_UPDATE_RATE;
	end
	endfunction

	
	// Phase Accumulator
	wire  [PHASE_ACC_WIDTH-1:0] phase_accumulator;

	
	//
	// DDS Waveform Memory
	//	
	wire [WF_ADDR_WIDTH-1:0] wf_addr_a;
	wire [WF_ADDR_WIDTH-1:0] wf_addr_b;
	wire [WF_DATA_WIDTH-1:0] wf_data_a;
	wire [WF_DATA_WIDTH-1:0] wf_data_b;
	
	DDS_Waveform_Memory
	#(
		.ADDR_WIDTH( WF_ADDR_WIDTH ),
		.DATA_WIDTH( WF_DATA_WIDTH ),
		.INIT_FILE( WF_INIT_FILE )
	)
	dds_wf_mem
	(
		// Read A Port Signals
		.ADDR_A( wf_addr_a ),
		.DOUT_A( wf_data_a ),
		
		// Read B Port Signals
		.ADDR_B( wf_addr_b ),
		.DOUT_B( wf_data_b ),
		
		.CLK( CLK )
	);
		
	
	//
	// Phase Selector A
	//
	DDS_Phase_Selector
	#(
		.PHASE_ACC_WIDTH( PHASE_ACC_WIDTH ),
		.WF_ADDR_WIDTH( WF_ADDR_WIDTH )
	)
	phase_selector_a
	(
		// Phase Accumulator Signals
		.PHASE_ACCUMULATOR( phase_accumulator ),
		
		// Configuration Signals
		.DDS_FREQ_MULT( DDS_FREQ_MULT_A ),
		.DDS_PHASE_SEL( DDS_PHASE_SEL_A ),
		
		// Waveform Index Signals
		.WF_ADDR( wf_addr_a )
	);


	//
	// Phase Selector B
	//
	DDS_Phase_Selector
	#(
		.PHASE_ACC_WIDTH( PHASE_ACC_WIDTH ),
		.WF_ADDR_WIDTH( WF_ADDR_WIDTH )
	)
	phase_selector_b
	(
		// Phase Accumulator Signals
		.PHASE_ACCUMULATOR( phase_accumulator ),
		
		// Configuration Signals
		.DDS_FREQ_MULT( DDS_FREQ_MULT_B ),
		.DDS_PHASE_SEL( DDS_PHASE_SEL_B ),
		
		// Waveform Index Signals
		.WF_ADDR( wf_addr_b )
	);
	
	
	//
	// DDS Phase Accumulator Update Timer
	//
	wire update_timer_tick;
	
	DDS_Update_Timer
	#(
		.CLK_RATE_HZ( CLK_RATE_HZ ),
		.UPDATE_RATE_HZ( PHASE_ACC_UPDATE_RATE )
	)
	update_timer
	(
		// Timer Signals
		.TIMER_TICK( update_timer_tick ),
		
		// System Signals
		.CLK( CLK )
	);
	
	
	//
	// DDS Phase Controller
	//
	DDS_Phase_Controller
	#(
		.PHASE_ACC_WIDTH( PHASE_ACC_WIDTH )
	)
	phase_controller
	(
		// Control Signals
		.ENABLE( ENABLE_OUTPUT_A | ENABLE_OUTPUT_B ),
		.UPDATE_TIMER_TICK( update_timer_tick ),
		
		// Phase Signals
		.DDS_TUNING_WORD( DDS_TUNING_WORD ),
		.PHASE_ACCUMULATOR( phase_accumulator ),
		
		// System Signals
		.CLK( CLK ),
		.RESET( RESET )
	);
	
	
	//
	// DDS Waveform Output Registers
	//
	initial
	begin
		DAC_OUTPUT_A = {WF_DATA_WIDTH{1'b0}};
		DAC_OUTPUT_B = {WF_DATA_WIDTH{1'b0}};
	end
	
	always @(posedge CLK)
	begin
		if (!ENABLE_OUTPUT_A)
			DAC_OUTPUT_A <= {WF_DATA_WIDTH{1'b0}};
		else
			DAC_OUTPUT_A <= wf_data_a;			
	end

	always @(posedge CLK)
	begin
		if (!ENABLE_OUTPUT_B)
			DAC_OUTPUT_B <= {WF_DATA_WIDTH{1'b0}};
		else
			DAC_OUTPUT_B <= wf_data_b;			
	end

endmodule
