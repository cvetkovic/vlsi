module led_driver_d
	(
		input clk,
		input async_nreset,
		
		input btn_next_led_debounded,
		input btn_mode_debounced,
		input btn_cyclic_debounced,
		
		input sw_h_debounced,
		input sw_l_debounced,
		
		output [9:0] led_output,
		output reg [7:0] seg1,
		output reg [7:0] seg2
	);
	
	reg btn_next_1;
	reg btn_mode_1;
	reg btn_cyclic_1;
	
	led_driver_c led_driver_c_inst_1
	(
		.clk(clk),
		.async_nreset(async_nreset),
	
		.btn_next_led_debounded(btn_next_1),
		.btn_mode_debounced(btn_mode_1),
		.btn_cyclic_debounced(btn_cyclic_1),
		
		.led_output(led_output[4:0])
	);
	
	reg btn_next_2;
	reg btn_mode_2;
	reg btn_cyclic_2;
	
	led_driver_c led_driver_c_inst_2
	(
		.clk(clk),
		.async_nreset(async_nreset),
	
		.btn_next_led_debounded(btn_next_2),
		.btn_mode_debounced(btn_mode_2),
		.btn_cyclic_debounced(btn_cyclic_2),
		
		.led_output(led_output[9:5])
	);
	
	always @(*)
	begin
		btn_next_1 <= 1'b0;
		btn_mode_1 <= 1'b0;
		btn_cyclic_1 <= 1'b0;
	
		btn_next_2 <= 1'b0;
		btn_mode_2 <= 1'b0;
		btn_cyclic_2 <= 1'b0;
	
		if (sw_h_debounced == 1'b1)
		begin
			btn_next_1 <= btn_next_led_debounded;
			btn_mode_1 <= btn_mode_debounced;
			btn_cyclic_1 <= btn_cyclic_debounced;
		end
		
		if (sw_l_debounced == 1'b1)
		begin
			btn_next_2 <= btn_next_led_debounded;
			btn_mode_2 <= btn_mode_debounced;
			btn_cyclic_2 <= btn_cyclic_debounced;
		end
	end
	
	always @(*)
	begin
		seg1 <= 7'd0;
		seg2 <= 7'd0;
	
		if (sw_h_debounced == 1'b1)
		begin
			seg1 <= 7'b001_1111;
		end
		
		if (sw_l_debounced == 1'b1)
		begin
			seg2 <= 7'b001_1111;
		end
	end
	
endmodule
