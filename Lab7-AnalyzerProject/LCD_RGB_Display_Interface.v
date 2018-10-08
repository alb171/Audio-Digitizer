<<<<<<< HEAD
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    11:15:00 04/08/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #7 Project
// Module Name:    LCD_RGB_Display_Interface
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    LCD RGB Display Interface
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module LCD_RGB_Display_Interface
#(
	parameter CLK_RATE_HZ = 18000000
)
(
	// Control Signals
	input ENABLE,
	input DISP_ENABLE,
	
	// Pixel Data Signals
	output reg       DATA_SOF,	
	output reg [8:0] DATA_COL,
	output reg [8:0] DATA_ROW,
	input      [7:0] DATA_R,
	input      [7:0] DATA_G,
	input      [7:0] DATA_B,
	
	// LCD RGB Interface Signals
	output reg       LCD_DISP,
	output reg       LCD_CK,
	output reg       LCD_HSYNC,
	output reg       LCD_VSYNC,
	output reg [7:0] LCD_R,
	output reg [7:0] LCD_G,
	output reg [7:0] LCD_B,
	
	output reg [8:0] DATA_ROW_INV,

	// System Signals
	input CLK,
	input RESET
);

	// Include StdFunctions for bit_index()
	`include "StdFunctions.vh"

	//
	// Display Timing Parameters for Sharp LQ043 TFT LCD panel
	//
	localparam TH  = 525;  // Hsync Total Period (clks)
	localparam THp = 41;   // Hsync Pulse Width (clks)
	localparam THd = 480;  // Hsync Data Period (clks)
	localparam THb = 2;    // Hsync Back Porch (clks)
	localparam THf = 2;    // Hsync Front Porch (clks)
	localparam TV  = 286;  // Vsync Total Period (lines)
	localparam TVp = 10;   // Vsync Pulse Width (lines)
	localparam TVd = 272;  // Vsync Data Period (lines)
	localparam TVb = 2;    // Vsync Back Porch (lines)
	localparam TVf = 2;    // Vsync Front Porch (lines)
	
	
	//
	// Horizontal Counter Parameters
	//
	localparam HSYNC_INTERVAL_TICKS = TH;
	localparam HSYNC_INTERVAL_WIDTH = bit_index(HSYNC_INTERVAL_TICKS);
	localparam [HSYNC_INTERVAL_WIDTH:0] HSYNC_INTERVAL_LOADVAL = {1'b1, {HSYNC_INTERVAL_WIDTH{1'b0}}} - HSYNC_INTERVAL_TICKS[HSYNC_INTERVAL_WIDTH:0] + 1'b1;

	localparam HSYNC_PULSE_TICKS = THp;
	localparam [HSYNC_INTERVAL_WIDTH:0] HSYNC_PULSE_LOADVAL = {1'b1, {HSYNC_INTERVAL_WIDTH{1'b0}}} - HSYNC_PULSE_TICKS[HSYNC_INTERVAL_WIDTH:0];
	
	reg [HSYNC_INTERVAL_WIDTH:0] hsync_interval_counter;
	reg [HSYNC_INTERVAL_WIDTH:0] hsync_pulse_counter;
	
	wire hsync_interval_tick = hsync_interval_counter[HSYNC_INTERVAL_WIDTH];
	wire hsync_pulse_active = hsync_pulse_counter[HSYNC_INTERVAL_WIDTH];
		
	
	//
	// Vertical Counter Parameters
	//
	localparam VSYNC_INTERVAL_TICKS = TV;
	localparam VSYNC_INTERVAL_WIDTH = bit_index(VSYNC_INTERVAL_TICKS);
	localparam [VSYNC_INTERVAL_WIDTH:0] VSYNC_INTERVAL_LOADVAL = {1'b1, {VSYNC_INTERVAL_WIDTH{1'b0}}} - VSYNC_INTERVAL_TICKS[VSYNC_INTERVAL_WIDTH:0];
	
	localparam VSYNC_PULSE_TICKS = TVp;
	localparam [VSYNC_INTERVAL_WIDTH:0] VSYNC_PULSE_LOADVAL = {1'b1, {VSYNC_INTERVAL_WIDTH{1'b0}}} - VSYNC_PULSE_TICKS[VSYNC_INTERVAL_WIDTH:0];
	
	reg [VSYNC_INTERVAL_WIDTH:0] vsync_interval_counter;
	reg [VSYNC_INTERVAL_WIDTH:0] vsync_pulse_counter;
	
	wire vsync_interval_tick = vsync_interval_counter[VSYNC_INTERVAL_WIDTH];
	wire vsync_pulse_active = vsync_pulse_counter[VSYNC_INTERVAL_WIDTH];
	
	
	//
	// Display State Machine
	//
	reg [2:0] State;
	localparam [2:0]
		S0 = 3'b001,
		S1 = 3'b010,
		S2 = 3'b100;
	
	reg hsync_line_start;
	reg vsync_frame_start;
	
	// TASK: State Machine Implementation
	
	always @(posedge CLK)
	begin 
	
		if(RESET)
		begin
			LCD_DISP <= 1'b0;
			LCD_CK <= 1'b0;
			LCD_HSYNC <= 1'b1;
			LCD_VSYNC <= 1'b1;
			LCD_R <= {8{1'b0}};
			LCD_G <= {8{1'b0}};
			LCD_B <= {8{1'b0}};
			DATA_SOF <= 1'b0;
			DATA_COL <= {9{1'b0}};
			DATA_ROW <= {9{1'b0}};
			
			DATA_ROW_INV <= 9'h000;
			
			hsync_line_start <= 1'b0;
			vsync_frame_start <= 1'b0;
			hsync_interval_counter <= HSYNC_INTERVAL_LOADVAL;
			hsync_pulse_counter <= HSYNC_PULSE_LOADVAL;
			vsync_interval_counter <= VSYNC_INTERVAL_LOADVAL;
			vsync_pulse_counter <= VSYNC_PULSE_LOADVAL;
			State <= S0;
		
		
		
		end
		else
		begin
			case(State)
				S0:
				begin
					DATA_SOF <= 1'b0;
					hsync_line_start <= 1'b1;
					vsync_frame_start <= 1'b1;
					LCD_DISP <= 1'b0;
					LCD_CK <= 1'b0;
					LCD_HSYNC <= 1'b1;
					LCD_VSYNC <= 1'b1;
					LCD_R <= {8{1'b0}};
					LCD_G <= {8{1'b0}};
					LCD_B <= {8{1'b0}};
					
					if(ENABLE)
					begin
						State <= S1;
					end
					
				
				
				end
				
				S1:
				begin
					LCD_CK <= 1'b0;
					
					if(hsync_line_start)
					begin
						hsync_interval_counter <= HSYNC_INTERVAL_LOADVAL;
						hsync_pulse_counter <= HSYNC_PULSE_LOADVAL;
					end
					else
					begin
						hsync_interval_counter <= hsync_interval_counter + 1'b1;
						hsync_pulse_counter <= hsync_pulse_counter + 1'b1;
					end
					
					
					if(vsync_frame_start)
					begin
						vsync_interval_counter <= VSYNC_INTERVAL_LOADVAL;
						vsync_pulse_counter <= VSYNC_PULSE_LOADVAL;
						DATA_SOF <= 1'b1;
					end
					else if(hsync_line_start)
					begin
						vsync_interval_counter <= vsync_interval_counter + 1'b1;
						vsync_pulse_counter <= vsync_pulse_counter + 1'b1;
						DATA_SOF <= 1'b0;
					end
					else
					begin
						DATA_SOF <= 1'b0;
					end
					
					if(ENABLE)
					begin
						State <= S2;
					end
					else
					begin
						State <= S0;
					end
				
				
				
				end
				
				
				S2:
				begin
					LCD_CK <= 1'b1;
					
					if(vsync_interval_tick)
					begin
						LCD_DISP <= DISP_ENABLE;
					end
					LCD_HSYNC <= hsync_pulse_active;
					LCD_VSYNC <= (vsync_pulse_active & ~vsync_interval_tick);
					LCD_R <= (hsync_pulse_active & vsync_pulse_active) ? DATA_R : 8'h00;
					LCD_G <= (hsync_pulse_active & vsync_pulse_active) ? DATA_G : 8'h00;
					LCD_B <= (hsync_pulse_active & vsync_pulse_active) ? DATA_B : 8'h00;
					hsync_line_start <= hsync_interval_tick;
					vsync_frame_start <= vsync_interval_tick;
					DATA_COL <= hsync_pulse_counter[8:0];
					DATA_ROW <= vsync_pulse_counter[8:0];
					
					DATA_ROW_INV <= 9'd274 - vsync_pulse_counter[8:0];
					

					State <= S1;
				
				end
			
			
			
			endcase
		
		
		
		
		
		end
	
	
	
	end
	
endmodule
=======
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    11:15:00 04/08/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #7 Project
// Module Name:    LCD_RGB_Display_Interface
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    LCD RGB Display Interface
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module LCD_RGB_Display_Interface
#(
	parameter CLK_RATE_HZ = 18000000
)
(
	// Control Signals
	input ENABLE,
	input DISP_ENABLE,
	
	// Pixel Data Signals
	output reg       DATA_SOF,	
	output reg [8:0] DATA_COL,
	output reg [8:0] DATA_ROW,
	input      [7:0] DATA_R,
	input      [7:0] DATA_G,
	input      [7:0] DATA_B,
	
	// LCD RGB Interface Signals
	output reg       LCD_DISP,
	output reg       LCD_CK,
	output reg       LCD_HSYNC,
	output reg       LCD_VSYNC,
	output reg [7:0] LCD_R,
	output reg [7:0] LCD_G,
	output reg [7:0] LCD_B,
	
	output reg [8:0] DATA_ROW_INV,

	// System Signals
	input CLK,
	input RESET
);

	// Include StdFunctions for bit_index()
	`include "StdFunctions.vh"

	//
	// Display Timing Parameters for Sharp LQ043 TFT LCD panel
	//
	localparam TH  = 525;  // Hsync Total Period (clks)
	localparam THp = 41;   // Hsync Pulse Width (clks)
	localparam THd = 480;  // Hsync Data Period (clks)
	localparam THb = 2;    // Hsync Back Porch (clks)
	localparam THf = 2;    // Hsync Front Porch (clks)
	localparam TV  = 286;  // Vsync Total Period (lines)
	localparam TVp = 10;   // Vsync Pulse Width (lines)
	localparam TVd = 272;  // Vsync Data Period (lines)
	localparam TVb = 2;    // Vsync Back Porch (lines)
	localparam TVf = 2;    // Vsync Front Porch (lines)
	
	
	//
	// Horizontal Counter Parameters
	//
	localparam HSYNC_INTERVAL_TICKS = TH;
	localparam HSYNC_INTERVAL_WIDTH = bit_index(HSYNC_INTERVAL_TICKS);
	localparam [HSYNC_INTERVAL_WIDTH:0] HSYNC_INTERVAL_LOADVAL = {1'b1, {HSYNC_INTERVAL_WIDTH{1'b0}}} - HSYNC_INTERVAL_TICKS[HSYNC_INTERVAL_WIDTH:0] + 1'b1;

	localparam HSYNC_PULSE_TICKS = THp;
	localparam [HSYNC_INTERVAL_WIDTH:0] HSYNC_PULSE_LOADVAL = {1'b1, {HSYNC_INTERVAL_WIDTH{1'b0}}} - HSYNC_PULSE_TICKS[HSYNC_INTERVAL_WIDTH:0];
	
	reg [HSYNC_INTERVAL_WIDTH:0] hsync_interval_counter;
	reg [HSYNC_INTERVAL_WIDTH:0] hsync_pulse_counter;
	
	wire hsync_interval_tick = hsync_interval_counter[HSYNC_INTERVAL_WIDTH];
	wire hsync_pulse_active = hsync_pulse_counter[HSYNC_INTERVAL_WIDTH];
		
	
	//
	// Vertical Counter Parameters
	//
	localparam VSYNC_INTERVAL_TICKS = TV;
	localparam VSYNC_INTERVAL_WIDTH = bit_index(VSYNC_INTERVAL_TICKS);
	localparam [VSYNC_INTERVAL_WIDTH:0] VSYNC_INTERVAL_LOADVAL = {1'b1, {VSYNC_INTERVAL_WIDTH{1'b0}}} - VSYNC_INTERVAL_TICKS[VSYNC_INTERVAL_WIDTH:0];
	
	localparam VSYNC_PULSE_TICKS = TVp;
	localparam [VSYNC_INTERVAL_WIDTH:0] VSYNC_PULSE_LOADVAL = {1'b1, {VSYNC_INTERVAL_WIDTH{1'b0}}} - VSYNC_PULSE_TICKS[VSYNC_INTERVAL_WIDTH:0];
	
	reg [VSYNC_INTERVAL_WIDTH:0] vsync_interval_counter;
	reg [VSYNC_INTERVAL_WIDTH:0] vsync_pulse_counter;
	
	wire vsync_interval_tick = vsync_interval_counter[VSYNC_INTERVAL_WIDTH];
	wire vsync_pulse_active = vsync_pulse_counter[VSYNC_INTERVAL_WIDTH];
	
	
	//
	// Display State Machine
	//
	reg [2:0] State;
	localparam [2:0]
		S0 = 3'b001,
		S1 = 3'b010,
		S2 = 3'b100;
	
	reg hsync_line_start;
	reg vsync_frame_start;
	
	// TASK: State Machine Implementation
	
	always @(posedge CLK)
	begin 
	
		if(RESET)
		begin
			LCD_DISP <= 1'b0;
			LCD_CK <= 1'b0;
			LCD_HSYNC <= 1'b1;
			LCD_VSYNC <= 1'b1;
			LCD_R <= {8{1'b0}};
			LCD_G <= {8{1'b0}};
			LCD_B <= {8{1'b0}};
			DATA_SOF <= 1'b0;
			DATA_COL <= {9{1'b0}};
			DATA_ROW <= {9{1'b0}};
			
			DATA_ROW_INV <= 9'h000;
			
			hsync_line_start <= 1'b0;
			vsync_frame_start <= 1'b0;
			hsync_interval_counter <= HSYNC_INTERVAL_LOADVAL;
			hsync_pulse_counter <= HSYNC_PULSE_LOADVAL;
			vsync_interval_counter <= VSYNC_INTERVAL_LOADVAL;
			vsync_pulse_counter <= VSYNC_PULSE_LOADVAL;
			State <= S0;
		
		
		
		end
		else
		begin
			case(State)
				S0:
				begin
					DATA_SOF <= 1'b0;
					hsync_line_start <= 1'b1;
					vsync_frame_start <= 1'b1;
					LCD_DISP <= 1'b0;
					LCD_CK <= 1'b0;
					LCD_HSYNC <= 1'b1;
					LCD_VSYNC <= 1'b1;
					LCD_R <= {8{1'b0}};
					LCD_G <= {8{1'b0}};
					LCD_B <= {8{1'b0}};
					
					if(ENABLE)
					begin
						State <= S1;
					end
					
				
				
				end
				
				S1:
				begin
					LCD_CK <= 1'b0;
					
					if(hsync_line_start)
					begin
						hsync_interval_counter <= HSYNC_INTERVAL_LOADVAL;
						hsync_pulse_counter <= HSYNC_PULSE_LOADVAL;
					end
					else
					begin
						hsync_interval_counter <= hsync_interval_counter + 1'b1;
						hsync_pulse_counter <= hsync_pulse_counter + 1'b1;
					end
					
					
					if(vsync_frame_start)
					begin
						vsync_interval_counter <= VSYNC_INTERVAL_LOADVAL;
						vsync_pulse_counter <= VSYNC_PULSE_LOADVAL;
						DATA_SOF <= 1'b1;
					end
					else if(hsync_line_start)
					begin
						vsync_interval_counter <= vsync_interval_counter + 1'b1;
						vsync_pulse_counter <= vsync_pulse_counter + 1'b1;
						DATA_SOF <= 1'b0;
					end
					else
					begin
						DATA_SOF <= 1'b0;
					end
					
					if(ENABLE)
					begin
						State <= S2;
					end
					else
					begin
						State <= S0;
					end
				
				
				
				end
				
				
				S2:
				begin
					LCD_CK <= 1'b1;
					
					if(vsync_interval_tick)
					begin
						LCD_DISP <= DISP_ENABLE;
					end
					LCD_HSYNC <= hsync_pulse_active;
					LCD_VSYNC <= (vsync_pulse_active & ~vsync_interval_tick);
					LCD_R <= (hsync_pulse_active & vsync_pulse_active) ? DATA_R : 8'h00;
					LCD_G <= (hsync_pulse_active & vsync_pulse_active) ? DATA_G : 8'h00;
					LCD_B <= (hsync_pulse_active & vsync_pulse_active) ? DATA_B : 8'h00;
					hsync_line_start <= hsync_interval_tick;
					vsync_frame_start <= vsync_interval_tick;
					DATA_COL <= hsync_pulse_counter[8:0];
					DATA_ROW <= vsync_pulse_counter[8:0];
					
					DATA_ROW_INV <= 9'd274 - vsync_pulse_counter[8:0];
					

					State <= S1;
				
				end
			
			
			
			endcase
		
		
		
		
		
		end
	
	
	
	end
	
endmodule
>>>>>>> 5c0e9cfc3a367921175bd02b7a161392474dce77
