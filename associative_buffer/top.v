module top
	#(
		parameter KEY_WIDTH = 2,
		parameter DATA_WIDTH = 4,
		parameter CTRL_WIDTH = 2
	)
	(
		input rst,
		input clk,
		input read_all,
		input [(CTRL_WIDTH - 1) : 0] ctrl,
		input [(KEY_WIDTH - 1) : 0] key_input,
		input [(DATA_WIDTH - 1) : 0] data_input,
		output [7 : 0] key_output,
		output [7 : 0] data_output,
		output valid
	);
	
	localparam SIZE = 2;
	localparam TIMER_WIDTH = 28;
	
	localparam RISING_EDGE = 0;
	localparam FALLING_EDGE = 1;
	localparam BOTH_EDGES = 2;
	
	wire read_all_red;
	wire [(CTRL_WIDTH - 1) : 0] ctrl_red;
	
	edge_detector
		#(
			.SIGNAL_NUM(1),
			.EDGE(RISING_EDGE)
		)
	edge_detector_instance_1
		(
			.rst(rst),
			.clk(clk),
			.signal_input(read_all),
			.signal_output(read_all_red)
		);
	
	edge_detector
		#(
			.SIGNAL_NUM(CTRL_WIDTH),
			.EDGE(RISING_EDGE)
		)
	edge_detector_instance_2
		(
			.rst(rst),
			.clk(clk),
			.signal_input(ctrl),
			.signal_output(ctrl_red)
		);
		
	wire [(KEY_WIDTH - 1) : 0] key_input_deb;
	wire [(DATA_WIDTH - 1) : 0] data_input_deb;
	
	debouncer
		#(
			.SIGNAL_NUM(KEY_WIDTH)
		)
	debouncer_instance_1
		(
			.rst(rst),
			.clk(clk),
			.signal_input(key_input),
			.signal_output(key_input_deb)
		);
	
	debouncer
		#(
			.SIGNAL_NUM(DATA_WIDTH)
		)
	debouncer_instance_2
		(
			.rst(rst),
			.clk(clk),
			.signal_input(data_input),
			.signal_output(data_input_deb)
		);
	
	wire [(CTRL_WIDTH - 1) : 0] timer_ctrl;
	wire [(TIMER_WIDTH - 1) : 0] timer_output;
	
	wire [(DATA_WIDTH - 1) : 0] buffer_data_output;
	
	associative_buffer
		#(
			.SIZE(SIZE),
			.KEY_WIDTH(KEY_WIDTH),
			.DATA_WIDTH(DATA_WIDTH),
			.CTRL_WIDTH(CTRL_WIDTH),
			.TIMER_WIDTH(TIMER_WIDTH)
		)
	associative_buffer_instance
		(
			.rst(rst),
			.clk(clk),
			.read_all(read_all_red),
			.ctrl(ctrl_red),
			.timer_input(timer_output),
			.timer_ctrl(timer_ctrl),
			.key(key_input_deb),
			.data_input(data_input_deb),
			.data_output(buffer_data_output),
			.valid(valid)
		);
	
	register
		#(
			.DATA_WIDTH(TIMER_WIDTH)
		)
	timer
		(
			.rst(rst),
			.clk(clk),
			.ctrl(timer_ctrl),
			.data_input({ TIMER_WIDTH{1'b0} }),
			.data_output(timer_output)
		);
		
	encoder key_encoder
		(
			.digit(key_input),
			.encoding(key_output)
		);
	
	encoder data_encoder
		(
			.digit(buffer_data_output),
			.encoding(data_output)
		);
	
endmodule
