module flap_indicator_1
	(
		input clk,
		input async_nreset,
		
		input change_position_re,
		
		output reg [7:0] display
	);
	
	reg [1:0] state_reg, state_next;
	
	localparam UP = 0;
	localparam HORIZONTAL = 1;
	localparam DOWN = 2;
	
	always @(*)
	begin
		state_next <= state_reg;
		
		if (change_position_re == 1'b1)
		begin
			case (state_reg)
				UP:
					state_next <= HORIZONTAL;
				HORIZONTAL:
					state_next <= DOWN;
				DOWN:
					state_next <= UP;
			endcase
		end
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (async_nreset == 1'b0)
			state_reg <= UP;
		else
			state_reg <= state_next;
	end
	
	always @(*)
	begin
		case (state_reg)
			UP:
				display <= 8'b0100_0000;
			HORIZONTAL:
				display <= 8'b1000_0000;
			DOWN:
				display <= 8'b0010_0000;
			default:
				display <= 8'd0;
		endcase
	end
	
endmodule