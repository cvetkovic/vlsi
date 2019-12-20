`timescale 1ns/1ps

module rmodule_wave_tb;

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
		#(clk_period / 2);
		data_in <= 1'b0;
		valid <= 1'b1;
		
		//////////////////	DATA 3	//////////////////
		@(posedge clk);
		#(clk_period / 2);
		data_in <= 1'b1;
		valid <= 1'b1;
		
		//////////////////	DATA 4	//////////////////
		@(posedge clk);
		#(clk_period / 2);
		data_in <= 1'b1;
		valid <= 1'b1;
		
		//////////////////	TEST0 	//////////////////
		@(posedge clk);
		#(clk_period / 2);
		data_in <= 1'b0;
		valid <= 1'b0;
		
		@(posedge clk);
		#(clk_period * 4);
		
		//////////////////	DATA 5	//////////////////
		@(posedge clk);
		#(clk_period / 2);
		data_in <= 1'b1;
		valid <= 1'b1;
		
		//////////////////	DATA 5	//////////////////
		@(posedge clk);
		#(clk_period / 2);
		data_in <= 1'b0;
		valid <= 1'b1;
		
		//////////////////	TEST1 	//////////////////
		@(posedge clk);
		#(clk_period / 2);
		data_in <= 1'b0;
		valid <= 1'b0;
		
		//////////////////	DATA 6	//////////////////
		@(posedge clk);
		#(clk_period / 2);
		data_in <= 1'b0;
		valid <= 1'b1;
		
		//////////////////	DATA 7	//////////////////
		@(posedge clk);
		#(clk_period / 2);
		data_in <= 1'b0;
		valid <= 1'b1;
		
		//////////////////	DATA 8	//////////////////
		@(posedge clk);
		#(clk_period / 2);
		data_in <= 1'b0;
		valid <= 1'b1;
		
		//////////////////	TEST2 	//////////////////
		@(posedge clk);
		#(clk_period / 2);
		data_in <= 1'b0;
		valid <= 1'b0;
		
		@(posedge clk);
		#(clk_period * 2);
		
		$stop;
	
	end
	
endmodule
