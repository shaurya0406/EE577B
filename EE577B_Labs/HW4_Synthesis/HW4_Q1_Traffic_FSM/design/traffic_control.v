// // EE577B HW3 - Traffic Light Controller 
// module traffic_control (
//     input  CLK,
//     input  reset,   // synchronous, active HIGH (ignored when ERR=1)
//     input  ERR,     // synchronous, active HIGH, highest priority
//     input  PA,      // synchronous, active HIGH
//     input  PB,      // synchronous, active HIGH
//     output reg [2:0] L_A,
//     output reg [2:0] L_B,
//     output reg       RA,
//     output reg       RB
// );

//     // --- Signal encodings
//     parameter [2:0] SIG_GREEN        = 3'b110;
//     parameter [2:0] SIG_G_LEFT       = 3'b101;
//     parameter [2:0] SIG_YELLOW       = 3'b100;
//     parameter [2:0] SIG_RED          = 3'b011;
//     parameter [2:0] SIG_G_RIGHT      = 3'b010;
//     parameter [2:0] SIG_FLASH_RED    = 3'b111;
//     parameter [2:0] SIG_FLASH_YELLOW = 3'b000;

//     // --- State encodings
//     parameter [2:0] S0_PED = 3'd0;
//     parameter [2:0] S1     = 3'd1;
//     parameter [2:0] S2     = 3'd2;
//     parameter [2:0] S3     = 3'd3;
//     parameter [2:0] S4     = 3'd4;
//     parameter [2:0] S5     = 3'd5;
//     parameter [2:0] S6     = 3'd6;
//     parameter [2:0] S7_ERR = 3'd7;

//     // --- Durations (clks)
//     parameter [5:0] D0 = 6, D1 = 8, D2 = 3, D3 = 3, D4 = 8, D5 = 3, D6 = 3;

//     // --- Registers
//     reg [2:0] state, next_state;
//     reg [2:0] return_state;        // where to go after S0
//     reg [5:0] tick;                // per-state cycle counter
//     reg       pa_req, pb_req;      // latched ped requests  (SINGLE WRITER)
//     reg       pa_served, pb_served;// which sides are being served in current S0
//     reg       force_ped_once;      // S0 required after leaving ERR/reset

//     // --- Duration helper
//     function [5:0] state_duration;
//         input [2:0] s;
//         begin
//             case (s)
//                 S0_PED: state_duration = D0;
//                 S1:     state_duration = D1;
//                 S2:     state_duration = D2;
//                 S3:     state_duration = D3;
//                 S4:     state_duration = D4;
//                 S5:     state_duration = D5;
//                 S6:     state_duration = D6;
//                 default:state_duration = 0; // S7_ERR or invalid
//             endcase
//         end
//     endfunction

//     wire tick_en   = (state != S7_ERR) && (state_duration(state) != 0);
//     wire tick_last = tick_en && (tick == state_duration(state)-1);

//     // Precompute entry conditions (combinational)
//     wire entering_S0_from_normal = (state != S0_PED) && (state != S7_ERR) && (next_state == S0_PED);
//     wire entering_S0_from_err    = (state == S7_ERR) && (next_state == S0_PED);

//     // ----------------------------------------------------------------
//     // SINGLE WRITER for pa_req/pb_req (fixes ELAB-366)
//     //   - Clear on ERR/reset
//     //   - Latch PA/PB only outside S0/S7
//     //   - Clear when entering S0 from normal path (we’re about to serve them)
//     // ----------------------------------------------------------------
//     always @(posedge CLK) begin
//         if (ERR) begin
//             pa_req <= 1'b0;
//             pb_req <= 1'b0;
//         end else if (reset) begin
//             pa_req <= 1'b0;
//             pb_req <= 1'b0;
//         end else begin
//             // Clear latched requests the cycle we enter S0 from S3/S6
//             if (entering_S0_from_normal) begin
//                 pa_req <= 1'b0;
//                 pb_req <= 1'b0;
//             end
//             else begin
//                 // Latch requests only outside S0 and S7
//                 if (state != S0_PED && state != S7_ERR) begin
//                     if (PA) pa_req <= 1'b1;
//                     if (PB) pb_req <= 1'b1;
//                 end
//             end
//             // Note: entering from S7 path doesn't rely on pa_req/pb_req
//         end
//     end

