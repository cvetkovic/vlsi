module uart_tx_testbench;

	reg clk, async_nreset;
	
	reg [7:0] data_in;
	reg data_valid;
	wire data_out;

	uart_tx
	#(
		.BAUD_RATE(115_200),
		.EXTERNAL_CLOCK(50_000_000)
	)
	uart_tx_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.data_in(data_in),
		.data_valid(data_valid),
		
		.data_out(data_out)
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
		
		async_nreset = 1'b0;
		#(clk_cycle * 2.5);
		async_nreset = 1'b1;
		
		@(posedge clk);
		#(clk_cycle / 2);
		data_in <= 8'b1011_1101;
		
		@(posedge clk);
		#(clk_cycle / 2);
		data_valid <= 1'b1;
		
		// START BIT
		@(posedge clk);
		#(clk_cycle / 4);
		if (data_out != 1'b0) begin
			$display("Start bit expected at time %d", $time);
			$stop;
		end
		#(clk_cycle / 4);
		
		@(posedge clk);
		#(clk_cycle * 3);
		// END START BIT
		
		// DATA BIT 0
		@(posedge clk);
		#(clk_cycle / 4);
		if (data_out != 1'b1) begin
			$display("Data bit expected at time %d", $time);
			$stop;
		end
		#(clk_cycle / 4);
		
		@(posedge clk);
		#(clk_cycle * 3);
		// END
		
		// DATA BIT 1
		@(posedge clk);
		#(clk_cycle / 4);
		if (data_out != 1'b0) begin
			$display("Data bit expected at time %d", $time);
			$stop;
		end
		#(clk_cycle / 4);
		
		@(posedge clk);
		#(clk_cycle * 3);
		// END
		
		// DATA BIT 2
		@(posedge clk);
		#(clk_cycle / 4);
		if (data_out != 1'b1) begin
			$display("Data bit expected at time %d", $time);
			$stop;
		end
		#(clk_cycle / 4);
		
		@(posedge clk);
		#(clk_cycle * 3);
		// END
		
		// DATA BIT 3
		@(posedge clk);
		#(clk_cycle / 4);
		if (data_out != 1'b1) begin
			$display("Data bit expected at time %d", $time);
			$stop;
		end
		#(clk_cycle / 4);
		
		@(posedge clk);
		#(clk_cycle * 3);
		// END
		
		// DATA BIT 4
		@(posedge clk);
		#(clk_cycle / 4);
		if (data_out != 1'b1) begin
			$display("Data bit expected at time %d", $time);
			$stop;
		end
		#(clk_cycle / 4);
		
		@(posedge clk);
		#(clk_cycle * 3);
		// END
		
		// DATA BIT 5
		@(posedge clk);
		#(clk_cycle / 4);
		if (data_out != 1'b1) begin
			$display("Data bit expected at time %d", $time);
			$stop;
		end
		#(clk_cycle / 4);
		
		@(posedge clk);
		#(clk_cycle * 3);
		// END
		
		// DATA BIT 6
		@(posedge clk);
		#(clk_cycle / 4);
		if (data_out != 1'b0) begin
			$display("Data bit expected at time %d", $time);
			$stop;
		end
		#(clk_cycle / 4);
		
		@(posedge clk);
		#(clk_cycle * 3);
		// END
		
		// DATA BIT 7
		@(posedge clk);
		#(clk_cycle / 4);
		if (data_out != 1'b1) begin
			$display("Data bit expected at time %d", $time);
			$stop;
		end
		#(clk_cycle / 4);
		data_valid <= 1'b0;
		
		@(posedge clk);
		#(clk_cycle * 3);
		// END
		
		// PARITY BIT
		@(posedge clk);
		#(clk_cycle / 4);
		if (data_out != 1'b0) begin
			$display("Parity bit expected at time %d", $time);
			$stop;
		end
		#(clk_cycle / 4);
		data_valid <= 1'b0;
		
		@(posedge clk);
		#(clk_cycle * 3);
		// END
		
		// STOP BIT
		@(posedge clk);
		#(clk_cycle / 4);
		if (data_out != 1'b1) begin
			$display("Stop bit expected at time %d", $time);
			$stop;
		end
		#(clk_cycle / 4);
		data_valid <= 1'b0;
		
		@(posedge clk);
		#(clk_cycle * 3);
		// END
		
		// NOT TRANSMITING
		@(posedge clk);
		#(clk_cycle / 4);
		if (data_out != 1'b1) begin
			$display("Output should be high at time %d", $time);
			$stop;
		end
		#(clk_cycle / 4);
		data_valid <= 1'b0;
		
		@(posedge clk);
		#(clk_cycle * 3);
		// END
		
		// END OF SIMULATION FOR ONE BYTE SENDING VIA UART
		@(posedge clk);
		#(clk_cycle * 20);
		
		$stop;
	end
	
endmodule
