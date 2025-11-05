`timescale 1ns/1ps

module digital_recognition(
    input   wire        clk             ,
    input   wire        rst_n           ,
    //输入
    input   wire        vsync_i         ,//场信号
    input   wire        flag            ,//threshold value
    input   wire [10:0] pixle_x         ,
    input   wire [10:0] pixle_y         ,
    input   wire [10:0] x_min           ,
    input   wire [10:0] x_max           ,
    input   wire [10:0] y_min           ,
    input   wire [10:0] y_max           ,
    //
	output  reg  [7:0]	number
);

reg vsync_rise_r0;
reg vsync_rise_r1;
reg vsync_rise_r2;

reg 	   x1_l,x1_r,x2_l,x2_r;
reg [3:0]  y,x1,x2;

reg     [17:0]    x_min_r;
reg     [17:0]    x_max_r;
reg     [17:0]    y_min_r;
reg     [17:0]    y_max_r;

reg [11:0] h_2; //(hcount_l + hcount_r)/2
reg [11:0] v_5; // (vcount_r - vcount_l)*2/5 + vcount_l
reg [11:0] v_3; // (vcount_r - vcount_l)*2/3 + vcount_l

// =============提取同步信号边沿============
reg vsync_reg0, vsync_reg1;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        vsync_reg0 <= 0;
        vsync_reg1 <= 0;
    end else begin
        vsync_reg0 <= vsync_i;
        vsync_reg1 <= vsync_reg0;
    end
end

wire vsync_rise = (vsync_reg0 && ~vsync_reg1);
wire vsync_fall = (~vsync_reg0 && vsync_reg1);
//-------------------------------------------------------------
//frame counter
//-------------------------------------------------------------
reg [2:0]  frame_cnt;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        frame_cnt <=3'd0;
    else if(frame_cnt == 3'd3)
        frame_cnt <=3'd0;
    else if(vsync_fall) //falling edge
        frame_cnt <= frame_cnt + 3'd1;
    else
        frame_cnt <= frame_cnt;
end

//==============flag========================
reg flag_reg0, flag_reg1;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        flag_reg0 <= 0;
        flag_reg1 <= 0;
    end else begin
        flag_reg0 <= flag;
        flag_reg1 <= flag_reg0;
    end
end

wire flag_fall;
assign flag_fall = (~flag_reg0 && flag_reg1);

//-------------------------------------------------
//pipiline
//-------------------------------------------------
always @(posedge clk ) begin
    if(!rst_n)
        vsync_rise_r0 <= 1'b0;
    else
        vsync_rise_r0 <= vsync_rise;
end
//-------------------------------------------------
// 1/2 x            2/5 y             2/3 y
//-------------------------------------------------
always @(posedge clk or negedge rst_n) begin  
    if(!rst_n) begin
        h_2 <= 12'd0;
        v_5 <= 12'd0;
        v_3 <= 12'd0;
        x_min_r <= 18'b0;
        x_max_r <= 18'b0;
        y_min_r <= 18'b0;
        y_max_r <= 18'b0;
    end
    else if(frame_cnt == 3'd1) begin
        if(vsync_rise) begin
            x_min_r <= x_min;
            x_max_r <= x_max;
            y_min_r <= y_min;
            y_max_r <= y_max;
        end
        else if(vsync_rise_r0) begin
            h_2 <= x_min_r + ((x_max_r - x_min_r) >> 1);
            v_3 <= y_min_r + ((y_max_r - y_min_r) >> 2) + ((y_max_r - y_min_r) >> 4);
            v_5 <= y_min_r + ((y_max_r - y_min_r) >> 1) + ((y_max_r - y_min_r) >> 2)+ ((y_max_r - y_min_r) >> 4) - 10;
        end
    end
end

//----------------------------------------------------
// x1 
//----------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        x1 <= 4'd0;
    else if(frame_cnt == 3'd1) begin
        if(vsync_rise)//vsync rising edge 
            x1 <= 4'd0;
        else if(pixle_y == v_3) 
            if(flag_fall)
	           x1 <= x1 + 4'd1;
	   else
	       x1 <= x1;
    end
    else
        x1 <= x1;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        x1_l <= 1'b0;
    else if(frame_cnt == 3'd1) begin
        if(vsync_rise)//vsync rising edge 
            x1_l <= 1'b0;
    else if((pixle_y == v_3) && (pixle_x < h_2)) //left
        if(flag_fall)
	       x1_l <= 1'b1;
        else
	       x1_l <= x1_l;
    end
    else
        x1_l <= x1_l;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        x1_r <= 1'b0;
    else if(frame_cnt == 3'd1) begin
        if(vsync_rise)//vsync rising edge 
            x1_r <= 1'b0;
    else if((pixle_y == v_3) && (pixle_x > h_2)) 
        if(flag_fall)
	       x1_r <= 1'b1;
	   else
	       x1_r <= x1_r;
    end
    else
        x1_r <= x1_r;
end
//----------------------------------------------------
// x2
//----------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        x2 <= 4'd0;
    else if(frame_cnt == 3'd1) begin
        if(vsync_rise) //vsync rising edge 
            x2 <= 4'd0;
    else if(pixle_y == v_5) 
        if(flag_fall)
	       x2 <= x2 + 4'd1;
        else
	       x2 <= x2;
    end
    else
        x2 <= x2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        x2_l <= 1'b0;
    else if(frame_cnt == 3'd1) begin
        if(vsync_rise)//vsync rising edge 
            x2_l <= 1'b0;
        else if((pixle_y == v_5) && (pixle_x < h_2)) begin
            if(flag_fall)
	           x2_l <= 1'b1;
            else
	           x2_l <= x2_l;
	    end
    end
    else
        x2_l <= x2_l;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        x2_r <= 1'b0;
    else if(frame_cnt == 3'd1) begin
        if(vsync_rise)//vsync rising edge 
            x2_r <= 1'b0;
        else if((pixle_y == v_5) && (pixle_x > h_2)) begin
            if(flag_fall)
	           x2_r <= 1'b1;
            else
	           x2_r <= x2_r;
	    end
    end
    else
        x2_r <= x2_r;
end
//----------------------------------------------------
// y
//----------------------------------------------------
reg curr_flag;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        curr_flag <= 1'b0;
    else if(frame_cnt == 3'd1) begin
        if(pixle_x == h_2)
            curr_flag <= flag;
    end
end

reg next_flag_reg0,next_flag_reg1;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        next_flag_reg0 <= 1'b0;
        next_flag_reg1 <= 1'b0;
    end
    else begin
        next_flag_reg0 <= curr_flag;
        next_flag_reg1 <= next_flag_reg0;
    end
end

wire cn_flag_fall = (~next_flag_reg0 && next_flag_reg1);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        y <= 4'd0;
    else if(frame_cnt == 3'd1) begin
        if(vsync_rise)//vsync rising edge 
            y <= 4'd0;
        else  if(cn_flag_fall)
            y <= y + 4'd1;
        else
            y <= y;
    end
end
//----------------------------------------------------
// 输出
//----------------------------------------------------
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		number <= 8'h0;
	else if((frame_cnt == 3'd2) && vsync_rise)begin
		case({x1_l,x1_r,x2_l,x2_r,y,x1,x2})
			16'b1111_0010_0010_0010: number <= {8'h0};//
			16'b0101_0001_0001_0001: number <= {8'h1};//
			16'b0110_0011_0001_0001: number <= {8'h2};//
			16'b0101_0011_0001_0001: number <= {8'h3};//
			16'b1101_0010_0010_0001: number <= {8'h4};//
			16'b1001_0011_0001_0001: number <= {8'h5};//
			16'b1011_0011_0001_0010: number <= {8'h6};//
			16'b0101_0010_0001_0001: number <= {8'h7};//
			16'b1111_0011_0010_0010: number <= {8'h8};//
			16'b1101_0011_0010_0001: number <= {8'h9};//
			default: number <= 8'hff;
		endcase
	end
	else
		number <= number; 
end

endmodule 