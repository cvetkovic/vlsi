module memory
	#(
		ADDRESS_WIDTH = 8,
		DATA_WIDTH = 8
	)
	(
		input clk,
		
		input [ADDRESS_WIDTH-1:0] address,
		input [DATA_WIDTH-1:0] data_in,
		input write,
		
		output reg [DATA_WIDTH-1:0] data_out
	);
	
	(* ram_init_file = "memory_initialization_1.mif" *)
	reg [DATA_WIDTH-1:0] mem [2 ** ADDRESS_WIDTH - 1 : 0];
	
	always @(posedge clk)
	begin
		if (write)
			mem[address] <= data_in;
			
		data_out <= mem[address];
	end
	
endmodule
