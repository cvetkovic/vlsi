module rmodule
	#(
		parameter N = 8,
		parameter M = 3
	)
	(
		input clk,
		input async_nreset,
		
		input data_in,
		input valid,
		
		output reg [N-1:0] data_out,
		output reg parity,
		output reg more
	);
	
	reg [N-1:0] data_buffer_reg, data_buffer_next;
	reg [31:0] entered_reg, entered_next;
	
	integer entered;
	
	always @(*)
	begin
		
		data_buffer_next <= data_buffer_reg;
		entered_next <= entered_reg;
		
		if (valid)
		begin
			data_buffer_next <= {data_buffer_reg[N-2:0], data_in};
			
			if (entered_reg < 32'd15)
				entered_next <= entered_reg + 32'd1;
		end
		
	end
	
	always @(posedge clk)
	begin
		if (!async_nreset)
		begin
			data_buffer_reg <= {N{1'b0}};
			entered_reg <= 32'd0;
		end
		else
		begin
			data_buffer_reg <= data_buffer_next;
			entered_reg <= entered_next;
		end
	end
	
	integer i, p;
	integer zero, one;
	
	always @(*)
	begin
		data_out <= data_buffer_reg;
		p = 0;
		
		for (i = 0; i < entered_reg && i < N; i = i + 1)
		begin
			p = p ^ data_buffer_reg[i];
		end
		
		parity <= p[0];
		
		/////////////////////////////////////////////////////////
		one = 0;
		zero = 0;
		
		for (i = 0; i < M; i = i + 1)
		begin
			if (data_buffer_reg[i] == 1'b1)
				one = one + 1;
			else
				zero = zero + 1;
		end
		
		if (one > zero)
			more <= 1'b1;
		else
			more <= 1'b0;
	end
	
endmodule
