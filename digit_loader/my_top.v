module my_top
	(
		input clk, 
		input async_nreset,
		
		input sw0,
		input btn0, 
		input btn1, 
		input btn2,
		
		output reg [7:0] hex0
	);

	wire sw0_deb;
	wire btn0_re, btn2_re;
	
	rising_edge rising_edge_0
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.in(btn0),
		.out(btn0_re)
	);
	
	rising_edge rising_edge_1
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.in(btn1),
		.out(btn1_re)
	);
	
	rising_edge rising_edge_2
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.in(btn2),
		.out(btn2_re)
	);
	
	debouncer debouncer_sw0
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.signal_in(sw0),
		.signal_out(sw0_deb)
	);
	
	wire [3:0] hex0_driver;
	wire [7:0] hex0_driver_output;
	
	hex_driver hex_driver_inst
	(
		.in(hex0_driver),
		.out(hex0_driver_output)
	);
	
	wire valid;
	
	lab_1 lab_1_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.sw0(sw0_deb),
		.btn0(btn0_re),
		.btn2(btn2_re),
		
		.bcd_output(hex0_driver),
		.valid(valid)
	);
	
	always @(*)
	begin
		if (valid)
			hex0 <= hex0_driver_output;
		else
			hex0 <= 8'b1111_1111;
	end
	
endmodule
