`timescale 1ns/1ns

module tb_TM_ALU;

  parameter W = 8;

  reg               clk, reset;
  reg  [W-1:0]      AvgTxLen, InstExed, CurTxLen;
  wire [W-1:0]      AvgTxLen_new, InstExed_new;

  // DUT
  TM_ALU #(W) dut (
    .clk(clk),
    .reset(reset),
    .AvgTxLen(AvgTxLen),
    .InstExed(InstExed),
    .CurTxLen(CurTxLen),
    .AvgTxLen_new(AvgTxLen_new),
    .InstExed_new(InstExed_new)
  );

  // clock
  initial clk = 1'b0;
  always #5 clk = ~clk;   // 100 MHz in sim

  integer errors, i;
  integer cycles;

  // expected result pipeline (3-cycle latency)
  reg [W-1:0] exp_avg_s1,  exp_avg_s2,  exp_avg_s3;
  reg [W-1:0] exp_inst_s1, exp_inst_s2, exp_inst_s3;

  // “next” stimulus prepared on negedge to avoid NBA races
  reg [W-1:0] nxt_Avg, nxt_Inst, nxt_Cur;
  reg [W-1:0] nxt_exp_avg, nxt_exp_inst;

  // golden models (integer math, truncating divide)
  function [W-1:0] golden_avg;
    input [W-1:0] a, inst, cur;
    integer num, den, q;
    begin
      num = a * inst + cur;      // up to ~65790
      den = inst + 1;            // 1..256
      if (den == 0) q = 0; else q = num / den;
      if (q < 0)    q = 0;
      if (q > 255)  q = 255;
      golden_avg = q[7:0];
    end
  endfunction

  function [W-1:0] golden_inst;
    input [W-1:0] inst;
    integer den;
    begin
      den = inst + 1;            // 1..256
      golden_inst = den[7:0];    // truncates 256->0, matches RTL
    end
  endfunction

  // prepare next stimulus and its golden result on NEGEDGE
  always @(negedge clk) begin
    if (!reset) begin
      nxt_Avg  = $random & 8'hFF;
      nxt_Inst = $random & 8'hFF;
      nxt_Cur  = $random & 8'hFF;

      nxt_exp_avg  = golden_avg(nxt_Avg, nxt_Inst, nxt_Cur);
      nxt_exp_inst = golden_inst(nxt_Inst);
    end
  end

  // drive DUT and maintain expected-value pipeline on POSEDGE
  always @(posedge clk) begin
    if (reset) begin
      AvgTxLen   <= {W{1'b0}};
      InstExed   <= {W{1'b0}};
      CurTxLen   <= {W{1'b0}};
      exp_avg_s1  <= {W{1'b0}}; exp_avg_s2  <= {W{1'b0}}; exp_avg_s3  <= {W{1'b0}};
      exp_inst_s1 <= {W{1'b0}}; exp_inst_s2 <= {W{1'b0}}; exp_inst_s3 <= {W{1'b0}};
      cycles <= 0;
    end else begin
      // drive inputs
    //   AvgTxLen <= nxt_Avg;
    //   InstExed <= nxt_Inst;
    //   CurTxLen <= nxt_Cur;

      // shift expected results (3-cycle latency)
      exp_avg_s3  <= exp_avg_s2;   exp_avg_s2  <= exp_avg_s1;   exp_avg_s1  <= nxt_exp_avg;
      exp_inst_s3 <= exp_inst_s2;  exp_inst_s2 <= exp_inst_s1;  exp_inst_s1 <= nxt_exp_inst;

      cycles <= cycles + 1;
    end
  end

  always @(negedge clk) begin
    if (reset) begin
        AvgTxLen   <= {W{1'b0}};
        InstExed   <= {W{1'b0}};
        CurTxLen   <= {W{1'b0}};
    end else begin
        AvgTxLen <= nxt_Avg;
        InstExed <= nxt_Inst;
        CurTxLen <= nxt_Cur;
    end
  end

  // compare outputs after pipeline fills
  always @(posedge clk) begin
    if (!reset && cycles >= 3) begin
      if (AvgTxLen_new !== exp_avg_s3 || InstExed_new !== exp_inst_s3) begin
        $display("MISMATCH @%0t: got avg=%0d inst=%0d  exp avg=%0d inst=%0d",
                 $time, AvgTxLen_new, InstExed_new, exp_avg_s3, exp_inst_s3);
        errors = errors + 1;
      end
    end
  end

  // test sequence
  initial begin
    errors = 0;
    reset  = 1'b1;
    repeat (4) @(posedge clk);
    reset  = 1'b0;

    // run N random vectors
    for (i = 0; i < 1000; i = i + 1) begin
      @(posedge clk);
    end

    // drain a few extra cycles
    repeat (6) @(posedge clk);

    $display("TB DONE. Errors = %0d", errors);
    if (errors == 0) $display("PASS");
    else             $display("FAIL");
    $finish;
  end

endmodule
