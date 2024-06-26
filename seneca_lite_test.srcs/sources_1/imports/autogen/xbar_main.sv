// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// xbar_main module generated by `tlgen.py` tool
// all reset signals should be generated from one reset signal to not make any deadlock
//
// Interconnect
// corei
//   -> s1n_6
//     -> sm1_7
//       -> ram_instr
//     -> sm1_8
//       -> ram_data
//     -> sm1_9
//       -> noc_fifo
// cored
//   -> s1n_10
//     -> sm1_7
//       -> ram_instr
//     -> sm1_8
//       -> ram_data
//     -> sm1_9
//       -> noc_fifo
// externalif
//   -> s1n_11
//     -> sm1_7
//       -> ram_instr
//     -> sm1_8
//       -> ram_data
//     -> sm1_9
//       -> noc_fifo

module xbar_main (
  input clk_main_i,
  input rst_main_ni,

  // Host interfaces
  input  tlul_pkg::tl_h2d_t tl_corei_i,
  output tlul_pkg::tl_d2h_t tl_corei_o,
  input  tlul_pkg::tl_h2d_t tl_cored_i,
  output tlul_pkg::tl_d2h_t tl_cored_o,
  input  tlul_pkg::tl_h2d_t tl_externalif_i,
  output tlul_pkg::tl_d2h_t tl_externalif_o,

  // Device interfaces
  output tlul_pkg::tl_h2d_t tl_ram_instr_o,
  input  tlul_pkg::tl_d2h_t tl_ram_instr_i,
  output tlul_pkg::tl_h2d_t tl_ram_data_o,
  input  tlul_pkg::tl_d2h_t tl_ram_data_i,
  output tlul_pkg::tl_h2d_t tl_noc_fifo_o,
  input  tlul_pkg::tl_d2h_t tl_noc_fifo_i
);

  import tlul_pkg::*;
  import tl_main_pkg::*;

  tl_h2d_t tl_s1n_6_us_h2d ;
  tl_d2h_t tl_s1n_6_us_d2h ;


  tl_h2d_t tl_s1n_6_ds_h2d [3];
  tl_d2h_t tl_s1n_6_ds_d2h [3];

  // Create steering signal
  logic [1:0] dev_sel_s1n_6;


  tl_h2d_t tl_sm1_7_us_h2d [3];
  tl_d2h_t tl_sm1_7_us_d2h [3];

  tl_h2d_t tl_sm1_7_ds_h2d ;
  tl_d2h_t tl_sm1_7_ds_d2h ;


  tl_h2d_t tl_sm1_8_us_h2d [3];
  tl_d2h_t tl_sm1_8_us_d2h [3];

  tl_h2d_t tl_sm1_8_ds_h2d ;
  tl_d2h_t tl_sm1_8_ds_d2h ;


  tl_h2d_t tl_sm1_9_us_h2d [3];
  tl_d2h_t tl_sm1_9_us_d2h [3];

  tl_h2d_t tl_sm1_9_ds_h2d ;
  tl_d2h_t tl_sm1_9_ds_d2h ;

  tl_h2d_t tl_s1n_10_us_h2d ;
  tl_d2h_t tl_s1n_10_us_d2h ;


  tl_h2d_t tl_s1n_10_ds_h2d [3];
  tl_d2h_t tl_s1n_10_ds_d2h [3];

  // Create steering signal
  logic [1:0] dev_sel_s1n_10;

  tl_h2d_t tl_s1n_11_us_h2d ;
  tl_d2h_t tl_s1n_11_us_d2h ;


  tl_h2d_t tl_s1n_11_ds_h2d [3];
  tl_d2h_t tl_s1n_11_ds_d2h [3];

  // Create steering signal
  logic [1:0] dev_sel_s1n_11;



  assign tl_sm1_7_us_h2d[0] = tl_s1n_6_ds_h2d[0];
  assign tl_s1n_6_ds_d2h[0] = tl_sm1_7_us_d2h[0];

  assign tl_sm1_8_us_h2d[0] = tl_s1n_6_ds_h2d[1];
  assign tl_s1n_6_ds_d2h[1] = tl_sm1_8_us_d2h[0];

  assign tl_sm1_9_us_h2d[0] = tl_s1n_6_ds_h2d[2];
  assign tl_s1n_6_ds_d2h[2] = tl_sm1_9_us_d2h[0];

  assign tl_sm1_7_us_h2d[1] = tl_s1n_10_ds_h2d[0];
  assign tl_s1n_10_ds_d2h[0] = tl_sm1_7_us_d2h[1];

  assign tl_sm1_8_us_h2d[1] = tl_s1n_10_ds_h2d[1];
  assign tl_s1n_10_ds_d2h[1] = tl_sm1_8_us_d2h[1];

  assign tl_sm1_9_us_h2d[1] = tl_s1n_10_ds_h2d[2];
  assign tl_s1n_10_ds_d2h[2] = tl_sm1_9_us_d2h[1];

  assign tl_sm1_7_us_h2d[2] = tl_s1n_11_ds_h2d[0];
  assign tl_s1n_11_ds_d2h[0] = tl_sm1_7_us_d2h[2];

  assign tl_sm1_8_us_h2d[2] = tl_s1n_11_ds_h2d[1];
  assign tl_s1n_11_ds_d2h[1] = tl_sm1_8_us_d2h[2];

  assign tl_sm1_9_us_h2d[2] = tl_s1n_11_ds_h2d[2];
  assign tl_s1n_11_ds_d2h[2] = tl_sm1_9_us_d2h[2];

  assign tl_s1n_6_us_h2d = tl_corei_i;
  assign tl_corei_o = tl_s1n_6_us_d2h;

  assign tl_ram_instr_o = tl_sm1_7_ds_h2d;
  assign tl_sm1_7_ds_d2h = tl_ram_instr_i;

  assign tl_ram_data_o = tl_sm1_8_ds_h2d;
  assign tl_sm1_8_ds_d2h = tl_ram_data_i;

  assign tl_noc_fifo_o = tl_sm1_9_ds_h2d;
  assign tl_sm1_9_ds_d2h = tl_noc_fifo_i;

  assign tl_s1n_10_us_h2d = tl_cored_i;
  assign tl_cored_o = tl_s1n_10_us_d2h;

  assign tl_s1n_11_us_h2d = tl_externalif_i;
  assign tl_externalif_o = tl_s1n_11_us_d2h;

  always_comb begin
    // default steering to generate error response if address is not within the range
    dev_sel_s1n_6 = 2'd3;
    if ((tl_s1n_6_us_h2d.a_address &
         ~(ADDR_MASK_RAM_INSTR)) == ADDR_SPACE_RAM_INSTR) begin
      dev_sel_s1n_6 = 2'd0;

    end else if ((tl_s1n_6_us_h2d.a_address &
                  ~(ADDR_MASK_RAM_DATA)) == ADDR_SPACE_RAM_DATA) begin
      dev_sel_s1n_6 = 2'd1;

    end else if ((tl_s1n_6_us_h2d.a_address &
                  ~(ADDR_MASK_NOC_FIFO)) == ADDR_SPACE_NOC_FIFO) begin
      dev_sel_s1n_6 = 2'd2;
