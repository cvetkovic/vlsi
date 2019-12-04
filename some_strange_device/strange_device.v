module strange_device
	#(
		parameter DIGIT_NUM = 7,
		parameter HISTORY_WIDTH = 4
	)
	(
		input rst,
		input clk,
		input [(DIGIT_NUM - 1) : 0] digit_choice,
		input digit_load,
		input digit_change,
		input mode_change,
		output reg [(ENCODING_WIDTH - 1) : 0] display,
		output digit_load_indicator
	);
	
	localparam DIGIT_WIDTH = 4;
	localparam ENCODING_WIDTH = 7;
	
	localparam CTRL_WIDTH = 3;
	
	localparam CTRL_NONE = 3'd0;
	localparam CTRL_CLR  = 3'd1;
	localparam CTRL_LOAD = 3'd2;
	localparam CTRL_INCR = 3'd3;
	localparam CTRL_DECR = 3'd4;
	
	localparam HISTORY_LENGTH = 2 ** HISTORY_WIDTH;
	
	reg [(CTRL_WIDTH - 1) : 0] history_ctrl;
	reg [(HISTORY_LENGTH * DIGIT_WIDTH - 1) : 0] history_input;
	wire [(HISTORY_LENGTH * DIGIT_WIDTH - 1) : 0] history_output;
	
	register
		#(
			.DATA_WIDTH(HISTORY_LENGTH * DIGIT_WIDTH)
		)
	history_register
		(
			.rst(rst),
			.clk(clk),
			.ctrl(history_ctrl),
			.data_input(history_input),
			.data_output(history_output)
		);
	
	reg [(CTRL_WIDTH - 1) : 0] index_ctrl;
	reg [(HISTORY_WIDTH - 1) : 0] index_input;
	wire [(HISTORY_WIDTH - 1) : 0] index_output;
	
	register
		#(
			.DATA_WIDTH(HISTORY_WIDTH)
		)
	index_register
		(
			.rst(rst),
			.clk(clk),
			.ctrl(index_ctrl),
			.data_input(index_input),
			.data_output(index_output)
		);
	
	reg [(CTRL_WIDTH - 1) : 0] size_ctrl;
	reg [(HISTORY_WIDTH - 1) : 0] size_input;
	wire [(HISTORY_WIDTH - 1) : 0] size_output;
	
	register
		#(
			.DATA_WIDTH(HISTORY_WIDTH)
		)
	size_register
		(
			.rst(rst),
			.clk(clk),
			.ctrl(size_ctrl),
			.data_input(size_input),
			.data_output(size_output)
		);
	
	localparam TIMER_WIDTH = 28;
	
	localparam TICK_1000_MS = 28'd2;
	// localparam TICK_1000_MS = 28'd50_000_000;
	
	reg [(CTRL_WIDTH - 1) : 0] timer_ctrl;
	wire [(TIMER_WIDTH - 1) : 0] timer_output;
	
	register
		#(
			.DATA_WIDTH(TIMER_WIDTH)
		)
	timer
		(
			.rst(rst),
			.clk(clk),
			.ctrl(timer_ctrl),
			.data_input({ TIMER_WIDTH{1'b0} }),
			.data_output(timer_output)
		);
	
	reg [(DIGIT_WIDTH - 1) : 0] encoder_input;
	wire [(ENCODING_WIDTH - 1) : 0] encoder_output;
	
	encoder encoder_instance
		(
			.digit(encoder_input),
			.encoding(encoder_output)
		);
	
	localparam MAIN_MODE = 1'b0;
	localparam HISTORY_MODE = 1'b1;
	
	localparam INDICATOR_OFF = 1'b0;
	localparam INDICATOR_ON	 = 1'b1;
	
	reg state_reg, state_next;
	reg [(DIGIT_NUM - 1) : 0] choice_reg, choice_next;
	reg indicator_reg, indicator_next;
	
	always @(negedge rst, posedge clk) begin
		if (!rst) begin
			state_reg <= MAIN_MODE;
			choice_reg <= { DIGIT_NUM{1'b0} };
			indicator_reg <= INDICATOR_OFF;
		end
		else begin
			state_reg <= state_next;
			choice_reg <= choice_next;
			indicator_reg <= indicator_next;
		end
	end
	
	reg [(DIGIT_WIDTH - 1) : 0] digit;
	
	always @(*) begin
		history_ctrl = CTRL_NONE;
		history_input = { (HISTORY_LENGTH * DIGIT_WIDTH){1'b0} };
		
		index_ctrl = CTRL_NONE;
		index_input = { HISTORY_WIDTH{1'b0} };
		
		size_ctrl = CTRL_NONE;
		size_input = { HISTORY_WIDTH{1'b0} };
		
		timer_ctrl = CTRL_NONE;
		
		encoder_input = history_output[(index_output * DIGIT_WIDTH) +: DIGIT_WIDTH];
	
		state_next = state_reg;
		choice_next = digit_choice;
		indicator_next = indicator_reg;
		
		if (size_output == { HISTORY_WIDTH{1'b0} })
			display = { ENCODING_WIDTH{1'b1} };
		else
			display = encoder_output;
		
		casez (digit_choice)
			7'b1zzzzzz: digit = 4'd9;
			7'b01zzzzz: digit = 4'd8;
			7'b001zzzz: digit = 4'd7;
			7'b0001zzz: digit = 4'd6;
			7'b00001zz: digit = 4'd5;
			7'b000001z: digit = 4'd4;
			7'b0000001: digit = 4'd3;
			default: digit = 4'd0;
		endcase
		
		case (state_reg)
			MAIN_MODE: begin
				if (indicator_reg == INDICATOR_ON && choice_reg != digit_choice)
					indicator_next = INDICATOR_OFF;
				
				if (mode_change) begin
					index_ctrl = CTRL_CLR;
					timer_ctrl = CTRL_CLR;
					indicator_next = INDICATOR_OFF;
					
					state_next = HISTORY_MODE;
				end
				else if (digit_load) begin
					if (|digit_choice) begin
						history_ctrl = CTRL_LOAD;
						history_input = { history_output[DIGIT_WIDTH +: ((HISTORY_LENGTH - 1) * DIGIT_WIDTH)], digit };
						
						index_ctrl = CTRL_CLR;
						
						if (size_output < HISTORY_LENGTH - 1)
							size_ctrl = CTRL_INCR;
						
						encoder_input = digit;
						indicator_next = INDICATOR_ON;
					end
				end
				else if (digit_change) begin
					if (index_output == size_output)
						index_ctrl = CTRL_CLR;
					else
						index_ctrl = CTRL_INCR;
				end
			end
			
			HISTORY_MODE: begin
				if (mode_change) begin
					index_ctrl = CTRL_CLR;
					timer_ctrl = CTRL_CLR;
					
					state_next = MAIN_MODE;
				end
				else begin
					if (timer_output == TICK_1000_MS) begin
						if (index_output == size_output)
							index_ctrl = CTRL_CLR;
						else
							index_ctrl = CTRL_INCR;
						
						timer_ctrl = CTRL_CLR;
					end
					else begin
						timer_ctrl = CTRL_INCR;
					end
				end
			end
		endcase
	end
	
	assign digit_load_indicator = indicator_reg;
	
endmodule
