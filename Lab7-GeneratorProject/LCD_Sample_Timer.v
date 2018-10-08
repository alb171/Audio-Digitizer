`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    6:12:00 04/09/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #7 Project
// Module Name:    LCD_Sample_Timer
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    LCD Sample Timer
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module LCD_Sample_Timer
#(
	parameter CLK_RATE_HZ = 18432000,
	parameter SAMPLE_RATE_HZ = 48000
)
(
	// Timer Signals
	output TIMER_TICK,
	
	// System Signals
	input CLK
);

	// Include StdFunctions for bit_index()
	`include "StdFunctions.vh"

	localparam integer TIMER_TICKS = CLK_RATE_HZ / SAMPLE_RATE_HZ;
	localparam TIMER_WIDTH = bit_index(TIMER_TICKS);
	localparam [TIMER_WIDTH:0] TIMER_LOADVAL = {1'b1, {TIMER_WIDTH{1'b0}}} - TIMER_TICKS[TIMER_WIDTH:0] + 1'b1;

	reg [TIMER_WIDTH:0] timer_reg;

	assign TIMER_TICK = timer_reg[TIMER_WIDTH];
	
	initial
	begin
		timer_reg <= TIMER_LOADVAL;
	end
	
	always @(posedge CLK)
	begin
		if (TIMER_TICK)
			timer_reg <= TIMER_LOADVAL;
		else
			timer_reg <= timer_reg + 1'b1;
	end

endmodule
