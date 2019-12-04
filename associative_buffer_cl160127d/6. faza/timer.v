module timer
	(
		input clk,
		input async_nreset,
		
		input enable,
		input clear,
		output second_elapsed
	);
	
	reg [1:0] ctrl;
	reg [31:0] data_in;
	wire [31:0] data_out;
	
	register
	#(
		.WIDTH(32)
	)
	counter_reg
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.ctrl(ctrl),
		
		.data_in(data_in),
		.data_out(data_out)
	);
	
	localparam NONE = 2'd0;
	localparam LOAD = 2'd1;
	localparam INCR = 2'd2;
	localparam CLR = 2'd3;
	
	always @(*)
	begin
		ctrl <= NONE;
		
		if (enable)
		begin
			if (data_out <= 32'd49_999_998)
				ctrl <= INCR;
			else if (data_out == 32'd49_999_999)
				ctrl <= CLR;
		end
			
		if (clear)
			ctrl <= CLR;
	end
	
	assign second_elapsed = (data_out == 32'd49_999_999);
	
endmodule
