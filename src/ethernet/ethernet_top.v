module ethernet_top(
	input	wire			clk				,
	input	wire			video_clk		,
	input	wire			rst_n			,
	input	wire            hs_reg			,
	input	wire            vs_reg			,
	input	wire 			de_reg			,
	input	wire	[23:0]  vout_data		,
	//
	input	wire			key_flag1		,
	//
	output	wire            udp_rx_en		,
	output	wire    [7:0]   udp_idata    	,
	//ethernet
	output	wire			mac_rx_clk		,
    input   wire	     	eth_rx_clk      ,//PHY芯片
    input   wire	     	eth_rx_valid    ,
    input   wire	[3:0]	eth_rx_data     ,
    output  wire	     	eth_tx_clk      ,
    output  wire	     	eth_tx_valid    ,
    output  wire	[3:0]	eth_tx_data          
 );

parameter	fpga_mac 	= 48'h11_22_33_44_55_66	;//源mac
parameter	fpga_ip  	= 32'hc0_a8_00_08		;//源ip--192.168.0.8
parameter	pc_mac   	= 48'hff_ff_ff_ff_ff_ff	;//目的mac，不知道pc的mac，以广播的形式发送
parameter	pc_ip    	= 32'hc0_a8_00_02		;//目的ip--192.168.0.2
parameter	source_port = 16'd1234				;//源端口
parameter	des_port    = 16'd5678			 	;//目的端口

parameter	FORMAT    =   8'h04     ;//图像格式 04:(RGB565)
parameter	H_PIXEL   =   16'd640   ;//行像素个数：1280
parameter	V_PIXEL   =   16'd480   ;//场像素个数：720				

//------------------------------ethernet-----------------------------
//arp_ctrl
wire            arp_tx_en;
wire            arp_tx_op;
//arp
wire            arp_rx_op  ;
wire            arp_rx_done;
wire            arp_tx_valid;
wire    [7:0]   arp_tx_data ;
wire            arp_rx_valid;
wire    [7:0]   arp_rx_data ;
//udp
wire    [7:0]   udp_tx_data ;
wire            udp_tx_valid;
wire    [15:0]  udp_odata   ;
wire            udp_data_valid;
wire            udp_rx_valid;
wire            udp_rx_data ;
// wire    [7:0]   udp_idata  ;
// wire            udp_rx_en  ;
wire            udp_rx_done;
wire    [15:0]  udp_tx_data_num ;
wire            image_format_end;
wire            udp_tx_done     ;
wire            udp_data_req    ;
wire            udp_tx_en       ;//udp开始信号
//rgmii 
wire            mac_tx_clk  ;
wire            mac_tx_valid;
wire    [7:0]   mac_tx_data ;
// wire            mac_rx_clk  ;

wire            mac_rx_valid;
wire    [7:0]   mac_rx_data ;
//protocol

//
wire    [47:0]  des_mac;
wire    [31:0]  des_ip ;

reg 			de_flag_de;
wire 			negedge_flag_de;
wire    		negedge_vs;
reg 	[10:0]	cnt_vs;
reg 			reg_vs;
wire 			reg_de;
wire	[7:0]	udp_cam_data;
wire			vs_vild;
wire			rf_rd_en;

reg                            hs;
reg                            vs;
reg 						   de;

reg                            hs_reg0;
reg                            vs_reg0;
reg 						   de_reg0;

reg 	[15:0]					udp_wr_data;

//================rgb888转rgb565=====================
always @(posedge video_clk or negedge rst_n) begin
    if (!rst_n) begin
        udp_wr_data <= 16'd0;
    end
    else
        udp_wr_data <= {vout_data[23:19], vout_data[15:10], vout_data[7:3]};
