`timescale 1ns / 1ps

module seg_led_ctrl(
    input   wire    		clk      ,
    input   wire    		rst_n    ,
    input   wire    [ 7:0]  eth_data ,
    input   wire    		flag     ,
    output  reg     [ 6:0]  seg      ,
    output  reg     [ 7:0]  sel      ,
    output  reg     [ 3:0]  led      
 );

localparam delay_cnt = 60_000_000;

reg [27:0] cnt;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt <= 0;
    else if(cnt == delay_cnt - 28'd1 || flag)
        cnt <= 0;
    else if(flag == 1'b0)
        cnt <= cnt + 28'd1;
end

reg [3:0]   number;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        number <= 4'd0;
    else if(flag)
        number <= 4'd0;
    else if(cnt == delay_cnt - 28'd1 && eth_data == 8'haa) begin
        if(number == 4'd15)
            number <= 4'd0;
        else
            number <= number + 4'd1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        led <= 4'b0;
    else if(flag)
        led <= 4'b0;
    else if(flag == 1'b0) begin
        case(eth_data)
            8'hbb: begin
				if(cnt == delay_cnt - 28'd1)
        		    led <= ~led;
        		else
        		    led <= led;
            end
            8'hcc:begin
                if(led == 4'b0 || led == 4'b1111)
                    led <= 4'b1000;
        		else if(cnt == delay_cnt - 28'd1)
        		    led <= {led[0],led[3:1]};
            end
            default :led <= 4'b0;
        endcase
    end
end

always @(*) begin
	sel <= 8'b11110000;   
	case(number)
		4'd0    :	seg	<=	7'b1000_000;//7'b0111_111;
		4'd1 	:	seg	<=	7'b1111_001;//7'b0000_110;
		4'd2 	:	seg	<=	7'b0100_100;//7'b1011_011;
		4'd3 	:	seg	<=	7'b0110_000;//7'b1001_111;
		4'd4 	:	seg	<=	7'b0011_001;//7'b1100_110;
		4'd5 	:	seg	<=	7'b0010_010;//7'b1101_101;
		4'd6 	:	seg	<=  7'b0000_010;//7'b1111_101;
		4'd7 	:	seg	<=	7'b1111_000;//7'b0000_111;
		4'd8 	:	seg	<=	7'b0000_000;//7'b1111_111;
		4'd9 	:	seg	<=	7'b0010_000;//7'b1101_111;
		4'd10	:	seg	<=	7'b0001_000;//7'b1110_111;
		4'd11	:	seg	<=	7'b0000_011;//7'b1111_100;
		4'd12	:	seg	<=	7'b1000_110;//7'b0111_001;
		4'd13	:	seg	<=	7'b0100_001;//7'b1011_110;
		4'd14	:	seg	<=	7'b0000_110;//7'b1111_001;
		4'd15	:	seg	<=	7'b0001_110;//7'b1110_001;
		default	:	seg	<=	7'b1000_000;//7'b0111_111;	
	endcase	
end

endmodule
