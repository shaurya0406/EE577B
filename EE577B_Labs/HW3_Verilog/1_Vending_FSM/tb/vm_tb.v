`timescale 1ns/1ns
//==============================================================================
// EE577B HW3 — Q1 Vending Machine Coin Return
// Self-checking Testbench with compact .out log + VCD for GTKWave
//------------------------------------------------------------------------------
// * Outputs created by this TB:
//   - vm.out : compact, one-line-per-test summary for submission
//   - tb.vcd : waveform dump for GTKWave
//
// * Compact log row format (space-separated):
//   TEST <id>  M=<money>  P=<price>  A=[B Q D N P]  CHG=<cents>
//   EXP=[b q d n p]  GOT=[b q d n p]  REM=<rem_change>  RESULT=<PASS|FAIL>
//
// ? Units: CENTS (COIN_B=100, COIN_Q=25, COIN_D=10, COIN_N=5, COIN_P=1)
// ! Verilog only; no SystemVerilog constructs.
//==============================================================================

module tb_vm_log;

  //--------------------------------------------------------------------------
  // DUT I/O
  //--------------------------------------------------------------------------
  reg         clk;
  reg         reset;     // synchronous, active HIGH
  reg         start;     // one-cycle pulse
  reg  [8:0]  money;     // cents
  reg  [8:0]  price;     // cents
  reg         avail_B, avail_Q, avail_D, avail_N, avail_P;

  wire        disp_B, disp_Q, disp_D, disp_N, disp_P;
  wire        done;

  //--------------------------------------------------------------------------
  // Instantiate DUT
  //--------------------------------------------------------------------------
  coin_return dut (
    .disp_B (disp_B),
    .disp_Q (disp_Q),
    .disp_D (disp_D),
    .disp_N (disp_N),
    .disp_P (disp_P),
    .done   (done),

    .money  (money),
    .price  (price),
    .start  (start),
    .clk    (clk),
    .reset  (reset),

    .avail_B(avail_B),
    .avail_Q(avail_Q),
    .avail_D(avail_D),
    .avail_N(avail_N),
    .avail_P(avail_P)
  );

  //--------------------------------------------------------------------------
  // Clock: 10 ns period
  //--------------------------------------------------------------------------
  initial clk = 1'b0;
  always #5 clk = ~clk;

  //--------------------------------------------------------------------------
  // VCD for GTKWave
  //--------------------------------------------------------------------------
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb_vm_log);
  end

  //--------------------------------------------------------------------------
  // File I/O
  //--------------------------------------------------------------------------
  integer fout;
  initial begin
    fout = $fopen("vm.out","w");
    if (fout == 0) begin
      $display("! ERROR: cannot open vm.out");
      $finish;
    end
    // Header (comment-style, ignored by graders if they parse lines)
    $fwrite(fout, "# EE577B HW3 Q1 — vending machine results\n");
    $fwrite(fout, "# Format: TEST <id> M=<money> P=<price> A=[B Q D N P] CHG=<cents> ");
    $fwrite(fout, "EXP=[b q d n p] GOT=[b q d n p] REM=<rem> RESULT=<PASS|FAIL>\n");
  end

  //--------------------------------------------------------------------------
  // Scoreboard / helpers
  //--------------------------------------------------------------------------
  integer test_id, errors_total;
  integer cycle;

  // mirror DUT coin magnitudes (cents)
  integer COIN_B, COIN_Q, COIN_D, COIN_N, COIN_P;
  initial begin
    COIN_B = 100; COIN_Q = 25; COIN_D = 10; COIN_N = 5; COIN_P = 1;
  end

  // expected counts
  integer expB, expQ, expD, expN, expP;
  // got counts
  integer gotB, gotQ, gotD, gotN, gotP;

  // remaining change during expected calc
  integer rem_change;

  // latched availability snapshot for expectation
  integer snapB, snapQ, snapD, snapN, snapP;

  //--------------------------------------------------------------------------
  // Small utilities
  //--------------------------------------------------------------------------
  task tick; begin @(posedge clk); cycle = cycle + 1; end endtask

  task drive_reset;
    begin
      reset = 1'b1; start = 1'b0;
      money = 0; price = 0;
      avail_B = 0; avail_Q = 0; avail_D = 0; avail_N = 0; avail_P = 0;
      cycle = 0;
      tick; // sync reset edge
      reset = 1'b0;
      tick; // settle to IDLE
    end
  endtask

  // Compute greedy expected counts from (change, latched availability)
  task compute_expected_counts;
    input  integer change_in;
    input  integer aB, aQ, aD, aN, aP;
    output integer cB, cQ, cD, cN, cP;
  begin
    rem_change = change_in;

    if (aB) begin cB = rem_change / COIN_B; rem_change = rem_change - cB*COIN_B; end
    else cB = 0;

    if (aQ) begin cQ = rem_change / COIN_Q; rem_change = rem_change - cQ*COIN_Q; end
    else cQ = 0;

    if (aD) begin cD = rem_change / COIN_D; rem_change = rem_change - cD*COIN_D; end
    else cD = 0;

    if (aN) begin cN = rem_change / COIN_N; rem_change = rem_change - cN*COIN_N; end
    else cN = 0;

    if (aP) begin cP = rem_change / COIN_P; rem_change = rem_change - cP*COIN_P; end
    else cP = 0;
  end
  endtask

  // Count pulses until DONE; assumes DUT emits exactly one pulse per coin
  task count_pulses_until_done;
    begin
      gotB = 0; gotQ = 0; gotD = 0; gotN = 0; gotP = 0;

      // First step after start: S_LATCH→S_SELECT (no pulse expected)
      tick;

      // Then loop consuming pulses until DONE observed
      while (!done) begin
        tick; // observe pulse cycle or non-pulse
        if (disp_B) gotB = gotB + 1;
        if (disp_Q) gotQ = gotQ + 1;
        if (disp_D) gotD = gotD + 1;
        if (disp_N) gotN = gotN + 1;
        if (disp_P) gotP = gotP + 1;
      end
      // At this point, DONE is high; next tick returns to IDLE
      tick;
    end
  endtask

  // Run a single test, log compact line, accumulate errors
  task run_test;
    input  [8:0] M_cents;
    input  [8:0] P_cents;
    input        aB, aQ, aD, aN, aP;
    reg   [8*64-1:0] result_str;
    integer change_target;
    integer pass;
    integer all_unavail;
    integer exp_total, got_total, exp_rem_copy;
  begin
    test_id = test_id + 1;

    // Prepare inputs BEFORE start; availability is latched in S_LATCH
    money   = M_cents;
    price   = P_cents;
    avail_B = aB; avail_Q = aQ; avail_D = aD; avail_N = aN; avail_P = aP;

    change_target = (M_cents >= P_cents) ? (M_cents - P_cents) : 0;

    // Snapshot (what DUT will latch)
    snapB = aB; snapQ = aQ; snapD = aD; snapN = aN; snapP = aP;

    // Compute expected greedy counts + remainder
    compute_expected_counts(change_target, snapB,snapQ,snapD,snapN,snapP,
                            expB,expQ,expD,expN,expP);
    exp_rem_copy = rem_change; // keep a copy for logging

    // Start pulse (1 cycle)
    start = 1'b1; tick; start = 1'b0;

    // Count pulses until DONE (includes UPDATE steps internally)
    count_pulses_until_done();

    // Compare totals
    exp_total = expB*COIN_B + expQ*COIN_Q + expD*COIN_D + expN*COIN_N + expP*COIN_P;
    got_total = gotB*COIN_B + gotQ*COIN_Q + gotD*COIN_D + gotN*COIN_N + gotP*COIN_P;

    pass = 1;
    if (gotB!=expB || gotQ!=expQ || gotD!=expD || gotN!=expN || gotP!=expP) pass = 0;
    if (got_total != exp_total) pass = 0;

    if (!pass) errors_total = errors_total + 1;

    // Write compact line
    $fwrite(fout,
      "TEST %0d  M=%0d  P=%0d  A=[%0d %0d %0d %0d %0d]  CHG=%0d  EXP=[%0d %0d %0d %0d %0d]  GOT=[%0d %0d %0d %0d %0d]  REM=%0d  RESULT=%s\n",
      test_id, M_cents, P_cents, aB,aQ,aD,aN,aP, change_target,
      expB,expQ,expD,expN,expP, gotB,gotQ,gotD,gotN,gotP, exp_rem_copy,
      pass ? "PASS" : "FAIL"
    );
  end
  endtask

  //--------------------------------------------------------------------------
  // Main stimulus
  //--------------------------------------------------------------------------
  initial begin
    errors_total = 0;
    test_id      = 0;

    drive_reset();

    //============================================================
    // Tests (concise; feel free to add more)
    //============================================================

    // * Mixed all-available (change=185 → 1xB, 3xQ, 1xD)
    run_test(9'd285, 9'd100, 1,1,1,1,1);

    // * All unavailable → immediate done
    run_test(9'd150, 9'd50,  0,0,0,0,0);

    // // * Skip unavailable (Q & D disabled) change=135 → 1xB + 7xN
    // run_test(9'd235, 9'd100, 1,0,0,1,1);

    // // * Impossible exact change (P disabled) change=3 → 0 coins
    // run_test(9'd103, 9'd100, 1,1,1,1,0);

    // // * Partial then impossible: (P,N disabled) change=12 → 1xD then stuck
    // run_test(9'd112, 9'd100, 1,1,1,0,0);

    // // * Larger mixed case
    // run_test(9'd499, 9'd121, 1,1,1,1,1);

    //============================================================
    // Wrap up
    //============================================================
    if (errors_total == 0) begin
      $display("* ALL TESTS PASSED");
    end else begin
      $display("! TESTS FAILED: %0d failing test(s)", errors_total);
    end

    $fclose(fout);
    $finish;
  end

endmodule
