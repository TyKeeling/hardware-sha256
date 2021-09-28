module rightrotate
#(
	parameter WIDTH=32,
	parameter BITS=4
)
(
	input logic [WIDTH-1:0] in,
	output [WIDTH-1:0] out
);

assign out = (in >> BITS) | (in << (WIDTH-BITS));

endmodule