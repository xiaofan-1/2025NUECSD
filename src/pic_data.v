`timescale 1ns / 1ps

module pic_data(
    input   wire            rgmii_clk       ,
    input   wire            hdmi_clk        ,
    input   wire            rst_n           ,
    input   wire    [7:0]   udp_rx_data     ,
    input   wire            udp_rx_en       ,
    input   wire            de              ,
    input   wire    [11:0]  pic_x           ,
    input   wire    [11:0]  pic_y           ,
    output  wire    [15:0]  pic_data    
    );

reg     [15:0]  addra;
reg     [15:0]  addrb;

reg     [0:0]   wea;

localparam pic_size_x = 80;//rgb565
localparam pic_size_y = 80;
localparam ram_addr = pic_size_x * pic_size_y * 2;
localparam hdmi_addr = pic_size_x * pic_size_y;

wire    [15:0]  doutb;
wire            flag;

wire    [15:0]  flip_data;

reg 	[11:0]	pic_x_reg;
reg 	[11:0]	pic_y_reg;

always @(posedge hdmi_clk) begin
    if(!rst_n) begin
		pic_x_reg <= 12'd0;
		pic_y_reg <= 12'd0;
	end
    else begin
		pic_x_reg <= pic_x;
		pic_y_reg <= pic_y;
	end
end


assign flag = (pic_x_reg == 0 && pic_y_reg == 0) ? 1 : 0;

always @(posedge rgmii_clk) begin
    if(!rst_n)
        wea <= 0;
    else if(addra == ram_addr - 1 && flag) 
        wea <= 0;
    else if(addra < ram_addr - 1&&  flag==0) 
        wea <= 1;
    else
        wea <= wea;
end

always @(posedge rgmii_clk) begin
    if(!rst_n)
        addra <= 0;
    else if(wea) begin
        if(addra < ram_addr - 1 && udp_rx_en)
            addra <= addra + 1;
        else
            addra <= addra;
    end 
    else
        addra <= addra;
end

always @(posedge hdmi_clk) begin
    if(!rst_n)
        addrb <= 0;
    else if(wea == 0) begin
        if(addrb == hdmi_addr - 1)
            addrb <= 0;
        else if(addrb < hdmi_addr && pic_x_reg < pic_size_x && pic_y_reg < pic_size_y && de)
            addrb <= addrb + 1;
    end
end

assign flip_data = {doutb[15:8],doutb[7:0]};
assign pic_data = (pic_x_reg < pic_size_x && pic_y_reg < pic_size_y && de) ? flip_data : 16'hff_ff;

pic_data_ram pic_data_ram_u ( 
    .clka        (rgmii_clk)  ,
    .cea         (1'b1)       ,
    .wea         (wea)        ,
    .addra       (addra)      , 
    .dia         (udp_rx_data),
    .clkb        (hdmi_clk)   ,
	.ceb         (1'b1)       , 
    .addrb       (addrb)      , 
	.dob         (doutb)      
);

endmodule
