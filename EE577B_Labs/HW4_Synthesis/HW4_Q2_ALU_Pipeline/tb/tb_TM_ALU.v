`timescale 1ns/1ps

module tb_TM_ALU;

  parameter W = 8;

  reg               clk, reset;
  reg  [W-1:0]      AvgTxLen, InstExed, CurTxLen;
  wire [W-1:0]      AvgTxLen_new, InstExed_new;

  // Instantiate DUT (no parameters for synthesized netlist)
  TM_ALU dut (
    .clk(clk),
    .reset(reset),
    .AvgTxLen(AvgTxLen),
    .InstExed(InstExed),
    .CurTxLen(CurTxLen),
    .AvgTxLen_new(AvgTxLen_new),
    .InstExed_new(InstExed_new)
  );

  // ------------------- Clock Generation -------------------
  initial clk = 1'b0;
  always #5 clk = ~clk;   // 100 MHz (10 ns period)

  // ------------------- Variables --------------------------
  integer errors, cycles, i;

  // Expected pipeline (4-cycle latency)
  reg [W-1:0] exp_avg_s1, exp_avg_s2, exp_avg_s3, exp_avg_s4;
  reg [W-1:0] exp_inst_s1, exp_inst_s2, exp_inst_s3, exp_inst_s4;

  reg [W-1:0] nxt_Avg, nxt_Inst, nxt_Cur;
  reg [W-1:0] nxt_exp_avg, nxt_exp_inst;

  // ------------------- Golden Model -----------------------
  function [W-1:0] golden_avg;
    input [W-1:0] a, inst, cur;
    integer num, den, q;
    begin
      num = a * inst + cur;   // numerator
      den = inst + 1;         // denominator
      q = (den != 0) ? (num / den) : 0;
      if (q > 255) q = 255;
      golden_avg = q[7:0];
    end
  endfunction

  function [W-1:0] golden_inst;
    input [W-1:0] inst;
    integer den;
    begin
      den = inst + 1;
      golden_inst = den[7:0]; // truncates 256→0
    end
  endfunction

  // ------------------- Stimulus Preparation ----------------
  always @(negedge clk) begin
    if (!reset) begin
      nxt_Avg  = $random & 8'hFF;
      nxt_Inst = $random & 8'hFF;
      nxt_Cur  = $random & 8'hFF;

      nxt_exp_avg  = golden_avg(nxt_Avg, nxt_Inst, nxt_Cur);
      nxt_exp_inst = golden_inst(nxt_Inst);
    end
  end

  // ------------------- Drive & Pipeline Shift ----------------
  always @(posedge clk) begin
    if (reset) begin
      AvgTxLen <= 0; InstExed <= 0; CurTxLen <= 0;
      exp_avg_s1 <= 0; exp_avg_s2 <= 0; exp_avg_s3 <= 0; exp_avg_s4 <= 0;
      exp_inst_s1<= 0; exp_inst_s2<= 0; exp_inst_s3<= 0; exp_inst_s4<= 0;
      cycles <= 0; errors <= 0;
    end else begin
      // Drive DUT inputs
      AvgTxLen <= nxt_Avg;
      InstExed <= nxt_Inst;
      CurTxLen <= nxt_Cur;

      // Shift expected results through 4-stage pipeline
      exp_avg_s4  <= exp_avg_s3;  exp_avg_s3  <= exp_avg_s2;
      exp_avg_s2  <= exp_avg_s1;  exp_avg_s1  <= nxt_exp_avg;

      exp_inst_s4 <= exp_inst_s3; exp_inst_s3 <= exp_inst_s2;
      exp_inst_s2 <= exp_inst_s1; exp_inst_s1 <= nxt_exp_inst;

      cycles <= cycles + 1;
    end
  end

  // ------------------- Comparison (after 4 cycles) ----------------
  always @(posedge clk) begin
    if (!reset && cycles >= 4) begin
      if (AvgTxLen_new !== exp_avg_s4 || InstExed_new !== exp_inst_s4) begin
        $display("MISMATCH @%0t ns: got avg=%0d inst=%0d  exp avg=%0d inst=%0d",
                 $time, AvgTxLen_new, InstExed_new, exp_avg_s4, exp_inst_s4);
        errors = errors + 1;
      end
    end
  end

  // ------------------- Test Sequence ----------------
  initial begin
    reset = 1'b1;
    repeat (4) @(posedge clk);
    reset = 1'b0;

    // apply 1000 random transactions
    for (i = 0; i < 1000; i = i + 1) @(posedge clk);

    // drain remaining pipeline
    repeat (6) @(posedge clk);

    $display("TB completed: %0d mismatches.", errors);
    if (errors == 0) $display("✅ PASS");
    else             $display("❌ FAIL");
    $finish;
  end

endmodule
