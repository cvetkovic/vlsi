module bomb_timer
	(
		input clk,
		input async_nreset,
		
		input enabled,
		input clear,
		
		output half_second,
		output second
	);
		
	reg [1:0] ctrl;
	wire [31:0] data_out;
	
	localparam NONE = 2'd0;
	localparam LOAD = 2'd1;
	localparam INCR = 2'd2;
	localparam DECR = 2'd3;
	
	bomb_register 
	#(
		.WIDTH(32)
	)
	bomb_timer
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.ctrl(ctrl),
		.data_in(32'd0),
		.data_out(data_out)
	);
	
	always @(*)
	begin
	
		if (clear || data_out == 32'd49_999_999)
			ctrl <= LOAD;
		else if (enabled)
			ctrl <= INCR;
		else
			ctrl <= NONE;
	end
	
	assign half_second = (data_out == 32'd24_999_999 || data_out == 32'd49_999_999);
	assign second = (data_out == 32'd49_999_999);
	
endmodule
