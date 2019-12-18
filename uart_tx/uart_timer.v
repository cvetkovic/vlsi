module uart_timer
	(
		input clk,
		input async_nreset,
		
		input enable,
		input clear,
		
		output tick
	);
	
	reg [31:0] counter_reg, counter_next;
	
	localparam NUMBER_OF_TICKS = 32'd3;
	
	always @(*)
	begin
	
		counter_next <= counter_reg;
		
		if (enable)
		begin
		
			if (counter_reg < NUMBER_OF_TICKS)
				counter_next <= counter_reg + 32'd1;
			else if (counter_reg == NUMBER_OF_TICKS)
				counter_next <= 32'd0;
		
		end
		
		if (clear)
		begin
			counter_next <= 32'd0;
		end
	
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (!async_nreset)
			counter_reg <= 32'd0;
		else
			counter_reg <= counter_next;
	end
	
	assign tick = (counter_reg == NUMBER_OF_TICKS);
	
endmodule
