`timescale 1ns/1ps
// EE577B HW2 — Part C (synthesizable DFFs)

// delta : asynchronous reset (active LOW), enable (active LOW)
module dff_delta (clk, rst, en, d, q);
  input  clk, rst, en, d;
  output reg q;
  always @(negedge clk or negedge rst) begin
    if (!rst)      q <= 1'b0;      // async, active-LOW
    else if (!en)  q <= d;         // en active-LOW
  end
endmodule
