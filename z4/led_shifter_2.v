module led_shifter_2
	(
		input clk,
		input async_nreset,
		
		input button0_re,
		input button1_re,
		
		input show_parity_deb,
		
		output [7:0] out,
		output reg [7:0] hex
	);
	
	reg [7:0] number_reg, number_next;
	
	always @(*)
	begin
		number_next <= number_reg;
		
		if (button0_re)
			number_next <= (number_reg << 1) || 1'b0;
		else if (button1_re)
			number_next <= (number_reg << 1) || 1'b1;
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
	
	always @(*)
	begin
		
		hex <= 8'd0;
		
		if (show_parity_deb)
		begin
			case (~(^number_reg))
				1'b0:
					hex <= 8'b0011_1111;
				1'b1:
					hex <= 8'b0000_0011;
			endcase
		end
		
	end
	
endmodule