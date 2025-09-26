`timescale 1ns/1ps
// EE577B HW2 — Part C 

// beta : asynchronous reset (active HIGH), enable (active LOW)
module dff_beta (clk, rst, en, d, q);
  input  clk, rst, en, d;
  output reg q;
  always @(negedge clk or posedge rst) begin
    if (rst)       q <= 1'b0;      // async, active-HIGH
    else if (!en)  q <= d;         // en active-LOW
  end
endmodule

