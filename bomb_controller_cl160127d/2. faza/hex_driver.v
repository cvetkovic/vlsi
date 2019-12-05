module hex_driver
	(
		input [3:0] in,
		output reg [6:0] out
	);

	always @(*)
	begin
	
		out <= ~7'b0000_0000;
	
		case (in)
		
			4'd0:
				out <= ~7'b011_1111;
			4'd1:
				out <= ~7'b000_0110;
			4'd2:
				out <= ~7'b101_1011;
			4'd3:
				out <= ~7'b100_1111;
			4'd4:
				out <= ~7'b110_0110;
			4'd5:
				out <= ~7'b110_1101;
			4'd6:
				out <= ~7'b111_1101;
			4'd7:
				out <= ~7'b000_0111;
			4'd8:
				out <= ~7'b111_1111;
			4'd9:
				out <= ~7'b110_0111;
	
		endcase
	
	end
	
endmodule
