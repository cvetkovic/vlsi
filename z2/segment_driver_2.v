module segment_driver_2
	(
		input clk,
		input async_nreset,
		
		input next_segment_re,
		input change_mode_re,
		
		output reg [7:0] display
	);
	
	localparam STATE_A = 3'd0;
	localparam STATE_B = 3'd1;
	localparam STATE_C = 3'd2;
	localparam STATE_D = 3'd3;
	localparam STATE_E = 3'd4;
	localparam STATE_F = 3'd5;
	
	localparam FORWARD_MODE = 2'd0;
	localparam BACKWARD_MODE = 2'd1;
	localparam OFF_MODE = 2'd2;
	localparam CYCLIC_MODE = 2'd3;
	
	reg [2:0] state_reg, state_next;
	reg [1:0] mode_reg, mode_next;
	
	always @(*)
	begin
		state_next <= state_reg;
		mode_next <= mode_reg;
		
		if (change_mode_re)
		begin
			case (mode_reg)
				FORWARD_MODE:
					mode_next <= BACKWARD_MODE;
				BACKWARD_MODE:
					mode_next <= OFF_MODE;
				OFF_MODE:
					mode_next <= FORWARD_MODE;
				//CYCLIC_MODE:
			endcase
		end
		
		if (next_segment_re && (mode_reg != OFF_MODE))
		begin
			case (state_reg)
				STATE_A:
					if (mode_reg == FORWARD_MODE)
						state_next <= STATE_B;
					else if (mode_reg == BACKWARD_MODE)
						state_next <= STATE_F;
				STATE_B:
					if (mode_reg == FORWARD_MODE)
						state_next <= STATE_C;
					else if (mode_reg == BACKWARD_MODE)
						state_next <= STATE_A;
				STATE_C:
					if (mode_reg == FORWARD_MODE)
						state_next <= STATE_D;
					else if (mode_reg == BACKWARD_MODE)
						state_next <= STATE_B;
				STATE_D:
					if (mode_reg == FORWARD_MODE)
						state_next <= STATE_E;
					else if (mode_reg == BACKWARD_MODE)
						state_next <= STATE_C;
				STATE_E:
					if (mode_reg == FORWARD_MODE)
						state_next <= STATE_F;
					else if (mode_reg == BACKWARD_MODE)
						state_next <= STATE_D;
				STATE_F:
					if (mode_reg == FORWARD_MODE)
						state_next <= STATE_A;
					else if (mode_reg == BACKWARD_MODE)
						state_next <= STATE_E;
			endcase
		end
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (async_nreset == 1'b0)
		begin
			state_reg <= STATE_A;
			mode_reg <= FORWARD_MODE;
		end
		else
		begin
			state_reg <= state_next;
			mode_reg <= mode_next;
		end
	end
	
	always @(*)
	begin
		if (mode_reg == OFF_MODE)
			display <= 8'd0;
		else
			display <= {2'b0, 
						state_reg == STATE_F,
						state_reg == STATE_E,
						state_reg == STATE_D,
						state_reg == STATE_C,
						state_reg == STATE_B,
						state_reg == STATE_A};
	end
endmodule