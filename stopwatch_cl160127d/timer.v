module timer
	(
		input clk,
		input async_nreset,
		
		input enabled,
		input clear,
		
		output reg elapsed_1s,
		output reg elapsed_100ms,
		output reg elapsed_10ms,
		output reg elapsed_1ms
	);
	
	reg [31:0] counter_second_reg, counter_second_next;
	reg [31:0] counter_tenth_reg, counter_tenth_next;
	reg [31:0] counter_hundred_reg, counter_hundred_next;
	reg [31:0] counter_thousand_reg, counter_thousand_next;
	
	always @(*)
	begin
		counter_second_next <= counter_second_reg;
		counter_tenth_next <= counter_tenth_reg;
		counter_hundred_next <= counter_hundred_reg;
		counter_thousand_next <= counter_thousand_reg;
	
		if (enabled)
		begin
			if (counter_second_reg <= 32'd49_999_998)
				counter_second_next <= counter_second_reg + 32'd1;
			else if (counter_second_reg == 32'd49_999_999)
				counter_second_next <= 32'd0;
				
			if (counter_tenth_reg <= 32'd4_999_998)
				counter_tenth_next <= counter_tenth_reg + 32'd1;
			else if (counter_tenth_reg == 32'd4_999_999)
				counter_tenth_next <= 32'd0;
			
			if (counter_hundred_reg <= 32'd499_998)
				counter_hundred_next <= counter_hundred_reg + 32'd1;
			else if (counter_hundred_reg == 32'd499_999)
				counter_hundred_next <= 32'd0;
				
			if (counter_thousand_reg <= 32'd49_998)
				counter_thousand_next <= counter_thousand_reg + 32'd1;
			else if (counter_thousand_reg == 32'd49_999)
				counter_thousand_next <= 32'd0;
		end
		
		if (clear)
		begin
			counter_second_next <= 32'd0;
			counter_tenth_next <= 32'd0;
			counter_hundred_next <= 32'd0;
			counter_thousand_next <= 32'd0;
		end
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (!async_nreset)
		begin
			counter_second_reg <= 32'd0;
			counter_tenth_reg <= 32'd0;
			counter_hundred_reg <= 32'd0;
			counter_thousand_reg <= 32'd0;
		end
		else
		begin
			counter_second_reg <= counter_second_next;
			counter_tenth_reg <= counter_tenth_next;
			counter_hundred_reg <= counter_hundred_next;
			counter_thousand_reg <= counter_thousand_next;
		end
	end
	
	always @(*)
	begin
		elapsed_1s <= 1'b0;
		elapsed_100ms <= 1'b0;
		elapsed_10ms <= 1'b0;
		elapsed_1ms <=  1'b0;
		
		if (counter_second_reg == 32'd49_999_999)
			elapsed_1s <= 1'b1;
		if (counter_tenth_reg == 32'd4_999_999)
			elapsed_100ms <= 1'b1;
		if (counter_hundred_reg == 32'd499_999)
			elapsed_10ms <= 1'b1;
		if (counter_thousand_reg == 32'd49_999)
			elapsed_1ms <= 1'b1;
	end
	
endmodule
