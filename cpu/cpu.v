module cpu
	(
		input clk,
		input async_nreset,
		
		input exit_trap,
		
		input [7:0] io_data_in,
		output reg [7:0] io_data_out,
		output reg io_write,
		
		input [7:0] mem_data_in,
		output reg [7:0] mem_addr_out,
		output reg [7:0] mem_data_out,
		output reg mem_write
	);
	
	localparam ALU_ADD = 1'd0;
	localparam ALU_SUB = 1'd1;
	
	localparam NONE = 2'd0;
	localparam INCR = 2'd1;
	localparam LOAD = 2'd2;
	localparam CLR = 2'd3;
	
	reg [1:0] register_ctrl [4:0];
	reg [7:0] register_in [4:0];
	wire [7:0] register_out [4:0];
	
	localparam ACC = 0;
	localparam PC = 1;
	localparam IR0 = 2;
	localparam IR1 = 3;
	localparam PSW = 4;
	
	localparam INSTR_LD = 4'b0000;
	localparam INSTR_ST = 4'b0001;
	localparam INSTR_ADD = 4'b0100;
	localparam INSTR_SUB = 4'b0101;
	localparam INSTR_IN = 4'b0010;
	localparam INSTR_OUT = 4'b0011;
	localparam INSTR_TRAP = 4'b1111;
	localparam INSTR_JZ = 4'b1000;
	localparam INSTR_JNZ = 4'b1001;
	localparam INSTR_JMP = 4'b1010;
	
	genvar i;
	generate
		for (i = 0; i < 5; i = i + 1)
		begin : genBlock
			register
			#(
				.WIDTH(8)
			)
			register_i
			(
				.clk(clk),
				.async_nreset(async_nreset),
				
				.ctrl(register_ctrl[i]),
				.data_in(register_in[i]),
				.data_out(register_out[i])
			);
		end
	endgenerate
	
	reg [7:0] alu_a;
	reg [7:0] alu_b;
	reg alu_op;
	wire [7:0] alu_res;
	wire alu_carry;
	
	alu alu_inst
	(
		.in_a(alu_a),
		.in_b(alu_b),
		
		.operation(alu_op),
		
		.result(alu_res),
		.carry(alu_carry)
	);
	
	reg [3:0] state_reg, state_next;
	
	localparam IR0_FETCH = 4'd0;
	localparam IR0_LOAD = 4'd1;
	localparam IR0_DECODE = 4'd2;
	localparam IR1_LOAD = 4'd3;
	localparam IR1_DECODE = 4'd4;
	localparam EXECUTE = 4'd5;
	localparam TRAP = 4'd6;
	localparam UNKNOWN_INSTRUCTION = 4'd7;
	
	localparam PSW_ZERO = 8'd0;
	
	integer j;
	
	always @(*)
	begin
	
		mem_addr_out <= {8{1'b0}};
		io_data_out <= {8{1'b0}};
		io_write <= 1'b0;
		mem_data_out <= {8{1'b0}};
		mem_write <= 1'b0;
		alu_a <= {8{1'b0}};
		alu_b <= {8{1'b0}};
		alu_op <= 1'b0;
	
		for (j = 0; j < 5; j = j + 1)
		begin
			register_ctrl[j] <= NONE;
			register_in[j] <= {8{1'b0}};
		end
	
		state_next <= state_reg;
		
		case (state_reg)
		
			IR0_FETCH:
			begin
				mem_addr_out <= register_out[PC];
				register_ctrl[PC] <= INCR;
				state_next <= IR0_LOAD;
			end
			IR0_LOAD:
			begin
				register_ctrl[IR0] <= LOAD;
				register_in[IR0] <= mem_data_in;
				state_next <= IR0_DECODE;
			end
			IR0_DECODE:
			begin
				case (register_out[IR0][7:4])
					INSTR_LD, INSTR_ST, INSTR_ADD, INSTR_SUB, INSTR_JZ, INSTR_JNZ, INSTR_JMP:
					begin
						mem_addr_out <= register_out[PC];
						register_ctrl[PC] <= INCR;
						state_next <= IR1_LOAD;
					end
					INSTR_IN:
					begin
						register_ctrl[ACC] <= LOAD;
						register_in[ACC] <= io_data_in;
						state_next <= IR0_FETCH;
					end
					INSTR_OUT:
					begin
						io_data_out <= register_out[ACC];
						io_write <= 1'b1;
						state_next <= IR0_FETCH;
					end
					INSTR_TRAP:
						state_next <= TRAP;
					default:
						state_next <= UNKNOWN_INSTRUCTION;
				endcase
			end
			IR1_LOAD:
			begin
				register_ctrl[IR1] <= LOAD;
				register_in[IR1] <= mem_data_in;
				state_next <= IR1_DECODE;
			end
			IR1_DECODE:
			begin
				case (register_out[IR0][7:4])
					INSTR_JZ:
					begin
					
						if (register_out[PSW][PSW_ZERO])
						begin
							register_in[PC] <= register_out[IR1];
							register_ctrl[PC] <= LOAD;
						end
						
						state_next <= IR0_FETCH;
					
					end
					
					INSTR_JNZ:
					begin
					
						if (!register_out[PSW][PSW_ZERO])
						begin
							register_in[PC] <= register_out[IR1];
							register_ctrl[PC] <= LOAD;
						end
						
						state_next <= IR0_FETCH;
					
					end
					
					INSTR_JMP:
					begin
						register_in[PC] <= register_out[IR1];
						register_ctrl[PC] <= LOAD;
						state_next <= IR0_FETCH;
					end
					
					INSTR_ST:
					begin
						mem_addr_out <= register_out[IR1];
						mem_data_out <= register_out[ACC];
						mem_write <= 1'b1;
						state_next <= IR0_FETCH;
					end
					
					INSTR_LD, INSTR_ADD, INSTR_SUB:
					begin
						mem_addr_out <= register_out[IR1];
						state_next <= EXECUTE;
					end
					
				endcase
			end
			EXECUTE:
			begin
				case (register_out[IR0][7:4])
					INSTR_ADD, INSTR_SUB:
					begin	
						alu_a <= register_out[ACC];
						alu_b <= mem_data_in;
						alu_op <= (register_out[IR0][7:4] == INSTR_ADD ? 1'b0 : 1'b1);
						
						register_in[ACC] <= alu_res;
						register_ctrl[ACC] <= 1'b1;
						
						if (alu_res == 8'd0)
							register_in[PSW][PSW_ZERO] <= 1'b1;
						else
							register_in[PSW][PSW_ZERO] <= 1'b0;
						register_ctrl[PSW] <= LOAD;
						
						state_next <= IR0_FETCH;
					end
					INSTR_LD:
					begin
						register_in[ACC] <= mem_data_in;
						register_ctrl[ACC] <= LOAD;
						
						if (mem_data_in == 8'd0)
							register_in[PSW][PSW_ZERO] <= 1'b1;
						else
							register_in[PSW][PSW_ZERO] <= 1'b0;
						register_ctrl[PSW] <= LOAD;
						
						state_next <= IR0_FETCH;
					end
				endcase
				
				state_next <= IR0_FETCH;
			end
			TRAP:
			begin
				if (exit_trap)
					state_next <= IR0_FETCH;
			end
		endcase
		
	end
	
	always @(posedge clk, negedge async_nreset)
	begin
		if (!async_nreset)
			state_reg <= IR0_FETCH;
		else
			state_reg <= state_next;
	end
	
endmodule
