module debouncer
	(
		input clk,
		input async_nreset,
		
		input signal_in,
		output signal_out
	);

	reg ff_reg [1:0], ff_next [1:0];
	reg out_reg, out_next;
	
	reg [1:0] counter_ctrl;
	wire [31:0] counter_data_out;
	
	register
	#(
		.WIDTH(32)
	)
	register_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.ctrl(counter_ctrl),
		.data_in(4'd0),
		.data_out(counter_data_out)
	);
	
	always @(*)
	begin
		ff_next[0] <= signal_in;
		ff_next[1] <= ff_reg[0];
		out_next <= out_reg;
		
		if (ff_reg[0] == ff_reg[1])
			counter_ctrl <= 2'd1;
		else
			counter_ctrl <= 2'd3;
			
		if (counter_data_out == 32'd5_000_000)
			out_next <= ff_reg[0];		
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (!async_nreset)
		begin
			ff_reg[0] <= 1'b0;
			ff_reg[1] <= 1'b0;
			out_reg <= 1'b0;
		end
		else
		begin
			ff_reg[0] <= ff_next[0];
			ff_reg[1] <= ff_next[1];
			out_reg <= out_next;
		end
	end
	
	assign signal_out = out_reg;
	
endmodule
