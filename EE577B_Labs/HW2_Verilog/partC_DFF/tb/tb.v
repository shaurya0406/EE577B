`timescale 1ns/1ps
// EE577B HW2 — Part C Testbench
// - 100 MHz clock
// - Reset asserted for 5 cycles at start for BOTH polarities:
//     0–5 cycles:   rst = 1 (exercises alpha/beta initial reset)
//     5–10 cycles:  rst = 0 (exercises gamma/delta initial reset)
// - Exhaustive (en,d) combinations at negedge
// - Explicit synchronous vs asynchronous resets mid-simulation
// - Data timing before/after negedge
// - Individual .out logs for each DFF

module tb;
  reg clk, rst, en, d;
  wire qa, qb, qg, qd;

  // DUTs
  dff_alpha u_alpha (.clk(clk), .rst(rst), .en(en), .d(d), .q(qa));
  dff_beta  u_beta  (.clk(clk), .rst(rst), .en(en), .d(d), .q(qb));
  dff_gamma u_gamma (.clk(clk), .rst(rst), .en(en), .d(d), .q(qg));
  dff_delta u_delta (.clk(clk), .rst(rst), .en(en), .d(d), .q(qd));

  // 100 MHz clock
  initial begin
    clk = 1'b1;
    forever #5 clk = ~clk;
  end

  // VCD + monitor
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    $display(" time  clk rst en d  |  qa qb qg qd");
    $monitor("%4t   %b   %b  %b %b  |   %b  %b  %b  %b",
             $time, clk, rst, en, d,   qa, qb, qg, qd);
  end

  // Per-DFF logs
  integer f_alpha, f_beta, f_gamma, f_delta;
  initial begin
    f_alpha = $fopen("dff_alpha.out","w");
    f_beta  = $fopen("dff_beta.out" ,"w");
    f_gamma = $fopen("dff_gamma.out","w");
    f_delta = $fopen("dff_delta.out","w");
    if (!f_alpha || !f_beta || !f_gamma || !f_delta) begin
      $display("ERROR opening logs"); $finish;
    end
  end

  task log_all;
    begin
      if (f_alpha) $fwrite(f_alpha,"t=%0t ns : clk=%b rst=%b en=%b d=%b | qa=%b\n",$time,clk,rst,en,d,qa);
      if (f_beta ) $fwrite(f_beta, "t=%0t ns : clk=%b rst=%b en=%b d=%b | qb=%b\n",$time,clk,rst,en,d,qb);
      if (f_gamma) $fwrite(f_gamma,"t=%0t ns : clk=%b rst=%b en=%b d=%b | qg=%b\n",$time,clk,rst,en,d,qg);
      if (f_delta) $fwrite(f_delta,"t=%0t ns : clk=%b rst=%b en=%b d=%b | qd=%b\n",$time,clk,rst,en,d,qd);
    end
  endtask
  always @ (qa or qb or qg or qd or clk or rst or en or d) log_all();

  task wait_negedges; input integer n; integer k;
    begin for (k=0;k<n;k=k+1) @(negedge clk); end
  endtask
  task drive_combo; input en_i, d_i; input integer cycles; integer j;
    begin en=en_i; d=d_i; for (j=0;j<cycles;j=j+1) @(negedge clk); end
  endtask

  integer i;
  initial begin
    // -------- Initial dual-polarity reset requirement (5 cycles each) --------
    en=1'b0; d=1'b0;

    // Active-HIGH reset phase (alpha/beta)
    rst = 1'b1;              // assert high
    wait_negedges(5);

    // Active-LOW reset phase (gamma/delta)
    rst = 1'b0;              // assert low
    wait_negedges(5);

    // -------- Park for alpha normal operation: rst=0 (alpha deasserted) -----
    rst = 1'b0;              // alpha out of reset; gamma is IN reset (by design)
    @(negedge clk);

    // Alpha capture: make qa = 1
    en = 1'b1; d = 1'b1;     // set before negedge
    @(negedge clk);          // alpha captures 1 here → qa should be 1
    // keep a cycle to observe hold
    @(negedge clk);

    // -------- Now deassert for gamma/delta normal operation ------------------
    // Switch to rst=1 so gamma (sync-LOW) and delta (async-LOW) are deasserted
    rst = 1'b1;
    @(negedge clk);

    // Gamma sanity capture: make qg = 1
    en = 1'b1; d = 1'b1;
    @(negedge clk);          // gamma captures 1 here
    @(negedge clk);

    // -------- Exhaustive (en,d) combos under neutral rst for all ------------
    // Keep rst=1 (alpha deasserted, beta deasserted, gamma/delta deasserted)
    for (i=0;i<2;i=i+1) begin
      drive_combo(1'b0,1'b0,2);
      drive_combo(1'b0,1'b1,2);
      drive_combo(1'b1,1'b0,2);
      drive_combo(1'b1,1'b1,2);
    end

    // -------- Data timing checks (before/after negedge) ----------------------
    en = 1'b1; d = 1'b0;
    @(posedge clk); #4 d = 1'b1;  // 1 ns before negedge → captured
    @(negedge clk);
    #1 d = 1'b0;                  // 1 ns after negedge → next capture
    @(negedge clk);

    // -------- Explicit synchronous reset pulses ------------------------------
    // alpha (sync-HIGH): assert across a negedge
    rst = 1'b1; @(negedge clk);   // alpha resets here
    rst = 1'b0; @(negedge clk);   // release for alpha

    // gamma (sync-LOW): assert across a negedge
    rst = 1'b0; @(negedge clk);   // gamma resets here
    rst = 1'b1; @(negedge clk);   // release for gamma

    // -------- Explicit asynchronous reset pulses mid-cycle -------------------
    // beta (async-HIGH): immediate effect
    en = 1'b0; d = 1'b1; rst = 1'b0;
    @(posedge clk); #2 rst = 1'b1; #2 rst = 1'b0; @(negedge clk);

    // delta (async-LOW): immediate effect
    en = 1'b1; d = 1'b1; rst = 1'b1;
    @(posedge clk); #2 rst = 1'b0; #2 rst = 1'b1; @(negedge clk);

    #20;
    f_alpha = 0; f_beta = 0; f_gamma = 0; f_delta = 0;
    $fclose(f_alpha); $fclose(f_beta); $fclose(f_gamma); $fclose(f_delta);
    $finish;
  end
endmodule