end
  end

  always_comb begin
    // default steering to generate error response if address is not within the range
    dev_sel_s1n_10 = 2'd3;
    if ((tl_s1n_10_us_h2d.a_address &
         ~(ADDR_MASK_RAM_INSTR)) == ADDR_SPACE_RAM_INSTR) begin
      dev_sel_s1n_10 = 2'd0;

    end else if ((tl_s1n_10_us_h2d.a_address &
                  ~(ADDR_MASK_RAM_DATA)) == ADDR_SPACE_RAM_DATA) begin
      dev_sel_s1n_10 = 2'd1;

    end else if ((tl_s1n_10_us_h2d.a_address &
                  ~(ADDR_MASK_NOC_FIFO)) == ADDR_SPACE_NOC_FIFO) begin
      dev_sel_s1n_10 = 2'd2;
end
  end

  always_comb begin
    // default steering to generate error response if address is not within the range
    dev_sel_s1n_11 = 2'd3;
    if ((tl_s1n_11_us_h2d.a_address &
         ~(ADDR_MASK_RAM_INSTR)) == ADDR_SPACE_RAM_INSTR) begin
      dev_sel_s1n_11 = 2'd0;

    end else if ((tl_s1n_11_us_h2d.a_address &
                  ~(ADDR_MASK_RAM_DATA)) == ADDR_SPACE_RAM_DATA) begin
      dev_sel_s1n_11 = 2'd1;

    end else if ((tl_s1n_11_us_h2d.a_address &
                  ~(ADDR_MASK_NOC_FIFO)) == ADDR_SPACE_NOC_FIFO) begin
      dev_sel_s1n_11 = 2'd2;
