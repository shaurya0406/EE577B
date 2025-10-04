`timescale 1ns/1ns
//==============================================================================
// EE577B HW3 — Q2 Structural Multiplier (4×4 two’s-complement)
//------------------------------------------------------------------------------
// * Cells used: ha, fa (exactly as provided; lowercase names & ports)
// * Method:
//   - A_ext  = sign-extend(a) to 8 bits: {a[3],a[3],a[3],a[3], a[3:0]}
//   - Row0..Row2 = (A_ext & {8{b[j]}}) << j           for j=0..2   (positive)
//   - Row3       = ((~A_ext + 1) & {8{b[3]}}) << 3                 (negative)
//   - Sum rows with CSA: (R0,R1,R2) -> (S1,C1), then (S1,C1<<1,R3) -> (S2,C2)
//   - Final CPA: p = S2 + (C2<<1) via ha/fa ripple
//------------------------------------------------------------------------------
// ! Notes
//   - Strictly structural (no '+'), uses only gate-level ha/fa cells.
//   - Two’s-complement wrap at 8 bits is natural.
//==============================================================================

module mult4x4 (
  input  [3:0] a,
  input  [3:0] b,
  output [7:0] p
);

  //--------------------------------------------------------------------------
  // Sign-extend A to 8 bits
  //--------------------------------------------------------------------------
  wire [7:0] A_ext;
  assign A_ext[3:0] = a[3:0];
  assign A_ext[7:4] = {4{a[3]}};

  //--------------------------------------------------------------------------
  // Compute (-A_ext) = ~A_ext + 1 using ha/fa ripple (no behavioral '+')
  //--------------------------------------------------------------------------
  wire [7:0] A_not = ~A_ext;
  wire [7:0] negA8;

  wire c_n0, c_n1, c_n2, c_n3, c_n4, c_n5, c_n6, c_n7;
  // bit 0: A_not[0] + 1
  ha INC0 (.a(A_not[0]), .b(1'b1), .sum(negA8[0]), .cout(c_n0));
  // bits 1..7: add carry only (second operand 0)
  fa INC1 (.a(A_not[1]), .b(1'b0), .cin(c_n0), .sum(negA8[1]), .cout(c_n1));
  fa INC2 (.a(A_not[2]), .b(1'b0), .cin(c_n1), .sum(negA8[2]), .cout(c_n2));
  fa INC3 (.a(A_not[3]), .b(1'b0), .cin(c_n2), .sum(negA8[3]), .cout(c_n3));
  fa INC4 (.a(A_not[4]), .b(1'b0), .cin(c_n3), .sum(negA8[4]), .cout(c_n4));
  fa INC5 (.a(A_not[5]), .b(1'b0), .cin(c_n4), .sum(negA8[5]), .cout(c_n5));
  fa INC6 (.a(A_not[6]), .b(1'b0), .cin(c_n5), .sum(negA8[6]), .cout(c_n6));
  fa INC7 (.a(A_not[7]), .b(1'b0), .cin(c_n6), .sum(negA8[7]), .cout(c_n7)); // c_n7 ignored

  //--------------------------------------------------------------------------
  // Partial rows
  //   Row0..Row2 are (+) A_ext when b[j]=1, shifted by j
  //   Row3 is (−) A_ext when b[3]=1  -> use negA8 and shift by 3
  //--------------------------------------------------------------------------
  wire [7:0] R0, R1, R2, R3_raw, R3;

  // R0 = (A_ext & {8{b0}}) << 0
  and a00 (R0[0], A_ext[0], b[0]);
  and a01 (R0[1], A_ext[1], b[0]);
  and a02 (R0[2], A_ext[2], b[0]);
  and a03 (R0[3], A_ext[3], b[0]);
  and a04 (R0[4], A_ext[4], b[0]);
  and a05 (R0[5], A_ext[5], b[0]);
  and a06 (R0[6], A_ext[6], b[0]);
  and a07 (R0[7], A_ext[7], b[0]);

  // R1 = (A_ext & {8{b1}}) << 1
  wire [7:0] R1_pre;
  and a10 (R1_pre[0], A_ext[0], b[1]);
  and a11 (R1_pre[1], A_ext[1], b[1]);
  and a12 (R1_pre[2], A_ext[2], b[1]);
  and a13 (R1_pre[3], A_ext[3], b[1]);
  and a14 (R1_pre[4], A_ext[4], b[1]);
  and a15 (R1_pre[5], A_ext[5], b[1]);
  and a16 (R1_pre[6], A_ext[6], b[1]);
  and a17 (R1_pre[7], A_ext[7], b[1]);
  assign R1[0]   = 1'b0;
  assign R1[7:1] = R1_pre[6:0];

  // R2 = (A_ext & {8{b2}}) << 2
  wire [7:0] R2_pre;
  and a20 (R2_pre[0], A_ext[0], b[2]);
  and a21 (R2_pre[1], A_ext[1], b[2]);
  and a22 (R2_pre[2], A_ext[2], b[2]);
  and a23 (R2_pre[3], A_ext[3], b[2]);
  and a24 (R2_pre[4], A_ext[4], b[2]);
  and a25 (R2_pre[5], A_ext[5], b[2]);
  and a26 (R2_pre[6], A_ext[6], b[2]);
  and a27 (R2_pre[7], A_ext[7], b[2]);
  assign R2[1:0] = 2'b00;
  assign R2[7:2] = R2_pre[5:0];

  // R3 = ((negA8) & {8{b3}}) << 3   (negative contribution)
  and a30 (R3_raw[0], negA8[0], b[3]);
  and a31 (R3_raw[1], negA8[1], b[3]);
  and a32 (R3_raw[2], negA8[2], b[3]);
  and a33 (R3_raw[3], negA8[3], b[3]);
  and a34 (R3_raw[4], negA8[4], b[3]);
  and a35 (R3_raw[5], negA8[5], b[3]);
  and a36 (R3_raw[6], negA8[6], b[3]);
  and a37 (R3_raw[7], negA8[7], b[3]);
  assign R3[2:0] = 3'b000;
  assign R3[3]   = R3_raw[0];
  assign R3[4]   = R3_raw[1];
  assign R3[5]   = R3_raw[2];
  assign R3[6]   = R3_raw[3];
  assign R3[7]   = R3_raw[4];
  // (R3_raw[5..7]) would go to bits 8..10 and are truncated in 8-bit p

  //--------------------------------------------------------------------------
  // CSA Stage A: (R0,R1,R2) → (S1, C1)
  //--------------------------------------------------------------------------
  wire [7:0] S1;
  wire [8:0] C1; assign C1[0] = 1'b0;

  genvar k;
  generate
    for (k=0; k<8; k=k+1) begin : CSA_A
      fa uA (.a(R0[k]), .b(R1[k]), .cin(R2[k]), .sum(S1[k]), .cout(C1[k+1]));
    end
  endgenerate
  wire [7:0] C1sh = {C1[7:0]};  // left shift by 1

  //--------------------------------------------------------------------------
  // CSA Stage B: (S1, C1<<1, R3) → (S2, C2)
  //--------------------------------------------------------------------------
  wire [7:0] S2;
  wire [8:0] C2; assign C2[0] = 1'b0;

  generate
    for (k=0; k<8; k=k+1) begin : CSA_B
      fa uB (.a(S1[k]), .b(C1sh[k]), .cin(R3[k]), .sum(S2[k]), .cout(C2[k+1]));
    end
  endgenerate
  wire [7:0] C2sh = {C2[7:0]};  // left shift by 1

  //--------------------------------------------------------------------------
  // Final CPA: p = S2 + (C2<<1)  (ripple with ha/fa)
//--------------------------------------------------------------------------
  wire c0, c1b, c2b, c3b, c4b, c5b, c6b;

  // bit 0
  ha CPA0 (.a(S2[0]), .b(C2sh[0]), .sum(p[0]), .cout(c0));
  // bits 1..6
  fa CPA1 (.a(S2[1]), .b(C2sh[1]), .cin(c0),  .sum(p[1]), .cout(c1b));
  fa CPA2 (.a(S2[2]), .b(C2sh[2]), .cin(c1b), .sum(p[2]), .cout(c2b));
  fa CPA3 (.a(S2[3]), .b(C2sh[3]), .cin(c2b), .sum(p[3]), .cout(c3b));
  fa CPA4 (.a(S2[4]), .b(C2sh[4]), .cin(c3b), .sum(p[4]), .cout(c4b));
  fa CPA5 (.a(S2[5]), .b(C2sh[5]), .cin(c4b), .sum(p[5]), .cout(c5b));
  fa CPA6 (.a(S2[6]), .b(C2sh[6]), .cin(c5b), .sum(p[6]), .cout(c6b));
  // bit 7 (cout ignored)
  wire c7_unused;
  fa CPA7 (.a(S2[7]), .b(C2sh[7]), .cin(c6b), .sum(p[7]), .cout(c7_unused));

endmodule
