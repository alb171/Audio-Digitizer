`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    15:39:00 04/10/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #7 Project
// Module Name:    LCD_Display_Sample_Buffer
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    LCD Display Sample Buffer
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module LCD_Display_Sample_Buffer
#(
	parameter DATA_WIDTH = 9
)
(
	// Audio DAC Interface Signals (AUD_CLK Domain)
	input                   AUD_DAC_FRAME_START,
	input                   AUD_DAC_FRAME_DONE,
	input                   AUD_DAC_DATA_WR,
	input  [DATA_WIDTH-1:0] AUD_DAC_DATA,
	input                   AUD_CLK,
	
	// LCD Display Interface Signals (LCD_CLK Domain)
	input                 [8:0] LCD_COL,
	output reg [DATA_WIDTH-1:0] LCD_DATA,
	input                       LCD_CLK
);

	localparam ADDR_WIDTH = 9;
	localparam FRAME_NUM = 2;

	// Frame Status Flags
	wire active_frame = 1'b0;
	wire shadow_frame = 1'b0;
	
	
	//
	// DAC Channel Address Auto-Increment
	//
	reg                  dac_addr_inc;
	reg [ADDR_WIDTH-1:0] dac_chan_addr;
	
	initial
	begin
		dac_addr_inc <= 1'b0;
		dac_chan_addr <= {ADDR_WIDTH{1'b0}};
	end
	
	// After Data Write, Increment the Address
	always @(posedge AUD_CLK)
	begin
		dac_addr_inc <= AUD_DAC_DATA_WR;
	end
	
	// Address Register
	always @(posedge AUD_CLK)
	begin
		if (AUD_DAC_FRAME_START)
			dac_chan_addr <= {ADDR_WIDTH{1'b0}};
		else if (dac_addr_inc)
			dac_chan_addr <= dac_chan_addr + 1'b1;
	end
	
	
	//
	// Dual-Port Memory Buffer
	//
	localparam RAM_SIZE = (2**ADDR_WIDTH) * FRAME_NUM;
	
	// Variable width, variable depth RAM register
	reg [DATA_WIDTH-1:0] ram [RAM_SIZE-1:0] /* synthesis ramstyle = "no_rw_check, M10K" */;

	integer i;
	initial
	begin
		for (i = 0; i < RAM_SIZE; i=i+1)
			ram[i] <= {DATA_WIDTH{1'b1}};
	end
	
	// Audio DAC Write Port
	always @(posedge AUD_CLK)
	begin
		if (AUD_DAC_DATA_WR)
			ram[{ shadow_frame, dac_chan_addr }] <= AUD_DAC_DATA;
	end

	// LCD Data Read Port
	always @(posedge LCD_CLK)
	begin
		LCD_DATA <= ram[{ active_frame, LCD_COL }];
	end

endmodule
