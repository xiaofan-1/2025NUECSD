`timescale 1ns / 1ps

module image_color(
    input	wire			clk						,  			
	input	wire			rst_n					,			
			
    input   wire        	hsync_i     			,//行信号
    input   wire        	vsync_i     			,//场信号
    input   wire        	de_i        			,
    input   wire 	[23:0] 	data_i      			,//
			
	input	wire			key2_flag				,
	input	wire			key3_flag				,
	input	wire			key4_flag				,
	
	input	wire 	[10:0]  pixel_x					,
	input	wire 	[10:0]	pixel_y					,
	
	input   wire 	[11:0] 	x_min_move			    ,
    input   wire 	[11:0] 	x_max_move			    ,
    input   wire 	[11:0] 	y_min_move			    ,
    input   wire 	[11:0] 	y_max_move			    ,
	
    output  wire 	       	hsync_o     			,
    output  wire 	       	vsync_o     			,
    output  wire 	       	de_o        			,
	output  reg  	[23:0] 	data_o_eth				,      			 
	output  reg  	[23:0] 	data_o      			 //
    );
	
wire	[2:0]	color_threshold_select	;
wire	[2:0]	color_threshold_select_eth	;
	
reg		[23:0]	rgb_data_reg;
reg		[23:0]	rgb_data_reg0;
reg		[23:0]	rgb_data_reg1;
reg		[23:0]	rgb_data_reg2;
reg		[23:0]	rgb_data_reg3;
reg		[23:0]	rgb_data_reg4;
reg		[23:0]	rgb_data_reg5;
reg		[23:0]	rgb_data_reg6;
reg		[23:0]	rgb_data_reg7;
reg		[23:0]	rgb_data_reg8;
reg		[23:0]	rgb_data_reg9;
reg		[23:0]	rgb_data_reg10;
reg		[23:0]	rgb_data_reg11;	
reg		[23:0]	rgb_data_reg12;
reg		[23:0]	rgb_data_reg13;
reg		[23:0]	rgb_data_reg14;
reg		[23:0]	rgb_data_reg15;
reg		[23:0]	rgb_data_reg16;

reg		[11:0]	pixle_x_reg;
reg		[11:0]	pixle_y_reg;
reg		[11:0]	pixle_x_reg0;
reg		[11:0]	pixle_y_reg0;
reg		[11:0]	pixle_x_reg1;
reg		[11:0]	pixle_y_reg1;
reg		[11:0]	pixle_x_reg2;
reg		[11:0]	pixle_y_reg2;
reg		[11:0]	pixle_x_reg3;
reg		[11:0]	pixle_y_reg3;
reg		[11:0]	pixle_x_reg4;
reg		[11:0]	pixle_y_reg4;
reg		[11:0]	pixle_x_reg5;
reg		[11:0]	pixle_y_reg5;
reg		[11:0]	pixle_x_reg6;
reg		[11:0]	pixle_y_reg6;
reg		[11:0]	pixle_x_reg7;
reg		[11:0]	pixle_y_reg7;
reg		[11:0]	pixle_x_reg8;
reg		[11:0]	pixle_y_reg8;
reg		[11:0]	pixle_x_reg9;
reg		[11:0]	pixle_y_reg9;
reg		[11:0]	pixle_x_reg10;
reg		[11:0]	pixle_y_reg10;
reg		[11:0]	pixle_x_reg11;
reg		[11:0]	pixle_y_reg11;	
reg		[11:0]	pixle_x_reg12;
reg		[11:0]	pixle_y_reg12;	
reg		[11:0]	pixle_x_reg13;
reg		[11:0]	pixle_y_reg13;	
reg		[11:0]	pixle_x_reg14;
reg		[11:0]	pixle_y_reg14;	
reg		[11:0]	pixle_x_reg15;
reg		[11:0]	pixle_y_reg15;	
reg		[11:0]	pixle_x_reg16;
reg		[11:0]	pixle_y_reg16;		
reg		[11:0]	pixle_x_reg17;
reg		[11:0]	pixle_y_reg17;	

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rgb_data_reg  <= 24'h0;
		rgb_data_reg0 <= 24'h0;
		rgb_data_reg1 <= 24'h0;
		rgb_data_reg2 <= 24'h0;
		rgb_data_reg3 <= 24'h0;
		rgb_data_reg4 <= 24'h0;
		rgb_data_reg5 <= 24'h0;
		rgb_data_reg6 <= 24'h0;
		rgb_data_reg7 <= 24'h0;
		rgb_data_reg8 <= 24'h0;
		rgb_data_reg9 <= 24'h0;
		rgb_data_reg10 <= 24'h0;	
		rgb_data_reg11 <= 24'h0;	
		rgb_data_reg12 <= 24'h0;
		rgb_data_reg13 <= 24'h0;
		rgb_data_reg14 <= 24'h0;
		rgb_data_reg15 <= 24'h0;
		rgb_data_reg16 <= 24'h0;
		
		pixle_x_reg   <= 12'd0;
		pixle_y_reg   <= 12'd0;
		pixle_x_reg0  <= 12'd0;
		pixle_y_reg0  <= 12'd0;
		pixle_x_reg1  <= 12'd0;
		pixle_y_reg1  <= 12'd0;
		pixle_x_reg2  <= 12'd0;
		pixle_y_reg2  <= 12'd0;
		pixle_x_reg3  <= 12'd0;
		pixle_y_reg3  <= 12'd0;
		pixle_x_reg4  <= 12'd0;
		pixle_y_reg4  <= 12'd0;
		pixle_x_reg5  <= 12'd0;
		pixle_y_reg5  <= 12'd0;
		pixle_x_reg6  <= 12'd0;
		pixle_y_reg6  <= 12'd0;
		pixle_x_reg7  <= 12'd0;
		pixle_y_reg7  <= 12'd0;
		pixle_x_reg8  <= 12'd0;
		pixle_y_reg8  <= 12'd0;
		pixle_x_reg9  <= 12'd0;
		pixle_y_reg9  <= 12'd0;
		pixle_x_reg10  <= 12'd0;
		pixle_y_reg10  <= 12'd0;	
		pixle_x_reg11  <= 12'd0;
		pixle_y_reg11  <= 12'd0;	
		pixle_x_reg12  <= 12'd0;
		pixle_y_reg12  <= 12'd0;	
		pixle_x_reg13  <= 12'd0;
		pixle_y_reg13  <= 12'd0;	
		pixle_x_reg14  <= 12'd0;
		pixle_y_reg14  <= 12'd0;	
		pixle_x_reg15  <= 12'd0;
		pixle_y_reg15  <= 12'd0;	
		pixle_x_reg16  <= 12'd0;
		pixle_y_reg16  <= 12'd0;
		pixle_x_reg17  <= 12'd0;
		pixle_y_reg17  <= 12'd0;
		
	end
	else begin
		rgb_data_reg0 <= data_i;
		rgb_data_reg1 <= rgb_data_reg0;
		rgb_data_reg2 <= rgb_data_reg1;
		rgb_data_reg3 <= rgb_data_reg2;
		rgb_data_reg4 <= rgb_data_reg3;
		rgb_data_reg5 <= rgb_data_reg4;
		rgb_data_reg6 <= rgb_data_reg5;
		rgb_data_reg7 <= rgb_data_reg6;
		rgb_data_reg8 <= rgb_data_reg7 ;
		rgb_data_reg9 <= rgb_data_reg8 ;
		rgb_data_reg10 <=rgb_data_reg9 ;
		rgb_data_reg11 <=rgb_data_reg10;
		rgb_data_reg12 <= rgb_data_reg11;
		rgb_data_reg13 <= rgb_data_reg12;
		rgb_data_reg14 <= rgb_data_reg13;
		rgb_data_reg15 <= rgb_data_reg14;
		rgb_data_reg  <=  rgb_data_reg11;
		
		
		pixle_x_reg0  <= pixel_x;
		pixle_y_reg0  <= pixel_y;
		pixle_x_reg1  <= pixle_x_reg0;
		pixle_y_reg1  <= pixle_y_reg0;
		pixle_x_reg2  <= pixle_x_reg1;
		pixle_y_reg2  <= pixle_y_reg1;
		pixle_x_reg3  <= pixle_x_reg2;
		pixle_y_reg3  <= pixle_y_reg2;
		pixle_x_reg4  <= pixle_x_reg3;
		pixle_y_reg4  <= pixle_y_reg3;
		pixle_x_reg5  <= pixle_x_reg4;
		pixle_y_reg5  <= pixle_y_reg4;
		pixle_x_reg6  <= pixle_x_reg5;
		pixle_y_reg6  <= pixle_y_reg5;
		pixle_x_reg7  <= pixle_x_reg6;
		pixle_y_reg7  <= pixle_y_reg6;
		pixle_x_reg8  <= pixle_x_reg7 ;
		pixle_y_reg8  <= pixle_y_reg7 ;
		pixle_x_reg9  <= pixle_x_reg8 ;
		pixle_y_reg9  <= pixle_y_reg8 ;
		pixle_x_reg10 <= pixle_x_reg9 ;
		pixle_y_reg10 <= pixle_y_reg9 ;
		pixle_x_reg11 <= pixle_x_reg10;
		pixle_y_reg11 <= pixle_y_reg10;	
		pixle_x_reg12  <= pixle_x_reg11;
		pixle_y_reg12  <= pixle_y_reg11;
		pixle_x_reg13  <= pixle_x_reg12;
		pixle_y_reg13  <= pixle_y_reg12;
		pixle_x_reg14  <= pixle_x_reg13;
		pixle_y_reg14  <= pixle_y_reg13;
		pixle_x_reg15  <= pixle_x_reg14;
		pixle_y_reg15  <= pixle_y_reg14;
		pixle_x_reg16  <= pixle_x_reg15;
		pixle_y_reg16  <= pixle_y_reg15;
		pixle_x_reg17  <= pixle_x_reg16;
		pixle_y_reg17  <= pixle_y_reg16;
		pixle_x_reg    <= pixle_x_reg11;
		pixle_y_reg    <= pixle_y_reg11;
	end
end

// colour_extract_ctrl入口选择参数
reg	[2:0]	SELECT_BIT	;
reg	[8:0]	ADD_VALUE	;
reg	[7:0]	THRESHOLD	;

// colour_extract_ctrl入口颜色寄存参数
reg	[8:0]	ADD_VALUE_GREEN ;
reg	[8:0]	ADD_VALUE_RED	;
reg	[8:0]	ADD_VALUE_BLUE	;
reg	[8:0]	ADD_VALUE_BLACK	;
reg	[7:0]	THRESHOLD_GREEN ;
reg	[7:0]	THRESHOLD_RED	;
reg	[7:0]	THRESHOLD_BLUE	;
reg	[7:0]	THRESHOLD_BLACK	;

wire        	hs_reg;
wire        	vs_reg;
wire        	de_reg;
wire	[7:0]	data_color;

localparam pix_h = 640,
           pix_v = 480;
               
reg  [11:0]  x,y;
wire add_x = de_reg;
wire end_x = add_x && x == pix_h - 1;
wire add_y = end_x;
wire end_y = add_y && y == pix_v - 1;

reg  [11:0] x_min_r;
reg  [11:0] x_max_r;
reg  [11:0] y_min_r;
reg  [11:0] y_max_r;

//==============行计数器====================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        x <= 0;
    else if (add_x)
        x <= end_x ? 0 : x + 1;
end

//==============列计数器====================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        y <= 0;
    else if (add_y)
        y <= end_y ? 0 : y + 1;
end

reg vsync_reg0, vsync_reg1;
// =============提取同步信号边沿============
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        vsync_reg0 <= 0;
        vsync_reg1 <= 0;
    end else begin
        vsync_reg0 <= vs_reg;
        vsync_reg1 <= vsync_reg0;
    end
end

wire pos_vsync = (vsync_reg0 && ~vsync_reg1);
wire neg_vsync = (~vsync_reg0 && vsync_reg1);

// 边界检测（边缘像素即有效像素）
// assign pixel_valid = (data_color == 8'h0 && x > x_min_move && x < x_max_move && y > y_min_move && y < y_max_move);

assign pixel_valid = (data_color == 8'h0 && x > 5 && x < 634 && y > 5 && y < 474);
// 记录边界（极值法）
reg [10:0] x_min, x_max, y_min, y_max;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n || pos_vsync)
        x_min <= pix_h;
    else if (pixel_valid && x < x_min)
        x_min <= x;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n || pos_vsync)
        x_max <= 0;
    else if (pixel_valid && x > x_max)
        x_max <= x;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n || pos_vsync)
        y_min <= pix_v;
    else if (pixel_valid && y < y_min)
        y_min <= y;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n || pos_vsync)
        y_max <= 0;
    else if (pixel_valid && y > y_max)
        y_max <= y;
end

// =============锁存边界到下一帧=============
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        x_min_r <= 0; 
        x_max_r <= 0;
        y_min_r <= 0; 
        y_max_r <= 0;
    end 
    else if (neg_vsync) begin
        if (x_min < x_max && y_min < y_max) begin
            x_min_r <= x_min;
            x_max_r <= x_max;
            y_min_r <= y_min;
            y_max_r <= y_max;
        end
    end
end

wire	[23:0]	font_rom_data;
wire	[23:0]	font_rom_data_eth;
wire	[23:0]	char_data;

font_rom font_rom_u(
	/*input		wire			*/.clk			(clk					),
	/*input		wire			*/.rst_n		(rst_n					),
	/*input		wire 	[10:0]  */.pixel_x		(pixle_x_reg9			),
	/*input		wire 	[10:0]	*/.pixel_y		(pixle_y_reg9			),
	/*input		wire			*/.de			(de_reg					),
	/*input		wire			*/.key			(key2_flag				),
	/*output	wire	[2:0]	*/.color_select	(color_threshold_select_eth	),
    /*output 	reg  	[23:0] 	*/.data_o		(font_rom_data_eth			)	
);

font_rom_eth font_rom_eth_u(
	/*input		wire			*/.clk			(clk					),
	/*input		wire			*/.rst_n		(rst_n					),
	/*input		wire 	[10:0]  */.pixel_x		(pixle_x_reg9			),
	/*input		wire 	[10:0]	*/.pixel_y		(pixle_y_reg9			),
	/*input		wire			*/.de			(de_reg					),
	/*input		wire			*/.key			(key2_flag				),
	/*output	wire	[2:0]	*/.color_select	(color_threshold_select	),
    /*output 	reg  	[23:0] 	*/.data_o		(font_rom_data			)	
);

// =============数据输出====================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        data_o <= 24'b0;
	else if(pixle_y_reg < 50 && pixle_x_reg < 50)begin
		if(font_rom_data != 24'hff_ff_ff)
			data_o <= 24'hff_00_a0;
		else
			data_o <= rgb_data_reg;
	end
    else if ((pixle_y_reg == y_min_move || pixle_y_reg == y_max_move) && (pixle_x_reg >= x_min_move && pixle_x_reg <= x_max_move))
        data_o <= 24'hff_00_00; // 横线
    else if ((pixle_x_reg == x_min_move || pixle_x_reg == x_max_move) && (pixle_y_reg >= y_min_move && pixle_y_reg <= y_max_move))
        data_o <= 24'hff_00_00; // 竖线
    else if ((pixle_y_reg == y_min_r || pixle_y_reg == y_max_r) && (pixle_x_reg >= x_min_r && pixle_x_reg <= x_max_r))
        data_o <= 24'h00_ff_00; // 横线
    else if ((pixle_x_reg == x_min_r || pixle_x_reg == x_max_r) && (pixle_y_reg >= y_min_r && pixle_y_reg <= y_max_r))
        data_o <= 24'h00_ff_00; // 竖线
	else if(data_color == 8'h0)
		case(color_threshold_select)
			4'd1:data_o <= 24'hfe_00_00;
			4'd2:data_o <= 24'h00_fe_00;
			4'd3:data_o <= 24'h00_00_fe;
			4'd4:data_o <= 24'hfe_fe_00;
			default:data_o <= rgb_data_reg;
		endcase
	else
		data_o <= rgb_data_reg;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        data_o_eth <= 24'b0;
	else if(pixle_y_reg < 50 && pixle_x_reg < 50)begin
		if(font_rom_data_eth != 24'hff_ff_ff)
			data_o_eth <= 24'hff_00_a0;
		else
			data_o_eth <= rgb_data_reg;
	end
    else if ((pixle_y_reg == y_min_move || pixle_y_reg == y_max_move) && (pixle_x_reg >= x_min_move && pixle_x_reg <= x_max_move))
        data_o_eth <= 24'hff_00_00; // 横线
    else if ((pixle_x_reg == x_min_move || pixle_x_reg == x_max_move) && (pixle_y_reg >= y_min_move && pixle_y_reg <= y_max_move))
        data_o_eth <= 24'hff_00_00; // 竖线
    else if ((pixle_y_reg == y_min_r || pixle_y_reg == y_max_r) && (pixle_x_reg >= x_min_r && pixle_x_reg <= x_max_r))
        data_o_eth <= 24'h00_ff_00; // 横线
    else if ((pixle_x_reg == x_min_r || pixle_x_reg == x_max_r) && (pixle_y_reg >= y_min_r && pixle_y_reg <= y_max_r))
        data_o_eth <= 24'h00_ff_00; // 竖线
	else if(data_color == 8'h0)
		case(color_threshold_select_eth)
			4'd1:data_o_eth <= 24'hfe_00_00;
			4'd2:data_o_eth <= 24'h00_fe_00;
			4'd3:data_o_eth <= 24'h00_00_fe;
			4'd4:data_o_eth <= 24'hfe_fe_00;
			default:data_o_eth <= rgb_data_reg;
		endcase
	else
		data_o_eth <= rgb_data_reg;
end

//==============信号同步====================
reg  [2:0]  hsync_i_reg;
reg  [2:0]  vsync_i_reg;
reg  [2:0]  de_i_reg   ;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        hsync_i_reg <= 3'b0;
        vsync_i_reg <= 3'b0;
        de_i_reg    <= 3'b0;
    end
    else begin  
        hsync_i_reg <= {hsync_i_reg[1:0], hs_reg};
        vsync_i_reg <= {vsync_i_reg[1:0], vs_reg};
        de_i_reg    <= {de_i_reg   [1:0], de_reg};
    end
end

assign hsync_o = hsync_i_reg[2];
assign vsync_o = vsync_i_reg[2];
assign de_o    = de_i_reg   [2];

/***************************************************************
模块功能 ： 通过按键调节阈值，可以适应不同光环境
***************************************************************/
always@(posedge	clk or negedge rst_n) begin
	if(!rst_n ) begin
		ADD_VALUE_GREEN   <= 9'd120;
		ADD_VALUE_RED	  <= 9'd240;
		ADD_VALUE_BLUE	  <= 9'd0;
		ADD_VALUE_BLACK	  <= 9'd180;//黄
		THRESHOLD_GREEN   <= 8'd140;
		THRESHOLD_RED	  <= 8'd175;
		THRESHOLD_BLUE	  <= 8'd160;
		THRESHOLD_BLACK	  <= 8'd200;
	end
	else begin
		case(color_threshold_select)
			3'd1 : begin
						if(key4_flag == 1'b1)//红色二值化阈值
							THRESHOLD_RED	<= THRESHOLD_RED + 1'd1;
						else	if(key3_flag == 1'b1)
							THRESHOLD_RED	<= THRESHOLD_RED - 1'd1;
						else
							THRESHOLD_RED	<= THRESHOLD_RED;
					 end
			3'd2 : begin
						if(key4_flag == 1'b1)//绿色二值化阈值
							THRESHOLD_GREEN	<= THRESHOLD_GREEN + 1'd1;
						else	if(key3_flag == 1'b1)
							THRESHOLD_GREEN	<= THRESHOLD_GREEN - 1'd1;
						else
							THRESHOLD_GREEN	<= THRESHOLD_GREEN;
					 end
			
			3'd3 : begin
						if(key4_flag == 1'b1)//蓝色二值化阈值
							THRESHOLD_BLUE	<= THRESHOLD_BLUE + 1'd1;
						else	if(key3_flag == 1'b1)
							THRESHOLD_BLUE	<= THRESHOLD_BLUE - 1'd1;
						else
							THRESHOLD_BLUE	<= THRESHOLD_BLUE;
					 end
			3'd4 : begin
						if(key4_flag == 1'b1)//黑色二值化阈值
							THRESHOLD_BLACK	<= THRESHOLD_BLACK + 1'd1;
						else	if(key3_flag == 1'b1)
							THRESHOLD_BLACK	<= THRESHOLD_BLACK - 1'd1;
						else
							THRESHOLD_BLACK	<= THRESHOLD_BLACK;
					 end
			default : ;
		endcase
	end
end
/***************************************************************
模块功能 ： 通过不同参数的传入，提取不同颜色
***************************************************************/
always@(posedge	clk or negedge rst_n) begin
	if(!rst_n ) begin
		SELECT_BIT	<= 3'b0;
		ADD_VALUE	<= 9'd0;
		THRESHOLD	<= 8'd0;
	end
	else begin//启动识别，轮询赋值
		case(color_threshold_select)
		// case(2)
			3'd1 : begin
						SELECT_BIT	<= 3'b010;
			/*红*/		ADD_VALUE	<= ADD_VALUE_RED;
						THRESHOLD	<= THRESHOLD_RED;
					end
			/***********************************************/
			3'd2 :  begin
						SELECT_BIT	<= 3'b010;
			/*绿*/		ADD_VALUE	<= ADD_VALUE_GREEN;
						THRESHOLD	<= THRESHOLD_GREEN;
					end
			/***********************************************/
			3'd3 : begin
						SELECT_BIT	<= 3'b010;
			/*蓝*/		ADD_VALUE	<= ADD_VALUE_BLUE;
						THRESHOLD	<= THRESHOLD_BLUE;
					end
			/***********************************************/
			3'd4 : begin
						SELECT_BIT	<= 3'b001 ; 
			/*黑*/		ADD_VALUE	<= ADD_VALUE_BLACK; 
						THRESHOLD	<= THRESHOLD_BLACK;
					end
			/***********************************************/				
			default  : ;
		endcase
	end
end
/***************************************************************
颜色识别
***************************************************************/
image_color_ctrl image_color_ctrl_u(
    .clk   (clk  ),
    .rst_n (rst_n),
	
	.SELECT_BIT	(SELECT_BIT	),
	.ADD_VALUE	(ADD_VALUE	),
    .THRESHOLD	(THRESHOLD	),
	
	.i_rgb_href	(hsync_i),
    .i_rgb_vsync(vsync_i),
    .i_rgb_clken(de_i   ),    
    .i_rgb_r	(data_i[23:16]),
    .i_rgb_g	(data_i[15:8] ),
    .i_rgb_b	(data_i[7:0]  ),
	
    .o_b_extract_href	(hs_reg		),
	.o_b_extract_vsync	(vs_reg		),	
    .o_b_extract_clken	(de_reg		),
	.o_b_extract_data	(data_color )
);	
endmodule
