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

module up_counter_test_top(
    input clk, reset_p,
    output  [15:0] count,
    output [7:0] seg_7,
    output [3:0] com
);
        reg [31:0] count_32;

        always @(posedge clk, posedge reset_p)begin
                if(reset_p) count_32 = 0;
                else count_32 = count_32 +1;
        end                
        
        assign count = count_32[31:16];
        
        ring_counter_fnd rc(.clk(clk), .reset_p(reset_p), .com(com));
        
        reg [3:0] value;
        
        always @(posedge clk) begin
                case(com)
                        4'b0111: value = count_32[31:28];
                        4'b1011: value = count_32[27:24];
                        4'b1101: value = count_32[23:20];
                        4'b1110: value = count_32[19:16];
                endcase
        end
        
        decoder_7seg fnd (.hex_value(value), .seg_7(seg_7));
        
endmodule

module button_seg_7_top(
    input clk, reset_p,
    input [3:0] btn,
    output [7:0] seg_7);
    reg [7:0] btn_counter;
    wire [3:0]btnU_pedge;
  
    button_cntr btnU_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btnU_pedge[0]));
    button_cntr btnU_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btnU_pedge[1]));
    button_cntr btnU_cntr2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btnU_pedge[2]));
    button_cntr btnU_cntr3(.clk(clk), .reset_p(reset_p), .btn(btn[3]), .btn_pe(btnU_pedge[3]));
    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)btn_counter = 0;
        else begin
            if(btnU_pedge[0]) btn_counter = btn_counter + 1;
            else if(btnU_pedge[1]) btn_counter = btn_counter - 1;
             else if(btnU_pedge[2]) btn_counter = {btn_counter[6:0], btn_counter[7]};
            else if(btnU_pedge[3]) btn_counter = {btn_counter[0], btn_counter[7:1]};
        end
    end
    wire  [7:0] seg_7_bar;
    decoder_7seg(.hex_value(btn_counter[3:0]), .seg_7(seg_7_bar));
    assign seg_7 = ~seg_7_bar;
    
endmodule

module button_test_top(     //순서 논리 회로는 무조건 초기화 할 수 있어야 한다.
        input clk, reset_p,
        input [3:0]btnU,
        output [7:0] seg_7,
        output [3:0] com
);
        reg [15:0] btn_counter; 
        wire [3:0] btnU_pedge;
        
          button_cntr btnU_cntr0(.clk(clk), .reset_p(reset_p), .btn(btnU[0]), .btn_pe(btnU_pedge[0]));
          button_cntr btnU_cntr1(.clk(clk), .reset_p(reset_p), .btn(btnU[1]), .btn_pe(btnU_pedge[1]));
          button_cntr btnU_cntr2(.clk(clk), .reset_p(reset_p), .btn(btnU[2]), .btn_pe(btnU_pedge[2]));
          button_cntr btnU_cntr3(.clk(clk), .reset_p(reset_p), .btn(btnU[3]), .btn_pe(btnU_pedge[3]));
          
      
      
        always @(posedge clk, posedge reset_p)begin  //always 문에 들어가는 것은 clk 과 reset 만 들어간다. (다른 문법도 가능하지만 빠른 회로를 만들때는 두개만 쓴다.)
                if(reset_p) btn_counter = 0;
                
                else begin
                       if(btnU_pedge[0])  btn_counter = btn_counter + 1;
                       else if(btnU_pedge[1]) btn_counter = btn_counter - 1;
                       else if(btnU_pedge[2]) btn_counter = {btn_counter[14:0], btn_counter[15]};
                       else if(btnU_pedge[3]) btn_counter = {btn_counter[0], btn_counter[15:1]};
                end
        end
        fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(btn_counter), .seg_7_ca(seg_7), .com(com));
   
endmodule

module led_bar_top(
        input clk, reset_p,
        output [7:0] led_bar
);
        reg [31:0] clk_div;
        always @(posedge clk) clk_div = clk_div + 1;
        
        assign led_bar[0] = ~clk_div[24];
        assign led_bar[1] = ~clk_div[25];
        assign led_bar[2] = ~clk_div[26];
        assign led_bar[3] = ~clk_div[27];
        assign led_bar[4] = ~clk_div[28];
        assign led_bar[5] = ~clk_div[29];
        assign led_bar[6] = ~clk_div[30];
        assign led_bar[7] = ~clk_div[31];
endmodule 

module button_ledbar_top(
   input clk, reset_p,
   input [1:0] btnU,
   output reg [7:0]led_bar);
    reg [31:0]clk_div;
   always @(posedge clk) clk_div=clk_div+1;
   edge_detector_n ed(.clk(clk),.reset_p(reset_p), .cp(clk_div[16]), .p_edge(clk_div_16));
   reg [1:0]debounced_btn;      
   
   always @(posedge clk, posedge reset_p)begin
      if(reset_p) debounced_btn =0;
      else if (clk_div_16) debounced_btn[1:0] = btnU[1:0];
   end
   wire btnU_pedge[1:0];
   edge_detector_n ed2(.clk(clk),.reset_p(reset_p), .cp(debounced_btn[0]), .p_edge(btnU_pedge[0]));
   edge_detector_n ed3(.clk(clk),.reset_p(reset_p), .cp(debounced_btn[1]), .p_edge(btnU_pedge[1]));
   reg [7:0]count;
   always @(posedge clk, posedge reset_p) begin
      if(reset_p) count = 0;
       else begin
            if(btnU_pedge[0]) count = count+1;
            else if(btnU_pedge[1]) count = count-1;
        end
   end
   always @(posedge clk) begin
   led_bar = ~count;
   end
   
//   always@(posedge clk) begin
//      case(count)
//         3'b000: led_bar=8'b1111_1110;
//         3'b001: led_bar=8'b1111_1101;
//         3'b010: led_bar=8'b1111_1011;
//         3'b011: led_bar=8'b1111_0111;
//         3'b100: led_bar=8'b1110_1111;
//         3'b101: led_bar=8'b1101_1111;
//         3'b110: led_bar=8'b1011_1111;
//         3'b111: led_bar=8'b0111_1111;
//      endcase
//   end
endmodule

