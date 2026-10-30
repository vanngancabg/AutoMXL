; ======================================================================
========
; UI: TAB 1 - BUFF
; ======================================================================
========
Gui, Main:Tab, 1
; Khung 1. BUFF SET PHỤ
Gui, Main:Add, Progress, x6 y66 w250 h185 BackgroundEDFFF1 Disabled, 0
Gui, Main:Font, s10 Bold c004CFF
Gui, Main:Add, GroupBox, x6 y66 w250 h185, 1. BUFF SET PHỤ
Gui, Main:Font, s9 Norm cDefault
Gui, Main:Add, Text, BackgroundTrans x17 y94 w68, Chuyển set:
Gui, Main:Add, Edit, x88 y90 w54 h20 vZSetKey, None
Gui, Main:Add, Text, BackgroundTrans x149 y94 w35, Delay:
Gui, Main:Add, Edit, x187 y90 w54 h20 vZSetDelay, 500
Gui, Main:Add, Text, BackgroundTrans x17 y124 w68, Kill 1:
Gui, Main:Add, Edit, x88 y120 w54 h20 vZKeyF1, None
Gui, Main:Add, Text, BackgroundTrans x149 y124 w35, Delay:
Gui, Main:Add, Edit, x187 y120 w54 h20 vZDelay1, 500
Gui, Main:Add, Text, BackgroundTrans x17 y154 w68, Kill 2:
Gui, Main:Add, Edit, x88 y150 w54 h20 vZKeyF2, None
Gui, Main:Add, Text, BackgroundTrans x149 y154 w35, Delay:
Gui, Main:Add, Edit, x187 y150 w54 h20 vZDelay2, 500
Gui, Main:Add, Text, BackgroundTrans x17 y186 w88, Phím chạy set:
Gui, Main:Add, Edit, x105 y182 w136 h20 vZRunKey, B
Gui, Main:Add, Text, BackgroundTrans x17 y216 w224 h20 vBuffSetLeftInfo, Kill trái: chưa
GET
; Khung 2. BUFF NHANH

Gui, Main:Add, Progress, x6 y258 w250 h113 BackgroundFFF3E9 Disabled, 0
Gui, Main:Font, s10 Bold c004CFF
Gui, Main:Add, GroupBox, x6 y258 w250 h113, 2. BUFF NHANH
Gui, Main:Font, s9 Norm cDefault
Gui, Main:Add, Text, BackgroundTrans x17 y292 w68, Phím buff:
Gui, Main:Add, Edit, x88 y288 w153 h20 vXKey, F3
Gui, Main:Add, Text, BackgroundTrans x17 y322 w68, Delay:
Gui, Main:Add, Edit, x88 y318 w65 h20 vXDelay, 200
Gui, Main:Add, Text, BackgroundTrans x17 y348 w224 h18 Center, Chạy 4 -&gt; 5 -&gt; 6 (chạy 1
lần)
; Khung 4. PHÍM CAST
Gui, Main:Add, Progress, x263 y66 w190 h139 BackgroundF4EEFF Disabled, 0
Gui, Main:Font, s10 Bold c004CFF
Gui, Main:Add, GroupBox, x263 y66 w190 h139, 4. PHÍM CAST
Gui, Main:Font, s9 Norm cDefault
Gui, Main:Add, Text, BackgroundTrans x272 y87 w172 Center, Chỉ bấm phím
Loop, 3 {
yy := 110 + ((A_Index - 1) * 29)
Gui, Main:Add, Text, BackgroundTrans x272 y%yy% w23 Center, %A_Index%
Gui, Main:Add, Edit, x299 y%yy% w63 h20 vQCastKey%A_Index%,
Gui, Main:Add, Text, BackgroundTrans x366 y%yy% w34, Delay:
Gui, Main:Add, Edit, x402 y%yy% w41 h20 vQCastDelay%A_Index%, 20000
}
