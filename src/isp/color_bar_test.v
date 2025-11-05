`timescale 1ns / 1ps

module color_data(   
    input   wire        clk         ,
    input   wire        rst_n       ,
    input   wire [11:0] pic_x       ,
    input   wire [11:0] pic_y       ,
    output  reg  [15:0] pic_data
    );
    
// always @(posedge clk or negedge rst_n) begin//479
    // if(!rst_n)
        // pic_data <= 0;
    // else if(pic_y <= 59)
        // pic_data <= 16'hf0_ff;
    // else if(pic_y >= 60 && pic_y <= 119)
        // pic_data <= 16'hed_91;
	// else if(pic_y >= 120 && pic_y <= 179)
        // pic_data <= 16'hde_91;
	// else if(pic_y >= 180 && pic_y <= 239)
        // pic_data <= 16'h56_91;
    // else if(pic_y >= 240 && pic_y <= 399)
        // pic_data <= 16'h21_fc;
	// else if(pic_y >= 300 && pic_y <= 359)
        // pic_data <= 16'h33_fc;
	// else if(pic_y >= 360 && pic_y <= 419)
        // pic_data <= 16'h22_fc;
    // else
        // pic_data <= 16'h88_8a;
// end
	
// 定义颜色常量 (RGB565格式)
localparam WHITE = 16'hFFFF;
localparam BLACK = 16'h0000;

// ==========================================================
// ## 您可以在这里修改参数来定义菱形 ##
// ==========================================================
localparam CENTER_X = 320; // 菱形中心 X 坐标
localparam CENTER_Y = 240; // 菱形中心 Y 坐标

localparam RADIUS_H = 200; // 水平半径 (决定菱形的宽度)
localparam RADIUS_V = 100; // 垂直半径 (决定菱形的高度)
// ==========================================================

// -- 中间计算信号 --
// 为了防止减法溢出，位宽比输入大1位
wire signed [12:0] x_diff;
wire signed [12:0] y_diff;

// 绝对值
wire [11:0] abs_x_diff;
wire [11:0] abs_y_diff;

// 乘法项，位宽是两个操作数位宽之和
wire [23:0] term1; // RADIUS_V * |x - cx|
wire [23:0] term2; // RADIUS_H * |y - cy|

// 曼哈顿距离求和项，位宽比乘积大1位以防溢出
wire [24:0] manhattan_sum;

// 阈值 (RADIUS_H * RADIUS_V)
wire [23:0] threshold;

// 最终判断结果
wire is_inside_diamond;


// --- 组合逻辑计算 ---
// 1. 计算当前点到中心的距离 (x, y分量)
assign x_diff = pic_x - CENTER_X;
assign y_diff = pic_y - CENTER_Y;

// 2. 取绝对值
assign abs_x_diff = (x_diff < 0) ? -x_diff : x_diff;
assign abs_y_diff = (y_diff < 0) ? -y_diff : y_diff;

// 3. 计算公式的左边部分: b * |x-cx| + a * |y-cy|
assign term1 = RADIUS_V * abs_x_diff;
assign term2 = RADIUS_H * abs_y_diff;
assign manhattan_sum = term1 + term2;

// 4. 计算公式的右边部分: a * b
assign threshold = RADIUS_H * RADIUS_V;

// 5. 判断是否在菱形内部
assign is_inside_diamond = (manhattan_sum <= threshold);


// --- 时序逻辑输出 ---
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pic_data <= 16'h0000; // 复位时输出黑色
    end
    else begin
        // 如果当前坐标在菱形内部
        if (is_inside_diamond) begin
            pic_data <= BLACK; // 输出黑色
        end
        else begin
            pic_data <= WHITE; // 否则，输出白色背景
        end
    end
end

endmodule
