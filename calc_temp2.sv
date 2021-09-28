module calculate_temp2(
	input logic [31:0] a, b, c
	output [31:0] temp2
);

wire [31:0] s0, maj, t1, t2, t3;

rightrotate r0 #(BITS=2) (.in(a), .out(t1));
rightrotate r1 #(BITS=13)(.in(a), .out(t2));
rightrotate r2 #(BITS=22)(.in(a), .out(t3));

always_comb begin
	s0 = t1 ^ t2 ^ t3;
	maj = (a & b) ^ (a & c) ^ (b & c);
	temp2 = s0 + maj;
end

endmodule
