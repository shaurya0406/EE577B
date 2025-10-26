/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : K-2015.06-SP5-5
// Date      : Tue Oct 14 16:18:25 2025
/////////////////////////////////////////////////////////////


module ham_74_decoder ( c, qc, qd, x );
  input [7:0] c;
  output [7:0] qc;
  output [3:0] qd;
  output x;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n32, n33, n34, n35, n36;
  assign qd[3] = qc[6];
  assign qd[2] = qc[5];
  assign qd[1] = qc[4];
  assign qd[0] = qc[2];

  NOR2X1 U9 ( .A(n4), .B(n1), .Y(x) );
  XNOR2X1 U10 ( .A(c[7]), .B(n33), .Y(qc[7]) );
  XNOR2X1 U12 ( .A(c[6]), .B(n29), .Y(qc[6]) );
  XNOR2X1 U14 ( .A(c[5]), .B(n30), .Y(qc[5]) );
  XNOR2X1 U16 ( .A(c[4]), .B(n31), .Y(qc[4]) );
  XNOR2X1 U18 ( .A(c[3]), .B(n34), .Y(qc[3]) );
  XNOR2X1 U21 ( .A(c[2]), .B(n35), .Y(qc[2]) );
  XNOR2X1 U23 ( .A(c[1]), .B(n27), .Y(qc[1]) );
  XNOR2X1 U25 ( .A(c[0]), .B(n28), .Y(qc[0]) );
  XNOR2X1 U28 ( .A(c[6]), .B(n22), .Y(n10) );
  XNOR2X1 U29 ( .A(n23), .B(c[2]), .Y(n12) );
  FAX1 U30 ( .A(n22), .B(n25), .C(n23), .YS(n24) );
  XNOR2X1 U31 ( .A(c[1]), .B(n26), .Y(n23) );
  XOR2X1 U32 ( .A(c[7]), .B(c[3]), .Y(n25) );
  FAX1 U33 ( .A(c[4]), .B(c[2]), .C(c[0]), .YS(n22) );
  FAX1 U34 ( .A(c[4]), .B(n26), .C(c[3]), .YS(n16) );
  XOR2X1 U35 ( .A(c[5]), .B(c[6]), .Y(n26) );
  AND2X1 U36 ( .A(n32), .B(n3), .Y(n4) );
  AND2X1 U37 ( .A(n11), .B(n32), .Y(n15) );
  AND2X1 U38 ( .A(n18), .B(n10), .Y(n19) );
  INVX1 U39 ( .A(n19), .Y(n27) );
  AND2X1 U40 ( .A(n20), .B(n36), .Y(n21) );
  INVX1 U41 ( .A(n21), .Y(n28) );
  AND2X1 U42 ( .A(n8), .B(n2), .Y(n7) );
  INVX1 U43 ( .A(n7), .Y(n29) );
  AND2X1 U44 ( .A(n8), .B(n10), .Y(n9) );
  INVX1 U45 ( .A(n9), .Y(n30) );
  AND2X1 U46 ( .A(n36), .B(n11), .Y(n13) );
  INVX1 U47 ( .A(n13), .Y(n31) );
  OR2X1 U48 ( .A(n2), .B(n12), .Y(n6) );
  INVX1 U49 ( .A(n6), .Y(n32) );
  AND2X1 U50 ( .A(n4), .B(n1), .Y(n5) );
  INVX1 U51 ( .A(n5), .Y(n33) );
  INVX1 U52 ( .A(n15), .Y(n34) );
  AND2X1 U53 ( .A(n18), .B(n2), .Y(n17) );
  INVX1 U54 ( .A(n17), .Y(n35) );
  OR2X1 U55 ( .A(n12), .B(n10), .Y(n14) );
  INVX1 U56 ( .A(n14), .Y(n36) );
  INVX1 U57 ( .A(n10), .Y(n2) );
  AND2X1 U58 ( .A(n16), .B(n1), .Y(n11) );
  AND2X1 U59 ( .A(n20), .B(n12), .Y(n18) );
  AND2X1 U60 ( .A(n11), .B(n12), .Y(n8) );
  AND2X1 U61 ( .A(n3), .B(n1), .Y(n20) );
  INVX1 U62 ( .A(n16), .Y(n3) );
  INVX1 U63 ( .A(n24), .Y(n1) );
endmodule

