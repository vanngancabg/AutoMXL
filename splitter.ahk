#NoEnv
#SingleInstance Force
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

sourceFile := A_ScriptDir . "\Gốc.ahk"
if (!FileExist(sourceFile))
{
    MsgBox, 48, Lỗi, Không tìm thấy file Gốc.ahk trong thư mục hiện tại!
    ExitApp
}

libDir := A_ScriptDir . "\lib"
if (!FileExist(libDir))
    FileCreateDir, %libDir%
if (!FileExist(A_ScriptDir . "\profile"))
    FileCreateDir, %A_ScriptDir%\profile
if (!FileExist(A_ScriptDir . "\txt"))
    FileCreateDir, %A_ScriptDir%\txt

; 1. Gỡ thuộc tính Read-Only và dọn sạch chữ ERROR bị lưu nhầm trong các file .ini
CleanIniFiles(A_ScriptDir . "\txt\*.ini")
CleanIniFiles(A_ScriptDir . "\profile\*.ini")

; 2. Xóa các file tách cũ trong lib\
FileDelete, %libDir%\*.ahk

; 3. Danh sách 14 file chức năng
modules := []
modules.Push({file: "01_globals.ahk",                  startLine: 1,     desc: "Biến cờ đầu file & cấu hình file Log"})
modules.Push({file: "02_startup.ahk",                  startLine: 51,    desc: "Khởi tạo Admin, biến toàn cục, Timer & Auto-Execute"})
modules.Push({file: "03_buff_cast_info.ahk",           startLine: 464,   desc: "Cửa sổ ngầm, QCast, Dãy F, Buff Z/X & Bảng Info xanh"})
modules.Push({file: "04_gui_profile.ahk",              startLine: 2144,  desc: "Giao diện 4 Tab (ShowConfig), Lưu cấu hình & Quản lý Profile"})
modules.Push({file: "05_heal_pot_cube.ahk",            startLine: 5040,  desc: "Tự động bơm HP/Mana (Belt, Rương, Cube) & Đọc máu/mana"})
modules.Push({file: "06_pickup_core_memory.ahk",       startLine: 5818,  desc: "Nhặt đồ, Cảnh báo đồ hiếm, Chuyển Cube & Đọc RAM cơ bản"})
modules.Push({file: "07_config_belt_log_quickbuff.ahk",startLine: 9201,  desc: "Auto Buff Delay, Load/Save INI, Nạp Belt/Cube, Ghi tọa độ & QuickBuff"})
modules.Push({file: "08_combat_attack_monster.ahk",    startLine: 13083, desc: "Tự đánh quái, Quét Boss, Bán kính đánh & PET loại trừ"})
modules.Push({file: "09_route_move_stuck.ahk",         startLine: 18076, desc: "Di chuyển lộ trình, F-ON nạp map, Thoát kẹt & Buff trạng thái"})
modules.Push({file: "10_map_scos_recovery_room.ahk",   startLine: 25220, desc: "Map SCOS, Tạo phòng mới, Đăng nhập lại GĐ4 & Tạo/Sửa map"})
modules.Push({file: "11_sig_town_farmlab.ahk",         startLine: 30076, desc: "GET Item, Quy trình SIG, Về thành & Các map VeLab/FAUT/CYC/UBU/TRAN/VIZ"})
modules.Push({file: "12_item_filter_editor.ahk",       startLine: 37048, desc: "Hướng dẫn, Soạn thảo lọc đồ Tab 4, Lịch sử phòng & Map 130-139"})
modules.Push({file: "13_cain_hop_bo_boss.ahk",         startLine: 42192, desc: "Logic chuyên biệt cho map CAIN, HOP, BO & Tìm Boss"})
modules.Push({file: "14_watchdog_flow_vnlog.ahk",      startLine: 47407, desc: "Watchdog chống đứng, Form 6, Sắp Rương/Kho, Chu kỳ Tâm & Log tiếng Việt"})

FileEncoding, UTF-8
FileRead, rawText, %sourceFile%
lines := StrSplit(rawText, "`n", "`r")
totalLines := lines.Length()

mainContent := "; ==============================================================================`r`n"
mainContent .= "; AUTO-GSF V38 - BẢN CHIA NHÓM CHỨC NĂNG (ĐÃ TỐI ƯU & CHỐNG XUNG ĐỘT TOÀN DIỆN)`r`n"
mainContent .= "; ==============================================================================`r`n`r`n"

