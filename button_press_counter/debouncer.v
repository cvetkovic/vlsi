module debouncer
	(
		input rst,
		input clk,
		input signal_input,
		output signal_output
	);
	
	localparam CTRL_NONE = 3'd0;
	localparam CTRL_CLR  = 3'd1;
	localparam CTRL_LOAD = 3'd2;
	localparam CTRL_INCR = 3'd3;
	localparam CTRL_DECR = 3'd4;
	
	// changed for simulation purposes
	// localparam TICK_10_MS = 20'd500_000;
	localparam TICK_10_MS = 20'd2;
	
	reg [1 : 0] ff_reg, ff_next;
	reg data_reg, data_next;
	
	reg [2 : 0] counter_ctrl;
	wire [19 : 0] counter_output;
	
	register
		#(
			.DATA_WIDTH(20)
		)
	counter
		(
			.rst(rst),
			.clk(clk),
			.ctrl(counter_ctrl),
			.data_input(20'd0),
			.data_output(counter_output)
		);
	
	always @(negedge rst, posedge clk) begin
		if (!rst) begin
			ff_reg <= 2'b00;
			data_reg <= 1'b0;
		end
		else begin
			ff_reg <= ff_next;
			data_reg <= data_next;
		end
	end
	
	always @(*) begin
		ff_next = { ff_reg[0], signal_input };
		data_next = data_reg;
		
		counter_ctrl = CTRL_NONE;
		
		if (counter_output == TICK_10_MS) begin
			counter_ctrl = CTRL_CLR;
			data_next = ff_reg[1];
		end
		else if (ff_reg[0] ^ ff_reg[1]) begin
			counter_ctrl = CTRL_CLR;
		end
		else begin
			counter_ctrl = CTRL_INCR;
		end
	end
	
	assign signal_output = data_reg;
	
endmodule