module keypad_test_top(
        input clk, reset_p,
        input [3:0] row,
        output [3:0] col,
        output [7:0] seg_7,
        output [3:0] com
       
);
        wire [3:0] key_value;
        reg [15:0] key_counter;
        key_pad_cntr key_pad(.clk(clk), .reset_p(reset_p), .row(row), .col(col), .key_value(key_value), .key_valid(key_valid));
        
        edge_detector_n ed1(.clk(clk), .reset_p(reset_p), .cp(key_valid), .p_edge(key_valid_pe));
        
        always @(posedge clk or posedge reset_p)begin
                if(reset_p) key_counter = 0;
                else if(key_valid_pe)begin
                        if(key_value == 1) key_counter = key_counter + 1;
                        else if(key_value == 2) key_counter = key_counter - 1;                
                end
        end
        fnd_4digit_cntr(.clk(clk), .reset_p(reset_p), .value(key_counter), .seg_7_ca(seg_7), .com(com));
endmodule

module watch_top(
        input clk, reset_p,
        input [2:0] btn,
        output [3:0] com,
        output [7:0] seg_7
);
        wire clk_usec, clk_msec, clk_sec, clk_min;
        wire [3:0] sec1, sec10 ,min1, min10;
        wire sec_edge, min_edge;
        wire [2:0] btn_pedge;
        wire set_mode;
        
        counter_dec_60 counter_sec(clk, reset_p, sec_edge, sec1, sec10);
        counter_dec_60 counter_min(clk, reset_p, min_edge, min1, min10);
        clock_set clock(.clk(clk), .reset_p(reset_p),  .clk_usec(clk_usec), .clk_msec(clk_msec), 
                                                .clk_sec(clk_sec), .clk_min(clk_min));
       
        fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value({min10, min1, sec10, sec1}), .seg_7_ca(seg_7), .com(com));
        
        button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
        button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
        button_cntr btn_cntr2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));
        
        t_flip_flop_p tff_setmode(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(set_mode));
        
        assign sec_edge = set_mode ? btn_pedge[1] : clk_sec;
        assign min_edge = set_mode ? btn_pedge[2] : clk_min;
    
endmodule

module loadable_watch(
        input clk, reset_p,
        input [2:0] btn_pedge,
        output [15:0] value
);
        wire clk_usec, clk_msec, clk_sec, clk_min;
        wire sec_edge, min_edge;
        wire set_mode;
        wire cur_time_load_en, set_time_load_en;
        wire [3:0] cur_sec1, cur_sec10, set_sec1, set_sec10;
        wire [3:0] cur_min1, cur_min10, set_min1, set_min10;
        wire [15:0] cur_time, set_time;
        
         clock_set clock(.clk(clk), .reset_p(reset_p),  .clk_usec(clk_usec), .clk_msec(clk_msec), 
                                                .clk_sec(clk_sec), .clk_min(clk_min));
        
        loadable_counter_dec_60 cur_time_sec(.clk(clk), .reset_p(reset_p), .clk_time(clk_sec), 
                            .load_enable(cur_time_load_en), .set_value1(set_sec1), .set_value10(set_sec10),
                            .dec1(cur_sec1), .dec10(cur_sec10));
                            
        loadable_counter_dec_60 cur_time_min(.clk(clk), .reset_p(reset_p), .clk_time(clk_min), 
                            .load_enable(cur_time_load_en), .set_value1(set_min1), .set_value10(set_min10),
                            .dec1(cur_min1), .dec10(cur_min10));
                            
        loadable_counter_dec_60 set_time_sec(.clk(clk), .reset_p(reset_p), .clk_time(btn_pedge[1]), 
                            .load_enable(set_time_load_en), .set_value1(cur_sec1), .set_value10(cur_sec10),
                            .dec1(set_sec1), .dec10(set_sec10));
                            
        loadable_counter_dec_60 set_time_min(.clk(clk), .reset_p(reset_p), .clk_time(btn_pedge[2]), 
                            .load_enable(set_time_load_en), .set_value1(cur_min1), .set_value10(cur_min10),
                            .dec1(set_min1), .dec10(set_min10));
    
        t_flip_flop_p tff_setmode(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(set_mode));
        
        edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(set_mode), .n_edge(cur_time_load_en), .p_edge(set_time_load_en));
          
        assign cur_time = {cur_min10, cur_min1, cur_sec10, cur_sec1};
        assign set_time = {set_min10, set_min1, set_sec10, set_sec1};
        assign value = set_mode ? set_time : cur_time;
        assign sec_edge = set_mode ? btn_pedge[1] : clk_sec;
        assign min_edge = set_mode ? btn_pedge[2] : clk_min;
    
endmodule


module loadable_watch_top(
        input clk, reset_p,
        input [2:0] btn,
        output [3:0] com,
        output [7:0] seg_7
);
        
       wire [15:0] value;
       wire [2:0] btn_pedge;
       
        button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
        button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
        button_cntr btn_cntr2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));
        
        loadable_watch watch(clk, reset_p, btn_pedge, value);
        fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_ca(seg_7), .com(com));
        
endmodule

module stop_watch_csec(
        input clk, reset_p,
        input [2:0] btn_pedge,
        output [15:0] value
);
        wire clk_usec, clk_msec, clk_sec, clk_csec;
        wire start_stop;
        wire clk_start;
        wire [3:0] sec1, sec10, csec1, csec10;
        wire lap_swatch, lap_load;
        wire [15:0] cur_time;
        
        reg [15:0] lap_time;
        
        clock_set clock(.clk(clk_start), .reset_p(reset_p),  .clk_usec(clk_usec), .clk_msec(clk_msec), 
                                                .clk_csec(clk_csec), .clk_sec(clk_sec));
      
        t_flip_flop_p tff_start(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(start_stop));
        t_flip_flop_p tff_lap(.clk(clk), .reset_p(reset_p), .t(btn_pedge[1]), .q(lap_swatch));
        
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


module stop_watch_top(
        input clk, reset_p,
        input[2:0] btn,
        output [3:0] com,
        output [7:0] seg_7
);
        wire clk_usec, clk_msec, clk_sec, clk_min;
        wire [2:0] btn_pedge;
        wire start_stop;
        wire clk_start;
        wire [3:0] sec1, sec10, min1, min10;
        
        clock_usec usec_clk(clk_start,reset_p,clk_usec); //.뒤에 있는건 순서만 맞으면 생략해 줄 수 있다. .을 붙이면 순서가 달라도 괜찮음
        clock_div_1000 msec_clk(clk_start, reset_p, clk_usec, clk_msec);
        clock_div_1000 sec_clk(clk_start,reset_p, clk_msec, clk_sec);
        clock_min min_clk(clk_start,reset_p, clk_sec, clk_min);
        
        button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
        button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
        button_cntr btn_cntr2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));
        
        t_flip_flop_p tff_setmode(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(start_stop));
        
        assign clk_start = start_stop ? clk : 0;
        
        counter_dec_60 counter_sec(clk, reset_p, clk_sec,sec1,sec10);
        counter_dec_60 counter_min(clk,reset_p, clk_min,min1, min10);
         fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value({min10, min1, sec10, sec1}), .seg_7_ca(seg_7), .com(com));
        
