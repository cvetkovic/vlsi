module associative_buffer
	#(
		parameter DATA_WIDTH,
		parameter KEY_WIDTH,
		parameter BUFFER_SIZE
	)
	(
		input clk,
		input async_nreset,
				
		input start_reading,
		input [1:0] ctrl,
		
		input [KEY_WIDTH-1:0] key,
		input [DATA_WIDTH-1:0] data_in,
		output reg [DATA_WIDTH-1:0] data_out,
		output reg valid
	);
	
	reg [1:0] valid_register_ctrl [BUFFER_SIZE-1:0];
	reg valid_register_input [BUFFER_SIZE-1:0];
	wire valid_register_output [BUFFER_SIZE-1:0];
	
	reg [1:0] tag_register_ctrl [BUFFER_SIZE-1:0];
	reg [KEY_WIDTH-1:0] tag_register_input [BUFFER_SIZE-1:0];
	wire [KEY_WIDTH-1:0] tag_register_output [BUFFER_SIZE-1:0];
	
	reg [1:0] data_register_ctrl [BUFFER_SIZE-1:0];
	reg [DATA_WIDTH-1:0] data_register_input [BUFFER_SIZE-1:0];
	wire [DATA_WIDTH-1:0] data_register_output [BUFFER_SIZE-1:0];
	
	reg [1:0] lru_register_ctrl [BUFFER_SIZE-1:0];
	reg [31:0] lru_register_input [BUFFER_SIZE-1:0];
	wire [31:0] lru_register_output [BUFFER_SIZE-1:0];
	
	genvar i;
	generate
		for (i = 0; i < BUFFER_SIZE; i = i + 1)
		begin : genBlock
			
			parallel_register
			#(
				.WIDTH(1)
			)
			valid_register_i
			(
				.clk(clk),
				.async_nreset(async_nreset),
				
				.ctrl(valid_register_ctrl[i]),
				
				.data_in(valid_register_input[i]),
				.data_out(valid_register_output[i])
			);
			
			parallel_register
			#(
				.WIDTH(KEY_WIDTH)
			)
			tag_register_i
			(
				.clk(clk),
				.async_nreset(async_nreset),
				
				.ctrl(tag_register_ctrl[i]),
				
				.data_in(tag_register_input[i]),
				.data_out(tag_register_output[i])
			);
			
			parallel_register
			#(
				.WIDTH(DATA_WIDTH)
			)
			data_register_i
			(
				.clk(clk),
				.async_nreset(async_nreset),
				
				.ctrl(data_register_ctrl[i]),
				
				.data_in(data_register_input[i]),
				.data_out(data_register_output[i])
			);
			
			parallel_register
			#(
				.WIDTH(32)
			)
			lru_register_i
			(
				.clk(clk),
				.async_nreset(async_nreset),
				
				.ctrl(lru_register_ctrl[i]),
				
				.data_in(lru_register_input[i]),
				.data_out(lru_register_output[i])
			);
			
		end
	endgenerate

	localparam NONE = 2'd0;
	localparam LOAD = 2'd1;
	localparam INCR = 2'd2;
	localparam CLR = 2'd3;
	
	integer j, size, index;
	
	localparam BUFFER_MODE = 1'd0;
	localparam WRITING_MODE = 1'd1;
	
	reg state_reg, state_next;
	
	reg [1:0] writing_mode_counter_ctrl;
	reg [31:0] writing_mode_counter_data_in;
	wire [31:0] writing_mode_counter_data_output;
	
	wire timer_enabled;
	wire second_elapsed;
	
	always @(*)
	begin
		size = 0;
		index = BUFFER_SIZE;
			
		valid <= 1'b0;
		data_out <= {DATA_WIDTH{1'b0}};
		writing_mode_counter_ctrl <= NONE;
	
		for (j = 0; j < BUFFER_SIZE; j = j + 1)
		begin
		
			valid_register_ctrl[j] <= NONE;
			tag_register_ctrl[j] <= NONE;
			data_register_ctrl[j] <= NONE;
			lru_register_ctrl[j] <= NONE;
			
			valid_register_input[j] <= 1'b0;
			tag_register_input[j] <= {KEY_WIDTH{1'b0}};
			data_register_input[j] <= {DATA_WIDTH{1'b0}};
			lru_register_input[j] <= 32'b0;
			
		
		end
		
		state_next <= state_reg;
	
		if (state_reg == BUFFER_MODE && start_reading)
			state_next <= WRITING_MODE;
		else if (state_reg == BUFFER_MODE)
		begin

			for (j = 0; j < BUFFER_SIZE; j = j + 1)
			begin
				if (tag_register_output[j][0+:KEY_WIDTH] == key && valid_register_output[j])
					index = j;
					
				if (valid_register_output[j])
					size = size + 1;
			end
			
			if (index == BUFFER_SIZE)
			begin
				if (size < BUFFER_SIZE)
				begin
			
					// space available, key not found -> insert new one
				
					valid_register_ctrl[size] <= LOAD;
					tag_register_ctrl[size] <= LOAD;
					data_register_ctrl[size] <= ctrl;
					lru_register_ctrl[size] <= LOAD;
					
					valid_register_input[size] <= 1'b1;
					tag_register_input[size] <= key;
					data_register_input[size] <= data_in;
					lru_register_input[size] <= 1'b0;
					
					data_out <= data_register_output[size];
				
					// increment all other elements lru by 1
					for (j = 0; j < BUFFER_SIZE; j = j + 1)
					begin
						if (j != size)
							lru_register_ctrl[j] <= INCR;
					end
				end
				else 
				begin
				
					// no space available, key not found -> remove lru, insert new one
				
					// find LRU
					for (j = 0; j < BUFFER_SIZE; j = j + 1)
					begin
						if (lru_register_output[j] == BUFFER_SIZE - 1)
							index = j;
					end
					
					valid_register_ctrl[index] <= LOAD;
					tag_register_ctrl[index] <= LOAD;
					data_register_ctrl[index] <= ctrl;
					lru_register_ctrl[index] <= LOAD;
					
					valid_register_input[index] <= 1'b1;
					tag_register_input[index] <= key;
					data_register_input[index] <= data_in;
					lru_register_input[index] <= 1'b0;
					
					data_out <= data_register_output[index];
				
					// increment all other elements lru by 1
					for (j = 0; j < BUFFER_SIZE; j = j + 1)
					begin
						if (j != index)
							lru_register_ctrl[j] <= INCR;
					end
				
				end
				
			end
			else
			begin
			
				// key found -> do something on top of it
			
				if (ctrl == CLR)
				begin
					valid_register_ctrl[index] <= ctrl;			// set valid to 0 if
					tag_register_ctrl[index] <= ctrl;			
				end
			
				data_register_ctrl[index] <= ctrl;
				data_register_input[index] <= data_in;
				lru_register_ctrl[index] <= INCR;
				
				valid <= valid_register_output[index];
				data_out <= data_register_output[index];
			
				// increment all other elements lru by 1
				for (j = 0; j < BUFFER_SIZE; j = j + 1)
				begin
					if (j != index)
						lru_register_ctrl[j] <= INCR;
				end
			
			end
		end
		else if (state_reg == WRITING_MODE)
		begin
		
			data_out <= data_register_output[writing_mode_counter_data_output];
		
			if (second_elapsed)
				writing_mode_counter_ctrl <= INCR;
			
			if ((writing_mode_counter_data_output == BUFFER_SIZE - 1) && (second_elapsed))
				state_next <= BUFFER_MODE;
		
		end
	
	end
	
	parallel_register
	#(
		.WIDTH(32)
	)
	writing_mode_counter
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.ctrl(writing_mode_counter_ctrl),
		
		.data_in(writing_mode_counter_data_in),
		.data_out(writing_mode_counter_data_output)
	);
	
	timer timer_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.enabled(timer_enabled),
		
		.second_elapsed(second_elapsed)
	);
	
	assign timer_enabled = (state_reg == WRITING_MODE);
		
	always @(posedge clk, negedge async_nreset)
	begin
		if (async_nreset == 1'b0)
			state_reg <= BUFFER_MODE;
		else
			state_reg <= state_next;
	end
	
endmodule
