`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    11:21:00 04/10/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #7 Project
// Module Name:    Audio_Stream_Digitizer_Display_Scaler
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    Audio Stream Digitizer Display Scaler
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module Audio_Stream_Digitizer_Display_Scaler
#(
	parameter DATA_WIDTH = 16
)
(
	// FFT Result Bus Signals
	input                         FFT_FRAME_READY,
	input                         FFT_FRAME_VALID,
	input                         FFT_FRAME_START,
	input                         FFT_FRAME_END,
	input signed [DATA_WIDTH-1:0] FFT_FRAME_DATA_REAL,
	input signed [DATA_WIDTH-1:0] FFT_FRAME_DATA_IMAG,
	
	// Display Buffer Signals
	output reg       LCD_FRAME_VALID,
	output reg       LCD_FRAME_START,
	output reg       LCD_FRAME_END,
	output reg [9:0] LCD_FRAME_DATA,
	
	// System Signals
	input CLK,
	input RESET
);


	//
	// FFT Complex Result Converter
	//
	reg [DATA_WIDTH*2-1:0] fft_res_reg;

	wire signed [DATA_WIDTH*2-1:0] fft_real_sq = FFT_FRAME_DATA_REAL * FFT_FRAME_DATA_REAL;
	wire signed [DATA_WIDTH*2-1:0] fft_imag_sq = FFT_FRAME_DATA_IMAG * FFT_FRAME_DATA_IMAG;
	wire signed [DATA_WIDTH*2-1:0] fft_res_sum = fft_real_sq + fft_imag_sq + {1'h1, {DATA_WIDTH{1'b0}}};

	initial
	begin
		fft_res_reg <= {DATA_WIDTH*2{1'b0}};
	end
	
	always @(posedge CLK)
	begin
		fft_res_reg = fft_res_sum;
	end

	
	
	//
	// Display Buffer Interface
	//	
	reg [3:0] State;
	localparam [3:0]
		S0 = 4'b0001,
		S1 = 4'b0010,
		S2 = 4'b0100,
		S3 = 4'b1000;

	reg lcd_data_en;
	
	always @(posedge CLK)
	begin
		LCD_FRAME_DATA <= lcd_data_en ? fft_res_reg[DATA_WIDTH +: 10] : {10{1'b0}};
	end
	
	
	always @(posedge CLK, posedge RESET)
	begin
	
		if (RESET)
		begin
		
			LCD_FRAME_VALID <= 1'b0;
			LCD_FRAME_START <= 1'b0;
			LCD_FRAME_END <= 1'b0;
			
			lcd_data_en <= 1'b0;
			
			State <= S0;
			
		end
		else
		begin
		
			case (State)
			
				S0 :
				begin
				
					LCD_FRAME_END <= 1'b0;
					LCD_FRAME_VALID <= 1'b0;

					lcd_data_en <= FFT_FRAME_VALID ? 1'b1 : 1'b0;
					
					if (FFT_FRAME_READY & FFT_FRAME_VALID & FFT_FRAME_START)
						State <= S1;
						
				end
				
				S1 :
				begin
				
					LCD_FRAME_VALID <= 1'b1;
				
					LCD_FRAME_START <= 1'b1;
										
					State <= S2;
					
				end
				
				S2 :
				begin
					
					LCD_FRAME_START <= 1'b0;
					
					if (FFT_FRAME_END)
						State <= S3;
						
				end
	
				S3 :
				begin
				
					LCD_FRAME_END <= 1'b1;
				
					State <= S0;
					
				end
				
			endcase
			
		end
		
	end
	
endmodule