endmodule

module stop_watch_lap_top(
        input clk, reset_p,
        input[2:0] btn,
        output [3:0] com,
        output [7:0] seg_7
);
        wire clk_usec, clk_msec, clk_sec, clk_min;
        wire [2:0] btn_pedge;
        wire start_stop;
        wire clk_start;
        wire [3:0] sec1, sec10, min1, min10;
        wire lap_swatch, lap_load;
        reg [15:0] lap;
        wire [15:0] value;
        
        clock_usec usec_clk(clk_start,reset_p,clk_usec); //.뒤에 있는건 순서만 맞으면 생략해 줄 수 있다. .을 붙이면 순서가 달라도 괜찮음
        clock_div_1000 msec_clk(clk_start, reset_p, clk_usec, clk_msec);
        clock_div_1000 sec_clk(clk_start,reset_p, clk_msec, clk_sec);
        clock_min min_clk(clk_start,reset_p, clk_sec, clk_min);
        
        button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
        button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
        button_cntr btn_cntr2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));
        
        t_flip_flop_p tff_start(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(start_stop));
        t_flip_flop_p tff_lap(.clk(clk), .reset_p(reset_p), .t(btn_pedge[1]), .q(lap_swatch));
       
        counter_dec_60 counter_sec(clk, reset_p, clk_sec,sec1,sec10);
        counter_dec_60 counter_min(clk,reset_p, clk_min,min1, min10);
        
        edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(lap_swatch), .p_edge(lap_load));
        assign clk_start = start_stop ? clk : 0;
        
        always @(posedge clk or posedge reset_p)begin
                if(reset_p)lap = 0;
                else if(lap_load) lap = {min10, min1, sec10, sec1};
        end
        
        assign value = lap_swatch ? lap : {min10, min1, sec10, sec1};
        
        fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_ca(seg_7), .com(com));
endmodule

module stop_watch_lap_msec_top(
        input clk, reset_p,
        input [2:0] btn,
        output [3:0] com,
        output [7:0] seg_7
);
        
        wire [2:0] btn_pedge;
        wire [15:0] value;
      
        button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
        button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
        button_cntr btn_cntr2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));
        
        stop_watch_csec stop_watch(clk, reset_p, btn_pedge, value);
        fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_ca(seg_7), .com(com));
 
endmodule

/*module stop_watch_led(
        input clk, reset_p,
        input [3:0] btn,
        output led,
        output [3:0] com,
        output [7:0] seg_7
);
        wire clk_start;
        wire start_stop;
        wire [2:0] btn_pedge;
        wire clk_usec, clk_msec, clk_sec, clk_min;
        wire [3:0] sec1, sec10, min1, min10;
        
        
        //assign cur_time = {cur_min10, cur_min1, cur_sec10, cur_sec1};
      //  assign set_time = {set_min10, set_min1, set_sec10, set_sec1};
        assign value = start_stop ? cur_time : set_time;
        
        clock_usec usec_clk(clk_start,reset_p,clk_usec); //.뒤에 있는건 순서만 맞으면 생략해 줄 수 있다. .을 붙이면 순서가 달라도 괜찮음
        clock_div_1000 msec_clk(clk_start, reset_p, clk_usec, clk_msec);
        clock_div_1000 sec_clk(clk_start,reset_p, clk_msec, clk_sec);
        clock_min min_clk(clk_start,reset_p, clk_sec, clk_min);
        
        button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
        button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
        button_cntr btn_cntr2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));
        
         t_flip_flop_p tff_start(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(start_stop));
         
         counter_dec_60 counter_sec(clk, reset_p, btn_pedge[1], sec1, sec10);
         counter_dec_60 counter_min(clk, reset_p, btn_pedge[2], min1, min10);
         counter_dec_60_down downcounter_sec(clk, reset_p, clk_sec,sec1,sec10);
         counter_dec_60_down downcounter_min(clk, reset_p, clk_min,min1,min10);
        
        assign clk_start = start_stop ? clk : 0;
        fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value({min10, min1, sec10, sec1}), .seg_7_ca(seg_7), .com(com));
        
endmodule*/

module cook_timer(
        input clk,reset_p,
        input [3:0] btn_pedge,
        output [15:0] value,
        output buzz_clk,
        output [5:0] led
);      

        wire btn_start, inc_sec, inc_min, alarm_off;
        wire [3:0] set_sec1, set_sec10, set_min1, set_min10;          //설정 시간
        wire [3:0] cur_sec1, cur_sec10, cur_min1, cur_min10;        //현재 시간
        wire load_enable, dec_clk;
        wire clk_start;
        wire [15:0] cur_time, set_time;
        wire timeout_pedge;
        
        reg [16:0] clk_div = 0;
        reg time_out;
        reg start_stop;
        reg alarm;
        
        assign {alarm_off, inc_min, inc_sec, btn_start} = btn_pedge;
        assign clk_start = start_stop ? clk : 0;
        assign cur_time = {cur_min10, cur_min1, cur_sec10, cur_sec1};
        assign set_time = {set_min10, set_min1, set_sec10, set_sec1};
        assign value = start_stop ? cur_time : set_time;
        
        assign led[5] = start_stop;
        assign led[4] = time_out;
        assign led[0] = buzz_clk;
        

        clock_set clock(.clk(clk_start), .reset_p(reset_p),  .clk_usec(clk_usec), .clk_msec(clk_msec), 
                                              .clk_sec(clk_sec));
        
        counter_dec_60 set_sec(clk, reset_p, inc_sec, set_sec1, set_sec10);                              // 초 증가 
        counter_dec_60 set_min(clk, reset_p, inc_min, set_min1, set_min10);                            // 분 증가
        
        loadable_downcounter_dec_60 cur_sec( .clk(clk), .reset_p(reset_p), .clk_time(clk_sec), .load_enable(load_enable), 
                                                             .set_value1(set_sec1), .set_value10(set_sec10), .dec1(cur_sec1), 
                                                                .dec10(cur_sec10), .dec_clk(dec_clk));
                                                                
        loadable_downcounter_dec_60 cur_min( .clk(clk), .reset_p(reset_p), .clk_time(dec_clk), .load_enable(load_enable), 
                                                             .set_value1(set_min1), .set_value10(set_min10), .dec1(cur_min1), 
                                                                .dec10(cur_min10)); //dec_clk은 위에 선언되있기 떄문에 지워줘야함 
                                                                
        always @(posedge clk or posedge reset_p)begin
                if(reset_p)begin
                        alarm = 0;
                end
                else begin
                        if(timeout_pedge) alarm = 1;
                        
                        else if(alarm && alarm_off)alarm = 0;
                end
        end  
   
        always @(posedge clk or posedge reset_p)begin
                if(reset_p) start_stop = 0;
                else begin
                        if(btn_start)start_stop = ~start_stop;
                        else if(timeout_pedge) start_stop = 0;
                end
        end
        
        always @(posedge clk or posedge reset_p)begin
                if(reset_p) time_out = 0;
                else begin
                        if(start_stop && clk_msec && cur_time == 0) time_out = 1;
                        else time_out = 0;
                end
        end
        edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(start_stop), .p_edge(load_enable));
        edge_detector_n ed_timeout(.clk(clk), .reset_p(reset_p), .cp(time_out), .p_edge(timeout_pedge));
        
        
        
        always @(posedge clk) clk_div = clk_div + 1;
        
        assign buzz_clk = alarm ? clk_div[12] : 0;
