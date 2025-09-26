`timescale 1ns/1ns
// EE577B HW2 Part D.2 — Sequence detector for 11010101
// Uses shift_register as an 8-bit sliding window at posedge.
// We shift LEFT every cycle so the LSB holds the most recent bit.
// Then compare the entire register to 8'b11010101.
module seq_detect (D_IN, CLK, RST, MATCH);
  input  CLK, RST, D_IN;           // RST: sync active-HIGH
  output MATCH;

  wire [7:0] q;

  // Instantiate the shift register
  // RST connects to rst, SHIFT=1 each cycle, LOAD=0 always, DIR=0 (LEFT)
  // ser_in gets the incoming serial bit D_IN
  shift_register u_sr (
    .clk   (CLK),
    .rst   (RST),
    .shift (1'b1),
    .load  (1'b0),
    .dir   (1'b0),       // 0 => left shift, LSB gets ser_in (most recent)
    .data  (8'b0),
    .ser_in(D_IN),
    .q     (q)
  );

  // Pattern comparison
  wire [7:0] window = {q[6:0], D_IN};   // left shift, newest bit in LSB
  assign MATCH = (window == 8'b11010101);

endmodule
