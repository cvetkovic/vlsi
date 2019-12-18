module top
	(
		input rst,
		input clk,
		input activator,
		input [2 : 0] buttons,
		input [2 : 0] equalizer,
		output [7 : 0] display,
		output [9 : 0] indicator
	);
	
	wire activator_debounced;
	
	debouncer
	debouncer_instance
		(
			.rst(rst),
			.clk(clk),
			.signal_input(activator),
			.signal_output(activator_debounced)
		);
	
	wire [2 : 0] buttons_red;
	
	edge_detector
		#(
			.SIGNAL_WIDTH(3)
		)
	edge_detector_instance
		(
			.rst(rst),
			.clk(clk),
			.signal_input(buttons),
			.signal_output(buttons_red)
		);
	
	button_press_counter
	button_press_counter_instance
		(
			.rst(rst),
			.clk(clk),
			.activator(activator_debounced),
			.buttons(buttons_red),
			.equalizer(equalizer),
			.display(display),
			.indicator(indicator)
		);
	
endmodule
