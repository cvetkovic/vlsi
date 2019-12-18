module vdevice
	(
		input clk,
		input async_nreset,
		
		input start,
		input reset,
		
		input btn2,
		input btn1,
		input btn0,
		
		output reg [7:0] counter_2,
		output reg [7:0] counter_1,
		output reg [7:0] counter_0
	);
	
	localparam COUNTER_REGISTER_WIDTH = 8;
	
	reg [COUNTER_REGISTER_WIDTH-1:0] counter_data_in [2:0];
	reg [1:0] counter_ctrl [2:0];
	wire [COUNTER_REGISTER_WIDTH-1:0] counter_data_out [2:0];
	
	localparam NONE = 2'd0;
	localparam LOAD = 2'd1;
	localparam INCR = 2'd2;
	localparam DECR = 2'd3;
	
	reg timer_enable;
	reg timer_clear;
	wire timer_second_elapsed;
	
	vtimer timer
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.enable(timer_enable),
		.clear(timer_clear),
		
		.second_elapsed(timer_second_elapsed)
	);
	
	reg [15:0] clock_register_data_in;
	reg [1:0] clock_register_ctrl;
	wire [15:0] clock_register_data_out;
	
	vregister
	#(
		.WIDTH(16)
	)
	clock_register
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.data_in(clock_register_data_in),
		.ctrl(clock_register_ctrl),
		.data_out(clock_register_data_out)
	);
	
	genvar i;
	generate
	
		for (i = 0; i < 3; i = i + 1)
		begin : genBlock
		
			vregister
			#(
				.WIDTH(COUNTER_REGISTER_WIDTH)
			)
			vregister_cnt_i
			(
				.clk(clk),
				.async_nreset(async_nreset),
				
				.data_in(counter_data_in[i]),
				.ctrl(counter_ctrl[i]),
				.data_out(counter_data_out[i])
			);
			
		end
		
	endgenerate
	
	localparam STATE_INITIAL = 2'd0;
	localparam STATE_COUNTING = 2'd1;
	localparam STATE_TIMEOUT = 2'd2;
	
	reg [1:0] state_reg, state_next;
	integer ii;
	
	always @(*)
	begin
	
		for (ii = 0; ii < 3; ii = ii + 1)
		begin
			counter_ctrl[ii] <= NONE;
			counter_data_in[ii] <= {COUNTER_REGISTER_WIDTH{1'b0}};
		end
	
		timer_enable <= 1'b0;
		timer_clear <= 1'b0;
		clock_register_data_in <= 16'd0;
		clock_register_ctrl <= NONE;
	
		state_next <= state_reg;
		
		case (state_reg)
		
			STATE_INITIAL:
			begin
			
				if (start)
				begin
				
					clock_register_data_in <= 16'd0;
					clock_register_ctrl <= LOAD;
				
					timer_clear <= 1'b1;
				
					state_next <= STATE_COUNTING;
					
				end
			
			end
			
			STATE_COUNTING:
			begin
			
				timer_enable <= 1'b1;
			
				if (btn2)
					counter_ctrl[2] <= INCR;
				
				if (btn1)
					counter_ctrl[1] <= INCR;
					
				if (btn0)
					counter_ctrl[0] <= INCR;
					
				if (timer_second_elapsed)
				begin
					
					clock_register_ctrl <= INCR;
					
				end
				
				if (clock_register_data_out == 16'd9)
					state_next <= STATE_TIMEOUT;
				
			end
			
			STATE_TIMEOUT:
			begin
			
				if (reset)
					state_next <= STATE_INITIAL;
			
			end
			
		endcase
	
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (!async_nreset)
		begin
			state_reg <= STATE_INITIAL;
		end
		else
		begin
			state_reg <= state_next;
		end
	end
	
	always @(*)
	begin
		
		counter_0 <= 8'd0;
		counter_1 <= 8'd0;
		counter_2 <= 8'd0;
		
		if (state_reg == STATE_TIMEOUT)
		begin
			counter_0 <= counter_data_out[0];
			counter_1 <= counter_data_out[1];
			counter_2 <= counter_data_out[2];
		end
		
	end
	
endmodule
