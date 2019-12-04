`timescale 1ns/1ps

module testbench;
	reg rst;
	reg clk;
	reg [1 : 0] device_choice;
	reg [6 : 0] digit_choice;
	reg digit_load;
	reg digit_change;
	reg mode_change;
	wire [31 : 0] displays_flattened;
	wire digit_load_indicator;
	
	/*
	strange_device
	strange_device_instance
		(
			.rst(rst),
			.clk(clk),
			.digit_choice(digit_choice),
			.digit_load(digit_load),
			.digit_change(digit_change),
			.mode_change(mode_change),
			.display(display),
			.digit_load_indicator(digit_load_indicator)
		);
		
	integer i;
	
	initial begin
		clk <= 1'b0;
		#10
		clk <= 1'b1;
		
		rst <= 1'b0;
		#20
		rst <= 1'b1;
		
		digit_choice <= 7'b0000001;
		for (i = 0; i < 20; i = i + 1) begin
			#30
			digit_load <= 1'b1;
			#20
			digit_load <= 1'b0;
			#20
			digit_choice <= digit_choice + 7'd1;
		end
		
		for (i = 0; i < 20; i = i + 1) begin
			#40
			digit_change <= 1'b1;
			#20
			digit_change <= 1'b0;
		end
		
		mode_change <= 1'b1;
		#10
		mode_change <= 1'b0;
		
		#100
		
		mode_change <= 1'b1;
		#10
		mode_change <= 1'b0;
		
		digit_choice <= 7'b1000001;
		digit_load <= 1'b1;
		#10
		digit_load <= 1'b0;
	end
	*/
	
	top top_instance
		(
			.rst(rst),
			.clk(clk),
			.device_choice(device_choice),
			.digit_choice(digit_choice),
			.digit_load(digit_load),
			.digit_change(digit_change),
			.mode_change(mode_change),
			.displays_flattened(displays_flattened),
			.digit_load_indicator(digit_load_indicator)
		);
	
	initial begin
		clk <= 1'b0;
		#10
		clk <= 1'b1;
		
		rst <= 1'b0;
		#20
		rst <= 1'b1;
		
		digit_load <= 1'b0;
		device_choice <= 2'b00;
		digit_choice <= 7'b0000001;
		
		#30
		digit_load <= 1'b1;
		#20
		digit_load <= 1'b0;
		#20
		
		device_choice <= 2'b01;
		
		#30
		digit_load <= 1'b1;
		#20
		digit_load <= 1'b0;
		#20
		
		device_choice <= 2'b11;
		
		#30
		digit_load <= 1'b1;
		#20
		digit_load <= 1'b0;
	end
	
	always @(*) begin
		#10
		clk <= ~clk;
	end
	
endmodule
