`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    12:22:00 04/11/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #4 Project
// Module Name:    Digitizer_ZeroCross_Detector
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    Digitizer Zero Cross Detector
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module Digitizer_ZeroCross_Detector
#(
	parameter DATA_WIDTH = 16
)
(
	// Sample Data Signals
	input                  SAMPLE_TRIG,
	input [DATA_WIDTH-1:0] SAMPLE_DATA,
	output reg             SAMPLE_ZC,
	
	// System Signals
	input CLK
);

	// NOTE: Assuming Two's Complement Data so only look at the sign bit
	
	reg [3:0] zc_reg;
	
	initial
	begin
		zc_reg <= 4'h0;
		SAMPLE_ZC <= 1'b0;
	end
	
	always @(posedge CLK)
	begin
		if (SAMPLE_TRIG)
			zc_reg <= { zc_reg[2:0], SAMPLE_DATA[DATA_WIDTH-1] };
	end
	
	always @(posedge CLK)
	begin
		SAMPLE_ZC <= (&zc_reg[3:2]) & (~|zc_reg[1:0]);
	end
	
endmodule
