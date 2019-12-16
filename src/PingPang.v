`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/05/2019 10:45:55 AM
// Design Name: 
// Module Name: Pingpang_Test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Pingpang#(
	// Width of S_AXI data bus
	parameter integer C_S_AXI_DATA_WIDTH	 = 32,
	// Width of S_AXI address bus
	parameter integer C_S_AXI_ADDR_WIDTH	 = 6,
	parameter integer C_M_AXI_BURST_LEN		 = 16,
	//Data width
	parameter integer ADDR_WIDTH 			 = 32,
	parameter integer C_M_AXI_DATA_WIDTH 	 = 32,
	parameter integer FIFO_Counter_WIDTH     = 8
)(
	input wire clk,
	input wire data_en,
	input wire start,
	output reg ready,
	input wire [C_M_AXI_DATA_WIDTH-1:0]data,
	input wire [FIFO_Counter_WIDTH-1:0]WARNING_THRES,
	input wire [FIFO_Counter_WIDTH-1:0]WARNING_CANCEL_THRES,
	//wires signals
	input wire rst,//reset signal
	input wire [FIFO_Counter_WIDTH-1:0] HP0_FIFO_Counter,
	input wire [FIFO_Counter_WIDTH-1:0] HP1_FIFO_Counter,
	input wire M_1_AXI_WREADY,
	input wire M_2_AXI_WREADY,
	input wire [ADDR_WIDTH-1:0]Base_ADDR,//initial address
	input wire [ADDR_WIDTH-1:0]End_ADDR,//end address

	//Complete signal
	output reg Write_done,
	output reg INIT_AXI_TXN_1,
	input wire INIT_AXI_TXN_DONE_1,
	output reg [ADDR_WIDTH-1:0]BIAS_ADDR_1,
	output reg Data_en_1,
	output wire [C_M_AXI_DATA_WIDTH-1:0]Data_1,

	output reg INIT_AXI_TXN_2,
	input wire INIT_AXI_TXN_DONE_2,
	output reg [ADDR_WIDTH-1:0]BIAS_ADDR_2,
	output reg Data_en_2,
	output wire [C_M_AXI_DATA_WIDTH-1:0]Data_2,
	output reg [2:0]current_state,
	output reg [2:0]next_state,
	output reg restarted

);

	// function called clogb2 that returns an integer which has the
	//value of the ceiling of the log base 2

	// function called clogb2 that returns an integer which has the 
	// value of the ceiling of the log base 2.                      
	function integer clogb2 (input integer bit_depth);              
	begin                                                           
		for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
			bit_depth = bit_depth >> 1;                                 
		end                                                           
	endfunction                                                     

	// C_TRANSACTIONS_NUM is the width of the index counter for 
	// number of write or read transaction.
	localparam M_AXI_AWSIZE	= (C_M_AXI_DATA_WIDTH/8);
	localparam integer C_TRANSACTIONS_NUM = clogb2(C_M_AXI_BURST_LEN-1);
	localparam integer ADDRESS_CHANGE = ((C_M_AXI_BURST_LEN*M_AXI_AWSIZE)<<1);
	//control signals
	reg [ADDR_WIDTH-1:0]Write_Address;
	reg [C_M_AXI_DATA_WIDTH-1:0]Write_Data;
	reg [C_TRANSACTIONS_NUM : 0]write_index;
	
	reg data_en_temp;
	wire data_en_flag;

	always @(posedge clk) begin
		data_en_temp <= data_en;
	end


	assign data_en_flag = data_en &(~data_en_temp);

	reg start_temp;
	wire start_flag;

	always @(posedge clk) begin
		start_temp <= start;
	end
	

	assign start_flag = start &(~start_temp);
	//Write signal state machine

	localparam IDLE 	 = 3'd0;
	localparam PRE_S 	 = 3'd1;
	localparam Write1 	 = 3'd2;
	localparam Write2 	 = 3'd3;
	localparam Wait_Pre1 = 3'd4;
	localparam Wait_Pre2 = 3'd5;
	localparam Wait 	 = 3'd6;
	localparam HALT 	 = 3'd7;
	reg restart;
	wire HP0_Warning = HP0_FIFO_Counter >= WARNING_THRES;
	wire HP1_Warning = HP1_FIFO_Counter >= WARNING_THRES;
	wire Warning = HP1_Warning | HP0_Warning;
	wire WARNING_CANCEL = (HP1_FIFO_Counter <= WARNING_CANCEL_THRES) && (HP0_FIFO_Counter <= WARNING_CANCEL_THRES);
	//State machine
	always @(posedge clk) begin
		if (rst) begin
		// reset
		current_state <= IDLE;

		end
		else begin
		current_state <= next_state;
		end
		end

		always @(*) begin
		next_state = current_state;
		case(current_state)
			IDLE : begin
				next_state = start ? PRE_S : IDLE;
			end

			PRE_S : begin
				next_state = data_en_flag ? Write1 : PRE_S;
			end

			Write1 : begin
				if(Warning) begin
					next_state = HALT;
				end
				else if (INIT_AXI_TXN_DONE_1) begin				
					next_state = ((BIAS_ADDR_1 + ADDRESS_CHANGE) < End_ADDR) ? Write2 : Wait_Pre2;
				end
			end

			Write2 : begin
				if(Warning) begin
					next_state = HALT;
				end
				if (INIT_AXI_TXN_DONE_2) begin
					next_state = ((BIAS_ADDR_2 + ADDRESS_CHANGE) < End_ADDR) ? Write1 : Wait_Pre1;
				end
			end

			Wait_Pre1: begin
				if(INIT_AXI_TXN_DONE_1) begin
					next_state = Wait;
				end
			end

			Wait_Pre2: begin
				if(INIT_AXI_TXN_DONE_2) begin
					next_state = Wait;
				end
			end
			Wait : begin
				next_state = start ? Wait : IDLE;
			end
			HALT:begin
				if(WARNING_CANCEL) begin
					next_state = PRE_S;
				end
			end
			default : begin
				next_state = IDLE;
			end
		endcase
	end

	always @(posedge clk) begin
		if (rst) begin
		Data_en_1 <= 1'b0;
		Data_en_2 <= 1'b0;
		INIT_AXI_TXN_1 <= 1'b0;
		INIT_AXI_TXN_2 <= 1'b0;	
		Write_done <= 1'b0;	
		restart <= 1'b0;
		ready <= 1'b0;
		restarted <= 1'b0;
		end
		else begin
			case(next_state)

			IDLE : begin
				ready = 1'b0;
				restart <= 1'b0;
				restarted <= 1'b0;
				Data_en_1 <= 1'b0;
				Data_en_2 <= 1'b0;
				INIT_AXI_TXN_1 <= 1'b0;
				INIT_AXI_TXN_2 <= 1'b0;	
				Write_done <= 1'b0;		
			end

			PRE_S : begin
				ready = 1'b0;
				restart <= 1'b0;
				Data_en_1 <= 1'b0;
				Data_en_2 <= 1'b0;
				INIT_AXI_TXN_1 <= 1'b1;
				INIT_AXI_TXN_2 <= 1'b0;	
				Write_done <= 1'b0;		
			end

			Write1 : begin
				ready = M_1_AXI_WREADY;
				Data_en_1 <= data_en;
				Data_en_2 <= 1'b0;
				INIT_AXI_TXN_1 <= 1'b0;
				INIT_AXI_TXN_2 <= ((BIAS_ADDR_2 + ADDRESS_CHANGE) < End_ADDR);
				Write_done <= 1'b0;		
			end

			Write2 : begin
				ready = M_2_AXI_WREADY;
				Data_en_1 <= 1'b0;
				Data_en_2 <= data_en;
				INIT_AXI_TXN_1 <= ((BIAS_ADDR_1 + ADDRESS_CHANGE) < End_ADDR);
				Write_done <= 1'b0;		
				INIT_AXI_TXN_2 <= 1'b0;
			end

			Wait_Pre1 : begin
				ready = M_1_AXI_WREADY;
				Data_en_1 <= data_en;
				Data_en_2 <= 1'b0;
				INIT_AXI_TXN_1 <= 1'b0;
				INIT_AXI_TXN_2 <= 1'b0;
				Write_done <= 1'b0;		
			end

			Wait_Pre2 : begin
				ready = M_2_AXI_WREADY;
				Data_en_2 <= data_en;
				Data_en_1 <= 1'b0;
				INIT_AXI_TXN_1 <= 1'b0;
				INIT_AXI_TXN_2 <= 1'b0;
				Write_done <= 1'b0;		
			end
			Wait : begin
				ready = 1'b0;
				Data_en_1 <= 1'b0;
				Data_en_2 <= 1'b0;
				INIT_AXI_TXN_1 <= 1'b0;
				INIT_AXI_TXN_2 <= 1'b0;
				Write_done <= 1'b1;
			end
			HALT: begin
				ready = 1'b0;
				restart <= 1'b1;
				restarted <= 1'b1;
				Data_en_1 <= 1'b0;
				Data_en_2 <= 1'b0;
				INIT_AXI_TXN_1 <= 1'b0;
				INIT_AXI_TXN_2 <= 1'b0;
				Write_done <= 1'b0;
			end
			default : begin
				ready = 1'b0;
				restart <= 1'b0;
				restarted <= 1'b0;
				Data_en_1 <= 1'b0;
				Write_done <= 1'b0;		
				Data_en_2 <= 1'b0;
				INIT_AXI_TXN_1 <= 1'b0;
				INIT_AXI_TXN_2 <= 1'b0;	
			end

			endcase
		end
	end
	//Write data channel
	always @(posedge clk) begin
		if (rst) begin
			//reset
			Write_Data <= 0;	
		end
		else begin
			Write_Data <= data;
		end
	end
	assign Data_1 = Write_Data;
	assign Data_2 = Write_Data;

	always @(posedge clk) begin
		if (rst) begin
			BIAS_ADDR_1 <= 0;
			BIAS_ADDR_2 <= ADDRESS_CHANGE>>1;
		end
		else if(restart | start_flag) begin
			BIAS_ADDR_1 <= 0;
			BIAS_ADDR_2 <= ADDRESS_CHANGE>>1;
		end
		else begin
			BIAS_ADDR_1 <= INIT_AXI_TXN_DONE_1 ? (BIAS_ADDR_1 + ADDRESS_CHANGE) : BIAS_ADDR_1;
			BIAS_ADDR_2 <= INIT_AXI_TXN_DONE_2 ? (BIAS_ADDR_2 + ADDRESS_CHANGE) : BIAS_ADDR_2;
		end
	end


endmodule
