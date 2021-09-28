module chunk_inner_loop_tb();

logic chunk[512];
logic hash[256];
logic valid, reset, clk;
logic ready;

chunk_inner_loop dut(.*);

endmodule
