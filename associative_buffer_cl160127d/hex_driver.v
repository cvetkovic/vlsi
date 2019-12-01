module hex_driver
	(
		input [3:0] in,
		output reg [7:0] out
	);

	always @(*)
	begin
	
		out <= 8'b0000_0000;
	
		case (in)
		
			4'd0:
				out <= ~8'b0011_1111;
			4'd1:
				out <= ~8'b0000_0110;
			4'd2:
				out <= ~8'b0101_1011;
			4'd3:
				out <= ~8'b0100_1111;
			4'd4:
				out <= ~8'b0110_0110;
			4'd5:
				out <= ~8'b0110_1101;
			4'd6:
				out <= ~8'b0110_1101;
			4'd7:
				out <= ~8'b0000_0111;
			4'd8:
				out <= ~8'b0111_1111;
			4'd9:
				out <= ~8'b0110_0111;
	
		endcase
	
	end
	
endmodule
