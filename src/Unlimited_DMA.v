`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/24/2019 06:01:37 PM
// Design Name: 
// Module Name: Unlimited_DMA
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
module Unlimited_DMA#
(
	// Users to add parameters here
	
	// User parameters ends
	// Do not modify the parameters beyond this line
	// Base address of targeted slave
	parameter  C_M_TARGET_SLAVE_BASE_ADDR	= 32'h10000000,
	// Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
	parameter integer C_M_AXI_BURST_LEN	= 128,
	// Thread ID Width
	parameter integer C_M_AXI_ID_WIDTH	= 1,
	// Width of Address Bus
	parameter integer C_M_AXI_ADDR_WIDTH	= 32,
	// Width of Data Bus
	parameter integer C_M_AXI_DATA_WIDTH	= 32,
	// Width of User Write Address Bus
	parameter integer C_M_AXI_AWUSER_WIDTH	= 0,
	// Width of User Read Address Bus
	parameter integer C_M_AXI_ARUSER_WIDTH	= 0,
	// Width of User Write Data Bus
	parameter integer C_M_AXI_WUSER_WIDTH	= 0,
	// Width of User Read Data Bus
	parameter integer C_M_AXI_RUSER_WIDTH	= 0,
	// Width of User Response Bus
	parameter integer C_M_AXI_BUSER_WIDTH	= 0,
	// Width of S_AXI data bus
	parameter integer C_S_AXI_DATA_WIDTH	= 32,
	// Width of S_AXI address bus
	parameter integer C_S_AXI_ADDR_WIDTH	= 6,
	// Width of the FIFO conter depth
	parameter integer FIFO_Counter_WIDTH    = 8
)(

//input signals for pingpang module
	input wire clk,
	input wire data_en,
	input wire [C_M_AXI_DATA_WIDTH-1:0]data,
	input [FIFO_Counter_WIDTH-1:0] HP0_FIFO_Counter,
	input [FIFO_Counter_WIDTH-1:0] HP1_FIFO_Counter,
//output signals for the intercon
	output wire intercon_RST_N,
	output wire M_AXI_WREADY,

//Axi lite ports
	// Global Clock Signal
    input wire  S_AXI_ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input wire  S_AXI_ARESETN,
    // Write address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    // Write channel Protection type. This signal indicates the
        // privilege and security level of the transaction, and whether
        // the transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_AWPROT,
    // Write address valid. This signal indicates that the master signaling
        // valid write address and control information.
    input wire  S_AXI_AWVALID,
    // Write address ready. This signal indicates that the slave is ready
        // to accept an address and associated control signals.
    output wire  S_AXI_AWREADY,
    // Write data (issued by master, acceped by Slave) 
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    // Write strobes. This signal indicates which byte lanes hold
        // valid data. There is one write strobe bit for each eight
        // bits of the write data bus.    
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    // Write valid. This signal indicates that valid write
        // data and strobes are available.
    input wire  S_AXI_WVALID,
    // Write ready. This signal indicates that the slave
        // can accept the write data.
    output wire  S_AXI_WREADY,
    // Write response. This signal indicates the status
        // of the write transaction.
    output wire [1 : 0] S_AXI_BRESP,
    // Write response valid. This signal indicates that the channel
        // is signaling a valid write response.
    output wire  S_AXI_BVALID,
    // Response ready. This signal indicates that the master
        // can accept a write response.
    input wire  S_AXI_BREADY,
    // Read address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    // Protection type. This signal indicates the privilege
        // and security level of the transaction, and whether the
        // transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_ARPROT,
    // Read address valid. This signal indicates that the channel
        // is signaling valid read address and control information.
    input wire  S_AXI_ARVALID,
    // Read address ready. This signal indicates that the slave is
        // ready to accept an address and associated control signals.
    output wire  S_AXI_ARREADY,
    // Read data (issued by slave)
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    // Read response. This signal indicates the status of the
        // read transfer.
    output wire [1 : 0] S_AXI_RRESP,
    // Read valid. This signal indicates that the channel is
        // signaling the required read data.
    output wire  S_AXI_RVALID,
    // Read ready. This signal indicates that the master can
        // accept the read data and response information.
    input wire  S_AXI_RREADY,

//Axi4 ports

//Channel 1 AXI4	
	// Global Clock Signal.
	input wire M_1_AXI_ACLK,
	input wire M_1_AXI_ARESETN,
	// Master Interface Write Address ID
	output wire [C_M_AXI_ID_WIDTH-1 : 0] M_1_AXI_AWID,
	// Master Interface Write Address
	output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_1_AXI_AWADDR,
	// Burst length. The burst length gives the exact number of transfers in a burst
	output wire [7 : 0] M_1_AXI_AWLEN,
	// Burst size. This signal indicates the size of each transfer in the burst
	output wire [2 : 0] M_1_AXI_AWSIZE,
	// Burst type. The burst type and the size information, 
// determine how the address for each transfer within the burst is calculated.
	output wire [1 : 0] M_1_AXI_AWBURST,
	// Lock type. Provides additional information about the
// atomic characteristics of the transfer.
	output wire  M_1_AXI_AWLOCK,
	// Memory type. This signal indicates how transactions
// are required to progress through a system.
	output wire [3 : 0] M_1_AXI_AWCACHE,
	// Protection type. This signal indicates the privilege
// and security level of the transaction, and whether
// the transaction is a data access or an instruction access.
	output wire [2 : 0] M_1_AXI_AWPROT,
	// Quality of Service, QoS identifier sent for each write transaction.
	output wire [3 : 0] M_1_AXI_AWQOS,
	// Optional User-defined signal in the write address channel.
	output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] M_1_AXI_AWUSER,
	// Write address valid. This signal indicates that
// the channel is signaling valid write address and control information.
	output wire  M_1_AXI_AWVALID,
	// Write address ready. This signal indicates that
// the slave is ready to accept an address and associated control signals
	input wire  M_1_AXI_AWREADY,
	// Master Interface Write Data.
	output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_1_AXI_WDATA,
	// Write strobes. This signal indicates which byte
// lanes hold valid data. There is one write strobe
// bit for each eight bits of the write data bus.
	output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_1_AXI_WSTRB,
	// Write last. This signal indicates the last transfer in a write burst.
	output wire  M_1_AXI_WLAST,
	// Optional User-defined signal in the write data channel.
	output wire [C_M_AXI_WUSER_WIDTH-1 : 0] M_1_AXI_WUSER,
	// Write valid. This signal indicates that valid write
// data and strobes are available
	output wire  M_1_AXI_WVALID,
	// Write ready. This signal indicates that the slave
// can accept the write data.
	input wire  M_1_AXI_WREADY,
	// Master Interface Write Response.
	input wire [C_M_AXI_ID_WIDTH-1 : 0] M_1_AXI_BID,
	// Write response. This signal indicates the status of the write transaction.
	input wire [1 : 0] M_1_AXI_BRESP,
	// Optional User-defined signal in the write response channel
	input wire [C_M_AXI_BUSER_WIDTH-1 : 0] M_1_AXI_BUSER,
	// Write response valid. This signal indicates that the
// channel is signaling a valid write response.
	input wire  M_1_AXI_BVALID,
	// Response ready. This signal indicates that the master
// can accept a write response.
	output wire  M_1_AXI_BREADY,
	// Master Interface Read Address.
	output wire [C_M_AXI_ID_WIDTH-1 : 0] M_1_AXI_ARID,
	// Read address. This signal indicates the initial
// address of a read burst transaction.
	output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_1_AXI_ARADDR,
	// Burst length. The burst length gives the exact number of transfers in a burst
	output wire [7 : 0] M_1_AXI_ARLEN,
	// Burst size. This signal indicates the size of each transfer in the burst
	output wire [2 : 0] M_1_AXI_ARSIZE,
	// Burst type. The burst type and the size information, 
// determine how the address for each transfer within the burst is calculated.
	output wire [1 : 0] M_1_AXI_ARBURST,
	// Lock type. Provides additional information about the
// atomic characteristics of the transfer.
	output wire  M_1_AXI_ARLOCK,
	// Memory type. This signal indicates how transactions
// are required to progress through a system.
	output wire [3 : 0] M_1_AXI_ARCACHE,
	// Protection type. This signal indicates the privilege
// and security level of the transaction, and whether
// the transaction is a data access or an instruction access.
	output wire [2 : 0] M_1_AXI_ARPROT,
	// Quality of Service, QoS identifier sent for each read transaction
	output wire [3 : 0] M_1_AXI_ARQOS,
	// Optional User-defined signal in the read address channel.
	output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] M_1_AXI_ARUSER,
	// Write address valid. This signal indicates that
// the channel is signaling valid read address and control information
	output wire  M_1_AXI_ARVALID,
	// Read address ready. This signal indicates that
// the slave is ready to accept an address and associated control signals
	input wire  M_1_AXI_ARREADY,
	// Read ID tag. This signal is the identification tag
// for the read data group of signals generated by the slave.
	input wire [C_M_AXI_ID_WIDTH-1 : 0] M_1_AXI_RID,
	// Master Read Data
	input wire [C_M_AXI_DATA_WIDTH-1 : 0] M_1_AXI_RDATA,
	// Read response. This signal indicates the status of the read transfer
	input wire [1 : 0] M_1_AXI_RRESP,
	// Read last. This signal indicates the last transfer in a read burst
	input wire  M_1_AXI_RLAST,
	// Optional User-defined signal in the read address channel.
	input wire [C_M_AXI_RUSER_WIDTH-1 : 0] M_1_AXI_RUSER,
	// Read valid. This signal indicates that the channel
// is signaling the required read data.
	input wire  M_1_AXI_RVALID,
	// Read ready. This signal indicates that the master can
// accept the read data and response information.
	output wire  M_1_AXI_RREADY,

//Channel 2 AXI4	
	input wire M_2_AXI_ACLK,
	input wire M_2_AXI_ARESETN,
	// Master Interface Write Address ID
	output wire [C_M_AXI_ID_WIDTH-1 : 0] M_2_AXI_AWID,
	// Master Interface Write Address
	output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_2_AXI_AWADDR,
	// Burst length. The burst length gives the exact number of transfers in a burst
	output wire [7 : 0] M_2_AXI_AWLEN,
	// Burst size. This signal indicates the size of each transfer in the burst
	output wire [2 : 0] M_2_AXI_AWSIZE,
	// Burst type. The burst type and the size information, 
// determine how the address for each transfer within the burst is calculated.
	output wire [1 : 0] M_2_AXI_AWBURST,
	// Lock type. Provides additional information about the
// atomic characteristics of the transfer.
	output wire  M_2_AXI_AWLOCK,
	// Memory type. This signal indicates how transactions
// are required to progress through a system.
	output wire [3 : 0] M_2_AXI_AWCACHE,
	// Protection type. This signal indicates the privilege
// and security level of the transaction, and whether
// the transaction is a data access or an instruction access.
	output wire [2 : 0] M_2_AXI_AWPROT,
	// Quality of Service, QoS identifier sent for each write transaction.
	output wire [3 : 0] M_2_AXI_AWQOS,
	// Optional User-defined signal in the write address channel.
	output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] M_2_AXI_AWUSER,
	// Write address valid. This signal indicates that
// the channel is signaling valid write address and control information.
	output wire  M_2_AXI_AWVALID,
	// Write address ready. This signal indicates that
// the slave is ready to accept an address and associated control signals
	input wire  M_2_AXI_AWREADY,
	// Master Interface Write Data.
	output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_2_AXI_WDATA,
	// Write strobes. This signal indicates which byte
// lanes hold valid data. There is one write strobe
// bit for each eight bits of the write data bus.
	output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_2_AXI_WSTRB,
	// Write last. This signal indicates the last transfer in a write burst.
	output wire  M_2_AXI_WLAST,
	// Optional User-defined signal in the write data channel.
	output wire [C_M_AXI_WUSER_WIDTH-1 : 0] M_2_AXI_WUSER,
	// Write valid. This signal indicates that valid write
// data and strobes are available
	output wire  M_2_AXI_WVALID,
	// Write ready. This signal indicates that the slave
// can accept the write data.
	input wire  M_2_AXI_WREADY,
	// Master Interface Write Response.
	input wire [C_M_AXI_ID_WIDTH-1 : 0] M_2_AXI_BID,
	// Write response. This signal indicates the status of the write transaction.
	input wire [1 : 0] M_2_AXI_BRESP,
	// Optional User-defined signal in the write response channel
	input wire [C_M_AXI_BUSER_WIDTH-1 : 0] M_2_AXI_BUSER,
	// Write response valid. This signal indicates that the
// channel is signaling a valid write response.
	input wire  M_2_AXI_BVALID,
	// Response ready. This signal indicates that the master
// can accept a write response.
	output wire  M_2_AXI_BREADY,
	// Master Interface Read Address.
	output wire [C_M_AXI_ID_WIDTH-1 : 0] M_2_AXI_ARID,
	// Read address. This signal indicates the initial
// address of a read burst transaction.
	output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_2_AXI_ARADDR,
	// Burst length. The burst length gives the exact number of transfers in a burst
	output wire [7 : 0] M_2_AXI_ARLEN,
	// Burst size. This signal indicates the size of each transfer in the burst
	output wire [2 : 0] M_2_AXI_ARSIZE,
	// Burst type. The burst type and the size information, 
// determine how the address for each transfer within the burst is calculated.
	output wire [1 : 0] M_2_AXI_ARBURST,
	// Lock type. Provides additional information about the
// atomic characteristics of the transfer.
	output wire  M_2_AXI_ARLOCK,
	// Memory type. This signal indicates how transactions
// are required to progress through a system.
	output wire [3 : 0] M_2_AXI_ARCACHE,
	// Protection type. This signal indicates the privilege
// and security level of the transaction, and whether
// the transaction is a data access or an instruction access.
	output wire [2 : 0] M_2_AXI_ARPROT,
	// Quality of Service, QoS identifier sent for each read transaction
	output wire [3 : 0] M_2_AXI_ARQOS,
	// Optional User-defined signal in the read address channel.
	output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] M_2_AXI_ARUSER,
	// Write address valid. This signal indicates that
// the channel is signaling valid read address and control information
	output wire  M_2_AXI_ARVALID,
	// Read address ready. This signal indicates that
// the slave is ready to accept an address and associated control signals
	input wire  M_2_AXI_ARREADY,
	// Read ID tag. This signal is the identification tag
// for the read data group of signals generated by the slave.
	input wire [C_M_AXI_ID_WIDTH-1 : 0] M_2_AXI_RID,
	// Master Read Data
	input wire [C_M_AXI_DATA_WIDTH-1 : 0] M_2_AXI_RDATA,
	// Read response. This signal indicates the status of the read transfer
	input wire [1 : 0] M_2_AXI_RRESP,
	// Read last. This signal indicates the last transfer in a read burst
	input wire  M_2_AXI_RLAST,
	// Optional User-defined signal in the read address channel.
	input wire [C_M_AXI_RUSER_WIDTH-1 : 0] M_2_AXI_RUSER,
	// Read valid. This signal indicates that the channel
// is signaling the required read data.
	input wire  M_2_AXI_RVALID,
	// Read ready. This signal indicates that the master can
// accept the read data and response information.
	output wire  M_2_AXI_RREADY

);

//inner connnecting signals
	//Channel 1
	wire [C_M_AXI_ADDR_WIDTH-1:0]BIAS_1_ADDR;
	wire Data_1_en;
	wire [C_M_AXI_DATA_WIDTH-1:0]Input_1_data;
	wire  INIT_1_AXI_TXN;
	wire  TXN_1_DONE;

	//Channel 2
	wire [C_M_AXI_ADDR_WIDTH-1:0]BIAS_2_ADDR;
	wire dData_2_en;
	wire [C_M_AXI_DATA_WIDTH-1:0]Input_2_data;
	wire  INIT_2_AXI_TXN;
	wire  TXN_2_DONE;

	wire [2:0]current_state;
	wire [2:0]next_state;

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

	localparam Channel_1_ID = 0;
	localparam Channel_2_ID = 1;

parameter IDLE = 2'b00;
parameter INIT_WRITE = 2'b01;

wire [C_S_AXI_DATA_WIDTH-1:0]	 slv_reg0;
wire [C_S_AXI_DATA_WIDTH-1:0]    slv_reg1;
wire [C_S_AXI_DATA_WIDTH-1:0]    slv_reg2;
wire [C_S_AXI_DATA_WIDTH-1:0]    slv_reg3;
wire [C_S_AXI_DATA_WIDTH-1:0]    slv_reg4;
wire [C_S_AXI_DATA_WIDTH-1:0]    slv_reg5;
wire [C_S_AXI_DATA_WIDTH-1:0]    slv_reg6;
wire [C_S_AXI_DATA_WIDTH-1:0]    slv_reg7;
wire [C_S_AXI_DATA_WIDTH-1:0]    slv_reg8;
wire [C_S_AXI_DATA_WIDTH-1:0]    slv_reg9;
wire [C_S_AXI_DATA_WIDTH-1:0]    slv_reg10;
wire [C_S_AXI_DATA_WIDTH-1:0]    slv_reg11;
wire [C_S_AXI_DATA_WIDTH-1:0]    slv_reg12;
wire [C_S_AXI_DATA_WIDTH-1:0]    slv_reg13;
wire [C_S_AXI_DATA_WIDTH-1:0]    slv_reg14;
wire [C_S_AXI_DATA_WIDTH-1:0]    slv_reg15;
AXI_LITE_CODE_v1_0_S_AXIL #(
        .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)
    ) inst_AXI_LITE_CODE_v1_0_S_AXIL (
        .slv_reg0      (slv_reg0),
        .slv_reg1      (slv_reg1),
        .slv_reg2      (slv_reg2),
        .slv_reg3      (slv_reg3),
        .slv_reg4      (slv_reg4),
        .slv_reg5      (slv_reg5),
        .slv_reg6      (slv_reg6),
        .slv_reg7      (slv_reg7),
        .slv_reg8      (slv_reg8),
        .slv_reg9      (slv_reg9),
        .slv_reg10     (slv_reg10),
        .slv_reg11     (slv_reg11),
        .slv_reg12     (slv_reg12),
        .slv_reg13     (slv_reg13),
        .slv_reg14     (slv_reg14),
        .slv_reg15     (slv_reg15),
        .slv_wire0     (slv_reg0),
        .slv_wire1     (slv_reg1),
        .slv_wire2     (slv_reg2),
        .slv_wire3     (slv_reg3),
        .slv_wire4     (slv_reg4),
        .slv_wire5     (slv_reg5),
        .slv_wire6     ({31'd0,Write_done}),
        .slv_wire7     (BIAS_1_ADDR),
        .slv_wire8     (BIAS_2_ADDR),
        .slv_wire9     ({31'd0,INIT_1_AXI_TXN}),
        .slv_wire10    ({31'd0,INIT_2_AXI_TXN}),
        .slv_wire11    ({31'd0,restarted}),
        .slv_wire12    (slv_reg12),
        .slv_wire13    (slv_reg13),
        .slv_wire14    (slv_reg14),
        .slv_wire15    (slv_reg15),
        .S_AXI_ACLK    (S_AXI_ACLK),
        .S_AXI_ARESETN (S_AXI_ARESETN),
        .S_AXI_AWADDR  (S_AXI_AWADDR),
        .S_AXI_AWPROT  (S_AXI_AWPROT),
        .S_AXI_AWVALID (S_AXI_AWVALID),
        .S_AXI_AWREADY (S_AXI_AWREADY),
        .S_AXI_WDATA   (S_AXI_WDATA),
        .S_AXI_WSTRB   (S_AXI_WSTRB),
        .S_AXI_WVALID  (S_AXI_WVALID),
        .S_AXI_WREADY  (S_AXI_WREADY),
        .S_AXI_BRESP   (S_AXI_BRESP),
        .S_AXI_BVALID  (S_AXI_BVALID),
        .S_AXI_BREADY  (S_AXI_BREADY),
        .S_AXI_ARADDR  (S_AXI_ARADDR),
        .S_AXI_ARPROT  (S_AXI_ARPROT),
        .S_AXI_ARVALID (S_AXI_ARVALID),
        .S_AXI_ARREADY (S_AXI_ARREADY),
        .S_AXI_RDATA   (S_AXI_RDATA),
        .S_AXI_RRESP   (S_AXI_RRESP),
        .S_AXI_RVALID  (S_AXI_RVALID),
        .S_AXI_RREADY  (S_AXI_RREADY)
    );

	wire rst 					   					  = slv_reg0[0];//reset signal
	wire [C_S_AXI_DATA_WIDTH-1:0]Base_ADDR 			  = slv_reg1;//initial address
	wire [C_S_AXI_DATA_WIDTH-1:0]End_ADDR  			  = slv_reg2;//end address
	wire start 							   			  = slv_reg3[0];
	wire [FIFO_Counter_WIDTH-1:0]WARNING_THRES 		  = slv_reg4[7:0];
	wire [FIFO_Counter_WIDTH-1:0]WARNING_CANCEL_THRES = slv_reg5[7:0];
	wire Write_done;
	wire restarted;

	assign intercon_RST_N = !rst;

	reg [C_M_AXI_DATA_WIDTH-1:0]data_buffer;

	always @(posedge clk) begin
		data_buffer  <= data;
	end
    	Pingpang #(
			.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
			.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
			.C_M_AXI_BURST_LEN(C_M_AXI_BURST_LEN),
			.ADDR_WIDTH(C_S_AXI_DATA_WIDTH),
			.C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
			.FIFO_Counter_WIDTH(FIFO_Counter_WIDTH)
		) inst_Pingpang (
			.clk                 (clk),
			.data_en             (data_en),
			.start				 (start),
			.data                (data_buffer),
			.WARNING_THRES		 (WARNING_THRES),
			.WARNING_CANCEL_THRES(WARNING_CANCEL_THRES),
			.rst                 (rst),
			.HP0_FIFO_Counter	 (HP0_FIFO_Counter),
			.HP1_FIFO_Counter	 (HP1_FIFO_Counter),
			.M_1_AXI_WREADY 	 (M_1_AXI_WREADY),
			.M_2_AXI_WREADY      (M_2_AXI_WREADY),
			.M_AXI_WREADY 	     (M_AXI_WREADY),
			.Base_ADDR           (Base_ADDR),
			.End_ADDR            (End_ADDR),
			.Write_done          (Write_done),
			.INIT_AXI_TXN_1      (INIT_1_AXI_TXN),
			.INIT_AXI_TXN_DONE_1 (TXN_1_DONE),
			.BIAS_ADDR_1         (BIAS_1_ADDR),
			.Data_en_1           (Data_1_en),
			.Data_1              (Input_1_data),
			.INIT_AXI_TXN_2      (INIT_2_AXI_TXN),
			.INIT_AXI_TXN_DONE_2 (TXN_2_DONE),
			.BIAS_ADDR_2         (BIAS_2_ADDR),
			.Data_en_2           (Data_2_en),
			.Data_2              (Input_2_data),
			.current_state		 (current_state),
			.next_state			 (next_state),
			.restarted 		  	 (restarted)
		);

WData2AXI4 #(
		.Channel_ID(Channel_1_ID),
		.C_M_TARGET_SLAVE_BASE_ADDR(C_M_TARGET_SLAVE_BASE_ADDR),
		.C_M_AXI_BURST_LEN(C_M_AXI_BURST_LEN),
		.C_M_AXI_ID_WIDTH(C_M_AXI_ID_WIDTH),
		.C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
		.C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
		.C_M_AXI_AWUSER_WIDTH(C_M_AXI_AWUSER_WIDTH),
		.C_M_AXI_ARUSER_WIDTH(C_M_AXI_ARUSER_WIDTH),
		.C_M_AXI_WUSER_WIDTH(C_M_AXI_WUSER_WIDTH),
		.C_M_AXI_RUSER_WIDTH(C_M_AXI_RUSER_WIDTH),
		.C_M_AXI_BUSER_WIDTH(C_M_AXI_BUSER_WIDTH)
	) U1_WData2AXI4 (
		.BIAS_ADDR     (BIAS_1_ADDR),
		.data_en       (Data_1_en),
		.input_data    (Input_1_data),
		.INIT_AXI_TXN  (INIT_1_AXI_TXN),
		.TXN_DONE      (TXN_1_DONE),
		.M_AXI_ACLK    (M_1_AXI_ACLK),
		.M_AXI_ARESETN (M_1_AXI_ARESETN),
		.M_AXI_AWID    (M_1_AXI_AWID),
		.M_AXI_AWADDR  (M_1_AXI_AWADDR),
		.M_AXI_AWLEN   (M_1_AXI_AWLEN),
		.M_AXI_AWSIZE  (M_1_AXI_AWSIZE),
		.M_AXI_AWBURST (M_1_AXI_AWBURST),
		.M_AXI_AWLOCK  (M_1_AXI_AWLOCK),
		.M_AXI_AWCACHE (M_1_AXI_AWCACHE),
		.M_AXI_AWPROT  (M_1_AXI_AWPROT),
		.M_AXI_AWQOS   (M_1_AXI_AWQOS),
		.M_AXI_AWUSER  (M_1_AXI_AWUSER),
		.M_AXI_AWVALID (M_1_AXI_AWVALID),
		.M_AXI_AWREADY (M_1_AXI_AWREADY),
		.M_AXI_WDATA   (M_1_AXI_WDATA),
		.M_AXI_WSTRB   (M_1_AXI_WSTRB),
		.M_AXI_WLAST   (M_1_AXI_WLAST),
		.M_AXI_WUSER   (M_1_AXI_WUSER),
		.M_AXI_WVALID  (M_1_AXI_WVALID),
		.M_AXI_WREADY  (M_1_AXI_WREADY),
		.M_AXI_BID     (M_1_AXI_BID),
		.M_AXI_BRESP   (M_1_AXI_BRESP),
		.M_AXI_BUSER   (M_1_AXI_BUSER),
		.M_AXI_BVALID  (M_1_AXI_BVALID),
		.M_AXI_BREADY  (M_1_AXI_BREADY),
		.M_AXI_ARID    (M_1_AXI_ARID),
		.M_AXI_ARADDR  (M_1_AXI_ARADDR),
		.M_AXI_ARLEN   (M_1_AXI_ARLEN),
		.M_AXI_ARSIZE  (M_1_AXI_ARSIZE),
		.M_AXI_ARBURST (M_1_AXI_ARBURST),
		.M_AXI_ARLOCK  (M_1_AXI_ARLOCK),
		.M_AXI_ARCACHE (M_1_AXI_ARCACHE),
		.M_AXI_ARPROT  (M_1_AXI_ARPROT),
		.M_AXI_ARQOS   (M_1_AXI_ARQOS),
		.M_AXI_ARUSER  (M_1_AXI_ARUSER),
		.M_AXI_ARVALID (M_1_AXI_ARVALID),
		.M_AXI_ARREADY (M_1_AXI_ARREADY),
		.M_AXI_RID     (M_1_AXI_RID),
		.M_AXI_RDATA   (M_1_AXI_RDATA),
		.M_AXI_RRESP   (M_1_AXI_RRESP),
		.M_AXI_RLAST   (M_1_AXI_RLAST),
		.M_AXI_RUSER   (M_1_AXI_RUSER),
		.M_AXI_RVALID  (M_1_AXI_RVALID),
		.M_AXI_RREADY  (M_1_AXI_RREADY)
	);


WData2AXI4 #(
		.Channel_ID(Channel_2_ID),
		.C_M_TARGET_SLAVE_BASE_ADDR(C_M_TARGET_SLAVE_BASE_ADDR),
		.C_M_AXI_BURST_LEN(C_M_AXI_BURST_LEN),
		.C_M_AXI_ID_WIDTH(C_M_AXI_ID_WIDTH),
		.C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
		.C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
		.C_M_AXI_AWUSER_WIDTH(C_M_AXI_AWUSER_WIDTH),
		.C_M_AXI_ARUSER_WIDTH(C_M_AXI_ARUSER_WIDTH),
		.C_M_AXI_WUSER_WIDTH(C_M_AXI_WUSER_WIDTH),
		.C_M_AXI_RUSER_WIDTH(C_M_AXI_RUSER_WIDTH),
		.C_M_AXI_BUSER_WIDTH(C_M_AXI_BUSER_WIDTH)
	) U2_WData2AXI4 (
		.BIAS_ADDR     (BIAS_2_ADDR),
		.data_en       (Data_2_en),
		.input_data    (Input_2_data),
		.INIT_AXI_TXN  (INIT_2_AXI_TXN),
		.TXN_DONE      (TXN_2_DONE),
		.M_AXI_ACLK    (M_2_AXI_ACLK),
		.M_AXI_ARESETN (M_2_AXI_ARESETN),
		.M_AXI_AWID    (M_2_AXI_AWID),
		.M_AXI_AWADDR  (M_2_AXI_AWADDR),
		.M_AXI_AWLEN   (M_2_AXI_AWLEN),
		.M_AXI_AWSIZE  (M_2_AXI_AWSIZE),
		.M_AXI_AWBURST (M_2_AXI_AWBURST),
		.M_AXI_AWLOCK  (M_2_AXI_AWLOCK),
		.M_AXI_AWCACHE (M_2_AXI_AWCACHE),
		.M_AXI_AWPROT  (M_2_AXI_AWPROT),
		.M_AXI_AWQOS   (M_2_AXI_AWQOS),
		.M_AXI_AWUSER  (M_2_AXI_AWUSER),
		.M_AXI_AWVALID (M_2_AXI_AWVALID),
		.M_AXI_AWREADY (M_2_AXI_AWREADY),
		.M_AXI_WDATA   (M_2_AXI_WDATA),
		.M_AXI_WSTRB   (M_2_AXI_WSTRB),
		.M_AXI_WLAST   (M_2_AXI_WLAST),
		.M_AXI_WUSER   (M_2_AXI_WUSER),
		.M_AXI_WVALID  (M_2_AXI_WVALID),
		.M_AXI_WREADY  (M_2_AXI_WREADY),
		.M_AXI_BID     (M_2_AXI_BID),
		.M_AXI_BRESP   (M_2_AXI_BRESP),
		.M_AXI_BUSER   (M_2_AXI_BUSER),
		.M_AXI_BVALID  (M_2_AXI_BVALID),
		.M_AXI_BREADY  (M_2_AXI_BREADY),
		.M_AXI_ARID    (M_2_AXI_ARID),
		.M_AXI_ARADDR  (M_2_AXI_ARADDR),
		.M_AXI_ARLEN   (M_2_AXI_ARLEN),
		.M_AXI_ARSIZE  (M_2_AXI_ARSIZE),
		.M_AXI_ARBURST (M_2_AXI_ARBURST),
		.M_AXI_ARLOCK  (M_2_AXI_ARLOCK),
		.M_AXI_ARCACHE (M_2_AXI_ARCACHE),
		.M_AXI_ARPROT  (M_2_AXI_ARPROT),
		.M_AXI_ARQOS   (M_2_AXI_ARQOS),
		.M_AXI_ARUSER  (M_2_AXI_ARUSER),
		.M_AXI_ARVALID (M_2_AXI_ARVALID),
		.M_AXI_ARREADY (M_2_AXI_ARREADY),
		.M_AXI_RID     (M_2_AXI_RID),
		.M_AXI_RDATA   (M_2_AXI_RDATA),
		.M_AXI_RRESP   (M_2_AXI_RRESP),
		.M_AXI_RLAST   (M_2_AXI_RLAST),
		.M_AXI_RUSER   (M_2_AXI_RUSER),
		.M_AXI_RVALID  (M_2_AXI_RVALID),
		.M_AXI_RREADY  (M_2_AXI_RREADY)
);


endmodule



