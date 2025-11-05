module video_delay
#(
	parameter DATA_WIDTH = 16                       // Video data one clock data width
)
(
	input                       video_clk,          // Video pixel clock
	input                       rst,
	output                      read_en,            // Read data enable
	input[DATA_WIDTH - 1:0]     read_data,          // Read data

	output                      hs,                 // horizontal synchronization
	output                      vs,                 // vertical synchronization
	output                      de,                 // video valid
	output	[24:0]    			vout_data,           // video data
	output  wire [11:0]         pic_x,
    output  wire [11:0]         pic_y

);
reg [20:0] hs_d;
reg [20:0] vs_d;
reg [20:0] de_d;

wire                   video_hs;
wire                   video_vs;
wire                   video_de;

wire [11:0]         pic_x_reg;
wire [11:0]         pic_y_reg;

reg  [11:0]         pic_x_reg0;
reg  [11:0]         pic_y_reg0;

reg[DATA_WIDTH - 1:0]  vout_data_r;

wire [7:0] cam_R,cam_G,cam_B;
wire	[15:0] cam_write_data;
assign cam_R = {cam_write_data[15:11],{3{cam_write_data[11]}}};
assign cam_G = {cam_write_data[10:5] ,{2{cam_write_data[5]}}};
assign cam_B = {cam_write_data[4:0]  ,{3{cam_write_data[0]}}};
assign vout_data = {cam_R,cam_G,cam_B};//cmos_wr_data_d1 to 888

wire	pixel_vlid;

assign pixel_vlid = read_en;

assign read_en = de_d[19];
assign hs = hs_d[20];
assign vs = vs_d[20];
assign de = de_d[20];
assign cam_write_data = vout_data_r;

assign pic_x = pic_x_reg0;
assign pic_y = pic_y_reg0;

//数据
always@(posedge video_clk or posedge rst)
begin
	if(rst == 1'b1)
		vout_data_r <= {DATA_WIDTH{1'b0}};
	else if(de_d[19])
		vout_data_r <= read_data;
	else
		vout_data_r <= {DATA_WIDTH{1'b0}};
end

//-----------------pic_x----------------------
always@(posedge video_clk or posedge rst) begin
	if(rst == 1'b1)
		pic_x_reg0 <= 12'd0;
    else if(de_d[19]) begin
        if(pic_x_reg0 == 639)
            pic_x_reg0 <= 12'd0;
        else
            pic_x_reg0 <= pic_x_reg0 + 12'd1;
    end
end

//------------------pic_y---------------------
always@(posedge video_clk or posedge rst) begin
	if(rst == 1'b1)
		pic_y_reg0 <= 12'd0;
	else if(pic_x_reg0 == 639 && de_d[19]) begin
	   if(de_d[19] && pic_x_reg0 == 639 && pic_y_reg0 == 479)
	       pic_y_reg0 <= 12'd0;
	   else
	       pic_y_reg0 <= pic_y_reg0 + 12'd1;
	end
end

//
always @(posedge video_clk or posedge rst)begin
	if(rst)begin
    	hs_d <= 20'b0;
        vs_d <= 20'b0;
        de_d <= 20'b0;
    end
	else begin
    	
    	hs_d <= {hs_d[19:0],video_hs};
        vs_d <= {vs_d[19:0],video_vs};
        de_d <= {de_d[19:0],video_de};
    end
end

color_bar color_bar_m0(
	.clk(video_clk),
	.rst(rst),
	.hs(video_hs),
	.vs(video_vs),
	.de(video_de),
	.pic_x(pic_x_reg),
	.pic_y(pic_y_reg),
	.rgb_r(),
	.rgb_g(),
	.rgb_b()
);

endmodule
