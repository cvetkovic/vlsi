module rising_edge_detector
	(
		input rst,
		input clk,
		input signal_input,
		output signal_output
	);
	
	reg [1 : 0] ff_reg, ff_next;
	
	always @(negedge rst, posedge clk) begin
		if (!rst)
			ff_reg <= 2'b00;
		else
			ff_reg <= ff_next;
	end
	
	always @(*) begin
		ff_next = { ff_reg[0], signal_input };
	end
	
	assign signal_output = ff_reg[0] & ~ff_reg[1];
	
endmodule
