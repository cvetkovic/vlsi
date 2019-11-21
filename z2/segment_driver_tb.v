module segment_driver_tb
	(
		output reg clk,
		output async_nreset,
		
		output reg btn_next_segment,
		output reg btn_mode,
		
		output reg sw_h,
		output reg sw_l,
		
		output [5:0] segments1,
		output dot1,
		output [5:0] segments2,
		output dot2,
		output [5:0] segments3,
		output dot3,
		output [5:0] segments4,
		output dot4
	);

	segment_driver_d
	(
		.clk(clk),
		.async_nreset(1'b1),
		
		.btn_next_segment(btn_next_segment),
		.btn_mode(btn_mode),
		
		.sw_h(sw_h),
		.sw_l(sw_l),
		
		.segments1(segments1),
		.dot1(dot1),
		.segments2(segments2),
		.dot2(dot2),
		.segments3(segments3),
		.dot3(dot3),
		.segments4(segments4),
		.dot4(dot4)
	);

	always
	begin
	
		clk <= 1'b0;
		#5;
		
		clk <= ~clk;
		#5;
		
	end
	
	
	
	integer i, j;
	
	initial
	begin
	
		sw_h <= 1'b0;
		sw_l <= 1'b0;
	
		for (j = 0; j < 4; j = j + 1)
		begin
		
			for(i = 0; i < 1000; i = i + 1)
			begin
			
				btn_next_segment <= 1'b1;
				#2;
				btn_next_segment <= 1'b0;
			
			end
			
			btn_mode <= 1'b1;
			#2;
			btn_mode <= 1'b0;
			
		end
	
		$finish();
	
	end

endmodule
