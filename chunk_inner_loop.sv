module chunk_inner_loop(
	input logic chunk[512], output logic hash[256],
	input logic valid, reset, clk,
	output logic ready
);

enum {START, CAPTURE_CHUNK, CALC_WI, CALC_TEMP, SHIFT_VALS, UPDATE_HASH} state;

reg [5:0] i; // counts up to 63

reg [31:0] k [63:0]; // 32-bit values with array depth 64
reg [31:0] w [63:0];
reg [31:0] hv [7:0];

wire [31:0] s0;
wire [31:0] s1;

wire [31:0] temp1;
wire [31:0] temp2;

reg [31:0] a;
reg [31:0] b;
reg [31:0] c;
reg [31:0] d;
reg [31:0] e;
reg [31:0] f;
reg [31:0] g;
reg [31:0] h;

calculate_temp1(
	.e(e),
	.f(f),
	.g(g),
	.h(h),
	.ki(k[i]),
	.wi(w[i]),
	.temp1(temp1)
);

calculate_temp2(
	.a(a),
	.b(b),
	.c(c),
	.temp2(temp2)
);

// For the right rotates
wire [31:0] w_i_minus_15;
wire [31:0] w_i_minus_2;

assign w_i_minus_15 = w[i-15];
assign w_i_minus_2  = w[i- 2];

calculate_s0 d0(
	.w_i_minus_15(w_i_minus_15),
	.s0(s0)
);

calculate_s1 d1(
	.w_i_minus_2(w_i_minus_2),
	.s1(s1)
);

assign ready = (state == START);

// initialize values of k, hv, when reset 
always_ff(posedge clk) begin
	if (reset) begin
		k <= {
			'h428a2f98, 'h71374491, 'hb5c0fbcf, 'he9b5dba5, 'h3956c25b, 'h59f111f1, 'h923f82a4, 0'hab1c5ed5,
			'hd807aa98, 'h12835b01, 'h243185be, 'h550c7dc3, 'h72be5d74, 'h80deb1fe, 'h9bdc06a7, 0'hc19bf174,
			'he49b69c1, 'hefbe4786, 'h0fc19dc6, 'h240ca1cc, 'h2de92c6f, 'h4a7484aa, 'h5cb0a9dc, 0'h76f988da,
			'h983e5152, 'ha831c66d, 'hb00327c8, 'hbf597fc7, 'hc6e00bf3, 'hd5a79147, 'h06ca6351, 0'h14292967,
			'h27b70a85, 'h2e1b2138, 'h4d2c6dfc, 'h53380d13, 'h650a7354, 'h766a0abb, 'h81c2c92e, 0'h92722c85,
			'ha2bfe8a1, 'ha81a664b, 'hc24b8b70, 'hc76c51a3, 'hd192e819, 'hd6990624, 'hf40e3585, 0'h106aa070,
			'h19a4c116, 'h1e376c08, 'h2748774c, 'h34b0bcb5, 'h391c0cb3, 'h4ed8aa4a, 'h5b9cca4f, 0'h682e6ff3,
			'h748f82ee, 'h78a5636f, 'h84c87814, 'h8cc70208, 'h90befffa, 'ha4506ceb, 'hbef9a3f7, 0'hc67178f2
		};

		hv <= {
			'h6a09e667,
			'hbb67ae85,
			'h3c6ef372,
			'ha54ff53a,
			'h510e527f,
			'h9b05688c,
			'h1f83d9ab,
			'h5be0cd19,	
		};
	end
end

// FSM Traversal
always_ff(posedge clk) begin
	if (reset) begin
		state <= START;
		
		genvar j;
		generate
		for (j = 0; j < 64; j++) begin
			w[j] <= 32'b0; // zero all elements of w in 1 clock cycle
		end
		endgenerate

		i <= 16;
	end

	else begin case(state)
		START: if (valid) begin
			state <= CAPTURE_CHUNK;

			// populate the first 16 elements of w in 1 clock cycle
			genvar j;
			generate
			for (j = 0; j < 16; j++) begin
				w[j] <= chunk[j*32+:32] // endian might be wrong, watch out
			end
			endgenerate

		end else begin
			hash <= {
				hv[7],
				hv[6],
				hv[5],
				hv[4],
				hv[3],
				hv[2],
				hv[1],
				hv[0]
			}
		end

		// This can be removed but my state machine needs more states
		CAPTURE_CHUNK: begin
			state <= CALC_WI;
		end

		CALC_WI: begin

			// s0 and s1 are determined combinationally in other module 
			w[i] <= w[i-16] + s0 + w[i-7] + s1
		
			if (i == 8'hFF) begin
				state <= CALC_TEMP;

				// set a to h for calc_temp operations
				a <= hv[0];
				b <= hv[1];
				c <= hv[2];
				d <= hv[3];
				e <= hv[4];
				f <= hv[5];
				g <= hv[6];
				h <= hv[7];
			end else begin
				i <= i + 1'b1;
			end
		end

		// temp1, temp2 are computed combinationally so this is less necessary
		CALC_TEMP: begin
			i <= 0;
			state <= SHIFT_VALS;
		end

		SHIFT_VALS: begin
			h <= g;
			g <= f;
			f <= e;
			e <= d + temp1;
			d <= c;
			c <= b;
			b <= a;
			a <= temp1+temp2;

			if (i == 8'hFF) begin
				state <= UPDATE_HASH;
			end else begin
				i <= i + 1'b1;
				state <= CALC_TEMP;
			end
		end

		UPDATE_HASH: begin
			hv[0] <= hv[0] + a;
			hv[1] <= hv[1] + b;
			hv[2] <= hv[2] + c;
			hv[3] <= hv[3] + d;
			hv[4] <= hv[4] + e;
			hv[5] <= hv[5] + f;
			hv[6] <= hv[6] + g;
			hv[7] <= hv[7] + h;

			state <= start;
		end

	end
end

endmodule
