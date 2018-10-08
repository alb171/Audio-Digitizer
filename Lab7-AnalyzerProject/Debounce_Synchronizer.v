`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    23:43:00 02/04/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #3 Project
// Module Name:    Debounce_Synchronizer
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    Asynchronous signal synchronizer and signal debouncer.
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module Debounce_Synchronizer
#(
	parameter CLK_RATE_HZ = 50000000, // Hz
	parameter DEBOUNCE_TIME = 10000, // ns
	parameter SIG_OUT_INIT = 1'b0
)
(
	// Input  Signals (asynchronous)
	input      SIG_IN,
	
	// Output Signals (synchronized to CLK domain)
	output reg SIG_OUT,
	
	// System Signals
	input CLK
);

	// Include StdFunctions for bit_index()
	`include "StdFunctions.vh"

	//
	// Compute Debounce Counter Parameters
	//
	localparam DBNC_TICKS = DEBOUNCE_TIME / (1000000000.0 / CLK_RATE_HZ);
	localparam DBNC_COUNT_WIDTH = bit_index(DBNC_TICKS);
	localparam DBNC_COUNT_LOADVAL = {1'b1, {(DBNC_COUNT_WIDTH){1'b0}}} - DBNC_TICKS;
	
	reg [2:0] sync_reg;
	reg [2:0] dbnc_reg;
	
	reg [DBNC_COUNT_WIDTH:0] dbnc_count_reg;

	wire dbnc_transition;
	wire dbnc_count_done;
	
	//
	// Initial register values
	//
	initial
	begin
		sync_reg = 3'h0;
		dbnc_reg = 3'h0;
		dbnc_count_reg = DBNC_COUNT_LOADVAL;
		SIG_OUT = SIG_OUT_INIT;
	end
	
	//
	// Synchronize Input Signal to the CLK Domain
	//
	always @(posedge CLK)
	begin
		sync_reg <= { sync_reg[1:0], SIG_IN };
	end

	//
	// Bus Signal State Transition Detector
	//
	assign dbnc_transition = dbnc_reg[1] ^ dbnc_reg[0];
	
	always @(posedge CLK)
	begin
		dbnc_reg <= { dbnc_reg[1:0], sync_reg[2] };
	end
	
	//
	// Debounce Counter
	//
	assign dbnc_count_done = dbnc_count_reg[DBNC_COUNT_WIDTH];
	
	always @(posedge CLK)
	begin
		if (dbnc_transition)
			dbnc_count_reg <= DBNC_COUNT_LOADVAL;
		else if (!dbnc_count_done)
			dbnc_count_reg <= dbnc_count_reg + 1'b1;
	end
	
	//
	// Bus Signal Output Register
	//
	always @(posedge CLK)
	begin
		if (dbnc_count_done)
			SIG_OUT <= dbnc_reg[2];
	end
	
endmodule
