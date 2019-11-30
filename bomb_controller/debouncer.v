module debouncer
	(
		input rst,
		input clk,
		input signal_input,
		output signal_output
	);
	
	reg data_reg, data_next;
	reg [1 : 0] ff_reg, ff_next;
	
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
	
	localparam CTRL_LOAD = 3'd2;
	localparam CTRL_INCR = 3'd3;
	
	always @(*) begin
		counter_ctrl = 3'd0;
		data_next = data_reg;
		
		ff_next = { ff_reg[0], signal_input };
		
		if (counter_output == 20'd500_000) begin
			counter_ctrl = CTRL_LOAD;
			data_next = ff_reg[1];
		end
		else if (^ff_reg) begin
			counter_ctrl = CTRL_LOAD;
		end
		else begin
			counter_ctrl = CTRL_INCR;
		end
	end
	
	assign signal_output = data_reg;

endmodule
