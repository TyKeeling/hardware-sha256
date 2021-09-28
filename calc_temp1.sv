module calculate_temp1(
	input logic [31:0] e, f, g, h, ki, wi,
	output [31:0] temp1
);

wire [31:0] s1, ch, t1, t2, t3;

rightrotate r0 #(BITS=6) (.in(e), .out(t1));
rightrotate r1 #(BITS=11)(.in(e), .out(t2));
rightrotate r2 #(BITS=25)(.in(e), .out(t3));

always_comb begin
	s1 = t1 ^ t2 ^ t3;
	ch = (e & f) ^ (~e & g);
	temp1 = h + s1 + ch + ki + wi;
end

endmodule
