module led_driver_c
	(
		input clk,
		input async_nreset,
	
		input btn_next_led_debounded,
		input btn_mode_debounced,
		input btn_cyclic_debounced,
		
		output reg [4:0] led_output
	);
	
	wire divided_clock;
	
	led_driver_clk_div led_driver_clk_div_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		.out_clk(divided_clock)
	);
	
	reg dr_a_btn;
	reg a_state_reg, a_state_next;
	wire [4:0] dr_a_out;
	
	led_driver_a led_driver_a_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		.btn_next_led_debounded(dr_a_btn),
		.led_output(dr_a_out)
	);
	
	reg dr_b_btn;
	reg b_state_reg, b_state_next;
	wire [4:0] dr_b_out;
	
	led_driver_b led_driver_b_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		.btn_next_led_debounded(dr_b_btn),
		.led_output(dr_b_out)
	);
	
	reg mode_reg, mode_next;
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (async_nreset == 1'b0)
		begin
			mode_reg <= 1'b0;
			a_state_reg <= 1'b0;
			b_state_reg <= 1'b0;
		end
		else
		begin
			mode_reg <= mode_next;
			a_state_reg <= a_state_next;
			b_state_reg <= b_state_next;
		end
	end
	
	always @(*)
	begin
		if (mode_reg == 1'b0)
			led_output <= dr_a_out;
		else
			led_output <= dr_b_out;	
	end
	
	always @(*)
	begin
		dr_a_btn <= 1'b0;
		dr_b_btn <= 1'b0;
	
		if (mode_reg == 1'b0)
		begin
			if (a_state_reg == 1'b0)
				dr_a_btn <= btn_next_led_debounded;
			else
				dr_a_btn <= divided_clock;
		end
		else 
		begin
			if (b_state_reg == 1'b0)
				dr_b_btn <= btn_next_led_debounded;
			else
				dr_b_btn <= divided_clock;
		end
	end
	
	always @(*)
	begin
	
		mode_next <= mode_reg;
		a_state_next <= a_state_reg;
		b_state_next <= b_state_reg;
	
		if (btn_mode_debounced == 1'b1)
		begin
			mode_next <= ~mode_reg;
		end
		
		if (btn_cyclic_debounced == 1'b1)
		begin
			if (mode_reg == 1'b0)
				a_state_next <= ~a_state_reg;
			else
				b_state_next <= ~b_state_reg;
		end
	
	end
	
endmodule
