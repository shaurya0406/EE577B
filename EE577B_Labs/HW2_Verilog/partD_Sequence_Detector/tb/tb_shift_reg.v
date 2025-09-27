`timescale 1ns/1ns
module tb_shift_reg;
  reg        clk;
  reg        rst;
  reg        shift;
  reg        load;
  reg        dir;
  reg  [7:0] data;
  reg        ser_in;
  wire [7:0] q;

  shift_register dut (
    .clk(clk), .rst(rst), .shift(shift),
    .load(load), .dir(dir), .data(data),
    .ser_in(ser_in), .q(q)
  );

  initial begin
    clk = 1'b0;
    forever #1 clk = ~clk;   // 500 MHz, T=2 ns
  end

  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb_shift_reg);
    $dumpvars(0, tb_shift_reg.dut.q);
  end

  // ---------------------- Precomputed expected sequence ----------------------
  integer exp_len;
  reg [7:0] exp_q [0:31];
  initial begin
    exp_q[ 0] = 8'hA5;
    exp_q[ 1] = 8'h4B;
    exp_q[ 2] = 8'h97;
    exp_q[ 3] = 8'h97;
    exp_q[ 4] = 8'h97;
    exp_q[ 5] = 8'h4B;
    exp_q[ 6] = 8'h25;
    exp_q[ 7] = 8'h12;
    exp_q[ 8] = 8'h3C;
    exp_q[ 9] = 8'h78;
    exp_q[10] = 8'hF1;
    exp_q[11] = 8'hE3;
    exp_q[12] = 8'hF1;
    exp_q[13] = 8'hE2;
    exp_q[14] = 8'hC4;
    exp_q[15] = 8'h88;
    exp_len   = 16;
  end

  integer idx, errors, cycles, fd;
  reg     checking;          // compare only when 1
  reg [7:0] exp_idx_val;
  reg       match_ok;

  initial begin
    $display(" time  clk rst load shift dir ser  data  |  q_dut  q_exp  result");
    errors = 0; cycles = 0; idx = 0; checking = 0;
    fd = $fopen("tb_shift_reg.out","w");
    if (!fd) begin
      $display("ERROR: could not open tb_shift_reg.out"); $finish;
    end
  end

  // Compare at posedge, AFTER we’ve given the DUT one posedge to update
  always @(posedge clk) begin
    if (checking && idx < exp_len) begin
      cycles      = cycles + 1;
      exp_idx_val = exp_q[idx];
      match_ok    = (q === exp_idx_val);

      $display(" %5t   %b   %b    %b     %b    %b   %b  0x%02h | 0x%02h  0x%02h  %s",
               $time, clk, rst, load, shift, dir, ser_in, data,
               q, exp_idx_val, match_ok ? "OK" : "MISMATCH");

      if (fd) $fwrite(fd,
        "At time %0t ns, CLK=%0b, RST=%0b, LOAD=%0b, SHIFT=%0b, DIR=%0b, SER_IN=%0b, DATA=%02h, Q_DUT=%02h, Q_EXP=%02h, %s\n",
        $time,  clk, rst, load, shift, dir, ser_in, data, q, exp_idx_val,
        match_ok ? "OK" : "MISMATCH");

      if (!match_ok) errors = errors + 1;
      idx = idx + 1;
    end
  end

  task hold_negedges; input integer n; integer k; begin for (k=0;k<n;k=k+1) @(negedge clk); end endtask

  initial begin
    // defaults
    rst=0; load=0; shift=0; dir=0; data=8'h00; ser_in=0;

    // Reset for 4 cycles, then release
    rst=1; hold_negedges(4);
    rst=0; hold_negedges(1);

    // 1) LOAD 0xA5 — arm checking only AFTER the load has been captured
    data=8'hA5; load=1; @(negedge clk); load=0;
    @(posedge clk);            // this posedge updates q to A5
    checking = 1'b1;           // start comparisons from the next line onward

    // 2) LEFT x2 with ser_in=1 -> expect 4B, 97
    dir=1'b0; ser_in=1'b1; shift=1; hold_negedges(2); shift=0;

    // 3) HOLD x2 -> expect 97, 97
    hold_negedges(2);

    // 4) RIGHT x3 with ser_in=0 -> expect 4B, 25, 12
    dir=1'b1; ser_in=1'b0; shift=1; hold_negedges(3); shift=0;

    // 5) LOAD 0x3C -> expect 3C
    data=8'h3C; load=1; @(negedge clk); load=0;

    // 6) LEFT x1 with ser_in=0 -> expect 78
    dir=1'b0; ser_in=1'b0; shift=1; hold_negedges(1); shift=0;

    // 7) LEFT x2 with ser_in=1 -> expect F1, E3
    dir=1'b0; ser_in=1'b1; shift=1; hold_negedges(2); shift=0;

    // 8) RIGHT x1 with ser_in=1 -> expect F1
    dir=1'b1; ser_in=1'b1; shift=1; hold_negedges(1); shift=0;

    // 9) LEFT x3 with ser_in=0 -> expect E2, C4, 88
    dir=1'b0; ser_in=1'b0; shift=1; hold_negedges(3); shift=0;

    // wrap up
    @(negedge clk);
    if (idx != exp_len)
      $display("WARNING: checks performed (%0d) != expected entries (%0d)", idx, exp_len);

    if (errors == 0)
      $display("RESULT: PASS (%0d checks, 0 mismatches)", idx);
    else
      $display("RESULT: FAIL (%0d checks, %0d mismatches)", idx, errors);

    if (fd) begin $fclose(fd); end
    $finish;
  end
endmodule
