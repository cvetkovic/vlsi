`timescale 1ns/1ps

module testbench_golden_vectors;

	reg rst, clk;
	reg activator;
	reg [2 : 0] buttons;
	reg [2 : 0] equalizer;
	wire [7 : 0] display;
	wire [9 : 0] indicator;
	
	localparam CLK_PERIOD = 20;
	// CLK_FREQUENCY = 50MHz => CLK_PERIOD = 20ns
	
	top
	design_under_test
		(
			.rst(rst),
			.clk(clk),
			.activator(activator),
			.buttons(buttons),
			.equalizer(equalizer),
			.display(display),
			.indicator(indicator)
		);

	initial begin
		clk = 1'b0;
		forever begin
			#(CLK_PERIOD / 2) clk = ~clk;
		end
	end
	
	integer i;
	
	initial begin
		rst = 1'b0;
		#(CLK_PERIOD * 2.5)
		rst = 1'b1;
		
		/***** TEST 1 *****/
		
		activator = 1'b1;
		buttons = 3'b000;
		equalizer = 3'b000;
		
		#(CLK_PERIOD * 10);
		
		for (i = 0; i < 3; i = i + 1) begin
			@(posedge clk);
			#(CLK_PERIOD / 4);
			buttons[2] = 1'b1;
			
			@(posedge clk);
			#(CLK_PERIOD / 4);
			buttons[2] = 1'b0;
		end
		
		#(CLK_PERIOD * 20);
		
		if (display != 8'hA4) begin
			$display("Output differs from the expected one");
			$stop;
		end
		
		/***** TEST 2 *****/
		
		activator = 1'b0;
		
		#(CLK_PERIOD * 10);
		
		activator = 1'b1;
		buttons = 3'b000;
		equalizer = 3'b000;
		
		#(CLK_PERIOD * 10);
		
		for (i = 0; i < 3; i = i + 1) begin
			@(posedge clk);
			#(CLK_PERIOD / 4);
			buttons[2] = 1'b1;
			
			@(posedge clk);
			#(CLK_PERIOD / 4);
			buttons[2] = 1'b0;
		end
		
		@(posedge clk);
		#(CLK_PERIOD / 4);
		equalizer[0] = 1'b1;
		
		#(CLK_PERIOD * 20);
		
		if (display != 8'h7F) begin
			$display("Output differs from the expected one");
			$stop;
		end
		
		/***** TEST 3 *****/
		
		activator = 1'b0;
		
		#(CLK_PERIOD * 10);
		
		activator = 1'b1;
		buttons = 3'b000;
		equalizer = 3'b000;
		
		#(CLK_PERIOD * 10);
		
		for (i = 0; i < 3; i = i + 1) begin
			@(posedge clk);
			#(CLK_PERIOD / 4);
			buttons[2] = 1'b1;
			
			@(posedge clk);
			#(CLK_PERIOD / 4);
			buttons[2] = 1'b0;
		end
		
		@(posedge clk);
		#(CLK_PERIOD / 4);
		equalizer[0] = 1'b1;
		
		@(posedge clk);
		#(CLK_PERIOD / 4);
		buttons[0] = 1'b1;
		
		@(posedge clk);
		#(CLK_PERIOD / 4);
		buttons[0] = 1'b0;
		
		#(CLK_PERIOD * 10);
		
		if (display != 8'hC0) begin
			$display("Output differs from the expected one");
			$stop;
		end
		
		$display("Design passed all tests");
		$stop;
	end

endmodule
