module led_driver_tb_1(input a);

	reg clk;
	reg async_nreset;
	
	reg next_led;
	reg change_mode;
	reg cyclic_mode;
	
	wire [4:0] led;
	
	initial
	begin
		clk <= 0;
		#1;
		
		forever
		begin
			clk <= ~clk;
			#1;
		end
	end
	
	led_driver_3 led_driver_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.next_led_re(next_led),
		.change_mode_re(change_mode),
		.btn_cylic_re(cyclic_mode),
		
		.led(led)
	);
	
	integer i;
	
	initial
	begin
	
		async_nreset <= 1'b1;
		#5;
		async_nreset <= 1'b0;
		#5;
		async_nreset <= 1'b1;
		
		for (i = 0; i < 100; i = i + 1)
		begin
			next_led <= 1'b1;
			#2;
			next_led <= 1'b0;
			#2;
		end
		
		#100;
		
		change_mode <= 1'b1;
		#2;
		change_mode <= 1'b0;
		#2;
		
		for (i = 0; i < 100; i = i + 1)
		begin
			next_led <= 1'b1;
			#2;
			next_led <= 1'b0;
			#2;
		end
		
		#100;
		
		change_mode <= 1'b1;
		#2;
		change_mode <= 1'b0;
		#2;
		
		// turn on cyclic mode
		cyclic_mode <= 1'b1;
		#2;
		cyclic_mode <= 1'b0;
		#2;
		
		#100;
		
		// turn off cyclic mode
		cyclic_mode <= 1'b1;
		#2;
		cyclic_mode <= 1'b0;
		#2;
		
		#100;
		
		
		change_mode <= 1'b1;
		#2;
		change_mode <= 1'b0;
		#2;
		
		// turn on cyclic mode
		cyclic_mode <= 1'b1;
		#2;
		cyclic_mode <= 1'b0;
		#2;
		
		#100;
		
		// turn off cyclic mode
		cyclic_mode <= 1'b1;
		#2;
		cyclic_mode <= 1'b0;
		#2;
		
		$finish();
	
	end
endmodule
