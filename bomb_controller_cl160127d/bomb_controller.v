module bomb_controller
	(
		input clk,
		input async_nreset,
		
		input start_counting,			// SW0
		
		input sw3,
		input sw2, 
		input sw1,
		
		input btn2,
		input btn1,
		input btn0,
		
		output reg [7:0] hex0,			// HEX0
		output reg [7:0] hex1,			// HEX1
		output reg [7:0] hex2,			// HEX2
		output reg [7:0] hex3,			// HEX3
		
		output reg led0,
		output reg led1,
		output reg led2
	);
	
	localparam STATE_INITIAL = 2'd0;
	localparam STATE_COUNTING = 2'd1;
	localparam STATE_BOOM = 2'd2;
	localparam STATE_FREEZE = 2'd3;
	
	reg [1:0] state_reg, state_next;
	
	localparam NONE = 2'd0;
	localparam LOAD = 2'd1;
	localparam INCR = 2'd2;
	localparam DECR = 2'd3;
	
	reg [1:0] bomb_ctrl [3:0];
	reg [3:0] bomb_data_in [3:0];
	wire [3:0] bomb_data_out [3:0];
	
	genvar i;
	generate
		for (i = 0; i < 4; i = i + 1)
		begin : genBlockRegister
	
			bomb_register 
			#(
				.WIDTH(4)
			)
			bomb_register_0
			(
				.clk(clk),
				.async_nreset(async_nreset),
				
				.ctrl(bomb_ctrl[i]),
				.data_in(bomb_data_in[i]),
				.data_out(bomb_data_out[i])
			);
			
		end
	endgenerate
	
	reg timer_enabled;
	reg timer_clear;
	wire timer_half_second;
	wire timer_second;
	
	bomb_timer bomb_timer_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.enabled(timer_enabled),
		.clear(timer_clear),
		
		.half_second(timer_half_second),
		.second(timer_second)
	);
	
	integer j;
	integer over;
	
	integer deactivate;
	integer miss;
	
	reg [2:0] password_reg [7:0], password_next [7:0];
	reg [2:0] guest_reg [7:0], guest_next [7:0];
	
	localparam KEY_A = 2'd0;
	localparam KEY_B = 2'd1;
	localparam KEY_C = 2'd2;
	
	always @(*)
	begin
		
		miss = 0;
		deactivate = 1;
		over = 0;
		blink_state_next <= blink_state_reg;
		state_next <= state_reg;
		timer_clear <= 1'b0;
		timer_enabled <= 1'b0;
		miss_counter_ctrl <= NONE;
		
		for (j = 0; j < 4; j = j + 1)
		begin
			bomb_data_in[j] <= 4'd0;
			bomb_ctrl[j] <= NONE;
		end
		
		for (j = 0; j < 8; j = j + 1)
		begin
			password_next[j] <= password_reg[j];
			guest_next[j] <= guest_reg[j];
		end
		
		case (state_reg)
			STATE_INITIAL:
			begin
			
				if (start_counting)
				begin
					timer_clear <= 1'b1;
					
					if (sw3)
					begin
						for (j = 0; j < 4; j = j + 1)
						begin
							bomb_data_in[j] <= 4'd9;
							bomb_ctrl[j] <= LOAD;
						end
					end
					else if (sw2)
					begin
						bomb_data_in[3] <= 4'd9;
						bomb_ctrl[3] <= LOAD;
						
						for (j = 0; j < 3; j = j + 1)
						begin
							bomb_data_in[j] <= 4'd9;
							bomb_ctrl[j] <= LOAD;
						end
					end
					else if (sw1)
					begin
					
						for (j = 1; j < 4; j = j + 1)
						begin
							bomb_data_in[j] <= 4'd0;
							bomb_ctrl[j] <= LOAD;
						end
					
						bomb_data_in[0] <= 4'd9;
						bomb_ctrl[0] <= LOAD;
					end
					
					if (sw3 || sw2 || sw1)
						state_next <= STATE_COUNTING;
					else
						state_next <= state_reg;
					
				end
				else if (btn0)
				begin
					
					for (j = 0; j < 7; j = j + 1)
						password_next[j + 1] <= password_reg[j];
						
					password_next[0] <= KEY_A;
					
				end
				else if (btn1)
				begin
					
					for (j = 0; j < 7; j = j + 1)
						password_next[j + 1] <= password_reg[j];
						
					password_next[0] <= KEY_B;
					
				end
				else if (btn2)
				begin
					
					for (j = 0; j < 7; j = j + 1)
						password_next[j + 1] <= password_reg[j];
						
					password_next[0] <= KEY_C;
					
				end
				
			end
			STATE_COUNTING:
			begin
				for (j = 0; j < 4; j = j + 1)
				begin
					if (bomb_data_out[j] != 4'd0)
						over = 0;
				end
				
				if (over == 1)
				begin
					state_next <= STATE_BOOM;
					timer_enabled <= 1'b0;
				end
				else
				begin
					timer_enabled <= 1'b1;
				
					if (timer_second)
					begin
					
						if (bomb_data_out[0] == 4'd0)
						begin
							bomb_data_in[0] <= 4'd9;
							bomb_ctrl[0] <= LOAD;
							
							if (bomb_data_out[1] == 4'd0)
							begin
								bomb_data_in[1] <= 4'd9;
								bomb_ctrl[1] <= LOAD;
								
								if (bomb_data_out[2] == 4'd0)
								begin
									bomb_data_in[2] <= 4'd9;
									bomb_ctrl[2] <= LOAD;
									
									// can never be zero because >>over<< would be one then
									bomb_ctrl[3] <= DECR;
								end
								else
								begin
									bomb_ctrl[2] <= DECR;
								end
							end
							else
							begin
								bomb_ctrl[1] <= DECR;
							end
						end
						else
						begin
							bomb_ctrl[0] <= DECR;
						end
						
					end
				end
				
				
				if (btn0)
				begin
					
					for (j = 0; j < 7; j = j + 1)
						guest_next[j + 1] <= guest_reg[j];
						
					guest_next[0] <= KEY_A;
					
				end
				else if (btn1)
				begin
					
					for (j = 0; j < 7; j = j + 1)
						guest_next[j + 1] <= guest_reg[j];
						
					guest_next[0] <= KEY_B;
					
				end
				else if (btn2)
				begin
					
					for (j = 0; j < 7; j = j + 1)
						guest_next[j + 1] <= guest_reg[j];
						
					guest_next[0] <= KEY_C;
					
				end
				
				for (j = 0; j < 8; j = j + 1)
					if (guest_reg[j] != password_reg[j])
					begin
						deactivate = 0;
						miss = miss + 1;
						
						miss_counter_ctrl <= INCR;
					end
				
				if (miss > 3)
					state_next <= STATE_BOOM;
				else if (deactivate)
					state_next <= STATE_FREEZE;
				
			end
			STATE_BOOM:
			begin
				
				if (blink_half_second)
					blink_state_next <= ~blink_state_reg;
				
			end
			STATE_FREEZE:
			begin
			
				// can't go any further
			
			end
		endcase
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
	
		if (!async_nreset)
		begin
			blink_state_reg <= 1'b0;
			state_reg <= STATE_INITIAL;
			
			for (j = 0; j < 8; j = j + 1)
			begin
				password_reg[j] <= 2'd0;
				guest_reg[j] <= 2'd0;
			end
		end
		else
		begin
			blink_state_reg <= blink_state_next;
			state_reg <= state_next;
			
			for (j = 0; j < 8; j = j + 1)
			begin
				password_reg[j] <= password_next[j];
				guest_reg[j] <= guest_next[j];
			end
		end
	
	end
	
	wire blink_half_second;	
	
	bomb_timer blink_timer
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.enabled(1'b1),
		.clear(1'b0),
		
		.half_second(blink_half_second),
		.second()
	);
	
	wire [7:0] hex_encoded [3:0];
	
	genvar k;
	generate
		for (k = 0; k < 4; k = k + 1)
		begin : genBlockEncoder
			hex_encoder hex_encoder_k
			(
				.decimal_digit(bomb_data_out[k]),
				.encode(hex_encoded[k])
			);
		end
	endgenerate
	
	reg blink_state_reg, blink_state_next;
	
	always @(*)
	begin
		
		case (state_reg)
			STATE_BOOM:
			begin
			
				if (blink_state_reg)
				begin
					hex0 <= ~8'b0100_0000;
					hex1 <= ~8'b0100_0000;
					hex2 <= ~8'b0100_0000;
					hex3 <= ~8'b0100_0000;
				end
				else
				begin
					hex0 <= ~8'b0000_0000;
					hex1 <= ~8'b0000_0000;
					hex2 <= ~8'b0000_0000;
					hex3 <= ~8'b0000_0000;
				end
			
			end
			default:
			begin
			
				hex0 <= hex_encoded[0];
				hex1 <= hex_encoded[1];
				hex2 <= hex_encoded[2];
				hex3 <= hex_encoded[3];
			
			end
		endcase
		
		case (miss_counter_data_out)
			2'd1:
			begin
				led0 <= 1'b1;
				led1 <= 1'b0;
				led2 <= 1'b0;
			end
			2'd2:
			begin
				led0 <= 1'b1;
				led1 <= 1'b1;
				led2 <= 1'b0;
			end
			2'd3:
			begin
				led0 <= 1'b1;
				led1 <= 1'b1;
				led2 <= 1'b1;
			end
			default:
			begin
				led0 <= 1'b0;
				led1 <= 1'b0;
				led2 <= 1'b0;
			end
		endcase
	
	end
	
	reg [2:0] miss_counter_ctrl;
	reg [2:0] miss_counter_data_in;
	wire [2:0] miss_counter_data_out;
	
	bomb_register 
	#(
		.WIDTH(2)
	)
	miss_counter
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.ctrl(miss_counter_ctrl),
		.data_in(miss_counter_data_in),
		.data_out(miss_counter_data_out)
	);
	
endmodule
