module timer
	(
		input clk,
		input async_nreset,
		
		input clear,
		input enable,
		
		output reg trigger
	);
	
	reg [31:0] counter_reg, counter_next;
	
	always @(*)
	begin
		counter_next <= counter_reg;
		trigger <= 1'b0;
		
		if (clear)
			counter_next <= 32'd0;
		else if (enable)
		begin
			if (counter_reg < 32'd3)
				counter_next <= counter_reg + {{31{1'b0}}, 1'b1};
			else if (counter_reg == 32'd3)
			begin
				counter_next <= 32'd0;
				trigger <= 1'b1;
			end
		end
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (async_nreset == 1'b0)
			counter_reg <= 32'd0;
		else
			counter_reg <= counter_next;
	end
	
endmodule