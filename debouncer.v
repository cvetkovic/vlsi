module debouncer
	(
		input clk,
		input async_nreset,
		input in,
		
		output reg out
	);
	
	// here it is necessary the load operation to have priority over increment 
	// so that debouncer can function properly
	register
	#(
		.WIDTH(20)
	)
	register_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		.data_in(20'd0),
		.load(ctrl_load),
		.inc(ctrl_inc),
		.data_out(counter_output)
	);
	
	reg [1:0] ff_reg, ff_next;
	reg output_reg, output_next;
	
	reg ctrl_load, ctrl_inc;
	wire [19:0] counter_output;
	
	reg count_over;
	reg difference;
	
	always @(*)
	begin
		difference <= ff_reg[0] ^ ff_reg[1];
		ctrl_load <= difference | count_over;
		ctrl_inc <= ~difference;
		count_over <= 1'b0;
		
		ff_next[0] <= in;
		ff_next[1] <= ff_reg[0];
		output_next <= output_reg;
		
		// if DE0 board clock is 50 MHz then we want the input signal 
		// to be stable for 10 ms, hence 500 000 clock cycles are needed
		if (counter_output == 20'd500_000)
		begin
			count_over <= 1'b1;
			output_next <= ff_reg[1];
		end
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (async_nreset == 1'b0)
		begin
			ff_reg <= 2'b00;
			output_reg <= 1'b0;
		end
		else
		begin
			ff_reg <= ff_next;
			output_reg <= output_next;
		end
	end
	
	always @(*)
	begin
		out <= output_reg;
	end
	
endmodule
