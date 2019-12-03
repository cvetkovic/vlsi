module top
	#(
		parameter DEVICE_WIDTH = 2,
		parameter DIGIT_NUM = 7,
		parameter HISTORY_WIDTH = 4
	)
	(
		input rst,
		input clk,
		input [(DEVICE_WIDTH - 1) : 0] device_choice,
		input [(DIGIT_NUM - 1) : 0] digit_choice,
		input digit_load,
		input digit_change,
		input mode_change,
		output reg [((ENCODING_WIDTH + 1) * DEVICE_NUM - 1) : 0] displays_flattened,
		output digit_load_indicator
	);
	
	localparam DEVICE_NUM = 2 ** DEVICE_WIDTH;
	
	localparam ENCODING_WIDTH = 7;
	
	wire digit_load_red, digit_change_red, mode_change_red;
	
	rising_edge_detector
	rising_edge_detector_instance_1
		(
			.rst(rst),
			.clk(clk),
			.signal_input(digit_load),
			.signal_output(digit_load_red)
		);
	
	rising_edge_detector
	rising_edge_detector_instance_2
		(
			.rst(rst),
			.clk(clk),
			.signal_input(digit_change),
			.signal_output(digit_change_red)
		);
	
	rising_edge_detector
	rising_edge_detector_instance_3
		(
			.rst(rst),
			.clk(clk),
			.signal_input(mode_change),
			.signal_output(mode_change_red)
		);
	
	reg [(DIGIT_NUM - 1) : 0] digit_choices [(DEVICE_NUM - 1) : 0];
	reg digit_loads [(DEVICE_NUM - 1) : 0];
	reg digit_changes [(DEVICE_NUM - 1) : 0];
	reg mode_changes [(DEVICE_NUM - 1) : 0];
	wire [(ENCODING_WIDTH - 1) : 0] displays [(DEVICE_NUM - 1) : 0];
	wire indicators [(DEVICE_NUM - 1) : 0];
	
	reg dots [(DEVICE_NUM - 1) : 0];
	
	always @(*) begin
		integer j;
		for (j = 0; j < DEVICE_NUM; j = j + 1) begin
			displays_flattened[(j * (ENCODING_WIDTH + 1)) +: (ENCODING_WIDTH + 1)] = { dots[j], displays[j] };
		end
	end
	
	genvar i;
	generate
		for (i = 0; i < DEVICE_NUM; i = i + 1) begin : generate_block
			strange_device
				#(
					.DIGIT_NUM(DIGIT_NUM),
					.HISTORY_WIDTH(HISTORY_WIDTH)
				)
			strange_device_instance
				(
					.rst(rst),
					.clk(clk),
					.digit_choice(digit_choices[i]),
					.digit_load(digit_loads[i]),
					.digit_change(digit_changes[i]),
					.mode_change(mode_changes[i]),
					.display(displays[i]),
					.digit_load_indicator(indicators[i])
				);
		end
	endgenerate
	
	localparam STATE_RUNNING = 1'b0;
	localparam STATE_BLOCKED = 1'b1;
	
	reg state_reg, state_next;
	reg [(DEVICE_NUM - 1) : 0] history_mode_reg, history_mode_next;
	
	always @(negedge rst, posedge clk) begin
		if (!rst) begin
			state_reg <= STATE_RUNNING;
			history_mode_reg <= { DEVICE_NUM{1'b0} };
		end
		else begin
			state_reg <= state_next;
			history_mode_reg <= history_mode_next;
		end
	end
	
	always @(*) begin
		integer j, same;
		for (j = 0; j < DEVICE_NUM; j = j + 1) begin
			digit_choices[j] = { DIGIT_NUM{1'b0} };
			digit_loads[j] = 1'b0;
			digit_changes[j] = 1'b0;
			mode_changes[j] = 1'b0;
			dots[j] = 1'b1;
		end
		
		state_next = state_reg;
		history_mode_next = history_mode_reg;
		
		case (state_reg)
			STATE_RUNNING: begin : running_block
				same = 1;
				
				for (j = 1; j < DEVICE_NUM; j = j + 1) begin
					if (displays[j] != displays[0]) begin
						same = 0;
						disable running_block;
					end
				end
				
				if (&history_mode_reg && same) begin
					state_next = STATE_BLOCKED;
				end
				else begin
					digit_choices[device_choice] = digit_choice;
					digit_loads[device_choice] = digit_load_red;
					digit_changes[device_choice] = digit_change_red;
					mode_changes[device_choice] = mode_change_red;
					dots[device_choice] = 1'b0;
					
					if (mode_change)
						history_mode_next[device_choice] = ~history_mode_reg[device_choice];
				end
			end
			
			STATE_BLOCKED: begin
				// wait for reset
			end
		endcase
	end
	
	assign digit_load_indicator = indicators[device_choice];
	
endmodule
