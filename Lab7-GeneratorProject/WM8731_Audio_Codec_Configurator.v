`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    12:36:00 02/18/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #4 Project
// Module Name:    WM8731_Audio_Codec_Configurator
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    WM8731 Audio Codec Configuration Controller
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module WM8731_Audio_Codec_Configurator
#(
	parameter CLK_RATE_HZ = 50000000,  // Hz
	parameter I2C_BUS_RATE = 400, // kHz
	parameter POWER_ON_DELAY = 1000000 // ns
)
(
	// Status Signals
	output reg CONFIG_COMPLETE,
	
	// WM8731 I2C Configuration Bus Signals
	output I2C_SCLK,
	inout  I2C_SDAT,

	// Logic Analyzer Debug Signals
	output LAD_I2C_SCLK,
	output LAD_I2C_SDAT,
	
	// System Signals
	input CLK,
	input RESET
);
	
	
	//
	// Power-On Configuration Delay after Reset
	//
	wire config_delay;
	
	Reset_Module
	#(
		.REF_CLK_RATE_HZ( CLK_RATE_HZ ),
		.POWER_ON_DELAY( POWER_ON_DELAY )
	)
	reset_controller
	(
		// Input Signals
		.PLL_LOCKED( ~RESET ),
		.REF_CLK( CLK ),
		
		// Output Signals
		.RESET( config_delay )
	);
	

	//
	// WM8731 I2C Configuration Module
	//	
	reg  config_start;
	wire config_done;
	
	WM8731_Config_Module
	#(
		.CLK_RATE_HZ( CLK_RATE_HZ ),
		.I2C_BUS_RATE( I2C_BUS_RATE )
	)
	audio_codec_config
	(
		// Command Signals
		.CMD_RUN( config_start ),
		.CMD_DONE( config_done ),
		
		// Status Signals
		.BUS_NO_ACK(  ),
		
		// I2C Bus Signals
		.I2C_SCLK( I2C_SCLK ),
		.I2C_SDAT( I2C_SDAT ),
		
		// Logic Analyzer Debug Signals
		.LAD_I2C_SCLK( LAD_I2C_SCLK ),
		.LAD_I2C_SDAT( LAD_I2C_SDAT ),

		// System Signals
		.CLK( CLK ),
		.RESET( RESET )
	);
	
	
	//
	// Startup Configuration State Machine
	//
	reg [3:0] State;
	localparam [3:0]
		S0 = 4'b0001,
		S1 = 4'b0010,
		S2 = 4'b0100,
		S3 = 4'b1000;
		
	always @(posedge CLK, posedge RESET)
	begin
	
		if (RESET)
		begin
			
			config_start <= 1'b0;

			CONFIG_COMPLETE <= 1'b0;
			
			State <= S0;
			
		end
		else
		begin
		
			case (State)
			
				S0 :
				begin
				
					if (~config_delay)
						State <= S1;
					
				end
				
				S1 :
				begin
				
					config_start <= 1'b1;
					
					State <= S2;
				
				end
				
				S2 :
				begin
				
					config_start <= 1'b0;
				
					if (config_done)
						State <= S3;
				
				end
				
				S3 :
				begin
				
					// Configuration Complete
					CONFIG_COMPLETE <= 1'b1;
					
				end
				
			endcase
			
		end
				
	end
	


endmodule
