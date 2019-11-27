module segment_driver_top
	(
		input clk,
		input async_nreset,
		
		input next_segment_raw,
		input change_mode_raw,
		
		input sw_h_raw,
		input sw_l_raw,
		
		output [7:0] display0,
		output [7:0] display1,
		output [7:0] display2,
		output [7:0] display3
	);
	
	wire next_segment;
	wire change_mode;
	
	wire sw_h;
	wire sw_l;
	
	rising_edge rising_edge_segment
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.in(next_segment_raw),
		.out(next_segment)
	);
	
	rising_edge rising_edge_mode
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.in(change_mode_raw),
		.out(change_mode)
	);
	
	debouncer debunder_h
	(
		.clk(clk),
		.async_nreset(async_nreset),
		.in(sw_h_raw),
		
		.out(sw_h)
	);
	
	debouncer debouncer_l
	(
		.clk(clk),
		.async_nreset(async_nreset),
		.in(sw_l_raw),
		
		.out(sw_l)
	);
	
	segment_driver_4 driver_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.next_segment_re(next_segment),
		.change_mode_re(change_mode),
		
		.sw_h_deb(sw_h),
		.sw_l_deb(sw_l),
		
		.display0(display0),
		.display1(display1),
		.display2(display2),
		.display3(display3)
	);
	
endmodule
