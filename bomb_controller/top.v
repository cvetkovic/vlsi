module top
	(
		input rst,
		input clk,
		input [3 : 0] trigger,
		output [7 : 0] hex0,
		output [7 : 0] hex1,
		output [7 : 0] hex2,
		output [7 : 0] hex3
	);
	
	localparam CTRL_WIDTH  = 3;
	localparam TIMER_WIDTH = 28;
	
	wire [(CTRL_WIDTH - 1) : 0] timer_ctrl;
	reg [(TIMER_WIDTH - 1) : 0] timer_data_input;
	wire [(TIMER_WIDTH - 1) : 0] timer_data_output;
	
	register
		#(
			.DATA_WIDTH(TIMER_WIDTH),
			.CTRL_WIDTH(CTRL_WIDTH)
		)
	timer
		(
			.rst(rst),
			.clk(clk),
			.ctrl(timer_ctrl),
			.data_input(timer_data_input),
			.data_output(timer_data_output)
		);
	
	controller
		#(
			.TIMER_WIDTH(TIMER_WIDTH),
			.CTRL_WIDTH(CTRL_WIDTH)
		)
	controller_instance
		(
			.rst(rst),
			.clk(clk),
			.trigger(trigger),
			.timer_input(timer_data_output),
			.timer_ctrl(timer_ctrl),
			.hex0(hex0),
			.hex1(hex1),
			.hex2(hex2),
			.hex3(hex3)
		);
	
endmodule
