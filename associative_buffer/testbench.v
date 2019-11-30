module testbench;
	reg rst, clk;
	reg [1 : 0] ctrl;
	reg [1 : 0] key;
	reg [3 : 0] data_input;
 	wire [3 : 0] data_output;
	wire valid;

	associative_buffer
	#(
		.KEY_WIDTH(2),
		.DATA_WIDTH(4)
	)
	associative_buffer_instance
	(
		.rst(rst),
		.clk(clk),
		.ctrl(ctrl),
		.key(key),
		.data_input(data_input),
		.data_output(data_output),
		.valid(valid)
	);
	
	initial begin
		clk <= 1'b0;
		#10
		clk <= 1'b1;
		
		#20
		key <= 2'b01;
		data_input <= 4'b1110;
		ctrl <= 2'b01;				// LOAD (1, E)
		
		#30
		key <= 2'b01;
		ctrl <= 2'b10;				// INCR (1)
	end
	
	always @(*) begin
		#10
		clk <= ~clk;
	end
endmodule
