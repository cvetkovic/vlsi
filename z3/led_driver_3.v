module led_driver_3
	(
		input clk,
		input async_nreset,
		
		input next_led_re,
		input change_mode_re,
		input btn_cylic_re,
		
		output reg [4:0] led
	);
	
	localparam OFF_STATE = 4'd0;
	localparam STATE_A = 4'd1;
	localparam STATE_B = 4'd2;
	localparam STATE_C = 4'd3;
	localparam STATE_D = 4'd4;
	localparam STATE_E = 4'd5;
	localparam STATE_F = 4'd6;
	localparam STATE_G = 4'd7;
	localparam STATE_H = 4'd8;
	localparam STATE_I = 4'd9;
	
	localparam STATE_2_OFF_STATE = 4'd0;
	localparam STATE_2_A = 4'd1;
	localparam STATE_2_B = 4'd2;
	localparam STATE_2_C = 4'd3;
	localparam STATE_2_D = 4'd4;
	localparam STATE_2_E = 4'd5;
	localparam STATE_2_F = 4'd6;
	localparam STATE_2_G = 4'd7;
	localparam STATE_2_H = 4'd8;
	localparam STATE_2_I = 4'd9;
	
	reg [3:0] state_reg, state_next;
	reg [3:0] state2_reg, state2_next;
	
	reg [1:0] mode_reg, mode_next;
	
	reg [1:0] cyclic_mode_reg, cyclic_mode_next;
	
	localparam MODE_1 = 2'd0;
	localparam MODE_2 = 2'd1;
	
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
		state2_next <= state2_reg;
		mode_next <= mode_reg;
		cyclic_mode_next <= cyclic_mode_reg;
		
		timer_clear <= 1'b0;
		timer_enable <= 1'b0;
		
		if (btn_cylic_re)
		begin
			cyclic_mode_next[mode_reg] <= ~cyclic_mode_reg[mode_reg];
			
			timer_clear <= 1'b1;
		end
		
		if (cyclic_mode_reg[mode_reg])
		begin
			timer_enable <= 1'b1;
		end
		
		if (change_mode_re)
		begin
			case (mode_reg)
				MODE_1:
					mode_next <= MODE_2;
				MODE_2:
					mode_next <= MODE_1;
			endcase
		end
		
		if (next_led_re || timer_trigger)
		begin
			if (mode_reg == MODE_1)
			begin
				case (state_reg)
					OFF_STATE:
						state_next <= STATE_A;
					STATE_A:
						state_next <= STATE_B;
					STATE_B:
						state_next <= STATE_C;
					STATE_C:
						state_next <= STATE_D;
					STATE_D:
						state_next <= STATE_E;
					STATE_E:
						state_next <= STATE_F;
					STATE_F:
						state_next <= STATE_G;
					STATE_G:
						state_next <= STATE_H;
					STATE_H:
						state_next <= STATE_I;
					STATE_I:
						state_next <= OFF_STATE;
				endcase
			end
			else if (mode_reg == MODE_2)
			begin
				case (state2_reg)
					STATE_2_OFF_STATE:
						state2_next <= STATE_2_A;
					STATE_2_A:
						state2_next <= STATE_2_B;
					STATE_2_B:
						state2_next <= STATE_2_C;
					STATE_2_C:
						state2_next <= STATE_2_D;
					STATE_2_D:
						state2_next <= STATE_2_E;
					STATE_2_E:
						state2_next <= STATE_2_F;
					STATE_2_F:
						state2_next <= STATE_2_G;
					STATE_2_G:
						state2_next <= STATE_2_H;
					STATE_2_H:
						state2_next <= STATE_2_I;
					STATE_2_I:
						state2_next <= STATE_2_OFF_STATE;
				endcase
			end
		end
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (async_nreset == 1'b0)
		begin
			mode_reg <= MODE_1;
			cyclic_mode_reg <= 2'b00;
		
			state_reg <= OFF_STATE;
			state2_reg <= STATE_2_OFF_STATE;
		end
		else 
		begin
			mode_reg <= mode_next;
			cyclic_mode_reg <= cyclic_mode_next;
		
			state_reg <= state_next;
			state2_reg <= state2_next;
		end
	end
	
	always @(*)
	begin
		led <= 5'b0_0000;
		
		if (mode_reg == MODE_1)
		begin
			case (state_reg)
				OFF_STATE:
					led <= 5'b0_0000;
				STATE_A:
					led <= 5'b0_0001;
				STATE_B:
					led <= 5'b1_0000;
				STATE_C:
					led <= 5'b0_0010;
				STATE_D:
					led <= 5'b0_1000;
				STATE_E:
					led <= 5'b0_0100;
				STATE_F:
					led <= 5'b0_0010;
				STATE_G:
					led <= 5'b0_1000;
				STATE_H:
					led <= 5'b0_0001;
				STATE_I:
					led <= 5'b1_0000;
			endcase
		end
		else if (mode_reg == MODE_2)
		begin
			case (state2_reg)
				STATE_2_OFF_STATE:
					led <= 5'b0_0000;
				STATE_2_A:
					led <= 5'b0_0001;
				STATE_2_B:
					led <= 5'b0_0011;
				STATE_2_C:
					led <= 5'b0_0111;
				STATE_2_D:
					led <= 5'b0_1111;
				STATE_2_E:
					led <= 5'b1_1111;
				STATE_2_F:
					led <= 5'b0_1111;
				STATE_2_G:
					led <= 5'b0_0111;
				STATE_2_H:
					led <= 5'b0_0011;
				STATE_2_I:
					led <= 5'b0_0001;
			endcase
		end
	end
	
endmodule