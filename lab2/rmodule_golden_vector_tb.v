`timescale 1ns/1ps

module rmodule_golden_vector_tb;

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
	
	initial
	begin
	
		async_nreset = 1'b0;
		#(clk_period * 2.5);
		async_nreset = 1'b1;
		
		//////////////////	DATA 1	//////////////////
		@(posedge clk);
		#(clk_period / 2);
		data_in <= 1'b1;
		valid <= 1'b1;
		
		//////////////////	DATA 2	//////////////////
		@(posedge clk);
		#(clk_period / 4);
		if (data_out != 8'b0000_0001) begin
			$display("Incorrect data output value at time %d.", $time);
			$stop;
		end
		else if (parity != 1'b1) begin
			$display("Incorrect parity value at time %d.", $time);
			$stop;
		end
		else if (more != 1'b0) begin
			$display("Incorrect digit with more values at time %d.", $time);
			$stop;
		end
		#(clk_period / 4);
		data_in <= 1'b0;
		valid <= 1'b1;
		
		//////////////////	DATA 3	//////////////////
		@(posedge clk);
		#(clk_period / 4);
		if (data_out != 8'b0000_0010) begin
			$display("Incorrect data output value at time %d.", $time);
			$stop;
		end
		else if (parity != 1'b1) begin
			$display("Incorrect parity value at time %d.", $time);
			$stop;
		end
		else if (more != 1'b0) begin
			$display("Incorrect digit with more values at time %d.", $time);
			$stop;
		end
		#(clk_period / 4);
		data_in <= 1'b1;
		valid <= 1'b1;
		
		//////////////////	DATA 4	//////////////////
		@(posedge clk);
		#(clk_period / 4);
		if (data_out != 8'b0000_0101) begin
			$display("Incorrect data output value at time %d.", $time);
			$stop;
		end
		else if (parity != 1'b0) begin
			$display("Incorrect parity value at time %d.", $time);
			$stop;
		end
		else if (more != 1'b1) begin
			$display("Incorrect digit with more values at time %d.", $time);
			$stop;
		end
		#(clk_period / 4);
		data_in <= 1'b1;
		valid <= 1'b1;
		
		//////////////////	TEST0 	//////////////////
		@(posedge clk);
		#(clk_period / 4);
		if (data_out != 8'b0000_1011) begin
			$display("Incorrect data output value at time %d.", $time);
			$stop;
		end
		else if (parity != 1'b1) begin
			$display("Incorrect parity value at time %d.", $time);
			$stop;
		end
		else if (more != 1'b1) begin
			$display("Incorrect digit with more values at time %d.", $time);
			$stop;
		end
		#(clk_period / 4);
		data_in <= 1'b0;
		valid <= 1'b0;
		
		@(posedge clk);
		#(clk_period * 4);
		
		//////////////////	DATA 5	//////////////////
		@(posedge clk);
		#(clk_period / 4);
		if (data_out != 8'b0000_1011) begin
			$display("Incorrect data output value at time %d.", $time);
			$stop;
		end
		else if (parity != 1'b1) begin
			$display("Incorrect parity value at time %d.", $time);
			$stop;
		end
		else if (more != 1'b1) begin
			$display("Incorrect digit with more values at time %d.", $time);
			$stop;
		end
		#(clk_period / 4);
		data_in <= 1'b1;
		valid <= 1'b1;
		
		//////////////////	DATA 5	//////////////////
		@(posedge clk);
		#(clk_period / 4);
		if (data_out != 8'b0001_0111) begin
			$display("Incorrect data output value at time %d.", $time);
			$stop;
		end
		else if (parity != 1'b0) begin
			$display("Incorrect parity value at time %d.", $time);
			$stop;
		end
		else if (more != 1'b1) begin
			$display("Incorrect digit with more values at time %d.", $time);
			$stop;
		end
		#(clk_period / 4);
		data_in <= 1'b0;
		valid <= 1'b1;
		
		//////////////////	TEST1 	//////////////////
		@(posedge clk);
		#(clk_period / 4);
		if (data_out != 8'b0010_1110) begin
			$display("Incorrect data output value at time %d.", $time);
			$stop;
		end
		else if (parity != 1'b0) begin
			$display("Incorrect parity value at time %d.", $time);
			$stop;
		end
		else if (more != 1'b1) begin
			$display("Incorrect digit with more values at time %d.", $time);
			$stop;
		end
		#(clk_period / 4);
		data_in <= 1'b0;
		valid <= 1'b0;
		
		//////////////////	DATA 6	//////////////////
		@(posedge clk);
		#(clk_period / 4);
		if (data_out != 8'b0010_1110) begin
			$display("Incorrect data output value at time %d.", $time);
			$stop;
		end
		else if (parity != 1'b0) begin
			$display("Incorrect parity value at time %d.", $time);
			$stop;
		end
		else if (more != 1'b1) begin
			$display("Incorrect digit with more values at time %d.", $time);
			$stop;
		end
		#(clk_period / 4);
		data_in <= 1'b0;
		valid <= 1'b1;
		
		//////////////////	DATA 7	//////////////////
		@(posedge clk);
		#(clk_period / 4);
		if (data_out != 8'b0101_1100) begin
			$display("Incorrect data output value at time %d.", $time);
			$stop;
		end
		else if (parity != 1'b0) begin
			$display("Incorrect parity value at time %d.", $time);
			$stop;
		end
		else if (more != 1'b0) begin
			$display("Incorrect digit with more values at time %d.", $time);
			$stop;
		end
		#(clk_period / 4);
		data_in <= 1'b0;
		valid <= 1'b1;
		
		//////////////////	DATA 8	//////////////////
		@(posedge clk);
		#(clk_period / 4);
		if (data_out != 8'b1011_1000) begin
			$display("Incorrect data output value at time %d.", $time);
			$stop;
		end
		else if (parity != 1'b0) begin
			$display("Incorrect parity value at time %d.", $time);
			$stop;
		end
		else if (more != 1'b0) begin
			$display("Incorrect digit with more values at time %d.", $time);
			$stop;
		end
		#(clk_period / 4);
		data_in <= 1'b0;
		valid <= 1'b1;
		
		//////////////////	TEST2 	//////////////////
		@(posedge clk);
		#(clk_period / 4);
		if (data_out != 8'b0111_0000) begin
			$display("Incorrect data output value at time %d.", $time);
			$stop;
		end
		else if (parity != 1'b1) begin
			$display("Incorrect parity value at time %d.", $time);
			$stop;
		end
		else if (more != 1'b0) begin
			$display("Incorrect digit with more values at time %d.", $time);
			$stop;
		end
		#(clk_period / 4);
		data_in <= 1'b0;
		valid <= 1'b0;
		
		@(posedge clk);
		#(clk_period * 2);
		
		$stop;
	
	end
	
endmodule
