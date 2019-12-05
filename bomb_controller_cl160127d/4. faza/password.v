module password
	(
		input clk,
		input async_nreset,
		
		input btn0,
		input btn1,
		input btn2,
		
		input mode,
		
		output reg unlocked,
		output reg explode,
		
		output reg [3:0] led
	);
	
	reg [1:0] password_ctrl  [7:0];
	reg [3:0] password_data_in [7:0];
	wire [3:0] password_data_out [7:0];
	reg [1:0] password_length_ctrl;
	reg [2:0] password_length_data_in;
	wire [2:0] password_length_data_out;
	
	reg [1:0] history_ctrl  [7:0];
	reg [3:0] history_data_in [7:0];
	wire [3:0] history_data_out [7:0];
	reg [1:0] history_length_ctrl;
	reg [2:0] history_length_data_in;
	wire [2:0] history_length_data_out;
	
	localparam MODE_PROGRAMMING = 1'b0;
	localparam MODE_UNLOCKING = 1'b1;
	
	localparam KEY_NONE = 2'd0;
	localparam KEY_0 = 2'd1;
	localparam KEY_1 = 2'd2;
	localparam KEY_2 = 2'd3;
	
	localparam NONE = 2'd0;
	localparam INCR = 2'd1;
	localparam LOAD = 2'd2;
	localparam CLR = 2'd3;
	
	register
	#(
		.WIDTH(3)
	)
	password_length
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.ctrl(password_length_ctrl),
		.data_in(password_length_data_in),
		.data_out(password_length_data_out)
	);
	
	register
	#(
		.WIDTH(3)
	)
	history_length
	(
		.clk(clk),
		.async_nreset(async_nreset),
		
		.ctrl(history_length_ctrl),
		.data_in(history_length_data_in),
		.data_out(history_length_data_out)
	);
	
	genvar i;
	generate 
		for (i = 0; i < 8; i = i + 1)
		begin : genBlockPassword
		
			register
			#(
				.WIDTH(2)
			)
			password_reg_i
			(
				.clk(clk),
				.async_nreset(async_nreset),
				
				.ctrl(password_ctrl[i]),
				.data_in(password_data_in[i]),
				.data_out(password_data_out[i])
			);
			
			register
			#(
				.WIDTH(2)
			)
			history_reg_i
			(
				.clk(clk),
				.async_nreset(async_nreset),
				
				.ctrl(history_ctrl[i]),
				.data_in(history_data_in[i]),
				.data_out(history_data_out[i])
			);
		
		end
	endgenerate
	
	integer j;
	
	always @(*)
	begin
	
		password_length_ctrl <= NONE;
		history_length_ctrl <= NONE;
	
		for (j = 0; j < 8; j = j + 1)
		begin
			
			password_data_in[j] <= KEY_NONE;
			password_ctrl[j] <= NONE;
			history_data_in[j] <= KEY_NONE;
			history_ctrl[j] <= NONE;
			
		end
	
		
		if (mode == MODE_PROGRAMMING)
		begin
			
			if (btn0 || btn1 || btn2)
			begin
				
				for (j = 1; j < 8; j = j + 1)
				begin
					
					password_data_in[j] <= password_data_out[j - 1];
					password_ctrl[j] <= LOAD;
					
				end
				
				password_length_ctrl <= INCR;
				
			end
			
			if (btn0)
			begin
				password_data_in[0] <= KEY_0;
				password_ctrl[0] <= LOAD;
			end
			else if (btn1)
			begin
				password_data_in[0] <= KEY_1;
				password_ctrl[0] <= LOAD;
			end
			else if (btn2)
			begin
				password_data_in[0] <= KEY_2;
				password_ctrl[0] <= LOAD;
			end
			
		end
		else
		begin
		
			if (btn0 || btn1 || btn2)
			begin
				
				for (j = 1; j < 8; j = j + 1)
				begin
					
					history_data_in[j] <= history_data_out[j - 1];
					history_ctrl[j] <= LOAD;
					
				end
				
				history_length_ctrl <= INCR;
				
			end
			
			if (btn0)
			begin
				history_data_in[0] <= KEY_0;
				history_ctrl[0] <= LOAD;
			end
			else if (btn1)
			begin
				history_data_in[0] <= KEY_1;
				history_ctrl[0] <= LOAD;
			end
			else if (btn2)
			begin
				history_data_in[0] <= KEY_2;
				history_ctrl[0] <= LOAD;
			end
		
		end
		
	end
	
	integer x;
	integer miss;
	
	always @(*)
	begin
		miss = 0;
		unlocked <= 1'b0;
		explode <= 1'b0;
		led <= 4'd0;
	
		for (x = 0 ; x < 8; x = x + 1)
		begin
			if (history_data_out[x] != password_data_out[x])
			begin
				miss = miss + 1;
			end
		end
		
		if (miss == 0 && mode)
			unlocked <= 1'b1;
		else if (miss == 1 && mode && (history_length_data_out == password_length_data_out))
			led <= 4'b0001;
		else if (miss == 2 && mode && (history_length_data_out == password_length_data_out))
			led <= 4'b0011;
		else if (miss == 3 && mode && (history_length_data_out == password_length_data_out))
			led <= 4'b0111;
		else if (miss >= 4 && mode && (history_length_data_out == password_length_data_out))
		begin
			led <= 4'b1111;
			explode <= 1'b1;
		end
	
	end
	
endmodule
