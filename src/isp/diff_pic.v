module diff_pic(
    input  wire                         sys_clk                 ,
    input  wire                         sys_rst_n               ,

    
    
    input  wire                         hsync_i                 ,
	input  wire                         vsync_i                 ,
	input  wire                         de_i                    ,
	
    input  wire        [   7:0]         new_pic                 ,
    input  wire        [   7:0]         last_pic                ,
    input  wire        [   7:0]         DIFF_THR                ,
    output wire                         hsync_o                 ,
    output wire                         vsync_o                 ,
	output wire                         de_o                    ,
    
    output wire        [  7:0]          diff_data              
);

reg        [   7:0]         last_picreg0               ;
reg        [   7:0]         last_picreg1               ;

reg							diff_flag;
//*将当前数据打一拍，
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)begin
        last_picreg0 <= 1'b0;
        last_picreg1 <= 1'b0;
    end
    else begin
        last_picreg0 <= last_pic;
        last_picreg1 <= last_picreg0;
    end
end

//*差分计算
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        diff_flag <= 1'b0;
    else if(de_i) begin
        if(last_picreg0 >= new_pic) begin
            if((last_picreg0 - new_pic) >= DIFF_THR)
                diff_flag <= 1'b0;//*输出黑色，显示区域
            else
                diff_flag <= 1'b1;
        end
        else if(new_pic > last_picreg0) begin
            if((new_pic - last_picreg0) >= DIFF_THR)
                diff_flag <= 1'b0;
            else
                diff_flag <= 1'b1;
        end
    end
end

//*rgb_data
assign diff_data = diff_flag ? 8'hff : 8'h00;

reg 	hsync_reg;
reg 	vsync_reg;
reg 	de_reg   ;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0) begin
        hsync_reg <= 1'd0;
        vsync_reg <= 1'd0;
        de_reg    <= 1'd0;
    end
    else begin
        hsync_reg <= hsync_i;
        vsync_reg <= vsync_i;
        de_reg    <= de_i   ;
    end
end
assign hsync_o = hsync_reg;
assign vsync_o = vsync_reg;
assign de_o    = de_reg   ;

endmodule