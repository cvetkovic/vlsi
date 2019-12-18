module button_press_counter
	(
		input rst,
		input clk,
		input activator,
		input [2 : 0] buttons,
		input [2 : 0] equalizer,
		output reg [7 : 0] display,
		output [9 : 0] indicator
	);
	
	localparam CTRL_NONE = 3'd0;
	localparam CTRL_CLR  = 3'd1;
	localparam CTRL_LOAD = 3'd2;
	localparam CTRL_INCR = 3'd3;
	localparam CTRL_DECR = 3'd4;
	
	reg [2 : 0] counter_ctrl [2 : 0];
	reg [9 : 0] counter_input [2 : 0];
	wire [9 : 0] counter_output [2 : 0];
	
	genvar i;
	generate
		for (i = 0; i < 3; i = i + 1) begin : generate_block
			register
				#(
					.DATA_WIDTH(10)
				)
			counter
				(
					.rst(rst),
					.clk(clk),
					.ctrl(counter_ctrl[i]),
					.data_input(counter_input[i]),
					.data_output(counter_output[i])
				);
		end
	endgenerate
	
	// changed for simulation purposes
	// localparam TICK_1000_MS = 28'd50_000_000;
	localparam TICK_1000_MS = 28'd1;
	
	reg [2 : 0] timer_ctrl;
	wire [27 : 0] timer_output;
	
	register
		#(
			.DATA_WIDTH(28)
		)
	timer
		(
			.rst(rst),
			.clk(clk),
			.ctrl(timer_ctrl),
			.data_input(28'd0),
			.data_output(timer_output)
		);
	
	reg [2 : 0] seconds_ctrl;
	wire [3 : 0] seconds_output;
	
	register
		#(
			.DATA_WIDTH(4)
		)
	seconds
		(
			.rst(rst),
			.clk(clk),
			.ctrl(seconds_ctrl),
			.data_input(4'd9),
			.data_output(seconds_output)
		);
	
	reg [3 : 0] encoder_input;
	wire [7 : 0] encoder_output;
	
	encoder
	encoder_instance
		(
			.digit(encoder_input),
			.encoding(encoder_output)
		);
	
	localparam STATE_INITIAL = 2'd0;
	localparam STATE_COUNTING = 2'd1;
	localparam STATE_RESULT = 2'd2;
	
	reg [1 : 0] state_reg, state_next;
	reg [9 : 0] indicator_reg, indicator_next;
	
	always @(negedge rst, posedge clk) begin
		if (!rst) begin
			state_reg <= STATE_INITIAL;
			indicator_reg <= 10'b11111_11111;
		end
		else begin
			state_reg <= state_next;
			indicator_reg <= indicator_next;
		end
	end
	
	integer j, max, index, count;
	always @(*) begin
		max = 0;
		index = 0;
		count = 0;
	
		for (j = 0; j < 3; j = j + 1) begin
			counter_ctrl[j] = CTRL_NONE;
			counter_input[j] = 10'd0;
		end
		
		timer_ctrl = CTRL_NONE;
		seconds_ctrl = CTRL_NONE;
		
		encoder_input = 4'd0;
		
		state_next = state_reg;
		indicator_next = indicator_reg;
		
		display = 8'hFF;
		
		case (state_reg)
			STATE_INITIAL: begin
				for (j = 0; j < 3; j = j + 1) begin
					counter_ctrl[j] = CTRL_CLR;
				end
				
				timer_ctrl = CTRL_CLR;
				seconds_ctrl = CTRL_LOAD;
				
				indicator_next = 10'b11111_11111;
			
				if (activator) begin
					state_next = STATE_COUNTING;
				end
			end
			
			STATE_COUNTING: begin
				if (activator) begin
					for (j = 0; j < 3; j = j + 1) begin
						if (max < counter_output[j]) begin
							max = counter_output[j];
							if (buttons[j]) max = max + 1;
						end
						
						if (buttons[j])
							counter_ctrl[j] = CTRL_INCR;
					end
					
					if (timer_output == TICK_1000_MS) begin
						timer_ctrl = CTRL_CLR;
						
						indicator_next[seconds_output] = 1'b0;
						
						if (seconds_output == 4'd0)
							state_next = STATE_RESULT;
						else
							seconds_ctrl = CTRL_DECR;
					end
					else begin
						timer_ctrl = CTRL_INCR;
					end
					
					for (j = 0; j < 3; j = j + 1) begin
						if (equalizer[j]) begin
							counter_ctrl[j] = CTRL_LOAD;
							counter_input[j] = max[9 : 0];
						end
					end
				end
				else begin
					state_next = STATE_INITIAL;
				end
			end
			
			STATE_RESULT: begin
				if (activator) begin
					for (j = 0; j < 3; j = j + 1) begin
						if (max < counter_output[j]) begin
							max = counter_output[j];
							count = 1;
							index = j;
						end
						else if (max == counter_output[j]) begin
							count = count + 1;
						end
					end
					
					if (count > 1) begin
						display = 8'h7F;
					end
					else begin
						encoder_input = index[3 : 0];
						display = encoder_output;
					end
				end
				else begin
					state_next = STATE_INITIAL;
				end
			end
		endcase
	end
	
	assign indicator = indicator_reg;
	
endmodule
