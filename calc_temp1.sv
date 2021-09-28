module calculate_temp1(
	input logic [31:0] e, f, g, h, ki, wi,
	output logic [31:0] temp1
);

reg [31:0] s1, ch, t1, t2, t3;

rightrotate #(.BITS(6))  r0 (.in(e), .out(t1));
rightrotate #(.BITS(11)) r1 (.in(e), .out(t2));
rightrotate #(.BITS(25)) r2 (.in(e), .out(t3));

always_comb begin
	s1 = t1 ^ t2 ^ t3;
	ch = (e & f) ^ (~e & g);
	temp1 = h + s1 + ch + ki + wi;
end

endmodule
