`timescale 1ns / 1ps

module image_data #(
    parameter	H_PIXEL = 16'd1280,//分辨率为1280*720
    parameter	V_PIXEL = 16'd720  //一个udp包传输1280字节，需要传输1440次
)(
    input   wire            clk                 ,
    input   wire            rst_n               ,
    
    input   wire    [7:0]   cam_data            ,//ddr摄像头数据
    input   wire            udp_data_start      ,//开始执行本模块信号
    input   wire            udp_tx_done         ,//以太网传输完一个包结束信号
    input   wire            rf_rd_req           ,//ddr读fifo不为空信号
    input   wire            udp_data_valid      ,//udp数据有效信号
   
    output  wire            rf_rd_en            ,//ddr读fifo使能
    output  reg     [7:0]   image_data          ,//封装好的图像数据
    output  reg             udp_tx_data_start   ,//以太网开始传输信号
    output  reg     [15:0]  image_data_num       //以太网传输数据个数
    );
	
localparam
    CNT_PACKET_WAIT = 28'd10,
    CNT_FRAME_WAIT = 28'd10;
    
localparam
    HEAD     =   32'h53_5a_48_59 ,//包头
    ADDR     =   8'h00           ,//设备地址
    CMD      =   8'h02           ,//指令
    CRC      =   16'h7C_0B       ;//CRC-16校验：关闭上位机校验，可填写任意值

localparam
    IDLE        = 6'b000_001,                               
    HEAD_PACKET = 6'b000_010,//第一包数据，包含包头    
	DATA_STARTE = 6'b100_001,
    DATA_PACKET = 6'b000_100,//图像数据
	LAST_STARTE = 6'b100_010,
    LAST_PACKET = 6'b001_000,//最后一包数据
    PACKET_WAIT = 6'b010_000,//单包发送完，等待时间
    FRAME_WAIT  = 6'b100_000;//一帧数据发送完，等待时间

reg     [5:0]   curr_state;
reg     [5:0]   next_state;
reg     [27:0]  cnt_packet;//单包等待时间计数
reg     [27:0]  cnt_frame;//单帧等待时间计数
//reg     [10:0]  cnt_v;//
reg     [10:0]  cnt_h;//一帧图像发送udp包的个数
reg     [10:0]  cnt_data;//传输数据个数计数，2字节

reg             udp_data_start_reg;
reg             udp_data_valid_reg;

localparam TOTAL_BYTES_VALUE = H_PIXEL*V_PIXEL*2 + 4 + 1 + 4 + 1 + 2;//包长：表示从包头到校验的所有数据长度，单位为字节   00_1c_20_0c   00_09_60_0c
                         //(1280*720*2)(图像数据) + 4(包头) + 1(设备地址) + 4(包长度) + 1(指令字节) + 2(校验字节)

// 声明一个 wire，并使用拼接操作符进行字节翻转，得到小端序
wire	[31:0]	DATA_NUM ;
assign DATA_NUM = {TOTAL_BYTES_VALUE[7:0],   // Byte 0 (LSB)
                   TOTAL_BYTES_VALUE[15:8],  // Byte 1
                   TOTAL_BYTES_VALUE[23:16], // Byte 2
                   TOTAL_BYTES_VALUE[31:24]};// Byte 3 (MSB)
				   
wire	[15:0]	h_num;
wire	[15:0]	v_num;
assign	h_num = (H_PIXEL <= 16'd736) ? H_PIXEL*2 : H_PIXEL;
assign	v_num = (H_PIXEL <= 16'd736) ? V_PIXEL : V_PIXEL*2;

//----------------------------state_one----------------------
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        curr_state <= IDLE;
    else
        curr_state <= next_state;
end

//----------------------------state_two----------------------
always @(*) begin
    if(!rst_n)
        next_state = IDLE;
    else begin
        case(curr_state)
            IDLE       :begin
                if(rf_rd_req && udp_data_start)
                    next_state = HEAD_PACKET;
                else
                    next_state = curr_state;
            end
            HEAD_PACKET:begin//第一包数据，包含包头
                if(udp_tx_done)
                    next_state = PACKET_WAIT;
                else
                    next_state = curr_state;
            end
			DATA_STARTE:begin
                if(rf_rd_req && udp_data_start)
                    next_state = DATA_PACKET;
                else
                    next_state = curr_state;
            end
            DATA_PACKET:begin//图像数据
                if(udp_tx_done)
                    next_state = PACKET_WAIT;
                else
                    next_state = curr_state;
            end
			LAST_STARTE:begin
                if(rf_rd_req && udp_data_start)
                    next_state = LAST_PACKET;
                else
                    next_state = curr_state;
            end
            LAST_PACKET: begin//最后一包数据
                if(udp_tx_done)
                    next_state = IDLE;
                else
                    next_state = curr_state;
            end
            PACKET_WAIT: begin//单包发送完，等待时间
                if(cnt_h < v_num - 16'd1)
                    next_state = DATA_STARTE;
                else if(cnt_h == v_num - 16'd1)
                    next_state = LAST_STARTE;
                else
                    next_state = curr_state;
            end
            FRAME_WAIT : begin//一帧数据发送完，等待时间
                if(cnt_frame == CNT_FRAME_WAIT)
                    next_state = IDLE;
                else
                    next_state = curr_state;
            end
            default:next_state = IDLE;
        endcase
    end
end
//-----------------------------开始执行本模块信号------------------------
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        udp_data_start_reg <= 1'b0;
    else if(udp_data_start)
        udp_data_start_reg <= 1'b1;
    else
        udp_data_start_reg <= udp_data_start_reg;
end
//----------------------------打拍udp_data_valid----------------------
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        udp_data_valid_reg <= 1'b0;
    else
        udp_data_valid_reg <= udp_data_valid;
end
//----------------------------单包数据等待时间----------------------
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_packet <= 28'd0;
    else if((curr_state == IDLE || curr_state == PACKET_WAIT) && udp_data_start_reg) begin
        if(cnt_packet == CNT_PACKET_WAIT)
            cnt_packet <= 28'd0;
        else
            cnt_packet <= cnt_packet + 28'd1;
    end
    else
        cnt_packet <= 28'd0;
end
//----------------------------单帧数据等待时间----------------------
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_frame <= 28'd0;
    else if(curr_state == FRAME_WAIT) begin
        if(cnt_frame == CNT_FRAME_WAIT)
            cnt_frame <= 28'd0;
        else
            cnt_frame <= cnt_frame + 1;
    end
    else
        cnt_frame <= 28'd0;
end
//----------------------------传输数据计数----------------------
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_data <= 11'd0;
    else if(curr_state == HEAD_PACKET || curr_state == DATA_PACKET || curr_state == LAST_PACKET) begin
        if(udp_data_valid_reg)
            cnt_data <= cnt_data + 1;
        else
            cnt_data <= cnt_data;
    end
    else
        cnt_data <= 11'd0;
end
//----------------------------传输数据----------------------
always @(*) begin
    if(!rst_n)
        image_data = 8'h0;
    else begin
        case(curr_state)
            HEAD_PACKET:begin
                case(cnt_data)                             
                    4'd0:image_data = HEAD[31:24];           
                    4'd1:image_data = HEAD[23:16];  
					4'd2:image_data = HEAD[15:8] ;           
                    4'd3:image_data = HEAD[7:0]  ;
					4'd4:image_data = ADDR;	
                    4'd5:image_data = DATA_NUM[31:24];
                    4'd6:image_data = DATA_NUM[23:16];
					4'd7:image_data = DATA_NUM[15:8];       
                    4'd8:image_data = DATA_NUM[7:0];  
					4'd9:image_data = CMD;   
                    default:image_data = cam_data; 
                endcase
            end
            DATA_PACKET:image_data = cam_data;
            LAST_PACKET:begin
                if(cnt_data == h_num)
                    image_data = CRC[15:8];
				else if(cnt_data == h_num + 16'd1)
					image_data = CRC[7:0];
                else 
                    image_data = cam_data;
            end
            default:image_data = 8'h0;
        endcase
    end
end
//----------------------------ddr读fifo使能----------------------
// always @(posedge clk or negedge rst_n) begin
    // if(!rst_n)
        // rf_rd_en <= 1'b0;
    // else if(udp_data_valid && ((curr_state == HEAD_PACKET && cnt_data >= 11'd9) || curr_state == DATA_PACKET || (curr_state == LAST_PACKET && cnt_data < h_num - 1)))
        // rf_rd_en <= 1'b1;
    // else
        // rf_rd_en <= 1'b0;
// end
assign rf_rd_en = udp_data_valid && 
                  ( (curr_state == HEAD_PACKET && cnt_data > 11'd8 && cnt_data < 11'd1289) || 
                    (curr_state == DATA_PACKET && cnt_data < h_num - 11'd1) || 
                    (curr_state == LAST_PACKET && cnt_data < h_num - 11'd1) 
                  );
//----------------------------以太网开始传输信号----------------------
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        udp_tx_data_start <= 1'b0;
    else if((next_state == HEAD_PACKET || next_state == DATA_PACKET || next_state == LAST_PACKET) && (curr_state != next_state))
        udp_tx_data_start <= 1'b1;
    else
        udp_tx_data_start <= 1'b0;
end
//----------------------------一帧图像发送的个数----------------------
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_h <= 11'd0;
    else if(curr_state == IDLE)
        cnt_h <= 11'd0;
    else if(udp_tx_done)
        cnt_h <= cnt_h + 11'd1;
    else
        cnt_h <= cnt_h;
end
//----------------------------以太网单包发送数据个数----------------------
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        image_data_num <= 16'd0;
    else if(curr_state == HEAD_PACKET)
        image_data_num <= h_num + 16'd10;
    else if(curr_state == DATA_PACKET)
        image_data_num <= h_num;
    else if(curr_state == LAST_PACKET)
        image_data_num <= h_num + 16'd2;
    else
        image_data_num <= image_data_num;
end

endmodule
