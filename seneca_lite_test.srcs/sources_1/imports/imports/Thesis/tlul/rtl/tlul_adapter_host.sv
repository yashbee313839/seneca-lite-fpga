// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// tlul_adapter (Host adapter) converts basic req/grant/rvalid into TL-UL interface. If
// MAX_REQS == 1 it is purely combinational logic. If MAX_REQS > 1 flops are required.
//
// The host driving the adapter is responsible for ensuring it doesn't have more requests in flight
// than the specified MAX_REQS.
//
// The outgoing address is always word aligned. The access size is always the word size (as
// specified by TL_DW). For write accesses that occupy all lanes the operation is PutFullData,
// otherwise it is PutPartialData, mask is generated from be_i. For reads all lanes are enabled as
// required by TL-UL (every bit in mask set).
//
// When MAX_REQS > 1 tlul_adapter_host does not do anything to order responses from the TL-UL
// interface which could return them out of order. It is the host's responsibility to either only
// have outstanding requests to an address space it knows will return responses in order or to not
// care about out of order responses (note that if read data is returned out of order there is no
// way to determine this).

`include "prim_assert.sv"

module tlul_adapter_host #(
  parameter int unsigned MAX_REQS = 2
) (
  input clk_i,
  input rst_ni,

  input                              req_i,
  output logic                       gnt_o,
  input  logic [top_pkg::TL_AW-1:0]  addr_i,
  input  logic                       we_i,
  input  logic [top_pkg::TL_DW-1:0]  wdata_i,
  input  logic [top_pkg::TL_DBW-1:0] be_i,

  output logic                       valid_o,
  output logic [top_pkg::TL_DW-1:0]  rdata_o,
  output logic                       err_o,

  output tlul_pkg::tl_h2d_t          tl_o,
  input  tlul_pkg::tl_d2h_t          tl_i
);
  localparam int WordSize = $clog2(top_pkg::TL_DBW);

  logic [top_pkg::TL_AIW-1:0] tl_source;
  logic [top_pkg::TL_DBW-1:0] tl_be;

  if (MAX_REQS == 1) begin : g_single_req
    assign tl_source = '0;
  end else begin : g_multiple_reqs
    localparam int ReqNumW  = $clog2(MAX_REQS);

    logic [ReqNumW-1:0] source_d;
    logic [ReqNumW-1:0] source_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        source_q <= '0;
      end else begin
        source_q <= source_d;
      end
    end

    always_comb begin
      source_d = source_q;

      if (req_i && gnt_o) begin
        if (source_q == MAX_REQS - 1) begin
          source_d = '0;
        end else  begin
          source_d = source_q + 1;
        end
      end
    end

    assign tl_source = top_pkg::TL_AIW'(source_q);
  end

  // For TL-UL Get opcode all active bytes must have their mask bit set, so all reads get all tl_be
  // bits set. For writes the supplied be_i is used as the mask.
  assign tl_be = ~we_i ? {top_pkg::TL_DBW{1'b1}} : be_i;

  assign tl_o = '{
    a_valid:   req_i,
    a_opcode:  (~we_i) ? tlul_pkg::Get           :
               (&be_i) ? tlul_pkg::PutFullData   :
                         tlul_pkg::PutPartialData,
    a_param:   3'h0,
    a_size:    top_pkg::TL_SZW'(WordSize),
    a_mask:    tl_be,
    a_source:  tl_source,
    a_address: {addr_i[31:WordSize], {WordSize{1'b0}}},
    a_data:    wdata_i,
    a_user:    '{default:'0},

    d_ready:   1'b1
  };

  assign gnt_o   = tl_i.a_ready;

  assign valid_o = tl_i.d_valid;
  assign rdata_o = tl_i.d_data;
  assign err_o   = tl_i.d_error;

`ifdef INC_ASSERT
  localparam int OutstandingReqCntW =
    (MAX_REQS == 2 ** $clog2(MAX_REQS)) ? $clog2(MAX_REQS) + 1 : $clog2(MAX_REQS);

  logic [OutstandingReqCntW-1:0] outstanding_reqs_q;
  logic [OutstandingReqCntW-1:0] outstanding_reqs_d;

  always_comb begin
    outstanding_reqs_d = outstanding_reqs_q;

    if ((req_i && gnt_o) && !valid_o) begin
      outstanding_reqs_d = outstanding_reqs_q + 1;
    end else if (!(req_i && gnt_o) && valid_o) begin
      outstanding_reqs_d = outstanding_reqs_q - 1;
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      outstanding_reqs_q <= '0;
    end else begin
      outstanding_reqs_q <= outstanding_reqs_d;
    end
  end

  //`ASSERT(DontExceeedMaxReqs, req_i |-> outstanding_reqs_d <= MAX_REQS);
`endif
endmodule