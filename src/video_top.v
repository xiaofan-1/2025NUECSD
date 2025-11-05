`timescale 1ns / 1ps

module video_top(
	input	wire			clk				,
	input	wire			rst_n			,
	input	wire            ext_mem_clk		,       //external memory clock
	input	wire            ext_mem_clk_sft	,
	input	wire			video_clk  		,
	input	wire			hdmi_5x_clk		,
	//key
	input	wire			key2_flag		,
	input	wire			key3_flag		,
	input	wire			key4_flag		,
	//cam                      
    input	wire			cam_pclk     	,  //cmos 数据像素时钟
    input	wire			cam_vsync    	,  //cmos 场同步信号
    input	wire			cam_href     	,  //cmos 行同步信号
    input	wire	[7:0]	cam_data     	,  //cmos 数据
    output	wire			cam_rst_n    	,  //cmos 复位信号，低电平有效
    output	wire			cam_pwdn     	,  //电源休眠模式选择 0：正常模式 1：电源休眠模式
    output	wire			cam_scl      	,  //cmos SCCB_SCL线
    inout	wire			cam_sda      	,  //cmos SCCB_SDA线  
	//
	output	wire			hsync_o			,
	output	wire			vsync_o	        ,
	output	wire			de_o   	        ,
	(* MARK_DEBUG="true" *)output	wire	[23:0]	data_o_eth		,
	(* MARK_DEBUG="true" *)output	wire	[23:0]	color_data
 );
parameter  H_CMOS_DISP = 11'd640;                  //CMOS分辨率--列	              
parameter  V_CMOS_DISP = 11'd480;                  //CMOS分辨率--行
                 
parameter  TOTAL_H_PIXEL = H_CMOS_DISP + 12'd1216; //CMOS分辨率--行
parameter  TOTAL_V_PIXEL = V_CMOS_DISP + 12'd504;    			

parameter   BURST_SIZE = 256;
parameter 	FRAME_BUFFER_SIZE = 21'd307200; //缓冲起始地址	   

//=========================sdram========================
wire 							Sdr_init_done;
// wire                            ext_mem_clk;       //external memory clock
// wire                            ext_mem_clk_sft;
wire							write_clk;
wire							read_clk;
//=========================HDMI========================
// wire                            video_clk;         //video pixel clock
// wire							hdmi_5x_clk;
wire                            hs;
wire                            vs;
wire 							de;

// wire                            hsync_o;
// wire                            vsync_o;
// wire 							de_o   ;

wire        					hs_reg;
wire        					vs_reg;
wire 							de_reg;
					
wire        					hs_reg1;
wire        					vs_reg1;
wire 							de_reg1;
					
wire        					hs_reg2;
wire        					vs_reg2;
wire 							de_reg2;
					
wire        					hs_reg3;
wire        					vs_reg3;
wire 							de_reg3;

wire        					hs_reg4;
wire        					vs_reg4;
wire 							de_reg4;

wire	[11:0]	 				pixle_x_reg;
wire	[11:0]	 				pixle_y_reg;

wire	[23:0]                  YCrCb_dara;
wire	[23:0]                  move_data_o;
wire	[23:0]                  data_o;

wire	[23:0]                  vout_data;
wire	[7:0]                   data_gray;

wire                            video_read_en;
wire	[31:0]                  video_read_data;
wire                            cam_write_en;
wire	[31:0]                  cam_write_data;
wire                            cam_write_req;
wire                            cam_write_req_ack;

wire 							cmos_frame_vsync;
wire 							cmos_frame_href;
wire 							cmos_frame_valid;
wire 	[15:0] 					cmos_wr_data;

wire 	[15:0]					data_out;
					
wire 	[15:0]					data_gray_reg;
					
wire 	[ 7:0]					diff_data;
					
wire 	[ 7:0]					data_erode;

wire 	[ 7:0]					data_dilate;

wire	[ 7:0]					number;
					
// wire 	[23:0]					color_data;
				
wire	[11:0]					pic_x;
wire	[11:0]					pic_y;
wire	[15:0]					pic_data;
				
wire	[10:0]					x_min_move;
wire	[10:0]					x_max_move;
wire	[10:0]					y_min_move;
wire	[10:0]					y_max_move;



//ov5640 驱动
ov5640_dri u_ov5640_dri(
    .clk               (clk),
    .rst_n             (rst_n),

    .cam_pclk          (cam_pclk ),
    .cam_vsync         (cam_vsync),
    .cam_href          (cam_href ),
    .cam_data          (cam_data ),
    .cam_rst_n         (cam_rst_n),
    .cam_pwdn          (cam_pwdn ),
    .cam_scl           (cam_scl  ),
    .cam_sda           (cam_sda  ),
    
    .capture_start     (Sdr_init_done),
    .cmos_h_pixel      (H_CMOS_DISP),
    .cmos_v_pixel      (V_CMOS_DISP),
    .total_h_pixel     (TOTAL_H_PIXEL),
    .total_v_pixel     (TOTAL_V_PIXEL),
    .cmos_frame_vsync  (cmos_frame_vsync),
    .cmos_frame_href   (cmos_frame_href),
    .cmos_frame_valid  (cmos_frame_valid),
    .cmos_frame_data   (cmos_wr_data)
    );   

ov5640_delay u_ov5640_delay(
    .clk               (cam_pclk),
    .rst_n             (rst_n),
    .cmos_frame_vsync  (cmos_frame_vsync),
    .cmos_frame_href   (cmos_frame_href),
    .cmos_frame_valid  (cmos_frame_valid),
    .cmos_wr_data      (cmos_wr_data),
    
    .cam_write_req(cam_write_req),
    .cam_write_req_ack(cam_write_req_ack),
    .cam_write_en(cam_write_en),
    .cam_write_data(cam_write_data)
);

video_delay video_delay_m0(
    .video_clk                  (video_clk                ),
	.rst                        (~rst_n    				  ),
    .read_en					(video_read_en			  ),
    .read_data					(data_out	  			  ),
    .hs                         (hs                       ),
	.vs                         (vs                       ),
	.de                         (de                       ),
	.vout_data					(vout_data				  ),
	.pic_x						(pic_x),
    .pic_y						(pic_y)
);

 dma_ctrl #(
     .FRAME_LEN              (FRAME_BUFFER_SIZE),       // 帧大小
     .BURST_LENGTH           (BURST_SIZE)               // 突发长度
 ) u_dma_ctrl (
     /*-----------------------------------------------------
     主控和时钟信号
     -----------------------------------------------------*/
     /*input              	*/.clk                      (ext_mem_clk),          // DMA控制器和SDRAM控制器的核心工作时钟
     /*input              	*/.sdram_clk                (ext_mem_clk_sft),    // 提供给SDRAM芯片的物理时钟
     /*input              	*/.rst_n                    (rst_n),        // 全局异步复位信号，低电平有效

     /*-----------------------------------------------------
     写通道1 (Write Port 1) - 用于接收摄像头等高速数据源
     -----------------------------------------------------*/
     /*input   [`DSIZE-1:0] 	*/.WR1_DATA             (cam_write_data),      // 要写入乒乓缓存区A/B的数据
     /*input              	*/.WR1                      (cam_write_en),       // 来自数据源的写请求
     /*input              	*/.WR1_LOAD                 (~rst_n),       // 通道1的配置载入信号 (通常在复位时给一个脉冲来初始化地址指针)
     /*input              	*/.WR1_CLK                  (cam_pclk),         // 数据源侧的时钟 (例如: 摄像头的像素时钟)
     /*output             	*/.WR1_FULL                 (),    // 写FIFO1已满标志，用于向上游(摄像头)提供反压，防止数据丢失
     /*output    [8:0]    	*/.WR1_USE                  (),   // 写FIFO1中已使用的数据量 (用于调试)

     /*-----------------------------------------------------
     写通道2 (Write Port 2) - 用于缓存图像处理后的结果
     -----------------------------------------------------*/
     /*input   [`DSIZE-1:0] */.WR2_DATA                 ({data_gray,8'h0}),    // 要写入乒乓缓存区C/D的数据
     /*input                */.WR2                      (de_reg),      // 来自数据源的写请求
     /*input                */.WR2_LOAD                 (~rst_n),       // 通道2的配置载入信号
     /*input                */.WR2_CLK                  (video_clk),         // 数据源侧的时钟 (例如: 图像处理模块的时钟)
     /*output               */.WR2_FULL                 (),   // 写FIFO2已满标志
     /*output    [8:0]      */.WR2_USE                  (),   // 写FIFO2中已使用的数据量

     /*-----------------------------------------------------
     读通道1 (Read Port 1) - 用于为显示控制器提供数据
     -----------------------------------------------------*/
     /*output  [`DSIZE-1:0] */.RD1_DATA                 (data_out),     // 从乒乓缓存区A/B读出的数据
     /*input              	*/.RD1                      (de),      // 来自数据用户的读请求
     /*input              	*/.RD1_LOAD                 (~rst_n),       // 通道1的配置载入信号
     /*input              	*/.RD1_CLK                  (video_clk),         // 数据用户侧的时钟 (例如: 图像处理模块的时钟)
     /*output             	*/.RD1_EMPTY                (),  // 读FIFO1已空标志，提示下游(图像处理模块)暂停读取
     /*output    [8:0]    	*/.RD1_USE                  (),   // 读FIFO1中已使用的数据量

     /*-----------------------------------------------------
     读通道2 (Read Port 2) - 用于为图像处理模块提供数据
     -----------------------------------------------------*/
     /*output  [`DSIZE-1:0] */.RD2_DATA                 (data_gray_reg),      // 从乒乓缓存区C/D读出的数据
     /*input              	*/.RD2                      (de_reg),       // 来自数据用户的读请求
     /*input              	*/.RD2_LOAD                 (~rst_n),       // 通道2的配置载入信号
     /*input              	*/.RD2_CLK                  (video_clk),          // 数据用户侧的时钟 (例如: VGA像素时钟)
     /*output             	*/.RD2_EMPTY                (),   // 读FIFO2已空标志，提示下游(VGA)暂停读取
     /*output    [8:0]    	*/.RD2_USE                  (),   // 读FIFO2中已使用的数据量

     /*-----------------------------------------------------
     状态信号
     -----------------------------------------------------*/
     /*output             	*/.sdram_init_done          (Sdr_init_done)    // SDRAM初始化完成标志，高电平表示可以开始读写操作
 );

image_top image_top_u(
	/*-----------------------------------------------------
     主控和时钟信号
     -----------------------------------------------------*/
	/*input	wire		   	*/.clk	 		(video_clk)		,
	/*input	wire		   	*/.rst_n   		(rst_n	  )		,
	/*-----------------------------------------------------
     输入行场信号和数据
     -----------------------------------------------------*/
	/*input   wire         	*/.hsync_i 		(hs)   			,//行信号
    /*input   wire         	*/.vsync_i 		(vs)   			,//场信号
    /*input   wire         	*/.de_i    		(de)   			,
    /*input   wire [23:0]  	*/.data_i  		(vout_data )   	,//
	/*-----------------------------------------------------
     输出行场信号和数据（灰度 - 中值 - 高斯）
     -----------------------------------------------------*/
	/*output  wire         	*/.hsync_o    	(hs_reg)       	,
    /*output  wire         	*/.vsync_o    	(vs_reg)       	,
    /*output  wire         	*/.de_o       	(de_reg)       	,
    /*output  wire [7:0]  	*/.data_o     	(data_gray)       
    );

//帧差法
diff_pic diff_pic_u(
	/*-----------------------------------------------------
     主控和时钟信号
     -----------------------------------------------------*/
    /*input  wire                   */.sys_clk       (video_clk  ) ,
    /*input  wire                   */.sys_rst_n     (rst_n) ,
    /*-----------------------------------------------------
     输入行场信号
     -----------------------------------------------------*/                                      
    /*input  wire                   */.hsync_i       (hs_reg) ,
	/*input  wire                   */.vsync_i       (vs_reg) ,
	/*input  wire                   */.de_i          (de_reg) ,
    /*-----------------------------------------------------
     输入帧差数据（第n帧和第n-2帧）
     -----------------------------------------------------*/                                      
    /*input  wire        [   7:0]   */.new_pic       (data_gray) ,
    /*input  wire        [   7:0]   */.last_pic      (data_gray_reg[15:8]) ,
	/*-----------------------------------------------------
     输入帧差阈值
     -----------------------------------------------------*/ 
	/*input  wire        [   7:0]   */.DIFF_THR      (8'd65),
	/*-----------------------------------------------------
     输出行场信号和数据
     -----------------------------------------------------*/ 
    /*output wire                   */.hsync_o       (hs_reg1) ,
    /*output wire                   */.vsync_o       (vs_reg1) ,
	/*output wire                   */.de_o          (de_reg1) ,                               
    /*output wire        [  7:0]    */.diff_data     (diff_data)     
);

image_erosion image_erosion_u(
	/*-----------------------------------------------------
     主控和时钟信号
     -----------------------------------------------------*/
    /*input   wire        */.clk        (video_clk  ) ,
    /*input   wire        */.rst_n      (rst_n) ,
    /*-----------------------------------------------------
     输入行场信号和数据（帧差法后的二值化数据）
     -----------------------------------------------------*/ 
    /*input   wire        */.hsync_i    (hs_reg1) ,
    /*input   wire        */.vsync_i    (vs_reg1) ,
    /*input   wire        */.de_i       (de_reg1) ,
    /*input	wire [7:0]    */.data_i	    (diff_data  ) ,
    /*-----------------------------------------------------
     输出行场信号和数据（腐蚀）
     -----------------------------------------------------*/ 
    /*output  wire        */.hsync_o    (hs_reg2    ) ,
    /*output  wire        */.vsync_o    (vs_reg2    ) ,
    /*output  wire        */.de_o       (de_reg2    ) ,
    /*output  wire [7:0]  */.data_erode (data_erode )
    );
	
image_dilation image_dilation_u(
	/*-----------------------------------------------------
     主控和时钟信号
     -----------------------------------------------------*/
    /*input   wire        */.clk         (video_clk),
    /*input   wire        */.rst_n       (rst_n),
    /*-----------------------------------------------------
     输入行场信号和数据（腐蚀后的二值化数据）
     -----------------------------------------------------*/ 
    /*input   wire        */.hsync_i     (hs_reg2),
    /*input   wire        */.vsync_i     (vs_reg2),
    /*input   wire        */.de_i        (de_reg2),
    /*input	  wire [7:0]  */.data_i		 (data_erode), 
    /*-----------------------------------------------------
     输出行场信号和数据（膨胀）
     -----------------------------------------------------*/ 
    /*output  wire        */.hsync_o     (hs_reg3),
    /*output  wire        */.vsync_o     (vs_reg3),
    /*output  wire        */.de_o        (de_reg3),
    /*output  wire [7:0]  */.data_dilate (data_dilate )
    );                     

//动态坐标
image_frame image_frame_u(
	/*-----------------------------------------------------
     主控和时钟信号
     -----------------------------------------------------*/
    /*input   wire        */.clk      		(video_clk  )   ,
    /*input   wire        */.rst_n    		(rst_n      )   ,
    /*-----------------------------------------------------
     输入行场信号和数据
     -----------------------------------------------------*/     		
    /*input   wire        */.hsync_i  		(hs_reg3)   	,//行信号
    /*input   wire        */.vsync_i  		(vs_reg3)   	,//场信号
    /*input   wire        */.de_i     		(de_reg3)   	,//图像有效信号
    /*input   wire [7:0]  */.data_i   		(data_dilate)  	,//处理后的图像
	/*-----------------------------------------------------
     行场信号坐标
     -----------------------------------------------------*/  
    /*input   wire [9:0]  */.pixle_x  		(pic_x)   		,
    /*input   wire [9:0]  */.pixle_y  		(pic_y)   		,
	/*-----------------------------------------------------
     摄像头图像数据
     -----------------------------------------------------*/ 
    /*input   wire [23:0] */.rgb_data 		(vout_data)  	,
	/*-----------------------------------------------------
     输出动态目标极值坐标
     -----------------------------------------------------*/ 
    /*output  reg  [10:0] */.x_min_r    	(x_min_move)	,
    /*output  reg  [10:0] */.x_max_r    	(x_max_move)	,
    /*output  reg  [10:0] */.y_min_r    	(y_min_move)	,
    /*output  reg  [10:0] */.y_max_r    	(y_max_move)	,
	/*-----------------------------------------------------
     输出打拍后的行场坐标
     -----------------------------------------------------*/ 
	/*output  reg  [11:0] */.pixle_x_reg 	(pixle_x_reg) 	,
	/*output  reg  [11:0] */.pixle_y_reg 	(pixle_y_reg) 	,
	/*-----------------------------------------------------
     输出行场信号和数据（打拍后的摄像头图像数据）
     -----------------------------------------------------*/
    /*output  reg         */.hsync_o  		(hs_reg4)   	,
    /*output  reg         */.vsync_o  		(vs_reg4)   	,
    /*output  reg         */.de_o     		(de_reg4)   	,
    /*output  reg  [23:0] */.data_o   		(move_data_o  )    //
    );

image_color image_color_u(
	/*-----------------------------------------------------
     主控和时钟信号
     -----------------------------------------------------*/
    /*input	wire			*/.clk						(video_clk),  			
	/*input	wire			*/.rst_n					(rst_n    ),			
	/*-----------------------------------------------------
     输入行场信号和数据
     -----------------------------------------------------*/   													
    /*input   wire        	*/.hsync_i     				(hs_reg4),//行信号
    /*input   wire        	*/.vsync_i     				(vs_reg4),//场信号
    /*input   wire        	*/.de_i        				(de_reg4),
    /*input   wire 	[23:0] 	*/.data_i      				(move_data_o),//
	/*-----------------------------------------------------
     按键
     -----------------------------------------------------*/ 	
	/*input	wire			*/.key2_flag				(key2_flag),	 
	/*input	wire			*/.key3_flag				(key3_flag),
	/*input	wire			*/.key4_flag				(key4_flag),
	/*-----------------------------------------------------
     输入行场坐标
     -----------------------------------------------------*/ 	
	/*input	wire 	[10:0]  */.pixel_x					(pixle_x_reg),
	/*input	wire 	[10:0]	*/.pixel_y					(pixle_y_reg),
	/*-----------------------------------------------------
     输出动态目标极值坐标
     -----------------------------------------------------*/ 													
	/*input   wire 	[11:0] 	*/.x_min_move			    (x_min_move),
    /*input   wire 	[11:0] 	*/.x_max_move			    (x_max_move),
    /*input   wire 	[11:0] 	*/.y_min_move			    (y_min_move),
    /*input   wire 	[11:0] 	*/.y_max_move			    (y_max_move),
	/*-----------------------------------------------------
     输出行场信号和数据（框和数据）
     -----------------------------------------------------*/
    /*output  wire 	       	*/.hsync_o     				(hsync_o   ),
    /*output  wire 	       	*/.vsync_o     				(vsync_o   ),
    /*output  wire 	       	*/.de_o        				(de_o      ),
	/*output  reg  	[23:0] 	*/.data_o_eth				(data_o_eth),  
	/*output  wire 	[23:0] 	*/.data_o      				(data_o    ) //
    );
    
	
endmodule
