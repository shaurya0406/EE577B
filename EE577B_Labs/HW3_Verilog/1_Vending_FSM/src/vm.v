`timescale 1ns/1ps
//==============================================================================
// EE577B HW3 — Q1 Vending Machine Coin Return FSM (vm.v)
//------------------------------------------------------------------------------
// * Purpose
//   Controller that returns change using a single coin/bill per clock, choosing
//   the largest available denomination first, and asserting `done` when idle or
//   when the transaction completes.
//
// * Interface (from spec, with plain Verilog types)
//   - Inputs
//       clk           : system clock
//       reset         : synchronous, active-HIGH
//       start         : synchronous, active-HIGH pulse (1 cycle)
//       money[8:0]    : amount inserted
//       price[8:0]    : item price (assume money >= price when start=1)
//       avail_B/Q/D/N/P: availability flags for $1, 25c, 10c, 5c, 1c (sampled at start)
//   - Outputs
//       disp_B/Q/D/N/P: one-cycle enable pulses to coin/bill stacks
//       done          : HIGH in idle and after completion
//
// * Assumptions (explicitly allowed by spec hints)
//   - `start` is asserted for exactly one clock cycle.
//   - All inputs (`money`, `price`, `avail_*`) are valid and stable in the start cycle.
//   - Units below assume CENTS (B=100, Q=25, D=10, N=5, P=1). Keep TB consistent.
//
// * Design choices (kept simple & synthesizable)
//   - Moore FSM with dedicated "pulse" states for each denomination to guarantee
//     clean one-cycle `disp_*` pulses at the clock edge.
//   - Inputs/flags are latched exactly once (the cycle after seeing `start`).
//   - A single flip-flop `coin_sel` holds the currently chosen coin value across
//     DISP → UPDATE, so subtraction is unambiguous.
//   - Greedy priority: B → Q → D → N → P.
//   - If no denomination can be used (given latched availability) and `change`
//     is still nonzero, we terminate (spec does not define partial behavior).
//
// * Coding style
//   - Non-blocking (<=) in sequential always block.
//   - Separate combinational blocks for next-state, selection, and outputs.
//   - No delays, no SV features, plain Verilog only.
//==============================================================================

module coin_return
(
  output reg disp_B,
  output reg disp_Q,
  output reg disp_D,
  output reg disp_N,
  output reg disp_P,
  output reg done,

  input  [8:0] money,
  input  [8:0] price,

  input        start,
  input        clk,
  input        reset,

  input        avail_B,
  input        avail_Q,
  input        avail_D,
  input        avail_N,
  input        avail_P
);

  //--------------------------------------------------------------------------
  // * Denomination values (CENTS). Keep your testbench in the same units.
  //--------------------------------------------------------------------------
  localparam integer COIN_B = 100; // $1.00
  localparam integer COIN_Q = 25;  // $0.25
  localparam integer COIN_D = 10;  // $0.10
  localparam integer COIN_N = 5;   // $0.05
  localparam integer COIN_P = 1;   // $0.01

  //--------------------------------------------------------------------------
  // * FSM state encoding (Moore)
  //   Separate one-cycle pulse states guarantee single coin per cycle.
  //--------------------------------------------------------------------------
  localparam [3:0]
    S_IDLE   = 4'd0,
    S_LATCH  = 4'd1,
    S_SELECT = 4'd2,
    S_DISP_B = 4'd3,
    S_DISP_Q = 4'd4,
    S_DISP_D = 4'd5,
    S_DISP_N = 4'd6,
    S_DISP_P = 4'd7,
    S_UPDATE = 4'd8,
    S_DONE   = 4'd9;

  reg [3:0] state, next_state;

  //--------------------------------------------------------------------------
  // * Latched snapshot (captured once per transaction)
  //   change_latched width (10b) safely covers up to 511 cents difference.
  //--------------------------------------------------------------------------
  reg [9:0] change_latched;
  reg       availB_l, availQ_l, availD_l, availN_l, availP_l;

  //--------------------------------------------------------------------------
  // * Coin selection
  //   - `choice_coin` is the combinational pick in S_SELECT.
  //   - `coin_sel` is the only FF that holds the chosen coin across states.
  //--------------------------------------------------------------------------
  reg  [7:0] choice_coin; // 0 when no coin fits
  reg  [7:0] coin_sel;    // registered selected coin (0 when none)

  //--------------------------------------------------------------------------
  // Sequential logic: state & registers (synchronous, active-HIGH reset)
  //--------------------------------------------------------------------------
  always @(posedge clk) begin
    if (reset) begin
      state          <= S_IDLE;
      change_latched <= 10'd0;
      availB_l       <= 1'b0;
      availQ_l       <= 1'b0;
      availD_l       <= 1'b0;
      availN_l       <= 1'b0;
      availP_l       <= 1'b0;
      coin_sel       <= 8'd0;
    end
    else begin
      state <= next_state;

      // * Latch inputs once after start is observed
      if (state == S_LATCH) begin
        // ! Spec: money >= price when start=1
        change_latched <= (money >= price) ? (money - price) : 10'd0;
        availB_l <= avail_B;
        availQ_l <= avail_Q;
        availD_l <= avail_D;
        availN_l <= avail_N;
        availP_l <= avail_P;
      end

      // * Capture the chosen coin in SELECT (0 when none fits)
      if (state == S_SELECT) begin
        coin_sel <= choice_coin;
      end

      // * Apply the subtraction in UPDATE using the registered selection
      else if (state == S_UPDATE) begin
        if (coin_sel != 8'd0) begin
          if (change_latched >= coin_sel)
            change_latched <= change_latched - coin_sel;
          else
            change_latched <= 10'd0; // defensive clamp
        end
      end

      // * Hygiene: clear coin_sel in IDLE/DONE (optional)
      if (state == S_DONE || state == S_IDLE) begin
        coin_sel <= 8'd0;
      end
    end
  end

  //--------------------------------------------------------------------------
  // Combinational: coin picker (priority B → Q → D → N → P)
  //   Only active in S_SELECT; otherwise 0 by default.
  //--------------------------------------------------------------------------
  always @* begin
    choice_coin = 8'd0;
    if (state == S_SELECT) begin
      if      (availB_l && (change_latched >= COIN_B)) choice_coin = COIN_B[7:0];
      else if (availQ_l && (change_latched >= COIN_Q)) choice_coin = COIN_Q[7:0];
      else if (availD_l && (change_latched >= COIN_D)) choice_coin = COIN_D[7:0];
      else if (availN_l && (change_latched >= COIN_N)) choice_coin = COIN_N[7:0];
      else if (availP_l && (change_latched >= COIN_P)) choice_coin = COIN_P[7:0];
      else                                             choice_coin = 8'd0;
    end
  end

  //--------------------------------------------------------------------------
  // Combinational: next-state logic
  //--------------------------------------------------------------------------
  always @* begin
    next_state = state;

    case (state)
      // * Idle: done is HIGH, wait for start pulse
      S_IDLE: begin
        if (start)
          next_state = S_LATCH;
        else
          next_state = S_IDLE;
      end

      // * Latch inputs & availability snapshot
      //   If nothing is available, terminate immediately.
      S_LATCH: begin
        if ( (avail_B | avail_Q | avail_D | avail_N | avail_P) == 1'b0 )
          next_state = S_DONE;
        else
          next_state = S_SELECT;
      end

      // * Decide next coin (or terminate if change==0 or no coin fits)
      S_SELECT: begin
        if (change_latched == 10'd0) begin
          next_state = S_DONE;
        end
        else if (choice_coin == 8'd0) begin
          // ? Exact change impossible with allowed denominations → finish
          next_state = S_DONE;
        end
        else begin
          if      (choice_coin == COIN_B[7:0]) next_state = S_DISP_B;
          else if (choice_coin == COIN_Q[7:0]) next_state = S_DISP_Q;
          else if (choice_coin == COIN_D[7:0]) next_state = S_DISP_D;
          else if (choice_coin == COIN_N[7:0]) next_state = S_DISP_N;
          else if (choice_coin == COIN_P[7:0]) next_state = S_DISP_P;
          else                                 next_state = S_DONE;
        end
      end

      // * One-cycle pulse states (exactly one coin drops at this posedge)
      S_DISP_B,
      S_DISP_Q,
      S_DISP_D,
      S_DISP_N,
      S_DISP_P: begin
        next_state = S_UPDATE;
      end

      // * Arithmetic update then try again
      S_UPDATE: begin
        next_state = S_SELECT;
      end

      // * Completion: assert done, then return to idle
      S_DONE: begin
        next_state = S_IDLE;
      end

      default: begin
        next_state = S_IDLE;
      end
    endcase
  end

  //--------------------------------------------------------------------------
  // Combinational: Moore outputs (depend only on current state)
  //--------------------------------------------------------------------------
  always @* begin
    // defaults
    disp_B = 1'b0;
    disp_Q = 1'b0;
    disp_D = 1'b0;
    disp_N = 1'b0;
    disp_P = 1'b0;
    done   = 1'b0;

    case (state)
      S_IDLE:   done = 1'b1;

      S_DISP_B: disp_B = 1'b1;
      S_DISP_Q: disp_Q = 1'b1;
      S_DISP_D: disp_D = 1'b1;
      S_DISP_N: disp_N = 1'b1;
      S_DISP_P: disp_P = 1'b1;

      S_DONE:   done   = 1'b1;

      default:  ; // in all other states, keep defaults
    endcase
  end

endmodule
