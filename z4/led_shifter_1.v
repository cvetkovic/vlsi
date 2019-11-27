module led_shifter_1
	(
		input clk,
		input async_reset_debounced,	
		
		input btn_0_re,
		input btn_1_re,
		
		output [7:0] led_output
	);
	
	reg [7:0] led_reg, led_next;
	
	always @(*)
	begin
		led_next <= led_reg;
		
		if (btn_0_re == 1'b1)
			led_next <= led_reg << 1;
		else if (btn_1_re == 1'b1)
			led_next <= (led_reg << 1) | 1'b1;
	end
	
	always @(posedge clk, negedge async_reset_debounced)
	begin
		if (async_reset_debounced == 1'b0)
			led_reg <= 8'd0;
		else
			led_reg <= led_next;
	end
	
	assign led_output = led_reg;
	
endmodule
