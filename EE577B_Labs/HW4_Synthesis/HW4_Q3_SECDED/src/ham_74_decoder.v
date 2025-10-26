//* ------------------------------
//* Hamming(7,4) SEC-DED Decoder
//* Inputs:  c[7:0]  (with overall parity at bit 7)
//* Outputs: qc[7:0] corrected SEC-DED codeword,
//*          qd[3:0] corrected data word,
//*          x       double-error flag (1 => detected uncorrectable error)
//* Behavior:
//*  if (overall_parity==1 && syndrome!=0) -> single-bit error in positions 1..7 -> correct
//*  if (overall_parity==1 && syndrome==0) -> error only in overall parity bit -> correct c[7]
//*  if (overall_parity==0 && syndrome!=0) -> double-bit error -> flag x=1, leave bits unmodified
//*  if (overall_parity==0 && syndrome==0) -> no error
//* ------------------------------

module ham_74_decoder (
    input  [7:0] c,        // received SEC-DED codeword
    output [7:0] qc,       // corrected SEC-DED codeword
    output [3:0] qd,       // corrected data word
    output       x         // double-error flag
);
    wire [6:0] r = c[6:0];

    // syndrome s = H * r  (H rows: [1 0 1 0 1 0 1],
    //                               [0 1 1 0 0 1 1],
    //                               [0 0 0 1 1 1 1])
    wire s0 = r[0] ^ r[2] ^ r[4] ^ r[6];                // for positions with bit-0=1
    wire s1 = r[1] ^ r[2] ^ r[5] ^ r[6];                // for positions with bit-1=1
    wire s2 = r[3] ^ r[4] ^ r[5] ^ r[6];                // for positions with bit-2=1
    wire [2:0] syn = {s2,s1,s0};                        // binary index (1..7) when nonzero

    // overall parity over all 8 bits (even expected)
    wire overall = ^c;                                  // 1 => odd => some odd number of flips

    // correct single-bit errors in positions 1..7
    reg [6:0] corr7;
    always @* begin
        corr7 = r;
        if (overall && syn!=3'b000) begin
            // flip the indicated bit (syn encodes 1..7)
            case (syn)
                3'd1: corr7[0] = ~r[0];
                3'd2: corr7[1] = ~r[1];
                3'd3: corr7[2] = ~r[2];
                3'd4: corr7[3] = ~r[3];
                3'd5: corr7[4] = ~r[4];
                3'd6: corr7[5] = ~r[5];
                3'd7: corr7[6] = ~r[6];
                default: corr7 = r;
            endcase
        end
    end

    // overall bit correction (if only c[7] is wrong)
    wire corr_overall = (overall && (syn==3'b000)) ? ~c[7] : c[7];

    // double-error detect: even overall parity but nonzero syndrome
    assign x  = (~overall && (syn!=3'b000));

    assign qc[6:0] = corr7;
    assign qc[7]   = corr_overall;

    // extract corrected data bits (positions 3,5,6,7)
    assign qd = { qc[6], qc[5], qc[4], qc[2] };
endmodule
