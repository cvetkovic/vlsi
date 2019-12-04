module debounced_top
	(
		input clk,
		input async_nreset,
		
		input load,
		input incr,
		input clear,
		
		input sw7,
		
		input [1:0] key,
		input [3:0] data,
		output [3:0] out,
		output valid
	);
	
	wire [2:0] control;
	
	edge_detector
	#(
		.WIDTH(3),
		.EDGE(0)
	)
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.signal_in({clear, incr, load}),
		.signal_out(control)
	);
	
	reg [1:0] ctrl;
	
	localparam NONE = 2'd0;
	localparam LOAD = 2'd1;
	localparam INCR = 2'd2;
	localparam CLR = 2'd3;
	
	always @(*)
	begin
		ctrl <= NONE;
		
		if (control[0])
			ctrl <= LOAD;
		else if (control[1])
			ctrl <= INCR;
		else if (control[2])
			ctrl <= CLR;
	end
	
	associative_buffer
	#(
		.KEY_SIZE(2),
		.DATA_SIZE(4),
		.BUFFER_SIZE(4)
	)
	associative_buffer_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.ctrl(ctrl),
		.sw7(sw7),
		
		.key(key),
		.data_in(data),
		.data_out(out),
		.valid(valid)
	);
	
endmodule
