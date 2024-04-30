`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Yashwanth Gopinath
// 
// Create Date: 19.12.2023 14:28:26
// Design Name: 
// Module Name: noc_itf
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


module noc_itf import tlul_pkg::*;(
      input IO_CLK,
      input IO_RST_N,
      input  tlul_pkg::tl_h2d_t  tl_nocif_i,
      output  tlul_pkg::tl_d2h_t  tl_nocif_o,
      output reg [39:0] noc_packet_o,
      input [31:0] noc_packet_i,
      output noc_fifo_flag
    );
  logic registerWrite;
  logic registerRead;
  logic registerAddress;
  logic [39:0] registerWrData;
  logic [3:0]  registerBe;
  logic [31:0] registerRdData;
  //Register Adapter Interface for TL-UL to FIFO connection
  tlul_adapter_reg #(
    .RegAw (8),
    .RegDw (40) 
  ) u_tlul_adapter_reg (
      .clk_i(IO_CLK),
      .rst_ni(IO_RST_N),
      // TL-UL interface
      .tl_i (tl_nocif_i),
      .tl_o (tl_nocif_o),
    
      // Register interface
      .re_o    (registerRead),
      .we_o    (registerWrite),
      .addr_o  (registerAddress),
      .wdata_o (registerWrData),
      .be_o    (registerBe),
      .rdata_i (registerRdData),
      .error_i (1'b0)
  );
  //FIFO to store messages recieved from NoC
  prim_fifo_async #(
    .Width     (32),
    .Depth     (4)
  ) u_noc_receive_fifo (
  //Write port external input for incoming NoC messages
    .clk_wr_i  (IO_CLK),
    .rst_wr_ni (IO_RST_N),
    .wvalid_i  ('b1),
    .wready_o  (),
    .wdata_i   (noc_packet_i),
    .wdepth_o  (),
    
    //Read port internal NoC message read port
    .clk_rd_i  (IO_CLK),
    .rst_rd_ni (IO_RST_N),
    .rvalid_o  (),
    .rready_i  ('b1),
    .rdata_o   (registerRdData),
    .rdepth_o  (noc_fifo_flag)
   );
   //FIFO to send messages into NoC
   prim_fifo_async #(
    .Width     (40),
    .Depth     (4)
    ) u_noc_send_fifo (
    // write port used by TL-UL register adapter
    .clk_wr_i  (IO_CLK),
    .rst_wr_ni (IO_RST_N),
    .wvalid_i  ('b1),
    .wready_o  (),
    .wdata_i   (registerWrData),
    .wdepth_o  (),
    
    // read port to router
    .clk_rd_i  (IO_CLK),
    .rst_rd_ni (IO_RST_N),
    .rvalid_o  (),
    .rready_i  ('b1),
    .rdata_o   (noc_packet_o),
    .rdepth_o  ()
    );
endmodule
