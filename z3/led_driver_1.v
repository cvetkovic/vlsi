module led_driver_1
	(
		input clk,
		input async_nreset,
		
		input next_led_re,
		
		output reg [4:0] led
	);
	
	localparam OFF_STATE = 4'd0;
	localparam STATE_A = 4'd1;
	localparam STATE_B = 4'd2;
	localparam STATE_C = 4'd3;
	localparam STATE_D = 4'd4;
	localparam STATE_E = 4'd5;
	localparam STATE_F = 4'd6;
	localparam STATE_G = 4'd7;
	localparam STATE_H = 4'd8;
	localparam STATE_I = 4'd9;
	
	reg [3:0] state_reg, state_next;
	
	always @(*)
	begin
		state_next <= state_reg;
		
		if (next_led_re)
		begin
			case (state_reg)
				OFF_STATE:
					state_next <= STATE_A;
				STATE_A:
					state_next <= STATE_B;
				STATE_B:
					state_next <= STATE_C;
				STATE_C:
					state_next <= STATE_D;
				STATE_D:
					state_next <= STATE_E;
				STATE_E:
					state_next <= STATE_F;
				STATE_F:
					state_next <= STATE_G;
				STATE_G:
					state_next <= STATE_H;
				STATE_H:
					state_next <= STATE_I;
				STATE_I:
					state_next <= OFF_STATE;
			endcase
		end
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (async_nreset == 1'b0)
			state_reg <= OFF_STATE;
		else 
			state_reg <= state_next;
	end
	
	always @(*)
	begin
		case (state_reg)
			OFF_STATE:
				led <= 5'b0_0000;
			STATE_A:
				led <= 5'b0_0001;
			STATE_B:
				led <= 5'b1_0000;
			STATE_C:
				led <= 5'b0_0010;
			STATE_D:
				led <= 5'b0_1000;
			STATE_E:
				led <= 5'b0_0100;
			STATE_F:
				led <= 5'b0_0010;
			STATE_G:
				led <= 5'b0_1000;
			STATE_H:
				led <= 5'b0_0001;
			STATE_I:
				led <= 5'b1_0000;
			default:
				led <= 5'b0_0000;
		endcase
	end
	
endmodule