endmodule

module cook_timer_top(
        input clk,reset_p,
        input [3:0] btn,
        output [3:0] com,
        output [7:0] seg_7
        //output [5:0] led,
       // output buzz_clk
);      
        wire btn_start, inc_sec, inc_min, alarm_off;
        wire [15:0] value;
        wire [3:0] btn_pedge;
        
        button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
        button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
        button_cntr btn_cntr2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));
        button_cntr btn_cntr3(.clk(clk), .reset_p(reset_p), .btn(btn[3]), .btn_pe(btn_pedge[3]));       //버튼 생성

        cook_timer cook(clk, reset_p, btn_pedge, value, led, buzz_clk);
        fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_ca(seg_7), .com(com));
        
endmodule

module clock_mode(
    
    input clk,reset_p,
    input mode_btn,
    input [3:0] btn,       
    output reg [3:0] com,       
    output reg [7:0] seg_7,
    output [5:0] led
   
);
        //모듈 가져옴 (시계, 스톱워치, 타이머)
        watch_top watch(.clk(clk), .reset_p(reset_p), .btn(btn_watch), .com(watch_com) ,.seg_7(watch_seg_7));
        stop_watch_lap_msec_top stop_watch(.clk(clk), .reset_p(reset_p), .btn(btn_stop_watch), .com(stop_watch_com), .seg_7(stop_watch_seg_7));
        cook_timer timer(.clk(clk), .reset_p(reset_p), .btn(btn_timer), .com(timer_com), .seg_7(timer_seg_7), .led(led));
        button_cntr btn_cntr(.clk(clk), .reset_p(reset_p), .btn(mode_btn), .btn_pe(mod_btn));
        
    wire mod_btn;
    wire [7:0] watch_seg_7, stop_watch_seg_7, timer_seg_7;
    wire  [3:0] watch_com, stop_watch_com, timer_com;
    reg [2:0] mode;
    reg [3:0] btn_watch, btn_stop_watch, btn_timer;
    reg alarm;
    

    assign led[0] = alarm;
    //모드변경 링카운터 생성 
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) mode <= 3'b001;
            else if(mod_btn) mode <= {mode[1:0], mode[2]};
    end
    
    always @(posedge clk)begin
            case (mode)
                    3'b001 : begin
                    com <= watch_com;
                    seg_7 <= watch_seg_7;
                    btn_watch = btn;
                    btn_stop_watch = 0;
                    btn_timer = 0;
                    end
                    
                    3'b010 : begin
                    com <= stop_watch_com;
                    seg_7 <= stop_watch_seg_7;
                    btn_watch = 0;
                    btn_stop_watch = btn;
                    btn_timer = 0;
                    end
                    
                    3'b100 : begin
                    com <= timer_com;
                    seg_7 <= timer_seg_7;
                    btn_watch = 0;
                    btn_stop_watch = 0;
                    btn_timer = btn;
                    end
                    
                    default : begin
                            seg_7 <= 0;
                    end
                    
            endcase
    end
endmodule

