module top
	(
		input rst,
		input clk,
		input [1 : 0] decimal_places,
		input start,
		input pause,
		input stop,
		output [7 : 0] display0,
		output [7 : 0] display1,
		output [7 : 0] display2,
		output [7 : 0] display3,
		output pause_indicator
	);
	
	wire start_red, pause_red, stop_red;
	
	rising_edge_detector
	rising_edge_detector_start
		(
			.rst(rst),
			.clk(clk),
			.signal_input(start),
			.signal_output(start_red)
		);
	
	rising_edge_detector
	rising_edge_detector_pause
		(
			.rst(rst),
			.clk(clk),
			.signal_input(pause),
			.signal_output(pause_red)
		);
	
	rising_edge_detector
	rising_edge_detector_stop
		(
			.rst(rst),
			.clk(clk),
			.signal_input(stop),
			.signal_output(stop_red)
		);
	
	stopwatch
	stopwatch_instance
		(
			.rst(rst),
			.clk(clk),
			.decimal_places(decimal_places),
			.start(start_red),
			.pause(pause_red),
			.stop(stop_red),
			.display0(display0),
			.display1(display1),
			.display2(display2),
			.display3(display3),
			.pause_indicator(pause_indicator)
		);
	
endmodule
