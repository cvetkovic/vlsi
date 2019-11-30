module controller
	#(
		parameter DIGIT_NUM = 4,
		parameter TIMER_WIDTH = 28,
		parameter CTRL_WIDTH = 3
	)
	(
		input rst,
		input clk,
		input [3 : 0] trigger,
		input [(TIMER_WIDTH - 1) : 0] timer_input,
		output reg [(CTRL_WIDTH - 1) : 0] timer_ctrl,
		output [7 : 0] hex0,
		output [7 : 0] hex1,
		output [7 : 0] hex2,
		output [7 : 0] hex3
	);
	
	localparam DIGIT_WIDTH = 4;
	
	localparam DISPLAY_NUM = 4;
	
	reg [(CTRL_WIDTH - 1) : 0] digits_ctrl [(DIGIT_NUM - 1) : 0];
	reg [(DIGIT_WIDTH - 1) : 0] digits_data_input [(DIGIT_NUM - 1) : 0];
	wire [(DIGIT_WIDTH - 1) : 0] digits_data_output [(DIGIT_NUM - 1) : 0];
	
	wire [7 : 0] encoding [(DIGIT_NUM - 1) : 0];
	reg [7 : 0] encoding_to_display [(DISPLAY_NUM - 1) : 0];
	
	genvar i;
	generate
		for (i = 0; i < DIGIT_NUM; i = i + 1) begin : generate_block
			register
				#(
					.DATA_WIDTH(DIGIT_WIDTH),
					.CTRL_WIDTH(CTRL_WIDTH)
				)
			digit
				(
					.rst(rst),
					.clk(clk),
					.ctrl(digits_ctrl[i]),
					.data_input(digits_data_input[i]),
					.data_output(digits_data_output[i])
				);
			
			encoder encoder_instance
				(
					.digit(digits_data_output[i]),
					.encoding(encoding[i])
				);
		end
	endgenerate
	
	localparam STATE_INITIAL = 2'd0;
	localparam STATE_COUNTING = 2'd1;
	localparam STATE_BOOM = 2'd2;
	
	reg [1 : 0] state_reg, state_next;
	reg blink_reg, blink_next;
	
	always @(negedge rst, posedge clk) begin
		if (!rst) begin
			state_reg <= STATE_INITIAL;
			blink_reg <= 1'b0;
		end
		else begin
			state_reg <= state_next;
			blink_reg <= blink_next;
		end
	end
	
	localparam TICK_1000_MS = 28'd50_000_000;
	localparam TICK_500_MS  = 28'd25_000_000;
	
	localparam CTRL_NONE = 3'd0;
	localparam CTRL_CLR  = 3'd1;
	localparam CTRL_LOAD = 3'd2;
	localparam CTRL_INCR = 3'd3;
	localparam CTRL_DECR = 3'd4;
	
	reg all_zero;
	
	integer j, k;
	always @(*) begin
		k = 0;
		all_zero = 1'b1;
		timer_ctrl = CTRL_NONE;
		
		for (j = 0; j < DIGIT_NUM; j = j + 1) begin
			digits_ctrl[j] = CTRL_NONE;
			digits_data_input[j] = { DIGIT_WIDTH{1'b0} };
			
			if (|digits_data_output[j])
				all_zero = 1'b0;
		end
		
		for (j = 0; j < DISPLAY_NUM; j = j + 1) begin
			encoding_to_display[j] = 8'hFF;
		end
		
		state_next = state_reg;
		blink_next = blink_reg;
		
		case (state_reg)
			STATE_INITIAL: begin
				/* casez (trigger)
					4'b1zzz: digit_num = 4;
					4'b01zz: digit_num = 3;
					4'b001z: digit_num = 2;
					4'b0001: digit_num = 1;
				endcase */
				
				if (|trigger) begin
					for (j = 0; j < DIGIT_NUM; j = j + 1) begin
						digits_ctrl[j] = CTRL_LOAD;
						digits_data_input[j] = 4'd9;
					end
					
					timer_ctrl = CTRL_CLR;
					state_next = STATE_COUNTING;
				end
			end
			
			STATE_COUNTING: begin
				for (j = 0; j < DIGIT_NUM; j = j + 1) begin
					encoding_to_display[j] = encoding[j];
				end
				
				if (all_zero) begin
					timer_ctrl = CTRL_CLR;
					state_next = STATE_BOOM;
				end
				else begin
					if (timer_input == TICK_1000_MS) begin
						j = 0;
						k = 0;
						while (j < DIGIT_NUM && digits_data_output[k] == 4'd0) begin
							digits_ctrl[j] = CTRL_LOAD;
							digits_data_input[j] = 4'd9;
							j = j + 1;
							if (j < DIGIT_NUM)
								k = k + 1;
						end
						
						digits_ctrl[j] = CTRL_DECR;
						timer_ctrl = CTRL_CLR;
					end
					else begin
						timer_ctrl = CTRL_INCR;
					end
				end
			end
			
			STATE_BOOM: begin
				for (j = 0; j < DIGIT_NUM; j = j + 1) begin
					encoding_to_display[j] = { 1'b1, blink_reg, 6'b111111 };
				end
				
				if (timer_input == TICK_500_MS) begin
					timer_ctrl = CTRL_CLR;
					blink_next = ~blink_reg;
				end
				else begin
					timer_ctrl = CTRL_INCR;
				end
			end
		endcase
	end
	
	assign hex0 = encoding_to_display[0];
	assign hex1 = encoding_to_display[1];
	assign hex2 = encoding_to_display[2];
	assign hex3 = encoding_to_display[3];
	
endmodule
