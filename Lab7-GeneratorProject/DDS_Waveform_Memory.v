`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    14:40:00 03/07/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #5 Project
// Module Name:    DDS_Waveform_Memory
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    DDS Waveform Memory
//                 Variable Width, Variable Depth Memory
//                 Loaded from initialization memory file
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module DDS_Waveform_Memory
#(
	parameter ADDR_WIDTH = 8,
	parameter DATA_WIDTH = 16,
	parameter INIT_FILE = "dds_waveform_memory_init.txt"
)
(
	// Read A Port Signals
	input      [ADDR_WIDTH-1:0] ADDR_A,
	output reg [DATA_WIDTH-1:0] DOUT_A,

	// Read B Port Signals
	input      [ADDR_WIDTH-1:0] ADDR_B,
	output reg [DATA_WIDTH-1:0] DOUT_B,

	input                       CLK
);

	// Variable width, variable depth ROM register
	reg [DATA_WIDTH-1:0] rom [(2**ADDR_WIDTH)-1:0];

	
	//
	// Initialize ROM register with data from init file
	//
	initial
	begin
		$readmemh(INIT_FILE, rom);
	end

	
	//
	// ROM Read Register
	//
	always @(posedge CLK)
	begin
		DOUT_A <= rom[ADDR_A];
		DOUT_B <= rom[ADDR_B];
	end

	
	//
	// Unused write port (specified to eliminate warnings)
	//
	wire                  we;
	wire [ADDR_WIDTH-1:0] waddr;
	
	assign we = 1'b0;
	assign waddr = {ADDR_WIDTH{1'b0}};
	
	always @(posedge CLK)
	begin
		if (we)
			rom[waddr] <= {DATA_WIDTH{1'b0}};
	end
	
endmodule
