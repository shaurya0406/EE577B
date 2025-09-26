`timescale 1ns/1ps
// EE577B HW2 — Part C
// Four negedge-triggered DFFs with identical pinout: (clk, rst, en, d, q)

// alpha : synchronous reset (active HIGH), enable (active HIGH)
module dff_alpha (clk, rst, en, d, q);
  input  clk, rst, en, d;
  output reg q;
  always @(negedge clk) begin
    if (rst)       q <= 1'b0;      // sync, active-HIGH
    else if (en)   q <= d;         // en active-HIGH
  end
endmodule

