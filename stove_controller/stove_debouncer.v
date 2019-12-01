module stove_debouncer
	#(
		parameter TIME_TO_WAIT
	)
	(
		input clk,
		input async_nreset,
		
		input signal_in,
		output signal_out
	);
	
	reg [31:0] counter_reg, counter_next;
	reg [1:0] ff_reg, ff_next;
	
	always @(*)
	begin
		
		ff_next[0] <= signal_in;
		ff_next[1] <= ff_reg[0];
		counter_next <= counter_reg;
		
		if (ff_reg[0] == ff_reg[1] && counter_reg < TIME_TO_WAIT)
			counter_next <= counter_reg + 32'd1;
		else
			counter_next <= 32'd0;
			
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
	
		if (!async_nreset)
		begin
		
			ff_reg <= 2'b00;
			counter_reg <= 32'd0;
		
		end
		else
		begin
		
			ff_reg <= ff_next;
			counter_reg <= counter_next;
		
		end
	
	end
	
	assign signal_out = (counter_reg == (TIME_TO_WAIT));
	
endmodule
