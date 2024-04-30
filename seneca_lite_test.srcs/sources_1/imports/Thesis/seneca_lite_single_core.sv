`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Yashwanth Gopinath
// 
// Create Date: 23.11.2023 15:18:25
// Design Name: 
// Module Name: senece_single_core
// Project Name: Seneca Lite
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

`ifndef RV32M
  `define RV32M ibex_pkg::RV32MFast
`endif

`ifndef RV32B
  `define RV32B ibex_pkg::RV32BNone
`endif

`ifndef RegFile
  `define RegFile ibex_pkg::RegFileFF
`endif
module seneca_lite_single_core(
  input IO_CLK,
  input IO_RST_N,
  output tlul_pkg::tl_h2d_t  tl_extif_req,
  input  tlul_pkg::tl_d2h_t  tl_extif_rsp,
  output [39:0] noc_packet_o,
  input [31:0] noc_packet_i,
  output noc_fifo_flag
    );
  parameter bit                 SecureIbex               = 1'b0;
  parameter bit                 ICacheScramble           = 1'b0;
  parameter bit                 PMPEnable                = 1'b0;
  parameter int unsigned        PMPGranularity           = 0;
  parameter int unsigned        PMPNumRegions            = 4;
  parameter int unsigned        MHPMCounterNum           = 0;
  parameter int unsigned        MHPMCounterWidth         = 40;
  parameter bit                 RV32E                    = 1'b0;
  parameter ibex_pkg::rv32m_e   RV32M                    = `RV32M;
  parameter ibex_pkg::rv32b_e   RV32B                    = `RV32B;
  parameter bit                 BranchTargetALU          = 1'b0;
  parameter bit                 WritebackStage           = 1'b0;
  parameter bit                 ICache                   = 1'b0;
  parameter bit                 DbgTriggerEn             = 1'b0;
  parameter bit                 ICacheECC                = 1'b0;
  parameter bit                 BranchPredictor          = 1'b0;
  parameter                     SRAMInitFile             = "";
  
  parameter int unsigned        DmHaltAddr        = 32'h1A110800;
  parameter int unsigned        DmExceptionAddr   = 32'h1A110808;

  import tlul_pkg::*;
  tlul_pkg::tl_h2d_t       tl_core_i_req;
  tlul_pkg::tl_d2h_t       tl_core_i_rsp;
  
  tlul_pkg::tl_h2d_t       tl_core_d_req;
  tlul_pkg::tl_d2h_t       tl_core_d_rsp;
  
  tlul_pkg::tl_h2d_t       tl_ram_instr_req;
  tlul_pkg::tl_d2h_t       tl_ram_instr_rsp;
  
  tlul_pkg::tl_h2d_t       tl_ram_data_req;
  tlul_pkg::tl_d2h_t       tl_ram_data_rsp;
  
  tlul_pkg::tl_h2d_t       tl_nocif_req;
  tlul_pkg::tl_d2h_t       tl_nocif_rsp;
  
  // ROM device
  parameter int instr_ram_depth_kb = 16;
  parameter int instr_addr_width = $clog2(instr_ram_depth_kb * 1024);
  parameter int instr_ram_depth  = (2**instr_addr_width)/4;
  logic                          ram_instr_req;
  logic                          ram_instr_we;
  logic [instr_addr_width - 1:0] ram_instr_addr;
  logic [31:0]                   ram_instr_wdata;
  logic [31:0]                   ram_instr_wmask;
  logic [31:0]                   ram_instr_rdata;
  logic                          ram_instr_rvalid;
  logic [1:0]                    ram_instr_rerror;
  
  // sram device
  parameter int data_ram_depth_kb = 64;
  parameter int data_addr_width = 16;
  parameter int data_ram_depth  = (2**data_addr_width)/4;
  // sram device
  logic        ram_data_req;
  logic        ram_data_we;
  logic [data_addr_width:0] ram_data_addr;
  logic [31:0] ram_data_wdata;
  logic [31:0] ram_data_wmask;
  logic [31:0] ram_data_rdata;
  logic        ram_data_rvalid;
  logic [1:0]  ram_data_rerror;
  
  // Instruction interface (Single core Internal)
  logic        instr_req;
  logic        instr_gnt;
  logic        instr_rvalid;
  logic [31:0] instr_addr;
  logic [31:0] instr_rdata;
  logic        instr_err;
  
  // Data interface (internal)
  logic        data_req;
  logic        data_gnt;
  logic        data_rvalid;
  logic        data_we;
  logic [3:0]  data_be;
  logic [31:0] data_addr;
  logic [31:0] data_wdata;
  logic [31:0] data_rdata;
  logic        data_err;
  
  logic [14:0] irq_fast;

    ibex_core #(
    .PMPEnable                ( PMPEnable                ),
    .PMPGranularity           ( PMPGranularity           ),
    .PMPNumRegions            ( PMPNumRegions            ),
    .MHPMCounterNum           ( MHPMCounterNum           ),
    .MHPMCounterWidth         ( MHPMCounterWidth         ),
    .RV32E                    ( RV32E                    ),
    .RV32M                    ( RV32M                    ),
    .RV32B                    ( RV32B                    ),
    .BranchTargetALU          ( BranchTargetALU          ),
    .WritebackStage           ( WritebackStage           ),
    .ICache                   ( ICache                   ),
    .ICacheECC                ( ICacheECC                ),
    .BranchPredictor          ( BranchPredictor          ),
    .DbgTriggerEn             ( DbgTriggerEn             ),
    .SecureIbex               ( SecureIbex               ),
    .DmHaltAddr               ( DmHaltAddr               ),
    .DmExceptionAddr          ( DmExceptionAddr          )
  ) u_core (
    .clk_i          ( IO_CLK      ),
    .rst_ni         ( IO_RST_N    ),
    .hart_id_i      (32'b0),
    .boot_addr_i (),

    .instr_req_o    ( instr_req    ),
    .instr_gnt_i    ( instr_gnt    ),
    .instr_rvalid_i ( instr_rvalid ),
    .instr_addr_o   ( instr_addr   ),
    .instr_rdata_i  ( instr_rdata  ),
    .instr_err_i    ( instr_err    ),

    .data_req_o     ( data_req     ),
    .data_gnt_i     ( data_gnt     ),
    .data_rvalid_i  ( data_rvalid  ),
    .data_we_o      ( data_we      ),
    .data_be_o      ( data_be      ),
    .data_addr_o    ( data_addr    ),
    .data_wdata_o   ( data_wdata   ),
    .data_rdata_i   ( data_rdata   ),
    .data_err_i     ( data_err     ),

    .irq_software_i (1'b0),
//    .irq_timer_i,
    .irq_external_i (1'b0),
    .irq_fast_i     ( irq_fast     ),
    .irq_nm_i (),

    .debug_req_i    (1'b0),

`ifdef RVFI
    .rvfi_valid,
    .rvfi_order,
    .rvfi_insn,
    .rvfi_trap,
    .rvfi_halt,
    .rvfi_intr,
    .rvfi_mode,
    .rvfi_ixl,
    .rvfi_rs1_addr,
    .rvfi_rs2_addr,
    .rvfi_rs3_addr,
    .rvfi_rs1_rdata,
    .rvfi_rs2_rdata,
    .rvfi_rs3_rdata,
    .rvfi_rd_addr,
    .rvfi_rd_wdata,
    .rvfi_pc_rdata,
    .rvfi_pc_wdata,
    .rvfi_mem_addr,
    .rvfi_mem_rmask,
    .rvfi_mem_wmask,
    .rvfi_mem_rdata,
    .rvfi_mem_wdata,
`endif

    .fetch_enable_i ()

//    .alert_minor_o,
//    .alert_major_o,
  );
  
  assign irq_fast[14:1] = 0;
  assign irq_fast[0] = noc_fifo_flag;

  //Instruction memory
  prim_ram_1p_adv #(
    .Width(32),
    .Depth(instr_ram_depth),
    .MemInitFile(SRAMInitFile)
  ) u_ram_instr (
    .clk_i    (IO_CLK),
    .rst_ni   (IO_RST_N),
    .req_i    (ram_instr_req),
    .write_i  (ram_instr_we),
    .wdata_i  (ram_instr_wdata),
    .wmask_i  (ram_instr_wmask),
    .rdata_o  (ram_instr_rdata),
    .rvalid_o (ram_instr_rvalid),
    .rerror_o (ram_instr_rerror),
    .cfg_i    (1'b0) // tied off for now
  );
  
  //Instruction memory to TL-UL adapter
  tlul_adapter_sram #(
    .SramAw(instr_addr_width),
    .SramDw(32),
    .Outstanding(2)
  ) u_tl_adapter_ram_instr (
    .clk_i    (IO_CLK),
    .rst_ni   (IO_RST_N),

    .tl_i     (tl_ram_instr_req),
    .tl_o     (tl_ram_instr_rsp),

    .req_o    (ram_instr_req),
    .gnt_i    (1'b1), // Always grant as only one requester exists
    .we_o     (ram_instr_we),
    .addr_o   (ram_instr_addr),
    .wdata_o  (ram_instr_wdata),
    .wmask_o  (ram_instr_wmask),
    .rdata_i  (ram_instr_rdata),
    .rvalid_i (ram_instr_rvalid),
    .rerror_i (ram_instr_rerror)
  );
  
  //Data memory 
  prim_ram_1p_adv #(
    .Width(32),
    .Depth(data_ram_depth),
    .DataBitsPerMask(8),
    .EnableParity(0)
  ) u_ram_data (
    .clk_i    (IO_CLK),
    .rst_ni   (IO_RST_N),

    .req_i    (ram_data_req),
    .write_i  (ram_data_we),
    .addr_i   (ram_data_addr[data_addr_width - 3:0]),
    .wdata_i  (ram_data_wdata),
    .wmask_i  (ram_data_wmask),
    .rdata_o  (ram_data_rdata),
    .rvalid_o (ram_data_rvalid),
    .rerror_o (ram_data_rerror),
    .cfg_i    ('0)
  );
  
  //Data memory to TL-UL
  tlul_adapter_sram #(
    .SramAw(data_addr_width),
    .SramDw(32),
    .Outstanding(2)
  ) u_tl_adapter_ram_data (
    .clk_i    (IO_CLK),
    .rst_ni   (IO_RST_N),
    .tl_i     (tl_ram_data_req),
    .tl_o     (tl_ram_data_rsp),

    .req_o    (ram_data_req),
    .gnt_i    (1'b1), // Always grant as only one requester exists
    .we_o     (ram_data_we),
    .addr_o   (ram_data_addr),
    .wdata_o  (ram_data_wdata),
    .wmask_o  (ram_data_wmask),
    .rdata_i  (ram_data_rdata),
    .rvalid_i (ram_data_rvalid),
    .rerror_i (ram_data_rerror)
  );
  
  //Ibex to TL-UL adapter for instruction memory
  tlul_adapter_host #(
    .MAX_REQS(2)
  ) tl_adapter_host_i_ibex (
    .clk_i   (IO_CLK),
    .rst_ni  (IO_RST_N),
    .req_i   (instr_req),
    .gnt_o   (instr_gnt),
    .addr_i  (instr_addr),
    .we_i    (1'b0),
    .wdata_i (32'b0),
    .be_i    (4'hF),
    .valid_o (instr_rvalid),
    .rdata_o (instr_rdata),
    .err_o   (instr_err),
    .tl_o    (tl_core_i_req),
    .tl_i    (tl_core_i_rsp)
  );

  //Ibex to TL-UL adapter for data memory
  tlul_adapter_host #(
    .MAX_REQS(2)
  ) tl_adapter_host_d_ibex (
    .clk_i   (IO_CLK),
    .rst_ni  (IO_RST_N),
    .req_i   (data_req),
    .gnt_o   (data_gnt),
    .addr_i  (data_addr),
    .we_i    (data_we),
    .wdata_i (data_wdata),
    .be_i    (data_be),
    .valid_o (data_rvalid),
    .rdata_o (data_rdata),
    .err_o   (data_err),
    .tl_o    (tl_core_d_req),
    .tl_i    (tl_core_d_rsp)
  );
  
//  Assign statements for design without XBAR
//  assign tl_core_i_i = tl_ram_instr_rsp;
//  assign tl_core_i_o = tl_ram_instr_req;
//  assign tl_core_d_i = tl_ram_data_rsp;
//  assign tl_core_d_o = tl_ram_data_req;
  noc_itf u_noc_itf (
    .tl_nocif_i (tl_nocif_req),
    .tl_nocif_o (tl_nocif_rsp),
    .IO_CLK (IO_CLK),
    .IO_RST_N (IO_RST_N),
    .noc_packet_o(noc_packet_o),
    .noc_packet_i(noc_packet_i),
    .noc_fifo_flag(noc_fifo_flag)
  );
  
  xbar_main u_xbar_main (
    .clk_main_i (IO_CLK),
    .rst_main_ni (IO_RST_IN),
    
    .tl_corei_i (tl_core_i_req),
    .tl_corei_o (tl_core_i_rsp),
    
    .tl_cored_i (tl_core_d_req),
    .tl_cored_o (tl_core_d_rsp),
    
    .tl_externalif_i (tl_extif_req),
    .tl_externalif_o (tl_extif_rsp),
    
    .tl_ram_instr_o (tl_ram_instr_req),
    .tl_ram_instr_i (tl_ram_instr_rsp),
    
    .tl_ram_data_o (tl_ram_data_req),
    .tl_ram_data_i (tl_ram_data_rsp),
    
    .tl_noc_fifo_o (tl_nocif_req),
    .tl_noc_fifo_i (tl_nocif_rsp)
  );
endmodule
