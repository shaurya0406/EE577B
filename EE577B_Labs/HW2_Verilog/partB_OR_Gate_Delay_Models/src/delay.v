`timescale 1ns/1ps
// EE577B HW2 - Part B
// Five separate OR modules modeling different delay semantics

// Model 1: Inter-statement delay with blocking assignment (inertial-like)
module or_block_inter (
  input  A,
  input  B,
  output reg Y
);
  always @ (*) begin
    #4 Y = A | B;
  end
endmodule

// Model 2: Inter-statement delay with non-blocking assignment (inertial-like, NBA landing)
module or_nba_inter (
  input  A,
  input  B,
  output reg Y
);
  always @ (*) begin
    #4 Y <= A | B;
  end
endmodule

// Model 3: Intra-assignment delay with blocking assignment (transport-like scheduling)
module or_block_intra (
  input  A,
  input  B,
  output reg Y
);
  always @ (*) begin
    Y = #4 A | B;
  end
endmodule

// Model 4: Intra-assignment delay with non-blocking assignment (transport-like scheduling, NBA landing)
module or_nba_intra (
  input  A,
  input  B,
  output reg Y
);
  always @ (*) begin
    Y <= #4 A | B;
  end
endmodule

// Model 5: Continuous assignment with delay (inertial by Verilog semantics)
module or_continuous (
  input  A,
  input  B,
  output Y
);
  assign #4 Y = A | B;
endmodule
