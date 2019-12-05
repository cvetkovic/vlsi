module stopwatch
	(
		input rst,
		input clk,
		input [1 : 0] decimal_places,
		input start,
		input pause,
		input stop,
		output [7 : 0] display0,
		output [7 : 0] display1,
		output [7 : 0] display2,
		output [7 : 0] display3,
		output reg pause_indicator
	);
	
	reg [2 : 0] digit_ctrl [3 : 0];
	wire [3 : 0] digit_output [3 : 0];
	
	wire [6 : 0] encoder_output [3 : 0];
	
	genvar i;
	generate
		for (i = 0; i < 4; i = i + 1) begin : generate_block
			register
				#(
					.WIDTH(4)
				)
			digit
				(
					.rst(rst),
					.clk(clk),
					.ctrl(digit_ctrl[i]),
					.data_input(4'd0),
					.data_output(digit_output[i])
				);
			
			encoder
			encoder_instance
				(
					.digit(digit_output[i]),
					.encoding(encoder_output[i])
				);
		end
	endgenerate
	
	localparam CTRL_START = 2'd1;
	localparam CTRL_PAUSE = 2'd2;
	localparam CTRL_STOP  = 2'd3;
	
	localparam CTRL_NONE = 3'd0;
	localparam CTRL_CLR  = 3'd1;
	localparam CTRL_LOAD = 3'd2;
	localparam CTRL_INCR = 3'd3;
	localparam CTRL_DECR = 3'd4;
	
	reg [1 : 0] timer_ctrl;
	wire elapsed_sec;
	wire elapsed_ten;
	wire elapsed_hundred;
	wire elapsed_thousand;
	
	timer
	timer_instance
		(
			.rst(rst),
			.clk(clk),
			.ctrl(timer_ctrl),
			.elapsed_sec(elapsed_sec),
			.elapsed_ten(elapsed_ten),
			.elapsed_hundred(elapsed_hundred),
			.elapsed_thousand(elapsed_thousand)
		);
	
	reg [2 : 0] counter_ctrl;
	wire [2 : 0] counter_output;
	
	register
		#(
			.WIDTH(3)
		)
	counter
		(
			.rst(rst),
			.clk(clk),
			.ctrl(counter_ctrl),
			.data_input(3'd0),
			.data_output(counter_output)
		);
	
	localparam STATE_STOPPED = 2'd0;
	localparam STATE_COUNTING = 2'd1;
	localparam STATE_PAUSED = 2'd2;
	localparam STATE_BLINK = 2'd3;
	
	reg [1 : 0] state_reg, state_next;
	reg [1 : 0] decimal_places_reg, decimal_places_next;
	
	always @(negedge rst, posedge clk) begin
		if (!rst) begin
			state_reg <= STATE_STOPPED;
			decimal_places_reg <= 2'b00;
		end
		else begin
			state_reg <= state_next;
			decimal_places_reg <= decimal_places_next;
		end
	end
	
	integer j;
	always @(*) begin
		for (j = 0; j < 4; j = j + 1) begin
			digit_ctrl[j] = CTRL_NONE;
		end
		
		timer_ctrl = CTRL_NONE;
		counter_ctrl = CTRL_NONE;
	
		state_next = state_reg;
		
		pause_indicator = 1'b0;
		
		case (state_reg)
			STATE_STOPPED: begin
				decimal_places_next = decimal_places;
				
				for (j = 0; j < 4; j = j + 1) begin
					digit_ctrl[j] = CTRL_CLR;
				end
				
				timer_ctrl = CTRL_STOP;
			
				if (start) begin
					timer_ctrl = CTRL_START;
					state_next = STATE_COUNTING;
				end
			end
			
			STATE_COUNTING: begin
				decimal_places_next = decimal_places_reg;
				
				if ((decimal_places_reg == 2'd0 && elapsed_sec) ||
					 (decimal_places_reg == 2'd1 && elapsed_ten) ||
					 (decimal_places_reg == 2'd2 && elapsed_hundred) ||
					 (decimal_places_reg == 2'd3 && elapsed_thousand)) begin : counting_block
					for (j = 0; j < 4; j = j + 1) begin
						if (digit_output[j] == 4'd9) begin
							digit_ctrl[j] = CTRL_CLR;
						end
						else begin
							digit_ctrl[j] = CTRL_INCR;
							disable counting_block;
						end
					end
				end
				
				if (pause) begin
					timer_ctrl = CTRL_PAUSE;
					state_next = STATE_PAUSED;
				end
				else if (stop) begin
					state_next = STATE_BLINK;
				end
			end
			
			STATE_PAUSED: begin
				decimal_places_next = decimal_places_reg;
				
				pause_indicator = 1'b1;
				
				if (start) begin
					timer_ctrl = CTRL_START;
					state_next = STATE_COUNTING;
				end
				else if (stop) begin
					timer_ctrl = CTRL_START;
					state_next = STATE_BLINK;
				end
			end
			
			STATE_BLINK: begin
				decimal_places_next = decimal_places_reg;
				
				if (elapsed_ten) begin
					if (counter_output == 3'd5)
						counter_ctrl = CTRL_CLR;
					else
						counter_ctrl = CTRL_INCR;
				end
				
				if (stop) begin
					counter_ctrl = CTRL_CLR;
					state_next = STATE_STOPPED;
				end
			end
		endcase
	end
	
	reg [3 : 0] dots;
	
	always @(*) begin
		case (decimal_places_reg)
			2'b00: dots = 4'b1110;
			2'b01: dots = 4'b1101;
			2'b10: dots = 4'b1011;
			default: dots = 4'b0111;
		endcase
	end
	
	assign display0 = (counter_output == 3'd5 ? 8'hFF : { dots[0], encoder_output[0] });
	assign display1 = (counter_output == 3'd5 ? 8'hFF : { dots[1], encoder_output[1] });
	assign display2 = (counter_output == 3'd5 ? 8'hFF : { dots[2], encoder_output[2] });
	assign display3 = (counter_output == 3'd5 ? 8'hFF : { dots[3], encoder_output[3] });
	
endmodule
