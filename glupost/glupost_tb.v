module glupost_tb;
	
	reg clk;
	
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
	
	reg async_nreset;
	
	reg [6:0] sw;
	reg btn2, btn1, btn0;
	
	wire led0;
	wire [3:0] bcd_output;
	
	glupost glupost_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.sw(sw),
		.btn2(btn2),
		.btn1(btn1),
		.btn0(btn0),
		
		.led0(led0),
		.bcd_output(bcd_output)
	);
	
	initial
	begin
		async_nreset <= 1'b0;
		#5;
		
		async_nreset <= 1'b1;
		#5;
		
		sw <= 7'b010_0000;
		btn2 <= 1'b1;
		#4;
		btn2 <= 1'b0;
		#6;
		
		sw <= 7'b110_0000;
		#10;
		btn2 <= 1'b1;
		#4;
		btn2 <= 1'b0;
		#6;
		
		sw <= 7'b000_0000;
		#10;
		
		btn1 <= 1'b1;
		#4;
		btn1 <= 1'b0;
		#4;
		
		#2;
		
		btn1 <= 1'b1;
		#4;
		btn1 <= 1'b0;
		#4;
		
		#2;
		
		btn1 <= 1'b1;
		#4;
		btn1 <= 1'b0;
		#4;
		
		#2;
		
		#100;
		
		// mode timer
		btn0 <= 1'b1;
		#2;
		btn0 <= 1'b0;
		#2;
		
		#1000;
		
		sw <= 7'b010_0000;
		btn2 <= 1'b1;
		#4;
		btn2 <= 1'b0;
		#6;
		
		#100;
		
		$finish();
	end
	
endmodule

	