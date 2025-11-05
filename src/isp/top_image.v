`timescale 1 ps/ 1 ps

module top_image(
	input	wire		clk			,
	input	wire		rst_n		,
	//
	input   wire        hsync_i     ,//行信号
    input   wire        vsync_i     ,//场信号
    input   wire        de_i        ,
    input   wire [23:0] data_i      ,//
	input	wire [7:0]	threshold	,
	input	wire [10:0] pixel_x,
	input	wire [10:0]	pixel_y,
	//
	output  wire [7:0]	number		,
	output  wire        hsync_o     ,
    output  wire        vsync_o     ,
    output  wire        de_o        ,
    output  wire [23:0] data_o           
    );

wire        hsync_reg;
wire        vsync_reg;
wire        de_reg   ;

wire        hsync_reg1;
wire        vsync_reg1;
wire        de_reg1   ;

wire        hsync_reg2;
wire        vsync_reg2;
wire        de_reg2   ;

reg         hsync_reg3;
reg         vsync_reg3;
reg         de_reg3   ;

wire        hsync_reg4;
wire        vsync_reg4;
wire        de_reg4   ;

wire [7:0]  data_gray,data_mid,data_gauss,data_erode;

reg  [7:0]	data_reg;

wire        pixel_valid;

wire [10:0] x_min;
wire [10:0] x_max;
wire [10:0] y_min;
wire [10:0] y_max;

rgb2ycrcb rgb2ycrcb_u(
    /*input   wire        */.clk       (clk  ),
    /*input   wire        */.rst_n     (rst_n),
    //输入                             
    /*input   wire        */.hsync_i   (hsync_i),//行信号
    /*input   wire        */.vsync_i   (vsync_i),//场信号
    /*input   wire        */.de_i      (de_i   ),
    /*input   wire [23:0] */.data_i    (data_i),//
    //输出                            
    /*output  wire        */.hsync_o   (hsync_reg),
    /*output  wire        */.vsync_o   (vsync_reg),
    /*output  wire        */.de_o      (de_reg   ),
	/*output  wire [7:0]  */.data_y    (data_gray ), 
	/*output  wire [7:0]  */.data_cb   (), 
    /*output  wire [7:0]  */.data_cr   () 
    );
	
image_midian image_midian_u(
    /*input   wire        */.clk       (clk  )  ,
    /*input   wire        */.rst_n     (rst_n)  ,
	//
    /*input   wire        */.hsync_i   (hsync_reg)  ,
    /*input   wire        */.vsync_i   (vsync_reg)  ,
    /*input   wire        */.de_i      (de_reg   )  ,
    /*input	wire [7:0]    */.data_i	   (data_gray ) ,
	//
    /*output  reg         */.hsync_o   (hsync_reg1)  ,
    /*output  reg         */.vsync_o   (vsync_reg1)  ,
    /*output  reg         */.de_o      (de_reg1   )  ,
    /*output  wire [7:0]  */.data_mid  (data_mid )    
    );

image_gauss image_gauss_u(
    /*input   wire        */.clk     (clk  )    ,
    /*input   wire        */.rst_n   (rst_n)    ,
    /*input   wire        */.hsync_i (hsync_reg1)    ,
    /*input   wire        */.vsync_i (vsync_reg1)    ,
    /*input   wire        */.de_i    (de_reg1   )    ,
    /*input	  wire [7:0]  */.data_i	 (data_mid)    ,
    /*output  wire        */.hsync_o (hsync_reg2)    ,
    /*output  wire        */.vsync_o (vsync_reg2)    ,
    /*output  wire        */.de_o    (de_reg2   )    ,
    /*output  reg  [7:0]  */.data_o  (data_gauss)    
);

always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		data_reg <= 8'h0;
	else if(data_gauss <= threshold)
		data_reg <= 8'h0;
	else
		data_reg <= 8'hff;
end

always @(posedge clk) begin
	hsync_reg3 <= hsync_reg;
	vsync_reg3 <= vsync_reg;
	de_reg3    <= de_reg   ;
end

image_erosion image_erosion_u(
    /*input   wire        */.clk        (clk  ) ,
    /*input   wire        */.rst_n      (rst_n) ,
    /*                  */
    /*input   wire        */.hsync_i    (hsync_reg3) ,
    /*input   wire        */.vsync_i    (vsync_reg3) ,
    /*input   wire        */.de_i       (de_reg3   ) ,
    /*input	wire [7:0]    */.data_i	    (data_reg  ) ,
    /*输出行场信号            */
    /*output  wire        */.hsync_o    (hsync_reg4) ,
    /*output  wire        */.vsync_o    (vsync_reg4) ,
    /*output  wire        */.de_o       (de_reg4   ) ,
    /*output  wire [23:0] */.data_erode (data_erode )
    );

image_frame image_frame_u(
    /*input   wire        */.clk      (clk  )   ,
    /*input   wire        */.rst_n    (rst_n)   ,
    /*输入                */       
    /*input   wire        */.hsync_i  (hsync_reg4)   ,//行信号
    /*input   wire        */.vsync_i  (vsync_reg4)   ,//场信号
    /*input   wire        */.de_i     (de_reg4   )   ,//图像有效信号
    /*input   wire [7:0]  */.data_i   (data_erode)   ,//处理后的图像
    /*input   wire [9:0]  */.pixle_x  (pixel_x)   ,
    /*input   wire [9:0]  */.pixle_y  (pixel_y)   ,
    /*input   wire [23:0] */.rgb_data ({data_erode[7:0],data_erode[7:0],data_erode[7:0]})  ,
    /*输出                */      
    /*output  wire        */.pixel_valid (pixel_valid),
    /*output  reg  [10:0] */.x_min_r    (x_min),
    /*output  reg  [10:0] */.x_max_r    (x_max),
    /*output  reg  [10:0] */.y_min_r    (y_min),
    /*output  reg  [10:0] */.y_max_r    (y_max),
    /*output  reg         */.hsync_o  (hsync_o)   ,
    /*output  reg         */.vsync_o  (vsync_o)   ,
    /*output  reg         */.de_o     (de_o   )   ,
    /*output  reg  [23:0] */.data_o   (data_o  )    //
    );
	
digital_recognition digital_recognition_u(
    /*input   wire        */.clk       (clk  ) ,
    /*input   wire        */.rst_n     (rst_n) ,
    /*input   wire        */.vsync_i   (vsync_o) ,//场信号
    /*input   wire        */.flag      (pixel_valid) ,//threshold value
    /*input   wire [10:0] */.pixle_x   (pixel_x) ,
    /*input   wire [10:0] */.pixle_y   (pixel_y) ,
    /*input   wire [10:0] */.x_min     (x_min) ,
    /*input   wire [10:0] */.x_max     (x_max) ,
    /*input   wire [10:0] */.y_min     (y_min) ,
    /*input   wire [10:0] */.y_max     (y_max) ,
	/*output  reg  [7:0]  */.number    (number)
);

endmodule
