//* ------------------------------
//* Hamming(7,4) SEC-DED Encoder
//* c[7] = overall parity over c[6:0] (even parity)
//* x0..x6 positions: 1..7 (LSB=pos1)
//* Parity positions: 1,2,4  (x0,x1,x3)
//* Data positions:   3,5,6,7 (x2,x4,x5,x6)  <= d[0],d[1],d[2],d[3]
//* ------------------------------

module ham_74_encoder (
    input  [3:0] d,     // d[3] MSB
    output [7:0] c      // c[7] overall parity ; c[6:0] Hamming(7,4)
);
    wire [6:0] x;
    // place data
    assign x[2] = d[0];   // pos3
    assign x[4] = d[1];   // pos5
    assign x[5] = d[2];   // pos6
    assign x[6] = d[3];   // pos7

    // compute parity bits for even parity
    assign x[0] = x[2] ^ x[4] ^ x[6];            // p1 covers positions 1,3,5,7
    assign x[1] = x[2] ^ x[5] ^ x[6];            // p2 covers positions 2,3,6,7
    assign x[3] = x[4] ^ x[5] ^ x[6];            // p4 covers positions 4,5,6,7

    // overall even parity
    assign c[6:0] = x;
    assign c[7]   = ^x;     // XOR-reduction of x[6:0]
endmodule