module led_shifter_3
	(
		input clk,
		input async_nreset,
		
		input button0_re,
		input button1_re,
		
		input show_parity_deb,
		
		input show_history_deb,
		
		output reg [7:0] out,
		output reg [7:0] hex
	);
	
	reg [7:0] number_reg, number_next;
	reg [15:0] history_reg, history_next;
	
	reg [1:0] history_state_reg, history_state_next;
	
	localparam HISTORY_L = 2'd0;
	localparam HISTORY_H = 2'd1;
	localparam HISTORY_OFF = 2'd2;
	
	reg timer_clear;
	reg timer_enable;
	wire trigger1;
	wire trigger2;
	wire trigger3;
	
	timer timer_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.clear(timer_clear),
		.enable(timer_enable),
		
		.trigger1(trigger1),
		.trigger2(trigger2),
		.trigger3(trigger3)
	);
	
	always @(*)
	begin
		number_next <= number_reg;
		history_next <= history_reg;
		history_state_next <= history_state_reg;
		
		timer_clear <= 1'b0;
		timer_enable <= 1'b1;
		
		if (show_history_deb == 1'b0)
		begin
		
			if (button0_re)
			begin
				number_next <= {number_reg[6:0], 1'b0};
				history_next <= {history_reg[14:0], 1'b0};
			
				timer_clear <= 1'b1;
			end
			else if (button1_re)
			begin
				number_next <= {number_reg[6:0], 1'b1};
				history_next <= {history_reg[14:0], 1'b1};
				
				timer_clear <= 1'b1;
			end
		end
		else
		begin
			
			timer_enable <= 1'b1;
			
			if (trigger1)
				history_state_next <= HISTORY_H;
			else if (trigger2)
				history_state_next <= HISTORY_OFF;
			else if (trigger3)
				history_state_next <= HISTORY_L;
			
		end
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (async_nreset == 1'b0)
		begin
			number_reg <= 8'd0;
			history_reg <= 16'd0;
			history_state_reg <= HISTORY_L;
		end
		else
		begin
			number_reg <= number_next;
			history_reg <= history_next;
			history_state_reg <= history_state_next;
		end
	end
	
	always @(*)
	begin
		
		out <= 8'd0;
		hex <= 8'd0;
		
		if (show_parity_deb)
		begin
			case (~(^number_reg))
				1'b0:
					hex <= 8'b0011_1111;
				1'b1:
					hex <= 8'b0000_0011;
			endcase
		end
		
		if (show_history_deb == 1'b0)
		begin
			out <= number_reg;
		end
		else
		begin
			case (history_state_reg)
				HISTORY_L:
					out <= history_reg[7:0];
				HISTORY_H:
					out <= history_reg[15:8];
				HISTORY_OFF:
					out <= 8'd00;
			endcase
		end
		
	end
	
endmodule