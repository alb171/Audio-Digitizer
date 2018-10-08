`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    11:29:00 04/11/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #7 Project
// Module Name:    EECS301_Lab7_Analyzer_TopLevel
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    EECS301 Lab7 Analyzer TopLevel
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module EECS301_Lab7_Analyzer_TopLevel
#(
	parameter SIM_PATH = "",
	parameter SW_DEBOUNCE_TIME = 10000000, // ns
	parameter WM8731_POWER_ON_DELAY = 1000000 // ns
)
(
	// Clock Input Signals
	input   CLOCK_50,

	// LED Status Signals
	output [9:0] LEDR,

	// Switch Signals
	input  [9:0] SW,

	// Key Signals
	input  [0:0] KEY,
	
	// I2C Bus Signals
	output  FPGA_I2C_SCLK,
	inout   FPGA_I2C_SDAT,
	
	// Audio Codec Bus Signals
	output  AUD_XCK,
	output  AUD_BCLK,
	output  AUD_DACLRCK,
	output  AUD_DACDAT,
	output  AUD_ADCLRCK,
	input   AUD_ADCDAT,

	// LCD Bus Signals (GPIO1)
	output LCD_R0,    // GPIO1_D1
	output LCD_R1,    // GPIO1_D3
	output LCD_R2,    // GPIO1_D4
	output LCD_R3,    // GPIO1_D5
	output LCD_R4,    // GPIO1_D6
	output LCD_R5,    // GPIO1_D7
	output LCD_R6,    // GPIO1_D8
	output LCD_R7,    // GPIO1_D9
	output LCD_G0,    // GPIO1_D10
	output LCD_G1,    // GPIO1_D11
	output LCD_G2,    // GPIO1_D12
	output LCD_G3,    // GPIO1_D13
	output LCD_G4,    // GPIO1_D14
	output LCD_G5,    // GPIO1_D15
	output LCD_G6,    // GPIO1_D17
	output LCD_G7,    // GPIO1_D19
	output LCD_B0,    // GPIO1_D20
	output LCD_B1,    // GPIO1_D21
	output LCD_B2,    // GPIO1_D22
	output LCD_B3,    // GPIO1_D23
	output LCD_B4,    // GPIO1_D24
	output LCD_B5,    // GPIO1_D25
	output LCD_B6,    // GPIO1_D26
	output LCD_B7,    // GPIO1_D27
	output LCD_CK,    // GPIO1_D28
	output LCD_DISP,  // GPIO1_D29
	output LCD_HSYNC, // GPIO1_D30
	output LCD_VSYNC  // GPIO1_D31	
);


	///////////////////////////////////////////////////////////
	//
	// System Clocks / Resets Manager
	//
	// WARNING: These rate parameters are not adjustable without  
	//          also reconfiguring the PLL IP Core used in the 
	//          System_Clock_Reset_Manager module.
	//
	localparam REF_CLK_RATE_HZ = 50000000; // 50 MHz
	localparam LCD_CLK_RATE_HZ = 18000000; // 18 MHz
	localparam AUD_CLK_RATE_HZ = 18432000; // 18.432 MHZ
	
	wire lcd_clk;
	wire lcd_reset;
	wire aud_clk;
	wire aud_reset;
	
	System_Clock_Reset_Manager
	#(
		.REF_CLK_RATE_HZ( REF_CLK_RATE_HZ ),
		.LCD_CLK_RATE_HZ( LCD_CLK_RATE_HZ ),
		.AUD_CLK_RATE_HZ( AUD_CLK_RATE_HZ )
	)
	sys_clk_manager
	(
		// Reference Clock Signal
		.REF_CLK( CLOCK_50 ),
		
		// LCD Clock Domain Signals
		.LCD_CLK( lcd_clk ),
		.LCD_RESET( lcd_reset ),
		
		// Audio Codec Domain Signals
		.AUD_CLK( aud_clk ),
		.AUD_RESET( aud_reset )
	);
	
	
	///////////////////////////////////////////////////////////
	//
	// Switch Bank Controller
	//
	wire [9:0] sw_sync;
	
	// Use LEDs as switch status indicators.
	assign LEDR = sw_sync;
	
	Switch_Bank_Synchronizer
	#(
		.CLK_RATE_HZ( AUD_CLK_RATE_HZ ),
		.SWITCH_NUM( 10 ),
		.DEBOUNCE_TIME( SW_DEBOUNCE_TIME )
	)
	switch_sync_bank
	(
		// Input  Signals (asynchronous)
		.SIG_IN( SW ),
		
		// Output Signals (synchronized to CLK domain)
		.SIG_OUT( sw_sync ),
		
		// System Signals
		.CLK( aud_clk )
	);

	
	///////////////////////////////////////////////////////////
	//
	// WM8731 Audio Codec Controller
	//	
	localparam ADC_DATA_WIDTH = 16;

	wire                      adc_rchan_ready;
	wire [ADC_DATA_WIDTH-1:0] adc_rchan_data;
	wire                      adc_lchan_ready;
	wire [ADC_DATA_WIDTH-1:0] adc_lchan_data;
	
	// TASK: Instantiate audio_codec_controller here...
	
	WM8731_Audio_Codec_Module
#(
	.CLK_RATE_HZ( AUD_CLK_RATE_HZ ),
	.I2C_BUS_RATE( 400 ),
	.DAC_DATA_WIDTH( ADC_DATA_WIDTH ),
	.POWER_ON_DELAY( WM8731_POWER_ON_DELAY )
)
	audio_codec_controller

(
	//Signals 
		// DAC Data Channels
		.DAC_RCHAN_DATA( adc_rchan_data ),
		.DAC_LCHAN_DATA( adc_lchan_data ),
		.DAC_RCHAN_TRIG(  ),
		.DAC_LCHAN_TRIG(  ),
		
		// ADC Data Channels
		.ADC_RCHAN_READY( adc_rchan_ready ),
		.ADC_RCHAN_DATA( adc_rchan_data ),
		.ADC_LCHAN_READY( adc_lchan_ready ),
		.ADC_LCHAN_DATA( adc_lchan_data ),
	
		// WM8731 I2C Configuration Bus Signals
		.I2C_SCLK( FPGA_I2C_SCLK ),
		.I2C_SDAT( FPGA_I2C_SDAT ),
		
		// DAC Codec Signals
		.AUD_XCK ( AUD_XCK ),
		.AUD_BCLK( AUD_BCLK ),
		.AUD_DACLRCK( AUD_DACLRCK ),
		.AUD_DACDAT( AUD_DACDAT ),
		.AUD_ADCLRCK( AUD_ADCLRCK ),
		.AUD_ADCDAT( AUD_ADCDAT ),
				
		// System Signals
		.CLK( aud_clk ),
		.RESET( aud_reset )
		
	
);

	
	///////////////////////////////////////////////////////////
	//
	// Audio Channel Spectrum Analyzers
	//
	localparam FFT_FRAME_SIZE = 512;
	localparam SCALED_WIDTH = 10;
	
	//
	// Left Channel
	//
	wire                    frame_valid_lchan;
	wire                    frame_start_lchan;
	wire                    frame_end_lchan;
	wire [SCALED_WIDTH-1:0] frame_data_lchan;
	
	// TASK: Instantiate audio_stream_analyzer_lchan here...
	
	Audio_Stream_Spectrum_Analyzer
#(
	.CLK_RATE_HZ( AUD_CLK_RATE_HZ ),
	.DATA_WIDTH( ADC_DATA_WIDTH ),
	.FRAME_SAMPLES( FFT_FRAME_SIZE )
)
	audio_stream_analyzer_lchan

(
	// Signals
		.ENABLE( 1'b1 ),
		.ADC_CHAN_TRIG( adc_lchan_ready ),
		.ADC_CHAN_DATA( adc_lchan_data ),
		.LCD_FRAME_VALID( frame_valid_lchan ),
		.LCD_FRAME_START( frame_start_lchan ),
		.LCD_FRAME_END( frame_end_lchan ),
		.LCD_FRAME_DATA( frame_data_lchan ),
		.CLK( aud_clk ),
		.RESET( aud_reset )
);
	

	//
	// Right Channel
	//
	wire                    frame_valid_rchan;
	wire                    frame_start_rchan;
	wire                    frame_end_rchan;
	wire [SCALED_WIDTH-1:0] frame_data_rchan;
	
	// TASK: Instantiate audio_stream_analyzer_rchan here...
	
	Audio_Stream_Spectrum_Analyzer
#(
	.CLK_RATE_HZ( AUD_CLK_RATE_HZ ),
	.DATA_WIDTH( ADC_DATA_WIDTH ),
	.FRAME_SAMPLES( FFT_FRAME_SIZE )
)
	audio_stream_analyzer_rchan

(
	// Signals
		.ENABLE( 1'b1 ),
		.ADC_CHAN_TRIG( adc_rchan_ready ),
		.ADC_CHAN_DATA( adc_rchan_data ),
		.LCD_FRAME_VALID( frame_valid_rchan ),
		.LCD_FRAME_START( frame_start_rchan ),
		.LCD_FRAME_END( frame_end_rchan ),
		.LCD_FRAME_DATA( frame_data_rchan ),
		.CLK( aud_clk ),
		.RESET( aud_reset )
);
	
	
	
	
	///////////////////////////////////////////////////////////
	//
	// LCD Display Sample Buffer
	//
	wire        lcd_data_sof;
	wire  [8:0] lcd_data_col;

	wire  [SCALED_WIDTH-1:0] lcd_data_lchan;
	wire  [SCALED_WIDTH-1:0] lcd_data_rchan;
	
	LCD_Display_Sample_Buffer
	#(
		.DATA_WIDTH( SCALED_WIDTH )
	)
	lcd_sample_buffer_lchan
	(
		// Audio DAC Interface Signals (AUD_CLK Domain)
		.AUD_DAC_FRAME_START( frame_start_lchan ),
		.AUD_DAC_FRAME_DONE( frame_end_lchan ),
		.AUD_DAC_DATA_WR(frame_valid_lchan ),
		.AUD_DAC_DATA( frame_data_lchan ),
		.AUD_CLK( aud_clk ),
		
		// LCD Display Interface Signals (LCD_CLK Domain)
		.LCD_COL( lcd_data_col ),
		.LCD_DATA( lcd_data_lchan ),
		.LCD_CLK( lcd_clk )
	);


	LCD_Display_Sample_Buffer
	#(
		.DATA_WIDTH( SCALED_WIDTH )
	)
	lcd_sample_buffer_rchan
	(
		// Audio DAC Interface Signals (AUD_CLK Domain)
		.AUD_DAC_FRAME_START( frame_start_rchan ),
		.AUD_DAC_FRAME_DONE( frame_end_rchan ),
		.AUD_DAC_DATA_WR(frame_valid_rchan ),
		.AUD_DAC_DATA( frame_data_rchan ),
		.AUD_CLK( aud_clk ),
		
		// LCD Display Interface Signals (LCD_CLK Domain)
		.LCD_COL( lcd_data_col ),
		.LCD_DATA( lcd_data_rchan ),
		.LCD_CLK( lcd_clk )
	);
	
	
	///////////////////////////////////////////////////////////
	//
	// LCD RGB Display Interface
	//
	reg  [23:0] lcd_data_rgb;
	wire  [8:0] lcd_data_row;
	wire  [8:0] lcd_data_row_inv;
	wire  [1:0] lcd_data_sel;
	
	assign lcd_data_sel[0] = (lcd_data_lchan[8:0] > lcd_data_row_inv) ? 1'b1 : 1'b0;
	assign lcd_data_sel[1] = (lcd_data_rchan[8:0] > lcd_data_row_inv) ? 1'b1 : 1'b0;
	
	always @*
	begin
		case (lcd_data_sel)
			2'h0 : lcd_data_rgb <= 24'h000000;  // Black
			2'h1 : lcd_data_rgb <= 24'hFF0000;  // Light Blue
			2'h2 : lcd_data_rgb <= 24'h00FF00;  // Green
			2'h3 : lcd_data_rgb <= 24'h9999FF;  // Aqua
		endcase
	end

	wire lcd_enable_n;
	wire lcd_disp_enable_n;
	
	localparam LCD_ENABLE_POWER_ON_DELAY = 50000000;
	localparam LCD_DISP_POWER_ON_DELAY = 500000000;
	
	Reset_Module
	#(
		.REF_CLK_RATE_HZ( LCD_CLK_RATE_HZ ),
		.POWER_ON_DELAY( LCD_ENABLE_POWER_ON_DELAY )
	)
	lcd_powerup_enable_delay
	(
		// Input Signals
		.PLL_LOCKED( ~lcd_reset ),
		.REF_CLK( lcd_clk ),
		
		// Output Signals
		.RESET( lcd_enable_n )
	);
	
	Reset_Module
	#(
		.REF_CLK_RATE_HZ( LCD_CLK_RATE_HZ ),
		.POWER_ON_DELAY( LCD_DISP_POWER_ON_DELAY )
	)
	lcd_powerup_disp_enable_delay
	(
		// Input Signals
		.PLL_LOCKED( ~lcd_reset ),
		.REF_CLK( lcd_clk ),
		
		// Output Signals
		.RESET( lcd_disp_enable_n )
	);
	
	LCD_RGB_Display_Interface
	#(
		.CLK_RATE_HZ( LCD_CLK_RATE_HZ )
	)
	lcd_display_if
	(
		// Control Signals
		.ENABLE( ~lcd_enable_n ),
		.DISP_ENABLE( ~lcd_disp_enable_n ),
		
		// Pixel Data Signals
		.DATA_SOF( lcd_data_sof ),
		.DATA_COL( lcd_data_col ),
		.DATA_ROW( lcd_data_row ),
		.DATA_ROW_INV( lcd_data_row_inv ),
		.DATA_R( lcd_data_rgb[23:16] ),
		.DATA_G( lcd_data_rgb[15:8] ),
		.DATA_B( lcd_data_rgb[7:0] ),
		
		// LCD RGB Interface Signals
		.LCD_DISP( LCD_DISP ),
		.LCD_CK( LCD_CK ),
		.LCD_HSYNC( LCD_HSYNC ),
		.LCD_VSYNC( LCD_VSYNC ),
		.LCD_R( { LCD_R7, LCD_R6, LCD_R5, LCD_R4, LCD_R3, LCD_R2, LCD_R1, LCD_R0 } ),
		.LCD_G( { LCD_G7, LCD_G6, LCD_G5, LCD_G4, LCD_G3, LCD_G2, LCD_G1, LCD_G0 } ),
		.LCD_B( { LCD_B7, LCD_B6, LCD_B5, LCD_B4, LCD_B3, LCD_B2, LCD_B1, LCD_B0 } ),

		// System Signals
		.CLK( lcd_clk ),
		.RESET( lcd_reset )
	);

endmodule
