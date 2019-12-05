module register
	#(
		parameter WIDTH = 8
	)
	(
		input rst,
		input clk,
		input [2 : 0] ctrl,
		input [(WIDTH - 1) : 0] data_input,
		output [(WIDTH - 1) : 0] data_output
	);
	
	localparam CTRL_NONE = 3'd0;
	localparam CTRL_CLR  = 3'd1;
	localparam CTRL_LOAD = 3'd2;
	localparam CTRL_INCR = 3'd3;
	localparam CTRL_DECR = 3'd4;
	
	reg [(WIDTH - 1) : 0] data_reg, data_next;
	
	always @(negedge rst, posedge clk) begin
		if (!rst)
			data_reg <= { WIDTH{1'b0} };
		else
			data_reg <= data_next;
	end
	
	always @(*) begin
		case (ctrl)
			CTRL_CLR:
				data_next = { WIDTH{1'b0} };
			CTRL_LOAD:
				data_next = data_input;
			CTRL_INCR:
				data_next = data_reg + { { (WIDTH - 1){1'b0} }, 1'b1 };
			CTRL_DECR:
				data_next = data_reg - { { (WIDTH - 1){1'b0} }, 1'b1 };
			default:
				data_next = data_reg;
		endcase
	end
	
	assign data_output = data_reg;
	
endmodule
