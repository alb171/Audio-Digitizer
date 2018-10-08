`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    18:01:00 04/10/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #7 Project
// Module Name:    Audio_Stream_Digitizer_FFT_Framer
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    Audio Stream Digitizer FFT Framer
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module Audio_Stream_Digitizer_FFT_Framer
#(
	parameter DATA_WIDTH = 16,
	parameter FRAME_SAMPLES = 480
)
(
	// Digitizer Sample Buffer Signals
	input                       BUFFER_READY,
	output reg                  BUFFER_READ,
	input      [DATA_WIDTH-1:0] BUFFER_DATA,
		
	// Frame Buffer Signals
	input                       FRAME_READY,
	output reg                  FRAME_VALID,
	output reg                  FRAME_START,
	output reg                  FRAME_END,
	output     [DATA_WIDTH-1:0] FRAME_DATA,
	
	// System Signals
	input CLK,
	input RESET
);

	// Include StdFunctions for bit_index()
	`include "StdFunctions.vh"

	//
	// Frame Sample Counter
	//
	localparam FRAME_COUNT_WIDTH = bit_index(FRAME_SAMPLES);
	localparam [FRAME_COUNT_WIDTH:0] FRAME_COUNT_LOADVAL = {1'b1, {FRAME_COUNT_WIDTH{1'b0}}} - FRAME_SAMPLES[FRAME_COUNT_WIDTH:0] + 2'h2;
	
	reg                        frame_count_reload;
	reg  [FRAME_COUNT_WIDTH:0] frame_count_reg;
	wire                       frame_done = frame_count_reg[FRAME_COUNT_WIDTH];
	
	initial
	begin
		frame_count_reg <= FRAME_COUNT_LOADVAL;
	end
	
	// Frame Count Register
	always @(posedge CLK)
	begin
		if (frame_count_reload)
			frame_count_reg <= FRAME_COUNT_LOADVAL;
		else
			frame_count_reg <= frame_count_reg + 1'b1;
	end

	
	// Output the Frame Data
	assign FRAME_DATA = BUFFER_DATA;

	
	//
	// LCD Frame Update State Machine
	//
	reg [2:0] State;
	localparam [2:0]
		S0 = 3'b001,
		S1 = 3'b010,
		S2 = 3'b100;
	
	// TASK: State Machine Implementation
	
always @(posedge CLK, posedge RESET)
	begin

	if (RESET)
	
		begin
		
			BUFFER_READ <= 1'b0;
			FRAME_START <= 1'b0;
			FRAME_END <= 1'b0; 
			FRAME_VALID <= 1'b0;
			frame_count_reload <= 1'b1;
			
			//Transition
			
			State <= S0;

		end
	
	else
	
		begin
		
			case (State)
	
			S0:
				begin
				
				FRAME_END <= 1'b0;
				FRAME_VALID <= 1'b0;
				BUFFER_READ <=  1'b0;
				frame_count_reload <= 1'b1;
				
				//Transition
				
				if (BUFFER_READY & FRAME_READY)
					State <= S1;
				
				end
		
			S1: 
				begin
				
				FRAME_VALID <= 1'b1;
				FRAME_START <= 1'b1;
				BUFFER_READ <= 1'b1; 
				frame_count_reload <= 1'b0;
				
				//Transition
			
				State <= S2;
		
				end
		
			S2: 
				begin
				
				FRAME_START <= 1'b0;
				
				if (frame_done)
				begin
					FRAME_END <= 1'b1;
					State <= S0;
				end
		
				end
		
			endcase
		
		end
		
	end
	
endmodule