//     // ----------------------------------------------------------------
//     // State / tick / force_ped_once / return_state sequencing
//     // ----------------------------------------------------------------
//     always @(posedge CLK) begin
//         if (ERR) begin
//             state          <= S7_ERR;
//             tick           <= 6'd0;
//             return_state   <= S1;
//             force_ped_once <= 1'b0;
//             pa_served      <= 1'b0;
//             pb_served      <= 1'b0;
//         end
//         else if (reset) begin
//             state          <= S7_ERR;
//             tick           <= 6'd0;
//             return_state   <= S1;
//             force_ped_once <= 1'b0;
//             pa_served      <= 1'b0;
//             pb_served      <= 1'b0;
//         end
//         else begin
//             state <= next_state;

//             // Tick
//             if (state == next_state) begin
//                 if (tick_en) begin
//                     if (tick_last) tick <= 6'd0;
//                     else           tick <= tick + 6'd1;
//                 end else begin
//                     tick <= 6'd0;
//                 end
//             end else begin
//                 tick <= 6'd0;
//             end

//             // S7 -> S0 forces one pedestrian cycle
//             if (entering_S0_from_err) begin
//                 force_ped_once <= 1'b1;
//             end
//             if (state == S0_PED && tick_last) begin
//                 force_ped_once <= 1'b0;
//             end

//             // Set return_state when scheduling S0 due to pending requests
//             if (state == S3 && tick_last && (pa_req || pb_req)) return_state <= S4;
//             if (state == S6 && tick_last && (pa_req || pb_req)) return_state <= S1;

//             // Capture served sides on entry to S0
//             if (entering_S0_from_normal) begin
//                 pa_served <= pa_req;
//                 pb_served <= pb_req;
//             end
//             else if (entering_S0_from_err) begin
//                 pa_served <= 1'b1;
//                 pb_served <= 1'b1;
//             end

//             // Clear served flags when S0 finishes
//             if (state == S0_PED && tick_last) begin
//                 pa_served <= 1'b0;
//                 pb_served <= 1'b0;
//             end
//         end
//     end

//     // ----------------------------------------------------------------
//     // Next-state (combinational)
//     // ----------------------------------------------------------------
//     always @* begin
//         next_state = state;
//         case (state)
//             S7_ERR: begin
//                 next_state = S0_PED; // when ERR=0, we move to S0
//             end
//             S0_PED: begin
//                 if (tick_last) next_state = return_state;
//             end
//             S1: begin
//                 if (tick_last) next_state = S2;
//             end
//             S2: begin
//                 if (tick_last) next_state = S3;
//             end
//             S3: begin
//                 if (tick_last) begin
//                     if (pa_req || pb_req) next_state = S0_PED;
//                     else                   next_state = S4;
//                 end
//             end
//             S4: begin
//                 if (tick_last) next_state = S5;
//             end
//             S5: begin
//                 if (tick_last) next_state = S6;
//             end
//             S6: begin
//                 if (tick_last) begin
//                     if (pa_req || pb_req) next_state = S0_PED;
//                     else                   next_state = S1;
//                 end
//             end
//             default: begin
//                 next_state = S7_ERR;
//             end
//         endcase
//     end

//     // ----------------------------------------------------------------
//     // Registered outputs (glitch-free)
//     // ----------------------------------------------------------------
//     reg [2:0] la_next, lb_next;
//     reg       ra_hold, rb_hold;

//     // Light code map (combinational)
//     always @* begin
//         la_next = L_A;
//         lb_next = L_B;
//         case (state)
//             S0_PED:   begin la_next = SIG_FLASH_RED;    lb_next = SIG_FLASH_RED;    end
//             S1:       begin la_next = SIG_GREEN;        lb_next = SIG_RED;          end
//             S2:       begin la_next = SIG_G_LEFT;       lb_next = SIG_G_RIGHT;      end
//             S3:       begin la_next = SIG_YELLOW;       lb_next = SIG_G_RIGHT;      end
//             S4:       begin la_next = SIG_RED;          lb_next = SIG_GREEN;        end
//             S5:       begin la_next = SIG_G_RIGHT;      lb_next = SIG_G_LEFT;       end
//             S6:       begin la_next = SIG_G_RIGHT;      lb_next = SIG_YELLOW;       end
//             S7_ERR:   begin la_next = SIG_FLASH_YELLOW; lb_next = SIG_FLASH_YELLOW; end
//             default:  begin la_next = SIG_FLASH_YELLOW; lb_next = SIG_FLASH_YELLOW; end
//         endcase
//     end

