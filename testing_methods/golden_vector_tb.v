`timescale 1ns/1ps

module golden_vector_tb;
	
	reg clk, async_nreset;
	reg [2:0] ctrl;
	reg serial_data_input;
	reg [7:0] parallel_data_input;
	wire [7:0] data_output;
	
	register
	#(
		.WIDTH(8)
	)
	register_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.ctrl(ctrl),
		
		.serial_data_input(serial_data_input),
		.parallel_data_input(parallel_data_input),
		
		.data_output(data_output)
	);
	
	localparam NONE = 3'd0;
	localparam CLR = 3'd1;
	localparam PARALLEL_LOAD = 3'd2;
	localparam SERIAL_MSB_LOAD = 3'd3;
	localparam SERIAL_LSB_LOAD = 3'd4;
	localparam SHIFT_LOGICAL_LEFT = 3'd5;
	localparam SHIFT_LOGICAL_RIGHT = 3'd6;
	
	localparam clk_period = 10;
	localparam clk_duty_cycle = 0.3;
	
	initial
	begin
	
		clk = 1'b1;
		
		forever
		begin
		
			if (clk == 1'b1)
				#(clk_period * clk_duty_cycle) clk = ~clk;
			else
				#(clk_period * (1 - clk_duty_cycle)) clk = ~clk;
		
		end
	
	end
	
	initial
	begin
	
		async_nreset = 1'b0;
		#(clk_period * 2.5);
		async_nreset = 1'b1;
		
		@(posedge clk);
		#(clk_period / 2);
		parallel_data_input = 8'b0000_1111;
		ctrl = PARALLEL_LOAD;
		
		@(posedge clk);
		#(clk_period / 4);
		$display("At time %d 'data_output' has value %b", $time, data_output);
		if (data_output != 8'b0000_1111)
			$display("Output differs from the expected one");
		$stop;
		#(clk_period / 4);
		serial_data_input = 1'b1;
		ctrl = SERIAL_MSB_LOAD;
		
		@(posedge clk);
		#(clk_period / 4);
		$display("At time %d 'data_output' has value %b", $time, data_output);
		if (data_output != 8'b1000_0111)
			$display("Output differs from the expected one");
		#(clk_period / 4);
		$stop;
		
		@(posedge clk);
		#(clk_period / 2);
		$stop;
	
	end
	
endmodule
