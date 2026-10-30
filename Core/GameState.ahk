; ==============================================================================
; MODULE: GAME STATE
; ==============================================================================
global Game := {}
global Player := {}
Player.GetHP := Func("State_GetHP")
State_GetHP(hProcess, playerBase) {
    if (!playerBase) return -1
    stats := Engine_ReadU32(hProcess, playerBase + Offset.Unit.Stats)
    root := stats ? Engine_ReadU32(hProcess, stats + 0x24) : 0
    if (!root) return -1
    hpRaw := Engine_ReadU32(hProcess, root + 0x24)
    return Floor(hpRaw / 256)
}
Player.GetMana := Func("State_GetMana")
State_GetMana(hProcess, playerBase) {
    if (!playerBase) return -1
    stats := Engine_ReadU32(hProcess, playerBase + Offset.Unit.Stats)
    root := stats ? Engine_ReadU32(hProcess, stats + 0x24) : 0
    if (!root) return -1
    manaRaw := Engine_ReadU32(hProcess, root + 0x34)
    return Floor(manaRaw / 256)
}
Player.GetPosition := Func("State_GetPosition")
State_GetPosition(hProcess, playerBase) {
    if (!playerBase) return {x: 0, y: 0}
    path := Engine_ReadU32(hProcess, playerBase + Offset.Unit.Path)
    if (!path) return {x: 0, y: 0}
    px := Engine_ReadU16(hProcess, path + Offset.Path.DynamicX)
    py := Engine_ReadU16(hProcess, path + Offset.Path.DynamicY)
    return {x: px, y: py}
}
Game.IsInTown := Func("State_IsInTown")
State_IsInTown(levelID) {
    townLevels := {1: true, 40: true, 75: true, 103: true, 109: true}
    return townLevels.HasKey(levelID)
}
