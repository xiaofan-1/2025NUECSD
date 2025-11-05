

module dma_ctrl #(
    parameter FRAME_LEN    = 21'd307200,	 //帧大小: 640*480 = 307200
	parameter BURST_LENGTH = 10'd256
)(
	input					clk			,//System Clock
	input					sdram_clk	,//SDRAM Clock
	input					rst_n				,//System Reset
	//	FIFO Write Side 1	
	input	[15:0]	WR1_DATA			,//Data input
	input					WR1					,//Write Request
	input					WR1_LOAD			,//Write register load & fifo clear
	input					WR1_CLK				,//Write fifo clock
	output					WR1_FULL			,//Write fifo full
	output	[8:0]			WR1_USE				,//Write fifo usedw
	//	FIFO Write Side 2	
	input	[15:0]	WR2_DATA			,//Data input
	input					WR2					,//Write Request
	input					WR2_LOAD			,//Write register load & fifo clear
	input					WR2_CLK				,//Write fifo clock
	output					WR2_FULL			,//Write fifo full
	output	[8:0]			WR2_USE				,//Write fifo usedw
	//	FIFO Read Side 1	
	output	[15:0]	RD1_DATA			,//Data output
	input					RD1					,//Read Request
	input					RD1_LOAD			,//Read register load & fifo clear
	input					RD1_CLK				,//Read fifo clock
	output					RD1_EMPTY			,//Read fifo empty
	output	[8:0]			RD1_USE				,//Read fifo usedw
	//	FIFO Read Side 2	
	output	[15:0]	RD2_DATA			,//Data output
	input					RD2					,//Read Request
	input					RD2_LOAD			,//Read register load & fifo clear
	input					RD2_CLK				,//Read fifo clock
	output					RD2_EMPTY			,//Read fifo empty
	output	[8:0]			RD2_USE				,//Read fifo usedw
	output	wire			sdram_init_done	
 );

localparam	FRAME_ADDR_WR1_TEMPA  = 0;
localparam	FRAME_ADDR_WR1_TEMPB  = FRAME_LEN;
localparam	FRAME_ADDR_WR2_TEMPA  = FRAME_LEN * 2;
localparam	FRAME_ADDR_WR2_TEMPB  = FRAME_LEN * 3;

localparam	FRAME_ADDR_MAX1_TEMPA = FRAME_LEN;
localparam	FRAME_ADDR_MAX1_TEMPB = FRAME_LEN * 2;
localparam	FRAME_ADDR_MAX2_TEMPA = FRAME_LEN * 3;
localparam	FRAME_ADDR_MAX2_TEMPB = FRAME_LEN * 4;

wire 			WR1_finish;
wire 			WR2_finish;
wire 			RD1_finish;
wire 			RD2_finish;

reg				wr_select0;
reg				rd_select0;
reg				wr_select1;
reg				rd_select1;

wire	[20:0]		write_addr_index0;
wire	[20:0]		write_addr_index1;
wire	[20:0]		write_max_index0 ;
wire	[20:0]		write_max_index1 ;


reg  	[20:0]		read_addr_index0 ;
reg  	[20:0]		read_addr_index1 ;
reg 	[20:0]		read_max_index0  ;
reg 	[20:0]		read_max_index1  ;

//------------写选择-----------
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		wr_select0 = 1'b0;
	else if(WR1_finish)
		wr_select0 = ~wr_select0;
	else
		wr_select0 = wr_select0;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		wr_select1 = 1'b0;
	else if(WR2_finish)
		wr_select1 = ~wr_select1;
	else
		wr_select1 = wr_select1;
end
//------------读选择-----------
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		rd_select0 = 1'b1;
	else if(WR1_finish)
		rd_select0 = ~rd_select0;
	else
		rd_select0 = rd_select0;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		rd_select1 = 1'b1;
	else if(WR2_finish)
		rd_select1 = ~rd_select1;
	else
		rd_select1 = rd_select1;
end


