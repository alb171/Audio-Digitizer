`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    14:33:00 03/07/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #5 Project
// Module Name:    DDS_Phase_Selector
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    DDS Phase Selector
//                 Output the Phase Index from the Phase Accumulator input
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module DDS_Phase_Selector
#(
	parameter PHASE_ACC_WIDTH = 16,
	parameter WF_ADDR_WIDTH = 8
)
(
	// Phase Accumulator Signals
	input  [PHASE_ACC_WIDTH-1:0] PHASE_ACCUMULATOR,
	
	// Configuration Signals
	input [2:0] DDS_FREQ_MULT,
	input [1:0] DDS_PHASE_SEL,
	
	// Waveform Index Signals
	output   [WF_ADDR_WIDTH-1:0] WF_ADDR
);
	
	//
	// DDS Frequency Multipler Selector
	//	
	reg  [WF_ADDR_WIDTH-1:0] phase_mult_index;

	always @*
	begin
	
		// DDS Frequency Multiplier Selector
		case (DDS_FREQ_MULT)
			3'h0 : phase_mult_index = { PHASE_ACCUMULATOR[PHASE_ACC_WIDTH-1 -: WF_ADDR_WIDTH] };  // x1
			3'h1 : phase_mult_index = { PHASE_ACCUMULATOR[PHASE_ACC_WIDTH-2 -: WF_ADDR_WIDTH] };  // x2
			3'h2 : phase_mult_index = { PHASE_ACCUMULATOR[PHASE_ACC_WIDTH-3 -: WF_ADDR_WIDTH] };  // x4
			3'h3 : phase_mult_index = { PHASE_ACCUMULATOR[PHASE_ACC_WIDTH-4 -: WF_ADDR_WIDTH] };  // x8
			3'h4 : phase_mult_index = { PHASE_ACCUMULATOR[PHASE_ACC_WIDTH-5 -: WF_ADDR_WIDTH] };  // x16
			3'h5 : phase_mult_index = { PHASE_ACCUMULATOR[PHASE_ACC_WIDTH-6 -: WF_ADDR_WIDTH] };  // x32
			3'h6 : phase_mult_index = { PHASE_ACCUMULATOR[PHASE_ACC_WIDTH-7 -: WF_ADDR_WIDTH] };  // x64
			3'h7 : phase_mult_index = { PHASE_ACCUMULATOR[PHASE_ACC_WIDTH-8 -: WF_ADDR_WIDTH] };  // x128
		endcase
				
	end
	
	//
	// DDS Phase Selector
	//
	// The Upper two bits of the index specify the waveform phase
	//
	reg  [1:0] phase_sel_index;

	always @*
	begin
	
		// DDS Phase Selector
		case (DDS_PHASE_SEL)
			4'h0 : phase_sel_index <= phase_mult_index[WF_ADDR_WIDTH-1:WF_ADDR_WIDTH-2]; // Phase 0
			4'h1 : phase_sel_index <= { ^phase_mult_index[WF_ADDR_WIDTH-1:WF_ADDR_WIDTH-2], ~phase_mult_index[WF_ADDR_WIDTH-2] }; // Phase 1/4
			4'h2 : phase_sel_index <= { ~phase_mult_index[WF_ADDR_WIDTH-1], phase_mult_index[WF_ADDR_WIDTH-2] }; // Phase 1/2
			4'h3 : phase_sel_index <= { ~^phase_mult_index[WF_ADDR_WIDTH-1:WF_ADDR_WIDTH-2], ~phase_mult_index[WF_ADDR_WIDTH-2] }; // Phase 3/4
		endcase
		
	end
	
	//
	// DDS Waveform Index
	//
	assign WF_ADDR = { phase_sel_index, phase_mult_index[WF_ADDR_WIDTH-3:0] };
	
	
endmodule
