`timescale 1ns / 1ps

module protocol_ctrl#(
	parameter	FORMAT   =   8'h04     ,//图像格式 04:(RGB565) 05:(RGB888)
    parameter	H_PIXEL  =   16'd1280  ,//行像素个数：1280
    parameter	V_PIXEL  =   16'd720    //场像素个数：720
)(
    input   wire            rst_n           ,
    input   wire    [7:0]   cam_data        ,//ddr摄像头数据
    input   wire            rf_rd_req       ,//ddr读fifo不为空信号
    output  wire            rf_rd_en        ,//ddr读fifo使能
    //arp
    input   wire            arp_tx_valid    ,
    input   wire            arp_tx_en       ,
    input   wire            arp_rx_op       ,
    input   wire            arp_rx_done     ,
    input   wire    [7:0]   arp_tx_data     ,
    //udp
    input   wire    [7:0]   udp_tx_data     ,
    input   wire            udp_tx_valid    ,
    input   wire            udp_tx_done     ,
	input   wire            udp_data_valid  ,//udp数据有效信号
    output  wire    [7:0]   udp_odata       ,//udp发送的数据
    output  wire            udp_tx_en       ,//以太网传输数据开始信号
    output  wire    [15:0]  udp_tx_data_num ,
	output  wire            image_format_end,//图像数据格式结束信号
    //rgmii
    input   wire            clk             ,
    output  wire            mac_tx_valid    ,
    output  wire    [7:0]   mac_tx_data     
    );
    
reg flag; //0:arp ,1:udp
assign mac_tx_valid = (flag) ? udp_tx_valid:arp_tx_valid;
assign mac_tx_data  = (flag) ? udp_tx_data :arp_tx_data ;

wire            udp_tx_cmd_start;
wire            udp_tx_data_start;
// wire            image_format_end;
wire            image_format_busy;
wire    [15:0]  image_format_num;
wire    [15:0]  image_data_num;
wire    [7:0]   image_format_data;
wire    [7:0]   image_data;

assign udp_tx_en = (udp_tx_cmd_start || udp_tx_data_start) ? 1 : 0; 
assign udp_tx_data_num = (image_format_busy) ? image_format_num : image_data_num;
assign udp_odata = (image_format_busy) ? image_format_data : image_data;

always @(posedge clk) begin
    if(!rst_n)
        flag <= 0;
    else if(arp_tx_en)//arp工作
        flag <= 0;
    else if(arp_rx_op == 0 && arp_rx_done)//arp接收应答包，并工作完成
        flag <= 1;
    else
        flag <= flag;
end

reg	flag_reg0;
reg	flag_reg1;
wire	posedge_flag;
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		flag_reg0 <= 1'b0;
		flag_reg1 <= 1'b0;
	end
	else begin
		flag_reg0 <= flag;
		flag_reg1 <= flag_reg0;
	end
end

assign posedge_flag = (~flag_reg1 && flag_reg0) ? 1'b1 : 1'b0;

image_format #(
	.FORMAT   (FORMAT ),//图像格式 04:(RGB565) 05:(RGB888)
    .H_PIXEL  (H_PIXEL),//行像素个数：1280--16'h05_00 低位在前
    .V_PIXEL  (V_PIXEL)//场像素个数：720--16'h02_d0  低位在前
)image_format_u(
    /*input   wire            */.clk                (clk              ) ,
    /*input   wire            */.rst_n              (rst_n            ) ,
    /*input   wire            */.udp_cmd_start      (posedge_flag     ) ,//发送命令开始信号
    /*input   wire            */.udp_tx_done        (udp_tx_done      ) ,//udp发送完一个数据包结束信号
	/*input   wire            */.udp_data_valid     (udp_data_valid   ) ,//udp数据有效信号
    /*output  reg             */.udp_tx_cmd_start   (udp_tx_cmd_start ) ,//发送图像数据格式开始信号
    /*output  reg     [7:0]   */.image_format_data  (image_format_data) ,//图像数据格式
    /*output  wire            */.image_format_end   (image_format_end ) ,//图像数据格式结束信号
    /*output  wire    [15:0]  */.image_format_num   (image_format_num ) , //udp发送数据字节个数
    /*output  wire            */.image_format_busy  (image_format_busy)
    );

image_data #(
    .H_PIXEL (H_PIXEL),//分辨率为1280*720
    .V_PIXEL (V_PIXEL) //一个udp包传输1280字节，需要传输1440次
)image_data_u(
    /*input   wire            */.clk               (clk              )  ,
    /*input   wire            */.rst_n             (rst_n            )  ,  
    /*input   wire    [7:0]   */.cam_data          (cam_data         )  ,//ddr摄像头数据
    /*input   wire            */.udp_data_start    (image_format_end )  ,//开始执行本模块信号
    /*input   wire            */.udp_tx_done       (udp_tx_done      )  ,//以太网传输完一个包结束信号
    /*input   wire            */.rf_rd_req         (rf_rd_req        )  ,//ddr读fifo不为空信号
	/*input   wire            */.udp_data_valid    (udp_data_valid   )  ,//udp数据有效信号
    /*output  wire            */.rf_rd_en          (rf_rd_en         )  ,//ddr读fifo使能
    /*output  reg     [7:0]   */.image_data        (image_data       )  ,//封装好的图像数据
    /*output  reg             */.udp_tx_data_start (udp_tx_data_start)  ,//以太网开始传输信号
    /*output  reg     [15:0]  */.image_data_num    (image_data_num   )   //以太网传输数据个数
    );

endmodule
