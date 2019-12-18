`timescale 1ns/1ps

module testbench_predictor;

	reg rst, clk;
	reg activator;
	
	reg [2 : 0] buttons;
	reg [2 : 0] equalizer;
	
	wire [7 : 0] display;
	wire [9 : 0] indicator;
	
	wire [7 : 0] display_predicted;
	wire [9 : 0] indicator_predicted;
	
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
	
	predictive_top
	predictor
		(
			.rst(rst),
			.clk(clk),
			.activator(activator),
			.buttons(buttons),
			.equalizer(equalizer),
			.display(display_predicted),
			.indicator(indicator_predicted)
		);

	initial begin
		clk = 1'b0;
		forever begin
			#(CLK_PERIOD / 2) clk = ~clk;
		end
	end
	
	integer i, j;
	
	localparam ITERATIONS = 1000;
	
	initial begin
		rst = 1'b0;
		#(CLK_PERIOD * 2.5)
		rst = 1'b1;
		
		for (i = 0; i < ITERATIONS; i = i + 1) begin
			activator = 1'b0;
		
			#(CLK_PERIOD * 10);
			
			activator = 1'b1;
			buttons = 3'b000;
			equalizer = 3'b000;
			
			#(CLK_PERIOD * 10);
			
			for (j = 0; j < 4; j = j + 1) begin
				@(posedge clk);
				#(CLK_PERIOD / 4);
				buttons = $random;
				equalizer = $random;
				
				@(posedge clk);
				#(CLK_PERIOD / 4);
				buttons = 3'b000;
				equalizer = 3'b000;
			end
			
			@(posedge clk);
			#(CLK_PERIOD / 4);
			buttons = $random;
			
			@(posedge clk);
			#(CLK_PERIOD / 4);
			buttons = 3'b000;
			
			#(CLK_PERIOD * 10);
			
			if (display != display_predicted) begin
				$display("Output differs from the expected one");
				$stop;
			end
		end
		
		$display("Design passed all tests");
		$stop;
	end

endmodule
