`timescale 1ns/1ps
//==============================================================================
// EE577B HW3 — Q1 Vending Machine Coin Return
// Self-checking Testbench with watchdog + compact .out + VCD for GTKWave
//==============================================================================

module tb_vm_log_safe;

  //--------------------------------------------------------------------------
  // DUT I/O
  //--------------------------------------------------------------------------
  reg         clk;
  reg         reset;     // sync, active HIGH
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
    .disp_B (disp_B), .disp_Q (disp_Q), .disp_D (disp_D), .disp_N (disp_N), .disp_P (disp_P),
    .done   (done),
    .money  (money),  .price  (price),
    .start  (start),  .clk    (clk),    .reset  (reset),
    .avail_B(avail_B),.avail_Q(avail_Q),.avail_D(avail_D),.avail_N(avail_N),.avail_P(avail_P)
  );

  //--------------------------------------------------------------------------
  // Clock: 10 ns
  //--------------------------------------------------------------------------
  initial clk = 1'b0;
  always  #5 clk = ~clk;

  //--------------------------------------------------------------------------
  // VCD for GTKWave (always on)
  //--------------------------------------------------------------------------
  initial begin
    $dumpfile("vm.vcd");
    $dumpvars(0, tb_vm_log_safe);
    $dumpvars(0, dut);
  end

  //--------------------------------------------------------------------------
  // File I/O (compact log)
  //--------------------------------------------------------------------------
  integer fout;
  initial begin
    fout = $fopen("vm.out","w");
    if (fout == 0) begin
      $display("! ERROR: cannot open vm.out");
      $finish;
    end
    $fwrite(fout, "# EE577B HW3 Q1 — vending machine results\n");
    $fwrite(fout, "# TEST <id> M=<money> P=<price> A=[B Q D N P] CHG=<cents> EXP=[b q d n p] GOT=[b q d n p] REM=<rem> RESULT=<PASS|FAIL|TIMEOUT>\n");
  end

  //--------------------------------------------------------------------------
  // Watchdogs
  //--------------------------------------------------------------------------
  integer MAX_CYCLES_PER_TEST;
  integer MAX_SIM_CYCLES;
  initial begin
    MAX_CYCLES_PER_TEST = 2000;   // ! per-test guard
    MAX_SIM_CYCLES      = 20000;  // ! global guard
  end

  integer global_cycle;
  initial global_cycle = 0;
  always @(posedge clk) global_cycle = global_cycle + 1;
  always @(posedge clk) if (global_cycle > MAX_SIM_CYCLES) begin
    $display("! GLOBAL TIMEOUT: exceeded %0d cycles", MAX_SIM_CYCLES);
    $fclose(fout);
    $finish;
  end

  //--------------------------------------------------------------------------
  // Scoreboard/helpers
  //--------------------------------------------------------------------------
  integer test_id, errors_total, cycle;

  // Coin magnitudes (mirror DUT)
  integer COIN_B, COIN_Q, COIN_D, COIN_N, COIN_P;
  initial begin
    COIN_B = 100; COIN_Q = 25; COIN_D = 10; COIN_N = 5; COIN_P = 1;
  end

  integer expB, expQ, expD, expN, expP;  // expected
  integer gotB, gotQ, gotD, gotN, gotP;  // observed
  integer rem_change;                    // leftover after expected greedy calc
  integer snapB, snapQ, snapD, snapN, snapP;

  task tick; begin @(posedge clk); cycle = cycle + 1; end endtask

  task drive_reset;
    begin
      reset=1'b1; start=1'b0;
      money=0; price=0;
      avail_B=0; avail_Q=0; avail_D=0; avail_N=0; avail_P=0;
      cycle=0;
      tick; reset=1'b0; tick;
    end
  endtask

  // * Greedy expected counts with latched availability
  task compute_expected_counts;
    input  integer change_in;
    input  integer aB,aQ,aD,aN,aP;
    output integer cB,cQ,cD,cN,cP;
  begin
    rem_change = change_in;
    if (aB) begin cB = rem_change/COIN_B; rem_change = rem_change - cB*COIN_B; end else cB=0;
    if (aQ) begin cQ = rem_change/COIN_Q; rem_change = rem_change - cQ*COIN_Q; end else cQ=0;
    if (aD) begin cD = rem_change/COIN_D; rem_change = rem_change - cD*COIN_D; end else cD=0;
    if (aN) begin cN = rem_change/COIN_N; rem_change = rem_change - cN*COIN_N; end else cN=0;
    if (aP) begin cP = rem_change/COIN_P; rem_change = rem_change - cP*COIN_P; end else cP=0;
  end
  endtask

  // * Count pulses until DONE or per-test timeout (fixed: named block for disable)
  task count_pulses_until_done_with_watchdog;
    output integer timed_out;
    integer local_cycles;
    begin
      gotB=0; gotQ=0; gotD=0; gotN=0; gotP=0;
      timed_out = 0;
      local_cycles = 0;

      // First step after start: S_LATCH→S_SELECT (no pulse expected)
      tick; local_cycles = local_cycles + 1;

      // Named block to allow 'disable' in plain Verilog
      begin : COUNT_LOOP
        while (1) begin
          // ? Break if DONE already high
          if (done) disable COUNT_LOOP;

          // Advance one cycle and sample pulses
          tick; local_cycles = local_cycles + 1;

          if (disp_B) gotB = gotB + 1;
          if (disp_Q) gotQ = gotQ + 1;
          if (disp_D) gotD = gotD + 1;
          if (disp_N) gotN = gotN + 1;
          if (disp_P) gotP = gotP + 1;

          // ! Per-test watchdog
          if (local_cycles > MAX_CYCLES_PER_TEST) begin
            timed_out = 1;
            disable COUNT_LOOP;
          end
        end
      end

      // Consume one more tick back to IDLE if not timed out
      if (!timed_out) tick;
    end
  endtask

  // * Run a single test, write compact log row
  task run_test;
    input  [8:0] M_cents;
    input  [8:0] P_cents;
    input        aB,aQ,aD,aN,aP;
    integer change_target;
    integer pass, timed_out;
    integer exp_total, got_total, exp_rem_copy;
  begin
    test_id = test_id + 1;

    // Prepare inputs BEFORE start
    money=M_cents; price=P_cents;
    avail_B=aB; avail_Q=aQ; avail_D=aD; avail_N=aN; avail_P=aP;

    change_target = (M_cents>=P_cents)? (M_cents-P_cents) : 0;

    // Snapshot (what DUT will latch)
    snapB=aB; snapQ=aQ; snapD=aD; snapN=aN; snapP=aP;

    compute_expected_counts(change_target, snapB,snapQ,snapD,snapN,snapP,
                            expB,expQ,expD,expN,expP);
    exp_rem_copy = rem_change;

    // start pulse
    start=1'b1; tick; start=1'b0;

    // count with watchdog
    count_pulses_until_done_with_watchdog(timed_out);

    // compare
    exp_total = expB*COIN_B + expQ*COIN_Q + expD*COIN_D + expN*COIN_N + expP*COIN_P;
    got_total = gotB*COIN_B + gotQ*COIN_Q + gotD*COIN_D + gotN*COIN_N + gotP*COIN_P;

    pass = (!timed_out) &&
           (gotB==expB) && (gotQ==expQ) && (gotD==expD) && (gotN==expN) && (gotP==expP) &&
           (got_total==exp_total);

    if (!pass) errors_total = errors_total + 1;

    // Compact log row
    $fwrite(fout,
      "TEST %0d  M=%0d  P=%0d  A=[%0d %0d %0d %0d %0d]  CHG=%0d  EXP=[%0d %0d %0d %0d %0d]  GOT=[%0d %0d %0d %0d %0d]  REM=%0d  RESULT=%s\n",
      test_id, M_cents, P_cents, aB,aQ,aD,aN,aP, change_target,
      expB,expQ,expD,expN,expP, gotB,gotQ,gotD,gotN,gotP, exp_rem_copy,
      timed_out ? "TIMEOUT" : (pass ? "PASS" : "FAIL")
    );
  end
  endtask

  //--------------------------------------------------------------------------
  // Main
  //--------------------------------------------------------------------------
  initial begin
    errors_total = 0; test_id = 0;
    drive_reset();

    // Tests
    run_test(9'd285, 9'd100, 1,1,1,1,1); // mixed all-available (185c)
    run_test(9'd150, 9'd50,  0,0,0,0,0); // all unavailable
    run_test(9'd235, 9'd100, 1,0,0,1,1); // Q,D disabled → B+N
    run_test(9'd103, 9'd100, 1,1,1,1,0); // impossible (3c, no P)
    run_test(9'd112, 9'd100, 1,1,1,0,0); // 12c, N/P disabled → 1xD then stuck
    run_test(9'd499, 9'd121, 1,1,1,1,1); // larger mixed

    if (errors_total == 0)
      $display("* ALL TESTS PASSED");
    else
      $display("! TESTS FAILED: %0d failing test(s)", errors_total);

    $fclose(fout);
    $finish;
  end

endmodule

