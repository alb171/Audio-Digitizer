`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    00:28:00 01/29/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #2 Project
// Module Name:    Reset_Module
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    Simple counter to provide short reset signal after power-on.
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module Reset_Module
#(
	parameter REF_CLK_RATE_HZ = 50000000, // Hz
	parameter POWER_ON_DELAY = 500  // ns
)
(
	// Input Signals
	input  PLL_LOCKED,
	input  REF_CLK,
	
	// Output Signals
	output RESET
);

	// Include StdFunctions for bit_index()
	`include "StdFunctions.vh"

	// Compute Reset Delay Counter Parameters
	localparam RESET_DELAY_TICKS = POWER_ON_DELAY / (1000000000.0 / REF_CLK_RATE_HZ);
	localparam RESET_COUNT_WIDTH = bit_index(RESET_DELAY_TICKS);
	localparam RESET_COUNT_LOADVAL = {1'b1, {RESET_COUNT_WIDTH{1'b0}}} - RESET_DELAY_TICKS;

	reg [RESET_COUNT_WIDTH:0] reset_counter;
	reg                 [1:0] reset_reg;
	reg                       reset_done;

	// Initialize registers incase PLL_LOCKED is not used and hard assigned to 1'b1
	initial
	begin
		reset_done <= 1'b0;
		reset_reg <= 2'h0;
		reset_counter <= RESET_COUNT_LOADVAL;
	end
	
	// Increment the counter while in Reset
	always @(posedge REF_CLK, negedge PLL_LOCKED)
	begin
		if (~PLL_LOCKED)
			reset_counter <= RESET_COUNT_LOADVAL;
		else if (~reset_done)
			reset_counter <= reset_counter + 1'b1;
	end

	always @(posedge REF_CLK, negedge PLL_LOCKED)
	begin
		if (~PLL_LOCKED)
			reset_done <= 1'b0;
		else if (reset_counter[RESET_COUNT_WIDTH])
			reset_done <= 1'b1;
	end
	

//	wire reset_clr_n = PLL_LOCKED & reset_counter[RESET_COUNT_WIDTH];
	
	// Clear the Reset when the counter rolls over
	always @(posedge REF_CLK, negedge reset_done)
	begin
		if (~reset_done)
			reset_reg <= 2'h0;
		else
			reset_reg <= { reset_reg[0], 1'b1 };
	end
	
	// Output the Reset Signal
	assign RESET = ~reset_reg[1];
	
endmodule
