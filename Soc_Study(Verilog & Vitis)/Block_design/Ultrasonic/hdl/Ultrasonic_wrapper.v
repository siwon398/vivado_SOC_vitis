//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
//Date        : Mon May 27 14:28:08 2024
//Host        : NOTEBOOK-SJ running 64-bit major release  (build 9200)
//Command     : generate_target Ultrasonic_wrapper.bd
//Design      : Ultrasonic_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module Ultrasonic_wrapper
   (com_0,
    echo_0,
    iic_rtl_scl_io,
    iic_rtl_sda_io,
    reset,
    seg_7_an_0,
    sys_clock,
    trigger_0,
    usb_uart_rxd,
    usb_uart_txd);
  output [3:0]com_0;
  input echo_0;
  inout iic_rtl_scl_io;
  inout iic_rtl_sda_io;
  input reset;
  output [7:0]seg_7_an_0;
  input sys_clock;
  output trigger_0;
  input usb_uart_rxd;
  output usb_uart_txd;

  wire [3:0]com_0;
  wire echo_0;
  wire iic_rtl_scl_i;
  wire iic_rtl_scl_io;
  wire iic_rtl_scl_o;
  wire iic_rtl_scl_t;
  wire iic_rtl_sda_i;
  wire iic_rtl_sda_io;
  wire iic_rtl_sda_o;
  wire iic_rtl_sda_t;
  wire reset;
  wire [7:0]seg_7_an_0;
  wire sys_clock;
  wire trigger_0;
  wire usb_uart_rxd;
  wire usb_uart_txd;

  Ultrasonic Ultrasonic_i
       (.com_0(com_0),
        .echo_0(echo_0),
        .iic_rtl_scl_i(iic_rtl_scl_i),
        .iic_rtl_scl_o(iic_rtl_scl_o),
        .iic_rtl_scl_t(iic_rtl_scl_t),
        .iic_rtl_sda_i(iic_rtl_sda_i),
        .iic_rtl_sda_o(iic_rtl_sda_o),
        .iic_rtl_sda_t(iic_rtl_sda_t),
        .reset(reset),
        .seg_7_an_0(seg_7_an_0),
        .sys_clock(sys_clock),
        .trigger_0(trigger_0),
        .usb_uart_rxd(usb_uart_rxd),
        .usb_uart_txd(usb_uart_txd));
  IOBUF iic_rtl_scl_iobuf
       (.I(iic_rtl_scl_o),
        .IO(iic_rtl_scl_io),
        .O(iic_rtl_scl_i),
        .T(iic_rtl_scl_t));
  IOBUF iic_rtl_sda_iobuf
       (.I(iic_rtl_sda_o),
        .IO(iic_rtl_sda_io),
        .O(iic_rtl_sda_i),
        .T(iic_rtl_sda_t));
endmodule
