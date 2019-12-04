module associative_buffer
	#(
		KEY_SIZE = 4,
		DATA_SIZE = 4,
		BUFFER_SIZE = 4
	)
	(
		input clk,
		input async_nreset,
		
		input [1:0] ctrl,
		input sw7,
		
		input [KEY_SIZE-1:0] key,
		input [DATA_SIZE-1:0] data_in,
		output reg [DATA_SIZE-1:0] data_out,
		output reg valid
	);
	
	reg [1:0] valid_ctrl [BUFFER_SIZE-1:0];
	reg valid_data_in [BUFFER_SIZE-1:0];
	wire valid_data_out [BUFFER_SIZE-1:0];
	
	reg [1:0] key_ctrl [BUFFER_SIZE-1:0];
	reg [KEY_SIZE-1:0] key_data_in [BUFFER_SIZE-1:0];
	wire [KEY_SIZE-1:0] key_data_out [BUFFER_SIZE-1:0];
	
	reg [1:0] data_ctrl [BUFFER_SIZE-1:0];
	reg [DATA_SIZE-1:0] data_data_in [BUFFER_SIZE-1:0];
	wire [DATA_SIZE-1:0] data_data_out [BUFFER_SIZE-1:0];
	
	reg state_reg, state_next;
	
	localparam STATE_INITIAL = 1'b0;
	localparam STATE_TIMER = 1'b1;
	
	genvar i;
	generate
		for (i = 0; i < BUFFER_SIZE; i = i + 1)
		begin : genBlockStructures
			
			register
			#(
				.WIDTH(1)
			)
			valid_register_i
			(
				.clk(clk),
				.async_nreset(async_nreset),
				
				.ctrl(valid_ctrl[i]),
				
				.data_in(valid_data_in[i]),
				.data_out(valid_data_out[i])
			);
			
			register
			#(
				.WIDTH(KEY_SIZE)
			)
			key_register_i
			(
				.clk(clk),
				.async_nreset(async_nreset),
				
				.ctrl(key_ctrl[i]),
				
				.data_in(key_data_in[i]),
				.data_out(key_data_out[i])
			);
			
			register
			#(
				.WIDTH(DATA_SIZE)
			)
			data_register_i
			(
				.clk(clk),
				.async_nreset(async_nreset),
				
				.ctrl(data_ctrl[i]),
				
				.data_in(data_data_in[i]),
				.data_out(data_data_out[i])
			);
		end
	endgenerate
	
	localparam NONE = 2'd0;
	localparam LOAD = 2'd1;
	localparam INCR = 2'd2;
	localparam CLR = 2'd3;
	
	integer size, foundAt;
	integer j;
	
	always @(*)
	begin
		state_next <= state_reg;
		timer_clear <= 1'b0;
		timer_enabled <= 1'b0;
	
		size = 0;
		foundAt = BUFFER_SIZE;
		
		counter_ctrl <= NONE;
		
		state_initial_out <= {DATA_SIZE{1'b0}};
		state_timer_out <= {DATA_SIZE{1'b0}};
		valid <= 1'b0;
		
		for (j = 0; j < BUFFER_SIZE; j = j + 1)
		begin
		
			valid_data_in[j] <= 1'b0;
			valid_ctrl[j] <= NONE;
			
			key_data_in[j] <= {KEY_SIZE{1'b0}};
			key_ctrl[j] <= NONE;
			
			data_data_in[j] <= {DATA_SIZE{1'b0}};
			data_ctrl[j] <= NONE;
		
		end
			
		if (state_reg == STATE_INITIAL)
		begin
			for (j = 0; j < BUFFER_SIZE; j = j + 1)
			begin
				if (valid_data_out[j] && key_data_out[j] == key)
					foundAt = j;
				
				if (valid_data_out[j])
					size = size + 1;
			end
			
			if (foundAt == BUFFER_SIZE)
			begin
			
				// key not found, insert if space available
				if (size < BUFFER_SIZE)
				begin
					
					valid_data_in[size] <= 1'b1;
					valid_ctrl[size] <= LOAD;
					
					key_data_in[size] <= key;
					key_ctrl[size] <= LOAD;
					
					data_data_in[size] <= data_in;
					data_ctrl[size] <= ctrl;
					
					state_initial_out <= data_data_out[size];
					
				end
			end
			else
			begin
			
				valid <= 1'b1;
			
				// key found, update data
				
				data_data_in[foundAt] <= data_in;
				data_ctrl[foundAt] <= ctrl;
				
				state_initial_out <= data_data_out[foundAt];
				
			end
			
			if (sw7)
			begin
				state_next <= STATE_TIMER;
				timer_clear <= 1'b1;
			end
		end
		else
		begin
			if (!sw7)
				state_next <= STATE_INITIAL;
				
			timer_enabled <= 1'b1;
			
			if (second_elapsed)
			begin
				if (counter_data_out == BUFFER_SIZE - 1)
					counter_ctrl <= CLR;
				else
					counter_ctrl <= INCR;
			end
			
			state_timer_out <= data_data_out[counter_data_out];
		end
	end
	
	reg [DATA_SIZE-1:0] state_initial_out;
	reg [DATA_SIZE-1:0] state_timer_out;
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (!async_nreset)
			state_reg <= STATE_INITIAL;
		else
			state_reg <= state_next;
	end
	
	reg timer_enabled;
	reg timer_clear;
	wire second_elapsed;
	
	timer timer_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.enable(timer_enabled),
		.clear(timer_clear),
		.second_elapsed(second_elapsed)
	);
	
	reg [1:0] counter_ctrl;
	reg [31:0] counter_data_in;
	wire [31:0] counter_data_out;	
	
	register
	#(
		.WIDTH(DATA_SIZE)
	)
	data_register_i
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.ctrl(counter_ctrl),
		
		.data_in(counter_data_in),
		.data_out(counter_data_out)
	);
	
	always @(*)
	begin
		if (state_reg == STATE_INITIAL)
		begin
			data_out <= state_initial_out;
		end
		else
		begin
			data_out <= state_timer_out;
		end
	end
	
endmodule
