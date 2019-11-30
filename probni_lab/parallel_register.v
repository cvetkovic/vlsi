module parallel_register
	#(
		WIDTH = 8
	)
	(
		input clk,
		input async_nreset,
		
		input load,
		input inc,
		input clear,
		
		input [WIDTH-1:0] data_in,
		output [WIDTH-1:0] data_out
	);
	
	reg [WIDTH-1:0] data_reg, data_next;
	
	always @(*)
	begin
		data_next <= data_reg;
		
		if (load)
			data_next <= data_in;
		else if (inc)
			data_next <= data_reg + {{WIDTH-1{1'b0}}, 1'b1};
		else if (clear)
			data_next <= {WIDTH{1'b0}};
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (async_nreset == 1'b0)
			data_reg <= {WIDTH{1'b0}};
		else
			data_reg <= data_next;
	end
	
	assign data_out = data_reg;
	
endmodule
