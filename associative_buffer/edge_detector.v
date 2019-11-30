module edge_detector
	#(
		parameter SIGNAL_NUM = 8,
		parameter EDGE = 0
	)
	(
		input rst,
		input clk,
		input [(SIGNAL_NUM - 1) : 0] signal_input,
		output reg [(SIGNAL_NUM - 1) : 0] signal_output
	);
	
	reg [(SIGNAL_NUM - 1) : 0] ff_reg [1 : 0];
	reg [(SIGNAL_NUM - 1) : 0] ff_next [1 : 0];
	
	always @(negedge rst, posedge clk) begin
		if (!rst) begin
			ff_reg[0] <= { SIGNAL_NUM{1'b0} };
			ff_reg[1] <= { SIGNAL_NUM{1'b0} };
		end
		else begin
			ff_reg[0] <= ff_next[0];
			ff_reg[1] <= ff_next[1];
		end
	end
	
	always @(*) begin
		ff_next[0] = signal_input;
		ff_next[1] = ff_reg[0];
	end
	
	always @(*) begin
		case (EDGE)
			2'd0:
				signal_output = ff_reg[0] & ~ff_reg[1];
			2'd1:
				signal_output = ~ff_reg[0] & ff_reg[1];
			2'd2:
				signal_output = ff_reg[0] ^ ff_reg[1];
		endcase
	end
	
endmodule
