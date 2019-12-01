module stove_1_tb();

	reg clk, async_nreset, sw_h, sw_l, child_lock, inc_pwr, dec_pwr, pwr;
	wire [7:0] left_hex, right_hex; 
	
	stove_1 inst
	(
		.clk(clk),
		.async_nreset(async_nreset),		// SW8
		
		.sw_h(sw_h),							// SW3
		.sw_l(sw_l),							// SW2
		
		.child_lock(child_lock),			// BTN3
		.inc_pwr(inc_pwr),					// BTN2
		.dec_pwr(dec_pwr),					// BTN1
	
		.pwr(pwr),								// BTN0
		
		.left_hex(left_hex),					// HEX3
		.right_hex(right_hex)				// HEX2
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
		
		pwr <= 1'b1;
		#2;
		pwr <= 1'b0;
		#2;
				
		sw_h <= 1'b0;
		sw_l <= 1'b0;
		inc_pwr <= 1'b1;
		child_lock <= 1'b1;
		#20;
		inc_pwr <= 1'b1;
		child_lock <= 1'b1;
		#100;
		pwr <= 1'b1;
		inc_pwr <= 1'b1;
		child_lock <= 1'b1;
		#20;
		pwr <= 1'b0;
		inc_pwr <= 1'b1;
		child_lock <= 1'b1;
		#20;
		inc_pwr <= 1'b0;
		child_lock <= 1'b0;
		
		#100;
		
		sw_h <= 1'b1;
		#2;
		
		inc_pwr <= 1'b1;
		#2;
		inc_pwr <= 1'b0;
		#2;
		
		sw_l <= 1'b1;
		#2;
		
		inc_pwr <= 1'b1;
		#2;
		inc_pwr <= 1'b0;
		#2;
		
		inc_pwr <= 1'b1;
		#2;
		inc_pwr <= 1'b0;
		#2;
		
		inc_pwr <= 1'b1;
		#2;
		inc_pwr <= 1'b0;
		#2;
		
		$finish();
	end
		
endmodule
