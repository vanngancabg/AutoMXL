; ==============================================================================
; MODULE: MEMORY ENGINE
; ==============================================================================
Engine_GetGamePID(windowTitle := "Diablo II") {
    WinGet, pid, PID, %windowTitle%
    return pid
}
Engine_OpenProcess(pid) {
    return DllCall("OpenProcess", "UInt", 0x1010, "Int", 0, "UInt", pid, "Ptr")
}
Engine_CloseProcess(hProcess) {
    if (hProcess)
        DllCall("CloseHandle", "Ptr", hProcess)
}
Engine_ReadU32(hProcess, address) {
    VarSetCapacity(buf, 4, 0)
    bytesRead := 0
    success := DllCall("ReadProcessMemory", "Ptr", hProcess, "Ptr", address, "Ptr", &buf, "UPtr", 4, "UPtr*", bytesRead)
    if (!success || bytesRead != 4)
        return 0
    return NumGet(buf, 0, "UInt")
}
Engine_ReadU16(hProcess, address) {
    VarSetCapacity(buf, 2, 0)
    bytesRead := 0
    DllCall("ReadProcessMemory", "Ptr", hProcess, "Ptr", address, "Ptr", &buf, "UPtr", 2, "UPtr*", bytesRead)
    return NumGet(buf, 0, "UShort")
}
Engine_ReadU8(hProcess, address) {
    VarSetCapacity(buf, 1, 0)
    bytesRead := 0
    DllCall("ReadProcessMemory", "Ptr", hProcess, "Ptr", address, "Ptr", &buf, "UPtr", 1, "UPtr*", bytesRead)
    return NumGet(buf, 0, "UChar")
}
Engine_GetModuleBase(pid, moduleName) {
    hSnapshot := DllCall("CreateToolhelp32Snapshot", "UInt", 0x00000008, "UInt", pid, "Ptr")
    if (hSnapshot = -1) return 0
    VarSetCapacity(MODULEENTRY32, 1024, 0)
    NumPut(1064, MODULEENTRY32, 0, "UInt")
    if (DllCall("Module32FirstW", "Ptr", hSnapshot, "Ptr", &MODULEENTRY32)) {
        Loop {
            currentModule := StrGet(&MODULEENTRY32 + 48, 256, "UTF-16")
            if (currentModule = moduleName) {
                baseAddress := NumGet(MODULEENTRY32, 24, "Ptr")
                DllCall("CloseHandle", "Ptr", hSnapshot)
                return baseAddress
            }
        } Until !DllCall("Module32NextW", "Ptr", hSnapshot, "Ptr", &MODULEENTRY32)
    }
    DllCall("CloseHandle", "Ptr", hSnapshot)
    return 0
}