//---------------地址切换--------------------
assign write_addr_index0 = (wr_select0 == 1'b0) ? FRAME_ADDR_WR1_TEMPA : FRAME_ADDR_WR1_TEMPB;
assign write_addr_index1 = (wr_select1 == 1'b0) ? FRAME_ADDR_WR2_TEMPA : FRAME_ADDR_WR2_TEMPB;

// assign read_addr_index0 = (rd_select0 == 1'b0 && RD1_finish) ? FRAME_ADDR_WR1_TEMPA : FRAME_ADDR_WR1_TEMPB;
// assign read_addr_index1 = (rd_select1 == 1'b0 && RD2_finish) ? FRAME_ADDR_WR2_TEMPA : FRAME_ADDR_WR2_TEMPB;

assign write_max_index0 = (wr_select0 == 1'b0) ? FRAME_ADDR_MAX1_TEMPA : FRAME_ADDR_MAX1_TEMPB;
assign write_max_index1 = (wr_select1 == 1'b0) ? FRAME_ADDR_MAX2_TEMPA : FRAME_ADDR_MAX2_TEMPB;

// assign read_max_index0 = (rd_select0 == 1'b0 && RD1_finish) ? FRAME_ADDR_MAX1_TEMPA : FRAME_ADDR_MAX1_TEMPB;
// assign read_max_index1 = (rd_select1 == 1'b0 && RD2_finish) ? FRAME_ADDR_MAX2_TEMPA : FRAME_ADDR_MAX2_TEMPB;

 always @(posedge clk or negedge rst_n) begin
     if (!rst_n)
         read_addr_index0 <= FRAME_ADDR_WR1_TEMPA;
     else if(rd_select0 == 1'b0 && RD1_finish)
         read_addr_index0 <= FRAME_ADDR_WR1_TEMPA;
	 else if(rd_select0 == 1'b1 && RD1_finish)
		 read_addr_index0 <= FRAME_ADDR_WR1_TEMPB;
	 else
		 read_addr_index0 <= read_addr_index0;
 end

 always @(posedge clk or negedge rst_n) begin
     if (!rst_n)
         read_addr_index1 <= FRAME_ADDR_WR2_TEMPA;
     else if(rd_select1 == 1'b0 && RD2_finish)
         read_addr_index1 <= FRAME_ADDR_WR2_TEMPA;
	 else if(rd_select1 == 1'b1 && RD2_finish)
		 read_addr_index1 <= FRAME_ADDR_WR2_TEMPB;
	 else
		 read_addr_index1 <= read_addr_index1;
 end

 always @(posedge clk or negedge rst_n) begin
     if (!rst_n)
         read_max_index0 <= FRAME_ADDR_MAX1_TEMPA;
     else if(rd_select0 == 1'b0 && RD1_finish)
         read_max_index0 <= FRAME_ADDR_MAX1_TEMPA;
	 else if(rd_select0 == 1'b1 && RD1_finish)
		 read_max_index0 <= FRAME_ADDR_MAX1_TEMPB;
	 else
		 read_max_index0 <= read_max_index0;
 end

 always @(posedge clk or negedge rst_n) begin
     if (!rst_n)
         read_max_index1 <= FRAME_ADDR_MAX2_TEMPA;
     else if(rd_select1 == 1'b0 && RD2_finish)
         read_max_index1 <= FRAME_ADDR_MAX2_TEMPA;
	 else if(rd_select1 == 1'b1 && RD2_finish)
		 read_max_index1 <= FRAME_ADDR_MAX2_TEMPB;
	 else
		 read_max_index1 <= read_max_index1;
 end

Sdram_Control_4Port  #(
    .FRAME_SIZE   (FRAME_LEN),       // 参数：传入单帧图像的大小 (例如: 640*480)
    .BURST_LENGTH (BURST_LENGTH)     // 参数：传入单次SDRAM突发传输的长度 (例如: 256)
) u_Sdram_Control_4Port (
    //-----------------------------------------------------
    // 主控和时钟信号
    //-----------------------------------------------------
    .CTRL_CLK                          (clk					),// 输入: SDRAM控制器的核心工作时钟 (例如: 100MHz)
    .SDRAM_CLK                         (sdram_clk			),// 输入: 提供给SDRAM芯片的物理时钟 (通常与CTRL_CLK有相位偏移)
    .RESET_N                           (rst_n				),// 输入: 全局异步复位信号，低电平有效

    //-----------------------------------------------------
    // 写通道1 (Write Port 1) - 用于第一个乒乓缓存系统
    //-----------------------------------------------------
    .WR1_DATA                          (WR1_DATA			),// 输入: [15:0] 要写入SDRAM的数据 (例如: 来自摄像头的数据)
    .WR1                               (WR1					),// 输入:       写请求信号，高电平有效
    .WR1_ADDR                          (write_addr_index0	),// 输入: [20:0] 动态计算的写缓存区起始地址 (Buffer A或B)
    .WR1_MAX_ADDR                      (write_max_index0	),// 输入: [20:0] 动态计算的写缓存区结束地址
    .WR1_LENGTH                        (BURST_LENGTH		),// 输入: [9:0]  单次突发写操作的长度
    .WR1_LOAD                          (WR1_LOAD			),// 输入:       地址和配置载入信号 (通常在复位或切换模式时给脉冲)
    .WR1_CLK                           (WR1_CLK				),// 输入:       写数据侧的时钟 (例如: 摄像头像素时钟 cam_pclk)
    .WR1_FULL                          (WR1_FULL			),// 输出:       写FIFO已满标志，提示上游模块暂停写入
    .WR1_USE                           (WR1_USE				),// 输出: [8:0]  写FIFO中已使用的数据深度

    //-----------------------------------------------------
    // 写通道2 (Write Port 2) - 用于第二个乒乓缓存系统
    //-----------------------------------------------------
    .WR2_DATA                          (WR2_DATA			),// 输入: [15:0] 要写入SDRAM的数据 (例如: 来自图像处理模块的结果)
    .WR2                               (WR2					),// 输入:       写请求信号
    .WR2_ADDR                          (write_addr_index1	),// 输入: [20:0] 动态计算的写缓存区起始地址 (Buffer C或D)
    .WR2_MAX_ADDR                      (write_max_index1 	),// 输入: [20:0] 动态计算的写缓存区结束地址
    .WR2_LENGTH                        (BURST_LENGTH	 	),// 输入: [8:0]  单次突发写操作的长度
    .WR2_LOAD                          (WR2_LOAD		 	),// 输入:       地址和配置载入信号
    .WR2_CLK                           (WR2_CLK			 	),// 输入:       写数据侧的时钟
    .WR2_FULL                          (WR2_FULL		 	),// 输出:       写FIFO已满标志
    .WR2_USE                           (WR2_USE			 	),// 输出: [8:0]  写FIFO中已使用的数据深度

    //-----------------------------------------------------
    // 读通道1 (Read Port 1) - 用于第一个乒乓缓存系统
    //-----------------------------------------------------
    .RD1_DATA                          (RD1_DATA		 	),// 输出: [15:0] 从SDRAM读出的数据 (例如: 送给图像处理模块)
    .RD1                               (RD1	 	),// 输入:       经过握手逻辑控制后的真正读请求
    .RD1_ADDR                          (read_addr_index0 	),// 输入: [20:0] 动态计算的读缓存区起始地址 (Buffer A或B)
    .RD1_MAX_ADDR                      (read_max_index0	 	),// 输入: [20:0] 动态计算的读缓存区结束地址
    .RD1_LENGTH                        (BURST_LENGTH	 	),// 输入: [9:0]  单次突发读操作的长度
    .RD1_LOAD                          (RD1_LOAD		 	),// 输入:       地址和配置载入信号
    .RD1_CLK                           (RD1_CLK			 	),// 输入:       读数据侧的时钟 (例如: 图像处理模块的工作时钟)
    .RD1_EMPTY                         (RD1_EMPTY		 	),// 输出:       读FIFO已空标志，提示下游模块暂停读取
    .RD1_USE                           (RD1_USE			 	),// 输出: [8:0]  读FIFO中已使用的数据深度

    //-----------------------------------------------------
    // 读通道2 (Read Port 2) - 用于第二个乒乓缓存系统
    //-----------------------------------------------------
    .RD2_DATA                          (RD2_DATA		 	),// 输出: [15:0] 从SDRAM读出的数据 (例如: 送给VGA显示)
    .RD2                               (RD2		),// 输入:       经过握手逻辑控制后的真正读请求
    .RD2_ADDR                          (read_addr_index1	),// 输入: [20:0] 动态计算的读缓存区起始地址 (Buffer C或D)
    .RD2_MAX_ADDR                      (read_max_index1		),// 输入: [20:0] 动态计算的读缓存区结束地址
    .RD2_LENGTH                        (BURST_LENGTH		),// 输入: [8:0]  单次突发读操作的长度
    .RD2_LOAD                          (RD2_LOAD			),// 输入:       地址和配置载入信号
    .RD2_CLK                           (RD2_CLK				),// 输入:       读数据侧的时钟 (例如: VGA像素时钟 vga_clk)
    .RD2_EMPTY                         (RD2_EMPTY			),// 输出:       读FIFO已空标志
    .RD2_USE                           (RD2_USE				),// 输出: [8:0]  读FIFO中已使用的数据深度
    
    //-----------------------------------------------------
    // 控制和状态信号
    //-----------------------------------------------------
    .sdram_init_done                   (sdram_init_done		),// 输出:       SDRAM初始化完成标志，高电平表示SDRAM准备就绪
	.pic_done0						   (pic_done0),
	.pic_done1						   (pic_done1),
    
    //-----------------------------------------------------
    // 新增的“帧完成”标志信号 (用于乒乓缓存切换)
    //-----------------------------------------------------
    .WR1_finish                        (WR1_finish			),// 输出:       写通道1完成一整帧数据写入的脉冲信号
    .WR2_finish                        (WR2_finish			),// 输出:       写通道2完成一整帧数据写入的脉冲信号
    .RD1_finish                        (RD1_finish			),// 输出:       读通道1完成一整帧数据读取的脉冲信号
    .RD2_finish                        (RD2_finish			) // 输出:       读通道2完成一整帧数据读取的脉冲信号
);


endmodule