end
  end


  // Instantiation phase
  tlul_socket_1n #(
    .HReqDepth (4'h0),
    .HRspDepth (4'h0),
    .DReqDepth (12'h0),
    .DRspDepth (12'h0),
    .N         (3)
  ) u_s1n_6 (
    .clk_i        (clk_main_i),
    .rst_ni       (rst_main_ni),
    .tl_h_i       (tl_s1n_6_us_h2d),
    .tl_h_o       (tl_s1n_6_us_d2h),
    .tl_d_o       (tl_s1n_6_ds_h2d),
    .tl_d_i       (tl_s1n_6_ds_d2h),
    .dev_select_i (dev_sel_s1n_6)
  );
  tlul_socket_m1 #(
    .HReqDepth (12'h0),
    .HRspDepth (12'h0),
    .DReqDepth (4'h0),
    .DRspDepth (4'h0),
    .M         (3)
  ) u_sm1_7 (
    .clk_i        (clk_main_i),
    .rst_ni       (rst_main_ni),
    .tl_h_i       (tl_sm1_7_us_h2d),
    .tl_h_o       (tl_sm1_7_us_d2h),
    .tl_d_o       (tl_sm1_7_ds_h2d),
    .tl_d_i       (tl_sm1_7_ds_d2h)
  );
  tlul_socket_m1 #(
    .HReqDepth (12'h0),
    .HRspDepth (12'h0),
    .DReqDepth (4'h0),
    .DRspDepth (4'h0),
    .M         (3)
  ) u_sm1_8 (
    .clk_i        (clk_main_i),
    .rst_ni       (rst_main_ni),
    .tl_h_i       (tl_sm1_8_us_h2d),
    .tl_h_o       (tl_sm1_8_us_d2h),
    .tl_d_o       (tl_sm1_8_ds_h2d),
    .tl_d_i       (tl_sm1_8_ds_d2h)
  );
  tlul_socket_m1 #(
    .HReqDepth (12'h0),
    .HRspDepth (12'h0),
    .DReqDepth (4'h0),
    .DRspDepth (4'h0),
    .M         (3)
  ) u_sm1_9 (
    .clk_i        (clk_main_i),
    .rst_ni       (rst_main_ni),
    .tl_h_i       (tl_sm1_9_us_h2d),
    .tl_h_o       (tl_sm1_9_us_d2h),
    .tl_d_o       (tl_sm1_9_ds_h2d),
    .tl_d_i       (tl_sm1_9_ds_d2h)
  );
  tlul_socket_1n #(
    .HReqDepth (4'h0),
    .HRspDepth (4'h0),
    .DReqDepth (12'h0),
    .DRspDepth (12'h0),
    .N         (3)
  ) u_s1n_10 (
    .clk_i        (clk_main_i),
    .rst_ni       (rst_main_ni),
    .tl_h_i       (tl_s1n_10_us_h2d),
    .tl_h_o       (tl_s1n_10_us_d2h),
    .tl_d_o       (tl_s1n_10_ds_h2d),
    .tl_d_i       (tl_s1n_10_ds_d2h),
    .dev_select_i (dev_sel_s1n_10)
  );
  tlul_socket_1n #(
    .HReqDepth (4'h0),
    .HRspDepth (4'h0),
    .DReqDepth (12'h0),
    .DRspDepth (12'h0),
    .N         (3)
  ) u_s1n_11 (
    .clk_i        (clk_main_i),
    .rst_ni       (rst_main_ni),
    .tl_h_i       (tl_s1n_11_us_h2d),
    .tl_h_o       (tl_s1n_11_us_d2h),
    .tl_d_o       (tl_s1n_11_ds_h2d),
    .tl_d_i       (tl_s1n_11_ds_d2h),
    .dev_select_i (dev_sel_s1n_11)
  );

endmodule
