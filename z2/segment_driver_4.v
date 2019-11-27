module segment_driver_4
	(
		input clk,
		input async_nreset,
		
		input next_segment_re,
		input change_mode_re,
		
		input sw_h_deb,
		input sw_l_deb,
		
		output reg [7:0] display0,
		output reg [7:0] display1,
		output reg [7:0] display2,
		output reg [7:0] display3
	);
	
	reg next_segment [3:0];
	reg change_mode [3:0];
	wire [7:0] display_tmp [3:0];
	
	genvar i;
	generate
		for (i = 0; i < 4; i = i + 1)
		begin : genBlock
			segment_driver_3
			(
				.clk(clk),
				.async_nreset(async_nreset),
				
				.next_segment_re(next_segment[i]),
				.change_mode_re(change_mode[i]),
				
				.display(display_tmp[i])
			);
		end
	endgenerate
	
	integer j;
	
	always @(*)
	begin
		for (j = 0; j < 4; j = j + 1)
		begin
			next_segment[j] <= 1'b0;
			change_mode[j] <= 1'b0;
		end
	
		case({sw_h_deb, sw_l_deb})
			2'b00:
			begin
				next_segment[0] <= next_segment_re;
				change_mode[0] <= change_mode_re;
			end
			2'b01:
			begin
				next_segment[1] <= next_segment_re;
				change_mode[1] <= change_mode_re;
			end
			2'b10:
			begin
				next_segment[2] <= next_segment_re;
				change_mode[2] <= change_mode_re;
			end
			2'b11:
			begin
				next_segment[3] <= next_segment_re;
				change_mode[3] <= change_mode_re;
			end
		endcase
	end
	
	always @(*)
	begin
	
		display0 <= {{sw_h_deb, sw_l_deb} == 2'b00, display_tmp[0][6:0]};
		display1 <= {{sw_h_deb, sw_l_deb} == 2'b01, display_tmp[1][6:0]};
		display2 <= {{sw_h_deb, sw_l_deb} == 2'b10, display_tmp[2][6:0]};
		display3 <= {{sw_h_deb, sw_l_deb} == 2'b11, display_tmp[3][6:0]};
	
	end
	
endmodule