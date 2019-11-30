module associative_buffer
	#(
		parameter KEY_WIDTH = 5,
		parameter DATA_WIDTH = 8,
		parameter CTRL_WIDTH = 2,
		parameter BUFFER_SIZE = 128
	)
	(
		input rst,
		input clk,
		input [(CTRL_WIDTH - 1) : 0] ctrl,
		input [(KEY_WIDTH - 1) : 0] key,
		input [(DATA_WIDTH - 1) : 0] data_input,
		output reg [(DATA_WIDTH - 1) : 0] data_output,
		output reg valid
	);
	
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
	
	reg [(CTRL_WIDTH - 1) : 0] counter_ctrl [((2 ** KEY_WIDTH) - 1) : 0];
	wire [9 : 0] counter_output [((2 ** KEY_WIDTH) - 1) : 0];
	
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
		end
		
		for (i = 0; i < (2 ** KEY_WIDTH); i = i + 1) begin : generate_counter
			register
				#(
					.DATA_WIDTH(10)
				)
			key_counter_register
				(
					.rst(rst),
					.clk(clk),
					.ctrl(counter_ctrl[i]),
					.data_input(10'd0),
					.data_output(counter_output[i])
				);
		end
	endgenerate
	
	integer j, index, size;
	always @(*) begin
		size = 0;
		index = BUFFER_SIZE;
		
		for (j = 0; j < BUFFER_SIZE; j = j + 1) begin
			data_reg_ctrl[j] = CTRL_NONE;
			data_reg_input[j] = { DATA_WIDTH{1'b0} };
			
			key_reg_ctrl[j] = CTRL_NONE;
			key_reg_input[j] = { (KEY_WIDTH + 1){1'b0} };
		end
		
		valid = 1'b0;
		data_output = { DATA_WIDTH{1'b0} };
		
		for (j = 0; j < BUFFER_SIZE; j = j + 1) begin
			if (key_reg_output[j][0 +: KEY_WIDTH] == key)
				index = j;
			
			if (key_reg_output[j][KEY_WIDTH])
				size = size + 1;
		end
		
		if (index == BUFFER_SIZE && size < BUFFER_SIZE) begin
			data_reg_ctrl[size] = ctrl;
			data_reg_input[size] = data_input;
			
			key_reg_ctrl[size] = CTRL_LOAD;
			key_reg_input[size] = { 1'b1, key };
			
			data_output = data_reg_output[size];
		end
		else begin
			data_reg_ctrl[index] = ctrl;
			data_reg_input[index] = data_input;
			
			valid = key_reg_output[index][KEY_WIDTH];
			
			data_output = data_reg_output[index];
		end
	end
	
endmodule
