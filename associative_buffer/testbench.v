`timescale 1ns/1ps

module testbench;
	reg rst, clk;
	reg [1 : 0] ctrl;
	reg [1 : 0] key;
	reg [3 : 0] data_input;
 	wire [3 : 0] data_output;
	wire valid;
	
	localparam CTRL_NONE = 2'd0;
	localparam CTRL_CLR = 2'd1;
	localparam CTRL_LOAD = 2'd2;
	localparam CTRL_INCR = 2'd3;

	associative_buffer
		#(
			.KEY_WIDTH(2),
			.DATA_WIDTH(4),
			.BUFFER_SIZE(4)
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
		ctrl <= CTRL_LOAD;
		
		#20
		ctrl <= CTRL_NONE;
		
		#20
		ctrl <= CTRL_INCR;
		
		#20
		ctrl <= CTRL_NONE;
	end
	
	always @(*) begin
		#10
		clk <= ~clk;
	end
endmodule
