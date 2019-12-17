`timescale 1ns/1ps;

module predictive_tb;

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
		forever begin
			if (clk == 1'b1)
				#(clk_period * clk_duty_cycle) clk = ~clk;
			else
				#(clk_period * (1 - clk_duty_cycle)) clk = ~clk;
		end
		
	end
	
	reg [7:0] expected_data_output;
	localparam NUMBER_OF_ITERATIONS = 1000;
	event calculate_prediction;
	
	integer i;
	
	initial
	begin
	
		async_nreset = 1'b0;
		#(clk_period * 2.5);
		async_nreset = 1'b1;
		
		@(posedge clk);
		#(clk_period / 4);
		ctrl = $random;
		parallel_data_input = $random;
		serial_data_input = $random;
		->calculate_prediction;
		
		for (i = 0; i < NUMBER_OF_ITERATIONS; i = i + 1)
		begin
			@(posedge clk);
			#(clk_period / 4);
			if (data_output != expected_data_output) begin
				$display("Data output differs from the expected value.");
				$stop;
			end
			#(clk_period / 4);
			ctrl = $random;
			parallel_data_input = $random;
			serial_data_input = $random;
			->calculate_prediction;
		end
		
		@(posedge clk);
		#(clk_period / 2);
		$done;
	
	end
	
	task automatic calculate_output
		(
			input [2:0] ctrl,
			input serial_data_input,
			input [7:0] parallel_data_input
		);
		begin
			
			case (ctrl)
				CLR:
					expected_data_output = 8'd0;
				PARALLEL_LOAD:
					expected_data_output = parallel_data_input;
				SERIAL_MSB_LOAD:
					expected_data_output = {serial_data_input, expected_data_output[7:1]};
				SERIAL_LSB_LOAD:
					expected_data_output = {expected_data_output[6:0], serial_data_input};
				SHIFT_LOGICAL_LEFT:
					expected_data_output = {expected_data_output[6:0], 1'b0};
				SHIFT_LOGICAL_RIGHT:
					expected_data_output = {1'b0, expected_data_output[7:1]};
				default:
				begin
				
				end
			endcase
			
		end
	endtask
	
	initial
	begin
		expected_data_output = 8'd0;
		forever begin
			@(calculate_prediction);
			calculate_output(ctrl, serial_data_input, parallel_data_input);
		end
	end
	
endmodule
