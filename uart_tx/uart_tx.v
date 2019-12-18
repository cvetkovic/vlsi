module uart_tx
	#(
		parameter BAUD_RATE = 115_200,
		parameter EXTERNAL_CLOCK = 50_000_000
	)
	(
		input clk,
		input async_nreset,
		
		input [7:0] data_in,
		input data_valid,
		
		output reg data_out
	);

	reg timer_enable;
	reg timer_clear;
	wire timer_tick;
	
	uart_timer uart_timer_instance
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.enable(timer_enable),
		.clear(timer_clear),
		
		.tick(timer_tick)
	);
	
	localparam STATE_IDLE = 3'd0;
	localparam STATE_START = 3'd1;
	localparam STATE_DATA = 3'd2;
	localparam STATE_PARITY = 3'd3;
	localparam STATE_STOP = 3'd4;
	
	reg [2:0] state_reg, state_next;
	
	reg data_parity;
	reg [2:0] index_reg, index_next;
	
	always @(*)
	begin
		
		index_next <= index_reg;
		
		timer_clear <= 1'b0;
		timer_enable <= 1'b0;
		
		data_parity <= 1'b0;
		
		state_next <= state_reg;
		
		case (state_reg)
		
			STATE_IDLE: 
			begin
			
				if (data_valid)
				begin
				
					timer_clear <= 1'b1;
					state_next <= STATE_START;
				
				end
			
			end
			
			STATE_START:
			begin
			
				timer_enable <= 1'b1;
				
				if (timer_tick)
				begin
					state_next <= STATE_DATA;
					index_next <= 3'd0;
				end
			
			end
			
			STATE_DATA:
			begin
			
				timer_enable <= 1'b1;
			
				if (timer_tick)
				begin
				
					if (index_reg < 3'd7)
						index_next <= index_reg + 3'd1;
					else if (index_reg == 3'd7)
					begin
						data_parity <= ^data_in;
						state_next <= STATE_PARITY;
					end
					
				end
			
			end
		
			STATE_PARITY:
			begin
			
				timer_enable <= 1'b1;
				
				if (timer_tick)
				begin
					timer_clear <= 1'b1;
					state_next <= STATE_STOP;
				end
				
			end
			
			STATE_STOP:
			begin
			
				timer_enable <= 1'b1;
			
				if (timer_tick)
					state_next <= STATE_IDLE;
					
			end
		
		endcase
		
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (!async_nreset)
		begin
			state_reg <= STATE_IDLE;
			index_reg <= 3'd0;
		end
		else
		begin
			state_reg <= state_next;
			index_reg <= index_next;
		end
	end
	
	always @(*)
	begin
		
		case (state_reg)
		
			STATE_IDLE:
				data_out <= 1'b1;
			STATE_START:
				data_out <= 1'b0;
			STATE_DATA:
				data_out <= data_in[index_reg];
			STATE_PARITY:
				data_out <= data_parity;
			STATE_STOP:
				data_out <= 1'b1;
				
			default:
				data_out <= 1'b1;
		
		endcase
		
	end
	
endmodule
