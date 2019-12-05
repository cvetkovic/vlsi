module stopwatch
	(
		input clk,
		input async_nreset,
		
		input start,
		input pause,
		input stop,
		
		output reg [7:0] hex0,
		output reg [7:0] hex1,
		output reg [7:0] hex2,
		output reg [7:0] hex3
	);

	reg [2:0] state_reg, state_next;
	
	localparam STATE_INITIAL = 3'd0;
	localparam STATE_COUNTING = 3'd1;
	localparam STATE_PAUSE = 3'd2;
	localparam STATE_STOP = 3'd3;
	
	reg timer_enabled;
	reg timer_clear;
	wire elapsed_1s;
	wire elapsed_100ms;
	wire elapsed_10ms;
	wire elapsed_1ms;
	
	timer timer_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.enabled(timer_enabled),
		.clear(timer_clear),
		
		.elapsed_1s(elapsed_1s),
		.elapsed_100ms(elapsed_100ms),
		.elapsed_10ms(elapsed_10ms),
		.elapsed_1ms(elapsed_1ms)
	);
	
	localparam NONE = 2'd0;
	localparam INCR = 2'd1;
	localparam LOAD = 2'd2;
	localparam CLR = 2'd3;
	
	reg [1:0] ctrl [3:0];
	reg [3:0] data_in [3:0];
	wire [3:0] data_out [3:0];
	wire [7:0] hex_out [3:0];
	
	genvar i;
	generate
		for (i = 0; i < 4; i = i + 1)
		begin : genBlock
		
			register
			#(
				.WIDTH(4)
			)
			register_i
			(
				.clk(clk),
				.async_nreset(async_nreset),
				
				.ctrl(ctrl[i]),
				.data_in(data_in[i]),
				.data_out(data_out[i])
			);
		
			hex_driver hex_driver_i
			(
				.digit(data_out[i]),
				.encoding(hex_out[i])
			);
		
		end
	endgenerate
	
	integer j;
	
	always @(*)
	begin
		
		state_next <= state_reg;
		timer_enabled <= 1'b0;
		timer_clear <= 1'b0;
		
		for (j = 0; j < 4; j = j + 1)
		begin
			data_in[j] <= 4'd0;
			ctrl[j] <= NONE;
		end
		
		case (state_reg)
		
			STATE_INITIAL:
			begin
				for (j = 0; j < 4; j = j + 1)
				begin
					data_in[j] <= 4'd0;
					ctrl[j] <= LOAD;
				end
			
				if (start)
				begin
					state_next <= STATE_COUNTING;
					timer_clear <= 1'b1;
				end
			end
			
			STATE_COUNTING:
			begin
			
				timer_enabled <= 1'b1;
			
				if (elapsed_1ms)
				begin
					if (data_out[0] == 4'd9)
					begin
						data_in[0] <= 4'd0;
						ctrl[0] <= LOAD;
						
						if (data_out[1] == 4'd9)
						begin
							data_in[1] <= 4'd0;
							ctrl[1] <= LOAD;
						
							if (data_out[2] == 4'd9)
							begin
								data_in[2] <= 4'd0;
								ctrl[2] <= LOAD;
								
								if (data_out[3] == 4'd9)
								begin
									for (j = 0; j < 4; j = j + 1)
									begin
										data_in[j] <= 4'd0;
										ctrl[j] <= LOAD;
									end
								end
								else
									ctrl[3] <= INCR;
							end
							else
								ctrl[2] <= INCR;
						end
						else
							ctrl[1] <= INCR;
					end
					else
					begin
						ctrl[0] <= INCR;
					end
				end
			
				if (pause)
					state_next <= STATE_PAUSE;
				else if (stop)
					state_next <= STATE_STOP;
			end
			
			STATE_PAUSE:
			begin
			
				if (pause)
					state_next <= STATE_COUNTING;
					
			end
			
			STATE_STOP:
			begin
				
				if (start)
					state_next <= STATE_INITIAL;
				
			end
			
		endcase
		
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
		hex0 <= hex_out[0];
		hex1 <= hex_out[1];
		hex2 <= hex_out[2];
		hex3 <= hex_out[3];
	end
	
endmodule
	