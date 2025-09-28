`timescale 1ns/1ns
// EE577B HW2 Part E — JTAG TAP Controller FSM 
// Ports: TCK (clock), TRST (sync, active HIGH), TMS (control), STATE[3:0] (encoded)

module tap_controller (TCK, TRST, TMS, STATE);
  input  TCK, TRST, TMS;
  output [3:0] STATE;

  // State register
  reg [3:0] state, next_state;

  // Output Combinaional Logic
  assign STATE = state;

  // Table 2 state encodings (explicitly with PARAMETER as required)
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

  // Synchronous, active-HIGH reset: sample TRST at posedge TCK
  always @(posedge TCK) begin
    if (TRST)
      state <= TEST_LOGIC_RESET;
    else
      state <= next_state;
  end

  // Next-state logic: TMS determines the arc out of each state
  always @* begin
    case (state)
      TEST_LOGIC_RESET: next_state = (TMS ? TEST_LOGIC_RESET : RUN_TEST_IDLE);
      RUN_TEST_IDLE   : next_state = (TMS ? SELECT_DR_SCAN  : RUN_TEST_IDLE);
      SELECT_DR_SCAN  : next_state = (TMS ? SELECT_IR_SCAN  : CAPTURE_DR);
      CAPTURE_DR      : next_state = (TMS ? EXIT1_DR        : SHIFT_DR);
      SHIFT_DR        : next_state = (TMS ? EXIT1_DR        : SHIFT_DR);
      EXIT1_DR        : next_state = (TMS ? UPDATE_DR       : PAUSE_DR);
      PAUSE_DR        : next_state = (TMS ? EXIT2_DR        : PAUSE_DR);
      EXIT2_DR        : next_state = (TMS ? UPDATE_DR       : SHIFT_DR);
      UPDATE_DR       : next_state = (TMS ? SELECT_DR_SCAN  : RUN_TEST_IDLE);

      SELECT_IR_SCAN  : next_state = (TMS ? TEST_LOGIC_RESET: CAPTURE_IR);
      CAPTURE_IR      : next_state = (TMS ? EXIT1_IR        : SHIFT_IR);
      SHIFT_IR        : next_state = (TMS ? EXIT1_IR        : SHIFT_IR);
      EXIT1_IR        : next_state = (TMS ? UPDATE_IR       : PAUSE_IR);
      PAUSE_IR        : next_state = (TMS ? EXIT2_IR        : PAUSE_IR);
      EXIT2_IR        : next_state = (TMS ? UPDATE_IR       : SHIFT_IR);
      UPDATE_IR       : next_state = (TMS ? SELECT_DR_SCAN  : RUN_TEST_IDLE);

      default         : next_state = TEST_LOGIC_RESET;
    endcase
  end
endmodule
