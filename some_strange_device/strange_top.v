module strange_top
	#(
		parameter DIGIT_NUM = 7,
		parameter HISTORY_WIDTH = 4
	)
	(
		input rst,
		input clk,
		input [(DIGIT_NUM - 1) : 0] digit_choice,
		input digit_load,
		input digit_change,
		input mode_change,
		output [(7 - 1) : 0] display,
		output digit_load_indicator
	);
	
	wire digit_load_red, digit_change_red, mode_change_red;
	
	rising_edge_detector
	rising_edge_detector_instance_1
		(
			.rst(rst),
			.clk(clk),
			.signal_input(digit_load),
			.signal_output(digit_load_red)
		);
	
	rising_edge_detector
	rising_edge_detector_instance_2
		(
			.rst(rst),
			.clk(clk),
			.signal_input(digit_change),
			.signal_output(digit_change_red)
		);
	
	rising_edge_detector
	rising_edge_detector_instance_3
		(
			.rst(rst),
			.clk(clk),
			.signal_input(mode_change),
			.signal_output(mode_change_red)
		);
	
	strange_device
		#(
			.DIGIT_NUM(DIGIT_NUM),
			.HISTORY_WIDTH(HISTORY_WIDTH)
		)
	strange_device_instance
		(
			.rst(rst),
			.clk(clk),
			.digit_choice(digit_choice),
			.digit_load(digit_load_red),
			.digit_change(digit_change_red),
			.mode_change(mode_change_red),
			.display(display),
			.digit_load_indicator(digit_load_indicator)
		);
	
endmodule