end
//
always @(posedge video_clk or negedge rst_n) begin
    if (!rst_n) begin
        hs <= 1'b0;
		vs <= 1'b0;
		de <= 1'b0;
		
        hs_reg0 <= 1'b0;
		vs_reg0 <= 1'b0;
		de_reg0 <= 1'b0;
    end
    else begin
        hs_reg0 <= hs_reg;
		vs_reg0 <= vs_reg;
		de_reg0 <= de_reg;
		hs <= hs_reg0;
		vs <= vs_reg0;
		de <= de_reg0;
    end
end

reg image_format_end_reg;
always @(posedge video_clk or negedge rst_n) begin
    if(!rst_n)
		image_format_end_reg <= 1'b0;
    else 
		image_format_end_reg <= image_format_end;
end


assign vs_vild = (image_format_end_reg) ? vs : 1'b0;

always @(posedge video_clk or negedge rst_n) begin
    if(!rst_n)
		reg_vs <= 1'b0;
    else 
		reg_vs <= vs_vild;
end

assign negedge_vs = (reg_vs && ~vs_vild) ? 1'b1 : 1'b0;

always @(posedge video_clk or negedge rst_n) begin
    if(!rst_n)
		cnt_vs <= 10'b0;
	else if(cnt_vs == 10'd10)
		cnt_vs <= cnt_vs;
    else if(negedge_vs)
		cnt_vs <= cnt_vs + 10'd1;
end

assign reg_de = (cnt_vs == 10'd10) ? de : 1'b0;

always @(posedge video_clk or negedge rst_n) begin
    if(!rst_n)
      de_flag_de <= 1'b0;
    else 
      de_flag_de <= reg_de;
end

assign negedge_flag_de = (de_flag_de && ~reg_de) ? 1 : 0;

eth_fifo eth_fifo_u(
  /*input            */.rst			(~rst_n || negedge_vs)	,
  /*input   [15:0]   */.di			(udp_wr_data)	,
  /*input            */.clkr		(mac_tx_clk)	,
  /*input            */.re			(rf_rd_en)	,
  /*input            */.clkw		(video_clk)	,
  /*input            */.we			(reg_de)	,
  /*output  [7:0]    */.dout		(udp_cam_data)	,
  /*output           */.empty_flag	()	,
  /*output           */.aempty		()	,
  /*output           */.full_flag	()	,
  /*output  [10:0]   */.rdusedw		()	,
  /*output  [9:0]    */.wrusedw		()	
);

//----------------------------arp-------------------------------------
arp_ctrl arp_ctrl_u(
    /*input   wire            */.clk           (mac_tx_clk )  ,
    /*input   wire            */.rst_n         (rst_n      )  ,
    /*input   wire            */.key           (key_flag1  )  ,
    /*input   wire            */.arp_rx_op     (arp_rx_op  )  ,
    /*input   wire            */.arp_rx_done   (arp_rx_done)  ,
    /*output  reg             */.arp_tx_en     (arp_tx_en  )  ,
    /*output  reg             */.arp_tx_op     (arp_tx_op  )   //1:请求包/0:应答包
    );

arp_top #(
	.fpga_mac (fpga_mac),//源mac
	.fpga_ip  (fpga_ip ),//源ip--192.168.0.8
	.pc_mac   (pc_mac  ),//目的mac，不知道pc的mac，以广播的形式发送
	.pc_ip    (pc_ip   ) //目的ip--192.168.0.2
)arp_top_u(
    /*input   wire            */.rst_n          (rst_n) ,
    //-------------------------tx-----------------------------                                 
    /*input   wire            */.arp_tx_clk     (mac_tx_clk) ,
    /*input   wire            */.arp_tx_en      (arp_tx_en) ,
    /*input   wire            */.arp_tx_op      (arp_tx_op) ,
    /*output  wire    [7:0]   */.arp_tx_data    (arp_tx_data ) ,
    /*output  wire            */.arp_tx_valid   (arp_tx_valid) ,
    //-------------------------rx-----------------------------                                 
    /*input   wire            */.arp_rx_clk     (mac_rx_clk  ) ,
    /*input   wire            */.arp_rx_valid   (mac_rx_valid) ,
    /*input   wire    [7:0]   */.arp_rx_data    (mac_rx_data ) ,
    /*output  reg     [47:0]  */.des_mac        (des_mac) ,
    /*output  reg     [31:0]  */.des_ip         (des_ip ) ,
    /*output  wire            */.arp_rx_op      (arp_rx_op  ) ,
    /*output  wire            */.arp_rx_done    (arp_rx_done)  
    );
    
//----------------------------udp-------------------------------------
udp_top #(
	.fpga_mac 	 (fpga_mac 	 ),//源mac
	.fpga_ip  	 (fpga_ip  	 ),//源ip--192.168.0.8
	.source_port (source_port),//源端口
	.des_port    (des_port   ) //目的端口
)udp_top_u(
    /*input   wire            */.rst_n           (rst_n),
    //-------------tx---------------------  
    /*input   wire            */.udp_tx_en       (udp_tx_en),//udp开始信号
    /*input   wire    [7:0]   */.udp_odata       (udp_odata),//udp发送的数据
    /*input   wire    [47:0]  */.des_mac         (des_mac),
    /*input   wire    [31:0]  */.des_ip          (des_ip ),
    /*input   wire    [10:0]  */.udp_tx_data_num (udp_tx_data_num),//udp发送数据的个数
    /*output  wire            */.udp_data_valid  (udp_data_valid ),//udp数据有效信号
    /*output  wire            */.udp_tx_done     (udp_tx_done    ),//udp结束信号
    //rgmii                                 
    /*input   wire            */.udp_tx_clk      (mac_tx_clk),
    /*output  reg     [7:0]   */.udp_tx_data     (udp_tx_data ),//udp数据包：ip首部、udp首部、udp数据
    /*output  reg             */.udp_tx_valid    (udp_tx_valid),//udp数据包有效信号
    //-------------rx---------------------  
    /*output  reg     [7:0]   */.udp_idata       (udp_idata  ),//udp接收的数据
    /*output  reg             */.udp_rx_en       (udp_rx_en  ),
    /*output  wire            */.udp_rx_done     (udp_rx_done),
    //rgmii                                 
    /*input   wire            */.udp_rx_clk      (mac_rx_clk  ),
    /*input   wire            */.udp_rx_valid    (mac_rx_valid),
    /*input   wire    [7:0]   */.udp_rx_data     (mac_rx_data )
    );
