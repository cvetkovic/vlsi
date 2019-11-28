module led_shifter_tv(input a);

	reg clk;
	reg async_nreset;
	
	reg button0;
	reg button1;
	
	reg show_parity;
	reg show_history;
	
	wire [7:0] out;
	wire [7:0] hex;
	
	led_shifter_3 led_shifter_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.button0_re(button0),
		.button1_re(button1),
		
		.show_parity_deb(show_parity),
		.show_history_deb(show_history),

		.out(out),
		.hex(hex)
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
	
	integer i;
	
	initial
	begin
		button0 <= 0;
		button1 <= 0;
		show_history <= 0;
		show_parity <= 0;
	
		async_nreset <= 1'b1;
		#5;
		async_nreset <= 1'b0;
		#5;
		async_nreset <= 1'b1;
		#4;
		
		for (i = 0; i < 3; i = i + 1)
		begin
		
			write0();
			write0();
			write0();
			write1();
			write1();
			write0();
			write0();
			write1();
			write1();
			write0();
		
		end
		
		#100;
		
		show_parity <= 1'b1;
		
		for (i = 0; i < 3; i = i + 1)
		begin
		
			write0();
			write0();
			write0();
			write1();
			write1();
			write0();
			write0();
			write1();
			write1();
			write0();
		
		end
		
		show_parity <= 1'b0;
		#2;
		show_history <= 1'b1;
		
		#1000;
		
		$finish();
	
	end

	task write0;
		begin
			button0 <= 1'b1;
			#2;
			button0 <= 1'b0;
			#2;
		end
	endtask

	task write1;
		begin
			button1 <= 1'b1;
			#2;
			button1 <= 1'b0;
			#2;
		end
	endtask
	
endmodule
