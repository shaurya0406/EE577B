`timescale 1ns/1ns

// --------  small helper (3->8 one-hot) ----------
module dec3to8(input  [2:0] a, output [7:0] y);
  assign y = 8'b1 << a;
endmodule

module tb_ham_74;

  // clock & reset
  reg clk = 0;
  reg rst_n = 0;
  always #5 clk = ~clk;  // 100 MHz

  // random drivers (new values every cycle)
  reg  [3:0] d_rand;
  reg  [2:0] e0_idx, e1_idx;

  // error masks (one-hot)
  wire [7:0] m0, m1;
  dec3to8 D0 (.a(e0_idx), .y(m0));
  dec3to8 D1 (.a(e1_idx), .y(m1));

  // DUT I/Os
  wire [7:0] c_enc;
  wire [7:0] qc;      // corrected codeword
  wire [3:0] qd;      // corrected data
  wire        x;      // double-error flag (from decoder)

  // pipeline registers (match the 3 latch bars in the figure)
  // Stage-0 (after inputs/encoder)
  reg  [7:0] s0_c;          // encoder output
  reg  [3:0] s0_d;          // original data, pipelined for alignment
  // Stage-1 (after first XOR)
  reg  [7:0] s1_c;
  reg  [3:0] s1_d;
  // Stage-2 (after second XOR, before decoder)
  reg  [7:0] s2_c;
  reg  [3:0] s2_d;

  // 4-bit counter -> MSB selects double-bit error path every 8 cycles
  reg  [3:0] cnt;

  // ---- instantiate encoder/decoder ----
  ham_74_encoder UENC (.d(d_rand), .c(c_enc));
  ham_74_decoder UDEC (.c(s2_c), .qc(qc), .qd(qd), .x(x));

  // ---------- pipeline + randomization ----------
  // synchronous reset for all pipeline regs and counter
  always @(posedge clk) begin
    if (!rst_n) begin
      d_rand <= 4'd0;
      e0_idx <= 3'd0;
      e1_idx <= 3'd0;
      cnt    <= 4'd0;

      s0_c <= 8'd0; s0_d <= 4'd0;
      s1_c <= 8'd0; s1_d <= 4'd0;
      s2_c <= 8'd0; s2_d <= 4'd0;
    end else begin
      // new random stimuli each cycle
      d_rand <= $urandom;
      e0_idx <= $urandom;
      e1_idx <= $urandom;
      cnt    <= cnt + 4'd1;

      // Stage-0 latch (encoder output & align data)
      s0_c <= c_enc;
      s0_d <= d_rand;

      // Stage-1 latch (inject first error using m0)
      s1_c <= s0_c ^ m0;
      s1_d <= s0_d;

      // Stage-2 latch (optionally inject second error every 8 cycles)
      s2_c <= s1_c ^ (cnt[3] ? m1 : 8'd0);
      s2_d <= s1_d;
    end
  end

  // ---------- printing ----------
  integer cycles;
  always @(posedge clk) begin
    if (!rst_n) cycles <= 0;
    else begin
      cycles <= cycles + 1;
      // print after reset each cycle
      $display("[%0t]  d=%b  qc=%b  qd=%b  dbl_flag=%0b  cnt=%0d  sel=%0b",
               $time, s2_d, qc, qd, x, cnt, cnt[3]);
      if (cycles == 30) $finish;  // run >=10 cycles; here we run 30
    end
  end

  // ---------- reset sequence ----------
  initial begin
    // hold reset for a few cycles, then release
    repeat (3) @(posedge clk);
    rst_n = 1'b1;
  end

endmodule
