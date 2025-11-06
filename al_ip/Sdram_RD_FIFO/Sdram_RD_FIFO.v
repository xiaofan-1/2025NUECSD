/************************************************************\
**	Copyright (c) 2012-2025 Anlogic Inc.
**	All Right Reserved.
\************************************************************/
/************************************************************\
**	Build time: Oct 21 2025 18:14:29
**	TD version	:	6.2.168116
************************************************************/
`timescale 1ns/1ps
module Sdram_RD_FIFO
(
  input                         rst,
  input   [15:0]                di,
  input                         clkr,
  input                         re,
  input                         clkw,
  input                         we,
  output  [15:0]                dout,
  output                        empty_flag,
  output                        aempty,
  output                        full_flag,
  output                        afull,
  output                        valid,
  output                        overflow,
  output                        underflow,
  output                        wr_success,
  output  [9:0]                 rdusedw,
  output  [9:0]                 wrusedw,
  output                        wr_rst_done,
  output                        rd_rst_done
);

  soft_fifo_971daf10a6ca
  #(
      .COMMON_CLK_EN(0),
      .MEMORY_TYPE(0),
      .RST_TYPE(1),
      .DATA_WIDTH_W(16),
      .ADDR_WIDTH_W(9),
      .DATA_WIDTH_R(16),
      .ADDR_WIDTH_R(9),
      .DOUT_INITVAL(16'h0),
      .OUTREG_EN("NOREG"),
      .SHOW_AHEAD_EN(1),
      .AL_FULL_NUM(509),
      .AL_EMPTY_NUM(2),
      .RDUSEDW_WIDTH(10),
      .WRUSEDW_WIDTH(10),
      .ASYNC_RST_SYNC_RELS(1),
      .SYNC_STAGE(2)
  )soft_fifo_971daf10a6ca_Inst
  (
      .rst(rst),
      .di(di),
      .clkr(clkr),
      .re(re),
      .clkw(clkw),
      .we(we),
      .dout(dout),
      .empty_flag(empty_flag),
      .aempty(aempty),
      .full_flag(full_flag),
      .afull(afull),
      .valid(valid),
      .overflow(overflow),
      .underflow(underflow),
      .wr_success(wr_success),
      .rdusedw(rdusedw),
      .wrusedw(wrusedw),
      .wr_rst_done(wr_rst_done),
      .rd_rst_done(rd_rst_done)
  );
endmodule
