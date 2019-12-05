module bomb_controller
	(
		input clk,
		input async_nreset,
		
		input start_countdown,
		
		output reg [7:0] hex_output
	);
	
	reg [1:0] counter_ctrl;
	reg [3:0] counter_data_in;
	wire [3:0] counter_data_out;
	
	register
	#(
		.WIDTH(4)
	)
	counter_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.ctrl(counter_ctrl),
		.data_in(counter_data_in),
		.data_out(counter_data_out)
	);
	
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
	
	reg [3:0] bcd_output;
	wire [7:0] hex_output_raw;
	
	timer timer_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.enable(timer_enabled),
		.clear(timer_clear),
		
		.second_elapsed(second_elapsed),
		.half_second_elapsed(half_second_elapsed)
	);
	
	always @(*)
	begin
		state_next <= state_reg;
		blink_next <= blink_reg;
		
		timer_clear <= 1'b0;
		timer_enabled <= 1'b0;
		counter_ctrl <= NONE;
		counter_data_in <= 4'd0;
		
		bcd_output <= counter_data_out;
		
		case (state_reg)
		
			STATE_INITIAL:
			begin
				if (start_countdown)
				begin
					counter_ctrl <= LOAD;
					counter_data_in <= 4'd9;
				
					timer_clear <= 1'b1;
				
					state_next <= STATE_COUNTDOWN;
				end
			end
			
			STATE_COUNTDOWN:
			begin
				timer_enabled <= 1'b1;
			
				if (second_elapsed)
				begin
					counter_ctrl <= LOAD;
					counter_data_in <= counter_data_out - 4'd1;
				end
				
				if (counter_data_out == 4'd0)
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
	
	hex_driver hex_output_driver
	(
		.in(bcd_output),
		.out(hex_output_raw)
	);
	
	always @(*)
	begin
		hex_output <= hex_output_raw;
		
		if (state_reg == STATE_BOOM)
		begin
			if (blink_reg == BLINK_ON)
				hex_output <= ~8'b0100_0000;
			else
				hex_output <= ~8'b0000_0000;
		end
	end
	
endmodule
