`timescale 1ns / 1ps

module char_display#(
    parameter        HREF  =640            ,
    parameter        VSYNC =480
    
)(
    input                            clk      ,
    input                            rst_n    ,
    //行场信号
     input                            hsycn_i         ,//行同步
     input                            vsync_i         ,//场同步
     input                            de_i            ,//图像有效信号
     input            [23:0]          data_i          ,//数据
    //字符索引
    input      [7:0]                   char_0             ,
    input      [7:0]                   char_1             ,
    //输出
     output  reg                       hsycn_o         ,//行同步
     output  reg                       vsync_o         ,//场同步
     output  reg                       de_o            ,//图像有效信号
     output            [23:0]          data_o 
    );
localparam BLACK  = 16'b00000_000000_00000;     //RGB565 黑色
localparam WHITE  = 16'b11111_111111_11111;     //RGB565 白色
localparam BACK_GROUND = 16'b11111_000000_00000;     //背景色，此处用红色代替，实际上不显示

//字符位置
localparam CHINA_POS_X  = 11'd50;   //汉字区域起始点横坐标
localparam CHAR_POS_Y   = 11'd100;  //数字区域起始点纵坐标

localparam CHAR_WIDTH   = 11'd16;   //字符区域宽度
localparam CHAR_HEIGHT  = 11'd32;   //字符区域高度
reg  [511:0] char_num [33:0] ;  //字模
reg  [511:0] chinese  [10:0] ; 
reg  [10:0]  x_cnt           ; //行坐标   
reg  [9:0]   y_cnt           ; //场坐标
reg  [23:0]  gui_data        ;
reg          flag            ;

always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		x_cnt <= 10'd0;
		y_cnt <= 10'd0;
	end
	else if(!vsync_i)begin
		x_cnt <= 10'd0;
		y_cnt <= 10'd0;
	end
	else if(de_i ) begin
		if(x_cnt < HREF - 1) begin
			x_cnt <= x_cnt + 1'b1;
			y_cnt <= y_cnt; 
		end
		else begin
			x_cnt <= 10'd0;
			y_cnt <= y_cnt + 1'b1;
		end
	end
	else begin
	      x_cnt <= x_cnt  ;
	      y_cnt <= y_cnt  ;
	end
end

wire          flag_zifu ;//拉高表示绿色，不再显示倒计时

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)  begin
        gui_data   <= data_i ;
    end
	else if((x_cnt >= CHINA_POS_X) && (x_cnt < CHINA_POS_X + CHAR_WIDTH*1) && (y_cnt >= CHAR_POS_Y) && (y_cnt < CHAR_POS_Y + CHAR_HEIGHT)) begin
		if(char_num [char_0] [ (CHAR_HEIGHT+CHAR_POS_Y - y_cnt)*CHAR_WIDTH - ((x_cnt-CHINA_POS_X)%CHAR_WIDTH) - 1 ] )
			gui_data <= WHITE;         
		else
			gui_data <= data_i;         
	end
    else 
        gui_data <= data_i;
end
always @ ( posedge clk  )begin//打一个拍
    vsync_o   <=  vsync_i    ;
    hsycn_o   <=  hsycn_i    ;
    de_o      <=  de_i       ;
end
assign  data_o = gui_data ;

    //字符模板
always @(posedge clk) begin 
    char_num[0] <= 512'h00000000000000000000000003C006200C30181818181808300C300C300C300C300C300C300C300C300C300C1808181818180C30062003C00000000000000000;/*"0",0*/
    char_num[1] <= 512'h000000000000000000000000008001801F800180018001800180018001800180018001800180018001800180018001800180018003C01FF80000000000000000;/*"1",1*/
    char_num[2] <= 512'h00000000000000000000000007E008381018200C200C300C300C000C001800180030006000C0018003000200040408041004200C3FF83FF80000000000000000;/*"2",2*/
    char_num[3] <= 512'h00000000000000000000000007C018603030301830183018001800180030006003C0007000180008000C000C300C300C30083018183007C00000000000000000;/*"3",3*/
    char_num[4] <= 512'h0000000000000000000000000060006000E000E0016001600260046004600860086010603060206040607FFC0060006000600060006003FC0000000000000000;/*"4",4*/
    char_num[5] <= 512'h0000000000000000000000000FFC0FFC10001000100010001000100013E0143018181008000C000C000C000C300C300C20182018183007C00000000000000000;/*"5",5*/
    char_num[6] <= 512'h00000000000000000000000001E006180C180818180010001000300033E0363038183808300C300C300C300C300C180C18080C180E3003E00000000000000000;/*"6",6*/
    char_num[7] <= 512'h0000000000000000000000001FFC1FFC100830102010202000200040004000400080008001000100010001000300030003000300030003000000000000000000;/*"7",7*/
    char_num[8] <= 512'h00000000000000000000000007E00C301818300C300C300C380C38081E180F2007C018F030783038601C600C600C600C600C3018183007C00000000000000000;/*"8",8*/
    char_num[9] <= 512'h00000000000000000000000007C01820301030186008600C600C600C600C600C701C302C186C0F8C000C0018001800103030306030C00F800000000000000000;/*"9",9*/
    char_num[10] <= 512'h000000000000200030003000600061FF41FFC41886188C18F818F8181018301820186018C618FE18F8188018001806183E18FBFFC3FF00000000000000000000;/*"红",红*/
    char_num[11] <= 512'h000000000000400063FF63FF6003C003C8038DFF99039803F002F7FF27FF60106110C311999BF9BEF07C007401D61B93FF13E211003000700060000000000000;/*"绿",绿*/
    char_num[12] <= 512'h0000000000000000000FC1FFE1FC7100310021000100010001FFE1FFE10C630C630C630C630C630C660C660C6E0C640CF00CFE008FFF03FF0000000000000000;/*"近",近*/
    char_num[13] <= 512'h000000000000018001800180018001800180FFFFFFFFC183C183C183C183C183C183FFFFFFFFC183C18301800180018001800180018001800180000000000000;/*"中",中*/
    char_num[14] <= 512'h00000000000000008000C7FEE7FE60002000000000000FFFEFFFE19861986198619861986198611963196319661F6E1F740EFC008FFF07FF001F000000000000;/*"远",远*/
    char_num[15] <= 512'h000000000000000000007FFE7FFE0300030003000300030003000300FFFFFFFF026002600660066006600C601C61186138617061E07FC03F8000000000000000;/*"无",无*/
end


endmodule