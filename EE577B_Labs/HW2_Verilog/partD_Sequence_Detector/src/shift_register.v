`timescale 1ns/1ns
// EE577B HW2 Part D.1 — 8-bit shift register (posedge)
// Priority: rst > load > shift; dir=1 => shift RIGHT (ser_in -> MSB)
// dir=0 => shift LEFT (ser_in -> LSB). Synchronous active-HIGH rst.


module shift_register (
  input        clk,
  input        rst,     // synchronous, active HIGH
  input        shift,   // synchronous, active HIGH
  input        load,    // synchronous, active HIGH
  input        dir,     // 1: shift RIGHT, 0: shift LEFT
  input  [7:0] data,
  input        ser_in,
  output reg [7:0] q
);
  always @(posedge clk) begin
    // Priority: rst > load > shift
    if (rst) begin
      q <= 8'b0;
    end else if (load) begin
      q <= data;
    end else if (shift) begin
      if (dir) begin
        // Shift RIGHT: MSB gets ser_in
        q <= {ser_in, q[7:1]};
      end else begin
        // Shift LEFT: LSB gets ser_in
        q <= {q[6:0], ser_in};
      end
    end
    // else: hold value
  end
endmodule
