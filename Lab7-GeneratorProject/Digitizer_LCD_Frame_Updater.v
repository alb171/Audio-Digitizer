`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    18:01:00 04/10/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #7 Project
// Module Name:    Digitizer_LCD_Frame_Updater
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    Digitizer LCD Frame Updater
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module Digitizer_LCD_Frame_Updater
#(
	parameter DATA_WIDTH = 16,
	parameter FRAME_SAMPLES = 480
)
(
	// Frame Update Control Signals
	input      FRAME_UPDATE_START,
	output reg FRAME_UPDATE_DONE,

	// Digitizer Sample Buffer Signals
	output reg                  BUFFER_DATA_NEXT,
	input      [DATA_WIDTH-1:0] BUFFER_LCHAN_DATA,
	input      [DATA_WIDTH-1:0] BUFFER_RCHAN_DATA,
	
	// LCD Frame Interface Signals
	output reg                  LCD_FRAME_START,
	output reg                  LCD_FRAME_DONE,
	output reg                  LCD_DATA_WR,
	output reg [DATA_WIDTH-1:0] LCD_LCHAN_DATA,
	output reg [DATA_WIDTH-1:0] LCD_RCHAN_DATA,

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
	localparam [FRAME_COUNT_WIDTH:0] FRAME_COUNT_LOADVAL = {1'b1, {FRAME_COUNT_WIDTH{1'b0}}} - FRAME_SAMPLES[FRAME_COUNT_WIDTH:0];
	
	reg                        frame_count_reload;
	reg                        frame_count_enable;
	reg  [FRAME_COUNT_WIDTH:0] frame_count_reg;
	wire                       frame_done = frame_count_reg[FRAME_COUNT_WIDTH];
	
	always @(posedge CLK)
	begin
		if (FRAME_UPDATE_START)
			frame_count_reg <= FRAME_COUNT_LOADVAL;
		else if (LCD_DATA_WR)
			frame_count_reg <= frame_count_reg + 1'b1;
	end

	
	//
	// LCD Frame Update State Machine
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
		
			FRAME_UPDATE_DONE <= 1'b0;

			BUFFER_DATA_NEXT <= 1'b0;
			
			LCD_FRAME_START <= 1'b0;
			LCD_FRAME_DONE <= 1'b0;
			LCD_DATA_WR <= 1'b0;
			LCD_LCHAN_DATA <= {DATA_WIDTH{1'b0}};
			LCD_RCHAN_DATA <= {DATA_WIDTH{1'b0}};
			
			State <= S0;
			
		end
		else
		begin
		
			case (State)
			
				S0 :
				begin
				
					FRAME_UPDATE_DONE <= 1'b0;
					LCD_FRAME_DONE <= 1'b0;
				
					if (FRAME_UPDATE_START)
						State <= S1;
						
				end
				
				S1 :
				begin
				
					// Start the Frame Data Write
					LCD_FRAME_START <= 1'b1;
					
					State <= S2;
					
				end
				
				S2 :
				begin
				
					// Clear Frame Start
					LCD_FRAME_START <= 1'b0;
								
					// Set the LCD Data
					LCD_LCHAN_DATA <= BUFFER_LCHAN_DATA;
					LCD_RCHAN_DATA <= BUFFER_RCHAN_DATA;

					// Write LCD Data
					LCD_DATA_WR <= 1'b1;
	
					State <= S3;
					
				end
				
				S3 :
				begin

					// Clear LCD Data Write 
					LCD_DATA_WR <= 1'b0;

					// Next Buffer Data
					BUFFER_DATA_NEXT <= 1'b1;
					
					State <= S4;
					
				end
				
				S4 :
				begin

					// Clear Next Buffer Data
					BUFFER_DATA_NEXT <= 1'b0;
					
					// Check Frame Done
					if (frame_done)
						State <= S5;
					else
						State <= S2;
				
				end
				
				S5 :
				begin
				
					// Frame Update Done
					FRAME_UPDATE_DONE <= 1'b1;
				
					// Frame Done
					LCD_FRAME_DONE <= 1'b1;
				
					State <= S0;
					
				end
				
			endcase
			
		end
		
	end
	
endmodule
