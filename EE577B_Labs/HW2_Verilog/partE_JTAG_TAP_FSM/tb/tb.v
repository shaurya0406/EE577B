`timescale 1ns/1ns
module tb_tap;
  reg  TCK, TRST, TMS;
  wire [3:0] STATE;

  tap_controller dut(.TCK(TCK), .TRST(TRST), .TMS(TMS), .STATE(STATE));

  // 500 MHz clock: 2 ns period
  initial begin TCK = 1'b0; forever #1 TCK = ~TCK; end

  integer fout;
  initial begin
    fout = $fopen("tap_controller.out","w");
    if (!fout) begin $display("ERROR opening tap_controller.out"); $finish; end
    $dumpfile("tb.vcd");
    $dumpvars(0, tb_tap);
  end

  // -------- State name decoder (Verilog-2001 friendly) --------
  function [127:0] sname;  // returns a packed string
    input [3:0] s;
    begin
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
    end
  endfunction

  // Required log line once per posedge (print code + human-readable name)
  always @(posedge TCK) begin
    #0; // post-NBA so STATE is updated
    $display("At time %0t ns, TMS=%0b, STATE=%04b (%s)", $time, TMS, STATE, sname(STATE));
    $fwrite(fout, "At time %0t ns, TMS=%0b, STATE=%04b\n",
                  $time, TMS, STATE);
  end

  // Drive one TMS bit for one clock
  task drive_tms; input v; begin TMS = v; @(posedge TCK); end endtask

  // A DR path round-trip from RTI
  task seq_dr_cycle;
    begin
      drive_tms(1); // Select-DR-Scan
      drive_tms(0); // Capture-DR
      drive_tms(0); // Shift-DR
      drive_tms(1); // Exit1-DR
      drive_tms(0); // Pause-DR
      drive_tms(1); // Exit2-DR
      drive_tms(1); // Update-DR
      drive_tms(0); // Run-Test/Idle
    end
  endtask

  // An IR path round-trip from RTI
  task seq_ir_cycle;
    begin
      drive_tms(1); // Select-DR-Scan
      drive_tms(1); // Select-IR-Scan
      drive_tms(0); // Capture-IR
      drive_tms(0); // Shift-IR
      drive_tms(1); // Exit1-IR
      drive_tms(0); // Pause-IR
      drive_tms(1); // Exit2-IR
      drive_tms(1); // Update-IR
      drive_tms(0); // Run-Test/Idle
    end
  endtask

  // Five ones on TMS will drive the machine back to Test-Logic-Reset from anywhere
  task tms_reset_5ones; integer k; begin for (k=0;k<5;k=k+1) drive_tms(1'b1); end endtask

  initial begin
    // Synchronous reset asserted for 4 clocks, then deassert
    TRST = 1'b1; TMS = 1'b1; repeat (4) @(posedge TCK);
    TRST = 1'b0;

    // Leave TLR to RTI
    drive_tms(1'b0);

    // Walk DR subgraph once
    seq_dr_cycle();

    // Walk IR subgraph once
    seq_ir_cycle();

    // Return to reset via TMS ones
    tms_reset_5ones();

    // Exercise synchronous TRST again
    TRST = 1'b1; @(posedge TCK); TRST = 1'b0; drive_tms(1'b0); // to RTI

    // Done
    repeat (2) @(posedge TCK);
    $fclose(fout);
    $finish;
  end
endmodule
