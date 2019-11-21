module segment_driver_b
	(
		input clk,
		input async_nreset,
		
		input btn_next_segment_re,
		input btn_mode_re,
		
		output [5:0] segments,
		output [1:0] current_mode
	);
	
	reg enable;
	reg forward;
	
	reg [1:0] mode_reg, mode_next;
	
	localparam MODE_FORWARD = 0;
	localparam MODE_OFF = 1;
	localparam MODE_BACKWARD = 2;
	localparam MODE_CLOCK = 3;
	
	segment_driver_a
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.forward(forward),
		.enable(enable),
		.btn_next_segment_re(btn_next_segment_re),
		
		.segments(segments)
	);
	
	always @(*)
	begin
		mode_next <= mode_reg;
		
		enable <= 1'b0;
		forward <= 1'b0;
		
		if (btn_mode_re)
		begin
		
			case (mode_reg)
			
				MODE_FORWARD:
				begin
					enable <= 1'b1;
					forward <= 1'b1;
				end
				
				MODE_OFF:
				begin
					enable <= 1'b0;
				end
					
				MODE_BACKWARD:
				begin
					enable <= 1'b1;
					forward <= 1'b0;
				end
				
				MODE_CLOCK:
				begin
					enable <= 1'b1;
					forward <= 1'b0;
				end
				
			endcase
			
		end
			
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (async_nreset == 1'b0)
			mode_reg <= MODE_FORWARD;
		else
			mode_reg <= mode_next;
	end
	
	assign current_mode = mode_reg;
	
endmodule
