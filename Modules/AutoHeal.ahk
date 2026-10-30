; ==============================================================================
; MODULE: AUTO HEAL
; ==============================================================================
global AutoHeal_Active := false
global AutoHeal_LastDrinkHP := 0
global AutoHeal_LastDrinkMana := 0
AutoHeal_Start() {
    AutoHeal_Active := true
    SetTimer, AutoHeal_Loop, 150
}
AutoHeal_Stop() {
    AutoHeal_Active := false
    SetTimer, AutoHeal_Loop, Off
}
AutoHeal_Loop:
    if (!AutoHeal_Active) return
    pid := Engine_GetGamePID()
    if (!pid) return
    hProcess := Engine_OpenProcess(pid)
    if (!hProcess) return
    baseAddress := Engine_GetModuleBase(pid, "D2Client.dll")
    if (!baseAddress) {
        Engine_CloseProcess(hProcess)
        return
    }
    playerBase := Engine_ReadU32(hProcess, baseAddress + Offset.D2Client.PlayerUnit)
    currentHP := Player.GetHP(hProcess, playerBase)
    if (currentHP > 0 && currentHP <= Config_HPThreshold) {
        if (A_TickCount - AutoHeal_LastDrinkHP >= Config_Cooldown) {
            ControlSend,, {1}, ahk_pid %pid%
            AutoHeal_LastDrinkHP := A_TickCount
        }
    }
    currentMana := Player.GetMana(hProcess, playerBase)
    if (currentMana > 0 && currentMana <= Config_ManaThreshold) {
        if (A_TickCount - AutoHeal_LastDrinkMana >= Config_Cooldown) {
            ControlSend,, {2}, ahk_pid %pid%
            AutoHeal_LastDrinkMana := A_TickCount
        }
    }
    Engine_CloseProcess(hProcess)
return
