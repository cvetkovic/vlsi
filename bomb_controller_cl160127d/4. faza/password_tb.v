module password_tb;
	
	reg clk, async_nreset;
	reg btn0, btn1, btn2;
	reg mode;
	
	wire unlocked, explode;
	wire [3:0] led;
	
	password password_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.btn0(btn0),
		.btn1(btn1),
		.btn2(btn2),
		
		.mode(mode),
		
		.unlocked(unlocked),
		.explode(explode),
		
		.led(led)
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
		
		mode <= 1'b0;
		
		btn0 <= 1'b1;
		#2;
		btn0 <= 1'b0;
		#2;
		
		btn1 <= 1'b1;
		#2;
		btn1 <= 1'b0;
		#2;
		
		btn2 <= 1'b1;
		#2;
		btn2 <= 1'b0;
		#2;
		
		btn0 <= 1'b1;
		#2;
		btn0 <= 1'b0;
		#2;
		
		btn1 <= 1'b1;
		#2;
		btn1 <= 1'b0;
		#2;
		
		btn2 <= 1'b1;
		#2;
		btn2 <= 1'b0;
		#2;
		
		// unlock mode
		mode <= 1'b1;
		
		btn0 <= 1'b1;
		#2;
		
		#100;
		
		$finish();
	end
	
endmodule
