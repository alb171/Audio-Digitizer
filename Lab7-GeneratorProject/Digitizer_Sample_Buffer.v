`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    17:09:00 04/10/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #7 Project
// Module Name:    Digitizer_Sample_Buffer
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    Digitizer Sample Buffer
//                 Sample Data Circular Buffer
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module Digitizer_Sample_Buffer
#(
	parameter DATA_WIDTH = 16,
	parameter BUFFER_SIZE = 512
)
(
	// Sample Control Signals
	input                  BUFFER_ENABLE,
	input                  BUFFER_PRETRIG,
	input                  BUFFER_TRIGGED,
	input                  SAMPLE_TRIG,
	input [DATA_WIDTH-1:0] SAMPLE_DATA,

	// Sample Read Port Signals
	input                       BUFFER_READ,
	output reg [DATA_WIDTH-1:0] BUFFER_DATA,

	// System Signals
	input CLK,
	input RESET
);

	// Include StdFunctions for bit_index()
	`include "StdFunctions.vh"

	localparam ADDR_WIDTH = bit_index(BUFFER_SIZE-1);
	
	reg [ADDR_WIDTH-1:0] addr_head;
	reg [ADDR_WIDTH-1:0] addr_tail;
	reg addr_head_inc;
	reg addr_tail_inc;
	
	reg [DATA_WIDTH-1:0] buffer_ram [BUFFER_SIZE-1:0] /* synthesis ramstyle = "no_rw_check, M10K" */;

	
	wire ram_we = BUFFER_ENABLE & SAMPLE_TRIG;
	
	
	// Write Port Address Auto-Increment
	always @(posedge CLK, posedge RESET)
	begin
		if (RESET)
		begin
			addr_head_inc <= 1'b0;
			addr_tail_inc <= 1'b0;
		end
		else
		begin
			addr_head_inc <= ram_we;
			addr_tail_inc <= (ram_we & (~BUFFER_PRETRIG & ~BUFFER_TRIGGED)) | BUFFER_READ;
		end
	end
	
	always @(posedge CLK, posedge RESET)
	begin
		if (RESET)
			addr_head <= {ADDR_WIDTH{1'b0}};
		else if (addr_head_inc)
			addr_head <= addr_head + 1'b1;
	end
	
	always @(posedge CLK, posedge RESET)
	begin
		if (RESET)
			addr_tail <= {ADDR_WIDTH{1'b0}};
		else if (addr_tail_inc)
			addr_tail <= addr_tail + 1'b1;
	end
	
	// Write Port Data Register
	always @(posedge CLK)
	begin
		if (ram_we)
			buffer_ram[addr_head] <= SAMPLE_DATA;
	end
	
	// Read Port Data Register
	always @(posedge CLK)
	begin
		BUFFER_DATA <= buffer_ram[addr_tail];
	end

endmodule
