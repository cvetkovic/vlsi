module timer
	(
		input clk,
		input async_nreset,
		
		input enable, 
		input clear,
		
		output second_elapsed
	);
	
	reg [1:0] counter_ctrl;
	reg [31:0] counter_data_in;
	wire [31:0] counter_data_out;
	
	localparam NONE = 2'd0;
	localparam INCR = 2'd1;
	localparam LOAD = 2'd2;
	localparam CLR = 2'd3;
	
	register 
	#(
		.WIDTH(32)
	)
	register_mode_counter
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.ctrl(counter_ctrl),
		.data_in(counter_data_in),
		.data_out(counter_data_out)
	);
	
	always @(*)
	begin
		counter_ctrl <= NONE;
	
		if (enable)
		begin
			if (counter_data_out <= 32'd2)
				counter_ctrl <= INCR;
			else if (counter_data_out == 32'd3)
				counter_ctrl <= CLR;
		end
		else if (clear)
			counter_ctrl <= CLR;	
	end
	
	assign second_elapsed = (counter_data_out == 32'd3);
	
endmodule