//     // Drive outputs on clock edges
//     always @(posedge CLK) begin
//         if (ERR) begin
//             L_A    <= SIG_FLASH_YELLOW;
//             L_B    <= SIG_FLASH_YELLOW;
//             RA     <= 1'b0;
//             RB     <= 1'b0;
//             ra_hold<= 1'b0;
//             rb_hold<= 1'b0;
//         end else if (reset) begin
//             L_A    <= SIG_FLASH_YELLOW;
//             L_B    <= SIG_FLASH_YELLOW;
//             RA     <= 1'b0;
//             RB     <= 1'b0;
//             ra_hold<= 1'b0;
//             rb_hold<= 1'b0;
//         end else begin
//             // lights follow state map
//             L_A <= la_next;
//             L_B <= lb_next;

//             // capture RA/RB intent on entry to S0 (no immediate drive)
//             if (entering_S0_from_normal) begin
//                 ra_hold <= pa_served;
//                 rb_hold <= pb_served;
//             end else if (entering_S0_from_err) begin
//                 ra_hold <= 1'b1;
//                 rb_hold <= 1'b1;
//             end

//             // drive RA/RB only while in S0
//             if (state == S0_PED) begin
//                 RA <= ra_hold | force_ped_once;
//                 RB <= rb_hold | force_ped_once;
//                 if (tick_last) begin
//                     ra_hold <= 1'b0;
//                     rb_hold <= 1'b0;
//                 end
//             end else begin
//                 RA <= 1'b0;
//                 RB <= 1'b0;
//             end
//         end
//     end

// endmodule




