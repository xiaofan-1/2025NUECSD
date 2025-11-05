`timescale 1ns / 1ps

module image_frame(
    input   wire        clk           ,
    input   wire        rst_n         ,
    //输入                             
    input   wire        hsync_i       ,//行信号
    input   wire        vsync_i       ,//场信号
    input   wire        de_i          ,//图像有效信号
    input   wire [7:0]  data_i        ,//处理后的图像
    input   wire [11:0] pixle_x       ,
    input   wire [11:0] pixle_y       ,
    input   wire [23:0] rgb_data      ,
    //输出                             
    output  wire        pixel_valid   ,
    output  reg  [11:0] x_min_r       ,
    output  reg  [11:0] x_max_r       ,
    output  reg  [11:0] y_min_r       ,
    output  reg  [11:0] y_max_r       ,
	output  reg  [11:0] pixle_x_reg   ,
	output  reg  [11:0] pixle_y_reg   ,
    output  wire        hsync_o       ,
    output  wire        vsync_o       ,
    output  wire        de_o          ,
    output  reg  [23:0] data_o       //
	// output  wire  [23:0] data_o       //
    );

// assign data_o = rgb_data_reg;

localparam pix_h = 640,
           pix_v = 480;
               
reg  [11:0]  x,y;
wire add_x = de_i;
wire end_x = add_x && x == pix_h - 1;
wire add_y = end_x;
wire end_y = add_y && y == pix_v - 1;

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
        vsync_reg0 <= vsync_i;
        vsync_reg1 <= vsync_reg0;
    end
end

wire pos_vsync = (vsync_reg0 && ~vsync_reg1);
wire neg_vsync = (~vsync_reg0 && vsync_reg1);

// 边界检测（边缘像素即有效像素）
assign pixel_valid = (data_i == 8'd0 && x > 5 && x < 634 && y > 5 && y < 474);
// 记录边界（极值法）
reg [10:0] x_min;
reg [10:0] x_max;
reg [10:0] y_min;
reg [10:0] y_max;

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

reg [7:0]  cnt_pos;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cnt_pos <= 8'd0;
    else if(cnt_pos == 2)
        cnt_pos <= 8'd0;
    else if(neg_vsync)
        cnt_pos <= cnt_pos + 1;
    else
        cnt_pos <= cnt_pos;    
end

// =============锁存边界到下一帧=============
// always @(posedge clk or negedge rst_n) begin
    // if (!rst_n) begin
        // x_min_r <= 0; 
        // x_max_r <= 0;
        // y_min_r <= 0; 
        // y_max_r <= 0;
    // end 
    // else if (neg_vsync) begin
        // x_min_r <= x_min;
        // x_max_r <= x_max;
        // y_min_r <= y_min;
        // y_max_r <= y_max;
    // end
// end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        x_min_r <= 0; 
        x_max_r <= 0;
        y_min_r <= 0; 
        y_max_r <= 0;
    end 
    else if (neg_vsync) begin
        if (x_min < x_max && y_min < y_max && (x_max - x_min) > 20  && (y_max - y_min) > 20) begin
            x_min_r <= x_min;
            x_max_r <= x_max;
            y_min_r <= y_min;
            y_max_r <= y_max;
        end
		else begin
			x_min_r <= 0;
            x_max_r <= 0;
            y_min_r <= 0;
            y_max_r <= 0;
		end
    end
end

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


// reg		[11:0]	pixle_x_reg;
// reg		[11:0]	pixle_y_reg;
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
		rgb_data_reg10<= 24'h0;
		rgb_data_reg11<= 24'h0;
		rgb_data_reg12<= 24'h0;
		rgb_data_reg13<= 24'h0;
		rgb_data_reg14<= 24'h0;
		rgb_data_reg15<= 24'h0;
		rgb_data_reg16<= 24'h0;
		
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
		pixle_x_reg10 <= 12'd0;
		pixle_y_reg10 <= 12'd0;
		pixle_x_reg11 <= 12'd0;
		pixle_y_reg11 <= 12'd0;
		pixle_x_reg12 <= 12'd0;
		pixle_y_reg12 <= 12'd0;
		pixle_x_reg13 <= 12'd0;
		pixle_y_reg13 <= 12'd0;
		pixle_x_reg14 <= 12'd0;
		pixle_y_reg14 <= 12'd0;
		pixle_x_reg15 <= 12'd0;
		pixle_y_reg15 <= 12'd0;
		pixle_x_reg16 <= 12'd0;
		pixle_y_reg16 <= 12'd0;
	end
	else begin
		rgb_data_reg0 <= rgb_data;
		rgb_data_reg1 <= rgb_data_reg0;
		rgb_data_reg2 <= rgb_data_reg1;
		rgb_data_reg3 <= rgb_data_reg2;
		rgb_data_reg4 <= rgb_data_reg3;
		rgb_data_reg5 <= rgb_data_reg4;
		rgb_data_reg6 <= rgb_data_reg5;
		rgb_data_reg7 <= rgb_data_reg6;
		rgb_data_reg8 <= rgb_data_reg7 ;
		rgb_data_reg9 <= rgb_data_reg8 ;
		rgb_data_reg10<= rgb_data_reg9 ;
		rgb_data_reg11<= rgb_data_reg10;
		rgb_data_reg12<= rgb_data_reg11;
		rgb_data_reg13<= rgb_data_reg12;
		rgb_data_reg14<= rgb_data_reg13;
		rgb_data_reg15<= rgb_data_reg14;
		rgb_data_reg16<= rgb_data_reg15;
		rgb_data_reg  <= rgb_data_reg16;
		
		pixle_x_reg0  <= pixle_x;
		pixle_y_reg0  <= pixle_y;
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
		pixle_x_reg12 <= pixle_x_reg11;
		pixle_y_reg12 <= pixle_y_reg11;
		pixle_x_reg13 <= pixle_x_reg12;
		pixle_y_reg13 <= pixle_y_reg12;
		pixle_x_reg14 <= pixle_x_reg13;
		pixle_y_reg14 <= pixle_y_reg13;
		pixle_x_reg15 <= pixle_x_reg14;
		pixle_y_reg15 <= pixle_y_reg14;
		pixle_x_reg16 <= pixle_x_reg15;
		pixle_y_reg16 <= pixle_y_reg15;
		pixle_x_reg   <= pixle_x_reg16;
		pixle_y_reg   <= pixle_y_reg16;
	end
end


// =============数据输出====================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        data_o <= 24'b0;
    else if ((pixle_y_reg == y_min_r || pixle_y_reg == y_max_r) && (pixle_x_reg >= x_min_r && pixle_x_reg <= x_max_r))
        data_o <= 24'hff_00_00; // 横线
    else if ((pixle_x_reg == x_min_r || pixle_x_reg == x_max_r) && (pixle_y_reg >= y_min_r && pixle_y_reg <= y_max_r))
        data_o <= 24'hff_00_00; // 竖线
	else
		data_o <= rgb_data_reg;
end

// always @(posedge clk or negedge rst_n) begin
    // if (!rst_n)
        // data_o <= 24'b0;
	// else if(de_o)
		// data_o <= {pixle_x_reg[10:3], pixle_y_reg[9:2], 8'd0};
	// else
		// data_o <= 24'hff_ff_ff;
// end

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
        hsync_i_reg <= {hsync_i_reg[1:0], hsync_i};
        vsync_i_reg <= {vsync_i_reg[1:0], vsync_i};
        de_i_reg    <= {de_i_reg   [1:0], de_i   };
    end
end

assign hsync_o = hsync_i_reg[2];
assign vsync_o = vsync_i_reg[2];
assign de_o    = de_i_reg   [2];

endmodule
