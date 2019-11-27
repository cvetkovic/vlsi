module flap_indicator_3
	(
		input clk,
		input async_nreset,
		
		input change_position_re,
		input change_mode_re,
		
		output reg [7:0] display
	);
	
	reg [1:0] state_reg, state_next;
	reg [1:0] mode_reg, mode_next;
	
	localparam UP = 2'd0;
	localparam HORIZONTAL = 2'd1;
	localparam DOWN = 2'd2;
	
	localparam SWITCH_MODE = 0;
	localparam OFF_MODE = 1;
	localparam CYCLIC_MODE = 2;
	
	reg timer_clear;
	reg timer_enable;
	wire timer_trigger;
	
	timer timer_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.clear(timer_clear),
		.enable(timer_enable),
		
		.trigger(timer_trigger)
	);
	
	always @(*)
	begin
		state_next <= state_reg;
		mode_next <= mode_reg;
		timer_clear <= 1'b0;
		
		if (mode_reg == CYCLIC_MODE)
			timer_enable <= 1'b1;
		else
			timer_enable <= 1'b0;
		
		if (change_mode_re == 1'b1)
		begin
			case (mode_reg)
				SWITCH_MODE:
					mode_next <= OFF_MODE;
				OFF_MODE:
					mode_next <= CYCLIC_MODE;
				CYCLIC_MODE:
				begin
					mode_next <= SWITCH_MODE;
					timer_clear <= 1'b1;
				end
			endcase
		end
		
		if ((change_position_re == 1'b1 && mode_reg == SWITCH_MODE) ||
			 (timer_trigger == 1'b1 && mode_reg == CYCLIC_MODE))
		begin
			case (state_reg)
				UP:
					state_next <= HORIZONTAL;
				HORIZONTAL:
					state_next <= DOWN;
				DOWN:
					state_next <= UP;
			endcase
		end
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (async_nreset == 1'b0)
		begin
			state_reg <= UP;
			mode_reg <= SWITCH_MODE;
		end
		else
		begin
			state_reg <= state_next;
			mode_reg <= mode_next;
		end
	end
	
	always @(*)
	begin
		display <= 8'd0;
	
		if (mode_reg != OFF_MODE)
		begin
			case (state_reg)
				UP:
					display <= 8'b0100_0000;
				HORIZONTAL:
					display <= 8'b1000_0000;
				DOWN:
					display <= 8'b0010_0000;
			endcase
		end
	end
	
endmodule