//------------------------------协议控制--------------------------------
protocol_ctrl #(
	.FORMAT   (FORMAT ),//图像格式 04:(RGB565)
    .H_PIXEL  (H_PIXEL),//行像素个数：1280
    .V_PIXEL  (V_PIXEL)//场像素个数：720
)protocol_ctrl_u(
    /*input   wire            */.rst_n           (rst_n) ,
    /*input   wire    [7:0]   */.cam_data        (udp_cam_data) ,//摄像头数据
    /*input   wire            */.rf_rd_req       (negedge_flag_de  ) ,//读fifo不为空信号
    /*output  reg             */.rf_rd_en        (rf_rd_en    ) ,//读fifo使能
    //arp                                   
    /*input   wire            */.arp_tx_valid    (arp_tx_valid) ,
    /*input   wire            */.arp_tx_en       (arp_tx_en   ) ,
    /*input   wire            */.arp_rx_op       (arp_rx_op   ) ,
    /*input   wire            */.arp_rx_done     (arp_rx_done ) ,
    /*input   wire    [7:0]   */.arp_tx_data     (arp_tx_data ) ,
    //udp                                   
    /*input   wire    [7:0]   */.udp_tx_data     (udp_tx_data ) ,
    /*input   wire            */.udp_tx_valid    (udp_tx_valid) ,
    /*input   wire            */.udp_tx_done     (udp_tx_done ) ,
	/*input   wire            */.udp_data_valid  (udp_data_valid),//udp数据有效信号
    /*output  wire    [7:0]   */.udp_odata       (udp_odata) ,//udp发送的数据
    /*output  wire            */.udp_tx_en       (udp_tx_en) ,//以太网传输数据开始信号
    /*output  wire    [15:0]  */.udp_tx_data_num (udp_tx_data_num) ,
	/*output  wire            */.image_format_end(image_format_end),//图像数据格式结束信号
    //rgmii                                 
    /*input   wire            */.clk             (mac_tx_clk  ) ,
    /*output  wire            */.mac_tx_valid    (mac_tx_valid) ,
    /*output  wire    [7:0]   */.mac_tx_data     (mac_tx_data ) 
    );

