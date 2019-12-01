module led_driver_4
	(
		input clk,
		input async_nreset,
		
		input next_led_re,
		input change_mode_re,
		input btn_cylic_re,
		
		input sw_h_deb,
		input sw_l_deb,
		
		output reg [9:0] led,
		output reg [7:0] display0,
		output reg [7:0] display1
	);

	reg next_led [1:0];
	reg change_mode [1:0];
	reg cyclic [1:0];
	wire [4:0] led_output [1:0];
	
	genvar i;
	generate
		for (i = 0; i < 2; i = i + 1)
		begin : genBlock
			led_driver_3 led_driver_i
			(
				.clk(clk),
				.async_nreset(async_nreset),
				
				.next_led_re(next_led[i]),
				.change_mode_re(change_mode[i]),
				.btn_cylic_re(cyclic[i]),
				
				.led(led_output[i])
			);
		end
	endgenerate
	
	integer j;
	
	always @(*)
	begin
		for (j = 0; j < 2; j = j + 1)
		begin
			next_led[j] <= 1'b0;
			change_mode[j] <= 1'b0;
			cyclic[j] <= 1'b0;
		end
		
		display0 <= 8'd0;
		display1 <= 8'd0;
	
		if (sw_h_deb)
		begin
			next_led[1] <= next_led_re;
			change_mode[1] <= change_mode_re;
			cyclic[1] <= btn_cylic_re;
			
			display1 <= 8'b0101_1101;
		end
		
		if (sw_l_deb)
		begin
			next_led[0] <= next_led_re;
			change_mode[0] <= change_mode_re;
			cyclic[0] <= btn_cylic_re;
			
			display0 <= 8'b0101_1101;
		end
	
	end
	
	always @(*)
	begin
		led <= {led_output[1], led_output[0]};
	end
	
endmodule
