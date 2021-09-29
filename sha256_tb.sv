module sha256_tb();

input logic clk;

input logic [7:0] byte_in;
input logic bytes_done;
input logic byte_valid;
input logic reset;

output logic ready_for_bytes;
output logic done;
output logic [255:0] hash


sha256(.*);

endmodule
