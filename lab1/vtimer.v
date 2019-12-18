module vtimer
	(
		input clk,
		input async_nreset,
		
		input enable,
		input clear,
		
		output second_elapsed
	);

	localparam NONE = 2'd0;
	localparam LOAD = 2'd1;
	localparam INCR = 2'd2;
	localparam DECR = 2'd3;
	
	reg [31:0] cnt_in;
	reg [1:0] cnt_ctrl;
	wire [31:0] cnt_out;
	
	vregister
	#(
		.WIDTH(32)
	)
	vregister_cnt
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.data_in(cnt_in),
		.ctrl(cnt_ctrl),
		.data_out(cnt_out)
	);
	
	always @(*)
	begin
	
		cnt_in <= 32'd0;
		cnt_ctrl <= NONE;
	
		if (enable)
		begin
			if (cnt_out < 32'd3)
				cnt_ctrl <= INCR;
			else if (cnt_out == 32'd3)
			begin
				cnt_in <= 32'd0;
				cnt_ctrl <= LOAD;
			end
		end
		
		if (clear)
		begin
			cnt_in <= 32'd0;
			cnt_ctrl <= LOAD;
		end
	
	end
	
	assign second_elapsed = (cnt_out == 32'd3);
	
endmodule
