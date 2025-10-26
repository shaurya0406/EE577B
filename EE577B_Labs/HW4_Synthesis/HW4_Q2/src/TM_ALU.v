// EE577B HW4 Q2 — Pipelined ALU
// Computes:
//   num  = AvgTxLen * InstExed + CurTxLen
//   den  = InstExed + 1
//   AvgTxLen_new = num / den
//   InstExed_new = den
//
// 8-bit I/O as specified. Unsigned arithmetic. Active-high synchronous reset.
// 3-stage pipeline (stage regs between MUL, ADD, DIV), one result per cycle once full.

module TM_ALU #
(
  parameter W = 8
)
(
  input  wire              clk,
  input  wire              reset,        // active-high synchronous
  input  wire [W-1:0]      AvgTxLen,     // 8-bit input
  input  wire [W-1:0]      InstExed,     // 8-bit input
  input  wire [W-1:0]      CurTxLen,     // 8-bit input
  output reg  [W-1:0]      AvgTxLen_new, // 8-bit output
  output reg  [W-1:0]      InstExed_new  // 8-bit output  (== InstExed + 1)
);

  // -------------------------
  // Stage 0 → Stage 1 (MUL)
  // -------------------------
  // Multiply can reach 16 bits (8x8).
  reg [2*W-1:0] mul_s1;
  reg [W-1:0]   cur_s1;
  reg [W:0]     den_s1;        // InstExed + 1 fits in 9 bits

  always @(posedge clk) begin
    if (reset) begin
      mul_s1 <= {2*W{1'b0}};
      cur_s1 <= {W{1'b0}};
      den_s1 <= {(W+1){1'b0}};
    end else begin
      mul_s1 <= AvgTxLen * InstExed; // MUL
      cur_s1 <= CurTxLen;            // align CurTxLen to pipeline
      den_s1 <= InstExed + {{W{1'b0}},1'b1}; // InstExed + 1 (zero-extended add)
    end
  end

  // -------------------------
  // Stage 1 → Stage 2 (ADD)
  // -------------------------
  // Add CurTxLen to product. Up to 17 bits.
  reg [2*W:0] add_s2;  // guard bit for sum
  reg [W:0]   den_s2;

  always @(posedge clk) begin
    if (reset) begin
      add_s2 <= {(2*W+1){1'b0}};
      den_s2 <= {(W+1){1'b0}};
    end else begin
      add_s2 <= {1'b0, mul_s1} + {{(2*W+1-W){1'b0}}, cur_s1}; // ADD, width align
      den_s2 <= den_s1;                                       // pass denominator
    end
  end

  // -------------------------
  // Stage 2 → Stage 3 (DIV)
  // -------------------------
  // Combinational divide in stage 3; result registered to outputs.
  // add_s2 fits in 17 bits, den_s2 fits in 9 bits. Quotient fits into 8 bits.
  wire [W-1:0] quotient_s3;
  assign quotient_s3 = (den_s2 != 0) ? add_s2 / den_s2 : {W{1'b0}}; // / is synthesizable

  always @(posedge clk) begin
    if (reset) begin
      AvgTxLen_new <= {W{1'b0}};
      InstExed_new <= {W{1'b0}};
    end else begin
      AvgTxLen_new <= quotient_s3;     // DIV result
      InstExed_new <= den_s2[W-1:0];   // InstExed + 1 (truncate MSB, safe for 8-bit input)
    end
  end

endmodule
