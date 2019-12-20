`timescale 1ns/1ps

module rmodule_prediction;

	reg clk, async_nreset;
	
	reg data_in;
	reg valid;
	
	wire [7:0] data_out;
	wire parity;
	wire more;
	
	rmodule
	#(
		.N(8),
		.M(3)
	)
	rmodule_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.data_in(data_in),
		.valid(valid),
		
		.data_out(data_out),
		.parity(parity),
		.more(more)
	);
	
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
	
	reg [7:0] expected_output;
	reg expected_parity;
	reg expected_more;
	
	localparam NUMBER_OF_ITERATIONS = 1000;
	integer i;
	
	event do_prediction;
	
	integer entered;
	
	initial
	begin
	
		entered = 0;
	
		async_nreset = 1'b0;
		#(clk_period * 2.5);
		async_nreset = 1'b1;
		
		@(posedge clk);
		#(clk_period / 4);
		data_in = $random;
		valid = $random;
		->do_prediction;
		entered = entered + 1;
		
		for (i = 0; i < NUMBER_OF_ITERATIONS; i = i + 1)
		begin
			
			@(posedge clk);
			#(clk_period / 4);
			if (data_out != expected_output) begin
				$display("Incorrect data output value at time %d.", $time);
				$stop;
			end
			else if (parity != expected_parity) begin
				$display("Incorrect parity value at time %d.", $time);
				$stop;
			end
			else if (more != expected_more) begin
				$display("Incorrect digit with more values at time %d.", $time);
				$stop;
			end
			#(clk_period / 4);
			data_in = $random;
			valid = $random;
			->do_prediction;
			if (entered < 8)
				entered = entered + 1;
		end
		
		@(posedge clk);
		#(clk_period / 2);
		
		$display("Simulation ended at time %d.", $time);
		$stop;
		
	end
	
	task automatic predict_output
		(
			input [7:0] old_data,
			input valid,
			input new_data
		);
		
		begin
			if (valid)
				expected_output = {old_data[6:0], new_data};
			else
				expected_output = old_data;
		end
	endtask
	
	task automatic predict_parity
		(
			input [7:0] old_data,
			input valid,
			input new_data
		);
		
		integer p;
		
		begin
		
			p = 0;
		
			if (valid)
			begin
			
				p = p ^ new_data;
				
				for (i = 0; i < 7 && i < entered - 1; i = i + 1)
				begin
					p = p ^ old_data[i];
				end
				
			end
			else
			begin
				
				for (i = 0; i < 8 && i < entered; i = i + 1)
				begin
					p = p ^ old_data[i];
				end
				
			end
			
			expected_parity = p[0];
		end
	endtask
	
	task automatic predict_more
		(
			input [7:0] old_data,
			input valid,
			input new_data
		);
		
		integer zero;
		integer one;
		integer i;
		
		begin
			zero = 0;
			one = 0;
		
			if (valid)
			begin
				if (new_data)
					one = one + 1;
				else
					zero = zero + 1;
					
				// from 0 to 2 because that will become 1 to 3 once shifted
				for (i = 0; i < 2; i = i + 1)
				begin
					if (old_data[i])
						one = one + 1;
					else
						zero = zero + 1;
				end
			end
			else
			begin
				for (i = 0; i < 3; i = i + 1)
				begin
					if (old_data[i])
						one = one + 1;
					else
						zero = zero + 1;
				end
			end
				
			if (one > zero)
				expected_more = 1'b1;
			else
				expected_more = 1'b0;
		end
	endtask
	
	
	always @(*)
	begin
	
		expected_output = 8'd0;
		expected_parity = 1'b0;
		expected_more = 1'b0;
		
		forever begin
			@(do_prediction);
			predict_output(data_out, valid, data_in);
			predict_parity(data_out, valid, data_in);
			predict_more(data_out, valid, data_in);
		end
	
	end
	
endmodule
