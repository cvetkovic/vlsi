module memory_builtin
	#(
		DATA_WIDTH = 8,
		ADDRESS_WIDTH = 10
	)
	(
		input clk,
		input [DATA_WIDTH-1:0] data_in,
		input [ADDRESS_WIDTH-1:0] addr,
		input write,
		
		output reg [DATA_WIDTH-1:0] data_out
	);
	
	// to initialize fpga chip during programming it provide init.mif
	(* ram_init_file = "init.mif" *)
	reg [DATA_WIDTH-1:0] memory [(2 ** ADDRESS_WIDTH)-1:0];
	
	always @(posedge clk)
	begin
	
		if (write == 1'b1)
			memory[addr] <= data_in;
			
		data_out <= memory[addr];
	
	end
	
endmodule
