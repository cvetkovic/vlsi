module hex_driver
	(
		input [3 : 0] digit,
		output reg [7 : 0] encoding
	);
	
	always @(*) begin
		case (digit)
			4'd0: encoding = 8'hC0;
			4'd1: encoding = 8'hF9;
			4'd2: encoding = 8'hA4;
			4'd3: encoding = 8'hB0;
			4'd4: encoding = 8'h99;
			4'd5: encoding = 8'h92;
			4'd6: encoding = 8'h82;
			4'd7: encoding = 8'hF8;
			4'd8: encoding = 8'h80;
			4'd9: encoding = 8'h90;
			default: encoding = 8'hFF;
		endcase
	end

endmodule
