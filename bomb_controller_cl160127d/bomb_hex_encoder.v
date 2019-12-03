module hex_encoder
	(
		input [3:0] decimal_digit,
		output reg [7:0] encode
	);
	
	always @(*)
	begin
		case (decimal_digit)
			4'd0 : encode = 8'hC0;
			4'd1 : encode = 8'hF9;
			4'd2 : encode = 8'hA4;
			4'd3 : encode = 8'hB0;
			4'd4 : encode = 8'h99;
			4'd5 : encode = 8'h92;
			4'd6 : encode = 8'h82;
			4'd7 : encode = 8'hF8;
			4'd8 : encode = 8'h80;
			4'd9 : encode = 8'h90;
			default : encode = 8'hFF;
		endcase
	end
endmodule
