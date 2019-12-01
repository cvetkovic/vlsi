module parallel_register
	#(
		WIDTH = 8
	)
	(
		input clk,
		input async_nreset,
		
		input [1:0] ctrl,
		
		input [WIDTH-1:0] data_in,
		output [WIDTH-1:0] data_out
	);
	
	reg [WIDTH-1:0] data_reg, data_next;
	
	localparam NONE = 2'd0;
	localparam LOAD = 2'd1;
	localparam INCR = 2'd2;
	localparam CLR = 2'd3;
	
	always @(*)
	begin
		case (ctrl)
			LOAD:
				data_next <= data_in;
			INCR:
				data_next <= data_reg + {{WIDTH-1{1'b0}}, 1'b1};
			CLR:
				data_next <= {WIDTH{1'b0}};
			default:
				data_next <= data_reg;
		endcase
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (async_nreset == 1'b0)
			data_reg <= {WIDTH{1'b0}};
		else
			data_reg <= data_next;
	end
	
	assign data_out = data_reg;
	
endmodule
