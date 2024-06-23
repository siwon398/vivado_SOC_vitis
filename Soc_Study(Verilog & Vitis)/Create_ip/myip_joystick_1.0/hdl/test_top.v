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

module joystick(
        input clk, reset_p,
        input vauxp6, vauxn6,
        input vauxp15, vauxn15,
        output reg [11:0] value_x, value_y
);

        wire [4:0] channel_out;
        wire [15:0] do_out;
        wire eoc_out, eoc_out_pedge;
      
        
        adc_ch6_ch15 adc_joystick
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
          
            always @(posedge clk or posedge reset_p)begin
                    if(reset_p)begin
                            value_x = 0;
                            value_y = 0;   
                    end        
                    else if (eoc_out_pedge)begin
                            case(channel_out[3:0])
                                    6: value_y =  {do_out[15:9]}; //2 4 8 16 32 64 최대 127까지 
                                    15 : value_x =  {do_out[15:9]}; //
                            endcase
                    end
            end         
endmodule