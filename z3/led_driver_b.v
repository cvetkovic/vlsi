module led_driver_b
	(
		input clk,
		input async_nreset,
	
		input btn_next_led_debounded,
		
		output reg [4:0] led_output
	);
	
	reg [3:0] state_reg, state_next;
	
	always @(*)
	begin
	
		state_next <= state_reg;
		
		if (btn_next_led_debounded == 1'b1)
		begin
			if (state_reg < 9)
				state_next <= state_reg + 4'd1;
			else
				state_next <= 4'd0;
		end
	
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (async_nreset == 1'b0)
			state_reg <= 4'd0;
		else
			state_reg <= state_next;
	end
	
	always @(*)
	begin
	
		led_output[0] <= ((state_reg == 4'd5) ? 1'b1 : 1'b0);
		led_output[1] <= ((state_reg >= 4'd4 || state_reg <= 4'd6) ? 1'b1 : 1'b0);
		led_output[2] <= ((state_reg >= 4'd3 || state_reg <= 4'd7) ? 1'b1 : 1'b0);
		led_output[3] <= ((state_reg >= 4'd2 || state_reg <= 4'd8) ? 1'b1 : 1'b0);
		led_output[4] <= ((state_reg >= 4'd1 || state_reg <= 4'd8) ? 1'b1 : 1'b0);
	
	end
	
endmodule