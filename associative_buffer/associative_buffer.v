module associative_buffer
	#(
		parameter SIZE = 2,
		parameter KEY_WIDTH = 4,
		parameter DATA_WIDTH = 4,
		parameter CTRL_WIDTH = 2,
		parameter TIMER_WIDTH = 28
	)
	(
		input rst,
		input clk,
		input read_all,
		input [(CTRL_WIDTH - 1) : 0] ctrl,
		
		input [(TIMER_WIDTH - 1) : 0] timer_input,
		output reg [(CTRL_WIDTH - 1) : 0] timer_ctrl,
		
		input [(KEY_WIDTH - 1) : 0] key,
		input [(DATA_WIDTH - 1) : 0] data_input,
		output reg [(DATA_WIDTH - 1) : 0] data_output,
		output reg valid
	);
	
	localparam BUFFER_SIZE = 2 ** SIZE;
	
	localparam CTRL_NONE = 2'd0;
	localparam CTRL_CLR = 2'd1;
	localparam CTRL_LOAD = 2'd2;
	localparam CTRL_INCR = 2'd3;
	
	reg [(CTRL_WIDTH - 1) : 0] data_reg_ctrl [(BUFFER_SIZE - 1) : 0];
	reg [(DATA_WIDTH - 1) : 0] data_reg_input [(BUFFER_SIZE - 1) : 0];
	wire [(DATA_WIDTH - 1) : 0] data_reg_output [(BUFFER_SIZE - 1) : 0];
	
	reg [(CTRL_WIDTH - 1) : 0] key_reg_ctrl [(BUFFER_SIZE - 1) : 0];
	reg [(KEY_WIDTH) : 0] key_reg_input [(BUFFER_SIZE - 1) : 0];
	wire [(KEY_WIDTH) : 0] key_reg_output [(BUFFER_SIZE - 1) : 0];
	
	reg [(CTRL_WIDTH - 1) : 0] lru_counter_ctrl [(BUFFER_SIZE - 1) : 0];
	wire [(SIZE - 1) : 0] lru_counter_output [(BUFFER_SIZE - 1) : 0];
	
	genvar i;
	generate
		for (i = 0; i < BUFFER_SIZE; i = i + 1) begin : generate_block
			register
				#(
					.DATA_WIDTH(DATA_WIDTH)
				)
			data_register
				(
					.rst(rst),
					.clk(clk),
					.ctrl(data_reg_ctrl[i]),
					.data_input(data_reg_input[i]),
					.data_output(data_reg_output[i])
				);
				
			register
				#(
					.DATA_WIDTH(KEY_WIDTH + 1)
				)
			key_register
				(
					.rst(rst),
					.clk(clk),
					.ctrl(key_reg_ctrl[i]),
					.data_input(key_reg_input[i]),
					.data_output(key_reg_output[i])
				);
			
			register
				#(
					.DATA_WIDTH(SIZE)
				)
			lru_counter_register
				(
					.rst(rst),
					.clk(clk),
					.ctrl(lru_counter_ctrl[i]),
					.data_input({ SIZE{1'b0} }),
					.data_output(lru_counter_output[i])
				);
		end
	endgenerate
	
	reg [(CTRL_WIDTH - 1) : 0] read_index_ctrl;
	wire [(SIZE - 1) : 0] read_index_output;
	
	register
		#(
			.DATA_WIDTH(SIZE)
		)
	read_index_register
		(
			.rst(rst),
			.clk(clk),
			.ctrl(read_index_ctrl),
			.data_input({ SIZE{1'b0} }),
			.data_output(read_index_output)
		);
	
	localparam STATE_MAIN = 1'b0;
	localparam STATE_READ_ALL = 1'b1;
	
	localparam TICK_1000_MS = 28'd50_000_000;
	
	reg state_reg, state_next;
	
	always @(negedge rst, posedge clk) begin
		if (!rst)
			state_reg <= STATE_MAIN;
		else
			state_reg <= state_next;
	end
	
	integer j, index, size;
	always @(*) begin
		size = 0;
		index = BUFFER_SIZE;
		
		for (j = 0; j < BUFFER_SIZE; j = j + 1) begin
			data_reg_ctrl[j] = CTRL_NONE;
			data_reg_input[j] = { DATA_WIDTH{1'b0} };
			
			key_reg_ctrl[j] = CTRL_NONE;
			key_reg_input[j] = { (KEY_WIDTH + 1){1'b0} };
			
			lru_counter_ctrl[j] = CTRL_NONE;
		end
		
		valid = 1'b0;
		data_output = { DATA_WIDTH{1'b0} };
		
		timer_ctrl = CTRL_NONE;
		read_index_ctrl = CTRL_NONE;
		
		state_next = state_reg;
		
		case (state_reg)
			STATE_MAIN: begin
				if (read_all) begin
					read_index_ctrl = CTRL_CLR;
					timer_ctrl = CTRL_CLR;
					
					state_next = STATE_READ_ALL;
				end
				
				for (j = 0; j < BUFFER_SIZE; j = j + 1) begin
					if (key_reg_output[j][0 +: KEY_WIDTH] == key)
						index = j;
					
					if (key_reg_output[j][KEY_WIDTH])
						size = size + 1;
				end
				
				if (index == BUFFER_SIZE) begin
					// MISS + NOT FULL
					if (size < BUFFER_SIZE) begin
						for (j = 0; j < BUFFER_SIZE; j = j + 1) begin
							if (key_reg_output[j][KEY_WIDTH])
								lru_counter_ctrl[j] = CTRL_INCR;
						end
					
						lru_counter_ctrl[size] = CTRL_CLR;
						
						data_reg_ctrl[size] = ctrl;
						data_reg_input[size] = data_input;
						
						key_reg_ctrl[size] = CTRL_LOAD;
						key_reg_input[size] = { 1'b1, key };
						
						data_output = data_reg_output[size];
					end
					// MISS + FULL => LRU
					else begin
						for (j = 0; j < BUFFER_SIZE; j = j + 1) begin
							if (lru_counter_output[j] == BUFFER_SIZE - 1)
								index = j;
							
							lru_counter_ctrl[j] = CTRL_INCR;
						end
						
						lru_counter_ctrl[index] = CTRL_CLR;
						
						data_reg_ctrl[index] = ctrl;
						data_reg_input[index] = data_input;
						
						key_reg_ctrl[index] = CTRL_LOAD;
						key_reg_input[index] = { 1'b1, key };
						
						valid = key_reg_output[index][KEY_WIDTH];
						data_output = data_reg_output[index];
					end
				end
				else begin
					// HIT
					for (j = 0; j < BUFFER_SIZE; j = j + 1) begin
						if (key_reg_output[j][KEY_WIDTH] && lru_counter_output[j] < lru_counter_output[index])
							lru_counter_ctrl[j] = CTRL_INCR;
					end
					
					lru_counter_ctrl[index] = CTRL_CLR;
				
					data_reg_ctrl[index] = ctrl;
					data_reg_input[index] = data_input;
					
					if (ctrl == CTRL_CLR)
						key_reg_ctrl[index] = ctrl;
					
					valid = key_reg_output[index][KEY_WIDTH];
					
					data_output = data_reg_output[index];
				end
			end
			
			STATE_READ_ALL: begin
				valid = key_reg_output[read_index_output][KEY_WIDTH];
				data_output = data_reg_output[read_index_output];
				
				if (timer_input == TICK_1000_MS) begin
					if (read_index_output == BUFFER_SIZE - 1) begin
						state_next = STATE_MAIN;
					end
					else begin
						read_index_ctrl = CTRL_INCR;
						timer_ctrl = CTRL_CLR;
					end
				end
				else begin
					timer_ctrl = CTRL_INCR;
				end
			end
		endcase
	end
	
endmodule
