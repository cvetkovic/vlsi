module register
	#(
		parameter WIDTH = 8
	)
	(
		input clk,
		input async_nreset,
		input [WIDTH-1:0] data_in,
		input load,
		input inc,
		
		output reg [WIDTH-1:0] data_out
	);
	
	reg [WIDTH-1:0] data_reg, data_next;
	
	always @(*)
	begin
		data_next <= data_reg;
	
		if (load == 1'b1)
			data_next <= data_in;
		else if (inc == 1'b1)
			data_next <= data_reg + {{WIDTH-1{1'b0}}, 1'b1};
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (async_nreset == 1'b0)
			data_reg <= {WIDTH{1'b0}};
		else
			data_reg <= data_next;
	end
	
	always @(*)
	begin
		data_out <= data_reg;
	end
	
endmodule
