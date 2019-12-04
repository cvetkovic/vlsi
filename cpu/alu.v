module alu
	#(
		WIDTH = 8
	)
	(
		input [WIDTH-1:0] in_a,
		input [WIDTH-1:0] in_b,
		
		input operation,
		
		output reg [WIDTH-1:0] result,
		output reg carry
	);
	
	localparam ADD = 1'd0;
	localparam SUB = 1'd1;
	
	always @(*)
	begin
		case (operation)
			ADD:
				{carry, result} <= in_a + in_b;
			SUB:
				{carry, result} <= in_a - in_b;
		endcase
	end
	
endmodule
