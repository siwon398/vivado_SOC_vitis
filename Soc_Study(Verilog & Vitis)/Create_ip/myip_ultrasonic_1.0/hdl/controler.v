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
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(echo), .p_edge(echo_pedge), .n_edge(echo_nedge));

    reg [3:0] state, next_state;
    reg [1:0] read_state;
    
    reg cnt_e;
    wire [11:0] cm;
    sr04_div58 div58(clk, reset_p, clk_usec, cnt_e, cm);
    
    assign led_bar[3:0] = state;

    always @(negedge clk or posedge reset_p)begin
        if(reset_p) state = S_IDLE;
        else state = next_state;
    end
    
    reg [11:0] echo_time;
    
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
    
    
//    always @(posedge clk or posedge reset_p)begin
//        if(reset_p)distance = 0;
//        else begin
            
        
//            distance = echo_time / 58;
//            if(echo_time < 58) distance = 0;
//            else if(echo_time < 116) distance = 1;
//            else if(echo_time < 174) distance = 2;
//            else if(echo_time < 232) distance = 3;
//            else if(echo_time < 290) distance = 4;
//            else if(echo_time < 348) distance = 5;
//            else if(echo_time < 406) distance = 6;
//            else if(echo_time < 464) distance = 7;
//            else if(echo_time < 522) distance = 8;
//            else if(echo_time < 580) distance = 9;
//            else if(echo_time < 638) distance = 10;
//            else if(echo_time < 696) distance = 11;
//            else if(echo_time < 754) distance = 12;
//            else if(echo_time < 812) distance = 13;
//            else if(echo_time < 870) distance = 14;
//            else if(echo_time < 928) distance = 15;
//            else if(echo_time < 986) distance = 16;
//            else if(echo_time < 1044) distance = 17;
//            else if(echo_time < 1102) distance = 18;
//            else if(echo_time < 1160) distance = 19;
//            else if(echo_time < 1218) distance = 20;
//            else if(echo_time < 1276) distance = 21;
//            else if(echo_time < 1334) distance = 22;
//            else if(echo_time < 1392) distance = 23;
//            else if(echo_time < 1450) distance = 24;
//            else if(echo_time < 1508) distance = 25;
//            else if(echo_time < 1566) distance = 26;
//            else if(echo_time < 1624) distance = 27;
//            else if(echo_time < 1682) distance = 28;
//            else if(echo_time < 1740) distance = 29;
//            else if(echo_time < 1798) distance = 30;
            
//        end
//    end

endmodule

