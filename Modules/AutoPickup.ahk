; ==============================================================================
; MODULE: AUTO PICKUP
; ==============================================================================
global AutoPickup_Active := false
global AutoPickup_LastTick := 0
AutoPickup_Start() {
    AutoPickup_Active := true
    SetTimer, AutoPickup_Loop, 100
}
AutoPickup_Stop() {
    AutoPickup_Active := false
    SetTimer, AutoPickup_Loop, Off
}
AutoPickup_Loop:
    if (!AutoPickup_Active || A_TickCount - AutoPickup_LastTick < Config_PickupDelay) return
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
    playerPos := Player.GetPosition(hProcess, playerBase)
    path := Engine_ReadU32(hProcess, playerBase + Offset.Unit.Path)
    room := path ? Engine_ReadU32(hProcess, path + Offset.Path.Room) : 0
    if (room) {
        pUnit := Engine_ReadU32(hProcess, room + 0x74)
        Loop, 1024 {
            if (!pUnit) break
            type := Engine_ReadU32(hProcess, pUnit + Offset.Unit.Type)
            if (type == 4) {
                classID := Engine_ReadU32(hProcess, pUnit + Offset.Unit.ClassID)
                if (Pickup_Filter.HasKey(classID)) {
                    itemPath := Engine_ReadU32(hProcess, pUnit + Offset.Unit.Path)
                    itemX := Engine_ReadU32(hProcess, itemPath + Offset.Path.StaticX)
                    itemY := Engine_ReadU32(hProcess, itemPath + Offset.Path.StaticY)
                    dist := Abs(itemX - playerPos.x) + Abs(itemY - playerPos.y)
                    if (dist <= Config_PickupRadius) {
                        AutoPickup_LastTick := A_TickCount
                        break
                    }
                }
            }
            pUnit := Engine_ReadU32(hProcess, pUnit + Offset.Unit.Next2)
        }
    }
    Engine_CloseProcess(hProcess)
return
