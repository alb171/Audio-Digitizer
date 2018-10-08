`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    11:14:00 04/09/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #7 Project
// Module Name:    LCD_Sample_Data_Scaler
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    LCD Sample Data Scaler
//	                Scale the Two's Complement Sample Data to fit the vertical
//                 LCD screen rows, and flip data to match LCD Row 0 at top.
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module LCD_Sample_Data_Scaler
#(
	parameter SAMPLE_WIDTH = 16,
	parameter SCALED_WIDTH = 9
)
(
	// Input Signals
	input  [SAMPLE_WIDTH-1:0] SAMPLE_DATA,
	
	// Output Signals
	output [SCALED_WIDTH-1:0] LCD_SCALED_DATA
);

	localparam LCD_ROWS = 272;
	localparam LCD_OFFSET = 10;

	// NOTE: Ideally, a scaling factor multiplication would be used
	//       to scale the sample data to lcd rows, but for time-constraint
	//       simpilcity a simple truncation to scale to 256 instead of 272 
	//       will be done.  This may be updated later.

	assign LCD_SCALED_DATA = { 1'b0, SAMPLE_DATA[SAMPLE_WIDTH-1], ~SAMPLE_DATA[SAMPLE_WIDTH-2 -: SCALED_WIDTH-2] } + LCD_OFFSET[SCALED_WIDTH-1:0];

endmodule
