`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    22:31:00 01/17/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #4 Demo
// Module Name:    DROM_Nx64 
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    Variable Width x 64 Deep ROM,
//                 Initialization Decalared In-line with Module Instance
//
// Dependencies:   None
//
//////////////////////////////////////////////////////////////////////////////////

module DROM_Nx64
#(
	parameter WIDTH = 4,
	parameter REGOUT = 1, // 0 = Unregistered, 1 = Registered
	parameter INIT_00 = {WIDTH{1'b0}}, parameter INIT_01 = {WIDTH{1'b0}},
	parameter INIT_02 = {WIDTH{1'b0}}, parameter INIT_03 = {WIDTH{1'b0}},
	parameter INIT_04 = {WIDTH{1'b0}}, parameter INIT_05 = {WIDTH{1'b0}},
	parameter INIT_06 = {WIDTH{1'b0}}, parameter INIT_07 = {WIDTH{1'b0}},
	parameter INIT_08 = {WIDTH{1'b0}}, parameter INIT_09 = {WIDTH{1'b0}},
	parameter INIT_0A = {WIDTH{1'b0}}, parameter INIT_0B = {WIDTH{1'b0}},
	parameter INIT_0C = {WIDTH{1'b0}}, parameter INIT_0D = {WIDTH{1'b0}},
	parameter INIT_0E = {WIDTH{1'b0}}, parameter INIT_0F = {WIDTH{1'b0}},
	parameter INIT_10 = {WIDTH{1'b0}}, parameter INIT_11 = {WIDTH{1'b0}},
	parameter INIT_12 = {WIDTH{1'b0}}, parameter INIT_13 = {WIDTH{1'b0}},
	parameter INIT_14 = {WIDTH{1'b0}}, parameter INIT_15 = {WIDTH{1'b0}},
	parameter INIT_16 = {WIDTH{1'b0}}, parameter INIT_17 = {WIDTH{1'b0}},
	parameter INIT_18 = {WIDTH{1'b0}}, parameter INIT_19 = {WIDTH{1'b0}},
	parameter INIT_1A = {WIDTH{1'b0}}, parameter INIT_1B = {WIDTH{1'b0}},
	parameter INIT_1C = {WIDTH{1'b0}}, parameter INIT_1D = {WIDTH{1'b0}},
	parameter INIT_1E = {WIDTH{1'b0}}, parameter INIT_1F = {WIDTH{1'b0}},
	parameter INIT_20 = {WIDTH{1'b0}}, parameter INIT_21 = {WIDTH{1'b0}},
	parameter INIT_22 = {WIDTH{1'b0}}, parameter INIT_23 = {WIDTH{1'b0}},
	parameter INIT_24 = {WIDTH{1'b0}}, parameter INIT_25 = {WIDTH{1'b0}},
	parameter INIT_26 = {WIDTH{1'b0}}, parameter INIT_27 = {WIDTH{1'b0}},
	parameter INIT_28 = {WIDTH{1'b0}}, parameter INIT_29 = {WIDTH{1'b0}},
	parameter INIT_2A = {WIDTH{1'b0}}, parameter INIT_2B = {WIDTH{1'b0}},
	parameter INIT_2C = {WIDTH{1'b0}}, parameter INIT_2D = {WIDTH{1'b0}},
	parameter INIT_2E = {WIDTH{1'b0}}, parameter INIT_2F = {WIDTH{1'b0}},
	parameter INIT_30 = {WIDTH{1'b0}}, parameter INIT_31 = {WIDTH{1'b0}},
	parameter INIT_32 = {WIDTH{1'b0}}, parameter INIT_33 = {WIDTH{1'b0}},
	parameter INIT_34 = {WIDTH{1'b0}}, parameter INIT_35 = {WIDTH{1'b0}},
	parameter INIT_36 = {WIDTH{1'b0}}, parameter INIT_37 = {WIDTH{1'b0}},
	parameter INIT_38 = {WIDTH{1'b0}}, parameter INIT_39 = {WIDTH{1'b0}},
	parameter INIT_3A = {WIDTH{1'b0}}, parameter INIT_3B = {WIDTH{1'b0}},
	parameter INIT_3C = {WIDTH{1'b0}}, parameter INIT_3D = {WIDTH{1'b0}},
	parameter INIT_3E = {WIDTH{1'b0}}, parameter INIT_3F = {WIDTH{1'b0}}
)
(	
	// Read Port Signals
	input            [5:0] ADDR,
	output reg [WIDTH-1:0] DATA_OUT,
	input                  CLK
);

	reg [WIDTH-1:0] rom [63:0];
	
	// Set the ROM Contents
	initial
	begin
		rom[ 0] = INIT_00;
		rom[ 1] = INIT_01;
		rom[ 2] = INIT_02;
		rom[ 3] = INIT_03;
		rom[ 4] = INIT_04;
		rom[ 5] = INIT_05;
		rom[ 6] = INIT_06;
		rom[ 7] = INIT_07;
		rom[ 8] = INIT_08;
		rom[ 9] = INIT_09;
		rom[10] = INIT_0A;
		rom[11] = INIT_0B;
		rom[12] = INIT_0C;
		rom[13] = INIT_0D;
		rom[14] = INIT_0E;
		rom[15] = INIT_0F;
		rom[16] = INIT_10;
		rom[17] = INIT_11;
		rom[18] = INIT_12;
		rom[19] = INIT_13;
		rom[20] = INIT_14;
		rom[21] = INIT_15;
		rom[22] = INIT_16;
		rom[23] = INIT_17;
		rom[24] = INIT_18;
		rom[25] = INIT_19;
		rom[26] = INIT_1A;
		rom[27] = INIT_1B;
		rom[28] = INIT_1C;
		rom[29] = INIT_1D;
		rom[30] = INIT_1E;
		rom[31] = INIT_1F;
		rom[32] = INIT_20;
		rom[33] = INIT_21;
		rom[34] = INIT_22;
		rom[35] = INIT_23;
		rom[36] = INIT_24;
		rom[37] = INIT_25;
		rom[38] = INIT_26;
		rom[39] = INIT_27;
		rom[40] = INIT_28;
		rom[41] = INIT_29;
		rom[42] = INIT_2A;
		rom[43] = INIT_2B;
		rom[44] = INIT_2C;
		rom[45] = INIT_2D;
		rom[46] = INIT_2E;
		rom[47] = INIT_2F;
		rom[48] = INIT_30;
		rom[49] = INIT_31;
		rom[50] = INIT_32;
		rom[51] = INIT_33;
		rom[52] = INIT_34;
		rom[53] = INIT_35;
		rom[54] = INIT_36;
		rom[55] = INIT_37;
		rom[56] = INIT_38;
		rom[57] = INIT_39;
		rom[58] = INIT_3A;
		rom[59] = INIT_3B;
		rom[60] = INIT_3C;
		rom[61] = INIT_3D;
		rom[62] = INIT_3E;
		rom[63] = INIT_3F;
	end

	// Generate block to choose registered or unregistered output
	generate
	begin
		if (REGOUT)
		begin : Registered_Output
			always @(posedge CLK)
			begin
				DATA_OUT <= rom[ADDR];
			end
		end
		else
		begin : Unregistered_Output
			always @*
			begin
				DATA_OUT <= rom[ADDR];
			end		
		end
	end
	endgenerate
	
	// Unused write port (specified to eliminate warnings)
	wire       we;
	wire [5:0] waddr;
	
	assign we = 1'b0;
	assign waddr = 6'h00;
	
	always @(posedge CLK)
	begin
		if (we)
			rom[waddr] <= {WIDTH{1'b0}};
	end
	
endmodule
