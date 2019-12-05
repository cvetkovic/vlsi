module bomb_controller_tb;
	
	reg clk, async_nreset, start_countdown;
	wire [7:0] hex_output;

	bomb_controller controller_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.start_countdown(start_countdown),
		
		.hex_output(hex_output)
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
		
		start_countdown <= 1'b1;
		#2;
		start_countdown <= 1'b0;
		#2;
		
		#1000;
		
		$finish();
	end
	
endmodule
