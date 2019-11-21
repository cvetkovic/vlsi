module segment_driver_d
	(
		input clk,
		input async_nreset,
		
		input btn_next_segment,
		input btn_mode,
		
		input sw_h,
		input sw_l,
		
		output [5:0] segments1,
		output reg dot1,
		output [5:0] segments2,
		output reg dot2,
		output [5:0] segments3,
		output reg dot3,
		output [5:0] segments4,
		output reg dot4
	);
	
	wire [1:0] active;
	
	debouncer debouncer_h
	(
		.async_nreset(async_nreset),
		.clk(clk),
		.in(sw_h),
		.out(active[1])
	);
	
	debouncer debouncer_l
	(
		.async_nreset(async_nreset),
		.clk(clk),
		.in(sw_l),
		.out(active[0])
	);
	
	wire btn_next_segment_re;
	wire btn_next_mode_re;
	
	rising_edge re_next_segment
	(
		.async_nreset(async_nreset),
		.in(btn_next_segment), 
		.clk(clk),
		.out(btn_next_segment_re)
	);
	
	rising_edge re_next_mode
	(
		.async_nreset(async_nreset),
		.in(btn_mode), 
		.clk(clk),
		.out(btn_next_mode_re)
	);
	
	reg next_segment_final [3:0];
	reg next_mode_final [3:0];
	
	segment_driver_c segment_driver_c_0
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.btn_next_segment_re(next_segment_final[0]),
		.btn_mode_re(next_mode_final[0]),
		
		.segments(segments1)
	);
	
	segment_driver_c segment_driver_c_1
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.btn_next_segment_re(next_segment_final[1]),
		.btn_mode_re(next_mode_final[1]),
		
		.segments(segments2)
	);
	
	segment_driver_c segment_driver_c_2
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.btn_next_segment_re(next_segment_final[2]),
		.btn_mode_re(next_mode_final[2]),
		
		.segments(segments3)
	);
	
	segment_driver_c segment_driver_c_3
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.btn_next_segment_re(next_segment_final[3]),
		.btn_mode_re(next_mode_final[3]),
		
		.segments(segments4)
	);
	
	always @(*)
	begin
		next_segment_final[0] <= btn_next_segment_re && (active == 2'b00);
		next_segment_final[1] <= btn_next_segment_re && (active == 2'b01);
		next_segment_final[2] <= btn_next_segment_re && (active == 2'b10);
		next_segment_final[3] <= btn_next_segment_re && (active == 2'b11);
		
		next_mode_final[0] <= btn_next_mode_re && (active == 2'b00);
		next_mode_final[1] <= btn_next_mode_re && (active == 2'b01);
		next_mode_final[2] <= btn_next_mode_re && (active == 2'b10);
		next_mode_final[3] <= btn_next_mode_re && (active == 2'b11);
		
		dot1 <= (active == 2'b00);
		dot2 <= (active == 2'b01);
		dot3 <= (active == 2'b10);
		dot4 <= (active == 2'b11);
	end
	
endmodule
