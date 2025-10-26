`timescale 1ns/1ps

module tb_traffic;

  // --------------------------------------------------------------------------
  // Clock and DUT I/O
  // --------------------------------------------------------------------------
  reg         CLK;
  reg         reset;   // sync, active-HIGH
  reg         ERR;     // sync, active-HIGH
  reg         PA;      // sync, active-HIGH
  reg         PB;      // sync, active-HIGH
  wire [2:0]  L_A;
  wire [2:0]  L_B;
  wire        RA;
  wire        RB;

  // Clock: 100 MHz (10 ns period)
  localparam CLK_PERIOD = 10;

  // --------------------------------------------------------------------------
  // Instantiate DUT
  //   NOTE: This matches the port list you used in traffic_control.
  // --------------------------------------------------------------------------
  traffic_control dut (
    .CLK   (CLK),
    .reset (reset),
    .ERR   (ERR),
    .PA    (PA),
    .PB    (PB),
    .L_A   (L_A),
    .L_B   (L_B),
    .RA    (RA),
    .RB    (RB)
  );

  // --------------------------------------------------------------------------
  // Clock generation
  // --------------------------------------------------------------------------
  initial CLK = 1'b0;
  always #(CLK_PERIOD/2) CLK = ~CLK;

  // --------------------------------------------------------------------------
  // Utilities
  // --------------------------------------------------------------------------
  integer cycle;

  task wait_clks;
    input integer n;
    integer i;
    begin
      for (i = 0; i < n; i = i + 1) begin
        @(posedge CLK);
      end
    end
  endtask

  task pulse_high_sync;
    inout reg sig;
    input integer width_clks;
    begin
      sig = 1'b1;
      wait_clks(width_clks);
      sig = 1'b0;
    end
  endtask

  // Pretty-print helpers (purely for readability in the transcript)
  function [25*8-1:0] code2txt; // up to 79 chars
    input [2:0] code;
    begin
      case (code)
        3'b110: code2txt = "GREEN         ";
        3'b101: code2txt = "G_LEFT        ";
        3'b100: code2txt = "YELLOW        ";
        3'b011: code2txt = "RED           ";
        3'b010: code2txt = "G_RIGHT       ";
        3'b111: code2txt = "FLASH_RED     ";
        3'b000: code2txt = "FLASH_YELLOW  ";
        default: code2txt = "UNKNOWN       ";
      endcase
    end
  endfunction

  // Track durations between output changes to sanity-check state timing.
  integer dur_cnt;
  reg [2:0] last_LA, last_LB;

  task check_and_report_duration;
    input [2:0] prev_LA, prev_LB;
    input integer dur;
    begin
      // Expected durations for the specific pairs (based on spec):
      // S0: (FLASH_RED, FLASH_RED) -> 6
      // S1: (GREEN, RED) -> 8
      // S2: (G_LEFT, G_RIGHT) -> 3
      // S3: (YELLOW, G_RIGHT) -> 3
      // S4: (RED, GREEN) -> 8
      // S5: (G_RIGHT, G_LEFT) -> 3
      // S6: (G_RIGHT, YELLOW) -> 3
      // S7: (FLASH_YELLOW, FLASH_YELLOW) -> N/A (don’t check)
      if (prev_LA == 3'b111 && prev_LB == 3'b111) begin
        if (dur !== 6)
          $display("[WARN] S0 observed for %0d cycles (expected 6)", dur);
      end
      else if (prev_LA == 3'b110 && prev_LB == 3'b011) begin
        if (dur !== 8)
          $display("[WARN] S1 observed for %0d cycles (expected 8)", dur);
      end
      else if (prev_LA == 3'b101 && prev_LB == 3'b010) begin
        if (dur !== 3)
          $display("[WARN] S2 observed for %0d cycles (expected 3)", dur);
      end
      else if (prev_LA == 3'b100 && prev_LB == 3'b010) begin
        if (dur !== 3)
          $display("[WARN] S3 observed for %0d cycles (expected 3)", dur);
      end
      else if (prev_LA == 3'b011 && prev_LB == 3'b110) begin
        if (dur !== 8)
          $display("[WARN] S4 observed for %0d cycles (expected 8)", dur);
      end
      else if (prev_LA == 3'b010 && prev_LB == 3'b101) begin
        if (dur !== 3)
          $display("[WARN] S5 observed for %0d cycles (expected 3)", dur);
      end
      else if (prev_LA == 3'b010 && prev_LB == 3'b100) begin
        if (dur !== 3)
          $display("[WARN] S6 observed for %0d cycles (expected 3)", dur);
      end
      else if (prev_LA == 3'b000 && prev_LB == 3'b000) begin
        // S7: do not check duration
      end
      // else: transitional / unknown pair -> ignore
    end
  endtask

  // --------------------------------------------------------------------------
  // Trace and lightweight checks each cycle
  // --------------------------------------------------------------------------
  always @(posedge CLK) begin
    cycle <= cycle + 1;

    // Detect output-region changes to check durations
    if ({L_A, L_B} !== {last_LA, last_LB}) begin
      if (cycle > 0) begin
        check_and_report_duration(last_LA, last_LB, dur_cnt);
      end
      dur_cnt  <= 1;
      last_LA  <= L_A;
      last_LB  <= L_B;
    end else begin
      dur_cnt  <= dur_cnt + 1;
    end

    // Print a compact line every cycle
    // $display("[%0t | %0d]  L_A=%s  L_B=%s  RA=%0d RB=%0d  (PA=%0d PB=%0d ERR=%0d rst=%0d)",
    //          $time, cycle, code2txt(L_A), code2txt(L_B), RA, RB, PA, PB, ERR, reset);
    
    $display("L_A=%s  L_B=%s  RA=%0d RB=%0d  (PA=%0d PB=%0d ERR=%0d rst=%0d)",
             code2txt(L_A), code2txt(L_B), RA, RB, PA, PB, ERR, reset);
  end

  // --------------------------------------------------------------------------
  // Stimulus
  // --------------------------------------------------------------------------
  initial begin
    // init
    cycle   = 0;
    dur_cnt = 0;
    last_LA = 3'bxxx;
    last_LB = 3'bxxx;

    reset = 1'b0;
    ERR   = 1'b0;
    PA    = 1'b0;
    PB    = 1'b0;

    // Apply synchronous reset for a couple of cycles (ERR=0)
    @(posedge CLK);
    reset = 1'b1;
    wait_clks(2);
    reset = 1'b0;

    // Upon reset deassertion, DUT goes to S7 (flash-yellow), then S0 (post-reset pedestrian), then S1

    // Let it run into S1 and S2… Place a pedestrian request on A during S2,
    // so it is serviced at end of S3 (per spec) then resume at S4.
    // Give some time to reach S1.
    wait_clks(12);

    // Issue PA for 1 cycle (sampled synchronously)
    pulse_high_sync(PA, 1);

    // Let it progress through S3 -> S0 -> S4 path
    wait_clks(30);

    // Now request PB during S5 so it is served at end of S6 and resumes at S1
    pulse_high_sync(PB, 1);

    // While in S0, press PA again to ensure it’s ignored during S0
    // Give a little time, then raise ERR to pre-empt everything
    wait_clks(15);
    // Try pressing PA during S0 window (if we happen to be there). It’s OK even if not exactly in S0;
    // the DUT will latch only outside S0/S7.
    pulse_high_sync(PA, 1);

    // Trigger an ERR window for a few cycles
    wait_clks(10);
    ERR = 1'b1;
    wait_clks(10);
    ERR = 1'b0; // On ERR deassert, DUT must do S0 (both RA/RB high), then resume at S1

    // Let it run for a few more loops
    wait_clks(80);

    $display("\n[TB] Finished basic stimulus.");
    $finish;
  end

endmodule
