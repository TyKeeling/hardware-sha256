module sha256(
    input logic clk,

    input logic [7:0] byte_in,
    input logic bytes_done,
    input logic byte_valid,
    input logic reset,

    output logic ready_for_bytes,
    output logic done,
    output logic [255:0] hash
);

reg chunk_processor_ready;
reg [511:0] chunk;
reg chunk_valid;

preprocessor pre(.*);

chunk_inner_loop inner(.valid(chunk_valid), .ready(chunk_processor_ready), .*);

endmodule
