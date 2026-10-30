; ==============================================================================
; MODULE: AUTO BUFF
; ==============================================================================
global AutoBuff_LoopOn := false
global AutoBuff_Step := 1
global AutoBuff_NextTick := 0
AutoBuff_ToggleLoop() {
    AutoBuff_LoopOn := !AutoBuff_LoopOn
    if (AutoBuff_LoopOn) {
        AutoBuff_Step := 1
        AutoBuff_NextTick := 0
        SetTimer, AutoBuff_Timer, 20
    } else {
        SetTimer, AutoBuff_Timer, Off
    }
}
AutoBuff_Timer:
    if (!AutoBuff_LoopOn || A_TickCount < AutoBuff_NextTick) return
    pid := Engine_GetGamePID()
    if (!pid) return
    hProcess := Engine_OpenProcess(pid)
    if (!hProcess) return
    baseAddress := Engine_GetModuleBase(pid, "D2Client.dll")
    playerBase := Engine_ReadU32(hProcess, baseAddress + Offset.D2Client.PlayerUnit)
    if (!playerBase) {
        Engine_CloseProcess(hProcess)
        return
    }
    path := Engine_ReadU32(hProcess, playerBase + Offset.Unit.Path)
    room := path ? Engine_ReadU32(hProcess, path + Offset.Path.Room) : 0
    levelID := 0
    if (room) {
        roomEx := Engine_ReadU32(hProcess, room + 0x08)
        levelID := roomEx ? Engine_ReadU32(hProcess, roomEx + 0x1C) : 0
    }
    if (Game.IsInTown(levelID)) {
        Engine_CloseProcess(hProcess)
        return
    }
    currentKey := Config_BuffKeys[AutoBuff_Step]
    currentDelay := Config_BuffDelays[AutoBuff_Step]
    if (currentKey != "" && currentKey != "None") {
        ControlSend,, {%currentKey%}, ahk_pid %pid%
    }
    AutoBuff_NextTick := A_TickCount + currentDelay
    AutoBuff_Step++
    if (AutoBuff_Step > Config_BuffKeys.Length()) {
        AutoBuff_Step := 1
    }
    Engine_CloseProcess(hProcess)
return
