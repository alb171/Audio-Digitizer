`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    00:48:00 01/25/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #2 Project
// Module Name:    Key_Synchronizer_Module
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    Key input signal synchronizer to align asynchronous key
//                 press signals to the system clock.  Also, provides a
//                 key lockout so only one key press will be generated per
//                 lockout delay period.
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module Key_Synchronizer_Module
#(
	parameter CLK_RATE = 50, // MHz
	parameter KEY_LOCK_DELAY = 800 // mS
)
(
	// Input Signals
	input KEY,
	
	// Output Signals
	output reg KEY_EVENT,
	
	// System Signals
	input CLK
);

	// Helper function to find the upper index needed 
	// for a register to hold the given value.
	function integer bit_index;
		input integer x;
		integer i,p;
	begin
		p = 2;
		for(i=1; p<=x; i=i+1)
			p=p*2;
		bit_index=i;
	end
	endfunction
	
	// Key Lockout Delay Parameter Calculations
	localparam KEY_LOCK_DELAY_TICKS = (KEY_LOCK_DELAY * 1000000) / (1000.0 / CLK_RATE);
	localparam KEY_LOCK_WIDTH = bit_index(KEY_LOCK_DELAY_TICKS);
	localparam KEY_LOCK_LOADVAL = {1'b1, {(KEY_LOCK_WIDTH-1){1'b0}}, 1'b1} - KEY_LOCK_DELAY_TICKS;
	
	
	//
	// Synchronize Key Input to System Clock
	//
	wire       key_sync;
	reg  [2:0] key_sync_reg;
	
	assign key_sync = key_sync_reg[2];
	
	// Simple shift register to triple buffer the signal
	always @(posedge CLK)
	begin
		key_sync_reg <= { key_sync_reg[1:0], ~KEY };
	end

	
	//
	// Key Lockout Counter
	//
	wire                    key_lock_out;
	reg  [KEY_LOCK_WIDTH:0] key_lock_counter_reg;
	
	initial
	begin
		key_lock_counter_reg <= { 1'b1, {KEY_LOCK_WIDTH{1'b0}} };
	end
	
	assign key_lock_out = ~key_lock_counter_reg[KEY_LOCK_WIDTH];
	
	always @(posedge CLK)
	begin
		if (~key_lock_out)
		begin
			if (key_sync)
				key_lock_counter_reg <= KEY_LOCK_LOADVAL;
		end
		else
			key_lock_counter_reg <= key_lock_counter_reg + 1'b1;
	end
	
	
	//
	// Key Event Register
	//
	always @(posedge CLK)
	begin
		if (key_sync & ~key_lock_out)
			KEY_EVENT <= 1'b1;
		else
			KEY_EVENT <= 1'b0;
	end

endmodule
