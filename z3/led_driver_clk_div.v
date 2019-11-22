module led_driver_clk_div
	(
		input clk,
		input async_nreset,
		
		output reg out_clk
	);
	
	reg [24:0] cnt_reg, cnt_next;
	
	always @(*)
	begin
		if (cnt_reg < (25'd25_000_000 - 25'd1))
			cnt_next <= cnt_reg + 25'd1;
		else
			cnt_next = 0;
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (async_nreset == 1'b0)
			cnt_reg <= 25'd0;
		else
			cnt_reg <= cnt_next;
	end
	
	always @(*)
	begin
		out_clk <= ((cnt_reg / 2 < 25'd12_499_999) ? 1'b0 : 1'b1);
	end
	
endmodule