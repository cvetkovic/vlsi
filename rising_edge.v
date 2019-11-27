module rising_edge
	(
		input clk,
		input in,
		input async_nreset,
		
		output reg out
	);
	
	reg [1:0] ff_reg, ff_next;
	
	always @(*)
	begin
		ff_next[0] <= in;
		ff_next[1] <= ff_reg[1];
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (async_nreset == 1'b0)
			ff_reg <= 2'b00;
		else
			ff_reg <= ff_next;
	end
	
	always @(*)
	begin
		out <= ~ff_reg[1] & ff_reg[0];
	end
	
endmodule
