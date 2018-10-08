`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    14:41:00 04/10/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #7 Project
// Module Name:    Digitizer_Trigger_Controller
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    Digitizer Trigger Controller
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module Digitizer_Trigger_Controller
#(
	parameter CLK_RATE_HZ = 18432000,
	parameter PRETRIG_SAMPLES = 240,
	parameter FRAME_SAMPLES = 480
)
(
	// Digitizer Control Signals
	input      FRAME_ARM,
	input      FRAME_TRIG,
	input      SAMPLE_TRIG,
	
	// Data Buffer Signals
	output reg SAMPLE_BUFFER_ENABLE,
	output reg SAMPLE_BUFFER_PRETRIG,
	output reg SAMPLE_BUFFER_TRIGGED,
	
	// LCD Frame Update Signals
	output reg LCD_UPDATE_START,
	input      LCD_UPDATE_DONE,
	
	// System Signals
	input CLK,
	input RESET
);

	// Include StdFunctions for bit_index()
	`include "StdFunctions.vh"

	
	//
	// Pre-Trigger Sample Counter
	//
	localparam PRETRIG_COUNT_WIDTH = bit_index(PRETRIG_SAMPLES);
	localparam [PRETRIG_COUNT_WIDTH:0] PRETRIG_COUNT_LOADVAL = {1'b1, {PRETRIG_COUNT_WIDTH{1'b0}}} - PRETRIG_SAMPLES[PRETRIG_COUNT_WIDTH:0];
	
	reg                          pretrig_count_reload;
	reg                          pretrig_count_enable;
	reg  [PRETRIG_COUNT_WIDTH:0] pretrig_count_reg;
	wire                         pretrig_done = pretrig_count_reg[PRETRIG_COUNT_WIDTH];
	
	always @(posedge CLK)
	begin
		if (pretrig_count_reload)
			pretrig_count_reg <= PRETRIG_COUNT_LOADVAL;
		else if (pretrig_count_enable & SAMPLE_TRIG)
			pretrig_count_reg <= pretrig_count_reg + 1'b1;
	end
	

	//
	// Frame Sample Counter
	//
	localparam FRAME_COUNT_WIDTH = bit_index(FRAME_SAMPLES);
	localparam [FRAME_COUNT_WIDTH:0] FRAME_COUNT_LOADVAL = {1'b1, {FRAME_COUNT_WIDTH{1'b0}}} - FRAME_SAMPLES[FRAME_COUNT_WIDTH:0];
	
	reg                        frame_count_reload;
	reg                        frame_count_enable;
	reg  [FRAME_COUNT_WIDTH:0] frame_count_reg;
	wire                       frame_done = frame_count_reg[FRAME_COUNT_WIDTH];
	
	always @(posedge CLK)
	begin
		if (frame_count_reload)
			frame_count_reg <= FRAME_COUNT_LOADVAL;
		else if (frame_count_enable & SAMPLE_TRIG)
			frame_count_reg <= frame_count_reg + 1'b1;
	end
	
	
	//
	// Trigger Controller State Machine
	//
	reg [5:0] State;
	localparam [5:0]
		S0 = 6'b000001,
		S1 = 6'b000010,
		S2 = 6'b000100,
		S3 = 6'b001000,
		S4 = 6'b010000,
		S5 = 6'b100000;
		
	
	always @(posedge CLK, posedge RESET)
	begin
	
		if (RESET)
		begin
		
			pretrig_count_reload <= 1'b1;
			pretrig_count_enable <= 1'b0;
			
			frame_count_reload <= 1'b1;
			frame_count_enable <= 1'b0;
		
			SAMPLE_BUFFER_ENABLE <= 1'b0;
			SAMPLE_BUFFER_PRETRIG <= 1'b0;
			SAMPLE_BUFFER_TRIGGED <= 1'b0;

			LCD_UPDATE_START <= 1'b0;
		
			State <= S0;
		
		end
		else
		begin
		
			case (State)
			
				S0 :
				begin
				
					// Reload the Sample Counters
					pretrig_count_reload <= 1'b1;
					frame_count_reload <= 1'b1;
					
					// Wait until Armed for Frame Capture
					if (FRAME_ARM)
						State <= S1;
						
				end
				
				S1 :
				begin
					
					// Enable the Sample Buffer for Pre-Trigger Samples
					SAMPLE_BUFFER_ENABLE <= 1'b1;
					SAMPLE_BUFFER_PRETRIG <= 1'b1;
					
					// Clear the Counter Reload Signals
					pretrig_count_reload <= 1'b0;
					frame_count_reload <= 1'b0;					
					
					// Load Pre-Trigger Samples
					pretrig_count_enable <= 1'b1;
					
					// Frame includes Pre-Trigger Samples
					frame_count_enable <= 1'b1;
				
					// Wait until all Pre-Trigger Samples collected
					if (pretrig_done)
						State <= S2;
						
				end
				
				S2 :
				begin
				
					// Done with Pre-Trigger
					SAMPLE_BUFFER_PRETRIG <= 1'b0;
					pretrig_count_enable <= 1'b0;
				
					// Pause the Frame Counter until Triggered
					frame_count_enable <= 1'b0;
					
					// Wait for Frame Trigger
					if (FRAME_TRIG)
						State <= S3;
						
				end
				
				S3 :
				begin
				
					// Enable the Sample Buffer for Trigger Samples
					SAMPLE_BUFFER_TRIGGED <= 1'b1;
				
					// Load remaining Frame Post-Trigger Samples
					frame_count_enable <= 1'b1;
				
					// Wait until all Frame Samples collected
					if (frame_done)
						State <= S4;
						
				end
				
				S4 :
				begin
				
					// Disable the Sample Buffer
					SAMPLE_BUFFER_ENABLE <= 1'b0;
					SAMPLE_BUFFER_TRIGGED <= 1'b0;
					
					// Update LCD Frame
					LCD_UPDATE_START <= 1'b1;
					
					State <= S5;
					
				end
				
				S5 :
				begin
				
					// Clear LCD Update Start 
					LCD_UPDATE_START <= 1'b0;
				
					// Wait until LCD Update completes
					if (LCD_UPDATE_DONE)
						State <= S0;
						
				end
				
			endcase
			
		end
		
	end
		
endmodule
