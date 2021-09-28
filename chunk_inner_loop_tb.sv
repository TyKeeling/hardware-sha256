module chunk_inner_loop_tb();

logic [511:0]chunk;
logic [255:0]hash;
logic valid, reset, clk;

logic ready;


initial begin
    clk = 0;
end

always begin
    #5 clk = ~clk;
end

chunk_inner_loop dut(.*);

initial begin
    reset = 1;
    valid = 0;

    // The pre-processed form of "hello world"
    chunk = 'h68656c6c6f20776f726c648000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000058;
    #20;

    reset = 0;
    valid = 1;
    #10;

    valid = 0;
    #200;
end

endmodule
