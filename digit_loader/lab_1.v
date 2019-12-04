module lab_1
	(
		input clk,
		input async_nreset,
		
		input sw0,
		input btn0,
		input btn2,
		
		output reg [3:0] bcd_output,
		output reg valid
	);
	
	reg [2:0] state_reg, state_next;
	
	localparam STATE_INITIAL = 3'd0;
	localparam STATE_SW0_INCREMENT = 3'd1;
	localparam STATE_DONE = 3'd2;
	
	reg [1:0] register_ctrl;
	wire [3:0] bcd_output_raw;
	
	register
	#(
		.WIDTH(4)
	)
	register_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.ctrl(register_ctrl),
		.data_in(4'd0),
		.data_out(bcd_output_raw)
	);
	
	always @(*)
	begin
		state_next <= state_reg;
		register_ctrl <= 2'd0;
		
		case (state_reg)
			STATE_INITIAL:
			begin
				if (sw0)
				begin
					state_next <= STATE_SW0_INCREMENT;
					register_ctrl <= 2'd3;
				end
			end
			STATE_SW0_INCREMENT:
			begin
				if (btn0 && bcd_output_raw < 4'd9)
					register_ctrl <= 2'd1;
				
				if (!sw0)
					state_next <= STATE_DONE;
			end
			STATE_DONE:
			begin
				// nothing in here
			end
		endcase
		
		if (btn2)
			state_next <= STATE_INITIAL;
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (!async_nreset)
			state_reg <= STATE_INITIAL;
		else
			state_reg <= state_next;
	end
	
	always @(*)
	begin
		valid <= 1'b0;
			bcd_output <= bcd_output_raw;
		
		if (state_reg == STATE_SW0_INCREMENT || state_reg == STATE_DONE)
			valid <= 1'b1;
	end
	
endmodule
