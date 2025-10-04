`timescale 1ns/1ns
//==============================================================================
// Half Adder (structural, gate-level)
//------------------------------------------------------------------------------
module ha (
  input  a,
  input  b,
  output sum,
  output cout
);
  // * sum = a ^ b
  xor u_xor(sum, a, b);

  // * carry = a & b
  and u_and(cout, a, b);
endmodule