// EE577B HW3 - Traffic Light Controller (Verilog-2001, ONE-HOT FSM)
// Glitch-free outputs; priorities: ERR > reset > PA/PB
module traffic_control (
    input  CLK,
    input  reset,   // synchronous, active HIGH (ignored when ERR=1)
    input  ERR,     // synchronous, active HIGH, highest priority
    input  PA,      // synchronous, active HIGH
    input  PB,      // synchronous, active HIGH
    output reg [2:0] L_A,
    output reg [2:0] L_B,
    output reg       RA,
    output reg       RB
);

    // -------------------------------
    // Signal encodings
    // -------------------------------
    parameter [2:0] SIG_GREEN        = 3'b110;
    parameter [2:0] SIG_G_LEFT       = 3'b101;
    parameter [2:0] SIG_YELLOW       = 3'b100;
    parameter [2:0] SIG_RED          = 3'b011;
    parameter [2:0] SIG_G_RIGHT      = 3'b010;
    parameter [2:0] SIG_FLASH_RED    = 3'b111;
    parameter [2:0] SIG_FLASH_YELLOW = 3'b000;

    // -------------------------------
    // ONE-HOT state encodings (bit position == state)
    // -------------------------------
    parameter [7:0] S0_PED   = 8'b0000_0001; // bit0
    parameter [7:0] S1       = 8'b0000_0010; // bit1
    parameter [7:0] S2       = 8'b0000_0100; // bit2
    parameter [7:0] S3       = 8'b0000_1000; // bit3
    parameter [7:0] S4       = 8'b0001_0000; // bit4
    parameter [7:0] S5       = 8'b0010_0000; // bit5
    parameter [7:0] S6       = 8'b0100_0000; // bit6
    parameter [7:0] S7_ERR   = 8'b1000_0000; // bit7

    // Durations (in clocks)
    parameter [5:0] D0 = 6, D1 = 8, D2 = 3, D3 = 3,
                    D4 = 8, D5 = 3, D6 = 3;

    // -------------------------------
    // Registers / flags
    // -------------------------------
    reg  [7:0] state, next_state;   // one-hot
    reg  [5:0] tick;                // per-state counter
    reg        pa_req, pb_req;      // SINGLE WRITER (see block below)
    reg        pa_served, pb_served;// which sides S0 is serving
    reg        force_ped_once;      // S0 required after leaving ERR/reset
    reg        ret_sel;             // 0 => resume S1, 1 => resume S4 (replaces return_state)

    // -------------------------------
    // Duration helper (one-hot)
    // -------------------------------
    function [5:0] state_duration;
        input [7:0] s;
        begin
            if      (s == S0_PED) state_duration = D0;
            else if (s == S1    ) state_duration = D1;
            else if (s == S2    ) state_duration = D2;
            else if (s == S3    ) state_duration = D3;
            else if (s == S4    ) state_duration = D4;
            else if (s == S5    ) state_duration = D5;
            else if (s == S6    ) state_duration = D6;
            else                  state_duration = 0; // S7_ERR or invalid
        end
    endfunction

    wire tick_en   = (state != S7_ERR) && (state_duration(state) != 0);
    wire tick_last = tick_en && (tick == state_duration(state)-1);

    // Convenience one-hot checks
    wire in_S7 = (state == S7_ERR);
    wire in_S0 = (state == S0_PED);

    // -------------------------------
    // Next-state (combinational, one-hot)
    // -------------------------------
    always @* begin
        next_state = state; // hold

        if (state == S7_ERR) begin
            // When ERR deasserts, we will move to S0; (ERR priority handled in seq block)
            next_state = S0_PED;
        end
        else if (state == S0_PED) begin
            if (tick_last) next_state = (ret_sel ? S4 : S1);
        end
        else if (state == S1) begin
            if (tick_last) next_state = S2;
        end
        else if (state == S2) begin
            if (tick_last) next_state = S3;
        end
        else if (state == S3) begin
            if (tick_last) begin
                if (pa_req || pb_req) next_state = S0_PED;
                else                   next_state = S4;
            end
        end
        else if (state == S4) begin
            if (tick_last) next_state = S5;
        end
        else if (state == S5) begin
            if (tick_last) next_state = S6;
        end
        else if (state == S6) begin
            if (tick_last) begin
                if (pa_req || pb_req) next_state = S0_PED;
                else                   next_state = S1;
            end
        end
        else begin
            next_state = S7_ERR; // safe default if illegal
        end
    end

    // Precompute entry conditions (combinational)
    wire entering_S0_from_normal = (next_state == S0_PED) && !(in_S0) && !(in_S7);
    wire entering_S0_from_err    = (next_state == S0_PED) &&  in_S7;

    // -------------------------------
    // SINGLE WRITER for pa_req/pb_req
    //  - Clear on ERR/reset
    //  - Latch outside S0/S7
    //  - Clear when entering S0 from normal path
    // -------------------------------
    always @(posedge CLK) begin
        if (ERR) begin
            pa_req <= 1'b0;
            pb_req <= 1'b0;
        end else if (reset) begin
            pa_req <= 1'b0;
            pb_req <= 1'b0;
        end else begin
            if (entering_S0_from_normal) begin
                pa_req <= 1'b0;
                pb_req <= 1'b0;
            end else begin
                if (!in_S0 && !in_S7) begin
                    if (PA) pa_req <= 1'b1;
                    if (PB) pb_req <= 1'b1;
                end
            end
        end
    end

    // -------------------------------
    // Sequential: state/tick/ret_sel/served/force_ped_once
    // -------------------------------
    always @(posedge CLK) begin
        if (ERR) begin
            state          <= S7_ERR;
            tick           <= 6'd0;
            force_ped_once <= 1'b0;
            ret_sel        <= 1'b0;  // after post-ERR S0, resume S1
            pa_served      <= 1'b0;
            pb_served      <= 1'b0;
        end
        else if (reset) begin
            state          <= S7_ERR;
            tick           <= 6'd0;
            force_ped_once <= 1'b0;
            ret_sel        <= 1'b0;  // after post-reset S0, resume S1
            pa_served      <= 1'b0;
            pb_served      <= 1'b0;
        end
        else begin
            state <= next_state;

            // Tick
            if (state == next_state) begin
                if (tick_en) begin
                    if (tick_last) tick <= 6'd0;
                    else           tick <= tick + 6'd1;
                end else begin
                    tick <= 6'd0; // S7
                end
            end else begin
                tick <= 6'd0;
            end

            // Force one pedestrian cycle when leaving S7
            if (entering_S0_from_err) force_ped_once <= 1'b1;
            if (in_S0 && tick_last)   force_ped_once <= 1'b0;

            // Set resume target when we schedule S0 due to requests
            if ((state == S3) && tick_last && (pa_req || pb_req)) ret_sel <= 1'b1; // -> S4
            if ((state == S6) && tick_last && (pa_req || pb_req)) ret_sel <= 1'b0; // -> S1

            // Capture whom we serve on entry to S0
            if (entering_S0_from_normal) begin
                pa_served <= pa_req;
                pb_served <= pb_req;
            end else if (entering_S0_from_err) begin
                pa_served <= 1'b1; // both
                pb_served <= 1'b1;
            end

            // Clear served flags when S0 completes
            if (in_S0 && tick_last) begin
                pa_served <= 1'b0;
                pb_served <= 1'b0;
            end
        end
    end

    // -------------------------------
    // Output mapping (registered, glitch-free)
    // -------------------------------
    reg [2:0] la_next, lb_next;
    reg       ra_hold, rb_hold;

    // Light codes (combinational from current state)
    always @* begin
        la_next = L_A;
        lb_next = L_B;

        if      (state == S0_PED)   begin la_next = SIG_FLASH_RED;    lb_next = SIG_FLASH_RED;    end
        else if (state == S1)       begin la_next = SIG_GREEN;        lb_next = SIG_RED;          end
        else if (state == S2)       begin la_next = SIG_G_LEFT;       lb_next = SIG_G_RIGHT;      end
        else if (state == S3)       begin la_next = SIG_YELLOW;       lb_next = SIG_G_RIGHT;      end
        else if (state == S4)       begin la_next = SIG_RED;          lb_next = SIG_GREEN;        end
        else if (state == S5)       begin la_next = SIG_G_RIGHT;      lb_next = SIG_G_LEFT;       end
        else if (state == S6)       begin la_next = SIG_G_RIGHT;      lb_next = SIG_YELLOW;       end
        else if (state == S7_ERR)   begin la_next = SIG_FLASH_YELLOW; lb_next = SIG_FLASH_YELLOW; end
        else                        begin la_next = SIG_FLASH_YELLOW; lb_next = SIG_FLASH_YELLOW; end
    end

    // Registered outputs & RA/RB protocol
    always @(posedge CLK) begin
        if (ERR) begin
            L_A     <= SIG_FLASH_YELLOW;
            L_B     <= SIG_FLASH_YELLOW;
            RA      <= 1'b0;
            RB      <= 1'b0;
            ra_hold <= 1'b0;
            rb_hold <= 1'b0;
        end else if (reset) begin
            L_A     <= SIG_FLASH_YELLOW;
            L_B     <= SIG_FLASH_YELLOW;
            RA      <= 1'b0;
            RB      <= 1'b0;
            ra_hold <= 1'b0;
            rb_hold <= 1'b0;
        end else begin
            // lights follow state map
            L_A <= la_next;
            L_B <= lb_next;

            // Capture RA/RB intent on entry to S0 (don’t assert yet)
            if (entering_S0_from_normal) begin
                ra_hold <= pa_served;
                rb_hold <= pb_served;
            end else if (entering_S0_from_err) begin
                ra_hold <= 1'b1;
                rb_hold <= 1'b1;
            end

            // Assert RA/RB only while actually in S0
            if (in_S0) begin
                RA <= ra_hold | force_ped_once;
                RB <= rb_hold | force_ped_once;
                if (tick_last) begin
                    ra_hold <= 1'b0;
                    rb_hold <= 1'b0;
                end
            end else begin
                RA <= 1'b0;
                RB <= 1'b0;
            end
        end
    end

endmodule
