; ==============================================================================
; MODULE: MEMORY ENGINE
; Mục đích: Cung cấp các hàm nền tảng để đọc/ghi trực tiếp vào bộ nhớ Game
; KHÔNG chứa bất kỳ logic tính toán máu, mana hay vật phẩm nào ở đây.
; ==============================================================================

; Lấy mã tiến trình (PID) của cửa sổ game đang hoạt động
Engine_GetGamePID(windowTitle := "Diablo II") {
    WinGet, pid, PID, %windowTitle%
    return pid
}

; Mở kết nối vào tiến trình để bắt đầu đọc bộ nhớ
; Trả về Handle (hProcess). Cần gọi Engine_CloseProcess khi dùng xong để tránh tràn RAM.
Engine_OpenProcess(pid) {
    ; Quyền 0x1000 = PROCESS_QUERY_INFORMATION, 0x0010 = PROCESS_VM_READ
    return DllCall("OpenProcess", "UInt", 0x1010, "Int", 0, "UInt", pid, "Ptr")
}

; Đóng kết nối
Engine_CloseProcess(hProcess) {
    if (hProcess)
        DllCall("CloseHandle", "Ptr", hProcess)
}

; Đọc dữ liệu 4 byte (Unsigned Integer 32-bit) - Tương đương D2ReadU32 cũ
Engine_ReadU32(hProcess, address) {
    VarSetCapacity(buf, 4, 0)
    bytesRead := 0
    success := DllCall("ReadProcessMemory", "Ptr", hProcess, "Ptr", address, "Ptr", &buf, "UPtr", 4, "UPtr*", bytesRead)
    if (!success || bytesRead != 4)
        return 0 ; Trả về 0 nếu đọc lỗi (game crash, chuyển map chưa xong...)
    return NumGet(buf, 0, "UInt")
}

; Đọc dữ liệu 2 byte (Unsigned Integer 16-bit) - Tương đương D2ReadU16 cũ
Engine_ReadU16(hProcess, address) {
    VarSetCapacity(buf, 2, 0)
    bytesRead := 0
    DllCall("ReadProcessMemory", "Ptr", hProcess, "Ptr", address, "Ptr", &buf, "UPtr", 2, "UPtr*", bytesRead)
    return NumGet(buf, 0, "UShort")
}

; Đọc dữ liệu 1 byte (Unsigned Integer 8-bit) - Tương đương D2ReadU8V18 cũ
Engine_ReadU8(hProcess, address) {
    VarSetCapacity(buf, 1, 0)
    bytesRead := 0
    DllCall("ReadProcessMemory", "Ptr", hProcess, "Ptr", address, "Ptr", &buf, "UPtr", 1, "UPtr*", bytesRead)
    return NumGet(buf, 0, "UChar")
}

; Lấy địa chỉ nền (Base Address) của các file .dll (ví dụ: D2Client.dll, D2Common.dll)
Engine_GetModuleBase(pid, moduleName) {
    ; Tạo snapshot toàn bộ modules của tiến trình (TH32CS_SNAPMODULE = 0x00000008)
    hSnapshot := DllCall("CreateToolhelp32Snapshot", "UInt", 0x00000008, "UInt", pid, "Ptr")
    if (hSnapshot = -1)
        return 0
    
    VarSetCapacity(MODULEENTRY32, 1024, 0)
    NumPut(1064, MODULEENTRY32, 0, "UInt") ; dwSize
    
    if (DllCall("Module32FirstW", "Ptr", hSnapshot, "Ptr", &MODULEENTRY32)) {
        Loop {
            ; Lấy tên module
            currentModule := StrGet(&MODULEENTRY32 + 48, 256, "UTF-16")
            if (currentModule = moduleName) {
                baseAddress := NumGet(MODULEENTRY32, 24, "Ptr") ; modBaseAddr
                DllCall("CloseHandle", "Ptr", hSnapshot)
                return baseAddress
            }
        } Until !DllCall("Module32NextW", "Ptr", hSnapshot, "Ptr", &MODULEENTRY32)
    }
    
    DllCall("CloseHandle", "Ptr", hSnapshot)
    return 0
}
