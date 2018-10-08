`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    12:36:00 02/18/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #4 Project
// Module Name:    WM8731_Audio_Codec_Transceiver
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    WM8731 Audio DAC Module
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module WM8731_Audio_Codec_Transceiver
#(
	parameter CLK_RATE_HZ = 18432203, // Hz
	parameter SAMPLE_RATE = 48000, // Hz
	parameter SAMPLE_BITS = 16,
	parameter SAMPLE_CHANS = 2
)
(
	// Control Signals
	input ENABLE,
	
	// DAC Data Channels
	input [SAMPLE_BITS-1:0] DAC_RCHAN_DATA,
	input [SAMPLE_BITS-1:0] DAC_LCHAN_DATA,
	output reg              DAC_RCHAN_TRIG,
	output reg              DAC_LCHAN_TRIG,

	// ADC Data Channels
	output reg                   ADC_RCHAN_READY,
	output reg [SAMPLE_BITS-1:0] ADC_RCHAN_DATA,
	output reg                   ADC_LCHAN_READY,
	output reg [SAMPLE_BITS-1:0] ADC_LCHAN_DATA,
	
	// DAC Codec Signals
	output reg AUD_BCLK,
	output reg AUD_DACLRCK,
	output reg AUD_DACDAT,
	output reg AUD_ADCLRCK,
	input      AUD_ADCDAT,
	
	// Logic Analyzer Debug Signals
	output reg LAD_AUD_BCLK,
	output reg LAD_AUD_DACLRCK,
	output reg LAD_AUD_DACDAT,
	output reg LAD_AUD_ADCLRCK,
	output reg LAD_AUD_ADCDAT,
	
	// System Signals
	input CLK,
	input RESET
);

	// Include StdFunctions for bit_index()
	`include "StdFunctions.vh"
	
	//
	// BCLK Clock Generator
	//
	localparam BCLK_RATE = SAMPLE_RATE * SAMPLE_BITS * SAMPLE_CHANS * 2;
	localparam integer BCLK_TIMER_TICKS = (1.0 * CLK_RATE_HZ) / (1.0 * BCLK_RATE);
	localparam BCLK_TIMER_WIDTH = bit_index(BCLK_TIMER_TICKS);
	localparam [BCLK_TIMER_WIDTH:0] BCLK_TIMER_LOADVAL = {1'b1, {BCLK_TIMER_WIDTH{1'b0}}} - BCLK_TIMER_TICKS[BCLK_TIMER_WIDTH:0] + 1'b1;

	reg [BCLK_TIMER_WIDTH:0] bclk_timer_reg;
	wire                     bclk_timer_tick = bclk_timer_reg[BCLK_TIMER_WIDTH];
	
	initial
	begin
		bclk_timer_reg <= BCLK_TIMER_LOADVAL;
	end
	
	always @(posedge CLK)
	begin
		if (bclk_timer_tick)
			bclk_timer_reg <= BCLK_TIMER_LOADVAL;
		else
			bclk_timer_reg <= bclk_timer_reg + 1'b1;
	end

	
	//
	// Logic Analyzer Debug Registers
	//
	always @(posedge CLK)
	begin
		LAD_AUD_BCLK <= AUD_BCLK;
		LAD_AUD_DACLRCK <= AUD_DACLRCK;
		LAD_AUD_DACDAT <= AUD_DACDAT;
		LAD_AUD_ADCLRCK <= AUD_ADCLRCK;
		LAD_AUD_ADCDAT <= AUD_ADCDAT;
	end

	
	//
	// Audio Bus Transceiver State Machine
	//
	
	reg [4:0] State;
	localparam [4:0]
		S0 = 5'b00001,
		S1 = 5'b00010,
		S2 = 5'b00100,
		S3 = 5'b01000,
		S4 = 5'b10000;

	// Sample Bit Rollover Counter Parameters
	localparam COUNTER_WIDTH = bit_index(SAMPLE_BITS);
	localparam [COUNTER_WIDTH:0] COUNTER_LOADVAL = {1'b1, {COUNTER_WIDTH{1'b0}}} - SAMPLE_BITS[COUNTER_WIDTH:0] + 1'b1;

	// Shift Register Parameter
	localparam SHIFT_REG_WIDTH = SAMPLE_BITS;
	
	reg                        sample_active_channel;
	reg                        sample_next_channel;
	reg      [COUNTER_WIDTH:0] sample_bit_counter;
	reg                        sample_bit_counter_rollover;
	reg  [SHIFT_REG_WIDTH-1:0] sample_dac_reg;
	reg  [SHIFT_REG_WIDTH-1:0] sample_adc_reg;
	
	
	always @(posedge CLK, posedge RESET)
	begin
	
		if (RESET)
		begin
		
			AUD_BCLK <= 1'b0;
			AUD_DACLRCK <= 1'b0;
			AUD_ADCLRCK <= 1'b0;
			AUD_DACDAT <= 1'b0;
		
			ADC_RCHAN_READY <= 1'b0;
			ADC_LCHAN_READY <= 1'b0;
			ADC_RCHAN_DATA <= {SHIFT_REG_WIDTH{1'b0}};
			ADC_LCHAN_DATA <= {SHIFT_REG_WIDTH{1'b0}};
			
			DAC_RCHAN_TRIG <= 1'b0;
			DAC_LCHAN_TRIG <= 1'b0;
		
			sample_active_channel <= 1'b0;
			sample_next_channel <= 1'b0;
			sample_bit_counter <= COUNTER_LOADVAL;
			sample_bit_counter_rollover <= 1'b0;
			sample_dac_reg <= {SHIFT_REG_WIDTH{1'b0}};
			sample_adc_reg <= {SHIFT_REG_WIDTH{1'b0}};
		
			State <= S0;
			
		end
		else
		begin
		
			case (State)
			
				S0 :
				begin

					// Idle the bus signals
					AUD_BCLK <= 1'b0;
					AUD_DACLRCK <= 1'b0;
					AUD_ADCLRCK <= 1'b0;
					AUD_DACDAT <= 1'b0;
					
					// Clear the ADC Data registers
					ADC_RCHAN_DATA <= {SHIFT_REG_WIDTH{1'b0}};
					ADC_LCHAN_DATA <= {SHIFT_REG_WIDTH{1'b0}};	
					
					// Always start on the Left channel
					sample_active_channel <= 1'b1;
				
					// Load Left Channel Data for the first transmission
					sample_dac_reg <= DAC_LCHAN_DATA;
				
					// Assert rollover so sample counter is reloaded after enable
					sample_bit_counter_rollover <= 1'b1;
				
					// Wait for Enable
					if (ENABLE)
						State <= S1;
						
				end
				
				S1 :
				begin
				
					// Wait for next timer tick
					if (bclk_timer_tick)
						State <= S2;
						
				end
				
				S2 :
				begin
				
					// BCLK Falling-Edge
					AUD_BCLK <= 1'b0;

					// Output the next data bit
					AUD_DACDAT <= sample_dac_reg[SHIFT_REG_WIDTH-1];
				
					// Output next active channel on rollover
					if (sample_bit_counter_rollover)
					begin
						AUD_DACLRCK <= sample_active_channel;
						AUD_ADCLRCK <= sample_active_channel;
					end
					
					// Update the active channel on rollover
					if (sample_bit_counter_rollover)
						sample_next_channel <= ~sample_active_channel;
						
					// Reload or increment the sample bit counter
					if (sample_bit_counter_rollover)
						sample_bit_counter <= COUNTER_LOADVAL;
					else
						sample_bit_counter <= sample_bit_counter + 1'b1;
					
					
					// Output the ADC Channel Data on rollover
					if (sample_bit_counter_rollover)
					begin
						if (sample_active_channel)
						begin
							ADC_RCHAN_DATA <= sample_adc_reg;
							ADC_RCHAN_READY <= 1'b1;
						end
						else
						begin
							ADC_LCHAN_DATA <= sample_adc_reg;
							ADC_LCHAN_READY <= 1'b1;
						end
					end
					
					// Check Enabled, otherwise continue
					if (!ENABLE)
						State <= S0;
					else
						State <= S3;
					
				end
				
				S3 :
				begin
				
					// Clear the ADC data ready flags
					ADC_LCHAN_READY <= 1'b0;
					ADC_RCHAN_READY <= 1'b0;
					
					// Set the Sample Triggers on Rollover and Timer Tick
					if (bclk_timer_tick & sample_bit_counter[COUNTER_WIDTH])
					begin
						case (sample_next_channel)
							1'b0 : DAC_RCHAN_TRIG <= 1'b1;
							1'b1 : DAC_LCHAN_TRIG <= 1'b1;
						endcase
					end
						
					// Wait for next timer tick
					if (bclk_timer_tick)
						State <= S4;
						
				end
				
				S4 :
				begin
				
					// BCLK Rising-Edge
					AUD_BCLK <= 1'b1;
					
					// Store the rollover status for usage on the falling edge
					sample_bit_counter_rollover <= sample_bit_counter[COUNTER_WIDTH];
				
					// Update the active channel on rollover
					if (sample_bit_counter[COUNTER_WIDTH])
						sample_active_channel <= sample_next_channel;

					// Load the register or shift the register data
					if (sample_bit_counter[COUNTER_WIDTH])
						sample_dac_reg <= sample_next_channel ? DAC_LCHAN_DATA : DAC_RCHAN_DATA;
					else
						sample_dac_reg <= { sample_dac_reg[SHIFT_REG_WIDTH-2:0], 1'b0 };
				
					// Capture the next ADC data bit
					sample_adc_reg <= { sample_adc_reg[SHIFT_REG_WIDTH-2:0], AUD_ADCDAT };
					
					// Clear the Sample Trigger Signals
					DAC_RCHAN_TRIG <= 1'b0;
					DAC_LCHAN_TRIG <= 1'b0;
					
					State <= S1;
					
				end
				
			endcase
					
		end
		
	end
	
endmodule
