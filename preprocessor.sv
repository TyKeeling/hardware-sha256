module preprocessor(
    input logic clk,

    input logic [7:0] byte_in,
    input logic bytes_done,
    input logic byte_valid,
    input logic reset,
    input logic chunk_processor_ready,

    output logic [511:0] chunk,
    output logic chunk_valid,
    output logic ready_for_bytes
);

enum {READY, SEND_CHUNK, SEND_LAST_CHUNK, SEND_OVERFLOW_CHUNK, SEND_PADDING} state;

assign ready_for_bytes = (state == READY);
assign chunk_valid = (state != READY);

logic [63:0] len;

logic [7:0] mod16;

always_comb begin
    mod16 = (len+1) & 8'hF;
end

always_ff @(posedge clk) begin
    if (reset) begin
        len <= 0;
        state <= READY;
        chunk <= 512'b0;
    end

    else case(state)
        READY: begin
            if (byte_valid) begin
                len <= len + 1;

                if (bytes_done) begin
                    if (mod16 == 0 || mod16 == 14 || mod16 == 15) begin
                        // Edge case. Due to the way SHA=256 works, we
                        // will process this 512-bit chunk first and then process
                        // the padding (containing the special 0x80 and length
                        // info) when the chunk processor is ready again.
                        state <= SEND_OVERFLOW_CHUNK;

                        if (mod16 != 0) begin
                            chunk[32*mod16+:8] <= 8'b10000000;
                        end
                    end else begin
                        // The amount of bytes in is complete. We will add the
                        // padding to it (we have space to fit the 96 bits of
                        // padding in this chunk), and then send it to the chunk on
                        // the following clock cycle.
                        state <= SEND_LAST_CHUNK;
                        chunk[32*mod16+:8] <= 8'b10000000;
                        chunk[447+:64] <= len + 1;
                    end
                end else begin
                    if (mod16 == 0) begin
                        // We have been given 16 bytes and there are more to come.
                        // this means that we send the first chunk of data (unmodified),
                        // but there will be more in the future which we will have to pad.
                        // retain the length!
                        state <= SEND_CHUNK;
                    end
                end
            end
        end

        SEND_CHUNK: begin
            if (chunk_processor_ready) begin
                state <= READY;
            end
        end

        SEND_OVERFLOW_CHUNK: begin
            if (chunk_processor_ready) begin
                state <= SEND_PADDING;
            end
        end

        SEND_PADDING: begin
            if (chunk_processor_ready) begin
                state <= READY;
            end
        end

    endcase
end


endmodule