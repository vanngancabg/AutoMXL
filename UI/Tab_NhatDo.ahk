; ======================================================================
========
; UI: TAB 2 - NHẶT ĐỒ
; ======================================================================
========
Gui, Main:Tab, 2
; Khung HP / MANA
Gui, Main:Add, Progress, x6 y66 w219 h500 BackgroundEAFCFF Disabled, 0
Gui, Main:Font, s10 Bold c004CFF
Gui, Main:Add, GroupBox, x6 y66 w219 h500, HP / MANA
Gui, Main:Font, s9 Bold cRed

Gui, Main:Add, Checkbox, BackgroundTrans -Theme x15 y93 w16 h15 vAutoPotOn,
Gui, Main:Add, Text, BackgroundTrans x33 y95 w174 h18, Buff HP Belt
Gui, Main:Font, s9 Norm cRed
Gui, Main:Add, Text, BackgroundTrans x15 y170 w42, Pot :
Gui, Main:Add, DropDownList, x92 y166 w115 vPotMode, 1|2|3|4|Auto(1-4)
Gui, Main:Add, Text, BackgroundTrans x15 y200 w74, Ngưỡng 1/2:
Gui, Main:Add, Edit, x92 y196 w50 h20 vPotHPThreshold, 4000
Gui, Main:Add, Text, BackgroundTrans x146 y200 w8, /
Gui, Main:Add, Edit, x157 y196 w50 h20 Number vPotHPThreshold2Input, 3000
; Khung NHẶT VẬT PHẨM
Gui, Main:Add, Progress, x235 y66 w219 h515 BackgroundEAFCFF Disabled, 0
Gui, Main:Font, s10 Bold c004CFF
Gui, Main:Add, GroupBox, x235 y66 w219 h515, NHẶT VẬT PHẨM
Gui, Main:Font, s9 Norm cBlue
Gui, Main:Add, Checkbox, BackgroundTrans -Theme x244 y94 w16 h15
vPickupEnabledInputV79 gPickupUiToggleV79,
Gui, Main:Add, Text, BackgroundTrans x262 y92 w30 h18, Nhặt
Gui, Main:Add, Edit, x299 y90 w42 h24 vPickupToggleKeyInputV79, N
Gui, Main:Add, Text, BackgroundTrans x348 y93 w55 h18, Bán kính:
Gui, Main:Add, Edit, x409 y90 w36 h24 vPickupRadius, 50
Gui, Main:Add, Checkbox, BackgroundTrans -Theme x244 y125 w16 h15
vPickupToCubeInputV37,
Gui, Main:Add, Text, BackgroundTrans x262 y124 w183 h18, Nhặt thẳng vào Cube
