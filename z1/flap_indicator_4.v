module flap_indicator_4
	(
		input clk,
		input async_nreset,
		
		input change_position_re,
		input change_mode_re,
		
		input sw_h_deb,
		input sw_l_deb,
		
		output reg [7:0] display1,
		output reg [7:0] display2,
		output reg [7:0] display3,
		output reg [7:0] display4
	);
	
	reg change_position_re_tmp [3:0];
	reg change_mode_re_tmp [3:0];
	
	wire [7:0] segment [3:0];
	
	genvar i;
	generate
	for (i = 0; i < 4; i = i + 1)
		begin: genBlock
			flap_indicator_3 flap_indicator_i
			(
				.clk(clk),
				.async_nreset(async_nreset),
				
				.change_position_re(change_position_re_tmp[i]),
				.change_mode_re(change_mode_re_tmp[i]),
				
				.display(segment[i])
			);
		end
	endgenerate
	
	integer j;
	
	always @(*)
	begin
		for (j = 0; j < 4; j = j + 1)
		begin
			change_position_re_tmp[j] <= 1'b0;
			change_mode_re_tmp[j] <= 1'b0;
			
			if ({sw_h_deb, sw_l_deb} == j[1:0])
			begin
				change_position_re_tmp[j] <= change_position_re;
				change_mode_re_tmp[j] <= change_mode_re;
			end
		end
	end
	
	always @(*)
	begin
		display1 = {1'b0, segment[0][6:0]};
		display2 = {1'b0, segment[1][6:0]};
		display3 = {1'b0, segment[2][6:0]};
		display4 = {1'b0, segment[3][6:0]};
		
		case ({sw_h_deb, sw_l_deb})
			2'b00:
				display1[7] = 1'b1;
			2'b01:
				display2[7] = 1'b1;
			2'b10:
				display3[7] = 1'b1;
			2'b11:
				display4[7] = 1'b1;
		endcase
	end
	
endmodule