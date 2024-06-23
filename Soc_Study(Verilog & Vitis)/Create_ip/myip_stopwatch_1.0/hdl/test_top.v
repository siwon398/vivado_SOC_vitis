`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/15 14:01:53
// Design Name: 
// Module Name: test_top
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

module stop_watch_csec(
        input clk, reset_p,
        input start_stop,
        input lap_swatch,
        output [15:0] value
);
        wire clk_usec, clk_msec, clk_sec, clk_csec;
        wire clk_start;
        wire [3:0] sec1, sec10, csec1, csec10;
        wire lap_load;
        wire [15:0] cur_time;
        
        reg [15:0] lap_time;
        
        clock_set clock(.clk(clk_start), .reset_p(reset_p),  .clk_usec(clk_usec), .clk_msec(clk_msec), 
                                                .clk_csec(clk_csec), .clk_sec(clk_sec));
        
        counter_dec_100 counter_csec(clk,reset_p,clk_csec, csec1, csec10);
        counter_dec_60 counter_sec(clk, reset_p, clk_sec,sec1,sec10);
       
        edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(lap_swatch), .p_edge(lap_load));
        
        assign cur_time = {sec10,sec1, csec10,csec1};
        assign clk_start = start_stop ? clk : 0;
        assign value = lap_swatch ? lap_time : cur_time;
        
        always @(posedge clk or posedge reset_p)begin
                if(reset_p)lap_time = 0;
                else if(lap_load) lap_time = cur_time;
        end
endmodule

module stop_watch_csec_top(
        input clk, reset_p,
        input [1:0]swcr,                 //stopwatch control register
        output [3:0] com,
        output [7:0] seg_7
);
        wire [15:0] value;
        wire start_stop, lap_swatch;
        
        assign start_stop = swcr[0];
        assign lap_swatch = swcr[1];
        
        stop_watch_csec stop_watch(clk, reset_p, start_stop, lap_swatch ,value);
        fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_an(seg_7), .com(com));
 
endmodule

