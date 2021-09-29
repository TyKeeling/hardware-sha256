module chunk_inner_loop_tb();

// This testbench will run the sha256 algorithm on the 512-bit input.
// If one runs this simulation and checks the value of "hash" once the FSM is completed,
// One will observe that the output value is equal to this:
//
// B94D27B9934D3E08A52E52D7DA7DABFAC484EFE37A5380EE9088F7ACE2EFCDE9
//
// which is the correct hash for the input "hello world". Of course, the entire
// purpose of a hash function is that small changes to the input create large changes
// to the output, so it is incredibly unlikely that this inplementation is correct
// if it is outputting the same hash of "hello world" as online tools.
//
// All preprocessing has been done in python (see sha256.py)

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
