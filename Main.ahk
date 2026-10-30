; ======================================================================
========
; AUTO-GSF V38 - REFACTORED MODULAR EDITION (By GSF Community)
; File chạy chính (Main.ahk)
; ======================================================================
========
#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Client
SetKeyDelay, 30, 30
; Đảm bảo chạy với quyền Admin như code gốc
if (!A_IsAdmin) {
Run, *RunAs &quot;%A_AhkPath%&quot; &quot;%A_ScriptFullPath%&quot;
ExitApp
}
; ======================================================================
========
; 1. KHỞI TẠO BIẾN &amp; ĐỌC CONFIG (Tương đương đoạn đầu của file gốc)
; ======================================================================
========
global ConfigFile := A_ScriptDir . &quot;\config.ini&quot;
global currentProfile := &quot;Assassin&quot;
global profileList := &quot;Assassin|Sorceress|Paladin|Default&quot;
; Các biến trạng thái toàn cục
global zRunning := false
global xRunning := false
global QCastOn := false
global autoPotOn := false
global pickupImageOn := false

; ======================================================================
========
; 2. THIẾT KẾ GIAO DIỆN CHÍNH (MAIN GUI)
; ======================================================================
========
Gui, Main:New, -AlwaysOnTop +MinimizeBox +HwndmainToolHwndV67, Auto-GSF V38 -
Tên + Option
Gui, Main:Margin, 0, 0
Gui, Main:Font, s9, Segoe UI
Gui, Main:Color, F7F7F7
; Header: Quản lý Profile
Gui, Main:Add, Text, BackgroundTrans x6 y10 w42 h20, Profile:
Gui, Main:Add, DropDownList, x50 y6 w110 vProfileSelect gLoadProfile, %profileList%
GuiControl, Main:ChooseString, ProfileSelect, %currentProfile%
Gui, Main:Add, Text, BackgroundTrans x166 y10 w25 h20, Tên:
Gui, Main:Add, Edit, x194 y6 w95 h24 vNewProfileName, %currentProfile%
Gui, Main:Add, Button, x295 y5 w75 h26 gAddProfile, LƯU PROFILE
Gui, Main:Add, Button, x376 y5 w77 h26 gDeleteProfile, XÓA PROFILE
; Khởi tạo 4 Tab chính xác như file gốc
Gui, Main:Add, Tab2, x0 y36 w459 h545 +0x2400 vAutoGSFMainTabs AltSubmit, 1. BUFF|2.
NHẶT ĐỒ|3. FARM|4. LIST ITEM
; --- NẠP THIẾT KẾ CỦA TỪNG TAB ---
#Include %A_ScriptDir%\UI\Tab_Buff.ahk
#Include %A_ScriptDir%\UI\Tab_NhatDo.ahk
#Include %A_ScriptDir%\UI\Tab_Farm.ahk
#Include %A_ScriptDir%\UI\Tab_ListItem.ahk
; ----------------------------------
; Footer: Các nút điều khiển chung
Gui, Main:Tab ; Thoát khỏi vùng Tab
Gui, Main:Add, Button, x6 y589 w55 h26 gSaveConfig, Lưu
Gui, Main:Add, Button, x68 y589 w102 h26 gRouteRecordToggle, Ghi Tọa Độ
Gui, Main:Add, Button, x177 y589 w82 h26 gFarmGD2TestButton, Run test
Gui, Main:Add, Button, x266 y589 w82 h26 gExportHPManaLog, Xuất Log
; Hiển thị Giao diện
Gui, Main:Show, Center w459 h624 NA, Auto-GSF V38 - Tên + Option

; ======================================================================
========
; CHỐT CHẶN (Bắt buộc trong AHK v1 để dừng luồng Auto-Execute)
; ======================================================================
========
return
; ======================================================================
========
; 3. CÁC HÀM XỬ LÝ SỰ KIỆN GIAO DIỆN (GUI EVENT HANDLERS)
; ======================================================================
========
LoadProfile:
; Gọi logic load profile từ file config
return
AddProfile:
; Gọi logic lưu profile mới
return
DeleteProfile:
; Gọi logic xóa profile
return
SaveConfig:
; Lưu trạng thái toàn bộ UI vào config.ini
return
RouteRecordToggle:
return
FarmGD2TestButton:
return
ExportHPManaLog:
return
MainGuiClose:
ExitApp
; Các hàm nút bấm trong Tab 2 (Nhặt đồ)
PickupUiToggleV79:
GuiControlGet, pickupImageOn,, PickupEnabledInputV79
return
; ======================================================================
========
; 4. NẠP CÁC MODULE LÕI VÀ LOGIC (BẮT BUỘC ĐỂ Ở CUỐI FILE)
; ======================================================================
========

#Include %A_ScriptDir%\Core\GameOffsets.ahk
#Include %A_ScriptDir%\Core\MemoryEngine.ahk
#Include %A_ScriptDir%\Core\GameState.ahk
#Include %A_ScriptDir%\Modules\Logic_AutoBuff.ahk
#Include %A_ScriptDir%\Modules\Logic_AutoHeal.ahk
#Include %A_ScriptDir%\Modules\Logic_AutoPickup.ahk
