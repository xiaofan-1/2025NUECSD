// font_rom.v
`timescale 1ns / 1ps

module font_rom_eth (
	input	wire			clk				,
	input	wire			rst_n			,
	input	wire 	[11:0]  pixel_x			,
	input	wire 	[11:0]	pixel_y			,
	input	wire			de				,
	input	wire			key				,
	output	reg 	[2:0]	color_select	,
    output 	reg  	[23:0] 	data_o		 		// 对应行的16个像素数据 (1 for ON, 0 for OFF)
);

localparam
	IDLE    = 3'd0,
	RED		= 3'd1,
	GREEN   = 3'd2,
	BLUE    = 3'd3,
	BLACK   = 3'd4;

wire	[23:0]	font_red_data;
wire	[23:0]	font_green_data;
wire	[23:0]	font_blue_data;
wire	[23:0]	font_black_data;

reg 	[11:0]	addra;
reg		[2:0]	curr_state;
reg		[2:0]	next_state;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        addra <= 0;
    else if(addra == 2500 - 1)
        addra <= 0;
    else if(addra < 2500  && pixel_x < 50  && pixel_y < 50 && de)
        addra <= addra + 1;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        curr_state <= IDLE;
    else
		curr_state <= next_state;
end

always @(*) begin
	if(!rst_n)
		next_state = IDLE;
	else begin
		case(curr_state)
			IDLE   :next_state = RED;
			RED	   :begin
				if(key)
					next_state = GREEN;
				else
					next_state = curr_state;
			end
			GREEN  :begin
				if(key)
					next_state = BLUE;
				else
					next_state = curr_state;
			end
			BLUE   :begin
				if(key)
					next_state = BLACK;
				else
					next_state = curr_state;
			end
			BLACK  :begin
				if(key)
					next_state = IDLE;
				else
					next_state = curr_state;
			end
			default:next_state = IDLE;
		endcase
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		color_select <= 3'd0;
		data_o       <= 24'h0;
	end
	else begin
		case(next_state)
			IDLE 	:begin
				color_select <= 3'd0;
				data_o       <= 24'h0;
			end
			RED	    :begin
				color_select <= 3'd1;
				data_o       <= font_red_data;
			end
			GREEN   :begin
				color_select <= 3'd2;
				data_o       <= font_green_data;
			end
			BLUE    :begin
				color_select <= 3'd3;
				data_o       <= font_blue_data;
			end
			BLACK   :begin
				color_select <= 3'd4;
				data_o       <= font_black_data;
			end
			default :begin
				color_select <= 3'd0;
				data_o       <= 24'h0;
			end
		endcase
	end
end

font_red font_red_u( 
	.doa		(font_red_data	), 
	.addra		(addra			), 
	.clka       (clk			)
);

font_green font_green_u( 
	.doa		(font_green_data), 
	.addra		(addra			), 
	.clka       (clk			)
);

font_blue font_blue_u( 
	.doa		(font_blue_data	), 
	.addra		(addra			), 
	.clka       (clk			)
);

font_black font_black_u( 
	.doa		(font_black_data	), 
	.addra		(addra			), 
	.clka       (clk			)
);



endmodule