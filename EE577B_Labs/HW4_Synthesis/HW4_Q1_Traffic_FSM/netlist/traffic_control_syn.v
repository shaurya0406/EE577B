/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : K-2015.06-SP5-5
// Date      : Tue Oct 14 22:47:28 2025
/////////////////////////////////////////////////////////////


module traffic_control ( CLK, reset, ERR, PA, PB, L_A, L_B, RA, RB );
  output [2:0] L_A;
  output [2:0] L_B;
  input CLK, reset, ERR, PA, PB;
  output RA, RB;
  wire   N96, N97, N100, N101, N102, N103, pa_req, pb_req, ret_sel,
         force_ped_once, pa_served, pb_served, N128, N129, N130, N131, N132,
         N133, N173, N174, N175, N176, N177, N178, N179, N180, N181, ra_hold,
         rb_hold, N275, N276, N277, N278, N279, N281, N282, n39, n40, n41, n43,
         n44, n45, n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56, n57,
         n58, n59, n60, n61, n62, n63, n64, n65, n66, n68, n69, n70, n71, n72,
         n73, n74, n75, n76, n77, n78, n79, n80, n81, n82, n83, n84, n85, n86,
         n87, n88, n89, n90, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100,
         n101, n102, n103, n104, n105, n106, n107, n108, n109, n110, n111,
         n112, n113, n114, n115, n116, sub_62_A_2_, n117, n118, n119, n120,
         n121, n122, n123, n124, n125, n126, n127, n128, n129, n130, n131,
         n132, n133, n134, n135, n136, n137, n138, n139, n140, n141, n142,
         n143, n144, n145, n146, n147, n148, n149, n150, n151, n152, n153,
         n154, n155, n156, n157, n158, n159, n160, n161, n162, n163, n164,
         n165, n166, n167, n168, n169, n170, n171, n172, n173, n174, n175,
         n176, n177, n178, n179, n180, n181, n182, n183, n184, n185, n186,
         n187, n188, n189, n190, n191, n192, n193, n194, n195, n196, n197,
         n198, n199, n200, n201, n202, n203, n204, n205, n206;
  wire   [2:0] state;
  wire   [5:0] tick;
  wire   [5:2] add_125_carry;

  DFFPOSX1 tick_reg_0_ ( .D(N176), .CLK(CLK), .Q(tick[0]) );
  DFFPOSX1 ret_sel_reg ( .D(n111), .CLK(CLK), .Q(ret_sel) );
  DFFPOSX1 state_reg_2_ ( .D(N175), .CLK(CLK), .Q(state[2]) );
  DFFPOSX1 state_reg_1_ ( .D(N174), .CLK(CLK), .Q(state[1]) );
  DFFPOSX1 state_reg_0_ ( .D(n163), .CLK(CLK), .Q(state[0]) );
  DFFPOSX1 force_ped_once_reg ( .D(n116), .CLK(CLK), .Q(force_ped_once) );
  DFFPOSX1 pa_req_reg ( .D(n115), .CLK(CLK), .Q(pa_req) );
  DFFPOSX1 pb_req_reg ( .D(n113), .CLK(CLK), .Q(pb_req) );
  DFFPOSX1 pb_served_reg ( .D(n129), .CLK(CLK), .Q(pb_served) );
  DFFPOSX1 pa_served_reg ( .D(n128), .CLK(CLK), .Q(pa_served) );
  DFFPOSX1 tick_reg_1_ ( .D(N177), .CLK(CLK), .Q(tick[1]) );
  DFFPOSX1 tick_reg_2_ ( .D(N178), .CLK(CLK), .Q(tick[2]) );
  DFFPOSX1 tick_reg_3_ ( .D(N179), .CLK(CLK), .Q(tick[3]) );
  DFFPOSX1 tick_reg_4_ ( .D(N180), .CLK(CLK), .Q(tick[4]) );
  DFFPOSX1 tick_reg_5_ ( .D(N181), .CLK(CLK), .Q(tick[5]) );
  DFFPOSX1 L_B_reg_2_ ( .D(n81), .CLK(CLK), .Q(L_B[2]) );
  DFFPOSX1 L_B_reg_1_ ( .D(N279), .CLK(CLK), .Q(L_B[1]) );
  DFFPOSX1 L_B_reg_0_ ( .D(n125), .CLK(CLK), .Q(L_B[0]) );
  DFFPOSX1 L_A_reg_2_ ( .D(n165), .CLK(CLK), .Q(L_A[2]) );
  DFFPOSX1 L_A_reg_1_ ( .D(N276), .CLK(CLK), .Q(L_A[1]) );
  DFFPOSX1 L_A_reg_0_ ( .D(N275), .CLK(CLK), .Q(L_A[0]) );
  DFFPOSX1 rb_hold_reg ( .D(n110), .CLK(CLK), .Q(rb_hold) );
  DFFPOSX1 ra_hold_reg ( .D(n109), .CLK(CLK), .Q(ra_hold) );
  DFFPOSX1 RA_reg ( .D(n126), .CLK(CLK), .Q(RA) );
  DFFPOSX1 RB_reg ( .D(n127), .CLK(CLK), .Q(RB) );
  AOI22X1 U49 ( .A(n40), .B(n204), .C(n61), .D(n206), .Y(n39) );
  AOI22X1 U50 ( .A(n40), .B(n203), .C(n61), .D(n205), .Y(n41) );
  OAI21X1 U51 ( .A(n197), .B(n151), .C(n134), .Y(n111) );
  NAND3X1 U52 ( .A(n49), .B(n151), .C(n44), .Y(n43) );
  AOI21X1 U54 ( .A(n44), .B(n48), .C(n117), .Y(n47) );
  NAND3X1 U55 ( .A(n196), .B(n48), .C(n50), .Y(n45) );
  NAND3X1 U56 ( .A(n139), .B(n150), .C(n143), .Y(n112) );
  NAND3X1 U58 ( .A(n62), .B(n40), .C(pb_req), .Y(n51) );
  OAI21X1 U59 ( .A(n54), .B(n161), .C(n136), .Y(n113) );
  NAND3X1 U62 ( .A(n138), .B(n150), .C(n142), .Y(n114) );
  NAND3X1 U64 ( .A(n149), .B(n194), .C(n62), .Y(n52) );
  NAND3X1 U66 ( .A(n62), .B(n40), .C(pa_req), .Y(n59) );
  OAI21X1 U67 ( .A(n63), .B(n161), .C(n135), .Y(n115) );
  NAND3X1 U70 ( .A(n194), .B(n181), .C(n162), .Y(n55) );
  NOR3X1 U73 ( .A(n155), .B(n68), .C(n144), .Y(n40) );
  NAND3X1 U74 ( .A(n195), .B(n181), .C(n169), .Y(n69) );
  OAI21X1 U75 ( .A(n189), .B(n168), .C(n164), .Y(n116) );
  NAND3X1 U78 ( .A(n174), .B(n181), .C(n49), .Y(n73) );
  OAI21X1 U81 ( .A(state[2]), .B(state[0]), .C(N100), .Y(N97) );
  NAND3X1 U82 ( .A(n180), .B(n177), .C(n171), .Y(N96) );
  AOI21X1 U84 ( .A(n205), .B(n201), .C(n179), .Y(N282) );
  AOI21X1 U85 ( .A(n206), .B(n201), .C(n179), .Y(N281) );
  OAI21X1 U86 ( .A(n117), .B(n182), .C(n190), .Y(N279) );
  AOI21X1 U87 ( .A(n82), .B(n177), .C(n117), .Y(N278) );
  AOI21X1 U88 ( .A(n180), .B(n82), .C(n117), .Y(N277) );
  OAI21X1 U89 ( .A(n117), .B(n173), .C(n146), .Y(N276) );
  NAND3X1 U91 ( .A(n182), .B(n177), .C(n84), .Y(n83) );
  NAND3X1 U92 ( .A(n199), .B(n198), .C(state[0]), .Y(n76) );
  OAI21X1 U93 ( .A(n85), .B(n117), .C(n179), .Y(N275) );
  NAND3X1 U95 ( .A(n87), .B(n88), .C(n49), .Y(n86) );
  XOR2X1 U96 ( .A(n198), .B(n155), .Y(n88) );
  XOR2X1 U97 ( .A(n200), .B(n89), .Y(n87) );
  AOI22X1 U99 ( .A(state[2]), .B(n141), .C(ret_sel), .D(n72), .Y(n91) );
  NAND3X1 U101 ( .A(state[2]), .B(n199), .C(state[0]), .Y(n78) );
  NOR3X1 U103 ( .A(n200), .B(n175), .C(n180), .Y(n44) );
  OAI21X1 U104 ( .A(n140), .B(n199), .C(n133), .Y(n68) );
  NAND3X1 U105 ( .A(n196), .B(n199), .C(state[0]), .Y(n96) );
  AOI21X1 U106 ( .A(n175), .B(n198), .C(n137), .Y(n95) );
  OAI21X1 U111 ( .A(ret_sel), .B(n174), .C(n159), .Y(n89) );
  AOI21X1 U112 ( .A(n196), .B(n100), .C(n101), .Y(n99) );
  NOR3X1 U113 ( .A(n200), .B(n196), .C(n166), .Y(n101) );
  OAI21X1 U114 ( .A(n48), .B(n160), .C(n85), .Y(n100) );
  NAND3X1 U115 ( .A(n200), .B(n199), .C(state[2]), .Y(n75) );
  NAND3X1 U120 ( .A(n199), .B(n198), .C(n200), .Y(n70) );
  NAND3X1 U121 ( .A(n176), .B(n103), .C(n104), .Y(n94) );
  NOR3X1 U122 ( .A(n105), .B(n186), .C(n106), .Y(n104) );
  XOR2X1 U123 ( .A(tick[3]), .B(N103), .Y(n106) );
  XNOR2X1 U124 ( .A(tick[2]), .B(N102), .Y(n103) );
  XOR2X1 U126 ( .A(tick[0]), .B(N100), .Y(n108) );
  XOR2X1 U127 ( .A(tick[1]), .B(N101), .Y(n107) );
  HAX1 add_125_U1_1_1 ( .A(tick[1]), .B(tick[0]), .YC(add_125_carry[2]), .YS(
        N129) );
  HAX1 add_125_U1_1_2 ( .A(tick[2]), .B(add_125_carry[2]), .YC(
        add_125_carry[3]), .YS(N130) );
  HAX1 add_125_U1_1_3 ( .A(tick[3]), .B(add_125_carry[3]), .YC(
        add_125_carry[4]), .YS(N131) );
  HAX1 add_125_U1_1_4 ( .A(tick[4]), .B(add_125_carry[4]), .YC(
        add_125_carry[5]), .YS(N132) );
  AND2X1 U129 ( .A(n182), .B(n173), .Y(n183) );
  AND2X1 U130 ( .A(n145), .B(n175), .Y(n93) );
  OR2X1 U131 ( .A(n180), .B(state[0]), .Y(n98) );
  AND2X1 U132 ( .A(n98), .B(n182), .Y(n85) );
  AND2X1 U133 ( .A(n173), .B(n169), .Y(n82) );
  AND2X1 U134 ( .A(n124), .B(n62), .Y(n109) );
  AND2X1 U135 ( .A(n123), .B(n62), .Y(n110) );
  AND2X1 U136 ( .A(n147), .B(n132), .Y(n54) );
  AND2X1 U137 ( .A(n147), .B(n131), .Y(n63) );
  OR2X1 U138 ( .A(n117), .B(n155), .Y(N175) );
  AND2X1 U139 ( .A(n49), .B(n130), .Y(n81) );
  AND2X1 U140 ( .A(state[0]), .B(n166), .Y(n46) );
  AND2X1 U141 ( .A(n193), .B(n192), .Y(n49) );
  INVX1 U142 ( .A(n49), .Y(n117) );
  BUFX2 U143 ( .A(n91), .Y(n118) );
  BUFX2 U144 ( .A(n86), .Y(n119) );
  BUFX2 U145 ( .A(n73), .Y(n120) );
  BUFX2 U146 ( .A(n45), .Y(n121) );
  BUFX2 U147 ( .A(n47), .Y(n122) );
  OR2X1 U148 ( .A(n153), .B(n154), .Y(n151) );
  OR2X1 U149 ( .A(n152), .B(n46), .Y(n154) );
  OR2X1 U150 ( .A(n90), .B(n158), .Y(n155) );
  OR2X1 U151 ( .A(n156), .B(n157), .Y(n158) );
  AND2X1 U152 ( .A(n44), .B(n202), .Y(n90) );
  BUFX2 U153 ( .A(n41), .Y(n123) );
  BUFX2 U154 ( .A(n39), .Y(n124) );
  BUFX2 U155 ( .A(N278), .Y(n125) );
  BUFX2 U156 ( .A(N281), .Y(n126) );
  BUFX2 U157 ( .A(N282), .Y(n127) );
  BUFX2 U158 ( .A(n114), .Y(n128) );
  BUFX2 U159 ( .A(n112), .Y(n129) );
  BUFX2 U160 ( .A(n83), .Y(n130) );
  AND2X1 U161 ( .A(PA), .B(n191), .Y(n65) );
  INVX1 U162 ( .A(n65), .Y(n131) );
  AND2X1 U163 ( .A(PB), .B(n191), .Y(n58) );
  INVX1 U164 ( .A(n58), .Y(n132) );
  BUFX2 U165 ( .A(n96), .Y(n133) );
  BUFX2 U166 ( .A(n43), .Y(n134) );
  AND2X1 U167 ( .A(n63), .B(pa_req), .Y(n64) );
  INVX1 U168 ( .A(n64), .Y(n135) );
  AND2X1 U169 ( .A(n54), .B(pb_req), .Y(n56) );
  INVX1 U170 ( .A(n56), .Y(n136) );
  AND2X1 U171 ( .A(n98), .B(n148), .Y(n97) );
  INVX1 U172 ( .A(n97), .Y(n137) );
  BUFX2 U173 ( .A(n59), .Y(n138) );
  BUFX2 U174 ( .A(n51), .Y(n139) );
  BUFX2 U175 ( .A(n95), .Y(n140) );
  AND2X1 U176 ( .A(n182), .B(n148), .Y(n92) );
  INVX1 U177 ( .A(n92), .Y(n141) );
  AND2X1 U178 ( .A(pa_served), .B(n61), .Y(n60) );
  INVX1 U179 ( .A(n60), .Y(n142) );
  AND2X1 U180 ( .A(pb_served), .B(n61), .Y(n53) );
  INVX1 U181 ( .A(n53), .Y(n143) );
  BUFX2 U182 ( .A(n69), .Y(n144) );
  AND2X1 U183 ( .A(n160), .B(n169), .Y(n84) );
  INVX1 U184 ( .A(n84), .Y(n145) );
  INVX1 U185 ( .A(n81), .Y(n146) );
  OR2X1 U186 ( .A(n117), .B(n40), .Y(n57) );
  INVX1 U187 ( .A(n57), .Y(n147) );
  INVX1 U188 ( .A(n93), .Y(n148) );
  AND2X1 U189 ( .A(n189), .B(n194), .Y(n61) );
  INVX1 U190 ( .A(n61), .Y(n149) );
  BUFX2 U191 ( .A(n52), .Y(n150) );
  INVX1 U192 ( .A(n122), .Y(n152) );
  INVX1 U193 ( .A(n121), .Y(n153) );
  INVX1 U194 ( .A(n118), .Y(n156) );
  INVX1 U195 ( .A(n177), .Y(n157) );
  BUFX2 U196 ( .A(n99), .Y(n159) );
  AND2X1 U197 ( .A(n166), .B(n200), .Y(n50) );
  INVX1 U198 ( .A(n50), .Y(n160) );
  BUFX2 U199 ( .A(n55), .Y(n161) );
  OR2X1 U200 ( .A(sub_62_A_2_), .B(n117), .Y(n66) );
  INVX1 U201 ( .A(n66), .Y(n162) );
  AND2X1 U202 ( .A(n49), .B(n195), .Y(N173) );
  INVX1 U203 ( .A(N173), .Y(n163) );
  AND2X1 U204 ( .A(force_ped_once), .B(n189), .Y(n71) );
  INVX1 U205 ( .A(n71), .Y(n164) );
  BUFX2 U206 ( .A(N277), .Y(n165) );
  OR2X1 U207 ( .A(n198), .B(n199), .Y(n74) );
  INVX1 U208 ( .A(n74), .Y(n166) );
  AND2X1 U209 ( .A(n185), .B(n183), .Y(n186) );
  INVX1 U210 ( .A(n186), .Y(n167) );
  AND2X1 U211 ( .A(n49), .B(n174), .Y(n62) );
  INVX1 U212 ( .A(n62), .Y(n168) );
  BUFX2 U213 ( .A(n70), .Y(n169) );
  BUFX2 U214 ( .A(N96), .Y(n170) );
  AND2X1 U215 ( .A(state[1]), .B(n200), .Y(n79) );
  INVX1 U216 ( .A(n79), .Y(n171) );
  AND2X1 U217 ( .A(n184), .B(n169), .Y(n185) );
  INVX1 U218 ( .A(n185), .Y(n172) );
  BUFX2 U219 ( .A(n76), .Y(n173) );
  AND2X1 U220 ( .A(n196), .B(sub_62_A_2_), .Y(n72) );
  INVX1 U221 ( .A(n72), .Y(n174) );
  BUFX2 U222 ( .A(n94), .Y(n175) );
  OR2X1 U223 ( .A(n107), .B(n108), .Y(n102) );
  INVX1 U224 ( .A(n102), .Y(n176) );
  BUFX2 U225 ( .A(n78), .Y(n177) );
  AND2X1 U226 ( .A(n187), .B(N100), .Y(n184) );
  INVX1 U227 ( .A(n184), .Y(n178) );
  AND2X1 U228 ( .A(n49), .B(sub_62_A_2_), .Y(n80) );
  INVX1 U229 ( .A(n80), .Y(n179) );
  AND2X1 U230 ( .A(state[1]), .B(n198), .Y(n77) );
  INVX1 U231 ( .A(n77), .Y(n180) );
  INVX1 U232 ( .A(n46), .Y(n181) );
  BUFX2 U233 ( .A(n75), .Y(n182) );
  INVX1 U234 ( .A(n161), .Y(n191) );
  INVX1 U235 ( .A(n40), .Y(n194) );
  INVX1 U236 ( .A(n169), .Y(sub_62_A_2_) );
  INVX1 U237 ( .A(n165), .Y(n190) );
  INVX1 U238 ( .A(n119), .Y(n188) );
  INVX1 U239 ( .A(n120), .Y(n189) );
  OR2X1 U240 ( .A(n117), .B(n68), .Y(N174) );
  AND2X1 U241 ( .A(N132), .B(n188), .Y(N180) );
  AND2X1 U242 ( .A(N131), .B(n188), .Y(N179) );
  AND2X1 U243 ( .A(N130), .B(n188), .Y(N178) );
  AND2X1 U244 ( .A(N129), .B(n188), .Y(N177) );
  INVX1 U245 ( .A(n175), .Y(n196) );
  INVX1 U246 ( .A(n89), .Y(n195) );
  INVX1 U247 ( .A(n170), .Y(N100) );
  INVX1 U248 ( .A(ret_sel), .Y(n197) );
  INVX1 U249 ( .A(reset), .Y(n192) );
  INVX1 U250 ( .A(ERR), .Y(n193) );
  INVX1 U251 ( .A(pa_served), .Y(n204) );
  INVX1 U252 ( .A(pb_served), .Y(n203) );
  AND2X1 U253 ( .A(N133), .B(n188), .Y(N181) );
  AND2X1 U254 ( .A(N128), .B(n188), .Y(N176) );
  INVX1 U255 ( .A(tick[0]), .Y(N128) );
  INVX1 U256 ( .A(n48), .Y(n202) );
  INVX1 U257 ( .A(state[0]), .Y(n200) );
  INVX1 U258 ( .A(state[2]), .Y(n198) );
  INVX1 U259 ( .A(state[1]), .Y(n199) );
  OR2X1 U260 ( .A(pb_req), .B(pa_req), .Y(n48) );
  INVX1 U261 ( .A(N97), .Y(n187) );
  OR2X1 U262 ( .A(tick[5]), .B(tick[4]), .Y(n105) );
  INVX1 U263 ( .A(force_ped_once), .Y(n201) );
  INVX1 U264 ( .A(rb_hold), .Y(n205) );
  INVX1 U265 ( .A(ra_hold), .Y(n206) );
  OAI21X1 U266 ( .A(N100), .B(n187), .C(n178), .Y(N101) );
  OAI21X1 U267 ( .A(n184), .B(n169), .C(n172), .Y(N102) );
  OAI21X1 U268 ( .A(n185), .B(n183), .C(n167), .Y(N103) );
  XOR2X1 U269 ( .A(add_125_carry[5]), .B(tick[5]), .Y(N133) );
endmodule

