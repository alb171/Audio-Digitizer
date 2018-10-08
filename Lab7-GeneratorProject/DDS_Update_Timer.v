`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    14:33:00 03/07/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #5 Project
// Module Name:    DDS_Update_Timer
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    Direct Digital Synthesis Update Timer
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module DDS_Update_Timer
#(
	parameter CLK_RATE_HZ = 50000000, // Hz
	parameter UPDATE_RATE_HZ = 1000000 // Hz
)
(
	// Timer Signals
	output TIMER_TICK,
	
	// System Signals
	input CLK
);

	// Include Standard Functions header file (needed for bit_index)
	`include "StdFunctions.vh"

	// Compute Timer Parameters
	localparam integer PHASE_ACC_TIMER_TICKS = CLK_RATE_HZ / UPDATE_RATE_HZ;
	localparam TIMER_WIDTH = bit_index(PHASE_ACC_TIMER_TICKS);
	localparam [TIMER_WIDTH:0] PHASE_ACC_TIMER_LOADVAL = {1'b1, {(TIMER_WIDTH){1'b0}}} - PHASE_ACC_TIMER_TICKS[TIMER_WIDTH:0] + 1'b1;

	reg [TIMER_WIDTH:0] phase_acc_timer_reg;
	wire                phase_acc_timer_tick;
	
	assign phase_acc_timer_tick = phase_acc_timer_reg[TIMER_WIDTH];
	
	initial
	begin
		phase_acc_timer_reg <= PHASE_ACC_TIMER_LOADVAL;
	end
	
	always @(posedge CLK)
	begin
		if (phase_acc_timer_tick)
			phase_acc_timer_reg <= PHASE_ACC_TIMER_LOADVAL;
		else
			phase_acc_timer_reg <= phase_acc_timer_reg + 1'b1;
	end

	//
	// Output Timer Tick
	//
	assign TIMER_TICK = phase_acc_timer_tick;

endmodule
