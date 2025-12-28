module montgomery_unit (
    input wire clk,
    input wire [31:0] a_in,
    output wire [31:0] a_out
);
    // Kyber/ML-KEM constants: q = 3329, q' = 3327 (where q' = -q^-1 mod 2^16)
    
    // Step 1: m = a * q' mod 2^16
    wire [31:0] m = (a_in * 32'd3327) & 32'hFFFF;
    
    // Step 2: t = (a + m * q) / 2^16
    wire [31:0] t = (a_in + m * 32'd3329) >> 16;
    
    // Step 3: Conditional reduction (t - q if t >= q)
    assign a_out = (t >= 32'd3329) ? (t - 32'd3329) : t;

endmodule