module calculate_s0(
	input [31:0] w_i_minus_15,
	output [31:0] s0
);

wire [31:0] t1;
wire [31:0] t2;

rightrotate r0 #(BITS=7)(.in(w_i_minus_15), .out(t1));
rightrotate r1 #(BITS=18)(.in(w_i_minus_15), .out(t2));

assign s0 = t1 ^ t2 ^ (w_i_minus_15 >> 3);

endmodule
