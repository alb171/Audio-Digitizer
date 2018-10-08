`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    12:36:00 02/18/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #4 Project
// Module Name:    WM8731_Config_Module
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    WM8731 Configuration Module
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module WM8731_Config_Module
#(
	parameter CLK_RATE_HZ = 50000000,  // Hz
	parameter I2C_BUS_RATE = 400 // kHz
)
(
	// Command Signals
	input             CMD_RUN,
	output reg        CMD_DONE,
	
	// Status Signals
	output reg        BUS_NO_ACK,
	
	// I2C Bus Signals
	output I2C_SCLK,
	inout  I2C_SDAT,
	
	// Logic Analyzer Debug Signals
	output LAD_I2C_SCLK,
	output LAD_I2C_SDAT,

	// System Signals
	input CLK,
	input RESET
);

	reg [6:0] State;
	localparam [6:0]
		S0  = 7'b0000001,
		S1  = 7'b0000010,
		S2  = 7'b0000100,
		S3  = 7'b0001000,
		S4  = 7'b0010000,
		S5  = 7'b0100000,
		S6  = 7'b1000000;

	
	// WM8731 I2C Bus Address
	localparam [7:0] WM8731_ADDR = { 7'h1A, 1'b0 };
	
	// Default WM8731 Configuration 
	localparam [15:0] CFG_R0 = { 7'h00, 9'h01B }; // L Line-in volume (+3.0dB)
	localparam [15:0] CFG_R1 = { 7'h01, 9'h01B }; // R Line-in volume (+3.0dB)
	localparam [15:0] CFG_R2 = { 7'h02, 9'h079 }; // L Headphone volume (0.0dB)
	localparam [15:0] CFG_R3 = { 7'h03, 9'h079 }; // R Headphone volume (0.0dB)
	localparam [15:0] CFG_R4 = { 7'h04, 9'h012 }; // Analog Audio Ctrl
	localparam [15:0] CFG_R5 = { 7'h05, 9'h000 }; // Digital Audio Ctrl
	localparam [15:0] CFG_R6 = { 7'h06, 9'h000 }; // Power Down Ctrl
	localparam [15:0] CFG_R7 = { 7'h07, 9'h001 }; // Digital Audio Format
	localparam [15:0] CFG_R8 = { 7'h08, 9'h002 }; // Sampling Ctrl
	localparam [15:0] CFG_R9 = { 7'h09, 9'h001 }; // Active Ctrl
	
	//
	// Command Sequence Table
	//
	reg  [4:0] op_addr;
	wire       op_start;
	wire       op_stop;
	wire       op_idle;
	wire       op_done;
	wire       op_ack;
	wire       op_rw;
	wire [3:0] op_data_sel;
	wire [7:0] op_data;

	DROM_Nx32
	#(
		.WIDTH( 18 ),
		.REGOUT( 0 ), // Unregistered Output
		
		// WM8731 Register R0 Write
		.INIT_00( { 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 4'hF, WM8731_ADDR } ),  // Send WM8731 Device Address/Write (0x1A)
		.INIT_01( { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'hF, CFG_R0[15:8] } ), // Send Register Data[15:8]
		.INIT_02( { 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 4'hF, CFG_R0[ 7:0] } ), // Send Register Data[7:0]; Stop; Idle

		// WM8731 Register R1 Write
		.INIT_03( { 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 4'hF, WM8731_ADDR } ),  // Send WM8731 Device Address/Write (0x1A)
		.INIT_04( { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'hF, CFG_R1[15:8] } ), // Send Register Data[15:8]
		.INIT_05( { 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 4'hF, CFG_R1[ 7:0] } ), // Send Register Data[7:0]; Stop; Idle

		// WM8731 Register R2 Write
		.INIT_06( { 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 4'hF,WM8731_ADDR } ),   // Send WM8731 Device Address/Write (0x1A)
		.INIT_07( { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'hF, CFG_R2[15:8] } ), // Send Register Data[15:8]
		.INIT_08( { 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 4'hF, CFG_R2[ 7:0] } ), // Send Register Data[7:0]; Stop; Idle

		// WM8731 Register R3 Write
		.INIT_09( { 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 4'hF, WM8731_ADDR } ),  // Send WM8731 Device Address/Write (0x1A)
		.INIT_0A( { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'hF, CFG_R3[15:8] } ), // Send Register Data[15:8]
		.INIT_0B( { 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 4'hF, CFG_R3[ 7:0] } ), // Send Register Data[7:0]; Stop; Idle

		// WM8731 Register R4 Write
		.INIT_0C( { 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 4'hF, WM8731_ADDR } ),  // Send WM8731 Device Address/Write (0x1A)
		.INIT_0D( { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'hF, CFG_R4[15:8] } ), // Send Register Data[15:8]
		.INIT_0E( { 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 4'hF, CFG_R4[ 7:0] } ), // Send Register Data[7:0]; Stop; Idle

		// WM8731 Register R5 Write
		.INIT_0F( { 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 4'hF, WM8731_ADDR } ),  // Send WM8731 Device Address/Write (0x1A)
		.INIT_10( { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'hF, CFG_R5[15:8] } ), // Send Register Data[15:8]
		.INIT_11( { 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 4'hF, CFG_R5[ 7:0] } ), // Send Register Data[7:0]; Stop; Idle

		// WM8731 Register R6 Write
		.INIT_12( { 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 4'hF, WM8731_ADDR } ),  // Send WM8731 Device Address/Write (0x1A)
		.INIT_13( { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'hF, CFG_R6[15:8] } ), // Send Register Data[15:8]
		.INIT_14( { 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 4'hF, CFG_R6[ 7:0] } ), // Send Register Data[7:0]; Stop; Idle
		
		// WM8731 Register R7 Write
		.INIT_15( { 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 4'hF, WM8731_ADDR } ),  // Send WM8731 Device Address/Write (0x1A)
		.INIT_16( { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'hF, CFG_R7[15:8] } ), // Send Register Data[15:8]
		.INIT_17( { 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 4'hF, CFG_R7[ 7:0] } ), // Send Register Data[7:0]; Stop; Idle

		// WM8731 Register R8 Write
		.INIT_18( { 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 4'hF, WM8731_ADDR } ),  // Send WM8731 Device Address/Write (0x1A)
		.INIT_19( { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'hF, CFG_R8[15:8] } ), // Send Register Data[15:8]
		.INIT_1A( { 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 4'hF, CFG_R8[ 7:0] } ), // Send Register Data[7:0]; Stop; Idle

		// WM8731 Register R9 Write
		.INIT_1B( { 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 4'hF, WM8731_ADDR } ),  // Send WM8731 Device Address/Write (0x1A)
		.INIT_1C( { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'hF, CFG_R9[15:8] } ), // Send Register Data[15:8]
		.INIT_1D( { 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 4'hF, CFG_R9[ 7:0] } ), // Send Register Data[7:0]; Stop; Done
		
		// Unused
		.INIT_1E( { 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'h0, 8'h00 } ), // Done
		.INIT_1F( { 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'h0, 8'h00 } )  // Done
	)
	Command_Sequence_ROM
	(
		// Read Port Signals
		.ADDR( op_addr ),
		.DATA_OUT( { op_done, op_start, op_stop, op_idle, op_ack, op_rw, op_data_sel, op_data } ),
		.CLK( CLK )
	);

	
	//
	// I2C Transceiver
	//
	reg        ts_start;
	wire       ts_done;
	wire       ts_ack_status;
	wire [7:0] ts_rd_data;
	reg  [7:0] ts_wr_data;
	
	I2C_Data_Transceiver
	#(
		.CLK_RATE_HZ( CLK_RATE_HZ ),
		.BUS_RATE( I2C_BUS_RATE )
	)
	i2c_transceiver
	(
		// Control Signals
		.START( ts_start ),
		.DONE( ts_done ),
		
		// Transmission Config Signals
		.START_BIT_ENA( op_start ),
		.STOP_BIT_ENA( op_stop ),
		.IDLE_BUS_ENA( op_idle ),
		.DATA_RW( op_rw ),
		.ACK_RW( ~op_rw ),
		.ACK_VAL( op_ack ),
		.ACK_STATUS( ts_ack_status ),
		
		// Data Signals
		.DATA_WR( ts_wr_data ),
		.DATA_RD( ts_rd_data ),

		// I2C Bus Signals
		.I2C_SCL( I2C_SCLK ),
		.I2C_SDA( I2C_SDAT ),
		
		// Logic Analyzer Debug Signals
		.LAD_I2C_SCLK( LAD_I2C_SCLK ),
		.LAD_I2C_SDAT( LAD_I2C_SDAT ),

		// System Signals
		.CLK( CLK ),
		.RESET( RESET )
	);

	
	//
	// WM8731 Configuration Bus Communications State Machine
	//
	always @(posedge CLK, posedge RESET)
	begin
	
		if (RESET)
		begin
					
			op_addr <= 5'h00;
			
			ts_start <= 1'b0;
			ts_wr_data <= 8'h00;
						
			BUS_NO_ACK <= 1'b0;
			
			CMD_DONE <= 1'b0;
						
			State <= S0;
			
		end
		else
		begin
		
			case (State)
			
				S0 :
				begin

					// Clear the done signals
					CMD_DONE <= 1'b0;
					
					// Start on any pending signal
					if (CMD_RUN)
						State <= S1;
					
				end
				
				S1 :
				begin
				
					// Clear the previous status
					BUS_NO_ACK <= 1'b0;
									
					// Set the operation starting address
					op_addr <= 5'h00;
					
					State <= S2;
				
				end
				
				S2 :
				begin
					
					// Set the output data
					if (~op_rw)
					begin
					
						case (op_data_sel)
							
							4'hF : ts_wr_data <= op_data;

							default : ts_wr_data <= 8'h00;
						endcase
						
					end
					
					// Start the operation command transaction
					ts_start <= 1'b1;
				
					State <= S3;
					
				end
				
				S3 :
				begin
				
					ts_start <= 1'b0;

					// Wait for transaction to complete
					if (ts_done)
						State <= S4;
				
				end
				
				S4 :
				begin
				
					// Check if an ACK bit was received
					if (op_start)
					begin
						if (!ts_ack_status)
						begin
							BUS_NO_ACK <= 1'b1;
						end
					end
					
					// Store the input data
				//	if (op_rw)
				//	begin
				//	
				//		case (op_data_sel)
				//		endcase
				//		
				//	end
					
					// Check if done
					if (op_done)
						State <= S6;
					else
						State <= S5;
				
				end
				
				S5 :
				begin
							
					// Next operation
					op_addr <= op_addr + 1'b1;
				
					State <= S2;
					
				end
				
				S6 :
				begin
				
					// Report Command Done
					CMD_DONE <= 1'b1;
					
					State <= S0;
				
				end
				
			endcase
					
		end
		
	end
	
	
endmodule
