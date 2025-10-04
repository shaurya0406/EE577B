// `timescale 1ns/1ns
// module tb_ha;
//   reg a,b;
//   wire sum,cout;

//   ha dut(.a(a),.b(b),.sum(sum),.cout(cout));

//   integer f; initial begin
//     $dumpfile("ha.vcd"); $dumpvars(0,tb_ha);
//     f = $fopen("ha.out","w");
//     $fwrite(f,"# a b | sum cout\n");
//     for (integer i=0;i<2;i=i+1)
//       for (integer j=0;j<2;j=j+1) begin
//         a=i; b=j; #1;
//         $fwrite(f,"%0d %0d | %0d   %0d\n", a,b,sum,cout);
//       end
//     $fclose(f);
//     $display("* HA DONE");
//     $finish;
//   end
// endmodule



// `timescale 1ns/1ps
// module tb_fa;
//   reg a,b,cin;
//   wire sum,cout;

//   fa dut(.a(a),.b(b),.cin(cin),.sum(sum),.cout(cout));

//   integer f; initial begin
//     $dumpfile("fa.vcd"); $dumpvars(0,tb_fa);
//     f = $fopen("fa.out","w");
//     $fwrite(f,"# a b cin | sum cout\n");
//     for (integer i=0;i<2;i=i+1)
//       for (integer j=0;j<2;j=j+1)
//         for (integer k=0;k<2;k=k+1) begin
//           a=i; b=j; cin=k; #1;
//           $fwrite(f,"%0d %0d  %0d  |  %0d   %0d\n", a,b,cin,sum,cout);
//         end
//     $fclose(f);
//     $display("* FA DONE");
//     $finish;
//   end
// endmodule



`timescale 1ns/1ns
//==============================================================================
// Self-checking TB for mult4x4 (two's complement, exhaustive 16x16)
// - All textual output goes to mult4x4.out (signed decimal fields)
// - Also emits mult4x4.vcd for GTKWave
//==============================================================================

module tb_mult4x4;
  reg  [3:0] a, b;         // two's complement inputs (-8..+7)
  wire [7:0] p;            // product from DUT (8b two's-comp wrap)
  mult4x4 dut(.a(a), .b(b), .p(p));

  // ---- Declarations (plain Verilog) ----
  integer f, errors, i, j;
  integer ina_dec, inb_dec, prod_dec, exp_dec, exp; // signed decimal temps
  reg [7:0] exp8; // expected wrapped to 8-bit two's-comp

  // helpers
  function integer s4; input [3:0] x; begin
    // two's-complement 4b → signed integer (-8..+7)
    s4 = x[3] ? (x - 16) : x;
  end endfunction

  function [7:0] s8pack; input integer val; integer t; begin
    // pack a signed integer into 8-bit two's-comp space (wrap)
    t = val;
    if (t < 0) s8pack = t + 256; else s8pack = t[7:0];
  end endfunction

  function integer s8; input [7:0] x; begin
    // two's-complement 8b → signed integer (-128..+127)
    s8 = x[7] ? (x - 256) : x;
  end endfunction

  initial begin
    // VCD for waves
    $dumpfile("mult4x4.vcd");
    $dumpvars(0, tb_mult4x4);

    // Open signed-decimal log
    f = $fopen("mult4x4.out","w");
    // Header (comment)
    $fwrite(f, "# InA  InB  |  Product  Expected  (signed decimal)\n");

    errors = 0;

    // Exhaustive sweep
    for (i = 0; i < 16; i = i + 1) begin
      for (j = 0; j < 16; j = j + 1) begin
        a = i[3:0];
        b = j[3:0];
        #1; // allow combinational settle

        // Convert inputs to signed decimals
        ina_dec = s4(a);
        inb_dec = s4(b);

        // DUT product → signed decimal via 8b two's-comp
        prod_dec = s8(p);

        // Golden reference (wrap to 8b, then interpret as signed)
        exp      = s4(a) * s4(b);
        exp8     = s8pack(exp);
        exp_dec  = s8(exp8);

        // Log one line (signed decimal)
        $fwrite(f, "%4d %4d | %8d %9d\n", ina_dec, inb_dec, prod_dec, exp_dec);

        // Track mismatches (quietly)
        if (p !== exp8) errors = errors + 1;
      end
    end

    // Summary (comment)
    if (errors==0) begin
      $fwrite(f, "# PASS: all 256 cases matched\n");
      $display("# PASS: all 256 cases matched\n");
    end
    else begin
      $fwrite(f, "# FAIL: %0d mismatches\n", errors);
      $display("# FAIL: %0d mismatches\n", errors);
    end
    
    $fclose(f);
    $finish;
  end
endmodule

