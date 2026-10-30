; ============================================================
; Auto-GSF Splitter v2 (Fixed Encoding)
; ============================================================
#NoEnv
#SingleInstance Force
SetWorkingDir, %A_ScriptDir%

FileSelectFile, src,, %A_ScriptDir%, Select original Auto-GSF file, AutoHotkey (*.ahk)
if (src = "")
    ExitApp

FileRead, content, %src%
if (ErrorLevel) {
    MsgBox, 16, Error, Cannot read the file. Please check again.
    ExitApp
}

pos1 := InStr(content, "#SingleInstance Force")
pos2 := InStr(content, "manualCastInput.Start()")
if (!pos1 || !pos2) {
    MsgBox, 16, Error, Cannot find split markers inside the file.
    ExitApp
}

afterStart := SubStr(content, pos2)
RegExMatch(afterStart, "manualCastInput\.Start\(\)\s*\r?\n\s*return", match)
pos3 := pos2 + StrLen(match)

globalsText := SubStr(content, 1, pos1 - 1)
startupText := SubStr(content, pos1, pos3 - pos1)
bodyText    := SubStr(content, pos3)

if (SubStr(RTrim(startupText), -5) != "return")
    startupText .= "`r`nreturn`r`n"

libDir := A_ScriptDir . "\lib"
FileCreateDir, %libDir%

WriteUtf8(libDir . "\globals.ahk", "; Auto-GSF globals`r`n`r`n" . globalsText)
WriteUtf8(libDir . "\startup.ahk", "; Auto-GSF startup`r`n`r`n" . startupText)
WriteUtf8(libDir . "\body.ahk",    "; Auto-GSF body`r`n`r`n" . bodyText)

; Tạo file Auto-GSF.ahk không có tiếng Việt để tránh lỗi font
wrapper := ""
wrapper .= "; Auto-GSF Entry Point`r`n"
wrapper .= "#Persistent`r`n`r`n"
wrapper .= "#Include lib\globals.ahk`r`n"
wrapper .= "#Include lib\startup.ahk`r`n"
wrapper .= "#Include lib\body.ahk`r`n"
WriteUtf8(A_ScriptDir . "\Auto-GSF.ahk", wrapper)

; Kiểm tra xem file đã tạo thực sự nằm trên ổ cứng chưa
if (FileExist(libDir . "\globals.ahk") && FileExist(A_ScriptDir . "\Auto-GSF.ahk"))
    MsgBox, 64, Success, Split successful!`n`nNow double-click Auto-GSF.ahk to run.
else
    MsgBox, 16, Error, Failed to create files.`nCheck if your antivirus blocked them.

return

WriteUtf8(path, text) {
    FileDelete, %path%
    FileAppend, %text%, %path%, UTF-8
}