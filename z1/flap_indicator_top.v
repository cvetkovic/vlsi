module flap_indicator_top
	(
		input clk,
		input async_nreset,
		input [1:0] selector,
		
		input change_mode,
		input change_position,
		
		output [3:0] segmented_output1,
		output [3:0] segmented_output2,
		output [3:0] segmented_output3,
		output [3:0] segmented_output4
	);
	
	wire [1:0] selector_deb;
	
	debouncer deb_1
	(
		.async_nreset(async_nreset),
		.clk(clk),
		.in(selector[0]),
		.out(selector_deb[0])
	);
	
	debouncer deb_2
	(
		.async_nreset(async_nreset),
		.clk(clk),
		.in(selector[1]),
		.out(selector_deb[1])
	);
	
	wire change_mode_deb;
	wire change_position_deb;
	
	rising_edge rising_edge_1
	(
		.async_nreset(async_nreset),
		.in(change_mode), 
		.clk(clk),
		.out(change_mode_deb)
	);
	
	rising_edge rising_edge_2
	(
		.async_nreset(async_nreset),
		.in(change_position), 
		.clk(clk),
		.out(change_position_deb)
	);
	
	reg [3:0] device_active;
	
	genvar i;
	generate for (i = 0; i < 4; i = i + 1)
	begin: indicator_genblock
	
		flap_indicator flap_indicator_inst
		(
			.clk(clk),
			.async_nreset(async_nreset),
			
			.change_operation_mode_debounced(change_mode_deb && device_active[i]),
			.change_state_debounced(change_position_deb && device_active[i]),
			
			.up(segmented_output_inner[i][0]),
			.hor(segmented_output_inner[i][1]),
			.down(segmented_output_inner[i][2])
		);
	
	end
	endgenerate
	
	wire [2:0] segmented_output_inner [3:0];
	reg segmented_output_inner_dot [3:0];
	
	always @(*)
	begin
	
		device_active <= 4'd0;
		segmented_output_inner_dot[0] <= 1'b0;
		segmented_output_inner_dot[1] <= 1'b0;
		segmented_output_inner_dot[2] <= 1'b0;
		segmented_output_inner_dot[3] <= 1'b0;
	
		case (selector_deb)
			2'b00:
			begin
				device_active[0] <= 1'b1;
				segmented_output_inner_dot[0] <= 1'b1;
			end
			
			2'b01:
			begin
				device_active[1] <= 1'b1;
				segmented_output_inner_dot[1] <= 1'b1;
			end
			
			2'b10:
			begin
				device_active[2] <= 1'b1;
				segmented_output_inner_dot[2] <= 1'b1;
			end
			
			2'b11:
			begin
				device_active[3] <= 1'b1;
				segmented_output_inner_dot[3] <= 1'b1;
			end
	
		endcase
	
	end
	
	assign segmented_output1 = { segmented_output_inner_dot[0], segmented_output_inner[0] };
	assign segmented_output2 = { segmented_output_inner_dot[1], segmented_output_inner[1] };
	assign segmented_output3 = { segmented_output_inner_dot[2], segmented_output_inner[2] };
	assign segmented_output4 = { segmented_output_inner_dot[3], segmented_output_inner[3] };
	
endmodule
