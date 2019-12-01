module timer
	(
		input clk,
		input async_nreset,
		
		input enabled,
		
		output ten_seconds_elapsed
	);

	reg [31:0] counter_reg, counter_next;
	
	always @(*)
	begin
	
		counter_next <= counter_reg;
	
		if (enabled)
		begin
			if (counter_reg <= 32'd500_000_000)
				counter_next <= counter_reg + {{31{1'b0}}, 1'b1};
			else
				counter_next <= 32'd1;
		end
	
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
	
		if (async_nreset == 1'b0)
		begin
			counter_reg <= {32{1'b0}};
		end
		else
		begin
			counter_reg <= counter_next;
		end
		
	end
	
	assign ten_seconds_elapsed = enabled && (counter_reg == 32'd500_000_000);
	
endmodule
