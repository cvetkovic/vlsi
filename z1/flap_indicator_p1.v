module flap_indicator
	(
		input clk,
		input async_nreset,
		
		input change_state_debounced,
		
		output up,
		output hor,
		output down
	);

	reg [1:0] state_reg, state_next;

	localparam UP = 0;
	localparam HORIZONTAL = 1;
	localparam DOWN = 2;

	always @(*)
	begin
	
		state_next <= state_reg;
		
		if (change_state_debounced == 1'b1)
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

	always @(posedge clk, negedge async_nreset)
	begin
	
		if (async_nreset == 1'b0)
		begin
			state_reg <= 2'd0;
		end
		else
		begin
			state_reg <= state_next;
		end
	
	end
	
	assign up = (state_reg == 2'b00);
	assign hor = (state_reg == 2'b01);
	assign down = (state_reg == 2'b10);

endmodule
