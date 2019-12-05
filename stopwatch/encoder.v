module encoder
	(
		input [3 : 0] digit,
		output reg [6 : 0] encoding
	);
	
	always @(*) begin
		case (digit)
			4'd0: encoding = 7'h40;
			4'd1: encoding = 7'h79;
			4'd2: encoding = 7'h24;
			4'd3: encoding = 7'h30;
			4'd4: encoding = 7'h19;
			4'd5: encoding = 7'h12;
			4'd6: encoding = 7'h02;
			4'd7: encoding = 7'h78;
			4'd8: encoding = 7'h00;
			4'd9: encoding = 7'h10;
			default: encoding = 7'h7F;
		endcase
	end
	
endmodule
