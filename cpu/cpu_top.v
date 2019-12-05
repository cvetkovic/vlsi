module cpu_top
	(
		input clk,
		input async_nreset,
		
		input exit_trap,
		
		input [7:0] io_input,
		output [7:0] io_output
	);
	
	wire exit_trap_re;
	wire [7:0] cpu_io_data_out;
	
	rising_edge rising_edge_exit_trap
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.in(exit_trap),
		.out(exit_trap_re)
	);
	
	wire [7:0] cpu_io_output;
	wire [7:0] cpu_io_input;
	wire io_write;
	
	cpu cpu_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.exit_trap(exit_trap_re),
		
		.io_data_in(io_input),
		.io_data_out(cpu_io_output),
		.io_write(io_write),
		
		.mem_data_in(mem_data_in),
		.mem_addr_out(mem_address_out),
		.mem_data_out(mem_data_out),
		.mem_write(mem_write)
	);
	
	wire [7:0] mem_data_in;
	wire [7:0] mem_address_out;
	wire [7:0] mem_data_out;
	wire mem_write;
	
	memory memory_inst
	(
		.clk(clk),
		
		.address(mem_address_out),
		.data_in(mem_data_out),
		.write(mem_write),
		
		.data_out(mem_data_in)
	);
	
	reg [1:0] io_ctrl;
	
	register register_io
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.ctrl(io_ctrl),
		.data_in(cpu_io_output),
		.data_out(io_output)
	);
	
	always @(*)
	begin
		io_ctrl <= NONE;
		
		if (io_write)
			io_ctrl <= LOAD;
	end
	
	localparam NONE = 2'd0;
	localparam INCR = 2'd1;
	localparam LOAD = 2'd2;
	localparam CLR = 2'd3;
	
endmodule
