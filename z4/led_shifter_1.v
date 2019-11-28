module led_shifter_1
	(
		input clk,
		input async_nreset,
		
		input button0_re,
		input button1_re,
		
		output [7:0] out
	);
	
	reg [7:0] number_reg, number_next;
	
	always @(*)
	begin
		number_next <= number_reg;
		
		if (button0_re)
			number_next <= {number_reg[6:0], 1'b0};
		else if (button1_re)
			number_next <= {number_reg[6:0], 1'b1};
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (async_nreset == 1'b0)
		begin
			number_reg <= 8'd0;
		end
		else
		begin
			number_reg <= number_next;
		end
	end
	
	assign out = number_reg;
	
endmodule