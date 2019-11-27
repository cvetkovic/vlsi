module alu_unit
	#(
		parameter WIDTH = 8
	)
	(
		input [WIDTH-1:0] a,
		input [WIDTH-1:0] b,
		input operation,
		
	/*
		// no reg example
		output [(WIDTH - 1) : 0] result,
		output carry
	);
		
		assign { carry, result } = operation ? (a - b) : (a + b);
		
	*/
		
		output reg [WIDTH-1:0] sum,
		output reg carry
	);
	
	always @(*)
	begin
		if (operation == 1'b0)
			{carry, sum} <= a + b;
		else
			{carry, sum} <= a - b;
	end
	
endmodule
