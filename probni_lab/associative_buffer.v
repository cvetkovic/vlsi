module associative_buffer
	#(
		WIDTH = 8,
		SIZE = 1
	)
	(
		input clk,
		input async_nreset,
		
		input write,
		input inc,
		input clear,
		
		input [SIZE-1:0] address,
		input [WIDTH-1:0] data_in,
		output [WIDTH-1:0] data_out,
		output valid
	);

	reg [2 ** SIZE-1:0] register_load;
	reg [2 ** SIZE-1:0] register_inc;
	reg [2 ** SIZE-1:0] register_clear;
	wire [WIDTH-1:0] register_data [2 ** SIZE-1:0];
	
	wire valid_data [2 ** SIZE-1:0];
	
	genvar i;
	generate 
		for (i = 0; i < 2 ** SIZE; i = i + 1)
		begin : genBlock
			parallel_register
			#(
				.WIDTH(8)
			)
			parallel_register_i
			(
				.clk(clk),
				.async_nreset(async_nreset),
				
				.load(register_load[i]),
				.inc(register_inc[i]),
				.clear(register_clear[i]),
				
				.data_in(data_in),
				.data_out(register_data[i])
			);
			
			parallel_register
			#(
				.WIDTH(8)
			)
			valid_register_i
			(
				.clk(clk),
				.async_nreset(async_nreset),
				
				.load(register_load[i]),
				.inc(1'b0),
				.clear(register_clear[i]),
				
				.data_in(1'b1),
				.data_out(valid_data[i])
			);
		end
	endgenerate
	
	always @(*)
	begin
	
		register_load <= {2 ** SIZE{1'b0}};
		register_inc <= {2 ** SIZE{1'b0}};
		register_clear <= {2 ** SIZE{1'b0}};
		
		if (~valid_data[address] && write)
		begin
		
			// this will trigger both register and valid
			register_load[address] <= 1'b1;
			
		end
		else if (valid_data[address] && inc)
		begin
		
			// this will trigger only register
			register_inc[address] <= 1'b1;
			
		end
		else if (valid_data[address] && clear)
		begin
		
			// this will trigger both register and valid
			register_clear[address] <= 1'b1;
			
		end
	
	end
	
	assign data_out = register_data[address];
	assign valid = valid_data[address];
	
endmodule
