module timer_tb;
	reg clk, async_nreset;
	reg timer_enabled;
	reg timer_clear;
	wire second_elapsed;
	wire half_second_elapsed;
	
	timer timer_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.enable(timer_enabled),
		.clear(timer_clear),
		
		.second_elapsed(second_elapsed),
		.half_second_elapsed(half_second_elapsed)
	);
	
	initial
	begin
		clk <= 1'b0;
		#1;
		
		forever
		begin
			clk <= ~clk;
			#1;
		end
	end
	
	initial
	begin
		async_nreset <= 1'b0;
		#5;
		async_nreset <= 1'b1;
		#5;
		
		timer_clear <= 1'b1;
		#2;
		timer_clear <= 1'b0;
		#2;
		
		#6;
		
		timer_enabled <= 1'b1;
		#100;
		
		$finish();
	end
	
endmodule
