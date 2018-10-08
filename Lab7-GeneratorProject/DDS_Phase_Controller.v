`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    14:33:00 03/07/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #5 Project
// Module Name:    DDS_Phase_Controller
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    Direct Digital Synthesis Phase Controller Module
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module DDS_Phase_Controller
#(
	parameter PHASE_ACC_WIDTH = 24
)
(
	// Control Signals
	input ENABLE,
	input UPDATE_TIMER_TICK,
	
	// Phase Signals
	input  [PHASE_ACC_WIDTH-1:0] DDS_TUNING_WORD,
	output [PHASE_ACC_WIDTH-1:0] PHASE_ACCUMULATOR,
	
	// System Signals
	input CLK,
	input RESET
);

	// FSM State Definition
	reg [2:0] State;
	localparam [2:0]
		S0 = 3'b001,
		S1 = 3'b010,
		S2 = 3'b100;

	
	// Phase Accumulator Register
	reg  [PHASE_ACC_WIDTH-1:0] phase_accumulator_reg;

	assign PHASE_ACCUMULATOR = phase_accumulator_reg;
	
	
	//
	// DDS Phase Control State Machine
	//
	always @(posedge CLK, posedge RESET)
	begin
	
		if (RESET)
		begin
		
			phase_accumulator_reg <= {PHASE_ACC_WIDTH{1'b0}};
					
			State <= S0;
			
		end
		else
		begin
		
			case (State)
			
				S0 :
				begin
				
					// Clear the Phase Accumulator
					phase_accumulator_reg <= {PHASE_ACC_WIDTH{1'b0}};
										
					// Start when Enabled
					if (ENABLE)
						State <= S1;
				
				end
				
				S1 :
				begin
				
					// Wait for next Update tick
					if (UPDATE_TIMER_TICK)
						State <= S2;
						
				end
				
				S2 :
				begin
												
					// Increment the Phase Accumulator
					phase_accumulator_reg <= phase_accumulator_reg + DDS_TUNING_WORD;
					
					// Check if still enabled
					if (ENABLE)
						State <= S1;
					else
						State <= S0;
				
				end
			
			endcase
		
		end
		
	end

endmodule
