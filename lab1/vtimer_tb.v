`timescale 1ns/1ps

module vtimer_tb;

	reg clk, async_nreset;
	reg enable, clear;
	wire second_elapsed;

	vtimer vtimer_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.enable(enable),
		.clear(clear),
		
		.second_elapsed(second_elapsed)
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
	
	integer i;
	
	initial
	begin
		
		async_nreset = 1'b0;
		#(clk_period * 2.5);
		async_nreset = 1'b1;
		
		@(posedge clk);
		#(clk_period / 2);
		enable = 1'b1;
		
		for (i = 0; i < 2; i = i + 1)
		begin
			@(posedge clk);
		end
		
		@(posedge clk);
		#(clk_period / 4);
		if (second_elapsed != 1'b1) begin
			$display("Verification failed at time %d", $time);
			$stop;
		end
		#(clk_period / 4);
		
		@(posedge clk);
		#(clk_period / 2);
		
		$stop;
	end
	
endmodule
