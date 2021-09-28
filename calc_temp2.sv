module calculate_temp2(
	input logic [31:0] a, b, c,
	output logic [31:0] temp2
);

logic [31:0] s0, maj, t1, t2, t3;

rightrotate #(.BITS(2))  r0 (.in(a), .out(t1));
rightrotate #(.BITS(13)) r1 (.in(a), .out(t2));
rightrotate #(.BITS(22)) r2 (.in(a), .out(t3));

always_comb begin
	s0 = t1 ^ t2 ^ t3;
	maj = (a & b) ^ (a & c) ^ (b & c);
	temp2 = s0 + maj;
end

endmodule
