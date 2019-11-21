module segment_driver_c
	(
		input clk,
		input async_nreset,
		
		input btn_next_segment_re,
		input btn_mode_re,
		
		output [5:0] segments
	);

	wire divided_clk;
	wire divided_clk_re;
	
	clock_divider clock_divider_inst
	(
		.in_clk(clk),
		.async_nreset(async_nreset),
		.clock_mode(1'b1),
		.out_clk(divided_clk)
	);
	
	reg next_segment_driver;
	wire [1:0] driver_mode;
	
	segment_driver_b segment_driver_b_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.btn_next_segment_re(next_segment_driver),
		.btn_mode_re(btn_mode_re),
		
		.segments(segments),
		.current_mode(driver_mode)
	);
	
	rising_edge rising_edge_inst
	(
		.async_nreset(async_nreset),
		.in(divided_clk), 
		.clk(clk),
		.out(divided_clk_re)
	);
	
	always @(*)
	begin
		if (driver_mode == 2'b11)
			next_segment_driver <= divided_clk_re;
		else
			next_segment_driver <= btn_next_segment_re;
	end
	
endmodule
