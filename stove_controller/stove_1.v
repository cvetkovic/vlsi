module stove_1
	(
		input clk,
		input async_nreset,			// SW8
		
		input sw_h,						// SW3
		input sw_l,						// SW2
		
		input child_lock,				// BTN3
		input inc_pwr,					// BTN2
		input dec_pwr,					// BTN1
	
		input pwr,						// BTN0
		
		output reg [7:0] left_hex,		// HEX3
		output reg [7:0] right_hex		// HEX2
	);

	reg [3:0] power_reg [1:0], power_next [1:0];
	reg [2:0] state_reg, state_next;
	
	localparam LEFT = 1'd0;
	localparam RIGHT = 1'd1;
	
	localparam STATE_OFF = 3'd0;
	localparam STATE_ON = 3'd1;
	localparam CHILD_LOCK_CONFIRM = 3'd2;
	localparam CHILD_LOCK_SHOW_L = 3'd3;
	localparam CHILD_LOCK_OFF = 3'd4;
	localparam CHILD_UNLOCK_CONFIRM = 3'd5;
	localparam LEFTOVER_HEAT = 3'd6;
	
	wire btn3_debounced;
	wire btn2_debounced;
	
	wire two_seconds;
	
	stove_debouncer 
	#(
		.TIME_TO_WAIT(32'd149_999_999)
	)
	stove_debouncer_btn3
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.signal_in(child_lock),
		.signal_out(btn3_debounced)
	);
	stove_debouncer
	#(
		.TIME_TO_WAIT(32'd149_999_999)
	)
	stove_debouncer_btn2
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.signal_in(inc_pwr),
		.signal_out(btn2_debounced)
	);
	stove_debouncer 
	#(
		.TIME_TO_WAIT(32'd99_999_999)
	)
	stove_debouncer_btn22
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.signal_in(child_lock),
		.signal_out(two_seconds)
	);

	reg timer_enabled;
	wire ten_seconds_elapsed;
	
	timer timer_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.enabled(timer_enabled),
		
		.ten_seconds_elapsed(ten_seconds_elapsed)
	);
	
	always @(*)
	begin
	
		state_next <= state_reg;
		power_next[LEFT] <= power_reg[LEFT];
		power_next[RIGHT] <= power_reg[RIGHT];
		
		timer_enabled <= 1'b0;
		
		case (state_reg)
			//////////////////////////////////////////////////////
			STATE_OFF:
			begin
				if (pwr)
				begin
					state_next <= STATE_ON;
					power_next[LEFT] <= 4'd0;
					power_next[RIGHT] <= 4'd0;
				end
			end
			//////////////////////////////////////////////////////
			STATE_ON:
			begin
			
				if (pwr)
				begin
					
					if ((power_reg[LEFT] != 4'd0) || (power_reg[RIGHT] != 4'd0))
					begin
					
						state_next <= STATE_OFF;
						power_next[LEFT] <= 4'd0;
						power_next[RIGHT] <= 4'd0;
					
					end
					else
					begin
				
						state_next <= LEFTOVER_HEAT;
						power_next[LEFT] <= 4'd0;
						power_next[RIGHT] <= 4'd0;
					
					end
					
					
				end
				else if (power_reg[LEFT] == 4'd0 &&
							power_reg[RIGHT] == 4'd0 &&
							sw_h == 1'd0 &&
							sw_l == 1'd0 && 
							btn3_debounced && 
							btn2_debounced)
				begin
					state_next <= CHILD_LOCK_CONFIRM;
				end
				else
				begin
				
					if (sw_h)
					begin
						
						if (inc_pwr && power_reg[LEFT] < 4'd9)
							power_next[LEFT] <= power_reg[LEFT] + 4'd1;
						else if (dec_pwr && power_reg[LEFT] > 4'd0)
							power_next[LEFT] <= power_reg[LEFT] - 4'd1;
							
					end
			
					if (sw_l)
					begin
						
						if (inc_pwr && power_reg[RIGHT] < 4'd9)
							power_next[RIGHT] <= power_reg[RIGHT] + 4'd1;
						else if (dec_pwr && power_reg[RIGHT] > 4'd0)
							power_next[RIGHT] <= power_reg[RIGHT] - 4'd1;
							
					end
					
				end
			end
			//////////////////////////////////////////////////////
			CHILD_LOCK_CONFIRM:
			begin
				if (child_lock)
					state_next <= CHILD_LOCK_SHOW_L;
				else
					state_next <= STATE_ON;
			end
			//////////////////////////////////////////////////////
			CHILD_LOCK_SHOW_L:
			begin
				if (two_seconds)
					state_next <= CHILD_LOCK_OFF;
			end
			//////////////////////////////////////////////////////
			CHILD_LOCK_OFF:
			begin
				if (pwr && btn3_debounced && btn2_debounced)
					state_next <= CHILD_UNLOCK_CONFIRM;
				else if (pwr)
					state_next <= CHILD_LOCK_SHOW_L;
			end
			//////////////////////////////////////////////////////
			CHILD_UNLOCK_CONFIRM:
			begin
				if (inc_pwr)
					state_next <= STATE_ON;
				else
					state_next <= CHILD_LOCK_OFF;
			end
			//////////////////////////////////////////////////////
			LEFTOVER_HEAT:
			begin
				timer_enabled <= 1'b1;
			
				if (ten_seconds_elapsed)
					state_next <= STATE_OFF;
			end
		endcase
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
	
		if (!async_nreset)
		begin
			state_reg <= STATE_OFF;
			power_reg[LEFT] <= 4'd0;
			power_reg[RIGHT] <= 4'd0;
		end
		else
		begin
			state_reg <= state_next;
			power_reg[LEFT] <= power_next[LEFT];
			power_reg[RIGHT] <= power_next[RIGHT];
		end
	
	end
	
	wire [6:0] hex_output_left, hex_output_right;
	
	hex_driver hex_driver_left
	(
		.in(power_reg[LEFT]),
		.out(hex_output_left)
	);
	
	hex_driver hex_driver_right
	(
		.in(power_reg[RIGHT]),
		.out(hex_output_right)
	);
	
	always @(*)
	begin
		left_hex <= ~8'd0;
		right_hex <= ~8'd0;
	
		if (state_reg == CHILD_LOCK_SHOW_L)
		begin
			left_hex <= ~8'b0011_1000;
		end
		else if (state_reg == STATE_ON)
		begin
			left_hex <= {sw_h, hex_output_left};
			right_hex <= {sw_l, hex_output_right};
		end
		else if (state_reg == LEFTOVER_HEAT)
		begin
			left_hex <= ~{1'b0, 7'b111_0110};
			right_hex <= ~{1'b0, 7'b111_0110};
		end
	end
	
endmodule
