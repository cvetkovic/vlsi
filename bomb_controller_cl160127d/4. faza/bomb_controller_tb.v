module bomb_controller_tb;
	
	reg clk, async_nreset, start_countdown;
	reg sw3, sw2, sw1;
	wire [7:0] hex_output3, hex_output2, hex_output1, hex_output0;

	bomb_controller controller_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.sw3(sw3),
		.sw2(sw2),
		.sw1(sw1),
		
		.start_countdown(start_countdown),
		
		.hex_output0(hex_output0),
		.hex_output1(hex_output1),
		.hex_output2(hex_output2),
		.hex_output3(hex_output3)
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
		
		sw1 <= 1'b1;
		
		start_countdown <= 1'b1;
		#2;
		start_countdown <= 1'b0;
		#2;
		
		#5000;
		
		$finish();
	end
	
endmodule
