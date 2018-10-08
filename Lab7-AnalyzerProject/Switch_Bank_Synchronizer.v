`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    13:30:00 03/23/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #6 Project
// Module Name:    Switch_Bank_Synchronizer
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    Switch Bank Synchronizer
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module Switch_Bank_Synchronizer
#(
	parameter CLK_RATE_HZ = 50000000, // Hz
	parameter SWITCH_NUM = 1,
	parameter DEBOUNCE_TIME = 10000000, // ns
	parameter SIG_OUT_INIT = 1'b0
)
(
	// Input  Signals (asynchronous)
	input [SWITCH_NUM-1:0] SIG_IN,
	
	// Output Signals (synchronized to CLK domain)
	output [SWITCH_NUM-1:0] SIG_OUT,
	
	// System Signals
	input CLK
);

	genvar i;
	generate
	begin
	
		for (i=0; i < SWITCH_NUM; i=i+1)
		begin : sw_sync_loop
		
			Debounce_Synchronizer
			#(
				.CLK_RATE_HZ( CLK_RATE_HZ ),
				.DEBOUNCE_TIME( DEBOUNCE_TIME ),
				.SIG_OUT_INIT( SIG_OUT_INIT )
			)
			sw_sync
			(
				// Input  Signals (asynchronous)
				.SIG_IN( SIG_IN[i] ),
				
				// Output Signals (synchronized to CLK domain)
				.SIG_OUT( SIG_OUT[i] ),
				
				// System Signals
				.CLK( CLK )
			);
		end
		
	end
	endgenerate
	
endmodule
