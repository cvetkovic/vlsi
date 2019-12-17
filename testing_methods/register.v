module register
	#(
		parameter WIDTH = 8
	)
	(
		input clk,
		input async_nreset,
		
		input [2:0] ctrl,
		
		input serial_data_input,
		input [WIDTH-1:0] parallel_data_input,
		
		output [WIDTH-1:0] data_output
	);
	
	reg [WIDTH-1:0] data_reg, data_next;
	
	localparam NONE = 3'd0;
	localparam CLR = 3'd1;
	localparam PARALLEL_LOAD = 3'd2;
	localparam SERIAL_MSB_LOAD = 3'd3;
	localparam SERIAL_LSB_LOAD = 3'd4;
	localparam SHIFT_LOGICAL_LEFT = 3'd5;
	localparam SHIFT_LOGICAL_RIGHT = 3'd6;
	
	always @(*)
	begin
		case (ctrl)
			CLR:
				data_next <= {WIDTH{1'b0}};
			PARALLEL_LOAD:
				data_next <= parallel_data_input;
			SERIAL_MSB_LOAD:
				data_next <= {serial_data_input, data_reg[WIDTH-1:1]};
			SERIAL_LSB_LOAD:
				data_next <= {data_reg[WIDTH-2:0], serial_data_input};
			SHIFT_LOGICAL_LEFT:
				data_next <= {data_reg[WIDTH-2:0], 1'b0};
			SHIFT_LOGICAL_RIGHT:
				data_next <= {1'b0, data_reg[WIDTH-1:1]};
			default:
				data_next <= data_reg;
		endcase
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (!async_nreset)
			data_reg <= {WIDTH{1'b0}};
		else
			data_reg <= data_next;
	end
	
	assign data_output = data_reg;
	
endmodule