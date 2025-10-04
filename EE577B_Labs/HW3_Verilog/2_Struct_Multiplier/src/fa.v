`timescale 1ns/1ns
//==============================================================================
// Full Adder (structural, gate-level)
//------------------------------------------------------------------------------
module fa (
  input  a,
  input  b,
  input  cin,
  output sum,
  output cout
);
  wire x1, c1, c2;

  // * XOR chain for sum
  xor u_xor1(x1,  a,   b);
  xor u_xor2(sum, x1,  cin);

  // * Carry = (a&b) | (a&cin) | (b&cin)
  and u_and1(c1, a, b);
  and u_and2(c2, x1, cin); // using (a^b)&cin + (a&b)
  or  u_or (cout, c1, c2);
endmodule
