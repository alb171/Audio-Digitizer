`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    17:09:00 04/10/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #7 Project
// Module Name:    Audio_Stream_Digitizer_Sample_Buffer
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    Digitizer Sample Buffer
//                 Audio Stream Digitizer Sample Buffer
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module Audio_Stream_Digitizer_Sample_Buffer
#(
	parameter DATA_WIDTH = 16,
	parameter FRAME_SIZE = 512,
	parameter BUFFER_SIZE = 1024
)
(
	// Sample Control Signals
	input                  BUFFER_ENABLE,
	input                  SAMPLE_TRIG,
	input [DATA_WIDTH-1:0] SAMPLE_DATA,

	// Sample Read Port Signals
	output reg                  BUFFER_READY,
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
	reg                  addr_head_inc;
	

	//
	// Buffer Memory
	//
	integer i;
	
	reg [DATA_WIDTH-1:0] buffer_ram [BUFFER_SIZE-1:0] /* synthesis ramstyle = "no_rw_check, M10K" */;

	initial
	begin
		for (i=0; i < BUFFER_SIZE; i=i+1)
			buffer_ram[i] = {DATA_WIDTH{1'b0}};		
	end
	
	//
	// Write Sample Data only when buffer if enabled
	//
	wire ram_we = BUFFER_ENABLE & SAMPLE_TRIG;
	
	
	//
	// Buffer Count Register
	//
	localparam BUFFER_COUNT_WIDTH = bit_index(BUFFER_SIZE);
	localparam [BUFFER_COUNT_WIDTH:0] BUFFER_COUNT_LOADVAL = {1'b1, {BUFFER_COUNT_WIDTH{1'b0}}} - FRAME_SIZE[BUFFER_COUNT_WIDTH:0] + 1'b1;
	
	reg [BUFFER_COUNT_WIDTH:0] buffer_count_reg;
	
	always @(posedge CLK, posedge RESET)
	begin
		if (RESET)
			buffer_count_reg <= BUFFER_COUNT_LOADVAL;
		else
			buffer_count_reg <= buffer_count_reg + (SAMPLE_TRIG ? 1'b1 : 1'b0) - (BUFFER_READ ? 1'b1 : 1'b0);
	end
	
	always @(posedge CLK, posedge RESET)
	begin
		if (RESET)
			BUFFER_READY <= 1'b0;
		else
			BUFFER_READY <= buffer_count_reg[BUFFER_COUNT_WIDTH];
	end
	
	//
	// Write Port Address Auto-Increment
	//
	always @(posedge CLK, posedge RESET)
	begin
		if (RESET)
			addr_head_inc <= 1'b0;
		else
			addr_head_inc <= ram_we;
	end

	//
	// Write Port Address
	//
	always @(posedge CLK, posedge RESET)
	begin
		if (RESET)
			addr_head <= {ADDR_WIDTH{1'b0}};
		else if (addr_head_inc)
			addr_head <= addr_head + 1'b1;
	end
	
	//
	// Read Port Address
	//
	always @(posedge CLK, posedge RESET)
	begin
		if (RESET)
			addr_tail <= {ADDR_WIDTH{1'b0}};
		else if (BUFFER_READ)
			addr_tail <= addr_tail + 1'b1;
	end
	
	//
	// Write Port Data Register
	//
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
