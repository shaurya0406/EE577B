// EE577B HW4 Q2 — Pipelined ALU
// Computes:
//   num  = AvgTxLen * InstExed + CurTxLen
//   den  = InstExed + 1
//   AvgTxLen_new = num / den
//   InstExed_new = den
//
// 8-bit I/O as specified. Unsigned arithmetic. Active-high synchronous reset.
// 4-stage pipeline (stage regs between Inputs | MUL | ADD | DIV | Outputs), one result per cycle once full.


module TM_ALU #(parameter W=8)(
  input  wire        clk, reset,
  input  wire [W-1:0] AvgTxLen, InstExed, CurTxLen,
  output reg  [W-1:0] AvgTxLen_new, InstExed_new
);
  // ---------------- Reg1: input register ----------------
  reg [W-1:0] avg_s1, inst_s1, cur_s1;
  always @(posedge clk) begin
    if (reset) begin avg_s1<=0; inst_s1<=0; cur_s1<=0; end
    else begin        avg_s1<=AvgTxLen; inst_s1<=InstExed; cur_s1<=CurTxLen; end
  end

  // ---------------- Reg2: after MUL --------------------
  reg [2*W-1:0] mul_s2;     // 16 bits for 8x8
  reg [W-1:0]   cur_s2;     // align CurTxLen
  reg [W-1:0]   inst_s2;    // pass InstExed forward (for den in Reg3)
  always @(posedge clk) begin
    if (reset) begin mul_s2<=0; cur_s2<=0; inst_s2<=0; end
    else begin
      mul_s2 <= avg_s1 * inst_s1;
      cur_s2 <= cur_s1;
      inst_s2<= inst_s1;
    end
  end

  // ---------------- Reg3: after ADD (+ compute den) ----
  reg [2*W:0] add_s3;       // 17-bit sum: mul + cur
  reg [W:0]   den_s3;       // 9-bit den = InstExed + 1
  always @(posedge clk) begin
    if (reset) begin add_s3<=0; den_s3<=0; end
    else begin
      add_s3 <= {1'b0, mul_s2} + {{(2*W+1-W){1'b0}}, cur_s2}; // width-align add
      den_s3 <= {1'b0, inst_s2} + 9'd1;                       // compute here
    end
  end

  // ---------------- Reg4: after DIV (final outputs) ----
  wire [W-1:0] q_div = (den_s3 != 0) ? add_s3 / den_s3 : {W{1'b0}}; // unsigned
  // wire [16:0] q_full;
  // wire [8:0]  r_unused;
  // wire [7:0] q_div = q_full[7:0];
  // div_unsigned #(.N(17), .M(9)) u_div (
  //   .a(add_s3),
  //   .b(den_s3),
  //   .q(q_full),
  //   .r(r_unused)
  // );

  always @(posedge clk) begin
    if (reset) begin AvgTxLen_new<=0; InstExed_new<=0; end
    else begin
      AvgTxLen_new <= q_div;
      InstExed_new <= den_s3[W-1:0]; // (= InstExed + 1)
    end
  end
endmodule


