module cpu
	(
		input clk,
		input async_nreset,
		
		input [7:0] mem_data_input,
		output reg [7:0] mem_data_output,
		output reg [7:0] mem_address_output,
		output reg mem_write,
		
		input [7:0] io_data_input,
		output reg [7:0] io_data_output,
		output reg io_write,
		
		input trap_trigger
	);
	
	// FSM
	localparam IR0_FETCH = 0;
	localparam IR0_LOAD_DECODE = 1;
	localparam IR1_LOAD_DECODE = 2;
	localparam OPERAND_FETCH = 3;
	localparam EXECUTE = 4;
	localparam TRAP = 5;
	localparam UNKNOWN_INSTRUCTION = 6;
	
	reg [3:0] state_reg, state_next;
	
	// registers
	localparam ACC = 0;
	localparam IR0 = 1;
	localparam IR1 = 2;
	localparam PC = 3;
	localparam PSW = 4;
	
	reg [7:0] reg_data_in [4:0];
	wire [7:0] reg_data_out [4:0];
	reg reg_ctrl_load [4:0];
	reg reg_ctrl_inc [4:0];
	
	genvar i;
	generate 
		for (i = 0; i < 5; i = i + 1)
		begin: register_generate
			register 
			#(.WIDTH(8)) 
			register_inst_i
			(
				.clk(clk),
				.async_nreset(async_nreset),
				.data_in(reg_data_in[i]),
				.load(reg_ctrl_load[i]),
				.inc(reg_ctrl_inc[i]),
				.data_out(reg_data_out[i])
			);
		end
	endgenerate
	
	// ALU
	reg [7:0] alu_in_a;
	reg [7:0] alu_in_b;
	reg alu_operation;
	wire [7:0] alu_out;
	wire alu_carry;
	
	alu_unit 
	#(.WIDTH(8)) 
	alu_inst
	(
		.a(alu_in_a),
		.b(alu_in_b),
		.operation(alu_operation),
		.sum(alu_out),
		.carry(alu_carry)
	);
	
	// operation codes
	localparam OC_LD 		= 4'b0000;
	localparam OC_ST 		= 4'b0001;
	localparam OC_ADD 	= 4'b0100;
	localparam OC_SUB 	= 4'b0101;
	localparam OC_IN 		= 4'b0010;
	localparam OC_OUT 	= 4'b0011;
	localparam OC_TRAP 	= 4'b1111;
	
	integer j;
	
	always @(*)
	begin
		state_next <= state_reg;
		
		for (j = 0; j < 5; j = j + 1)
		begin
			reg_data_in[j] <= 8'd0;
			reg_ctrl_load[j] <= 1'b0;
			reg_ctrl_inc[j] <= 1'b0;
		end
		
		mem_address_output <= 8'd0;
		mem_data_output <= 8'd0;
		mem_write <= 1'b0;
		
		io_data_output <= 8'd0;
		io_write <= 1'b0;
		
		alu_in_a <= 8'd0;
		alu_in_b <= 8'd0;
		alu_operation <= 1'b0;
		
	
		case (state_reg)
		
			IR0_FETCH:
			begin
				mem_address_output <= reg_data_out[PC];
				reg_ctrl_inc[PC] <= 1'b1;
				state_next <= IR0_LOAD_DECODE;
			end
			
			IR0_LOAD_DECODE:
			begin
				reg_data_in[IR0] <= mem_data_input;
				reg_ctrl_load[IR0] <= 1'b1;
				
				case (mem_data_input[7:4])
				
					OC_IN:
					begin
						reg_data_in[ACC] <= io_data_input;
						reg_ctrl_load[ACC] <= 1'b1;
						state_next <= IR0_FETCH;
					end
					
					OC_OUT:
					begin
						io_data_output <= reg_data_out[ACC];
						io_write <= 1'b1;
						state_next <= IR0_FETCH;
					end
					
					OC_TRAP:
					begin
						state_next <= TRAP;
					end
					
					OC_LD, OC_ST, OC_ADD, OC_SUB:
					begin
						mem_address_output <= reg_data_out[PC];
						reg_ctrl_inc[PC] <= 1'b1;
						state_next <= OPERAND_FETCH;
					end
					
					default:
					begin
						state_next <= UNKNOWN_INSTRUCTION;
					end
				
				endcase
			end
			
			OPERAND_FETCH:
			begin
				reg_data_in[IR1] <= mem_data_input;
				reg_ctrl_load[IR1] <= 1'b1;
			
				case (mem_data_input[7:4])
				
					OC_ST:
					begin
						mem_address_output <= mem_data_input;
						mem_data_output <= reg_data_out[ACC];
						mem_write <= 1'b1;
						state_next <= IR0_FETCH;
					end
					
					OC_LD, OC_ADD, OC_SUB:
					begin
						mem_address_output <= mem_data_input;
						state_next <= EXECUTE;
					end
					
					default:
						state_next <= UNKNOWN_INSTRUCTION;
				
				endcase
			
			end
			
			EXECUTE:
			begin
				state_next <= IR0_FETCH;
				
				case (mem_data_input[7:4])
				
					OC_LD:
					begin
						reg_data_in[ACC] <= mem_data_input;
						reg_ctrl_load[ACC] <= 1'b1;
					end
					
					OC_ADD:
					begin
						alu_in_a <= reg_data_out[ACC];
						alu_in_b <= mem_data_input;
						alu_operation <= 1'b0;
						reg_data_in[ACC] <= alu_out;
						reg_ctrl_load[ACC] <= 1'b1;
						reg_data_in[PSW] <= calculate_psw(alu_out, alu_carry);
						reg_ctrl_load[PSW] <= 1'b1;
					end
					
					OC_SUB:
					begin
						alu_in_a <= reg_data_out[ACC];
						alu_in_b <= mem_data_input;
						alu_operation <= 1'b1;
						reg_data_in[ACC] <= alu_out;
						reg_ctrl_load[ACC] <= 1'b1;
						reg_data_in[PSW] <= calculate_psw(alu_out, alu_carry);
						reg_ctrl_load[PSW] <= 1'b1;
					end
					
					default:
						state_next <= UNKNOWN_INSTRUCTION;
					
				endcase
			
			end
			
			default:
				state_next <= state_reg;
		
		endcase
		
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (async_nreset == 1'b0)
			state_reg <= 4'b0000;
		else
			state_reg <= state_next;
	end
	
	function automatic [7:0] calculate_psw;
		input [7:0] data;
		input carry;
		
		reg n, z, c;
		
		begin
			n = (data[7] == 1'b1 ? 1'b1 : 1'b0);
			z = (data == 8'd0);
			c = carry;
			
			calculate_psw = { 4'd0, n, z, c, 1'd0 };
		end
	endfunction
	
endmodule
