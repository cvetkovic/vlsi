module timer
	(
		input rst,
		input clk,
		input [1 : 0] ctrl,
		output reg elapsed_sec,
		output reg elapsed_ten,
		output reg elapsed_hundred,
		output reg elapsed_thousand
	);
	
	localparam CTRL_NONE  = 2'd0;
	localparam CTRL_START = 2'd1;
	localparam CTRL_PAUSE = 2'd2;
	localparam CTRL_STOP  = 2'd3;
	
	localparam TICK_1_MS = 16'd50_000;
	localparam TICK_10_MS = 20'd500_000;
	localparam TICK_100_MS = 24'd5_000_000;
	localparam TICK_1000_MS = 28'd50_000_000;
	
	reg [27 : 0] counter_sec_reg, counter_sec_next;
	reg [23 : 0] counter_ten_reg, counter_ten_next;
	reg [19 : 0] counter_hundred_reg, counter_hundred_next;
	reg [15 : 0] counter_thousand_reg, counter_thousand_next;
	
	localparam STATE_STOPPED = 2'd0;
	localparam STATE_COUNTING = 2'd1;
	localparam STATE_PAUSED = 2'd2;
	
	reg [1 : 0] state_reg, state_next;
	
	always @(negedge rst, posedge clk) begin
		if (!rst) begin
			state_reg <= STATE_STOPPED;
			counter_sec_reg <= 28'd0;
			counter_ten_reg <= 24'd0;
			counter_hundred_reg <= 20'd0;
			counter_thousand_reg <= 16'd0;
		end
		else begin
			state_reg <= state_next;
			counter_sec_reg <= counter_sec_next;
			counter_ten_reg <= counter_ten_next;
			counter_hundred_reg <= counter_hundred_next;
			counter_thousand_reg <= counter_thousand_next;
		end
	end
	
	always @(*) begin
		elapsed_sec = 1'b0;
		elapsed_ten = 1'b0;
		elapsed_hundred = 1'b0;
		elapsed_thousand = 1'b0;
	
		state_next = state_reg;
		
		case (state_reg)
			STATE_STOPPED: begin
				counter_sec_next = 28'd0;
				counter_ten_next = 24'd0;
				counter_hundred_next = 20'd0;
				counter_thousand_next = 16'd0;
				
				if (ctrl == CTRL_START)
					state_next = STATE_COUNTING;
			end
			
			STATE_COUNTING: begin
				if (counter_sec_reg == TICK_1000_MS) begin
					elapsed_sec = 1'b1;
					counter_sec_next = 28'd0;
				end
				else begin
					counter_sec_next = counter_sec_reg + 28'd1;
				end
				
				if (counter_ten_reg == TICK_100_MS) begin
					elapsed_ten = 1'b1;
					counter_ten_next = 24'd0;
				end
				else begin
					counter_ten_next = counter_ten_reg + 24'd1;
				end
				
				if (counter_hundred_reg == TICK_10_MS) begin
					elapsed_hundred = 1'b1;
					counter_hundred_next = 20'd0;
				end
				else begin
					counter_hundred_next = counter_hundred_reg + 20'd1;
				end
				
				if (counter_thousand_reg == TICK_1_MS) begin
					elapsed_thousand = 1'b1;
					counter_thousand_next = 16'd0;
				end
				else begin
					counter_thousand_next = counter_thousand_reg + 16'd1;
				end
				
				if (ctrl == CTRL_PAUSE)
					state_next = STATE_PAUSED;
				else if (ctrl == CTRL_STOP)
					state_next = STATE_STOPPED;
			end
			
			STATE_PAUSED: begin
				counter_sec_next = counter_sec_reg;
				counter_ten_next = counter_ten_reg;
				counter_hundred_next = counter_hundred_reg;
				counter_thousand_next = counter_thousand_reg;
				
				if (ctrl == CTRL_START)
					state_next = STATE_COUNTING;
				else if (ctrl == CTRL_STOP)
					state_next = STATE_STOPPED;
			end
		endcase
	end
	
endmodule
