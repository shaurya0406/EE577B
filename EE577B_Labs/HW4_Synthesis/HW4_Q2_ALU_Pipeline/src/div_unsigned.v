// Simple combinational unsigned divider
// Works for any bit width (parameterized)
// q = a / b; r = a % b
// If b = 0, q and r are 0.

module div_unsigned #(parameter N = 17, parameter M = 9)(
  input  wire [N-1:0] a,   // dividend (numerator)
  input  wire [M-1:0] b,   // divisor
  output reg  [N-1:0] q,   // quotient
  output reg  [M-1:0] r    // remainder
);
  integer i;
  reg [N+M-1:0] rem;   // temporary remainder (shift register)

  always @(*) begin
    // handle divide-by-zero
    if (b == 0) begin
      q = {N{1'b0}};
      r = {M{1'b0}};
    end
    else begin
      // initialize
      rem = { {(M){1'b0}}, a };
      q   = {N{1'b0}};

      // classic restoring division algorithm
      for (i = N-1; i >= 0; i = i - 1) begin
        rem = { rem[N+M-2:0], 1'b0 };   // left shift remainder
        if (rem[N+M-1:M] >= b) begin
          rem[N+M-1:M] = rem[N+M-1:M] - b;
          q[i] = 1'b1;
        end
      end
      r = rem[M-1:0];
    end
  end
endmodule