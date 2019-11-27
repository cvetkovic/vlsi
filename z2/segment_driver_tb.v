module segment_driver_tb();

	reg clk;
	
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

	reg async_nreset;
	reg next_segment;
	reg change_mode;
	wire [7:0] display;

	segment_driver_3 driver
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.next_segment_re(next_segment),
		.change_mode_re(change_mode),
		
		.display(display)
	);

	integer i;

	initial
	begin
		async_nreset <= 1'b1;
		#5;
		
		async_nreset <= 1'b0;
		#5;
		
		async_nreset <= 1'b1;
		#5;
		
		for (i = 0; i < 100; i = i + 1)
		begin
			next_segment <= 1'b1;
			#2;
			next_segment <= 1'b0;
			#2;
		end
		
		#100;
		
		change_mode <= 1'b1;
		#2;
		change_mode <= 1'b0;
		#2;
		
		for (i = 0; i < 100; i = i + 1)
		begin
			next_segment <= 1'b1;
			#2;
			next_segment <= 1'b0;
			#2;
		end
		
		#100;
		change_mode <= 1'b1;
		#2;
		change_mode <= 1'b0;
				
		#100;
		change_mode <= 1'b1;
		#2;
		change_mode <= 1'b0;
		
		#1000;
		
		$finish();
	end

endmodule