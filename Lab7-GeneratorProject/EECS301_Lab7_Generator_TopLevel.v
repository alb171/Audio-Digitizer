`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    11:21:00 04/09/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #7 Project
// Module Name:    EECS301_Lab7_Generator_TopLevel
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    EECS301 Lab7 Generator TopLevel
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module EECS301_Lab7_Generator_TopLevel
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

	wire key_force_trigger;
	
	Key_Synchronizer_Module
	#(
		.CLK_RATE( AUD_CLK_RATE_HZ ),
		.KEY_LOCK_DELAY( 800 ) // mS
	)
	key_sync
	(
		// Input Signals
		.KEY( KEY[0] ),
		
		// Output Signals
		.KEY_EVENT( key_force_trigger ),
		
		// System Signals
		.CLK( aud_clk )
	);
	
	
	///////////////////////////////////////////////////////////
	//
	// DDS Audio Mixer Generators
	//
	localparam DAC_DATA_WIDTH = 16;
	
	wire [DAC_DATA_WIDTH-1:0] dac_lchan_data;
	wire [DAC_DATA_WIDTH-1:0] dac_rchan_data;
	
	// Left Channel Mixer

	// TASK: Instantiate audio_left_channel_mixer here...
	
	
	DDS_Audio_Mixer_Module
	#(
		.CLK_RATE_HZ(AUD_CLK_RATE_HZ), 
		.WF_INIT_FILE({SIM_PATH, "dds_sine_waveform.dat"}),
		.WF_ADDR_WIDTH(11),
		.WF_DATA_WIDTH(16)
	
	)
	audio_left_channel_mixer
	(
	
	.ENABLE_1KHZ(sw_sync[5]),
	.ENABLE_3KHZ(sw_sync[6]),
	.ENABLE_5KHZ(sw_sync[7]),
	.ENABLE_7KHZ(sw_sync[8]),
	.ENABLE_10KHZ(sw_sync[9]),

	
	.DAC_MIXER_OUTPUT(dac_lchan_data),
	
	
	.CLK(aud_clk),
	.RESET(aud_reset)
	
	
	);
	
	// Right Channel Mixer

	// TASK: Instantiate audio_right_channel_mixer here...
	DDS_Audio_Mixer_Module
	#(
		.CLK_RATE_HZ(AUD_CLK_RATE_HZ), 
		.WF_INIT_FILE({SIM_PATH, "dds_sine_waveform.dat"}),
		.WF_ADDR_WIDTH(11),
		.WF_DATA_WIDTH(16)
	
	)
	audio_right_channel_mixer
	(
	
	.ENABLE_1KHZ(sw_sync[0]),
	.ENABLE_3KHZ(sw_sync[1]),
	.ENABLE_5KHZ(sw_sync[2]),
	.ENABLE_7KHZ(sw_sync[3]),
	.ENABLE_10KHZ(sw_sync[4]),

	
	.DAC_MIXER_OUTPUT(dac_rchan_data),
	
	
	.CLK(aud_clk),
	.RESET(aud_reset)
	
	
	);
	

	///////////////////////////////////////////////////////////
	//
	// WM8731 Audio Codec Controller
	//
	wire dac_rchan_trig;
	wire dac_lchan_trig;
	
	// TASK: Instantiate audio_codec_controller here...
	WM8731_Audio_Codec_Module
	#(
		.CLK_RATE_HZ(AUD_CLK_RATE_HZ), 
		.I2C_BUS_RATE(400),
		.DAC_DATA_WIDTH(DAC_DATA_WIDTH),
		.POWER_ON_DELAY(WM8731_POWER_ON_DELAY)
	)
	audio_codec_controller
	(
		.DAC_RCHAN_DATA(dac_rchan_data),
		.DAC_LCHAN_DATA(dac_lchan_data),
		.DAC_RCHAN_TRIG(dac_rchan_trig),
		.DAC_LCHAN_TRIG(dac_lchan_trig),
	
	
		.ADC_RCHAN_READY(),
		.ADC_RCHAN_DATA(),
		.ADC_LCHAN_READY(),
		.ADC_LCHAN_DATA(),
		
		.I2C_SCLK(FPGA_I2C_SCLK),
		.I2C_SDAT(FPGA_I2C_SDAT),
		
		
		.AUD_XCK(AUD_XCK),
		.AUD_BCLK(AUD_BCLK),
		.AUD_DACLRCK(AUD_DACLRCK),
		.AUD_DACDAT(AUD_DACDAT),
		.AUD_ADCLRCK(AUD_ADCLRCK),
		.AUD_ADCDAT(AUD_ADCDAT),
		
		
		.CLK(aud_clk),
	   .RESET(aud_reset)
	
	);

	
	///////////////////////////////////////////////////////////
	//
	// DAC Waveform Digitizer
	//
	localparam SCALED_WIDTH = 9;
	
	wire                     dig_frame_start;
	wire                     dig_frame_done;
	wire                     dig_data_wr;
	wire  [SCALED_WIDTH-1:0] dig_data_lchan;
	wire  [SCALED_WIDTH-1:0] dig_data_rchan;
	
	Digitizer_Module
	#(
		.CLK_RATE_HZ( AUD_CLK_RATE_HZ ),
		.SAMPLE_RATE_HZ( 48000 * 4 ),
		.SAMPLE_DATA_WIDTH( DAC_DATA_WIDTH ),
		.SCALED_DATA_WIDTH( SCALED_WIDTH )
	)
	dac_digitizer
	(
		// Control Signals
		.DIGITIZER_ENABLE( key_force_trigger ),
	
		// DAC Sample Data Signals
		.DAC_LCHAN_DATA( dac_lchan_data ),
		.DAC_RCHAN_DATA( dac_rchan_data ),
		
		// LCD Waveform Buffer Signals
		.LCD_FRAME_START( dig_frame_start ),
		.LCD_FRAME_DONE( dig_frame_done ),
		.LCD_DATA_WR( dig_data_wr ),
		.LCD_LCHAN_DATA( dig_data_lchan ),
		.LCD_RCHAN_DATA( dig_data_rchan ),

		// System Signals
		.CLK( aud_clk ),
		.RESET( aud_reset )
	);
	
	
	///////////////////////////////////////////////////////////
	//
	// LCD Display Sample Buffer
	//
	wire        lcd_data_sof;
	wire  [8:0] lcd_data_col;
	
	//
	// Left Channel LCD Sample Buffer
	//	
	wire  [SCALED_WIDTH-1:0] lcd_lchan_data;
	
	LCD_Display_Sample_Buffer
	#(
		.DATA_WIDTH( SCALED_WIDTH )
	)
	lchan_sample_buffer
	(
		// Audio DAC Interface Signals (AUD_CLK Domain)
		.AUD_DAC_FRAME_START( dig_frame_start ),
		.AUD_DAC_FRAME_DONE( dig_frame_done ),
		.AUD_DAC_DATA_WR( dig_data_wr ),
		.AUD_DAC_DATA( dig_data_lchan ),
		.AUD_CLK( aud_clk ),
		
		// LCD Display Interface Signals (LCD_CLK Domain)
		.LCD_COL( lcd_data_col ),
		.LCD_DATA( lcd_lchan_data ),
		.LCD_CLK( lcd_clk )
	);
	
	//
	// Right Channel LCD Sample Buffer
	//
	wire  [SCALED_WIDTH-1:0] lcd_rchan_data;
	
	LCD_Display_Sample_Buffer
	#(
		.DATA_WIDTH( SCALED_WIDTH )
	)
	rchan_sample_buffer
	(
		// Audio DAC Interface Signals (AUD_CLK Domain)
		.AUD_DAC_FRAME_START( dig_frame_start ),
		.AUD_DAC_FRAME_DONE( dig_frame_done ),
		.AUD_DAC_DATA_WR( dig_data_wr ),
		.AUD_DAC_DATA( dig_data_rchan ),
		.AUD_CLK( aud_clk ),
		
		// LCD Display Interface Signals (LCD_CLK Domain)
		.LCD_COL( lcd_data_col ),
		.LCD_DATA( lcd_rchan_data ),
		.LCD_CLK( lcd_clk )
	);
	
	
	///////////////////////////////////////////////////////////
	//
	// LCD RGB Display Interface
	//
	reg  [23:0] lcd_data_rgb;
	wire  [8:0] lcd_data_row;
	wire  [1:0] lcd_data_sel;
	
	// Pixel Enable Selection
	assign lcd_data_sel[0] = (lcd_rchan_data == lcd_data_row) ? 1'b1 : 1'b0;
	assign lcd_data_sel[1] = (lcd_lchan_data == lcd_data_row) ? 1'b1 : 1'b0;
	
	// Pixel Color Table
	always @*
	begin
		case (lcd_data_sel)
			2'h0 : lcd_data_rgb <= 24'h000000;  // Black
			2'h1 : lcd_data_rgb <= 24'h3399FF;  // Light Blue
			2'h2 : lcd_data_rgb <= 24'h66FF66;  // Green
			2'h3 : lcd_data_rgb <= 24'h99FFFF;  // Aqua
		endcase
	end

	//
	// LCD Panel Power-On Delays
	//
	// NOTE: These delays are kludged workarounds for display power-on bug.
	//
	wire lcd_enable_n;
	wire lcd_disp_enable_n;
	
	Reset_Module
	#(
		.REF_CLK_RATE_HZ( LCD_CLK_RATE_HZ ),
		.POWER_ON_DELAY( 10000000 )
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
		.POWER_ON_DELAY( 200000000 )
	)
	lcd_powerup_disp_enable_delay
	(
		// Input Signals
		.PLL_LOCKED( ~lcd_reset ),
		.REF_CLK( lcd_clk ),
		
		// Output Signals
		.RESET( lcd_disp_enable_n )
	);
	
	//
	// LCD Display Interface
	//
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
