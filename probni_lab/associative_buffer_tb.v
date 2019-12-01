module associative_buffer_tb;
	
	// for testing purposes make timer interval be 4 cycles
	
	localparam NONE = 2'd0;
	localparam LOAD = 2'd1;
	localparam INCR = 2'd2;
	localparam CLR = 2'd3;
	
	reg clk;
	reg async_nreset;
	
	reg start_reading;
	reg [1:0] ctrl;
	
	reg [3:0] key;
	reg [7:0] data_in;
	wire [7:0] data_out;
	wire valid;
	
	associative_buffer
	#(
		.DATA_WIDTH(8),
		.KEY_WIDTH(4),
		.BUFFER_SIZE(4)
	)
	associative_buffer_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
				
		.start_reading(start_reading),
		.ctrl(ctrl),
		
		.key(key),
		.data_in(data_in),
		.data_out(data_out),
		.valid(valid)
	);
	
	initial 
	begin
		clk <= 1'b0;
		#10;
		
		forever
		begin
			clk <= ~clk;
			#10;
		end
	end
	
	initial
	begin
		async_nreset <= 1'b0;
		#10;
		async_nreset <= 1'b1;
		#10;
		
		// write to 0
		key <= 4'b0000;
		data_in <= 4'b0000_0000;
		ctrl <= LOAD;
		
		#20;
		ctrl<= NONE;
		#20;
		
		///////////////////////////////////
		// write to 1
		key <= 4'b0001;
		data_in <= 4'b0000_1111;
		ctrl <= LOAD;
		
		#20;
		ctrl<= NONE;
		#20;
		///////////////////////////////////
		
		///////////////////////////////////
		// write to 2
		key <= 4'b0010;
		data_in <= 4'b1111_0000;
		ctrl <= LOAD;
		
		#20;
		ctrl<= NONE;
		#20;
		///////////////////////////////////
		
		/*start_reading <= 1'b1;
		#20;
		start_reading <= 1'b0;*/
		
		//#1000;
		///////////////////////////////////
		// write to 3
		key <= 4'd0011;
		data_in <= 4'b1111_1111;
		ctrl <= LOAD;
		
		#20;
		ctrl<= NONE;
		#20;
		///////////////////////////////////
		
		///////////////////////////////////
		// write to 0
		key <= 4'd1000;
		data_in <= 4'b1101_1011;
		ctrl <= LOAD;
		
		#20;
		ctrl<= NONE;
		#20;
		///////////////////////////////////
		
		#100;
		
		///////////////////////////////////
		// read from 0
		key <= 4'b1000;
		ctrl <= NONE;
		
		#20;
		///////////////////////////////////
		
		#100;
		$finish();
		
	end
	
endmodule
