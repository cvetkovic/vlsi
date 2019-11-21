module flap_indicator
	(
		input clk,
		input async_nreset,
		
		input change_operation_mode_debounced,
		input change_state_debounced,
		
		output up,
		output hor,
		output down
	);

	reg [1:0] mode_reg, mode_next;
	reg [1:0] state_reg, state_next;

	localparam FLAP_MODE = 0;
	localparam OFF_MODE = 1;
	localparam CYCLIC_MODE = 2;

	localparam UP = 0;
	localparam HORIZONTAL = 1;
	localparam DOWN = 2;

	wire clock_mode = (mode_reg == CYCLIC_MODE ? 1'b1 : 1'b0);

	clock_divider clock_divider_inst
	(
		.in_clk(clk),
		.async_nreset(async_nreset),
		
		.clock_mode(clock_mode),
		
		.out_clk(out_clk)
	);

	always @(*)
	begin
	
		mode_next <= mode_reg;
		
		if (change_operation_mode_debounced == 1'b1)
		begin
		
			case (mode_reg)
				FLAP_MODE:
					mode_next <= OFF_MODE;
				OFF_MODE:
					mode_next <= CYCLIC_MODE;
				CYCLIC_MODE:
					mode_next <= OFF_MODE;
				default:
					mode_next <= OFF_MODE;
			endcase
		
		end
	
	end

	always @(*)
	begin
	
		state_next <= state_reg;
		
		if (change_state_debounced == 1'b1 && mode_reg == FLAP_MODE)
		begin
		
			case (state_reg)
			
				UP:
					state_next <= HORIZONTAL;
				HORIZONTAL:
					state_next <= DOWN;
				DOWN:
					state_next <= UP;
				default:
					state_next <= UP;
			
			endcase
			
		end
		
	end

	always @(posedge out_clk, negedge async_nreset)
	begin
	
		if (async_nreset == 1'b0)
			state_reg <= 2'd0;
		else
			state_reg <= state_next;
	
	end
	
	assign up = (mode_reg != OFF_MODE && state_reg == UP);
	assign hor = (mode_reg != OFF_MODE && state_reg == HORIZONTAL);
	assign down = (mode_reg != OFF_MODE && state_reg == DOWN);

endmodule
