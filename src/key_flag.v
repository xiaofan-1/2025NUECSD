`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/02 06:40:24
// Design Name: 
// Module Name: key_ist
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


module key_flag(
    input                               clk                        ,
    input                               rst_n                      ,
    input                               key                        ,
  
    output reg                          key_flag                   ,
    output reg                          key_value                   
);
reg                    [  19:0]         cnt                        ;
reg                    [   1:0]         r_key                      ;
reg                    [   1:0]         state                      ;
always@(posedge clk)
     r_key <= {r_key[0],key};
     
wire                                    negedge_key                ;
     assign  negedge_key=r_key==2'b10;
wire                                    posedge_key                ;
     assign  posedge_key=r_key==2'b01;

always@(posedge clk or negedge rst_n)
    if(!rst_n)begin
        state<=0;
        key_flag<=0;
        cnt<=0;
        key_value<=1;
    end
    else
      begin case(state)
        0:
         begin
           key_flag<=0;
           key_value<=1;
          if(negedge_key)
               state<=1;
           else
               state<=0;
         end
        1:
          if((posedge_key)&&(cnt<20'd999999))
               state<=0;
          else if(cnt==20'd999999)begin
               state<=2;
               key_flag<=1;
               key_value<=0;
               cnt<=0;
          end
          else begin
               cnt<=cnt+1;
               state<=1;
          end
        2:
        begin
          key_flag<=0;
          key_value<=0;
          if(posedge_key)
               state<=3;
          else
               state<=2;
        end
        3:
          if((negedge_key)&&(cnt<20'd999999))
               state<=2;
          else if(cnt==20'd999999)begin
               state<=0;
               key_flag<=0;
               key_value<=1; 
               cnt<=0;
          end
          else begin
               cnt<=cnt+1;
               state<=3;
          end
      endcase
    end
endmodule
