module segment_driver_a
	(
		input clk,
		input async_nreset,
		
		input enable,
		input forward,
		input btn_next_segment_re,
		
		output [5:0] segments
	);
	
	reg [2:0] state_reg, state_next;
	
	localparam STATE_A = 0;
	localparam STATE_B = 1;
	localparam STATE_C = 2;
	localparam STATE_D = 3;
	localparam STATE_E = 4;
	localparam STATE_F = 5;
	
	always @(posedge clk)
	begin
		
		state_next <= state_reg;
		
		if (enable && btn_next_segment_re)
		begin
			case (state_reg)
				STATE_A:
					if (forward)
						state_next <= STATE_B;
					else
						state_next <= STATE_F;
				STATE_B:
					if (forward)
						state_next <= STATE_C;
					else
						state_next <= STATE_A;
				STATE_C:
					if (forward)
						state_next <= STATE_D;
					else
						state_next <= STATE_B;
				STATE_D:
					if (forward)
						state_next <= STATE_E;
					else
						state_next <= STATE_C;
				STATE_E:
					if (forward)
						state_next <= STATE_F;
					else
						state_next <= STATE_D;
				STATE_F:
					if (forward)
						state_next <= STATE_A;
					else
						state_next <= STATE_E;
			endcase
		end
		
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (async_nreset == 1'b0)
			state_reg <= STATE_A;
		else
			state_reg <= state_next;
	end
	
	wire [5:0] seg_temp = { state_reg == STATE_F,
								   state_reg == STATE_E,
									state_reg == STATE_D,
									state_reg == STATE_C,
									state_reg == STATE_B,
									state_reg == STATE_A };
	assign segments = seg_temp & {6{enable}};
	
endmodule