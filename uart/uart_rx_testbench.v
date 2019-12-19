module uart_rx_testbench;
	
	reg clk, async_nreset;
	
	reg data_in;
	wire [7:0] data_out;
	wire data_valid;

	uart_rx
	#(
		.BAUD_RATE(115_200),
		.EXTERNAL_CLOCK(50_000_000)
	)
	uart_rx_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.data_in(data_in),
		
		.data_out(data_out),
		.data_valid(data_valid)
	);
	
	localparam clk_cycle = 10;
	localparam clk_duty_cycle = 0.3;
	
	initial
	begin
		clk = 1'b1;
		forever begin
			if (clk == 1'b1)
				#(clk_cycle * clk_duty_cycle) clk = ~clk;
			else 
				#(clk_cycle * (1 - clk_duty_cycle)) clk = ~clk;
		end
	end
	
	initial
	begin
		
		data_in <= 1'b1;
		
		async_nreset = 1'b0;
		#(clk_cycle * 2.5);
		async_nreset = 1'b1;
		
		@(posedge clk);
		#(clk_cycle * 2);
		data_in <= 8'b1011_1101;
		
		// START BIT
		@(posedge clk);
		#(clk_cycle / 2);
		data_in <= 1'b0;
		
		@(posedge clk);
		#(clk_cycle * 3);
		// END START BIT
		
		//////////////////////////////////////////
		// DATA BIT 0
		@(posedge clk);
		#(clk_cycle / 2);
		data_in <= 1'b1;
		
		@(posedge clk);
		#(clk_cycle * 3);
		// END
		
		// DATA BIT 1
		@(posedge clk);
		#(clk_cycle / 2);
		data_in <= 1'b0;
		
		@(posedge clk);
		#(clk_cycle * 3);
		// END
		
		// DATA BIT 2
		@(posedge clk);
		#(clk_cycle / 2);
		data_in <= 1'b1;
		
		@(posedge clk);
		#(clk_cycle * 3);
		// END
		
		// DATA BIT 3
		@(posedge clk);
		#(clk_cycle / 2);
		data_in <= 1'b1;
		
		@(posedge clk);
		#(clk_cycle * 3);
		// END
		
		// DATA BIT 4
		@(posedge clk);
		#(clk_cycle / 2);
		data_in <= 1'b1;
		
		@(posedge clk);
		#(clk_cycle * 3);
		// END
		
		// DATA BIT 5
		@(posedge clk);
		#(clk_cycle / 2);
		data_in <= 1'b1;
		
		@(posedge clk);
		#(clk_cycle * 3);
		// END
		
		// DATA BIT 6
		@(posedge clk);
		#(clk_cycle / 2);
		data_in <= 1'b0;
		
		@(posedge clk);
		#(clk_cycle * 3);
		// END
		
		// DATA BIT 7
		@(posedge clk);
		#(clk_cycle / 2);
		data_in <= 1'b1;
		
		@(posedge clk);
		#(clk_cycle * 3);
		// END
		
		// PARITY
		@(posedge clk);
		#(clk_cycle / 2);
		data_in <= 1'b0;
		
		@(posedge clk);
		#(clk_cycle * 3);
		// END
		
		// STOP
		@(posedge clk);
		#(clk_cycle / 2);
		data_in <= 1'b1;
		
		@(posedge clk);
		#(clk_cycle * 3);
		// END
		
		@(posedge clk);
		#(clk_cycle / 2)
		
		$stop;
		
		$finish;
	end
	
endmodule
