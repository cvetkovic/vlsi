module debouncer
	#(
		parameter SIGNAL_NUM = 1
	)
	(
		input rst,
		input clk,
		input [(SIGNAL_NUM - 1) : 0] signal_input,
		output [(SIGNAL_NUM - 1) : 0] signal_output
	);
	
	localparam CTRL_WIDTH = 2;
	localparam COUNTER_WIDTH = 20;
	
	localparam CTRL_NONE = 2'd0;
	localparam CTRL_CLR = 2'd1;
	localparam CTRL_LOAD = 2'd2;
	localparam CTRL_INCR = 2'd3;
	
	localparam TICK_10_MS = 20'd500_000;
	
	reg [(SIGNAL_NUM - 1) : 0] ff_reg [1 : 0];
	reg [(SIGNAL_NUM - 1) : 0] ff_next [1 : 0];
	
	reg [(SIGNAL_NUM - 1) : 0] data_reg;
	reg [(SIGNAL_NUM - 1) : 0] data_next;
	
	reg [(CTRL_WIDTH - 1) : 0] counter_ctrl [(SIGNAL_NUM - 1) : 0];
	wire [(COUNTER_WIDTH - 1) : 0] counter_output [(SIGNAL_NUM - 1) : 0];
	
	genvar i;
	generate
		for (i = 0; i < SIGNAL_NUM; i = i + 1) begin : generate_block
			register
				#(
					.DATA_WIDTH(COUNTER_WIDTH)
				)
			counter
				(
					.rst(rst),
					.clk(clk),
					.ctrl(counter_ctrl[i]),
					.data_input({ COUNTER_WIDTH{1'b0} }),
					.data_output(counter_output[i])
				);
		end
	endgenerate
	
	always @(negedge rst, posedge clk) begin
		if (!rst) begin
			ff_reg[0] <= { SIGNAL_NUM{1'b0} };
			ff_reg[1] <= { SIGNAL_NUM{1'b0} };
			
			data_reg <= { SIGNAL_NUM{1'b0} };
		end
		else begin
			ff_reg[0] <= ff_next[0];
			ff_reg[1] <= ff_next[1];
			
			data_reg <= data_next;
		end
	end
	
	integer j;
	always @(*) begin
		for (j = 0; j < SIGNAL_NUM; j = j + 1) begin
			counter_ctrl[j] = CTRL_NONE;
		end
	
		ff_next[0] = signal_input;
		ff_next[1] = ff_reg[0];
		
		data_next = data_reg;
		
		for (j = 0; j < SIGNAL_NUM; j = j + 1) begin
			if (counter_output[j] == TICK_10_MS) begin
				counter_ctrl[j] = CTRL_CLR;
				data_next = ff_reg[1];
			end
			else if (ff_reg[0][j] ^ ff_reg[1][j]) begin
				counter_ctrl[j] = CTRL_CLR;
			end
			else begin
				counter_ctrl[j] = CTRL_INCR;
			end
		end
	end
	
	assign signal_output = data_reg;
	
endmodule
