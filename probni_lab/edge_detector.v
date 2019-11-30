module edge_detector
	#(
		WIDTH = 2,
		EDGE = RISING_EDGE
	)
	(
		input clk,
		input async_nreset,
		
		input [WIDTH-1:0] signal_in,
		output reg [WIDTH-1:0] signal_out
	);
	
	localparam RISING_EDGE = 0;
	localparam FALLING_EDGE = 1;
	localparam BOTH_EDGES = 2;
	
	reg [WIDTH-1:0] ff_0_reg, ff_0_next;
	reg [WIDTH-1:0] ff_1_reg, ff_1_next;
	
	always @(*)
	begin
		ff_0_next <= signal_in;
		ff_1_next <= ff_0_reg;
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (async_nreset == 1'b0)
		begin
			ff_0_reg <= {WIDTH{1'b0}};
			ff_1_reg <= {WIDTH{1'b0}};
		end
		else
		begin
			ff_0_reg <= ff_0_next;
			ff_1_reg <= ff_1_next;
		end
	end
	
	always @(*)
	begin
		signal_out <= {WIDTH{1'b0}};
	
		if (EDGE == RISING_EDGE || EDGE == BOTH_EDGES)
			signal_out <= ~ff_0_reg & ff_1_reg;
		else if (EDGE == FALLING_EDGE || EDGE == BOTH_EDGES)
			signal_out <= ff_0_reg & ~ff_1_reg;
	end
	
endmodule
