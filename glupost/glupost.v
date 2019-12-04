module glupost
	(
		input clk,
		input async_nreset,
		
		input [6:0] sw,
		input btn2,
		input btn1,
		input btn0,
		
		output reg led0,
		output reg [3:0] bcd_output
	);
	
	reg [1:0] register_ctrl [15:0];
	reg [3:0] register_data_in [15:0];
	wire [3:0] register_data_out [15:0];
	
	genvar i;
	generate
		for (i = 0; i < 16; i = i + 1)
		begin : genBlock
			register 
			#(
				.WIDTH(4)
			)
			register_inst_i
			(
				.clk(clk),
				.async_nreset(async_nreset),
				
				.ctrl(register_ctrl[i]),
				.data_in(register_data_in[i]),
				.data_out(register_data_out[i])
			);
		end
	endgenerate
	
	reg [1:0] mode_counter_ctrl;
	reg [3:0] mode_counter_data_in;
	wire [3:0] mode_counter_data_out;
	
	register 
	#(
		.WIDTH(4)
	)
	register_mode_counter
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.ctrl(mode_counter_ctrl),
		.data_in(mode_counter_data_in),
		.data_out(mode_counter_data_out)
	);
	
	reg timer_enable;
	reg timer_clear;
	wire second_elapsed;
	
	timer timer_inst
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.enable(timer_enable), 
		.clear(timer_clear),
		
		.second_elapsed(second_elapsed)
	);
	
	localparam MODE_REGULAR = 1'd0;
	localparam MODE_TIMER = 1'd1;
	
	localparam STATE_INITIAL = 2'd0;
	
	reg mode_reg, mode_next;
	reg led_driver_reg, led_driver_next;
	reg [6:0] old_sw_reg, old_sw_next;
	
	localparam NONE = 2'd0;
	localparam INCR = 2'd1;
	localparam LOAD = 2'd2;
	localparam CLR = 2'd3;
		
	integer k;
	
	always @(*)
	begin
		mode_next <= mode_reg;
		old_sw_next <= old_sw_reg;
		
		mode_counter_ctrl <= NONE;
		
		timer_enable <= 1'b0;
		timer_clear <= 1'b0;
		
		for (k = 15; k >= 0; k = k - 1)
		begin
			register_data_in[k] <= {4{1'b0}};
			register_ctrl[k] <= NONE;
		end
		
		if (sw != old_sw_reg)
			led_driver_next <= 1'b0;
		else
			led_driver_next <= led_driver_reg;
		
		case (mode_reg)
		
			MODE_REGULAR:
			begin
				if (btn2 && sw != 7'b000_0000)
				begin
					for (k = 15; k >= 1; k = k - 1)
					begin
						register_data_in[k] <= register_data_out[k-1];
						register_ctrl[k] <= LOAD;
					end
					
					if (sw[6])	// sw9
						register_data_in[0] <= 4'd9;
					else if (sw[5])
						register_data_in[0] <= 4'd8;
					else if (sw[4])
						register_data_in[0] <= 4'd7;
					else if (sw[3])
						register_data_in[0] <= 4'd6;
					else if (sw[2])
						register_data_in[0] <= 4'd5;
					else if (sw[1])
						register_data_in[0] <= 4'd4;
					else if (sw[0])
						register_data_in[0] <= 4'd3;
						
					register_ctrl[0] <= LOAD;
						
					led_driver_next <= 1'b1;
					old_sw_next <= sw;
				end
				else if (btn1)
				begin
					register_data_in[15] <= register_data_out[0];
					register_ctrl[15] <= LOAD;
				
					for (k = 0; k < 15; k = k + 1)
					begin
						register_data_in[k] <= register_data_out[k+1];
						register_ctrl[k] <= LOAD;
					end
				end
				else if (btn0)
				begin
					mode_next <= MODE_TIMER;
					timer_clear <= 1'b1;
					mode_counter_ctrl <= CLR;
				end
			end
			
			MODE_TIMER:
			begin
			
				timer_enable <= 1'b1;
				
				if (second_elapsed)
				begin
					register_data_in[15] <= register_data_out[0];
					register_ctrl[15] <= LOAD;
				
					for (k = 0; k < 15; k = k + 1)
					begin
						register_data_in[k] <= register_data_out[k+1];
						register_ctrl[k] <= LOAD;
					end
					
					mode_counter_ctrl <= INCR;
				end
				
				if (mode_counter_data_out == 4'd15)
				begin
					mode_next <= MODE_REGULAR;
					mode_counter_ctrl <= CLR;
				end
			end
			
		endcase
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (!async_nreset)
		begin
			mode_reg <= MODE_REGULAR;
			led_driver_reg <= 1'b0;
			old_sw_reg <= 7'd0;
		end
		else
		begin
			mode_reg <= mode_next;
			led_driver_reg <= led_driver_next;
			old_sw_reg <= old_sw_next;
		end
	end
	
	always @(*)
	begin
		bcd_output <= register_data_out[0];
		led0 <= led_driver_reg;
	end
	
endmodule
