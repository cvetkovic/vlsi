module uart_rx
	#(
		parameter BAUD_RATE = 115_200,
		parameter EXTERNAL_CLOCK = 50_000_000
	)
	(
		input clk,
		input async_nreset,
		
		input data_in,
		
		output [7:0] data_out,
		output data_valid
	);
	
	reg [2:0] state_reg, state_next;
	
	localparam STATE_WAIT_FOR_START = 3'd0;
	localparam STATE_RECEIVE_DATA = 3'd1;
	localparam STATE_RECEIVE_PARITY = 3'd2;
	localparam STATE_RECEIVE_STOP = 3'd3;
	
	reg [7:0] received_data_reg, received_data_next;
	reg [2:0] rx_counter_reg, rx_counter_next;
	
	reg timer_enable;
	reg timer_clear;
	wire timer_half_tick;
	wire timer_tick;
	
	uart_timer uart_timer_instance
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.enable(timer_enable),
		.clear(timer_clear),
		
		.half_tick(timer_half_tick),
		.tick(timer_tick)
	);
	
	reg [7:0] data_out_reg, data_out_next;
	reg data_valid_reg, data_valid_next;
	
	reg change_state_reg, change_state_next;
	
	always @(*)
	begin
		
		data_out_next <= data_out_reg;
		data_valid_next <= data_valid_reg;
		change_state_next <= change_state_reg;
		
		state_next <= state_reg;
		timer_clear <= 1'b0;
		timer_enable <= 1'b0;
		
		rx_counter_next <= rx_counter_reg;
		received_data_next <= received_data_reg;
		
		case (state_reg)
		
			STATE_WAIT_FOR_START:
			begin
			
				timer_enable <= 1'b1;
			
				data_out_next <= 8'd0;
				data_valid_next <= 1'b0;
			
				if (!data_in && timer_half_tick)
				begin
					rx_counter_next <= 3'd0;
					received_data_next <= 8'd0;
					
					change_state_next <= 1'b1;
				end
			
				if (change_state_reg && timer_tick)
				begin
					change_state_next <= 1'b0;
					state_next <= STATE_RECEIVE_DATA;
				end
			end
			
			STATE_RECEIVE_DATA:
			begin
			
				timer_enable <= 1'b1;
				
				if (timer_half_tick)	// sampling the data on middle of time signalization interval
					received_data_next[rx_counter_reg] <= data_in;
				else if (timer_tick)
					rx_counter_next <= rx_counter_reg + 3'd1;
					
				if (timer_tick && rx_counter_reg == 3'd7)
					state_next <= STATE_RECEIVE_PARITY;
					
			end
			
			STATE_RECEIVE_PARITY:
			begin
			
				timer_enable <= 1'b1;
				
				if (timer_half_tick)
				begin
					if (^received_data_reg != data_in)
						state_next <= STATE_WAIT_FOR_START;
					else
					begin
						data_out_next <= received_data_reg;
						data_valid_next <= 1'b1;
					end
				end
			
				if (timer_tick)
					state_next <= STATE_RECEIVE_STOP;
			
			end
			
			STATE_RECEIVE_STOP:
			begin
				
				if (timer_tick)
					state_next <= STATE_WAIT_FOR_START;
				
			end
			
		endcase
		
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (!async_nreset)
		begin
			state_reg <= STATE_WAIT_FOR_START;
			data_out_reg <= 8'd0;
			data_valid_reg <= 1'b0;
			received_data_reg <= 8'b0;
			rx_counter_reg <= 3'd0;
			
			change_state_reg <= 1'b0;
		end
		else
		begin
			state_reg <= state_next;
			data_out_reg <= data_out_next;
			data_valid_reg <= data_valid_next;
			received_data_reg <= received_data_next;
			rx_counter_reg <= rx_counter_next;
			
			change_state_reg <= change_state_next;
		end
	end
	
	assign data_out = data_out_reg;
	assign data_valid = data_valid_reg;
	
endmodule
