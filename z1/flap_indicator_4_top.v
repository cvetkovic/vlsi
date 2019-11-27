module flap_indicator_4_top
	(
		input clk,
		input async_nreset,
		
		input change_position,
		input change_mode,
		
		input sw_h,
		input sw_l,
		
		output [7:0] display1,
		output [7:0] display2,
		output [7:0] display3,
		output [7:0] display4
	);
	
	wire change_position_re;
	wire change_mode_re;
	
	wire sw_h_deb;
	wire sw_l_deb;
		
	rising_edge re_position
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.in(change_position),
		.out(change_position_re)
	);
	
	rising_edge re_mode
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.in(change_mode),
		.out(change_mode_re)
	);
	
	debouncer debouncer_h
	(
		.clk(clk),
		.async_nreset(async_nreset),
		.in(sw_h),
		
		.out(sw_h_deb)
	);
	
	debouncer debouncer_l
	(
		.clk(clk),
		.async_nreset(async_nreset),
		.in(sw_l),
		
		.out(sw_l_deb)
	);
	
	flap_indicator_4
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.change_position_re(change_position_re),
		.change_mode_re(change_mode_re),
		
		.sw_h_deb(sw_h_deb),
		.sw_l_deb(sw_l_deb),
		
		.display1(display1),
		.display2(display2),
		.display3(display3),
		.display4(display4)
	);
	
endmodule