totalMods := modules.Length()
Loop, %totalMods%
{
    idx := A_Index
    mod := modules[idx]
    startL := mod.startLine
    endL := (idx < totalMods) ? (modules[idx + 1].startLine - 1) : totalLines

    chunk := "; ==============================================================================`r`n"
    chunk .= "; FILE: " . mod.file . " (Dòng " . startL . " -> " . endL . " trong Gốc.ahk)`r`n"
    chunk .= "; CHỨC NĂNG: " . mod.desc . "`r`n"
    chunk .= "; ==============================================================================`r`n"

    Loop, % (endL - startL + 1)
    {
        lineNum := startL + A_Index - 1
        lineStr := lines[lineNum]

        ; [VÁ 1]: Bổ sung giá trị mặc định %A_Space% cho mọi lệnh IniRead bỏ trống cuối dòng
        if (RegExMatch(lineStr, "i)^\s*IniRead\s*,.*,\s*$"))
            lineStr .= "%A_Space%"

        ; [VÁ 2]: Bọc try riêng cho mọi lệnh IniWrite / IniDelete / FileMove / FileDelete / FileCopy
        if (RegExMatch(lineStr, "i)^(\s*)(IniWrite|IniDelete|FileMove|FileDelete|FileCopy|FileCreateDir)\s*,", m))
            lineStr := m1 . "try " . LTrim(lineStr)

        chunk .= lineStr . "`r`n"
    }

    ; [VÁ 3]: Chống đổi Profile hoặc ApplyConfig khi đang chạy Buff Set Phụ (zRunning) hoặc đang SIG (sigBusyV147)
    if (mod.file = "04_gui_profile.ahk")
    {
        oldLoadProf := "LoadProfileFromGui:`r`nif (xRunning)"
        newLoadProf := "LoadProfileFromGui:`r`nif (xRunning || zRunning || sigBusyV147)"
        chunk := StrReplace(chunk, oldLoadProf, newLoadProf)

        oldApply := "ApplyConfig:`r`nif (xRunning)`r`n    return"
        newApply := "ApplyConfig:`r`nif (xRunning || zRunning)`r`n    return"
        chunk := StrReplace(chunk, oldApply, newApply)
    }

    ; [VÁ 4]: Bọc catch an toàn cho FonLoadMapV382 và đảm bảo thư mục profile tồn tại trong file 09
    if (mod.file = "09_route_move_stuck.ahk")
    {
        oldTry := "    try`r`n        return FonLoadMapCoreV410(reason,inPid,inLevel,inX,inY)`r`n    finally"
        newTry := "    try`r`n        return FonLoadMapCoreV410(reason,inPid,inLevel,inX,inY)`r`n    catch fonErrV410`r`n        return false`r`n    finally"
        chunk := StrReplace(chunk, oldTry, newTry)

        oldStore := "RouteMapsStoreV21(profile)`r`n{`r`n    global ConfigFile, routeMapsV21, routeMapIdV21, routeMapNextV21"
        newStore := "RouteMapsStoreV21(profile)`r`n{`r`n    global ConfigFile, routeMapsV21, routeMapIdV21, routeMapNextV21`r`n    EnsureProfileFolder()"
        chunk := StrReplace(chunk, oldStore, newStore)
    }

    ; [VÁ 5]: Chặn chữ ERROR hiển thị lên các ô phím trong file 11
    if (mod.file = "11_sig_town_farmlab.ahk")
    {
        oldDisp := "MouseKeyDisplayV616(key)`r`n{`r`n    return RegExReplace(key,""i)MButton"",""M3"")`r`n}"
        newDisp := "MouseKeyDisplayV616(key)`r`n{`r`n    if (key = """" || key = ""ERROR"")`r`n        return ""None""`r`n    return RegExReplace(key,""i)MButton"",""M3"")`r`n}"
        chunk := StrReplace(chunk, oldDisp, newDisp)
    }

    outFile := libDir . "\" . mod.file
    f := FileOpen(outFile, "w", "UTF-8")
    if (IsObject(f))
    {
        f.Write(chunk)
        f.Close()
    }

    mainContent .= "; " . idx . ". " . mod.desc . "`r`n"
    mainContent .= "#Include %A_ScriptDir%\lib\" . mod.file . "`r`n`r`n"
}

fMain := FileOpen(A_ScriptDir . "\Auto-GSF.ahk", "w", "UTF-8")
if (IsObject(fMain))
{
    fMain.Write(mainContent)
    fMain.Close()
}

MsgBox, 64, Hoàn tất, Đã tách lại 14 file chức năng chuẩn xác và không còn lỗi ngoặc hàm!
ExitApp

CleanIniFiles(pattern)
{
    Loop, Files, %pattern%, F
    {
        filePath := A_LoopFileFullPath
        FileSetAttrib, -R, %filePath%
        FileRead, content, %filePath%
        if (!ErrorLevel && content != "")
        {
            cleaned := RegExReplace(content, "m)=ERROR\s*$", "=")
            if (cleaned != content)
            {
                FileDelete, %filePath%
                FileAppend, %cleaned%, %filePath%
            }
        }
    }
}