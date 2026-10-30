; ==============================================================================
; AUTO DIABLO 2 MEDIAN XL - MODULAR EDITION (GSF)
; ==============================================================================
#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

; Nạp biến cấu hình từ Config.ini (giả lập nạp tĩnh)
global Config_HPThreshold := 5000
global Config_ManaThreshold := 1000
global Config_Cooldown := 3000
global Config_PickupRadius := 15
global Config_PickupDelay := 200
global Config_BuffKeys := ["F3", "F4", "F5", "F10"]
global Config_BuffDelays := [200, 200, 200, 3000]

; Đọc Item-Nhat.txt (Giả lập bộ lọc)
global Pickup_Filter := {1204: true, 1734: true, 1735: true} 

; Nạp Core
#Include %A_ScriptDir%\Core\GameOffsets.ahk
#Include %A_ScriptDir%\Core\MemoryEngine.ahk
#Include %A_ScriptDir%\Core\GameState.ahk

; Nạp Modules
#Include %A_ScriptDir%\Modules\AutoHeal.ahk
#Include %A_ScriptDir%\Modules\AutoPickup.ahk
#Include %A_ScriptDir%\Modules\AutoBuff.ahk
#Include %A_ScriptDir%\Modules\WebSync.ahk

$`:: AutoBuff_ToggleLoop()

Gui, Font, s10
Gui, Add, Text, w250 Center, D2MXL BOT - MODULAR
Gui, Add, Text, x10 y+15 w100, Máu (AutoHeal):
Gui, Add, Button, x+10 yp-3 w70 gStartHeal, Bật
Gui, Add, Button, x+10 yp w70 gStopHeal, Tắt
Gui, Add, Text, x10 y+15 w100, Nhặt đồ (Pickup):
Gui, Add, Button, x+10 yp-3 w70 gStartPickup, Bật
Gui, Add, Button, x+10 yp w70 gStopPickup, Tắt
Gui, Add, Text, x10 y+15 w250 cGray, (Bấm phím '`' để bật/tắt Auto Buff)
Gui, Show,, D2 Auto Tool
return

StartHeal:
    AutoHeal_Start()
return
StopHeal:
    AutoHeal_Stop()
return
StartPickup:
    AutoPickup_Start()
return
StopPickup:
    AutoPickup_Stop()
return
GuiClose:
    ExitApp
