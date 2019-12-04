module edge_detector
	#(
		WIDTH = 1,
		EDGE = RISING_EDGE
	)
	(
		input clk,
		input async_nreset,
		
		input [WIDTH-1:0] signal_in,
		output reg [WIDTH-1:0] signal_out
	);

	reg [WIDTH-1:0] ff_reg [1:0], ff_next [1:0];
	
	localparam RISING_EDGE = 0;
	localparam FALLING_EDGE = 1;
	localparam BOTH_EDGES = 2;	
	
	always @(*)
	begin
		ff_next[0] <= signal_in;
		ff_next[1] <= ff_reg[0];
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (!async_nreset)
		begin
			ff_reg[0] <= {WIDTH{1'b0}};
			ff_reg[1] <= {WIDTH{1'b0}};
		end
		else
		begin
			ff_reg[0] <= ff_next[0];
			ff_reg[1] <= ff_next[1];
		end
	end
	
	always @(*)
	begin
		signal_out <= {WIDTH{1'b0}};
	
		if (EDGE == RISING_EDGE)
			signal_out <= ff_reg[0] & ~ff_reg[1];
		else if (EDGE == FALLING_EDGE || EDGE == BOTH_EDGES)
			signal_out <= ~ff_reg[0] & ff_reg[1];
	end
	
endmodule