module multy_purpose_watch(
        input clk, reset_p,
        input [4:0] btn,
        output [3:0] com,
        output [7:0] seg_7,
        output [5:0] led,
        output buzz_clk
);      
        //파라미터 선언
        parameter watch_mode = 3'b001;
        parameter stop_watch_mode = 3'b010;
        parameter cook_timer_mode = 3'b100;

        wire [2:0] watch_btn, stopw_btn;
        wire [3:0] cook_btn;
        wire [15:0] value, watch_value, stop_watch_value, cook_timer_value;
        wire btn_mode;
        wire [3:0] btn_pedge;
        
        reg [2:0] mode;
        
        
        button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
        button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
        button_cntr btn_cntr2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));
        button_cntr btn_cntr3(.clk(clk), .reset_p(reset_p), .btn(btn[3]), .btn_pe(btn_pedge[3]));    
        button_cntr btn_cntr4(.clk(clk), .reset_p(reset_p), .btn(btn[4]), .btn_pe(btn_mode));   //버튼 생성
        
        //모듈 가져옴(시계, 스톱워치, 타이머)
        loadable_watch watch(clk, reset_p, watch_btn, watch_value);
        stop_watch_csec stop_watch(clk, reset_p, stopw_btn, stop_watch_value);
        cook_timer cook(clk, reset_p, cook_btn, cook_timer_value, led, buzz_clk);
        
         fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_ca(seg_7), .com(com));
        
        //링카운트
        always @(posedge clk or posedge reset_p)begin
                if(reset_p) mode = watch_mode;
                else if(btn_mode)begin
                        case(mode)
                                watch_mode : mode = stop_watch_mode;
                                stop_watch_mode : mode = cook_timer_mode;
                                cook_timer_mode : mode = watch_mode;
                                default : mode = watch_mode;
                        endcase
                end
        end
        
        assign value = (mode == cook_timer_mode) ? cook_timer_value:
                                (mode == stop_watch_mode) ? stop_watch_value:
                                watch_value;
       
        //Demux
        assign {cook_btn, stopw_btn, watch_btn} = (mode == watch_mode) ? {7'b0, btn_pedge[2:0]} :
                                                                            (mode == stop_watch_mode) ? {4'b0, btn_pedge[2:0], 3'b0} : {btn_pedge[3:0], 6'b0};
endmodule


module dht11_top(
        input clk, reset_p,
        inout dht11_data,
        output [3:0] com,
        output [7:0] seg_7,
        output [7:0] led_bar
);
        wire [7:0] humidity, temperature;
        
        dht11 dht(clk, reset_p,dht11_data, humidity, temperature, led_bar);
        
        wire [15:0] bcd_humi, bcd_tmpr;
        bin_to_dec humi(.bin({4'b0000, humidity}), .bcd(bcd_humi));
        bin_to_dec tmpr(.bin({4'b0000, temperature}), .bcd(bcd_tmpr));
        
        wire [15:0] value;
        //assign value = {humidity, temperature};
        assign value = {bcd_humi[7:0], bcd_tmpr[7:0]};
        
        fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_ca(seg_7), .com(com));
endmodule

/*
module ultrasonic_top(
    input clk, reset_p,
    input echo, // 에코 펄스 (100us ~ 18ms)
    output trig, // 트리거 펄스 (10us 최소)
    output [3:0] com,
    output [7:0] seg_7,
    output [2:0] led_bar);
    wire [11:0] distance_value;
    ultrasonic ultsonic( clk, reset_p, echo, trig, distance_value, led_bar);
    wire [15:0] bcd_distance;
    bin_to_dec distance(.bin({4'b0000, distance_value}), .bcd(bcd_distance));
    wire [15:0] value;
    assign value = bcd_distance;
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(distance_value), .seg_7_ca(seg_7), .com(com));
endmodule
*/

module ultrasonic_top(
    input clk, reset_p,
    input echo, // 에코 펄스 (100us ~ 18ms)
    output trig, // 트리거 펄스 (10us 최소)
    output [3:0] com,
    output [7:0] seg_7
    );
    wire [11:0] distance_data;
    wire [15:0] bcd_distance;
    
    ultrasonic ultsonic(.clk(clk), .reset_p(reset_p), .echo(echo), .trigger(trig), .distance(distance_data));
   
    bin_to_dec distance(.bin(distance_data), .bcd(bcd_distance));
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(bcd_distance), .seg_7_ca(seg_7), .com(com));
endmodule

module led_pwm_top(
        input clk, reset_p,
        output [2:0]led_pwm
);

        reg [27:0] clk_div = 0;
        always @(posedge clk)clk_div = clk_div + 1;

        pwm_100pc pwm_led_r(.clk(clk), .reset_p(reset_p), .duty(clk_div[27:21]), 
                .pwm_freq(10000), .pwm_100pc(led_pwm[0]));
        pwm_100pc pwm_led_g(.clk(clk), .reset_p(reset_p), .duty(clk_div[26:20]), 
                .pwm_freq(10000), .pwm_100pc(led_pwm[1]));
        pwm_100pc pwm_led_b(.clk(clk), .reset_p(reset_p), .duty(clk_div[25:19]), 
                .pwm_freq(10000), .pwm_100pc(led_pwm[2]));
        
endmodule

module ultrasonic_top(
    input clk, reset_p,
    input echo, // 에코 펄스 (100us ~ 18ms)
    output trig, // 트리거 펄스 (10us 최소)
    output [3:0] com,
    output [7:0] seg_7
    );
    wire [11:0] distance_data;
    wire [15:0] bcd_distance;
    
    ultrasonic ultsonic(.clk(clk), .reset_p(reset_p), .echo(echo), .trigger(trig), .distance(distance_data));
   
    bin_to_dec distance(.bin(distance_data), .bcd(bcd_distance));
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(bcd_distance), .seg_7_ca(seg_7), .com(com));
endmodule

module led_pwm_top(
        input clk, reset_p,
        output [2:0]led_pwm
);

        reg [27:0] clk_div = 0;
        always @(posedge clk)clk_div = clk_div + 1;

        pwm_100pc pwm_led_r(.clk(clk), .reset_p(reset_p), .duty(clk_div[27:21]), 
                .pwm_freq(10000), .pwm_100pc(led_pwm[0]));
        pwm_100pc pwm_led_g(.clk(clk), .reset_p(reset_p), .duty(clk_div[26:20]), 
                .pwm_freq(10000), .pwm_100pc(led_pwm[1]));
        pwm_100pc pwm_led_b(.clk(clk), .reset_p(reset_p), .duty(clk_div[25:19]), 
                .pwm_freq(10000), .pwm_100pc(led_pwm[2]));
        
endmodule


module dc_motor_pwm_top(
        input clk, reset_p,
        output motor_pwm
);
        reg [29:0] clk_div;
        initial clk_div = 0;
        always @(posedge clk)clk_div = clk_div + 1;
        pwm_128step pwm_motor(.clk(clk), .reset_p(reset_p), .duty(clk_div[29:22]), 
                                .pwm_freq(100), .pwm_128(motor_pwm));


endmodule

module servo_motor_top(
        input clk, reset_p,
        input [3:0] btn,
        output s_motor_pwm
);
        parameter ANGLE0 = 7'b0000001;
        parameter ANGLE30 = 7'b0000010;
        parameter ANGLE60 = 7'b0000100;
        parameter ANGLE90 = 7'b0001000;
        parameter ANGLE120 = 7'b0010000;
        parameter ANGLE150 = 7'b0100000;
        parameter ANGLE180 = 7'b1000000;
        
        wire  [3:0] btn_pedge;
        wire [7:0] duty_cycle;
        reg [7:0] temp;
        reg [6:0] angle;
        assign duty_cycle = temp;
      
        button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
        button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
        button_cntr btn_cntr2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));
        button_cntr btn_cntr3(.clk(clk), .reset_p(reset_p), .btn(btn[3]), .btn_pe(btn_pedge[3]));
        
         pwm_servo pwm_ser(.clk(clk), .reset_p(reset_p), .duty(duty_cycle), 
                                      .pwm_freq(50), .pwm_signal(s_motor_pwm));
        
                       
        always @(posedge clk or posedge reset_p)begin
                if(reset_p)begin
                        temp = 0;
                        angle = ANGLE0;
                end
                else begin
                        if(btn_pedge[0]) temp = 7;
                        else if(btn_pedge[1]) temp = 20;
                        else if(btn_pedge[2]) temp = 32;
                       else if(btn_pedge[3])begin
                            case(angle)
                                    ANGLE0 : begin
                                            angle = ANGLE30;
                                            temp = 11;
                                    end
                                    ANGLE30 :  begin
                                            angle = ANGLE60;
                                            temp = 16;
                                    end
                                    ANGLE60 : begin
                                            angle = ANGLE90;
                                            temp = 20;
                                    end
                                    ANGLE90 : begin
                                            angle = ANGLE120;
                                            temp = 24;
                                end
                                    ANGLE120 : begin
                                            angle = ANGLE150;
                                            temp = 28;
                                end
                                ANGLE150 : begin
                                        angle = ANGLE180;
                                        temp = 32;
                                end
                                ANGLE180 : begin
                                        angle = ANGLE0;
                                        temp = 7;
                                end
                                default : begin
                                        angle = ANGLE0;
                                        temp = 7;
                                end
                        endcase
                end
                end
        end
endmodule 

module servo_sg90(
    input clk, reset_p,
    input [2:0] btn,
    output sg90,
    output [3:0] com,
    output [7:0] seg_7
);

        reg [31:0] clk_div;
        always @(posedge clk) clk_div = clk_div + 1;
        wire [2:0] btn_pedge;
        wire clk_div_pedge;
        
        edge_detector_n ed_timeout(.clk(clk), .reset_p(reset_p), .cp(clk_div[17]), .p_edge(clk_div_pedge));
        button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
        button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
        button_cntr btn_cntr2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));

        reg [21:0] duty;
        reg up_down;
        

        always @(posedge clk or posedge reset_p)begin
                if(reset_p)begin
                        duty = 100000;
                        up_down = 1;
                end
                else if(btn_pedge[0])begin
                       if(up_down) up_down = 0;
                       else up_down = 1;
                end
                else if(btn_pedge[1])begin
                        duty = 58_000;
                end
                else if(btn_pedge[2])begin
                        duty = 326_000;
                end
                else if(clk_div_pedge)begin
                        if(duty >= 326_000)up_down = 0;
                        else if(duty <= 58_000)up_down = 1;
                                
                        if(up_down)duty = duty + 100;
                        else duty = duty - 100;
                end
        end
    
        pwm512_period pwm_ser(.clk(clk), .reset_p(reset_p), .duty(duty), 
                                          .pwm_period(3_000_000), .pwm_512(sg90));
        wire [15:0] bcd_duty;
        bin_to_dec dist(.bin(duty[21:10]), .bcd(bcd_duty));

        fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(bcd_duty), .seg_7_ca(seg_7), .com(com));

