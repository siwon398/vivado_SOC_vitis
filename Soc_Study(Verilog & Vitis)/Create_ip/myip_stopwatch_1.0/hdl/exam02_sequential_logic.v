`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/05 14:49:49
// Design Name: 
// Module Name: exam02_sequential_logic
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


module D_flip_flop_n(
        input d,
        input clk,
        input reset_p,
        output reg q
        
);
        always @(negedge clk or posedge reset_p) begin 
            if(reset_p) begin q = 0;  end
            else begin q = d;  end
        end    

endmodule

module D_flip_flop_p(
        input d,
        input clk,
        input reset_p,
        output reg q
        
);
        always @(posedge clk or posedge reset_p) begin 
            if(reset_p) begin q = 0;  end
            else begin q = d;  end
        end    

endmodule

module t_flip_flop_n(
        input clk, reset_p,
        input t,
        output reg q
);

        always @(negedge clk or posedge reset_p) begin
                if (reset_p) begin q = 0; end
                else begin
                        if(t) q = ~q;
                        else q = q;
                end
        end
endmodule

module t_flip_flop_p(
        input clk, reset_p,
        input t,
        output reg q
);

        always @(posedge clk or posedge reset_p) begin
                if (reset_p) begin q = 0; end
                else begin
                        if(t) q = ~q;
                        else q = q;
                end
        end
endmodule

module up_counter_asyc(
        input clk, reset_p,
        output [3:0] count
);
         t_flip_flop_n T0(.clk(clk), .reset_p(reset_p), .t(1), .q(count[0]));
         t_flip_flop_n T1(.clk(count[0]), .reset_p(reset_p), .t(1), .q(count[1]));
         t_flip_flop_n T2(.clk(count[1]), .reset_p(reset_p), .t(1), .q(count[2]));
         t_flip_flop_n T3(.clk(count[2]), .reset_p(reset_p), .t(1), .q(count[3]));
         
endmodule

module down_counter_asyc(
        input clk, reset_p,
        output [3:0] count
);
        t_flip_flop_p T0(.clk(clk), .reset_p(reset_p), .t(1), .q(count[0]));
         t_flip_flop_p T1(.clk(count[0]), .reset_p(reset_p), .t(1), .q(count[1]));
         t_flip_flop_p T2(.clk(count[1]), .reset_p(reset_p), .t(1), .q(count[2]));
         t_flip_flop_p T3(.clk(count[2]), .reset_p(reset_p), .t(1), .q(count[3]));
endmodule

module up_counter_p(
    input clk, reset_p,
    output reg [3:0] count
);
     
        always @(posedge clk, posedge reset_p)begin
                if(reset_p) count = 0;
                else count = count +1;
        end                
endmodule

module down_counter_n(
        input clk, reset_p,
        output reg [3:0] count
);
        always @(posedge clk, posedge reset_p)begin
                if(reset_p) count = 0;
                else count = count -1;
        end
endmodule

module down_counter_en(
        input clk, reset_p, enable,
        output reg [3:0] count
);
        always @(posedge clk, posedge reset_p)begin
                if(enable) count = count -1;
                else count = count;
        end
endmodule

module down_counter_Nbit_p #(parameter N = 16)(
        input clk, reset_p, enable,
        output reg [N-1:0] count
);
        always @(posedge clk, posedge reset_p)begin
            if(reset_p) count = 0;
            else begin
                    if(enable) count = count -1;
                    else count = count;
            end
       end
endmodule

module bcd_up_counter_p(
        input clk, reset_p,
        output reg [3:0] count
);
        always @(posedge clk,posedge reset_p)begin
                if(reset_p) count = 0;
                else begin
                        count = count +1;
                        if(count == 10) count = 0;
                end                        
        end
endmodule

module up_down_count(
        input clk, reset_p,
        input down_up, // 1일때 down 0일때 up 
        output reg [3:0] count
);
        always @(posedge clk, posedge reset_p)begin
                 if (reset_p) count = 0;
                 else begin
                        if(down_up) count = count - 1;
                        else count = count +1;
                 end 
        end          
endmodule

module bcd_up_down_counter_p(
        input clk, reset_p,
        input down_up,
        output reg [3:0] count
);
         always @(posedge clk, posedge reset_p)begin //edge 사용할 때는 조건문 좀 빼먹어도 상관없다.
             if (reset_p) count = 0;
                else begin
                        if(down_up)                                         // if(down_up) count = count -1;
                                if (count == 0) count = 9;            // else count = count +1; 
                                else count = count -1;                // if(count == 15) count = 0;
                        else
                                if (count == 9) count = 0;
                                else count = count + 1;       
                end
        end         
endmodule



module ring_counter(
        input clk, reset_p,
        output reg [3:0] q
);
        always @(posedge clk or posedge reset_p)begin
                if(reset_p) q = 4'b0001;
                else begin
                        if( q == 4'b0001) q = 4'b1000;
                        else if( q == 4'b1000) q = 4'b0100;
                        else if( q == 4'b0100) q = 4'b0010;
                        
                        else q = 4'b0001;
                            
                     /*  case(q)
                                4'b0001 : q = 4'b1000;
                                4'b1000 : q = 4'b0100;
                                4'b0100 : q = 4'b0010;
                                4'b0010 : q = 4'b0001;
                                default : q = 4'b0001;
                        endcase */
                end
        end
endmodule

module ring_counter_fnd(
        input clk, reset_p,
        output reg [3:0] com
);

        reg [16:0] clk_div; //  vivado가 알아서 최적화를 해준다.
        always @(posedge clk) clk_div = clk_div + 1;

        always @(posedge clk_div[16] or posedge reset_p)begin
                if(reset_p) com = 4'b1110;
                else begin
                       case(com)
                                4'b1110 : com = 4'b1101;
                                4'b1101 : com = 4'b1011;
                                4'b1011 : com = 4'b0111;
                                4'b0111 : com = 4'b1110;
                                default : com = 4'b1110;
                        endcase
                end
        end
endmodule

module ring_counter_led(
        input clk, reset_p, 
        output reg [15:0] q
);

         reg [31:0] clk_div =0;
         always @(posedge clk) clk_div = clk_div + 1;
         always @(posedge clk_div[22] or posedge reset_p)begin
        
                if(reset_p) q = 16'b0000_0000_0000_0001;
                else begin
                        case(q)
                               16'b0000_0000_0000_0001 : q = 16'b0000_0000_0000_0010;
                               16'b0000_0000_0000_0010 : q = 16'b0000_0000_0000_0100;
                               16'b0000_0000_0000_0100 : q = 16'b0000_0000_0000_1000;
                               16'b0000_0000_0000_1000 : q = 16'b0000_0000_0001_0000;
                               16'b0000_0000_0001_0000 : q = 16'b0000_0000_0010_0000;
                               16'b0000_0000_0010_0000 : q = 16'b0000_0000_0100_0000;
                               16'b0000_0000_0100_0000 : q = 16'b0000_0000_1000_0000;
                               16'b0000_0000_1000_0000 : q = 16'b0000_0001_0000_0000;
                               16'b0000_0001_0000_0000 : q = 16'b0000_0010_0000_0000;
                               16'b0000_0010_0000_0000 : q = 16'b0000_0100_0000_0000;
                               16'b0000_0100_0000_0000 : q = 16'b0000_1000_0000_0000;
                               16'b0000_1000_0000_0000 : q = 16'b0001_0000_0000_0000;
                               16'b0001_0000_0000_0000 : q = 16'b0010_0000_0000_0000;
                               16'b0010_0000_0000_0000 : q = 16'b0100_0000_0000_0000;
                               16'b0100_0000_0000_0000 : q = 16'b1000_0000_0000_0000;
                               16'b1000_0000_0000_0000 : q = 16'b0000_0000_0000_0001;
                               default : q = 16'b0000_0000_0000_0001;
                        endcase
                end
        end
endmodule


module ring_counter_led_hw(
        input clk, reset_p,
        output reg [15:0] count
);
        reg [20:0] clk_div;
        
        always @(posedge clk) clk_div = clk_div + 1;
        
        always @(posedge clk_div[20], posedge reset_p) begin
                if(reset_p) count = 16'b1;  //앞에 0은 생략이 가능하다 16'b0000_0000_0000_0001 = 16'b1
                else begin
                        if (count == 16'b1000_0000_0000_0000) count = 16'b1;
                        else count = {count[14:0], 1'b0};
                end                        
        end                        
endmodule

module ring_counter_led2(
        input clk, reset_p,
        output reg [15:0] count
);
        reg [20:0] clk_div;
        
        always @(posedge clk) clk_div = clk_div + 1;
        always @(posedge clk_div[20], posedge reset_p) begin
                if (reset_p) count = 16'b1;
                else begin  
                        count = {count[14:0], count[15]};
                end                        
        end          
endmodule

module edge_detector_n( //blocking | non_blocking
        input clk, reset_p,
        input cp,
        output p_edge, n_edge
);
        reg ff_cur, ff_old;
        
        always @(negedge clk or posedge reset_p)begin
                if (reset_p)begin
                        ff_cur <= 0;
                        ff_old <= 0;
                end
                else begin
                        ff_cur <= cp;
                        ff_old <= ff_cur;
                end      
        end
        
        assign p_edge = ({ff_cur, ff_old} == 2'b10) ? 1 : 0;
        assign n_edge = ({ff_cur, ff_old} == 2'b01) ? 1 : 0;
endmodule

module ring_counter_led3(
        input clk, reset_p,
        output reg [15:0] count
);
        reg [20:0] clk_div;
        wire posedge_clk_div_20;
        
        always @(posedge clk) clk_div = clk_div + 1;
         /*리셋을 하고싶으면 여기서 해야됨.
                if(reset_p) clk_div = 0;
                else clk_div = clk_div + 1;
         */
        always @(posedge clk, posedge reset_p) begin
                if (reset_p) begin
                        count = 15'b1;
             
                end                        
                else begin  
                      if (posedge_clk_div_20) count = {count[14:0], count[15]};
                end                        
        end          
        
        edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(clk_div[20]), .p_edge(posedge_clk_div_20));
endmodule







/*module button_seg_7_top(
    input clk, reset_p,
   input [1:0] btnU,
   output reg [7:0]seg_7);
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
   wire [7:0] seg_7_bar;
   decoder_7seg(.hex_value(count[1:0]), .seg_7(seg_7_bar));
   
   always @(posedge clk)begin
          seg_7 = ~seg_7_bar;
   end
endmodule*/



module button_cntr(
        input clk, reset_p,
        input btn,
        output btn_pe, btn_ne
);
        reg [16:0] clk_div;
        always @(posedge clk) clk_div = clk_div + 1;
        wire clk_div_16;
        reg [3:0] debounced_btn;
        edge_detector_n ed1(.clk(clk), .reset_p(reset_p), .cp(clk_div[16]), .p_edge(clk_div_16));
        always @(posedge clk, posedge reset_p) begin
                if(reset_p) debounced_btn = 0;
                else if (clk_div_16) debounced_btn = btn;
        end
        edge_detector_n ed2(.clk(clk), .reset_p(reset_p), .cp(debounced_btn), .p_edge(btn_pe), .n_edge(btn_ne));          //, .n_dege(btn_ne)
endmodule

module fnd_4digit_cntr(
        input clk, reset_p,
        input [15:0] value,
        output [7:0] seg_7_an, seg_7_ca,        //0일때 신호 an , 1일떄 신호 cn
        output [3:0] com
);
        reg [3:0] hex_value;
        ring_counter_fnd rc(.clk(clk), .reset_p(reset_p), .com(com));
        
        always @(posedge clk)begin
                case(com)
                        4'b0111: hex_value = value[15:12];
                        4'b1011: hex_value = value[11:8];
                        4'b1101: hex_value = value[7:4];
                        4'b1110: hex_value = value[3:0];  
                endcase
        end
        decoder_7seg fnd (.hex_value(hex_value), .seg_7(seg_7_an));
        assign seg_7_ca = ~seg_7_an;                       
endmodule



module shift_register_SISO_n(
        input clk, reset_p,
        input d,
        output q
);      
        reg [3:0] siso_reg;
        always @(negedge clk or posedge reset_p)begin
                if(reset_p) siso_reg = 0;
                else begin
                        siso_reg[3] <= d;
                        siso_reg[2] <= siso_reg[3];
                        siso_reg[1] <= siso_reg[2];
                        siso_reg[0] <= siso_reg[1];     //D-filp_flop 4개 생성
                end
        end
        assign  q = siso_reg[0];
endmodule

module shift_register_SIPO_n( //직렬 입력 병렬 출력 
        input clk, reset_p,
        input d,
        input rd_en,        //rd_en 출력이 1일때 값이 나오게 한다.
        output [3:0] q
);
        reg [3:0] sipo_reg;
        
        always @(negedge clk or posedge reset_p)begin
                if(reset_p)begin
                        sipo_reg = 0;
                end
                else begin
                        sipo_reg = {d, sipo_reg[3:1]};
                end
        end
        assign q = rd_en ? sipo_reg : 4'bz ; //4비트 다 z 
        /*bufif1 (q[0], sipo_reg[0], rd_en); // 출력 , 입력, 제어입력 순서가 정해져 있다.
        bufif1 (q[1], sipo_reg[1], rd_en);
        bufif1 (q[2], sipo_reg[2], rd_en);
        bufif1 (q[3], sipo_reg[3], rd_en);*/
endmodule

module shift_register_PISO(
        input clk, reset_p,
        input [3:0] d,
        input shift_load,                   //select 비트
        output q
);
        
        reg [3:0] piso_reg;
        
        always @(posedge clk or posedge reset_p)begin
                if(reset_p) piso_reg = 0;
                else begin
                        if(shift_load) piso_reg = {1'b0, piso_reg[3:1]};
                        else piso_reg = d;
                end
        end
        
        assign q = piso_reg[0];
endmodule

module register_p #(parameter N = 8)(
        input clk, reset_p,
        input [N-1:0] d,
        input wr_en, rd_en,     //write enable, read enable
        output[N-1:0] q
);
        reg [N-1:0] register;
        always @(posedge clk or posedge reset_p)begin
                if(reset_p) register = 0;
                else if(wr_en)register = d;
        end
        assign q = rd_en ? register : 'bz;
endmodule

module sram_8bit_1024( //메모리는 필요하면 덮어쓰면 되기 떄문에 리셋이 없다.
        input clk,
        input wr_en, rd_en,
        input [9:0] addr,       //주소
        inout [7:0] data            //input도 되고 ouput도 된다. 입력선 출력선 같이 씀 
);                                         //출력하지 않을 때는 반드시 enfidance로 끊어줘야한다.

        reg [7:0] mem [0:1023];     //8비트 메모리 1024개             [비트선언] 변수명 [배열]
        
        always @(posedge clk)begin
                if(wr_en) mem [addr] <= data;
        end
        
        assign data = rd_en ? mem[addr] : 'bz;
endmodule

