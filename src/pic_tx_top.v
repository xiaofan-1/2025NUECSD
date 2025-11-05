module pic_tx_top(
	input	wire			rst_n			,
	input   wire            mac_rx_clk      ,
	input	wire			video_clk  		,
	input   wire    [7:0]   udp_idata       ,
    input   wire            udp_rx_en       ,
	output	wire            hs				,
	output	wire            vs				,
	output	wire 			de				,
	output	wire	[23:0]	vout_data
 );
// wire                            hs;
// wire                            vs;
// wire 						    de;
wire  [11:0] pic_x;
wire  [11:0] pic_y;
wire	[15:0]	pic_data;

pic_data pic_data_u(
    /*input   wire            */.rgmii_clk      (mac_rx_clk) ,
    /*input   wire            */.hdmi_clk       (video_clk   ) ,
    /*input   wire            */.rst_n          (rst_n) ,
                            
    /*input   wire    [7:0]   */.udp_rx_data    (udp_idata  ) ,
    /*input   wire            */.udp_rx_en      (udp_rx_en  ) ,
    /*input   wire            */.de             (de         ) ,
                                  
    /*input   wire    [10:0]  */.pic_x          (pic_x) ,
    /*input   wire    [10:0]  */.pic_y          (pic_y) ,
                                
    /*output  wire    [15:0]  */.pic_data       (pic_data)
    );
	
video_delay video_delay_m0(
    .video_clk                  (video_clk                ),
	.rst                        (~rst_n    				  ),
    .read_data					(pic_data	  			  ),
    .hs                         (hs                       ),
	.vs                         (vs                       ),
	.de                         (de                       ),
	.vout_data					(vout_data				  ),
	.pic_x						(pic_x					  ),
    .pic_y						(pic_y					  )
);

endmodule
