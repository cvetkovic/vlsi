module cpu_top
	(
		input clk,
		input async_nreset,
		input [7:0] io_in,
		input trap_trigger,
		
		output [7:0] io_out
	);
	
	rising_edge trap_rising_edge
	(
		.clk(clk),
		.in(trap_trigger),
		.async_nreset(async_nreset),
		
		.out(trap_re)
	);
	
	wire trap_re;
	
	register
	#(.WIDTH(8))
	io_register_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		.data_in(io_buffer),
		.load(io_write),
		.inc(1'b0),
		.data_out(io_out)
	);
	
	wire [7:0] io_buffer;
	wire io_write;
	
	memory_module memory
	(
		.data_in(mem_data_bus_out),
		.data_out(mem_data_bus_in),
		.address(mem_address_bus),
		.write(mem_write),
		.clk(clk)
	);
	
	wire [7:0] mem_address_bus;
	wire [7:0] mem_data_bus_in;
	wire [7:0] mem_data_bus_out;
	wire mem_write;
	
	cpu cpu_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.mem_data_input(mem_data_bus_in),
		.mem_data_output(mem_data_bus_out),
		.mem_address_output(mem_address_bus),
		.mem_write(mem_write),
		
		.io_data_input(io_in),
		.io_data_output(io_buffer),
		.io_write(io_write),
		
		.trap_trigger(trap_re)
	);
	
endmodule
