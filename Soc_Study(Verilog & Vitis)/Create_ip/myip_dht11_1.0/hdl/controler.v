`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/15 12:00:30
// Design Name: 
// Module Name: controler
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


module key_pad_cntr(
        input clk, reset_p,
        input [3:0] row,
        output reg [3:0] col,
        output reg [3:0] key_value,
        output reg key_valid
        );
       reg [19: 0 ] clk_div;
       always @(posedge clk) clk_div = clk_div +1;
       wire clk_8msec;
       edge_detector_n ed1(.clk(clk), .reset_p(reset_p), .cp(clk_div[19]), .p_edge(clk_8msec_p), .n_edge(clk_8msec_n));
       
       always @(posedge clk or posedge reset_p) begin
            if(reset_p) col = 4'b0001;
            else if(clk_8msec_p && !key_valid)begin
                    case(col)
                            4'b0001: col = 4'b0010;
                            4'b0010: col = 4'b0100;
                            4'b0100: col = 4'b1000;
                            4'b1000: col = 4'b0001;
                            default : col = 4'b0001;
                    endcase
            end 
        end
        
        always @(posedge clk, posedge reset_p)begin
                if(reset_p) begin
                        key_value = 0;
                        key_valid = 0;   //손 똈을떄 0으로 초기화  없으면 키 밸류값 그대로 유지   
                end
                else begin
                        if(clk_8msec_n)begin
                                if(row) begin
                                    key_valid = 1;  //키값이 1이면 증가 0이면 감소
                                    case({col,row})
                                           8'b0001_0001: key_value = 4'hA;  //0
                                           8'b0001_0010: key_value = 4'h9;  //1
                                           8'b0001_0100: key_value = 4'h8;  //2
                                           8'b0001_1000: key_value = 4'h7; //3
                                           8'b0010_0001: key_value = 4'hB;  //4
                                           8'b0010_0010: key_value = 4'h6;  //5
                                           8'b0010_0100: key_value = 4'h5;  //6
                                           8'b0010_1000: key_value = 4'h4;  //7
                                           8'b0100_0001: key_value = 4'hE;  //8
                                           8'b0100_0010: key_value = 4'h3;  //9
                                           8'b0100_0100: key_value = 4'h2;  //A
                                           8'b0100_1000: key_value = 4'h1;  //B
                                           8'b1000_0001: key_value = 4'hD;  //C
                                           8'b1000_0010: key_value = 4'hF;  //D
                                           8'b1000_0100: key_value = 4'h0;  //E
                                           8'b1000_1000: key_value = 4'hC;  //F
                                    endcase
                                end
                                else begin
                                        key_valid = 0;
                                        key_value = 0;
                                end
                        end
                end
         end
         
endmodule

module keypad_cntr_FSM(
        input clk, reset_p,
        input [3:0] row,
        output reg [3:0] col,
        output reg [3:0] key_value,
        output reg key_valid
);
        parameter SCAN_0 = 1;       //parameter은 상수 선언할때 사용. 값을 주는순간 변경할 수 없다.
        parameter SCAN_1 = 2;       //읽기 편하기 위해 적는다. 
        parameter SCAN_2 = 3;
        parameter SCAN_3 = 4;
        parameter KEY_PROCESS = 5;
        
        reg [2:0] state, next_state;
       always @* begin
            case(state)
                    SCAN_0: begin
                            if(row == 0) next_state = SCAN_1;
                            else next_state = KEY_PROCESS;                  
                    end
                    SCAN_1: begin
                            if(row == 0) next_state = SCAN_2;
                            else next_state = KEY_PROCESS;
                    end
                    SCAN_2: begin
                            if(row == 0) next_state = SCAN_3;
                            else next_state = KEY_PROCESS;
                    end
                    SCAN_3: begin
                            if(row == 0) next_state = SCAN_0;
                            else next_state = KEY_PROCESS;
                    end
                    KEY_PROCESS: begin
                            if(row != 0)next_state = KEY_PROCESS;
                            else next_state = SCAN_0;
                    end                            
            endcase
       end
       reg [19:0] clk_div;
       always @(posedge clk)clk_div = clk_div +1;
       wire clk_8msec;
       edge_detector_n ed1(.clk(clk), .reset_P(reset_p), .cp(clk_div[19]), .p_edge(clk_8msec));
       
       always @(posedge clk or posedge reset_p)begin
            if(reset_p)state = SCAN_0;
            else if(clk_8msec) state = next_state;
        end            
        
        always @(posedge clk or posedge reset_p)begin
                if(reset_p) begin
                        key_value = 0;
                        key_valid = 0;
                        col = 4'b0001;
                end
                else begin
                        case(state)
                                SCAN_0 : begin col = 4'b0001; key_valid = 0; end
                                SCAN_1 : begin col = 4'b0010; key_valid = 0; end
                                SCAN_2 : begin col = 4'b0100; key_valid = 0; end
                                SCAN_3 : begin col = 4'b1000; key_valid = 0; end
                                KEY_PROCESS : begin
                                        key_valid = 1;
                                        case({col, row})
                                                 8'b0001_0001: key_value = 4'hA;  //0
                                                 8'b0001_0010: key_value = 4'h9;  //1
                                                 8'b0001_0100: key_value = 4'h8;  //2
                                                 8'b0001_1000: key_value = 4'h7; //3
                                                 8'b0010_0001: key_value = 4'hB;  //4
                                                 8'b0010_0010: key_value = 4'h6;  //5
                                                 8'b0010_0100: key_value = 4'h5;  //6
                                                 8'b0010_1000: key_value = 4'h4;  //7
                                                 8'b0100_0001: key_value = 4'hE;  //8
                                                 8'b0100_0010: key_value = 4'h3;  //9
                                                 8'b0100_0100: key_value = 4'h2;  //A
                                                 8'b0100_1000: key_value = 4'h1;  //B
                                                 8'b1000_0001: key_value = 4'hD;  //C
                                                 8'b1000_0010: key_value = 4'hF;  //D
                                                 8'b1000_0100: key_value = 4'h0;  //E
                                                 8'b1000_1000: key_value = 4'hC;  //F
                                           endcase
                                    end
                            endcase 
                    end 
            end
endmodule

module dht11(
    input clk, reset_p,
    inout dht11_data, 
    output reg [7:0] humidity, temperature,
    output [7:0] led_bar);
    
    parameter S_IDLE = 6'b000001;
    parameter S_LOW_18MS = 6'b000010;
    parameter S_HIGH_20US = 6'b000100;
    parameter S_LOW_80US = 6'b001000;
    parameter S_HIGH_80US = 6'b010000;
    parameter S_READ_DATA = 6'b100000;
    
    parameter S_WAIT_PEDGE = 2'b01;
    parameter S_WAIT_NEDGE = 2'b10;
    
    reg [21:0] count_usec;
    wire clk_usec;
    reg count_usec_e;
    clock_usec usec_clk(clk, reset_p, clk_usec);
    
    
    
    always @(negedge clk or posedge reset_p)begin
        if(reset_p)  count_usec = 0;
        else begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1;
            else if(!count_usec_e) count_usec = 0;
        end
    end
    wire dht_pedge, dht_nedge;
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(dht11_data), .p_edge(dht_pedge), .n_edge(dht_nedge));
    
    reg [5:0] state, next_state;
    reg [1:0] read_state;
    
    assign led_bar[5:0] = state;
    
    always @(negedge clk or posedge reset_p)begin
        if(reset_p) state = S_IDLE;
        else state = next_state;
    end
    
    reg [39:0] temp_data;
    reg [5:0] data_count;
    
    reg dht11_buffer;
    assign dht11_data = dht11_buffer;
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            count_usec_e = 0;
            next_state = S_IDLE;
            dht11_buffer = 1'bz;
            read_state = S_WAIT_PEDGE;
            data_count = 0;
            
        end
        else begin
            case(state)
                S_IDLE:begin
                    if(count_usec < 22'd3_000_000)begin  //3_000_000
                        count_usec_e = 1;
                        dht11_buffer = 1'bz;
                    end
                    else begin
                        next_state = S_LOW_18MS;
                        count_usec_e = 0;
                    end
                end
                S_LOW_18MS:begin
                    if(count_usec < 22'd20_000)begin
                        count_usec_e =1;
                        dht11_buffer = 0;
                    end
                    else begin
                         count_usec_e = 0;
                         next_state = S_HIGH_20US;
                         dht11_buffer = 1'bz;
                    end
                end
                S_HIGH_20US:begin
                    count_usec_e = 1;
                    if(dht_nedge)begin
                        next_state = S_LOW_80US;
                        count_usec_e = 0;
                    end
                    if(count_usec > 22'd20_000)begin
                        next_state = S_IDLE;
                        count_usec_e = 0;
                    end
                end
                S_LOW_80US:begin
                    count_usec_e = 1;
                    if(dht_pedge)begin
                        next_state = S_HIGH_80US;
                        count_usec_e = 0;
                    end
                    if(count_usec > 22'd20_000)begin
                        next_state = S_IDLE;
                        count_usec_e = 0;
                    end
                end
                S_HIGH_80US:begin
                    count_usec_e = 1;
                    if(dht_nedge)begin
                        next_state = S_READ_DATA;
                        count_usec_e = 0;
                    end
                    if(count_usec > 22'd20_000)begin
                        next_state = S_IDLE;
                        count_usec_e = 0;
                    end
                    
                end
                S_READ_DATA:begin
                    case(read_state)
                        S_WAIT_PEDGE:begin
                            if(dht_pedge)begin
                                read_state = S_WAIT_NEDGE;
                            end
                            count_usec_e = 0;
                        end
                        S_WAIT_NEDGE:begin
                            if(dht_nedge)begin
                                if(count_usec < 45)begin
                                    temp_data = {temp_data[38:0], 1'b0};
                                end
                                else begin
                                    temp_data = {temp_data[38:0], 1'b1};
                                end
                                data_count = data_count + 1;
                                read_state = S_WAIT_PEDGE;
                            end
                            else begin
                                count_usec_e = 1;
                            end
                        end
                    endcase
                    if(data_count >= 40)begin
                        data_count = 0;
                        next_state = S_IDLE;
                        humidity = temp_data[39:32];
                        temperature = temp_data[23:16];
                    end
                    if(count_usec > 22'd50_000)begin
                        data_count = 0;
                        next_state = S_IDLE;
                        count_usec_e = 0;
                    end
                end
                default:next_state = S_IDLE;
            endcase
        end
    end
endmodule



/*
module ultrasonic(
    input clk, reset_p,
    input echo_data, // 에코 펄스 (100us ~ 18ms)
    output reg trig_data, // 트리거 펄스 (10us 최소)
    output reg [11:0] distance_value,
    output wire [2:0] led_bar);
    parameter S_IDLE = 3'b001;
    parameter S_Trigger = 3'b010;
    parameter S_Echo = 3'b100;
    reg [21:0] count_usec;
    wire clk_usec,clk_usec_pedge;
    reg count_usec_e;
    clock_usec usec_clk(clk, reset_p, clk_usec);
    always @(negedge clk or posedge reset_p)begin //clk, count
        if (reset_p) count_usec = 0;
        else begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1;
            else if (!count_usec_e) count_usec = 0;
         end
    end
    edge_detector_n clk_us( .clk(clk),  .reset_p(reset_p), .cp(clk_usec), .p_edge(clk_usec_pedge));
    wire echo_pedge, echo_nedge;
    edge_detector_n ed1( .clk(clk),  .reset_p(reset_p), .cp(echo_data), .p_edge(echo_pedge), .n_edge(echo_nedge));
    reg [2:0] state, next_state;
    reg [11:0] echo_time;
      wire cnt_e;
     wire [11:0] cm;
     sr04_div58 div58(clk, reset_p, clk_usec, cnt_e, cm);
     
    
    always @(negedge clk or posedge reset_p)begin                           //상태
        if (reset_p) state = S_IDLE;
        else state = next_state;
     end
    always @(posedge clk_usec or posedge reset_p)begin
        if (reset_p)begin
                count_usec_e = 0;
                next_state = S_IDLE;
                trig_data = 0;
       end
       else begin
            case (state)
                S_IDLE:begin
                       if(count_usec < 22'd500_000) begin     //0.5초마다 측정
                            count_usec_e = 1;
                            trig_data = 0;
                        end
                        else begin
                            next_state = S_Trigger;
                            count_usec_e = 0;
                        end
                end
                S_Trigger:begin
                       count_usec_e = 1;
                       if(count_usec < 22'd10)begin    //trigger 10us
                            trig_data = 1;   //trig HIGH
                        end
                        else begin
                            count_usec_e = 0;
                            trig_data = 0;
                            next_state = S_Echo;
                        end
                end
                 S_Echo:begin
                        if(echo_pedge)begin
                            count_usec_e = 1;
                            cnt_e = 1;
                         end
                         if(echo_nedge)begin
                                  //distance_value = count_usec / 58; //
                                  echo_time = count_usec;
                                  next_state = S_IDLE;
                              end
                        if(count_usec > 22'd40_000)begin
                              next_state = S_IDLE;
                              count_usec_e = 0;
                        end
                end
                default : next_state = S_IDLE;
             endcase
         end
     end
   

//     always @(posedge clk or posedge reset_p)begin
//        if(reset_p)distance = 0;
//        else begin
//                // distance = echo_time / 58;
//                if(echo_time < 58) distance = 0;
//                else if(echo_time < 116) distance = 1;
//                else if(echo_time < 174) distance = 2;
//                else if(echo_time < 232) distance = 3;
//                else if(echo_time < 290) distance = 4;
//                else if(echo_time < 348) distance = 5;
//                else if(echo_time < 406) distance = 6;
//                else if(echo_time < 464) distance = 7;
//                else if(echo_time < 522) distance = 8;
//                else if(echo_time < 580) distance = 9;
//                else if(echo_time < 638) distance = 10;
//                else if(echo_time < 696) distance = 11;
//                else if(echo_time < 754) distance = 12;
//                else if(echo_time < 812) distance = 13;
//                else if(echo_time < 870) distance = 14;
//                else if(echo_time < 928) distance = 15;
//                else if(echo_time < 986) distance = 16;
//                else if(echo_time < 1044) distance = 17;
//                else if(echo_time < 1102) distance = 18;
//                else if(echo_time < 1160) distance = 19;
//                else if(echo_time < 1218) distance = 20;
//                else if(echo_time < 1276) distance = 21;
//                else if(echo_time < 1334) distance = 22;
//                else if(echo_time < 1392) distance = 23;
//                else if(echo_time < 1450) distance = 24;
//                else if(echo_time < 1508) distance = 25;
//                else if(echo_time < 1566) distance = 26;
//                else if(echo_time < 1624) distance = 27;
//                else if(echo_time < 1682) distance = 28;
//                else if(echo_time < 1740) distance = 29;
//                else if(echo_time < 1798) distance = 30;
//        end
//    end
     assign led_bar [2:0] =  state; //{3'b000, state};
endmodule
*/
/*
module ultrasonic(
    input clk, reset_p,
    input echo,
    output reg trig,
    output reg [15:0] distance
);
    parameter S_IDLE = 3'b001;
    parameter S_Trigger = 3'b010;
    parameter S_Echo = 3'b100;

    reg [21:0] count_usec;
    wire clk_usec,clk_usec_pedge;
    reg count_usec_e;
    clock_usec usec_clk(clk, reset_p, clk_usec);

    always @(negedge clk or posedge reset_p)begin //clk, count
        if (reset_p) count_usec = 0;
        else begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1;
            else if (!count_usec_e) count_usec = 0;
         end
    end

    wire echo_pedge, echo_nedge;
    edge_detector_n clk_us( .clk(clk),  .reset_p(reset_p), .cp(clk_usec), .p_edge(clk_usec_pedge));
    edge_detector_n ed1( .clk(clk),  .reset_p(reset_p), .cp(echo), .p_edge(echo_pedge), .n_edge(echo_nedge));
    reg [2:0] state, next_state;
   
   always @(negedge clk or posedge reset_p)begin                           //상태
        if (reset_p) state = S_IDLE;
        else state = next_state;
     end
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            count_usec_e = 0;
            next_state = S_IDLE;
            trig = 0;
        end
        else begin
            case(state)
                S_IDLE:begin
                    if(count_usec < 22'd1000_000)begin
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = S_Trigger;
                        count_usec_e = 0;
                    end
                end

                S_Trigger:begin
                    count_usec_e = 1;
                    if(count_usec <= 22'd10)begin
                        
                        trig = 1;
                    end
                    else begin
                        count_usec_e = 0;
                        next_state = S_Echo;
                        trig = 0;
                    end
                end

                S_Echo:begin
                    if(echo_pedge)begin
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = S_IDLE;
                        distance = count_usec/58;
                        count_usec_e = 0;
                    end
                end

                default : next_state = S_IDLE;

            endcase
        end
    end
endmodule
*/

module ultrasonic(
    input clk, reset_p,
    input echo, 
    output reg trigger,
    output reg [11:0] distance,
    output [3:0] led_bar
);
    
    parameter S_IDLE    = 3'b001;
    parameter TRI_10US  = 3'b010;
    parameter ECHO_STATE= 3'b100;
    
    parameter S_WAIT_PEDGE = 2'b01;
    parameter S_WAIT_NEDGE = 2'b10;
    
    reg [21:0] count_usec;
    wire clk_usec;
    reg count_usec_e;
    
    clock_usec usec_clk(clk, reset_p, clk_usec);
    
    always @(negedge clk or posedge reset_p)begin
        if(reset_p) count_usec = 0;
        else begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1;
            else if(!count_usec_e) count_usec = 0;
        end
    end

    wire echo_pedge, echo_nedge;
    reg [3:0] state, next_state;
    reg [1:0] read_state;
    reg [11:0] echo_time;
    reg cnt_e;
    wire [11:0] cm;
    
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(echo), .p_edge(echo_pedge), .n_edge(echo_nedge));
    sr04_div58 div58(clk, reset_p, clk_usec, cnt_e, cm);
   
    assign led_bar[3:0] = state;

    always @(negedge clk or posedge reset_p)begin
        if(reset_p) state = S_IDLE;
        else state = next_state;
    end
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            count_usec_e = 0;
            next_state = S_IDLE;
            trigger = 0;
            read_state = S_WAIT_PEDGE;
        end
        else begin
            case(state)
                S_IDLE:begin
                    if(count_usec < 22'd100_000)begin 
                        count_usec_e = 1; 
                    end
                    else begin 
                        next_state = TRI_10US;
                        count_usec_e = 0; 
                    end
                end
                TRI_10US:begin 
                    if(count_usec <= 22'd10)begin 
                        count_usec_e = 1;
                        trigger = 1;
                    end
                    else begin
                        count_usec_e = 0;
                        trigger = 0;
                        next_state = ECHO_STATE;
                    end
                end
                ECHO_STATE:begin 
                    case(read_state)
                        S_WAIT_PEDGE:begin
                            count_usec_e = 0;
                            if(echo_pedge)begin
                                read_state = S_WAIT_NEDGE;
                                cnt_e = 1;
                            end
                        end
                        S_WAIT_NEDGE:begin
                            if(echo_nedge)begin       
                                read_state = S_WAIT_PEDGE;
                                count_usec_e = 0;                    
                                distance = cm;
                                cnt_e = 0;
                                next_state = S_IDLE;
                            end
                            else begin
                                count_usec_e = 1;
                            end
                        end
                    endcase
                end 
                default:next_state = S_IDLE;
            endcase
        end
    end

endmodule

module pwm_100pc(
    input clk, reset_p,
    input [6:0] duty,
    input [13:0] pwm_freq,
    output reg pwm_100pc
);

    parameter sys_clk_freq = 125_000_000;    //cora | basys는 100_000_000

    integer cnt;
    reg pwm_freqX100;
    reg [6:0] cnt_duty;
    wire pwm_freq_nedge;
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(pwm_freqX100), .n_edge(pwm_freq_nedge)); 
    always @(posedge clk or posedge reset_p)begin               //입력된 주파수를 가지는 pulse
        if(reset_p)begin
            pwm_freqX100 = 0;
            cnt = 0;
        end
        else begin
            if(cnt >= sys_clk_freq / pwm_freq / 2)begin
                cnt = 0;
                pwm_freqX100 = ~pwm_freqX100;
            end
            else cnt = cnt + 1;
        end
    end

    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            cnt_duty = 0;
            pwm_100pc = 0;
        end
        else begin
                if(pwm_freq_nedge)begin
                    if(cnt_duty >= 99) cnt_duty = 0;
                    else cnt_duty = cnt_duty + 1;

                    if(cnt_duty < duty)pwm_100pc = 1;
                    else pwm_100pc = 0;
                end
                else begin

                end
        end
    end
endmodule

module pwm_128step(
    input clk, reset_p,
    input [6:0] duty,
    input [13:0] pwm_freq,
    output reg pwm_128
);

    parameter sys_clk_freq = 125_000_000;    //cora | basys는 100_000_000

    integer cnt;
    reg pwm_freqX128;
    reg [6:0] cnt_duty;
    wire [26:0]temp;
    wire pwm_freqX128_nedge;
    assign temp = sys_clk_freq / pwm_freq;
    
//    always @(posedge clk or posedge reset_p)begin
//            if(reset_p)cnt_sysclk = 0;
//            else if(cnt_sysclk >= pwm_freq -1)begin
//                cnt_sysclk = 0;
//                temp = temp + 1;
//            end
//            else cnt_sysclk = cnt_sysclk + 1;
//    end
    
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(pwm_freqX128), .n_edge(pwm_freqX128_nedge)); 
    always @(posedge clk or posedge reset_p)begin               //입력된 주파수를 가지는 pulse
        if(reset_p)begin
            pwm_freqX128 = 0;
            cnt = 0;
        end
        else begin
            if(cnt >= temp[26:7]-1) cnt = 0;
            else cnt = cnt + 1;
            
            if(cnt < temp[26:8]) pwm_freqX128 = 0;
            else pwm_freqX128 = 1;
         end      
    end

    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            cnt_duty = 0;
            pwm_128 = 0;
        end
        else begin
                if(pwm_freqX128_nedge)begin
                    cnt_duty = cnt_duty + 1;    
                    if(cnt_duty < duty) pwm_128 = 1;
                    else pwm_128 = 0;
                end
                else begin

                end
        end
    end
endmodule

module pwm_servo(
    input clk, reset_p,
    input [7:0] duty,               //8bit
    input [13:0] pwm_freq,
    output reg pwm_signal
);

    parameter sys_clk_freq = 125_000_000;    //cora | basys는 100_000_000

    integer cnt;
    reg pwm_freqX256;       //8bit는 0~255
    reg [7:0] cnt_duty;     //duty랑 같은 bit
    wire [26:0]temp;
    
    assign temp = sys_clk_freq / pwm_freq;

    wire pwm_freq_nedge;
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(pwm_freqX256), .p_edge(pwm_freq_pedge), .n_edge(pwm_freq_nedge)); 
    always @(posedge clk or posedge reset_p)begin               //입력된 주파수를 가지는 pulse
        if(reset_p)begin
            pwm_freqX256 = 0;
            cnt = 0;
        end
        else begin
            if(cnt >= temp[26:8]-1) cnt = 0;
            else cnt = cnt + 1;
            
            if(cnt < temp[26:9]) pwm_freqX256 = 0;
            else pwm_freqX256 = 1;
         end      
    end

    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            cnt_duty = 0;
            pwm_signal = 0;
        end
        else begin
            if(pwm_freq_nedge)begin
                cnt_duty = cnt_duty + 1;
                if(cnt_duty < duty) pwm_signal = 1;
                else pwm_signal = 0;
            end
        end
    end
endmodule

module pwm_512step(
    input clk, reset_p,
    input [8:0] duty,
    input [13:0] pwm_freq,
    output reg pwm_512
);

    parameter sys_clk_freq = 125_000_000;    //cora | basys는 100_000_000

    integer cnt;
    reg pwm_freqX512;
    reg [8:0] cnt_duty;
    wire [26:0]temp;
    wire pwm_freqX512_nedge;
    assign temp = sys_clk_freq / pwm_freq;
    
    
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(pwm_freqX512), .n_edge(pwm_freqX512_nedge)); 
    always @(posedge clk or posedge reset_p)begin               //입력된 주파수를 가지는 pulse
        if(reset_p)begin
            pwm_freqX512 = 0;
            cnt = 0;
        end
        else begin
            if(cnt >= temp[26:9]-1) cnt = 0;
            else cnt = cnt + 1;
            
            if(cnt < temp[26:10]) pwm_freqX512 = 0;
            else pwm_freqX512 = 1;
         end      
    end

    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            cnt_duty = 0;
            pwm_512 = 0;
        end
        else begin
                if(pwm_freqX512_nedge)begin
                    cnt_duty = cnt_duty + 1;    
                    if(cnt_duty < duty) pwm_512 = 1;
                    else pwm_512 = 0;
                end
                else begin

                end
        end
    end
endmodule

module pwm512_period(
    input clk, reset_p,
    input [20:0] duty,
    input [20:0] pwm_period,
    output reg pwm_512
);  
    parameter sys_clk_freq = 125_000_000;    //cora | basys는 100_000_000
    reg [20:0] cnt_duty;

    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            cnt_duty = 0;
            pwm_512 = 0;
        end
        else begin
            if(cnt_duty >= pwm_period)cnt_duty = 0;
            else cnt_duty = cnt_duty + 1;

            if(cnt_duty < duty)pwm_512 = 1;
            else pwm_512 = 0;
        end
    end
endmodule

module I2C_master(
    input clk, reset_p,
    input rd_wr,
    input valid,
    input [6:0] addr,
    input [7:0] data,
    output reg sda,
    output reg scl
);

parameter IDLE =        7'b000_0001;
parameter COMM_START =  7'b000_0010;     
parameter SND_ADDR =    7'b000_0100;       //send address
parameter RD_ACK =      7'b000_1000;         
parameter SND_DATA =    7'b001_0000;       //send data
parameter SCL_STOP =    7'b010_0000;       
parameter COMM_STOP =   7'b100_0000;

wire [7:0] addr_rw;
wire clk_usec;
wire scl_nedge, scl_pedge;
wire valid_pedge;

reg [2:0] cnt_bit;
reg [2:0] count_usec5;
reg [6:0] state, next_state;
reg scl_toggle_e;
reg stop_data;

clock_usec usec_clk(clk,reset_p,clk_usec);

edge_detector_n ed_scl(.clk(clk), .reset_p(reset_p), .cp(scl), .n_edge(scl_nedge), .p_edge(scl_pedge));
edge_detector_n ed_valid(.clk(clk), .reset_p(reset_p), .cp(valid), .p_edge(valid_pedge));

assign addr_rw = {addr, rd_wr};

always @(posedge clk or posedge reset_p) begin
    if (reset_p) begin
        count_usec5 = 0;
        scl = 1;
    end
    else if(scl_toggle_e)begin
        if (clk_usec) begin
            if (count_usec5 >= 4) begin
                count_usec5 = 0;
                scl = ~scl;
            end
            else count_usec5 = count_usec5 + 1;
        end 
    end
    else if (scl_toggle_e == 0) count_usec5 = 0;
end

always @(negedge clk or posedge reset_p) begin
    if (reset_p) state = IDLE;
    else state = next_state;
end

always @(posedge clk or posedge reset_p) begin
    if (reset_p) begin
        sda = 1;
        next_state = IDLE;
        scl_toggle_e = 0;
        cnt_bit = 7;
        stop_data = 0;
    end
    else begin
        case (state)
            IDLE:begin
                if (valid_pedge) next_state = COMM_START;
            end 
            COMM_START:begin
                sda = 0;
                scl_toggle_e = 1;
                next_state = SND_ADDR;
            end
            SND_ADDR:begin
                if (scl_nedge) sda = addr_rw[cnt_bit];
                else if (scl_pedge) begin
                    if (cnt_bit == 0) begin
                        cnt_bit = 7;
                        next_state = RD_ACK;
                    end
                    else cnt_bit = cnt_bit - 1;
                end
            end
            RD_ACK:begin
                if (scl_nedge) sda = 'bz;
                else if (scl_pedge) begin
                    if (stop_data) begin
                        stop_data = 0;
                        next_state = SCL_STOP;
                    end
                    else begin
                        next_state = SND_DATA;
                    end 
                end 
            end
            SND_DATA:begin
                if (scl_nedge) sda = data[cnt_bit];
                else if (scl_pedge) begin
                    if (cnt_bit == 0) begin
                        cnt_bit = 7;
                        next_state = RD_ACK;
                        stop_data = 1;
                    end
                    else cnt_bit = cnt_bit - 1;
                end
            end
            SCL_STOP:begin
                if (scl_nedge) begin
                    sda = 0;
                end
                else if (scl_pedge) begin
                    
                    next_state = COMM_STOP;
                end
            end
            COMM_STOP:begin
                if(count_usec5 >= 3)begin
                    sda = 1;
                    scl_toggle_e = 0;
                    next_state = IDLE;
                end
            end
        endcase
    end
end

endmodule

module i2c_lcd_send_byte(
    input clk, reset_p,
    input [6:0] addr,
    input [7:0] send_buffer,
    input send, rs,
    output scl, sda,
    output reg busy
);
    parameter IDLE = 6'b00_0001;
    parameter SEND_HIGH_NIBBLE_DISABLE   = 6'b00_0010;
    parameter SEND_HIGH_NIBBLE_ENABLE    = 6'b00_0100;
    parameter SEND_LOW_NIBBLE_DISABLE    = 6'b00_1000;
    parameter SEND_LOW_NIBBLE_ENABLE     = 6'b01_0000;
    parameter SEND_DISABLE               = 6'b10_0000;

    wire clk_usec;
    wire send_pedge;

    reg [21:0] count_usec;
    reg [5:0] state, next_state;
    reg [7:0] data;
    reg count_usec_e;
    reg valid;

    clock_usec usec_clk(clk,reset_p,clk_usec);

    I2C_master master(.clk(clk), .reset_p(reset_p), .rd_wr(0), .valid(valid), .addr(7'h27), .data(data), .sda(sda), .scl(scl));

    edge_detector_n ed_send(.clk(clk), .reset_p(reset_p), .cp(send), .p_edge(send_pedge));

    always @(negedge clk or posedge reset_p) begin
        if (reset_p) begin
            count_usec = 0;
        end
        else begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1;
            else if (!count_usec_e) count_usec = 0;
        end
    end

    always @(negedge clk or posedge reset_p) begin
        if (reset_p) state = IDLE;
        else state = next_state;
    end

    always @(posedge clk or posedge reset_p)begin
        if (reset_p) begin
            next_state = IDLE;
        end
        else begin
            case (state)
                IDLE:begin
                    if (send_pedge) begin
                        next_state = SEND_HIGH_NIBBLE_DISABLE;
                        busy = 1;
                    end
                end
                SEND_HIGH_NIBBLE_DISABLE:begin
                    if (count_usec <= 22'd200) begin
                        data = {send_buffer[7:4], 3'b100, rs};   //[d7 d6 d5 d4], [BT EN RW] RS      BT = backlight
                        valid = 1;
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = SEND_HIGH_NIBBLE_ENABLE;
                        count_usec_e = 0;
                        valid = 0;
                    end
                end
                SEND_HIGH_NIBBLE_ENABLE:begin
                    if (count_usec <= 22'd200) begin
                        data = {send_buffer[7:4], 3'b110, rs};   //[d7 d6 d5 d4], [BT EN RW] RS      BT = backlight
                        valid = 1;
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = SEND_LOW_NIBBLE_DISABLE;
                        count_usec_e = 0;
                        valid = 0;
                    end
                end
                SEND_LOW_NIBBLE_DISABLE:begin
                    if (count_usec <= 22'd200) begin
                        data = {send_buffer[3:0], 3'b100, rs};   //[d7 d6 d5 d4], [BT EN RW] RS      BT = backlight
                        valid = 1;
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = SEND_LOW_NIBBLE_ENABLE;
                        count_usec_e = 0;
                        valid = 0;
                    end
                end
                SEND_LOW_NIBBLE_ENABLE:begin
                    if (count_usec <= 22'd200) begin
                        data = {send_buffer[3:0], 3'b110, rs};   //[d7 d6 d5 d4], [BT EN RW] RS      BT = backlight
                        valid = 1;
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = SEND_DISABLE;
                        count_usec_e = 0;
                        valid = 0;
                    end
                end
                SEND_DISABLE:begin
                    if (count_usec <= 22'd200) begin
                        data = {send_buffer[3:0], 3'b100, rs};   //[d7 d6 d5 d4], [BT EN RW] RS      BT = backlight
                        valid = 1;
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = IDLE;
                        count_usec_e = 0;
                        valid = 0;
                        busy = 0;
                    end
                end
            endcase
        end
    end
endmodule

module pwm_100pc_project(
    input clk, reset_p,
    input [6:0] duty,
    input [13:0] pwm_freq,
    output reg pwm_100pc);
    
    parameter sys_clk_freq = 125_000_000; //100MHz / cora?? 125MHz
    
    reg [26:0] cnt;      //?? 134_000_000
//    reg pwm_clk;
    reg pwm_freqX100;  //10000 x 100
        
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            pwm_freqX100 = 0;
            cnt = 0;
        end
        else begin
            if(cnt >= sys_clk_freq / pwm_freq/100 - 1)   cnt = 0;
            else cnt = cnt+1;
     
            //if pwm_freqX100 = ~pwm_freqX100;
            if (cnt < sys_clk_freq / pwm_freq /100 / 2)  pwm_freqX100 = 0;
            else pwm_freqX100 = 1;
        end
    end
    
    wire pwm_freqX100_nedge;
    edge_detector_n pwm_freq100_ed(.clk(clk), .reset_p(reset_p), .cp(pwm_freqX100), .n_edge(pwm_freqX100_nedge));
    
    reg [6:0] cnt_duty; //100??% ????? ????
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) begin
            cnt_duty = 0;
            pwm_100pc = 0;
        end
        else begin
            if(pwm_freqX100_nedge)begin
                if(cnt_duty >99) cnt_duty = 0;
                else cnt_duty = cnt_duty + 1;
                if(cnt_duty<duty) pwm_100pc = 1;
                else pwm_100pc = 0; 
            end
            else begin
            
            end
        end
    end 
endmodule

    module project1_last(
        input clk, reset_p,
        input btn,
        input timer_end,
        input motor_off_ultrasonic,
        output motor_pwm,
        output reg [2:0] led_power,
        output reg motor_idle
    );
        parameter IDLE = 2'b00;
        parameter POWER_LOW = 2'b01;
        parameter POWER_MID = 2'b10;
        parameter POWER_HIGH = 2'b11;
    
        reg [6:0] duty; //0~127 
        reg [1:0] state; //현재상태 
        
        wire [2:0] btn_pedge;
        button_cntr btn0(.clk(clk), .reset_p(reset_p), .btn(btn), .btn_pe(btn_pedge[0]));
    
        pwm_100pc_project pwm_moter1(.clk(clk), .reset_p(reset_p), .duty(duty), .pwm_freq(50), .pwm_100pc(motor_pwm));
    
        always @(posedge clk or posedge reset_p) begin
            if (reset_p) begin
                state <= IDLE;
                duty <= 0;
                led_power <= 3'b000;
                motor_idle <= 0;
            end
            else if (timer_end||motor_off_ultrasonic) begin
                state <= IDLE;
                duty <= 0;
                led_power <= 3'b000;
            end 
    //        else if (motor_off_ultrasonic) begin
    //            state <= IDLE;
    //            duty <= 0;
    //            led_power <= 3'b000;
    //        end
            else begin
                case(state)
                    IDLE: begin // 0
                        if (btn_pedge) begin
                            state = POWER_LOW; //  duty=10
                            duty = 10;
                            led_power = 3'b001; // led_power[1]
                            motor_idle<=0;
                        end
                    end
                    POWER_LOW: begin //  10
                        if (btn_pedge) begin
                            state = POWER_MID; // duty=20
                            duty = 20;         //10%
                            led_power = 3'b010; // led_power[2]
                        end
                    end
                    POWER_MID: begin //  20
                        if (btn_pedge) begin
                            state = POWER_HIGH; //  duty=30
                            duty = 30;          //20% 
                            led_power = 3'b100; // led_power[3]
                        end
                    end
                    POWER_HIGH: begin //  30
                        if (btn_pedge) begin
                            state = IDLE; //  0
                            duty = 0;           //30%
                            led_power = 3'b000; // led_power[0]
                            motor_idle<=1;
                        end
                    end
                    default: state = IDLE; // default 
                endcase
            end
        end
    endmodule

module clock_timer_SJ_last(
    input clk, reset_p,
    input btn,
    input motor_idle,
    output [3:0] com,
    output [7:0] seg_7,
    output reg led0_b,
    output reg [2:0] led,
    output reg timer_end
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
    assign set_time = {set_min10, set_min1, set_sec10, set_sec1};
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
   
    //전원버튼 입력/정지 ([임시] 0번버튼)
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) start_stop = 0;
        else begin
            if(btn_nedge)start_stop = 1;
            else if(btn_pedge) start_stop = 0;
            else if(timeout_pedge) start_stop = 0;
            else if(timer_mode == 4'b0001)start_stop = 0;
    
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
        else if(time_out) timer_mode <= 4'b0001;
        else if (motor_idle) timer_mode =4'b0001;
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
            end
            4'b0010:begin       //1H
                set_min1 = 1;
                led[0] = 1;
                led[1] = 0;
                led[2] = 0;
                led0_b = 0;
            end
            4'b0100:begin       //3H
                set_min1 = 3;
                led[0] = 0;
                led[1] = 1;
                led[2] = 0;
                led0_b = 0;
            end
            4'b1000:begin       //5H
                set_min1 = 5;
                led[0] = 0;
                led[1] = 0;
                led[2] = 1;
                led0_b = 0;
            end
        endcase
    end
    always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            timer_end <= 0;
        end
        else if (time_out) begin
            timer_end <= 1;
        end
        else begin
            timer_end <= 0;
        end
    end
endmodule

module LED_light_real_last_JW(
    input clk,
    input reset_p,
    input btn,
    output reg brightness
);

reg [1:0] state;
wire btn_pedge;

button_cntr btn_bright(
    .clk(clk),
    .reset_p(reset_p),
    .btn(btn),
    .btn_pe(btn_pedge)
);

reg [6:0] duty_cycle;
reg [13:0] pwm_freq;
wire pwm_out;

pwm_128step_last pwm_led(
    .clk(clk),
    .reset_p(reset_p),
    .duty(duty_cycle),
    .pwm_freq(pwm_freq),
    .pwm_128(pwm_out)
);

parameter BRIGHT_OFF    = 2'b00,
          BRIGHT_LOW    = 2'b01,
          BRIGHT_MID    = 2'b10,
          BRIGHT_HIGH   = 2'b11;

always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            state <= BRIGHT_OFF;
            duty_cycle <= 7'd0;
            pwm_freq <= 14'd10; // 1kHz (2^10)
        end else if (btn_pedge) begin
            case (state)
                BRIGHT_OFF: begin
                    state <= BRIGHT_LOW;
                    duty_cycle <= 7'd25;
                    pwm_freq <= 14'd10; // 1kHz (2^10)
                end
                BRIGHT_LOW: begin
                    state <= BRIGHT_MID;
                    duty_cycle <= 7'd50;
                    pwm_freq <= 14'd12; // 4kHz (2^12)
                end
                BRIGHT_MID: begin
                    state <= BRIGHT_HIGH;
                    duty_cycle <= 7'd75;
                    pwm_freq <= 14'd13; // 8kHz (2^13)
                end
                BRIGHT_HIGH: begin
                    state <= BRIGHT_OFF;
                    duty_cycle <= 7'd0;
                    pwm_freq <= 14'd10; // 1kHz (2^10)
                end
            endcase
        end
    end

always @(posedge clk or posedge reset_p) begin
    if (reset_p) begin
        brightness <= 1'b0;
    end else begin
        brightness <= pwm_out;
    end
end

endmodule

module pwm_128step_last(
    input clk, reset_p,
    input [6:0] duty,
    input [13:0] pwm_freq,
    output reg pwm_128);
    
    parameter sys_clk_freq = 125000000; //cora : 125_000_000
    
    reg [26:0] cnt = 0;
    reg pwm_freqX128;
    wire [26:0] temp;

    assign temp = sys_clk_freq >> pwm_freq;
   
    
    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            pwm_freqX128 = 0;
            cnt = 0;
        end
        else begin
            if(cnt >= temp[26:8]  - 1)  cnt = 0;
            else cnt =  cnt + 1;
            
            if(cnt < temp[26:9]) pwm_freqX128 = 0;
            else pwm_freqX128 = 1;
        end
    end    
    
    wire pwm_freqX128_nedge;
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(pwm_freqX128),
            .n_edge(pwm_freqX128_nedge));
    
    reg [6:0] cnt_duty;
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            cnt_duty = 0;
            pwm_128 = 0;         
        end
        else begin
            if(pwm_freqX128_nedge) begin
                cnt_duty = cnt_duty + 1;
                
                if(cnt_duty < duty) pwm_128 = 1;
                else pwm_128 = 0;
            end
            else begin
            
            end
        end
    end   
endmodule

module fan_rotation(
    input clk, reset_p,
    input btn,
    input motor_pwm,
    input motor_idle,
    input timer_end,
    output s_motor_pwm
);
    //clk_div 
    wire clk_div_pedge;
    reg [31:0] clk_div;
       
    wire btn_pedge;
    wire clk_start;

    reg [21:0] duty;
    reg start_stop;
    reg up_down;

    edge_detector_n ed_time(.clk(clk_start), .reset_p(reset_p), .cp(clk_div[17]), .p_edge(clk_div_pedge));

    
    button_cntr btn_cntr(.clk(clk), .reset_p(reset_p), .btn(btn), .btn_pe(btn_pedge));

    pwm512_period pwm_ser(.clk(clk), .reset_p(reset_p), .duty(duty), 
                                          .pwm_period(3_000_000), .pwm_512(s_motor_pwm));
        
    assign clk_start = start_stop ? clk : 0;

    //clk_div
    always @(posedge clk) clk_div = clk_div + 1;
    
    //회전버튼  회전/고정
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) start_stop = 0;
        else if(btn_pedge && motor_pwm) begin
            start_stop = ~start_stop;
        end
       else if(start_stop && motor_idle)begin
            start_stop = 0;
        end
        else if(start_stop && timer_end) begin
            start_stop = 0;
        end
    end
    always @(posedge clk)begin      //58000~326000  0~180
        if(clk_div_pedge)begin
            if(duty >= 328_000) up_down = 0;            
            else if(duty <= 126_000)up_down = 1;
                                
            if(up_down)duty = duty + 100;
            else duty = duty - 100;
        end
    end    
endmodule

module hc_sr04_project(
    input clk, reset_p,
    input echo, 
    output reg trigger,
    output reg [11:0] distance,
    output [3:0] led_bar,
    output reg motor_off_ultrasonic,
    output reg buzz
);
    
    parameter S_IDLE    = 3'b001;
    parameter TRI_10US  = 3'b010;
    parameter ECHO_STATE= 3'b100;
    
    parameter S_WAIT_PEDGE = 2'b01;
    parameter S_WAIT_NEDGE = 2'b10;
    
    wire clk_usec;
    reg [21:0] count_usec;
    reg count_usec_e;
    
    wire [11:0] cm;
    wire echo_pedge, echo_nedge;
    reg [3:0] state, next_state;
    reg [1:0] read_state;
    reg [11:0] echo_time;
    reg cnt_e;

    clock_usec usec_clk(clk, reset_p, clk_usec);

    sr04_div58 div58(clk, reset_p, clk_usec, cnt_e, cm);
    
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(echo), .p_edge(echo_pedge), .n_edge(echo_nedge));

    assign led_bar[3:0] = state;

    always @(negedge clk or posedge reset_p)begin
        if(reset_p) count_usec = 0;
        else begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1;
            else if(!count_usec_e) count_usec = 0;
        end
    end

    always @(negedge clk or posedge reset_p)begin
        if(reset_p) state = S_IDLE;
        else state = next_state;
    end
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            count_usec_e = 0;
            next_state = S_IDLE;
            trigger = 0;
            read_state = S_WAIT_PEDGE;
        end
        else begin
            case(state)
                S_IDLE:begin
                    if(count_usec < 22'd100_000)begin 
                        count_usec_e = 1; 
                    end
                    else begin 
                        next_state = TRI_10US;
                        count_usec_e = 0; 
                    end
                end
                TRI_10US:begin 
                    if(count_usec <= 22'd10)begin 
                        count_usec_e = 1;
                        trigger = 1;
                    end
                    else begin
                        count_usec_e = 0;
                        trigger = 0;
                        next_state = ECHO_STATE;
                    end
                end
                ECHO_STATE:begin 
                    case(read_state)
                        S_WAIT_PEDGE:begin
                            count_usec_e = 0;
                            if(echo_pedge)begin
                                read_state = S_WAIT_NEDGE;
                                cnt_e = 1;
                            end
                        end
                        S_WAIT_NEDGE:begin
                            if(echo_nedge)begin       
                                read_state = S_WAIT_PEDGE;
                                count_usec_e = 0;                    
                                distance = cm;
                                cnt_e = 0;
                                next_state = S_IDLE;
                            end
                            else begin
                                count_usec_e = 1;
                            end
                        end
                    endcase
                end
                default:next_state = S_IDLE;
            endcase
        end
    end
    
    always @(*) begin
        if(reset_p) begin
            motor_off_ultrasonic=0;
        end
        else begin
            if (distance >= 80) // 거리가 80cm 이상일 경우 (사람이 앞에 없는 경우)
                motor_off_ultrasonic = 1; // 모터를 끕니다.
            else if (distance <= 7) // 거리가 7cm 이하일 경우 (너무 가까워 위험한 경우)
                motor_off_ultrasonic = 1; // 모터를 끕니다.
            else // 그 외의 경우
                motor_off_ultrasonic = 0; // 모터를 켭니다.
        end
    end
endmodule
