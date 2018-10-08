`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    12:36:00 02/18/2017 
// Project Name:   EECS301 Digital Design
// Design Name:    Lab #4 Project
// Module Name:    I2C_Data_Transceiver
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    I2C Data Transceiver
//                 
// Dependencies:   
//
//////////////////////////////////////////////////////////////////////////////////

module I2C_Data_Transceiver
#(
	parameter CLK_RATE_HZ = 50000000,  // Hz
	parameter BUS_RATE = 400  // 400 kHz (for Fast I2C)
)
(
	// Control Signals
	input       START,
	output reg  DONE,
	
	// Transmission Config Signals
	input       START_BIT_ENA,
	input       STOP_BIT_ENA,
	input       IDLE_BUS_ENA,
	input       DATA_RW,
	input       ACK_RW,
	input       ACK_VAL,
	output reg  ACK_STATUS,
	
	// Data Signals
	input      [7:0] DATA_WR,
	output reg [7:0] DATA_RD,

	// I2C Bus Signals
	output reg  I2C_SCL,
	inout       I2C_SDA,
	
	// Logic Analyzer Debug Signals
	output reg  LAD_I2C_SCLK,
	output reg  LAD_I2C_SDAT,
	
	// System Signals
	input CLK,
	input RESET
);

	// Include StdFunctions for bit_index()
	`include "StdFunctions.vh"

	//
	// State Machine Register Definition
	//
	reg [6:0] State;
	localparam [6:0]
		S0  = 7'b0000001,
		S1  = 7'b0000010,
		S2  = 7'b0000100,
		S3  = 7'b0001000,
		S4  = 7'b0010000,
		S5  = 7'b0100000,
		S6  = 7'b1000000;

	
	//
	// I2C_SDA Bi-directional Data Bus Definition
	//
	reg         i2c_data_oe;
	reg         i2c_data_out;
	wire        i2c_data_in;
	
	assign I2C_SDA = i2c_data_oe ? i2c_data_out : 1'bz;
	assign i2c_data_in = I2C_SDA;
	
	//
	// Logic Analyzer Debug Assignments
	//
	
	always @(posedge CLK)
	begin
		LAD_I2C_SDAT <= i2c_data_in;
		LAD_I2C_SCLK <= I2C_SCL;
	end
	
	
	//
	// Command Sequence Table
	//
	// The Command Sequence Table provides the sequencial operation patterns
	//   for various functions the I2C Controller will need to form a full
	//   bus transaction.  The State Machine uses the data from the table for
	//   each operation.  This allows the State Machine to be much smaller but
	//   handle large sequencial data flows.  The table used distrubited RAM.
	//
	reg   [5:0] op_addr;
	wire  [1:0] op_dsel;
	wire        op_doe;
	wire        op_asel;
	wire        op_csel;
	wire        op_val;
	wire        op_done;

	DROM_Nx64
	#(
		.WIDTH( 7 ),
		.REGOUT( 0 ), // Unregistered Output
		
		// Start Bit Sequence
		.INIT_00( { 1'b0, 1'b1, 1'b0, 2'h1, 1'b0, 1'b0 } ), // Set Data Low 
		.INIT_01( { 1'b0, 1'b1, 1'b0, 2'h0, 1'b1, 1'b0 } ), // Set Clock Low
		.INIT_02( { 1'b1, 1'b0, 1'b0, 2'h0, 1'b0, 1'b0 } ), // Done
		
		// Stop Bit Sequence
		.INIT_03( { 1'b0, 1'b1, 1'b0, 2'h1, 1'b0, 1'b0 } ), // Set Data Low
		.INIT_04( { 1'b0, 1'b1, 1'b0, 2'h0, 1'b1, 1'b1 } ), // Set Clock High
		.INIT_05( { 1'b0, 1'b1, 1'b0, 2'h1, 1'b0, 1'b1 } ), // Set Data High
		.INIT_06( { 1'b1, 1'b0, 1'b0, 2'h0, 1'b0, 1'b0 } ), // Done
		
		// Ack Bit Sequence
		.INIT_07( { 1'b0, 1'b0, 1'b1, 2'h1, 1'b0, 1'b0 } ), // Set Data Low 
		.INIT_08( { 1'b0, 1'b0, 1'b1, 2'h0, 1'b1, 1'b1 } ), // Clock Rising Edge
		.INIT_09( { 1'b0, 1'b0, 1'b1, 2'h3, 1'b0, 1'b0 } ), // Nothing
		.INIT_0A( { 1'b0, 1'b0, 1'b1, 2'h0, 1'b1, 1'b0 } ), // Clock Falling Edge
		.INIT_0B( { 1'b1, 1'b0, 1'b1, 2'h0, 1'b0, 1'b0 } ), // Done
		
		// NoAck Bit Sequence
		.INIT_0C( { 1'b0, 1'b1, 1'b0, 2'h1, 1'b0, 1'b1 } ), // Set Data High 
		.INIT_0D( { 1'b0, 1'b1, 1'b0, 2'h0, 1'b1, 1'b1 } ), // Clock Rising Edge
		.INIT_0E( { 1'b0, 1'b1, 1'b0, 2'h0, 1'b0, 1'b0 } ), // Nothing
		.INIT_0F( { 1'b0, 1'b1, 1'b0, 2'h0, 1'b1, 1'b0 } ), // Clock Falling Edge
		.INIT_10( { 1'b1, 1'b0, 1'b0, 2'h0, 1'b0, 1'b0 } ), // Done
		
		// Data Read/Write Sequence
		.INIT_11( { 1'b0, 1'b0, 1'b0, 2'h2, 1'b0, 1'b0 } ), // Write Data Bit
		.INIT_12( { 1'b0, 1'b0, 1'b0, 2'h0, 1'b1, 1'b1 } ), // Clock Rising Edge
		.INIT_13( { 1'b0, 1'b0, 1'b0, 2'h3, 1'b0, 1'b0 } ), // Shift Write Data / Read Data Bit
		.INIT_14( { 1'b0, 1'b0, 1'b0, 2'h0, 1'b1, 1'b0 } ), // Clock Falling Edge
		.INIT_15( { 1'b0, 1'b0, 1'b0, 2'h2, 1'b0, 1'b0 } ), // Write Data Bit
		.INIT_16( { 1'b0, 1'b0, 1'b0, 2'h0, 1'b1, 1'b1 } ), // Clock Rising Edge
		.INIT_17( { 1'b0, 1'b0, 1'b0, 2'h3, 1'b0, 1'b0 } ), // Shift Write Data / Read Data Bit
		.INIT_18( { 1'b0, 1'b0, 1'b0, 2'h0, 1'b1, 1'b0 } ), // Clock Falling Edge
		.INIT_19( { 1'b0, 1'b0, 1'b0, 2'h2, 1'b0, 1'b0 } ), // Write Data Bit
		.INIT_1A( { 1'b0, 1'b0, 1'b0, 2'h0, 1'b1, 1'b1 } ), // Clock Rising Edge
		.INIT_1B( { 1'b0, 1'b0, 1'b0, 2'h3, 1'b0, 1'b0 } ), // Shift Write Data / Read Data Bit
		.INIT_1C( { 1'b0, 1'b0, 1'b0, 2'h0, 1'b1, 1'b0 } ), // Clock Falling Edge
		.INIT_1D( { 1'b0, 1'b0, 1'b0, 2'h2, 1'b0, 1'b0 } ), // Write Data Bit
		.INIT_1E( { 1'b0, 1'b0, 1'b0, 2'h0, 1'b1, 1'b1 } ), // Clock Rising Edge
		.INIT_1F( { 1'b0, 1'b0, 1'b0, 2'h3, 1'b0, 1'b0 } ), // Shift Write Data / Read Data Bit
		.INIT_20( { 1'b0, 1'b0, 1'b0, 2'h0, 1'b1, 1'b0 } ), // Clock Falling Edge
		.INIT_21( { 1'b0, 1'b0, 1'b0, 2'h2, 1'b0, 1'b0 } ), // Write Data Bit
		.INIT_22( { 1'b0, 1'b0, 1'b0, 2'h0, 1'b1, 1'b1 } ), // Clock Rising Edge
		.INIT_23( { 1'b0, 1'b0, 1'b0, 2'h3, 1'b0, 1'b0 } ), // Shift Write Data / Read Data Bit
		.INIT_24( { 1'b0, 1'b0, 1'b0, 2'h0, 1'b1, 1'b0 } ), // Clock Falling Edge
		.INIT_25( { 1'b0, 1'b0, 1'b0, 2'h2, 1'b0, 1'b0 } ), // Write Data Bit
		.INIT_26( { 1'b0, 1'b0, 1'b0, 2'h0, 1'b1, 1'b1 } ), // Clock Rising Edge
		.INIT_27( { 1'b0, 1'b0, 1'b0, 2'h3, 1'b0, 1'b0 } ), // Shift Write Data / Read Data Bit
		.INIT_28( { 1'b0, 1'b0, 1'b0, 2'h0, 1'b1, 1'b0 } ), // Clock Falling Edge
		.INIT_29( { 1'b0, 1'b0, 1'b0, 2'h2, 1'b0, 1'b0 } ), // Write Data Bit
		.INIT_2A( { 1'b0, 1'b0, 1'b0, 2'h0, 1'b1, 1'b1 } ), // Clock Rising Edge
		.INIT_2B( { 1'b0, 1'b0, 1'b0, 2'h3, 1'b0, 1'b0 } ), // Shift Write Data / Read Data Bit
		.INIT_2C( { 1'b0, 1'b0, 1'b0, 2'h0, 1'b1, 1'b0 } ), // Clock Falling Edge
		.INIT_2D( { 1'b0, 1'b0, 1'b0, 2'h2, 1'b0, 1'b0 } ), // Write Data Bit
		.INIT_2E( { 1'b0, 1'b0, 1'b0, 2'h0, 1'b1, 1'b1 } ), // Clock Rising Edge
		.INIT_2F( { 1'b0, 1'b0, 1'b0, 2'h3, 1'b0, 1'b0 } ), // Shift Write Data / Read Data Bit
		.INIT_30( { 1'b0, 1'b0, 1'b0, 2'h0, 1'b1, 1'b0 } ), // Clock Falling Edge
		.INIT_31( { 1'b1, 1'b0, 1'b0, 2'h0, 1'b0, 1'b0 } ), // Done
		
		// Idle Bus Sequence
		.INIT_32( { 1'b0, 1'b1, 1'b0, 2'h1, 1'b0, 1'b1 } ), // Set Data High
		.INIT_33( { 1'b0, 1'b1, 1'b0, 2'h0, 1'b1, 1'b1 } ), // Set Clock High
		.INIT_34( { 1'b1, 1'b0, 1'b0, 2'h0, 1'b0, 1'b0 } )  // Done		
	)
	Command_Sequence_ROM
	(
		// Read Port Signals
		.ADDR( op_addr ),
		.DATA_OUT( { op_done, op_doe, op_asel, op_dsel, op_csel, op_val } ),
		.CLK( CLK )
	);


	//
	// Bus Rate Timer
	//
	// The I2C Bus Rate is much slower than the system clock so the State Machine
	//   will need paced to output bit changes at the bus rate.  
	// The Tick Rate will be 4 times the Bus Rate so the State Machine can transition
	//   the clock and read the data on quarter cycles of the Bus Clock.  This is
	//   needed for the Start and Stop Bit generation in particular.
	//
	reg         tick_reset;
	wire        tick;
	
	// Compute Bus Timer Parameters
	localparam integer FSM_ADJ_TICKS = 2;
	localparam integer TIMER_TICKS = ((CLK_RATE_HZ / (BUS_RATE * 1000.0)) / 4.0);
	localparam integer TIMER_ADJ_TICKS = (CLK_RATE_HZ / (4.0 * TIMER_TICKS)) > (BUS_RATE * 1000.0) ? TIMER_TICKS - FSM_ADJ_TICKS + 1 : TIMER_TICKS - FSM_ADJ_TICKS;
	localparam TIMER_WIDTH = bit_index(TIMER_ADJ_TICKS);
	localparam [TIMER_WIDTH:0] TIMER_LOADVAL = {1'b1, {TIMER_WIDTH{1'b0}}} - TIMER_ADJ_TICKS[TIMER_WIDTH:0];

	reg [TIMER_WIDTH:0] tick_count_reg;

	assign tick = tick_count_reg[TIMER_WIDTH];
	
	always @(posedge CLK, posedge tick_reset)
	begin
		if (tick_reset)
			tick_count_reg <= TIMER_LOADVAL;
		else
			tick_count_reg <= tick_count_reg + 1'b1;
	end

	
	//
	// Bus State Machine
	//	
	reg       cmd_start_bit;
	reg       cmd_data_bits;
	reg       cmd_ack_bit;
	reg       cmd_noack_bit;
	reg       cmd_stop_bit;
	reg       cmd_idle_bus;
	
	reg [7:0] data_reg;
	
	always @(posedge CLK, posedge RESET)
	begin
	
		if (RESET)
		begin
		
			tick_reset <= 1'b1;
		
			cmd_start_bit <= 1'b0;
			cmd_data_bits <= 1'b0;
			cmd_ack_bit <= 1'b0;
			cmd_noack_bit <= 1'b0;
			cmd_stop_bit <= 1'b0;
			cmd_idle_bus <= 1'b0;
		
			i2c_data_oe <= 1'b0;
			i2c_data_out <= 1'b0;
			I2C_SCL <= 1'b1;
		
			data_reg <= 8'h00;
			DATA_RD <= 8'h00;
		
			ACK_STATUS <= 1'b0;
		
			DONE <= 1'b0;
		
			State <= S0;
			
		end
		else
		begin
		
			case (State)
			
				S0 :
				begin
				
					// Clear the Done Status
					DONE <= 1'b0;
				
					// Set Command Phases for Transaction
					cmd_start_bit <= START_BIT_ENA;
					cmd_data_bits <= 1'b1;
					cmd_ack_bit <= ACK_RW | (~ACK_RW & ~ACK_VAL);
					cmd_noack_bit <= ~ACK_RW & ACK_VAL;
					cmd_stop_bit <= STOP_BIT_ENA;
					cmd_idle_bus <= IDLE_BUS_ENA;
					
					// Set the Write Data for Transaction
					data_reg <= DATA_WR;
					
					// Wait for a Start Command
					if (START)
						State <= S1;
					
				end
				
				S1 :
				begin
				
					// Reset tick timer
					tick_reset <= 1'b1;

					// Set the next starting address depending on
					//   which phase is the next active priority.
					if (cmd_start_bit)
						op_addr <= 6'h00;
					else if (cmd_data_bits)
						op_addr <= 6'h11;
					else if (cmd_ack_bit)
						op_addr <= 6'h07;
					else if (cmd_noack_bit)
						op_addr <= 6'h0C;					
					else if (cmd_stop_bit)
						op_addr <= 6'h03;
					else if (cmd_idle_bus)
						op_addr <= 6'h32;

					// If there are still active phases, run the next phase
					//   otherwise, the transaction is done.
					if ( cmd_start_bit | cmd_data_bits | cmd_ack_bit | cmd_noack_bit | cmd_stop_bit | cmd_idle_bus )
						State <= S2;
					else
						State <= S6;
					
				end
												
				S2 :
				begin

					// Reset tick timer
					tick_reset <= 1'b1;
				
					// Set Clock Edge
					if (op_csel)
						I2C_SCL <= op_val;
					
					// Set Output Data 
					case (op_dsel)
					//	2'h0 : Do nothing
						2'h1 : i2c_data_out <= op_val;
						2'h2 : i2c_data_out <= data_reg[7];
					// 2'h3 : Do nothing	
					endcase
					
					// Capture Input Data / Shift Output Data
					if ( (op_asel == 1'b0) && (op_dsel == 2'h3) )
						data_reg <= { data_reg[6:0], i2c_data_in };

					// Capture the ACK Status
					if ( (op_asel == 1'b1) && (op_dsel == 2'h3) )
						ACK_STATUS <= i2c_data_in;
					
					// Set Data Ouput Enable
					case ( { op_asel, op_doe } )
						2'b00 : i2c_data_oe <= ~DATA_RW;
						2'b01 : i2c_data_oe <= 1'b1;
						2'b10 : i2c_data_oe <= DATA_RW;
						2'b11 : i2c_data_oe <= 1'b1;
					endcase
					
					State <= S3;
				
				end
				
				S3 :
				begin
				
					// Start tick timer
					tick_reset <= 1'b0;
					
					// Increment the op_addr
					op_addr <= op_addr + 1'b1;
					
					State <= S4;
					
				end
				
				S4 :
				begin
					
					// Wait for timer tick
					if (tick)
					begin
						if (op_done)
							State <= S5;
						else
							State <= S2;
					end
					
				end
				
				S5 :
				begin

					// Reset tick timer
					tick_reset <= 1'b1;

					// Clear the flag for the Phase just run
					if (cmd_start_bit)
						cmd_start_bit <= 1'b0;
					else if (cmd_data_bits)
						cmd_data_bits <= 1'b0;
					else if (cmd_ack_bit)
						cmd_ack_bit <= 1'b0;
					else if (cmd_noack_bit)
						cmd_noack_bit <= 1'b0;
					else if (cmd_stop_bit)
						cmd_stop_bit <= 1'b0;
					else if (cmd_idle_bus)
						cmd_idle_bus <= 1'b0;
				
					State <= S1;
					
				end
				
				S6 :
				begin
				
					// Output Read Data
					if (DATA_RW)
						DATA_RD <= data_reg;
						
					// Signal Done
					DONE <= 1'b1;
					
					State <= S0;
					
				end
				
			endcase
			
		end
		
	end

endmodule
