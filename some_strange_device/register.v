module register
	#(
		parameter DATA_WIDTH = 1
	)
	(
		input rst,
		input clk,
		input [(CTRL_WIDTH - 1) : 0] ctrl,
		input [(DATA_WIDTH - 1) : 0] data_input,
		output [(DATA_WIDTH - 1) : 0] data_output
	);
	
	localparam CTRL_WIDTH = 3;
	
	localparam CTRL_NONE = 3'd0;
	localparam CTRL_CLR  = 3'd1;
	localparam CTRL_LOAD = 3'd2;
	localparam CTRL_INCR = 3'd3;
	localparam CTRL_DECR = 3'd4;
	
	reg [(DATA_WIDTH - 1) : 0] data_reg, data_next;
	
	always @(negedge rst, posedge clk) begin
		if (!rst)
			data_reg <= { DATA_WIDTH{1'b0} };
		else
			data_reg <= data_next;
	end
	
	always @(*) begin
		case (ctrl)
			CTRL_CLR:
				data_next = { DATA_WIDTH{1'b0} };
			CTRL_LOAD:
				data_next = data_input;
			CTRL_INCR:
				data_next = data_reg + { { (DATA_WIDTH - 1){1'b0} }, 1'b1 };
			CTRL_DECR:
				data_next = data_reg - { { (DATA_WIDTH - 1){1'b0} }, 1'b1 };
			default:
				data_next = data_reg;
		endcase
	end
	
	assign data_output = data_reg;
	
endmodule
