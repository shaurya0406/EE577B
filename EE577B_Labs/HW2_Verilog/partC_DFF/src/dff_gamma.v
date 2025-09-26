`timescale 1ns/1ps
// EE577B HW2 — Part C (synthesizable DFFs)

// gamma : synchronous reset (active LOW), enable (active HIGH)
module dff_gamma (clk, rst, en, d, q);
  input  clk, rst, en, d;
  output reg q;
  always @(negedge clk) begin
    if (!rst)      q <= 1'b0;      // sync, active-LOW
    else if (en)   q <= d;         // en active-HIGH
  end
endmodule
