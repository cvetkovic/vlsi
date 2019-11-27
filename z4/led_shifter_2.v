module led_shifter_2
	(
		input clk,
		input async_reset_debounced,	
		
		input btn_0_re,
		input btn_1_re,
		input parity_debounced,
		
		output [7:0] led_output,
		output reg [7:0] segment_output
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
	
	always @(posedge clk, negedge async_reset)
	begin
		if (async_reset == 1'b0)
			led_reg <= 8'd0;
		else
			led_reg <= led_next;
	end
	
	always @(*)
	begin
	
		if (parity_debounced == 1'b1)
			segment_output <= (~^led_reg == 1'b1 ? 8'b0000_0110 : 8'b0011_1111);
		else
			segment_output <= 8'd0;
	
	end
	
	assign led_output = led_reg;
	
endmodule
