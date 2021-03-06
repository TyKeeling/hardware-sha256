module calculate_s1(
	input [31:0] w_i_minus_2,
	output [31:0] s1
);

wire [31:0] t1;
wire [31:0] t2;

rightrotate #(.BITS(17)) r0 (.in(w_i_minus_2), .out(t1));
rightrotate #(.BITS(19)) r1 (.in(w_i_minus_2), .out(t2));

assign s1 = t1 ^ t2 ^ (w_i_minus_2 >> 10);

endmodule
