`timescale 1ns/1ns
// Reads pattern bits from "pattern.in", 500 MHz clock, asserts RST for 4 cycles.
// Writes "seq.out" in the required format.
module tb_seq;
  reg CLK, RST, D_IN;
  wire MATCH;

  seq_detect dut(.D_IN(D_IN), .CLK(CLK), .RST(RST), .MATCH(MATCH));

  integer fin, fout;
  integer c, r;

  // 500 MHz clock (T = 2 ns), posedge-driven per spec
  initial begin CLK = 0; forever #1 CLK = ~CLK; end

  // VCD: dump entire testbench + the internal shift-register state
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb_seq);                 // everything here
    // Inside seq_detect, the shift register instance is dut.u_sr
    $dumpvars(0, tb_seq.dut.u_sr.q);
  end

  initial begin
    fout = $fopen("seq.out","w");
    if (!fout) begin $display("ERROR opening seq.out"); $finish; end
    fin  = $fopen("pattern.in","r");
    if (!fin)  begin $display("ERROR opening pattern.in"); $finish; end

    $display(" time(ns)  CLK RST D_IN MATCH");
    $monitor("%8t   %b   %b   %b    %b", $time, CLK, RST, D_IN, MATCH);
  end

  // Apply reset for 4 cycles at start
  initial begin
    RST = 1'b1; D_IN = 1'b0;
    repeat (4) @(posedge CLK);
    RST = 1'b0;
  end

  // Drive one input bit per clock from pattern.in
  // Accept characters '0' and '1'; ignore whitespace and newlines.
  initial begin
    // Wait until reset deasserted
    @(negedge RST);
    // Consume file until EOF
    while (!$feof(fin)) begin
      c = $fgetc(fin);
      if (c == "0" || c == "1") begin
        @(negedge CLK); 
        D_IN = (c == "1");
        @(posedge CLK);
        // Write required output line each cycle
        // "At time XX ns, CLK=X, RST=X, D_IN=X, MATCH=X"
        $fwrite(fout, "At time %0t ns, CLK=%0b, RST=%0b, D_IN=%0b, MATCH=%0b\n",
                       $time,  CLK,         RST,        D_IN,        MATCH);
      end
    end
    // Drain a few extra clocks to flush final matches
    repeat (4) @(posedge CLK);
    fin  = 0; fout = 0;
    $fclose(fin);  
    $fclose(fout); 
    $finish;
  end
endmodule
