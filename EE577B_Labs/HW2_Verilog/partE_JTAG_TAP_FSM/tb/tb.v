`timescale 1ns/1ns
// EE577B HW2 — Part E TAP controller testbench (sampled-TMS logging)
module tb_tap;
  reg  TCK, TRST, TMS;
  wire [3:0] STATE;

  tap_controller dut(.TCK(TCK), .TRST(TRST), .TMS(TMS), .STATE(STATE));

  // 500 MHz clock
  initial begin
    TCK = 1'b0;
    forever #1 TCK = ~TCK;
  end

  // Table 2 encodings
  parameter TEST_LOGIC_RESET = 4'b0000;
  parameter RUN_TEST_IDLE    = 4'b0001;
  parameter SELECT_DR_SCAN   = 4'b0010;
  parameter CAPTURE_DR       = 4'b0011;
  parameter SHIFT_DR         = 4'b0100;
  parameter EXIT1_DR         = 4'b0101;
  parameter PAUSE_DR         = 4'b0110;
  parameter EXIT2_DR         = 4'b0111;
  parameter UPDATE_DR        = 4'b1000;
  parameter SELECT_IR_SCAN   = 4'b1001;
  parameter CAPTURE_IR       = 4'b1010;
  parameter SHIFT_IR         = 4'b1011;
  parameter EXIT1_IR         = 4'b1100;
  parameter PAUSE_IR         = 4'b1101;
  parameter EXIT2_IR         = 4'b1110;
  parameter UPDATE_IR        = 4'b1111;

  // Pretty state name for logs
  function [95:0] sname; input [3:0] s;
    case (s)
      4'b0000: sname = "TEST_LOGIC_RESET";
      4'b0001: sname = "RUN_TEST_IDLE";
      4'b0010: sname = "SELECT_DR_SCAN";
      4'b0011: sname = "CAPTURE_DR";
      4'b0100: sname = "SHIFT_DR";
      4'b0101: sname = "EXIT1_DR";
      4'b0110: sname = "PAUSE_DR";
      4'b0111: sname = "EXIT2_DR";
      4'b1000: sname = "UPDATE_DR";
      4'b1001: sname = "SELECT_IR_SCAN";
      4'b1010: sname = "CAPTURE_IR";
      4'b1011: sname = "SHIFT_IR";
      4'b1100: sname = "EXIT1_IR";
      4'b1101: sname = "PAUSE_IR";
      4'b1110: sname = "EXIT2_IR";
      4'b1111: sname = "UPDATE_IR";
      default: sname = "UNKNOWN";
    endcase
  endfunction

  integer fout, checks, fails;
  reg tms_sampled;  // bit actually sampled on posedge

  // VCD + output file
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb_tap);
    fout = $fopen("tap_controller.out","w");
    if (!fout) begin $display("ERROR opening tap_controller.out"); $finish; end
  end

  // Log once per posedge, AFTER NBA updates, using the sampled TMS
  always @(posedge TCK) begin
    #0;
    tms_sampled <= TMS; // captured at this posedge
    $display("At time %0t ns, TMS(sampled)=%0b, STATE=%04b (%s)",
             $time, TMS, STATE, sname(STATE));
    $fwrite(fout, "At time %0t ns, TMS=%0b, STATE=%04b\n", $time, TMS, STATE);
  end

  // Drive TMS on negedge; check expected STATE at the next posedge
  task drive_and_check;
    input tms_bit;
    input [3:0] expected_state;
    begin
      @(negedge TCK); TMS = tms_bit;     // set up before sampling edge
      @(posedge TCK); #0;                // sample+update here
      checks = checks + 1;
      if (STATE !== expected_state) begin
        fails = fails + 1;
        $display("  CHECK FAIL @ %0t ns: expected %04b (%s), got %04b (%s)",
                 $time, expected_state, sname(expected_state), STATE, sname(STATE));
      end else begin
        $display("  CHECK PASS @ %0t ns: STATE=%04b (%s)",
                 $time, STATE, sname(STATE));
      end
    end
  endtask

  // DR and IR round trips (from RTI)
  task seq_dr_cycle_checked;
    begin
      drive_and_check(1'b1, SELECT_DR_SCAN);
      drive_and_check(1'b0, CAPTURE_DR);
      drive_and_check(1'b0, SHIFT_DR);
      drive_and_check(1'b1, EXIT1_DR);
      drive_and_check(1'b0, PAUSE_DR);
      drive_and_check(1'b1, EXIT2_DR);
      drive_and_check(1'b1, UPDATE_DR);
      drive_and_check(1'b0, RUN_TEST_IDLE);
    end
  endtask

  task seq_ir_cycle_checked;
    begin
      drive_and_check(1'b1, SELECT_DR_SCAN);
      drive_and_check(1'b1, SELECT_IR_SCAN);
      drive_and_check(1'b0, CAPTURE_IR);
      drive_and_check(1'b0, SHIFT_IR);
      drive_and_check(1'b1, EXIT1_IR);
      drive_and_check(1'b0, PAUSE_IR);
      drive_and_check(1'b1, EXIT2_IR);
      drive_and_check(1'b1, UPDATE_IR);
      drive_and_check(1'b0, RUN_TEST_IDLE);
    end
  endtask

  // Five ones path back to TLR
  task tms_to_reset_5ones_checked;
    begin
      drive_and_check(1'b1, SELECT_DR_SCAN);
      drive_and_check(1'b1, SELECT_IR_SCAN);
      drive_and_check(1'b1, TEST_LOGIC_RESET);
      drive_and_check(1'b1, TEST_LOGIC_RESET);
      drive_and_check(1'b1, TEST_LOGIC_RESET);
    end
  endtask

  initial begin
    checks = 0; fails = 0;

    // Hold synchronous reset for 4 posedges, then deassert on a negedge
    TRST = 1'b1; TMS = 1'b1; repeat (4) @(posedge TCK);
    @(negedge TCK); TRST = 1'b0;

    // Leave TLR to RTI
    drive_and_check(1'b0, RUN_TEST_IDLE);

    // DR then IR cycles
    seq_dr_cycle_checked();
    seq_ir_cycle_checked();

    // Back to reset via five ones on TMS
    tms_to_reset_5ones_checked();

    // Assert TRST again (sync), check TLR, then deassert on negedge
    @(negedge TCK); TRST = 1'b1;
    @(posedge TCK); #0;
    checks = checks + 1;
    if (STATE !== TEST_LOGIC_RESET) begin
      fails = fails + 1;
      $display("  CHECK FAIL @ %0t ns: TRST=1 expected TLR, got %04b (%s)",
               $time, STATE, sname(STATE));
    end else begin
      $display("  CHECK PASS @ %0t ns: TRST=1 -> TLR", $time);
    end
    @(negedge TCK); TRST = 1'b0;

    // One more step to RTI
    drive_and_check(1'b0, RUN_TEST_IDLE);

    // Summary
    $display("SUMMARY: %0d checks, %0d fails", checks, fails);
    if (fails == 0) $display("RESULT: PASS");
    else            $display("RESULT: FAIL");

    $fclose(fout);
    $finish;
  end
endmodule
