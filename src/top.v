`timescale 1ns / 1ps

module top(
	input	wire			clk				,
	input	wire			rst_n			,
	//HDMI
	output	wire			HDMI_CLK_P		,
	output	wire			HDMI_D2_P		,
	output	wire			HDMI_D1_P		,
	output	wire			HDMI_D0_P		,
	//key
	input	wire			key2			,
	input	wire			key3			,
	input	wire			key4			,	
	//
	input	wire			sw1				,
	input	wire			sw2				,
	input	wire			sw3				,
	input	wire			sw4				,
	//
	output	wire	[3:0]	led				,
    output  wire    [6:0]   seg             ,
    output  wire    [7:0]   sel             ,
	//cam                      
    input	wire			cam_pclk     	,  //cmos 数据像素时钟
    input	wire			cam_vsync    	,  //cmos 场同步信号
    input	wire			cam_href     	,  //cmos 行同步信号
    input	wire	[7:0]	cam_data     	,  //cmos 数据
    output	wire			cam_rst_n    	,  //cmos 复位信号，低电平有效
    output	wire			cam_pwdn     	,  //电源休眠模式选择 0：正常模式 1：电源休眠模式
    output	wire			cam_scl      	,  //cmos SCCB_SCL线
    inout	wire			cam_sda      	,  //cmos SCCB_SDA线   
    //ethernet
    input   wire	     	eth_rx_clk      ,//PHY芯片
    input   wire	     	eth_rx_valid    ,
    input   wire	[3:0]	eth_rx_data     ,
    output  wire	     	eth_tx_clk      ,
    output  wire	     	eth_tx_valid    ,
    output  wire	[3:0]	eth_tx_data 
);

wire                            hs;
wire                            vs;
wire 							de;

wire							hs_video;
wire							vs_video;
wire							de_video;

wire							hs_pic;
wire							vs_pic;
wire							de_pic;

wire 	[23:0]					color_data;
wire	[23:0]					vout_data;
wire	[23:0]					data_o_eth;

wire			mac_rx_clk;
wire 	[23:0]	hdmi_data;

wire    [7:0]   udp_idata  ;
wire            udp_rx_en  ;

wire			key_value;
reg		[27:0]	cnt_key;
wire            key_flag2;
wire            key_flag3;
wire            key_flag4;

reg 			eth_key;

wire                            ext_mem_clk;       //external memory clock
wire                            ext_mem_clk_sft;
wire                            video_clk;         //video pixel clock
wire							hdmi_5x_clk;

assign 	hs = sw3 ? (sw4 ? hs_video : hs_pic) : 1'b0;
assign 	vs = sw3 ? (sw4 ? vs_video : vs_pic) : 1'b0;
assign 	de = sw3 ? (sw4 ? de_video : de_pic) : 1'b0;
assign  hdmi_data = sw3 ? (sw4 ? color_data : vout_data) : 24'h0;

//always @(posedge mac_rx_clk or negedge rst_n) begin
//	if(!rst_n)
//		led <= 4'd0;
//	else if(sw3 == 0)
//		led <= udp_idata[3:0];
//	else
//		led <= 4'd0;
//end

seg_led_ctrl seg_led_ctrl_u(
    /*input   wire    		    */.clk      (mac_rx_clk),
    /*input   wire    		    */.rst_n    (rst_n),
    /*input   wire    [ 7:0]    */.eth_data (udp_idata),
    /*input   wire    		    */.flag     (sw3),
    /*output  reg     [ 6:0]  	*/.seg      (seg),
    /*output  reg     [ 7:0]  	*/.sel      (sel),
    /*output  reg     [ 3:0]  	*/.led      (led)
 );


always @(posedge mac_rx_clk or negedge rst_n) begin
	if(!rst_n) begin
		eth_key <= 1'b0;
		cnt_key <= 28'd0;
	end
	else if(key_value == 0) begin
		if(cnt_key == 100_000_000 - 1) begin
			eth_key <= 1'b1;
			cnt_key <= 28'd0;
		end
		else begin
			eth_key <= 1'b0;
			cnt_key <= cnt_key + 1;
		end
	end
	else begin
		eth_key <= 1'b0;
		cnt_key <= 28'd0;
	end
end


//=========================sdram_clk========================
sys_pll sys_pll_m0(
	.refclk                     (clk),
	.clk0_out                   (ext_mem_clk	),
	.clk1_out                   (ext_mem_clk_sft),
    .reset						(1'b0)
    );
//=========================HDMI_clk========================
video_pll video_pll_m0(
	.refclk                     (clk),
	.clk0_out                   (video_clk  ),
    .clk1_out					(hdmi_5x_clk),
    .reset						(1'b0)
	);

//==========================key===============================
key_flag key_flag_2(
    .clk                               (video_clk                 ),
    .rst_n                             (rst_n                     ),
    .key                               (key2                      ),
    .key_flag                          (key_flag2                 ),
    .key_value                         (key_value                 ) 
);

key_flag key_flag_3(
    .clk                               (video_clk                 ),
    .rst_n                             (rst_n                     ),
    .key                               (key3                      ),
    .key_flag                          (key_flag3                 ),
    .key_value                         (                          ) 
);

key_flag key_flag_4(
    .clk                               (video_clk                 ),
    .rst_n                             (rst_n                     ),
    .key                               (key4                      ),
    .key_flag                          (key_flag4                 ),
    .key_value                         (                          ) 
);

//===========================HDMI_display=================================
hdmi_tx #(
	 .FAMILY("EG4")//EF2、EF3、EG4、AL3、PH1
)u3_hdmi_tx(
		 .PXLCLK_I(video_clk),
		 .PXLCLK_5X_I(hdmi_5x_clk),

		 .RST_N (rst_n),
		 .VGA_HS (hs),
		 .VGA_VS (vs),
		 .VGA_DE (de),
		 .VGA_RGB(hdmi_data),

		 // HDMI
		 .HDMI_CLK_P(HDMI_CLK_P),
		 .HDMI_D2_P (HDMI_D2_P ),
		 .HDMI_D1_P (HDMI_D1_P ),
		 .HDMI_D0_P (HDMI_D0_P )	
	 );

//============================eth_to_pic=======================
pic_tx_top pic_tx_top_u(
	/*input		wire			*/.rst_n		(rst_n	),
	/*input   	wire            */.mac_rx_clk   (mac_rx_clk),
	/*input		wire			*/.video_clk  	(video_clk),
	/*input   	wire    [7:0]   */.udp_idata    (udp_idata),
    /*input   	wire            */.udp_rx_en    (udp_rx_en),
	/*output	wire            */.hs			(hs_pic)	,
	/*output	wire            */.vs			(vs_pic)	,
	/*output	wire 			*/.de			(de_pic)	,
	/*output	wire	[23:0]	*/.vout_data    (vout_data)
 );

//============================cam_data=============================
video_top video_top_u(
	/*input	wire			*/.clk				(clk			),
	/*input	wire			*/.rst_n			(rst_n),
	/*input	wire            */.ext_mem_clk		(ext_mem_clk	),       //external memory clock
	/*input	wire            */.ext_mem_clk_sft	(ext_mem_clk_sft),
	/*input	wire			*/.video_clk  		(video_clk  	),
	/*input	wire			*/.hdmi_5x_clk		(hdmi_5x_clk	),
	/*//key					*/
	/*input	wire			*/.key2_flag		(key_flag2		),
	/*input	wire			*/.key3_flag		(key_flag3		),
	/*input	wire			*/.key4_flag		(key_flag4		),
	/*//cam                 */            
    /*input	wire			*/.cam_pclk     	(cam_pclk     	),  //cmos 数据像素时钟
    /*input	wire			*/.cam_vsync    	(cam_vsync    	),  //cmos 场同步信号
    /*input	wire			*/.cam_href     	(cam_href     	),  //cmos 行同步信号
    /*input	wire	[7:0]	*/.cam_data     	(cam_data     	),  //cmos 数据
    /*output	wire		*/.cam_rst_n    	(cam_rst_n    	),  //cmos 复位信号，低电平有效
    /*output	wire		*/.cam_pwdn     	(cam_pwdn     	),  //电源休眠模式选择 0：正常模式 1：电源休眠模式
    /*output	wire		*/.cam_scl      	(cam_scl      	),  //cmos SCCB_SCL线
    /*inout	wire			*/.cam_sda      	(cam_sda      	),  //cmos SCCB_SDA线  
	/*//                    */                 
	/*output	wire		*/.hsync_o			(hs_video),
	/*output	wire		*/.vsync_o	        (vs_video),
	/*output	wire		*/.de_o   	        (de_video),
	/*output	wire	[23:0]	*/.data_o_eth	(data_o_eth)	,
	/*output	wire      	*/.color_data       (color_data)
 );

//=============================ethernet_ctrl===========================
ethernet_top ethernet_top_u(
	/*input		wire			*/.clk				(clk		 ),
	/*input		wire			*/.video_clk		(video_clk	 ),
	/*input		wire			*/.rst_n			(rst_n),
	/*input		wire            */.hs_reg			(hs	 ),
	/*input		wire            */.vs_reg			(vs	 ),
	/*input		wire 			*/.de_reg			(de	 ),
	/*input		wire	[23:0]  */.vout_data		(data_o_eth	 ),
	//	                                                         
	/*input		wire			*/.key_flag1		(eth_key   ),
	//	                                                         
	/*output	wire            */.udp_rx_en		(udp_rx_en	 ),
	/*output	wire    [7:0]   */.udp_idata 		(udp_idata   ),
	//ethernet                                   
	/*output	wire			*/.mac_rx_clk		(mac_rx_clk),
    /*input   	wire	     	*/.eth_rx_clk      	(eth_rx_clk  ),//PHY芯片
    /*input   	wire	     	*/.eth_rx_valid    	(eth_rx_valid),
    /*input   	wire	[3:0]	*/.eth_rx_data     	(eth_rx_data ),
    /*output  	wire	     	*/.eth_tx_clk      	(eth_tx_clk  ),
    /*output  	wire	     	*/.eth_tx_valid    	(eth_tx_valid),
    /*output  	wire	[3:0]	*/.eth_tx_data      (eth_tx_data )    
 );
endmodule 