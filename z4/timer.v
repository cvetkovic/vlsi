module timer
	(
		input clk,
		input async_nreset,
		
		input clear,
		input enable,
		
		output reg trigger1,
		output reg trigger2,
		output reg trigger3
	);
	
	reg [31:0] counter_reg, counter_next;
	reg [1:0] trigger_reg, trigger_next;
	
	always @(*)
	begin
		counter_next <= counter_reg;
		trigger_next <= trigger_reg;
		
		if (clear)
		begin
			counter_next <= 32'd0;
			trigger_next <= 1'b0;
		end
		else if (enable)
		begin
			if (counter_reg < 32'd3)
				counter_next <= counter_reg + {{31{1'b0}}, 1'b1};
			else if (counter_reg == 32'd3)
			begin
				counter_next <= 32'd0;
				if (trigger_reg < 2'd2)
					trigger_next <= trigger_reg + 2'd1;
				else
					trigger_next <= 2'd0;
			end
		end
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (async_nreset == 1'b0)
		begin
			counter_reg <= 32'd0;
			trigger_reg <= 1'b0;
		end
		else
		begin
			counter_reg <= counter_next;
			trigger_reg <= trigger_next;
		end
	end
	
	always @(*)
	begin
	
		trigger1 <= 1'b0;
		trigger2 <= 1'b0;
		trigger3 <= 1'b0;
		
		if (trigger_reg == 2'b00)
			trigger1 <= 1'b1;
		else if (trigger_reg == 2'b01)
			trigger2 <= 1'b1;
		else if (trigger_reg == 2'b10)
			trigger3 <= 1'b1;
	
	end
	
endmodule