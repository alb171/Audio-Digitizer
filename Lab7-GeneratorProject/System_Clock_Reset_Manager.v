`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    11:14:00 04/09/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #7 Project
// Module Name:    System_Clock_Reset_Manager
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    System Clock and Reset Manager
//	                
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module System_Clock_Reset_Manager
#(
	parameter REF_CLK_RATE_HZ = 50000000,
	parameter LCD_CLK_RATE_HZ = 18000000,
	parameter AUD_CLK_RATE_HZ = 18432000
)
(
	// Reference Clock Signal
	input  REF_CLK,
	
	// LCD Clock Domain Signals
	output LCD_CLK,
	output LCD_RESET,
	
	// Audio Codec Domain Signals
	output AUD_CLK,
	output AUD_RESET
);

	//
	// Startup PLL Reset Signal Generation
	//
	// This Reset controller insures the Reference Clock
	// is active for a few cycles before starting the PLL.
	// 
	wire pll_reset;
	
	Reset_Module
	#(
		.REF_CLK_RATE_HZ( REF_CLK_RATE_HZ ),
		.POWER_ON_DELAY( 100 ) // ns
	)
	pll_reset_ctrl
	(
		// Input Signals
		.PLL_LOCKED( 1'b1 ),
		.REF_CLK( REF_CLK ),
		
		// Output Signals
		.RESET( pll_reset )
	);

	// NOTE: Unfortunately, a single PLL can not accurately
	//       generate both 18.432MHz and 18.000MHz from the same
	//       base multiplier so two PLL Cores will be required.
	
	//
	// Audio Codec Clock Generator (Altera PLL IP Core)
	//
	// PLL Settings: 50 MHz to 18.432 MHz
	//   refclk:   50 MHz
	//   outclk_0: 18.432 MHz
	//
	wire aud_pll_locked;

	AudioCodec_Clock_Generator aud_clk_pll
	(
		.refclk( REF_CLK ),
		.rst( pll_reset ),
		.outclk_0( AUD_CLK ),
		.locked( aud_pll_locked )
	);
	
	// LCD Reset Signal Generation
	Reset_Module
	#(
		.REF_CLK_RATE_HZ( AUD_CLK_RATE_HZ ),
		.POWER_ON_DELAY( 500 ) // ns
	)
	aud_reset_ctrl
	(
		// Input Signals
		.PLL_LOCKED( aud_pll_locked ),
		.REF_CLK( AUD_CLK ),
	
		// Output Signals
		.RESET( AUD_RESET )
	);

	
	//
	// LCD Clock Generator (Altera PLL IP Core)
	//
	// PLL Settings: 50 MHz to 18.000 MHz
	//   refclk:   50 MHz
	//   outclk_0: 18.000 MHz
	//
	wire lcd_pll_locked;

	LCD_Clock_Generator lcd_clk_pll
	(
		.refclk( REF_CLK ),
		.rst( pll_reset ),
		.outclk_0( LCD_CLK ),
		.locked( lcd_pll_locked )
	);
	
	// LCD Reset Signal Generation
	Reset_Module
	#(
		.REF_CLK_RATE_HZ( LCD_CLK_RATE_HZ ),
		.POWER_ON_DELAY( 500 ) // ns
	)
	lcd_reset_ctrl
	(
		// Input Signals
		.PLL_LOCKED( lcd_pll_locked ),
		.REF_CLK( LCD_CLK ),
	
		// Output Signals
		.RESET( LCD_RESET )
	);

endmodule

