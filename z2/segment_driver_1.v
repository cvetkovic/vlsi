module segment_driver_1
	(
		input clk,
		input async_nreset,
		
		input next_segment_re,
		
		output reg [7:0] display
	);
	
	localparam STATE_A = 3'd0;
	localparam STATE_B = 3'd1;
	localparam STATE_C = 3'd2;
	localparam STATE_D = 3'd3;
	localparam STATE_E = 3'd4;
	localparam STATE_F = 3'd5;
	
	reg [2:0] state_reg, state_next;
	
	always @(*)
	begin
		state_next <= state_reg;
		
		if (next_segment_re)
		begin
			case (state_reg)
				STATE_A:
					state_next <= STATE_B;
				STATE_B:
					state_next <= STATE_C;
				STATE_C:
					state_next <= STATE_D;
				STATE_D:
					state_next <= STATE_E;
				STATE_E:
					state_next <= STATE_F;
				STATE_F:
					state_next <= STATE_A;
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
	
	always @(*)
	begin
		display <= {2'b0, 
					state_reg == STATE_F,
					state_reg == STATE_E,
					state_reg == STATE_D,
					state_reg == STATE_C,
					state_reg == STATE_B,
					state_reg == STATE_A};
	end
endmodule