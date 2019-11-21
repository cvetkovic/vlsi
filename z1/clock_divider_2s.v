module clock_divider
	(
		input in_clk,
		input async_nreset,
		
		output out_clk
	);

	reg [31:0] counter;
	parameter max_cnt = 32'd100_000_000;
	
	always @(posedge clk, negedge async_nreset)
	begin
	
		if (async_nreset == 1'b0)
			counter <= 32'd0;
		else 
		begin
			if (counter < max_cnt - 1)
				counter <= counter + {31'd0, 1'd1};
			else
				counter <= 32'd0;
		end			
			
	end
	
	assign out_clk = (counter > max_cnt / 2 ? 1'b1 : 1'b0);
	
endmodule