wire	clk_125_out;
wire	temac_clk90;
wire	gmii_txc_en;
wire	rgmii_txc_en;
wire	rgmii_txc_en_shift;
wire    rx_rgmii_clk ;
assign mac_tx_clk = clk_125_out;
assign mac_rx_clk = rx_rgmii_clk;
clk_gen_rst_gen clk_gen_rst_gen_u(
    .reset                             (~rst_n                    ),
    .clk_in                            (clk                       ),
    .rst_out                           (reset_reg                 ),
    .clk_125_out0                      (temac_clk                 ),
    .clk_125_out1                      (clk_125_out               ),
    .clk_125_out2                      (temac_clk90               ),
    .clk_12_5_out                      (clk_12_5_out              ),
    .clk_1_25_out                      (clk_1_25_out              ),
    .clk_25_out                        (clk_50_out                ) 
);
	
tx_clk_en_gen tx_clk_en_gen_(
    .reset                             (1'b0                      ),//tx_reset
    .speed_10_100                      (1'b0                      ),
    .speed_100                         (1'b0                      ),
    .clk                               (clk_125_out               ),//gtx_clk/tx_clk：  125mHZ
    .client_txc_en                     (                          ),//tx_clk_en
    .gmii_txc_en                       (gmii_txc_en               ),
    .rgmii_txc_en                      (rgmii_txc_en              ),
    .rgmii_txc_en_shift                (rgmii_txc_en_shift        ) 
   );

rgmii_interface rgmii_interface_u(
    /*input            */.tx_reset          (1'b0),
    /*input            */.rx_reset          (1'b0),
    /*input            */.speed_10_100      (1'b0),
	//rgmii接收到PHY芯片
    /*output           */.rgmii_txc         (eth_tx_clk  ),              //
    /*output           */.rgmii_tx_ctl      (eth_tx_valid),              //
    /*output     [3:0] */.rgmii_txd         (eth_tx_data ),              //
    /*input            */.rgmii_rxc         (eth_rx_clk  ),              //	
    /*input            */.rgmii_rx_ctl      (eth_rx_valid),              //
    /*input      [3:0] */.rgmii_rxd         (eth_rx_data ),              //
	//FPGA发送到rgmii
    /*input      [7:0] */.gmii_txd          (mac_tx_data ),              //
    /*input            */.gmii_tx_en        (mac_tx_valid),              //
	/*output     [7:0] */.gmii_rxd          (mac_rx_data ),              //
    /*output           */.gmii_rx_dv        (mac_rx_valid),              //
	
    /*input            */.gmii_tx_er        (1'b0),
	/*output           */.gmii_rx_er        (),                    
    /*output           */.gmii_crs          (),
    /*output           */.gmii_col          (),
	
    /*output reg       */.link_status       (),
    /*output reg [1:0] */.clock_speed       (),
    /*output reg       */.duplex_status     (),

    /*input            */.tx_clk            (clk_125_out),          // gtx_clk: 125mhz
    /*input            */.tx_clk_90         (temac_clk90),
    /*input            */.rgmii_txc_en      (rgmii_txc_en),
	/*input            */.gmii_txc_en       (gmii_txc_en ),          
    /*input            */.rgmii_txc_en_shift(rgmii_txc_en_shift),
    /*output           */.rx_rgmii_clk      (rx_rgmii_clk)          //output： 125mhz（1gbps） 25mhz(100mbps)    2.5mhz(10mbps)
  );
endmodule
