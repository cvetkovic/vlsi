module vdevice_tb;
	
	reg clk, async_nreset;
	reg start, reset;
	reg btn2, btn1, btn0;
	wire [7:0] counter_2, counter_1, counter_0;
	
	vdevice vdevice_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.start(start),
		.reset(reset),
		
		.btn2(btn2),
		.btn1(btn1),
		.btn0(btn0),
		
		.counter_2(counter_2),
		.counter_1(counter_1),
		.counter_0(counter_0)
	);
	
	localparam clk_period = 10;
	localparam clk_duty_cycle = 0.3;
	
	integer i;
	
	initial
	begin
		clk = 1'b1;
		forever begin
			if (clk == 1'b1)
				#(clk_period * clk_duty_cycle) clk = ~clk;
			else
				#(clk_period * (1 - clk_duty_cycle)) clk = ~clk;
		end
	end
	
	initial
	begin
		
		async_nreset = 1'b0;
		#(clk_period * 2.5);
		async_nreset = 1'b1;
		
		@(posedge clk);
		#(clk_period / 2);
		start <= 1'b1;
		
		@(posedge clk);
		#(clk_period / 2);
		start <= 1'b0;
		btn1 <= 1'b1;
		
		@(posedge clk);
		#(clk_period / 2);
		btn2 <= 1'b1;
		btn1 <= 1'b1;
		
		@(posedge clk);
		#(clk_period / 2);
		btn2 <= 1'b0;
		btn1 <= 1'b0;
		
		for (i = 0; i < 150; i = i + 1)
		begin
			@(posedge clk);
		end
		
		$stop;
		
	end
	
endmodule