endmodule

module adc_top(
        input clk,reset_p,
        input vauxp6, vauxn6,
        output [3:0] com,
        output [7:0] seg_7,
        output led_pwm      
);
        wire [4:0] channel_out;
        wire eoc_out;
        wire [15:0] do_out;
        wire [15:0] bcd_value;
        wire eoc_out_pedge;
        
        reg[11:0] adc_value;
        
         xadc_wiz_0 adc_ch6
          (
          .daddr_in({2'b0, channel_out}),            // Address bus for the dynamic reconfiguration port
          .dclk_in(clk),             // Clock input for the dynamic reconfiguration port
          .den_in(eoc_out),              // Enable Signal for the dynamic reconfiguration port
//          di_in,               // Input data bus for the dynamic reconfiguration port
//          dwe_in,              // Write Enable for the dynamic reconfiguration port
          .reset_in(reset_p),            // Reset signal for the System Monitor control logic
          .vauxp6(vauxp6),              // Auxiliary channel 6
          .vauxn6(vauxn6),
//          busy_out,            // ADC Busy signal
          .channel_out(channel_out),         // Channel Selection Outputs
          .do_out(do_out),              // Output data bus for dynamic reconfiguration port //여기값이 디지털값 
//          drdy_out,            // Data ready signal for the dynamic reconfiguration port
          .eoc_out(eoc_out)             // End of Conversion Signal
//          eos_out,             // End of Sequence Signal
//          alarm_out,           // OR'ed output of all the Alarms    
//          vp_in,               // Dedicated Analog Input Pair
//          vn_in
);
            edge_detector_n ed_timeout(.clk(clk), .reset_p(reset_p), .cp(eoc_out), .p_edge(eoc_out_pedge)); 
            
            bin_to_dec adc_bcd(.bin(adc_value), .bcd(bcd_value));
            
            fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(bcd_value), .seg_7_ca(seg_7), .com(com));
            
            pwm_128step pwm_led_r(.clk(clk), .reset_p(reset_p), .duty(do_out[15:9]), 
                                .pwm_freq(10000), .pwm_128(led_pwm));
                                
            always @(posedge clk or posedge reset_p)begin
                    if(reset_p) adc_value = 0;
                    else if (eoc_out_pedge)adc_value = {4'b0,do_out[15:8]};
            end
endmodule

module adc_sequence2_top(
        input clk, reset_p,
        input vauxp6, vauxn6,
        input vauxp15, vauxn15,
        output led_r, led_g,
        output [3:0] com,
        output [7:0] seg_7
);

        wire [4:0] channel_out;
        wire [15:0] do_out;
        wire eoc_out, eoc_out_pedge;
        wire [15:0] bcd_value_x, bcd_value_y;
        
        reg[11:0] adc_value_x, adc_value_y;
        
        adc_ch6_ch15 adc_seq2
          (
          .daddr_in({2'b0, channel_out}),            // Address bus for the dynamic reconfiguration port
          .dclk_in(clk),             // Clock input for the dynamic reconfiguration port
          .den_in(eoc_out),              // Enable Signal for the dynamic reconfiguration port
          .vauxp6(vauxp6),              // Auxiliary channel 6
          .vauxn6(vauxn6),
          .vauxp15(vauxp15),             // Auxiliary channel 15
          .vauxn15(vauxn15),
          .channel_out(channel_out),         // Channel Selection Outputs
          .do_out(do_out),              // Output data bus for dynamic reconfiguration port
          .eoc_out(eoc_out),             // End of Conversion Signal
          .eos_out(eos_out)             // End of Sequence Signal
          );
          
          edge_detector_n ed_timeout(.clk(clk), .reset_p(reset_p), .cp(eoc_out), .p_edge(eoc_out_pedge)); 
          
          bin_to_dec adc_bcdx(.bin(adc_value_x), .bcd(bcd_value_x));
           bin_to_dec adc_bcdy(.bin(adc_value_y), .bcd(bcd_value_y));
            
          fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value({bcd_value_x[7:0], bcd_value_y[7:0]}), .seg_7_ca(seg_7), .com(com));
          
          pwm_128step pwm_led_r(.clk(clk), .reset_p(reset_p), .duty(adc_value_x[6:0]), 
                                .pwm_freq(10000), .pwm_128(led_r));
                                
          pwm_128step pwm_led_g(.clk(clk), .reset_p(reset_p), .duty(adc_value_y[6:0]), 
                                .pwm_freq(10000), .pwm_128(led_g));
          
            always @(posedge clk or posedge reset_p)begin
                    if(reset_p)begin
                            adc_value_x = 0;
                            adc_value_y = 0;   
                    end        
                    else if (eoc_out_pedge)begin
                            case(channel_out[3:0])
                                    6: adc_value_x = {4'b0,do_out[15:10]}; //2 4 8 16 32 64 최대 64까지
                                    15 : adc_value_y = {4'b0,do_out[15:10]};
                            endcase
                    end
            end         
            
endmodule

module I2C_master_top(
        input clk, reset_p,
        input [1:0] btn,
        output sda, scl
);
        wire[1:0] btn_pedge, btn_nedge;

        reg [7:0] data;
        reg valid;

        I2C_master master(.clk(clk), .reset_p(reset_p), .rd_wr(0), .valid(valid), .addr(7'h27), .data(data), .sda(sda), .scl(scl));

        button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_ne(btn_nedge[0]), .btn_pe(btn_pedge[0]));
        button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_ne(btn_nedge[1]), .btn_pe(btn_pedge[1]));

        always @(posedge clk or posedge reset_p) begin
                if (reset_p) begin
                        data = 0;
                        valid = 0;
                end
                else begin
                        if (btn_pedge[0]) begin
                                data = 8'b0000_0000;
                                valid = 1;
                        end
                        else if (btn_nedge[0]) valid = 0;
                        else if (btn_pedge[1]) begin
                                data = 8'b1111_1111;
                                valid = 1;
                        end
                        else if(btn_nedge[1]) valid = 0;
                end
        end

endmodule

module i2c_txtlcd_top(
    input clk, reset_p,
    input [2:0]btn,
    output scl, sda);

    parameter IDLE = 6'b00_0001;
    parameter INIT = 6'b00_0010;
    parameter SEND = 6'b00_0100;
    parameter MOVE_CURSOR = 6'b00_1000;
    parameter SHIFT_DISPLAY = 6'b01_0000;
    
    parameter SAMPLE_DATA = "A";
    
    wire [2:0] btn_pedge, btn_nedge;    
    button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), 
        .btn_pe(btn_pedge[0]), .btn_ne(btn_nedge[0]));
    button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), 
        .btn_pe(btn_pedge[1]), .btn_ne(btn_nedge[1]));
    button_cntr btn_cntr2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), 
        .btn_pe(btn_pedge[2]), .btn_ne(btn_nedge[2]));
    
    reg [7:0] send_buffer;
    reg send_e, rs;
    wire busy;
    reg [3:0] cnt_data;
    i2c_lcd_send_byte send_byte(.clk(clk), .reset_p(reset_p),
        .addr(7'h27), .send_buffer(send_buffer), .send(send_e), .rs(rs),
        .scl(scl), .sda(sda), .busy(busy));
    
    reg [21:0] count_usec;
    reg count_usec_e;
    wire clk_usec;
    clock_usec usec_clk(clk, reset_p, clk_usec);
    
    always @(negedge clk or posedge reset_p)begin
        if(reset_p)begin
            count_usec = 0;
        end
        else begin
            if(clk_usec && count_usec_e)count_usec = count_usec + 1;
            else if(!count_usec_e)count_usec = 0;
        end
    end
    
    reg [5:0] state, next_state;
    always @(negedge clk or posedge reset_p)begin
        if(reset_p)state = IDLE;
        else state = next_state;
    end
    
    reg init_flag;
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            next_state = IDLE;
            send_buffer = 0;
            rs = 0;
            send_e = 0;
            init_flag = 0;
        end
        else begin
            case(state)
                IDLE:begin
                    if(init_flag)begin
                        if(btn_pedge[0])next_state = SEND;
                        else if(btn_pedge[1])next_state = MOVE_CURSOR;
                        else if(btn_pedge[2])next_state = SHIFT_DISPLAY;
                    end
                    else begin
                        if(count_usec <= 22'd80_000)begin
                            count_usec_e = 1;
                        end
                        else begin
                            next_state = INIT;
                            count_usec_e = 0;
                        end
                    end
                end
                INIT:begin
                    if(count_usec <= 22'd1000)begin
                        send_buffer = 8'h33;
                        send_e = 1;
                        count_usec_e = 1;
                    end
                    else if(count_usec <= 22'd1010)send_e = 0;
                    else if(count_usec <= 22'd2010)begin
                        send_buffer = 8'h32;
                        send_e = 1;
                        count_usec_e = 1;
                    end
                    else if(count_usec <= 22'd2020)send_e = 0;
                    else if(count_usec <= 22'd3020)begin
                        send_buffer = 8'h28;
                        send_e = 1;
                        count_usec_e = 1;
                    end
                    else if(count_usec <= 22'd3030)send_e = 0;
                    else if(count_usec <= 22'd4030)begin
                        send_buffer = 8'h0f;  //08
                        send_e = 1;
                        count_usec_e = 1;
                    end
                    else if(count_usec <= 22'd4040)send_e = 0;
                    else if(count_usec <= 22'd5040)begin
                        send_buffer = 8'h01;
                        send_e = 1;
                        count_usec_e = 1;
                    end
                    else if(count_usec <= 22'd5050)send_e = 0;
                    else if(count_usec <= 22'd6050)begin
                        send_buffer = 8'h06;
                        send_e = 1;
                        count_usec_e = 1;
                    end
                    else if(count_usec <= 22'd6060)send_e = 0;
                    else begin
                        next_state = IDLE;
                        init_flag = 1;
                        count_usec_e = 0;
                    end
                end
                SEND:begin
                    if(busy)begin
                        next_state = IDLE;
                        send_e = 0;
                        cnt_data = cnt_data + 1;
                    end
                    else begin
                        send_buffer = SAMPLE_DATA + cnt_data;
                        rs = 1;
                        send_e = 1;
                    end
                end
                MOVE_CURSOR: begin
                        if(busy)begin
                                next_state = IDLE;
                                send_e = 0;
                        end
                        else begin
                                send_buffer = 8'hc0;
                                rs = 0;
                                send_e = 1;
                        end
                end
                SHIFT_DISPLAY:begin
                        if(busy)begin
                                next_state = IDLE;
                                send_e = 0;
                        end
                        else begin
                                send_buffer = 8'h18;
                                rs = 0;
                                send_e = 1;
                        end
                end
            endcase
        end
    end
endmodule

module clock_timer(
    input clk, reset_p,
    input btn,
    output [3:0] com,
    output [7:0] seg_7,
    output reg led0_b,
    output reg sg90,
    output reg [2:0] led
);
   

    //타이머모드 4개 선언
    reg [3:0] timer_mode;
     
    //세팅시간, 현재시간

    wire [15:0] cur_time, set_time; 
    wire [3:0] cur_sec1, cur_sec10, cur_min1, cur_min10; 
    reg [3:0] set_sec1, set_sec10, set_min1, set_min10;

    wire load_enable,dec_clk;   //loadable_downcounter_dec_60
    wire btn_pedge,btn_nedge;        //버튼 p_edge, n_edge 생성
    wire [15:0] value;          //[임시] 7_seg 출력용 value

    //시작/정지(clk)

    wire clk_start;
    reg start_stop;
    reg time_out;

    assign clk_start = start_stop ? clk : 0;
    assign cur_time = {cur_min10, cur_min1, cur_sec10, cur_sec1};
    assign set_time = { set_min10, set_min1, set_sec10, set_sec1};
    assign value =  cur_time;
    
    clock_set clock(.clk(clk_start), .reset_p(reset_p),  .clk_usec(clk_usec), .clk_msec(clk_msec), .clk_sec(clk_sec));
    
    button_cntr btn_cntr(.clk(clk), .reset_p(reset_p), .btn(btn), .btn_pe(btn_pedge), .btn_ne(btn_nedge));

    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(start_stop), .p_edge(load_enable));
    edge_detector_n ed_timeout(.clk(clk), .reset_p(reset_p), .cp(time_out), .p_edge(timeout_pedge));
    
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_ca(seg_7), .com(com));
    
    loadable_downcounter_dec_60 cur_sec( .clk(clk), .reset_p(reset_p), .clk_time(clk_sec), .load_enable(load_enable), 
                                                            .set_value1(set_sec1), .set_value10(set_sec10), .dec1(cur_sec1), 
                                                                .dec10(cur_sec10), .dec_clk(dec_clk));
                                                                
    loadable_downcounter_dec_60 cur_min( .clk(clk), .reset_p(reset_p), .clk_time(dec_clk), .load_enable(load_enable), 
                                                            .set_value1(set_min1), .set_value10(set_min10), .dec1(cur_min1), 
                                                                .dec10(cur_min10)); 

    //전원버튼 시작/정지

    always @(posedge clk or posedge reset_p)begin
        if(reset_p) start_stop = 0;
        else begin
            if(btn_nedge)start_stop = 1;
            else if(btn_pedge) start_stop = 0;
            else if(timeout_pedge) start_stop = 0;
        end
    end

    //time_out (0h 0m 0s 정지)

    always @(posedge clk or posedge reset_p)begin
        if(reset_p) time_out = 0;
        else begin
            if(start_stop && clk_msec && cur_time == 0) time_out = 1;
            else time_out = 0;
        end
    end

    //타이머 동작

    always @(posedge clk or posedge reset_p)begin
        if(reset_p) timer_mode <= 4'b0001;
        else if(btn_pedge) timer_mode <= {timer_mode[2:0],timer_mode[3]};
        else if(time_out) begin
            timer_mode <= 4'b0001;
            //sg90 = 0;
        end
    end
    
    //타이머 모드(OFF/1H/3H/5H)

    always @(posedge clk)begin
        case (timer_mode)
            4'b0001:begin       //TIMER_OFF
                set_min1 = 0;
                led[0] = 0;
                led[1] = 0;
                led[2] = 0;
                led0_b = 1;
                sg90 = 0;
            end
            4'b0010:begin       //1H
                set_min1 = 1;
                led[0] = 1;
                led[1] = 0;
                led[2] = 0;
                led0_b = 0;
                sg90 = 1;
            end
            4'b0100:begin       //3H
                set_min1 = 3;
                led[0] = 0;
                led[1] = 1;
                led[2] = 0;
                led0_b = 0;
                sg90 = 1;
            end
            4'b1000:begin       //5H
                set_min1 = 5;
                led[0] = 0;
                led[1] = 0;
                led[2] = 1;
                led0_b = 0;
                sg90 = 1;
            end
        endcase
    end
endmodule



module top_module_WTJ_last(
    input clk, reset_p,
    input [3:0] btn,
    input echo_data,  //초음파echo
    output trig_data, //초음파trigger
    output [3:0] com_sr04, //초음파fnd
    output [7:0] seg_7_sr04, //초음파fnd
    output [3:0] led_bar_sr04, //초음파센서의 현재상태
    output motor_pwm,
    output led_brightness,
    output [3:0] com,
    output [7:0] seg_7,
    output led0_b,
    output s_motor_pwm,
    output [2:0] led_power_ctn,
    output [2:0] led_time_ctn);

    wire [3:0] btn_pedge;
    wire [11:0] distance;
    wire [15:0] value;
    wire [15:0] bcd_dis;
    wire timer_end;
    wire motor_idle;
    wire motor_off_ultrasonic;

    assign value = bcd_dis;

    // 버튼 입력 검출
    button_cntr btn0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
    button_cntr btn1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
    button_cntr btn2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));
    button_cntr btn3(.clk(clk), .reset_p(reset_p), .btn(btn[3]), .btn_pe(btn_pedge[3]));

    //seg_7
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_an(seg_7_sr04), .com(com_sr04));
    bin_to_dec dec(.bin({1'b0,distance}), .bcd(bcd_dis));

    // 바람 세기 제어 모듈
    project1_last wind_control(
        .clk(clk),
        .reset_p(reset_p),
        .btn(btn[0]),
        .timer_end(timer_end),
        .motor_off_ultrasonic(motor_off_ultrasonic),
        .motor_pwm(motor_pwm),
        .led_power(led_power_ctn),
        .motor_idle(motor_idle)
    );

    // 선풍기 조명 제어 모듈
    LED_light_real_last_JW  led_control(
        .clk(clk),
        .reset_p(reset_p),
        .btn(btn[1]),
        .brightness(led_brightness)
    );
    
    // 시간 예약 제어 모듈
    clock_timer_SJ_last timer_control(
        .clk(clk),
        .reset_p(reset_p),
        .motor_idle(motor_idle),
        .btn(btn[2]),
        .com(com),
        .seg_7(seg_7),
        .led0_b(led0_b),
        .led(led_time_ctn),
        .timer_end(timer_end)
    );

    //선풍기 회전/고정
    fan_rotation rotation(
    .clk(clk),
    .reset_p(reset_p),
    .btn(btn[3]),
    .motor_pwm(motor_pwm),
    .motor_idle(motor_idle),
    .timer_end(timer_end),
    .s_motor_pwm(s_motor_pwm)
    );

    //초음파 모듈
    hc_sr04_project hc_sr(
    .clk(clk), 
    .reset_p(reset_p), 
    .echo(echo_data), 
    .trigger(trig_data), 
    .distance(distance), 
    .led_bar(led_bar_sr04), 
    .motor_off_ultrasonic(motor_off_ultrasonic)
    );
    
endmodule