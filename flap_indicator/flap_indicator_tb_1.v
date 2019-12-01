module flap_indicator_tb_1(input a);

	reg clk;
	
	initial
	begin
		clk <= 0;
		#1;
		
		forever 
		begin
			#1 clk = ~clk;
		end
	end
	
	reg change_position;
	reg change_mode;
	
	reg async_nreset;
	
	wire [7:0] display;
	
	flap_indicator_3 flap_indicator_3_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.change_position_re(change_position),
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
		
		for (i = 0; i < 1000; i = i + 1)
		begin
			change_position <= 1'b1;
			#1;
			change_position <= 1'b0;
			#1;
		end
		
		change_mode <= 1'b1;
		#1;
		change_mode <= 1'b0;
		#1;
		
		#100;
		
		change_mode <= 1'b1;
		#1;
		change_mode <= 1'b0;
		#1;
		
		// test of cyclic mode
		#300;
		
		change_mode <= 1'b1;
		#1;
		change_mode <= 1'b0;
		#1;
		
		for (i = 0; i < 1000; i = i + 1)
		begin
			change_position <= 1'b1;
			#1;
			change_position <= 1'b0;
			#1;
		end
		
		$finish();
	
	end
	
endmodule
