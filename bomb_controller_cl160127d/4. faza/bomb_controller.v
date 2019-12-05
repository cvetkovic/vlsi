module bomb_controller
	(
		input clk,
		input async_nreset,
		
		input sw3,
		input sw2,
		input sw1,
		
		input btn2, 
		input btn1,
		input btn0,
		
		input start_countdown,
		
		output reg [7:0] hex_output0,
		output reg [7:0] hex_output1,
		output reg [7:0] hex_output2,
		output reg [7:0] hex_output3,
		
		output [3:0] led
	);
	
	reg password_mode;
	wire password_unlocked;
	wire password_explode;
	
	password password_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.btn0(btn0),
		.btn1(btn1),
		.btn2(btn2),
		
		.mode(password_mode),
		
		.unlocked(password_unlocked),
		.explode(password_explode),
		
		.led(led)
	);
	
	reg [1:0] counter_ctrl  [3:0];
	reg [3:0] counter_data_in [3:0];
	wire [3:0] counter_data_out [3:0];
	
	reg [3:0] bcd_output [3:0];
	wire [7:0] hex_output_raw [3:0];
	
	genvar i;
	generate
		for (i = 0; i < 4; i = i + 1)
		begin : genBlock
			register
			#(
				.WIDTH(4)
			)
			counter_inst_i
			(
				.clk(clk),
				.async_nreset(async_nreset),
				
				.ctrl(counter_ctrl[i]),
				.data_in(counter_data_in[i]),
				.data_out(counter_data_out[i])
			);
			
			hex_driver hex_output_driver
			(
				.in(bcd_output[i]),
				.out(hex_output_raw[i])
			);
		end
	endgenerate
	
	reg [2:0] state_reg, state_next;
	reg blink_reg, blink_next;
	
	localparam STATE_INITIAL = 2'd0;
	localparam STATE_COUNTDOWN = 2'd1;
	localparam STATE_BOOM = 2'd2;
	
	localparam BLINK_ON = 1'b0;
	localparam BLINK_OFF = 1'b1;
	
	localparam NONE = 2'd0;
	localparam INCR = 2'd1;
	localparam LOAD = 2'd2;
	localparam CLR = 2'd3;
	
	reg timer_enabled;
	reg timer_clear;
	wire second_elapsed;
	wire half_second_elapsed;
	
	timer timer_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.enable(timer_enabled),
		.clear(timer_clear),
		
		.second_elapsed(second_elapsed),
		.half_second_elapsed(half_second_elapsed)
	);
	
	integer j;
	
	always @(*)
	begin
		state_next <= state_reg;
		blink_next <= blink_reg;
		
		timer_clear <= 1'b0;
		timer_enabled <= 1'b0;
		
		password_mode <= 1'b0;
		
		for (j = 0; j < 4; j = j + 1)
		begin
			counter_ctrl[j] <= NONE;
			counter_data_in[j] <= 4'd0;
			bcd_output[j] <= counter_data_out[j];
		end
		
		case (state_reg)
		
			STATE_INITIAL:
			begin
				if (start_countdown)
				begin
					if (sw3)
					begin
						counter_ctrl[0] <= LOAD;
						counter_data_in[0] <= 4'd9;
						counter_ctrl[1] <= LOAD;
						counter_data_in[1] <= 4'd9;
						counter_ctrl[2] <= LOAD;
						counter_data_in[2] <= 4'd9;
						counter_ctrl[3] <= LOAD;
						counter_data_in[3] <= 4'd9;
					end
					else if (sw2)
					begin
						counter_ctrl[0] <= LOAD;
						counter_data_in[0] <= 4'd9;
						counter_ctrl[1] <= LOAD;
						counter_data_in[1] <= 4'd9;
						counter_ctrl[2] <= LOAD;
						counter_data_in[2] <= 4'd9;
						counter_ctrl[3] <= LOAD;
						counter_data_in[3] <= 4'd0;
					end
					else if (sw1)
					begin
						counter_ctrl[0] <= LOAD;
						counter_data_in[0] <= 4'd9;
						counter_ctrl[1] <= LOAD;
						counter_data_in[1] <= 4'd9;
						counter_ctrl[2] <= LOAD;
						counter_data_in[2] <= 4'd0;
						counter_ctrl[3] <= LOAD;
						counter_data_in[3] <= 4'd0;
					
					end
					else
					begin
						counter_ctrl[0] <= LOAD;
						counter_data_in[0] <= 4'd9;
						counter_ctrl[1] <= LOAD;
						counter_data_in[1] <= 4'd0;
						counter_ctrl[2] <= LOAD;
						counter_data_in[2] <= 4'd0;
						counter_ctrl[3] <= LOAD;
						counter_data_in[3] <= 4'd0;
					end
				
					timer_clear <= 1'b1;				
					state_next <= STATE_COUNTDOWN;
				end
			end
			
			STATE_COUNTDOWN:
			begin
				timer_enabled <= 1'b1;
				password_mode <= 1'b1;
			
				if (second_elapsed & !password_unlocked)
				begin
				
					if (counter_data_out[0] == 4'd0)
					begin
						counter_ctrl[0] <= LOAD;
						counter_data_in[0] <= 4'd9;
					
						if (counter_data_out[1] == 4'd0)
						begin
							counter_ctrl[1] <= LOAD;
							counter_data_in[1] <= 4'd9;
							
							if (counter_data_out[2] == 4'd0)
							begin
								counter_ctrl[2] <= LOAD;
								counter_data_in[2] <= 4'd9;
							
								if (counter_data_out[3] == 4'd0)
								begin
									counter_ctrl[0] <= LOAD;
									counter_data_in[0] <= 4'd0;
									
									counter_ctrl[1] <= LOAD;
									counter_data_in[1] <= 4'd0;
									
									counter_ctrl[2] <= LOAD;
									counter_data_in[2] <= 4'd0;
									
									counter_ctrl[3] <= LOAD;
									counter_data_in[3] <= 4'd0;
								end
								else
								begin
									counter_ctrl[3] <= LOAD;
									counter_data_in[3] <= counter_data_out[3] - 4'd1;
								end
							
							
							end
							else
							begin
								counter_ctrl[2] <= LOAD;
								counter_data_in[2] <= counter_data_out[2] - 4'd1;
							end
						
						end
						else
						begin
							counter_ctrl[1] <= LOAD;
							counter_data_in[1] <= counter_data_out[1] - 4'd1;
						end
					
					
					end
					else
					begin
						counter_ctrl[0] <= LOAD;
						counter_data_in[0] <= counter_data_out[0] - 4'd1;
					end
					
				end
				
				if ((counter_data_out[0] == 4'd0 && 
					  counter_data_out[1] == 4'd0 &&
					  counter_data_out[2] == 4'd0 &&
					  counter_data_out[3] == 4'd0) || password_explode)
				begin
					state_next <= STATE_BOOM;
					timer_clear <= 1'b1;
					
					blink_next <= BLINK_ON;
				end
			end
			
			STATE_BOOM:
			begin
				timer_enabled <= 1'b1;
				
				// no out of this state
				if (half_second_elapsed)
				begin
					if (blink_reg == BLINK_ON)
						blink_next <= BLINK_OFF;
					else
						blink_next <= BLINK_ON;
				end				
			end
			
		endcase
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (!async_nreset)
		begin
			state_reg <= STATE_INITIAL;
			blink_reg <= BLINK_OFF;
		end
		else
		begin
			state_reg <= state_next;
			blink_reg <= blink_next;
		end
	end
	
	always @(*)
	begin
		hex_output0 <= hex_output_raw[0];
		hex_output1 <= hex_output_raw[1];
		hex_output2 <= hex_output_raw[2];
		hex_output3 <= hex_output_raw[3];
		
		if (state_reg == STATE_BOOM)
		begin
			if (blink_reg == BLINK_ON)
			begin
				hex_output0 <= ~8'b0100_0000;
				hex_output1 <= ~8'b0100_0000;
				hex_output2 <= ~8'b0100_0000;
				hex_output3 <= ~8'b0100_0000;
			end
			else
			begin
				hex_output0 <= ~8'b0000_0000;
				hex_output1 <= ~8'b0000_0000;
				hex_output2 <= ~8'b0000_0000;
				hex_output3 <= ~8'b0000_0000;
			end
		end
	end
	
endmodule
