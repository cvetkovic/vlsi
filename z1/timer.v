module timer
	(
		input clk,
		input async_nreset,
		
		input clear,
		input enable,
		
		output trigger
	);
	
	reg [31:0] counter_reg, counter_next;
	
	always @(*)
	begin
		counter_next <= counter_reg;
		
		if (clear == 1'b1)
			counter_next <= 32'd0;
		else if (enable == 1'b1)
		begin
			if (counter_reg < 32'd99_999_999)
				counter_next <= counter_reg + {{31{1'b0}}, 1'b1};
			else if (counter_reg == 32'd99_999_999)
				counter_next <= 32'd0;
		end
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (async_nreset == 1'b0)
			counter_reg <= 32'd0;
		else
			counter_reg <= counter_next;
	end
	
	assign trigger = (counter_reg == 32'd99_999_999);
		
endmodule