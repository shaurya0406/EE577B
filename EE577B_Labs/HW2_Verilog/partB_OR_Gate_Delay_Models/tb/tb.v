`timescale 1ns/1ps
// EE577B HW2 - Part B Testbench
// Drives all five OR gate models with the same stimulus.
// Outputs to delay.out and tb.vcd.

module tb;
  reg A, B;
  wire OUT1;
  wire OUT2;
  wire OUT3;
  wire OUT4;
  wire OUT5;

  integer fd;

  // DUTs
  or_block_inter  u1 (.A(A), .B(B), .Y(OUT1));
  or_nba_inter    u2 (.A(A), .B(B), .Y(OUT2));
  or_block_intra  u3 (.A(A), .B(B), .Y(OUT3));
  or_nba_intra    u4 (.A(A), .B(B), .Y(OUT4));
  or_continuous   u5 (.A(A), .B(B), .Y(OUT5));

  // Open output file
  initial begin
    fd = $fopen("delay.out", "w");
    if (fd == 0) begin
      $display("ERROR: Could not open delay.out for writing.");
      $finish;
    end
  end

  // Optional waveform dump
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
  end

  // Log to console
  initial begin
    $monitor("At time %0t ps, A=%0b, B=%0b, OUT1=%0b, OUT2=%0b, OUT3=%0b, OUT4=%0b, OUT5=%0b",
              $time, A, B, OUT1, OUT2, OUT3, OUT4, OUT5);
  end

  // Log to file
  always @ (*) begin
    if (fd != 0) begin
      $fwrite(fd, "At time %0t ps, A=%0b, B=%0b, OUT1=%0b, OUT2=%0b, OUT3=%0b, OUT4=%0b, OUT5=%0b\n",
              $time, A, B, OUT1, OUT2, OUT3, OUT4, OUT5);
    end
  end

  // Stimulus as per HW spec:
  // (A,B) = (1,1)@0, (1,0)@4ns, (0,0)@7ns, (0,1)@11ns, (0,0)@14ns; finish @20ns
  initial begin
    A = 1; B = 1;       // @0
    #4  A = 1; B = 0;   // @4000 ps
    #3  A = 0; B = 0;   // @7000 ps
    #4  A = 0; B = 1;   // @11000 ps
    #3  A = 0; B = 0;   // @14000 ps
    #6 ;                // end @20000 ps

    if (fd != 0) $fclose(fd);
    $finish;
  end

endmodule
