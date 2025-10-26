/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : K-2015.06-SP5-5
// Date      : Tue Oct 14 23:05:00 2025
/////////////////////////////////////////////////////////////


module traffic_control ( CLK, reset, ERR, PA, PB, L_A, L_B, RA, RB );
  output [2:0] L_A;
  output [2:0] L_B;
  input CLK, reset, ERR, PA, PB;
  output RA, RB;
  wire   N62, N63, N65, N66, N67, N68, N69, ret_sel, pa_req, pb_req,
         force_ped_once, pa_served, pb_served, N163, N164, N165, N166, N167,
         N168, N203, N204, N205, N206, N207, N208, N209, N210, N211, N212,
         N213, N214, N215, N216, ra_hold, rb_hold, N249, N250, N252, N253,
         N255, N256, n39, n40, n41, n42, n43, n44, n45, n46, n47, n48, n49,
         n51, n52, n53, n54, n55, n56, n57, n58, n60, n61, n62, n63, n64, n65,
         n66, n68, n69, n70, n71, n72, n73, n75, n76, n77, n78, n79, n81, n82,
         n83, n84, n85, n86, n87, n88, n89, n90, n91, n92, n93, n94, n95, n96,
         n97, n98, n99, n100, n102, n103, n105, n106, n107, n108, n109, n110,
         n111, n112, n113, n114, n115, n116, n117, n118, n119, n120, n121,
         n122, n123, n124, n125, n126, n127, n128, n129, n130, n131, n132,
         n133, n134, n135, n136, n137, n138, n139, n140, n141, n142, n143,
         n144, n145, n146, n147, n148, n149, n150, n151, n152, n153, n154,
         n155, n156, n157, n158, n159, n160, n161, n162, n163, n164, n165,
         n166, n167, n168, n169, n170, n171, n172, n173, n174, n175, n176,
         n177, n178, n179, n180, n181, n182, n183, n184, n185, n186, n187,
         n188, n189, n190, n191, n192, n193, n194, n195, n196, n197, n198,
         n199, n200, n201, n202, n203, n204, n205, n206, n207, n208, n209,
         n210, n211, n212, n213, n214, n215, n216, n217, n218, n219, n220,
         n221, n222, n223, n224, n225, n226, n227, n228, n229, n230, n231,
         n232, n233, n234, n235, n236, n237, n238, n239, n240, n241, n242,
         n243, n244, n245, n246, n247, n248, n249, n250, n251, n252, n253,
         n254, n255, n256, n257;
  wire   [7:0] state;
  wire   [5:0] tick;
  wire   [5:2] add_452_carry;

  DFFPOSX1 tick_reg_0_ ( .D(N211), .CLK(CLK), .Q(tick[0]) );
  DFFPOSX1 state_reg_3_ ( .D(n146), .CLK(CLK), .Q(state[3]) );
  DFFPOSX1 state_reg_0_ ( .D(N203), .CLK(CLK), .Q(state[0]) );
  DFFPOSX1 ret_sel_reg ( .D(n135), .CLK(CLK), .Q(ret_sel) );
  DFFPOSX1 state_reg_4_ ( .D(N207), .CLK(CLK), .Q(state[4]) );
  DFFPOSX1 state_reg_5_ ( .D(N208), .CLK(CLK), .Q(state[5]) );
  DFFPOSX1 state_reg_6_ ( .D(n147), .CLK(CLK), .Q(state[6]) );
  DFFPOSX1 state_reg_1_ ( .D(N204), .CLK(CLK), .Q(state[1]) );
  DFFPOSX1 state_reg_2_ ( .D(N205), .CLK(CLK), .Q(state[2]) );
  DFFPOSX1 pb_req_reg ( .D(n136), .CLK(CLK), .Q(pb_req) );
  DFFPOSX1 pa_req_reg ( .D(n137), .CLK(CLK), .Q(pa_req) );
  DFFPOSX1 state_reg_7_ ( .D(n152), .CLK(CLK), .Q(state[7]) );
  DFFPOSX1 pa_served_reg ( .D(n150), .CLK(CLK), .Q(pa_served) );
  DFFPOSX1 tick_reg_1_ ( .D(N212), .CLK(CLK), .Q(tick[1]) );
  DFFPOSX1 tick_reg_2_ ( .D(N213), .CLK(CLK), .Q(tick[2]) );
  DFFPOSX1 tick_reg_3_ ( .D(N214), .CLK(CLK), .Q(tick[3]) );
  DFFPOSX1 tick_reg_4_ ( .D(N215), .CLK(CLK), .Q(tick[4]) );
  DFFPOSX1 tick_reg_5_ ( .D(N216), .CLK(CLK), .Q(tick[5]) );
  DFFPOSX1 force_ped_once_reg ( .D(n133), .CLK(CLK), .Q(force_ped_once) );
  DFFPOSX1 pb_served_reg ( .D(n151), .CLK(CLK), .Q(pb_served) );
  DFFPOSX1 L_B_reg_2_ ( .D(n242), .CLK(CLK), .Q(L_B[2]) );
  DFFPOSX1 L_B_reg_1_ ( .D(N253), .CLK(CLK), .Q(L_B[1]) );
  DFFPOSX1 L_B_reg_0_ ( .D(n149), .CLK(CLK), .Q(L_B[0]) );
  DFFPOSX1 L_A_reg_2_ ( .D(n243), .CLK(CLK), .Q(L_A[2]) );
  DFFPOSX1 L_A_reg_1_ ( .D(N250), .CLK(CLK), .Q(L_A[1]) );
  DFFPOSX1 L_A_reg_0_ ( .D(n148), .CLK(CLK), .Q(L_A[0]) );
  DFFPOSX1 rb_hold_reg ( .D(n131), .CLK(CLK), .Q(rb_hold) );
  DFFPOSX1 RB_reg ( .D(n154), .CLK(CLK), .Q(RB) );
  DFFPOSX1 ra_hold_reg ( .D(n130), .CLK(CLK), .Q(ra_hold) );
  DFFPOSX1 RA_reg ( .D(n153), .CLK(CLK), .Q(RA) );
  AOI22X1 U56 ( .A(n245), .B(n254), .C(n217), .D(n257), .Y(n39) );
  AOI22X1 U57 ( .A(n245), .B(n255), .C(n217), .D(n256), .Y(n41) );
  NAND3X1 U58 ( .A(n168), .B(n43), .C(n177), .Y(n132) );
  NAND3X1 U60 ( .A(n45), .B(n245), .C(pb_req), .Y(n42) );
  OAI21X1 U61 ( .A(n244), .B(n195), .C(n165), .Y(n133) );
  NAND3X1 U63 ( .A(n167), .B(n43), .C(n176), .Y(n134) );
  NAND3X1 U66 ( .A(n225), .B(n224), .C(n234), .Y(n47) );
  NAND3X1 U67 ( .A(n45), .B(n245), .C(pa_req), .Y(n48) );
  OAI21X1 U69 ( .A(n190), .B(n250), .C(n162), .Y(n135) );
  NAND3X1 U70 ( .A(n190), .B(n185), .C(n234), .Y(n55) );
  OAI21X1 U72 ( .A(n58), .B(n202), .C(n164), .Y(n136) );
  OAI21X1 U75 ( .A(n63), .B(n202), .C(n163), .Y(n137) );
  NAND3X1 U80 ( .A(n212), .B(n225), .C(n194), .Y(n53) );
  OAI21X1 U82 ( .A(force_ped_once), .B(rb_hold), .C(n211), .Y(n69) );
  OAI21X1 U84 ( .A(force_ped_once), .B(ra_hold), .C(n211), .Y(n70) );
  OAI21X1 U85 ( .A(n52), .B(n216), .C(n73), .Y(N253) );
  AOI21X1 U86 ( .A(n75), .B(n199), .C(n52), .Y(N252) );
  OAI21X1 U87 ( .A(n187), .B(n182), .C(n235), .Y(n73) );
  OAI21X1 U89 ( .A(n52), .B(n219), .C(n71), .Y(N250) );
  OAI21X1 U90 ( .A(n188), .B(n181), .C(n235), .Y(n71) );
  AOI21X1 U91 ( .A(n79), .B(n196), .C(n52), .Y(N249) );
  NAND3X1 U93 ( .A(n166), .B(n234), .C(n83), .Y(n81) );
  NOR3X1 U94 ( .A(n84), .B(n87), .C(n85), .Y(n83) );
  XOR2X1 U95 ( .A(n86), .B(state[1]), .Y(n85) );
  OAI21X1 U96 ( .A(state[0]), .B(n193), .C(n88), .Y(n84) );
  XOR2X1 U97 ( .A(n251), .B(n89), .Y(n88) );
  AOI22X1 U98 ( .A(n248), .B(state[5]), .C(n247), .D(state[2]), .Y(n82) );
  AOI21X1 U101 ( .A(n93), .B(n172), .C(n52), .Y(N209) );
  NAND3X1 U102 ( .A(n189), .B(n236), .C(state[6]), .Y(n94) );
  OAI21X1 U103 ( .A(n236), .B(n216), .C(n161), .Y(n91) );
  NAND3X1 U104 ( .A(N63), .B(n236), .C(state[5]), .Y(n97) );
  OAI21X1 U105 ( .A(n250), .B(n224), .C(n159), .Y(n89) );
  AOI22X1 U106 ( .A(n174), .B(n252), .C(n232), .D(state[4]), .Y(n98) );
  AOI21X1 U108 ( .A(n102), .B(n171), .C(n52), .Y(N206) );
  NAND3X1 U109 ( .A(n189), .B(n236), .C(state[3]), .Y(n103) );
  OAI21X1 U111 ( .A(n236), .B(n219), .C(n160), .Y(n90) );
  NAND3X1 U112 ( .A(N63), .B(n236), .C(state[2]), .Y(n105) );
  OAI21X1 U113 ( .A(ret_sel), .B(n224), .C(n158), .Y(n86) );
  AOI22X1 U114 ( .A(n173), .B(n252), .C(n232), .D(state[1]), .Y(n106) );
  NAND3X1 U117 ( .A(n170), .B(n225), .C(n57), .Y(n68) );
  NAND3X1 U118 ( .A(n246), .B(n108), .C(n140), .Y(n110) );
  NAND3X1 U119 ( .A(n246), .B(n108), .C(n141), .Y(n56) );
  NAND3X1 U123 ( .A(n169), .B(n114), .C(n115), .Y(n96) );
  NOR3X1 U124 ( .A(n116), .B(n239), .C(n117), .Y(n115) );
  XOR2X1 U125 ( .A(tick[3]), .B(N69), .Y(n117) );
  XNOR2X1 U126 ( .A(tick[2]), .B(N68), .Y(n114) );
  XOR2X1 U128 ( .A(tick[0]), .B(N66), .Y(n119) );
  XOR2X1 U129 ( .A(tick[1]), .B(N67), .Y(n118) );
  NAND3X1 U132 ( .A(n233), .B(n249), .C(n175), .Y(n72) );
  NAND3X1 U144 ( .A(n214), .B(n253), .C(n192), .Y(n122) );
  NAND3X1 U150 ( .A(n249), .B(n251), .C(n233), .Y(n128) );
  HAX1 add_452_U1_1_1 ( .A(tick[1]), .B(tick[0]), .YC(add_452_carry[2]), .YS(
        N164) );
  HAX1 add_452_U1_1_2 ( .A(tick[2]), .B(add_452_carry[2]), .YC(
        add_452_carry[3]), .YS(N165) );
  HAX1 add_452_U1_1_3 ( .A(tick[3]), .B(add_452_carry[3]), .YC(
        add_452_carry[4]), .YS(N166) );
  HAX1 add_452_U1_1_4 ( .A(tick[4]), .B(add_452_carry[4]), .YC(
        add_452_carry[5]), .YS(N167) );
  OR2X1 U154 ( .A(n187), .B(n188), .Y(N62) );
  OR2X1 U155 ( .A(N63), .B(n180), .Y(n92) );
  OR2X1 U156 ( .A(n183), .B(n246), .Y(n100) );
  OR2X1 U157 ( .A(n179), .B(n245), .Y(n40) );
  OR2X1 U158 ( .A(n225), .B(n195), .Y(n43) );
  AND2X1 U159 ( .A(n235), .B(n191), .Y(n61) );
  AND2X1 U160 ( .A(n145), .B(n45), .Y(n130) );
  AND2X1 U161 ( .A(n144), .B(n45), .Y(n131) );
  AND2X1 U162 ( .A(n61), .B(n156), .Y(n63) );
  AND2X1 U163 ( .A(n61), .B(n157), .Y(n58) );
  OR2X1 U164 ( .A(n199), .B(n236), .Y(n93) );
  AND2X1 U165 ( .A(n235), .B(n194), .Y(N203) );
  OR2X1 U166 ( .A(n196), .B(n236), .Y(n102) );
  OR2X1 U167 ( .A(n186), .B(state[0]), .Y(n111) );
  OR2X1 U168 ( .A(n184), .B(state[4]), .Y(n124) );
  AND2X1 U169 ( .A(n185), .B(n155), .Y(n57) );
  BUFX2 U170 ( .A(n81), .Y(n138) );
  OR2X1 U171 ( .A(n197), .B(n198), .Y(n196) );
  OR2X1 U172 ( .A(n127), .B(n111), .Y(n198) );
  OR2X1 U173 ( .A(n200), .B(n201), .Y(n199) );
  OR2X1 U174 ( .A(n126), .B(n124), .Y(n201) );
  OR2X1 U175 ( .A(n143), .B(n204), .Y(n203) );
  INVX1 U176 ( .A(n203), .Y(n139) );
  OR2X1 U177 ( .A(n66), .B(n245), .Y(n204) );
  OR2X1 U178 ( .A(n124), .B(n207), .Y(n206) );
  INVX1 U179 ( .A(n206), .Y(n140) );
  OR2X1 U180 ( .A(n249), .B(n120), .Y(n207) );
  OR2X1 U181 ( .A(n209), .B(n210), .Y(n208) );
  INVX1 U182 ( .A(n208), .Y(n141) );
  OR2X1 U183 ( .A(n125), .B(n124), .Y(n210) );
  OR2X1 U184 ( .A(n214), .B(n215), .Y(n213) );
  OR2X1 U185 ( .A(n129), .B(n112), .Y(n215) );
  OR2X1 U186 ( .A(n222), .B(n223), .Y(n221) );
  INVX1 U187 ( .A(n221), .Y(n142) );
  OR2X1 U188 ( .A(n123), .B(n111), .Y(n223) );
  OR2X1 U189 ( .A(n111), .B(n227), .Y(n226) );
  INVX1 U190 ( .A(n226), .Y(n143) );
  OR2X1 U191 ( .A(n253), .B(n112), .Y(n227) );
  OR2X1 U192 ( .A(state[7]), .B(n186), .Y(n129) );
  OR2X1 U193 ( .A(state[7]), .B(state[1]), .Y(n127) );
  OR2X1 U194 ( .A(state[6]), .B(state[3]), .Y(n126) );
  OR2X1 U195 ( .A(state[5]), .B(state[3]), .Y(n125) );
  OR2X1 U196 ( .A(state[7]), .B(state[2]), .Y(n123) );
  OR2X1 U197 ( .A(n211), .B(n52), .Y(n66) );
  BUFX2 U198 ( .A(n41), .Y(n144) );
  BUFX2 U199 ( .A(n39), .Y(n145) );
  BUFX2 U200 ( .A(N206), .Y(n146) );
  BUFX2 U201 ( .A(N209), .Y(n147) );
  BUFX2 U202 ( .A(N249), .Y(n148) );
  BUFX2 U203 ( .A(N252), .Y(n149) );
  BUFX2 U204 ( .A(n134), .Y(n150) );
  BUFX2 U205 ( .A(n132), .Y(n151) );
  AND2X1 U206 ( .A(n234), .B(n178), .Y(N210) );
  INVX1 U207 ( .A(N210), .Y(n152) );
  OR2X1 U208 ( .A(n52), .B(n70), .Y(N255) );
  INVX1 U209 ( .A(N255), .Y(n153) );
  OR2X1 U210 ( .A(n52), .B(n69), .Y(N256) );
  INVX1 U211 ( .A(N256), .Y(n154) );
  BUFX2 U212 ( .A(n110), .Y(n155) );
  AND2X1 U213 ( .A(PA), .B(n139), .Y(n65) );
  INVX1 U214 ( .A(n65), .Y(n156) );
  AND2X1 U215 ( .A(PB), .B(n139), .Y(n62) );
  INVX1 U216 ( .A(n62), .Y(n157) );
  BUFX2 U217 ( .A(n106), .Y(n158) );
  BUFX2 U218 ( .A(n98), .Y(n159) );
  BUFX2 U219 ( .A(n105), .Y(n160) );
  BUFX2 U220 ( .A(n97), .Y(n161) );
  BUFX2 U221 ( .A(n55), .Y(n162) );
  AND2X1 U222 ( .A(n63), .B(pa_req), .Y(n64) );
  INVX1 U223 ( .A(n64), .Y(n163) );
  AND2X1 U224 ( .A(n58), .B(pb_req), .Y(n60) );
  INVX1 U225 ( .A(n60), .Y(n164) );
  AND2X1 U226 ( .A(force_ped_once), .B(n244), .Y(n46) );
  INVX1 U227 ( .A(n46), .Y(n165) );
  BUFX2 U228 ( .A(n82), .Y(n166) );
  BUFX2 U229 ( .A(n48), .Y(n167) );
  BUFX2 U230 ( .A(n42), .Y(n168) );
  OR2X1 U231 ( .A(n118), .B(n119), .Y(n113) );
  INVX1 U232 ( .A(n113), .Y(n169) );
  AND2X1 U233 ( .A(n232), .B(state[0]), .Y(n109) );
  INVX1 U234 ( .A(n109), .Y(n170) );
  BUFX2 U235 ( .A(n103), .Y(n171) );
  BUFX2 U236 ( .A(n94), .Y(n172) );
  OR2X1 U237 ( .A(n236), .B(n208), .Y(n107) );
  INVX1 U238 ( .A(n107), .Y(n173) );
  OR2X1 U239 ( .A(n236), .B(n205), .Y(n99) );
  INVX1 U240 ( .A(n99), .Y(n174) );
  OR2X1 U241 ( .A(n184), .B(n251), .Y(n121) );
  INVX1 U242 ( .A(n121), .Y(n175) );
  AND2X1 U243 ( .A(pa_served), .B(n217), .Y(n49) );
  INVX1 U244 ( .A(n49), .Y(n176) );
  AND2X1 U245 ( .A(pb_served), .B(n217), .Y(n44) );
  INVX1 U246 ( .A(n44), .Y(n177) );
  AND2X1 U247 ( .A(n183), .B(n225), .Y(n87) );
  INVX1 U248 ( .A(n87), .Y(n178) );
  BUFX2 U249 ( .A(n47), .Y(n179) );
  AND2X1 U250 ( .A(n219), .B(n216), .Y(N65) );
  INVX1 U251 ( .A(N65), .Y(n180) );
  AND2X1 U252 ( .A(n216), .B(n213), .Y(n79) );
  INVX1 U253 ( .A(n79), .Y(n181) );
  AND2X1 U254 ( .A(n219), .B(n212), .Y(n75) );
  INVX1 U255 ( .A(n75), .Y(n182) );
  INVX1 U256 ( .A(n92), .Y(n183) );
  BUFX2 U257 ( .A(n122), .Y(n184) );
  BUFX2 U258 ( .A(n56), .Y(n185) );
  BUFX2 U259 ( .A(n128), .Y(n186) );
  AND2X1 U260 ( .A(n196), .B(n205), .Y(n76) );
  INVX1 U261 ( .A(n76), .Y(n187) );
  AND2X1 U262 ( .A(n199), .B(n208), .Y(n78) );
  INVX1 U263 ( .A(n78), .Y(n188) );
  AND2X1 U264 ( .A(n208), .B(n205), .Y(n95) );
  INVX1 U265 ( .A(n95), .Y(n189) );
  AND2X1 U266 ( .A(n234), .B(n57), .Y(n54) );
  INVX1 U267 ( .A(n54), .Y(n190) );
  BUFX2 U268 ( .A(n53), .Y(n191) );
  OR2X1 U269 ( .A(state[2]), .B(state[1]), .Y(n112) );
  INVX1 U270 ( .A(n112), .Y(n192) );
  INVX1 U271 ( .A(n194), .Y(n193) );
  BUFX2 U272 ( .A(n68), .Y(n194) );
  AND2X1 U273 ( .A(n235), .B(n224), .Y(n45) );
  INVX1 U274 ( .A(n45), .Y(n195) );
  INVX1 U275 ( .A(state[2]), .Y(n197) );
  INVX1 U276 ( .A(state[5]), .Y(n200) );
  INVX1 U277 ( .A(n139), .Y(n202) );
  INVX1 U278 ( .A(n140), .Y(n205) );
  INVX1 U279 ( .A(state[6]), .Y(n209) );
  INVX1 U280 ( .A(n212), .Y(n211) );
  BUFX2 U281 ( .A(n213), .Y(n212) );
  INVX1 U282 ( .A(state[0]), .Y(n214) );
  BUFX2 U283 ( .A(n72), .Y(n216) );
  INVX1 U284 ( .A(n40), .Y(n217) );
  INVX1 U285 ( .A(n220), .Y(n218) );
  INVX1 U286 ( .A(n218), .Y(n219) );
  BUFX2 U287 ( .A(n77), .Y(n220) );
  INVX1 U288 ( .A(n142), .Y(n77) );
  INVX1 U289 ( .A(state[1]), .Y(n222) );
  AND2X1 U290 ( .A(n246), .B(n211), .Y(n51) );
  INVX1 U291 ( .A(n51), .Y(n224) );
  INVX1 U292 ( .A(n143), .Y(n225) );
  AND2X1 U293 ( .A(n238), .B(N65), .Y(n239) );
  INVX1 U294 ( .A(n239), .Y(n228) );
  AND2X1 U295 ( .A(n237), .B(n212), .Y(n238) );
  INVX1 U296 ( .A(n238), .Y(n229) );
  OR2X1 U297 ( .A(ERR), .B(reset), .Y(n52) );
  INVX1 U298 ( .A(n52), .Y(n230) );
  AND2X1 U299 ( .A(n240), .B(N66), .Y(n237) );
  INVX1 U300 ( .A(n237), .Y(n231) );
  INVX1 U301 ( .A(n100), .Y(n232) );
  OR2X1 U302 ( .A(state[6]), .B(state[5]), .Y(n120) );
  INVX1 U303 ( .A(n120), .Y(n233) );
  INVX1 U304 ( .A(n73), .Y(n243) );
  INVX1 U305 ( .A(n71), .Y(n242) );
  INVX1 U306 ( .A(N62), .Y(N66) );
  INVX1 U307 ( .A(N63), .Y(n240) );
  INVX1 U308 ( .A(n191), .Y(n245) );
  OR2X1 U309 ( .A(n211), .B(N62), .Y(N63) );
  BUFX2 U310 ( .A(n230), .Y(n234) );
  BUFX2 U311 ( .A(n230), .Y(n235) );
  AND2X1 U312 ( .A(n235), .B(n89), .Y(N207) );
  AND2X1 U313 ( .A(n235), .B(n86), .Y(N204) );
  AND2X1 U314 ( .A(n235), .B(n90), .Y(N205) );
  AND2X1 U315 ( .A(n235), .B(n91), .Y(N208) );
  AND2X1 U316 ( .A(N167), .B(n241), .Y(N215) );
  AND2X1 U317 ( .A(N166), .B(n241), .Y(N214) );
  AND2X1 U318 ( .A(N165), .B(n241), .Y(N213) );
  AND2X1 U319 ( .A(N164), .B(n241), .Y(N212) );
  INVX1 U320 ( .A(n236), .Y(n246) );
  INVX1 U321 ( .A(n90), .Y(n247) );
  INVX1 U322 ( .A(n91), .Y(n248) );
  INVX1 U323 ( .A(n108), .Y(n252) );
  INVX1 U324 ( .A(n138), .Y(n241) );
  INVX1 U325 ( .A(n179), .Y(n244) );
  AND2X1 U326 ( .A(N168), .B(n241), .Y(N216) );
  AND2X1 U327 ( .A(N163), .B(n241), .Y(N211) );
  INVX1 U328 ( .A(tick[0]), .Y(N163) );
  INVX1 U329 ( .A(pa_served), .Y(n254) );
  INVX1 U330 ( .A(ra_hold), .Y(n257) );
  INVX1 U331 ( .A(pb_served), .Y(n255) );
  INVX1 U332 ( .A(rb_hold), .Y(n256) );
  OR2X1 U333 ( .A(tick[5]), .B(tick[4]), .Y(n116) );
  INVX1 U334 ( .A(state[7]), .Y(n253) );
  BUFX2 U335 ( .A(n96), .Y(n236) );
  OR2X1 U336 ( .A(pb_req), .B(pa_req), .Y(n108) );
  INVX1 U337 ( .A(state[4]), .Y(n251) );
  INVX1 U338 ( .A(state[3]), .Y(n249) );
  INVX1 U339 ( .A(ret_sel), .Y(n250) );
  OAI21X1 U340 ( .A(N66), .B(n240), .C(n231), .Y(N67) );
  OAI21X1 U341 ( .A(n237), .B(n213), .C(n229), .Y(N68) );
  OAI21X1 U342 ( .A(n238), .B(N65), .C(n228), .Y(N69) );
  XOR2X1 U343 ( .A(add_452_carry[5]), .B(tick[5]), .Y(N168) );
endmodule

