module stopwatch_top
	(
		input clk,
		input async_nreset,
		
		input start,
		input pause,
		input stop,
		
		output [7:0] hex0,
		output [7:0] hex1,
		output [7:0] hex2,
		output [7:0] hex3
	);

	wire start_re, pause_re, stop_re;
	
	rising_edge_detector re_start
	(
		.rst(async_nreset),
		.clk(clk),
		.signal_input(start),
		.signal_output(start_re)
	);
	rising_edge_detector re_pause
	(
		.rst(async_nreset),
		.clk(clk),
		.signal_input(pause),
		.signal_output(pause_re)
	);
	rising_edge_detector re_stop
	(
		.rst(async_nreset),
		.clk(clk),
		.signal_input(stop),
		.signal_output(stop_re)
	);
	
	stopwatch stopwatch_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.start(start_re),
		.pause(pause_re),
		.stop(stop_re),
		
		.hex0(hex0),
		.hex1(hex1),
		.hex2(hex2),
		.hex3(hex3)
	);
	
endmodule
