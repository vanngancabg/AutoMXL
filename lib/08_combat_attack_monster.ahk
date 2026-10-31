; ==============================================================================
; FILE: 08_combat_attack_monster.ahk (Dòng 13083 -> 18075 trong Gốc.ahk)
; CHỨC NĂNG: Tự đánh quái, Quét Boss, Bán kính đánh & PET loại trừ
; ==============================================================================
MonsterBossProbeTimerV1:
if (!ManualLogActiveV81())
{
    SetTimer, MonsterBossProbeTimerV1, Off
    return
}
if (!pickupCubeTraceUntil || A_TickCount >= pickupCubeTraceUntil)
{
    SetTimer, MonsterBossProbeTimerV1, Off
    return
}
if (monsterProbeBusyV1 || !IsGameActive())
    return
monsterProbeBusyV1 := true
try
    MonsterBossProbeScanV1()
finally
    monsterProbeBusyV1 := false
return

MonsterBossProbeReadV1(h, addr, size, ByRef buf)
{
    if (!h || addr < 0x10000 || size <= 0)
        return false
    VarSetCapacity(buf, size, 0)
    return DllCall("ReadProcessMemory", "Ptr", h, "Ptr", addr, "Ptr", &buf
        , "UPtr", size, "UPtrP", got) && got = size
}

MonsterBossProbeHexV1(ByRef buf, size)
{
    out := ""
    Loop, %size%
        out .= Format("{:02X}", NumGet(buf, A_Index-1, "UChar"))
    return out
}

MonsterBossProbeScanV1()
{
    global monsterProbeSeenV1, pickupCubeTraceUntil
    static cachePid := 0, cacheBase := 0
    pid := D2GetActiveGamePidV95()
    if (!pid)
        return
    if (pid != cachePid || !cacheBase)
    {
        cachePid := pid
        cacheBase := D2GetModuleBaseV35(pid, "D2Client.dll")
    }
    h := cacheBase ? DllCall("OpenProcess", "UInt", 0x0410, "Int", 0, "UInt", pid, "Ptr") : 0
    if (!h)
    {
        DebugTraceWrite("monster", "ERROR=OPEN_READ_CONTEXT pid=" . pid)
        return
    }
    try
    {
        player := D2ReadU32(h, cacheBase+0x11BBFC)
        path := player ? D2ReadU32(h, player+0x2C) : 0
        if (!MonsterBossProbeReadV1(h, path, 0x80, pb))
        {
            DebugTraceWrite("monster", "ERROR=PLAYER_PATH_READ pid=" . pid . " player=" . V92Hex(player))
            return
        }
        px := NumGet(pb, 0x02, "UShort"), py := NumGet(pb, 0x06, "UShort")
        room := NumGet(pb, 0x1C, "UInt")
        selectedRaw := D2ReadU32(h, cacheBase+0x11B834)
        DebugTraceWrite("monster", "SCAN pid=" . pid . " player=" . V92Hex(player)
            . " xy=" . px . "," . py . " room=" . V92Hex(room)
            . " selected_raw_11B834=" . V92Hex(selectedRaw))
        if (!room)
        {
            DebugTraceWrite("monster", "ERROR=ROOM_NOT_READY")
            return
        }
        rooms := MonsterLoadedRoomsV20(h,room), seenRooms := {}, seenUnits := {}

        DebugTraceWrite("monster", "BOSS_IDENTIFY_CONTEXT level=" . CoordLevelV14(h,room)
            . " selected_pointer_raw=" . V92Hex(selectedRaw)
            . " classification=UNCONFIRMED purpose=COMPARE_CLASS_UID_AND_MONSTER_DATA")
        count := 0, total := 0, errors := 0, truncated := false
        hpReads := 0, highestHP := -1, highestUID := 0, highestClass := 0, highestDist := -1, highestMaxHP := -1
        bestId := 0, bestDist := 0x7FFFFFFF, start := A_TickCount
        for ri, r in rooms
        {
            if (seenRooms.HasKey(r))
                continue
            seenRooms[r] := true
            u := D2ReadU32(h, r+0x74)
            Loop, 1024
            {
                if (!u || seenUnits.HasKey(u))
                    break
                if (total >= 2048 || A_TickCount-start >= 120
                    || A_TickCount >= pickupCubeTraceUntil || D2GetActiveGamePidV95() != pid)
                {
                    truncated := true
                    break
                }
                seenUnits[u] := true
                if (!MonsterBossProbeReadV1(h, u, 0xEC, ub))
                {
                    errors++
                    break
                }
                total++
                typ := NumGet(ub, 0x00, "UInt"), cls := NumGet(ub, 0x04, "UInt")
                uid := NumGet(ub, 0x0C, "UInt"), mode := NumGet(ub, 0x10, "UInt")
                data := NumGet(ub, 0x14, "UInt"), upath := NumGet(ub, 0x2C, "UInt")
                next := NumGet(ub, 0xE8, "UInt")
                if (typ = 1)
                {
                    count++
                    pathOK := MonsterBossProbeReadV1(h, upath, 0x80, mb)
                    x := pathOK ? NumGet(mb, 0x02, "UShort") : -1
                    y := pathOK ? NumGet(mb, 0x06, "UShort") : -1
                    dist := pathOK ? Abs(x-px)+Abs(y-py) : -1
                    hpInfo := MonsterBossProbeHPV2(h, NumGet(ub, 0x5C, "UInt"))
                    if (hpInfo.ok)
                        hpReads++
                    if (pathOK && hpInfo.ok && hpInfo.hp > 0
                        && (hpInfo.hp > highestHP || (hpInfo.hp = highestHP && dist < highestDist)))
                    {
                        highestHP := hpInfo.hp, highestMaxHP := hpInfo.maxhp
                        highestUID := uid, highestClass := cls, highestDist := dist
                    }
                    DebugTraceWrite("monster", "CANDIDATE room=" . ri . " unit=" . V92Hex(u)
                        . " type=" . typ . " class=" . cls . " uid=" . uid . " mode_raw=" . mode
                        . " data=" . V92Hex(data) . " path=" . V92Hex(upath)
                        . " path_ok=" . pathOK . " xy=" . x . "," . y . " dist_L1=" . dist
                        . " hp=" . hpInfo.hp . " max_hp=" . hpInfo.maxhp . " hp_ok=" . hpInfo.ok
                        . " hp_raw=" . hpInfo.raw . " max_hp_raw=" . hpInfo.maxraw
                        . " hp_source=" . hpInfo.source . " hp_reason=" . hpInfo.reason
                        . " selected_raw_match=" . (selectedRaw=u)
                        . " alive=" . (mode!=0 && mode!=12) . " excluded_pet_class=" . MonsterClassExcludedV11(cls,h,u)
                        . " level=" . (pathOK ? CoordLevelV14(h,NumGet(mb,0x1C,"UInt")) : -1)
                        . " dist_L2=" . (pathOK ? Round(Sqrt((x-px)**2+(y-py)**2),2) : -1)
                        . " boss=UNCONFIRMED enemy=UNCONFIRMED")
                    if (pathOK && dist < bestDist)
                        bestDist := dist, bestId := uid
                    key := pid . ":" . u . ":" . uid . ":" . cls . ":" . data
                    if (!monsterProbeSeenV1.HasKey(key))
                    {
                        monsterProbeSeenV1[key] := true
                        DebugTraceWrite("monster", "HP_STATS_RAW uid=" . uid . " " . hpInfo.dump)
                        DebugTraceWrite("monster", "UNIT_RAW uid=" . uid . " bytes_00_EB=" . MonsterBossProbeHexV1(ub, 0xEC))
                        if (pathOK)
                            DebugTraceWrite("monster", "PATH_RAW uid=" . uid . " bytes_00_7F=" . MonsterBossProbeHexV1(mb, 0x80))
                        if (MonsterBossProbeReadV1(h, data, 0x80, db))
                        {
                            DebugTraceWrite("monster", "DATA_RAW uid=" . uid . " class=" . cls . " bytes_00_7F=" . MonsterBossProbeHexV1(db, 0x80))
                            DebugTraceWrite("monster", "BOSS_DATA_COMPARE uid=" . uid . " class=" . cls
                                . " raw_u8_16=" . NumGet(db,0x16,"UChar") . " raw_u16_18=" . NumGet(db,0x18,"UShort")
                                . " raw_u32_1C=" . V92Hex(NumGet(db,0x1C,"UInt"))
                                . " interpretation=UNCONFIRMED no_boss_priority_applied=1")
                        }
                        else
                            DebugTraceWrite("monster", "DATA_READ_FAIL uid=" . uid)
                    }
                }
                u := next
            }
            if (truncated)
                break
        }
        DebugTraceWrite("monster", "SUMMARY rooms=" . seenRooms.Count() . " units=" . total
            . " type1_candidates=" . count . " read_errors=" . errors . " truncated=" . truncated
            . " nearest_candidate_uid=" . bestId . " dist_L1=" . (bestId ? bestDist : -1)
            . " hp_read_ok=" . hpReads . " priority_requested=HIGHEST_CURRENT_HP"
            . " highest_hp_candidate_uid=" . highestUID . " class=" . highestClass
            . " hp=" . highestHP . " max_hp=" . highestMaxHP . " dist_L1=" . highestDist
            . " hostile=UNCONFIRMED target_selected=0 attack_sent=0")
    }
    finally
        DllCall("CloseHandle", "Ptr", h)
}

MonsterBossProbeHPV2(h, stats)
{
    result := {ok:false,hp:-1,maxhp:-1,raw:-1,maxraw:-1
        ,source:"NONE",reason:"STATS_READ_FAIL",dump:"stats=" . V92Hex(stats)}
    if (!MonsterBossProbeReadV1(h, stats, 0x80, sb))
        return result
    result.dump .= " bytes_00_7F=" . MonsterBossProbeHexV1(sb, 0x80)
    result.reason := "HP_STAT_NOT_FOUND"
    for _, off in [0x48, 0x24]
    {
        root := NumGet(sb, off, "UInt")
        count := NumGet(sb, off+4, "UShort")
        capacity := NumGet(sb, off+6, "UShort")
        label := "STATS+" . Format("{:02X}", off)
        result.dump .= " " . label . " ptr=" . V92Hex(root)
            . " count=" . count . " capacity=" . capacity
        if (!root || count < 1 || count > 512 || capacity < count)
            continue
        if (!MonsterBossProbeReadV1(h, root, count*8, ab))
        {
            result.dump .= " READ_FAIL"
            continue
        }
        result.dump .= " array_first_" . Min(count,32) . "=" . MonsterBossProbeHexV1(ab, Min(count,32)*8)
        hpRaw := -1, maxRaw := -1, duplicates := false
        Loop, %count%
        {
            entry := (A_Index-1)*8
            layer := NumGet(ab, entry, "UShort")
            statId := NumGet(ab, entry+2, "UShort")
            value := NumGet(ab, entry+4, "UInt")
            if (layer != 0)
                continue
            if (statId = 6)
            {
                if (hpRaw != -1)
                    duplicates := true
                hpRaw := value
            }
            if (statId = 7)
            {
                if (maxRaw != -1)
                    duplicates := true
                maxRaw := value
            }
        }
        result.dump .= " hp_raw=" . hpRaw . " max_raw=" . maxRaw . " duplicate=" . duplicates
        if (duplicates || hpRaw < 0 || maxRaw <= 0 || hpRaw > maxRaw)
            continue
        result.ok := true
        result.hp := Floor(hpRaw/256), result.maxhp := Floor(maxRaw/256)
        result.raw := hpRaw, result.maxraw := maxRaw
        result.source := label, result.reason := "STRUCTURE_MATCH_PROBE"
        return result
    }
    return result
}

FarmGD2TestButtonV644:
FarmGD2TestStartV644()
return

FarmGD2TestStopV644(message := "Đã dừng TEST GD2.")
{
    global farmGD2TestV644,farmControlOwnerV186
    previousOwner := IsObject(farmGD2TestV644) ? farmGD2TestV644.previousOwner : ""
    FarmButtonStopV1()
    farmControlOwnerV186 := previousOwner
    FonInfoPushV385(message)
    return false
}

FarmGD2TestReadyV644(pid,level)
{
    global farmGD2TestV644,coordSavedV15
    if (!IsObject(farmGD2TestV644))
        return false
    if (pid!=farmGD2TestV644.pid || level!=farmGD2TestV644.level)
        return FarmGD2TestStopV644("TEST GD2 dừng: cửa sổ hoặc map đã đổi.")
    return IsObject(coordSavedV15) && coordSavedV15.Length()>0
}

FarmGD2TestStartV644()
{
    global
    local row,previousOwner,pid,level,point,oldResume
    if (IsObject(farmGD2TestV644))
        return FarmGD2TestStopV644()
    if (sigBusyV147 || gameItemActionOwner!="")
    {
        FonInfoPushV385("TEST GD2: chờ thao tác vật phẩm xong rồi bấm lại.")
        return false
    }
    row := FarmStartRowV394(),previousOwner := farmControlOwnerV186
    if (!SigBackgroundBindV179())
    {
        FonInfoPushV385("TEST GD2: chọn cửa sổ game trước.")
        return false
    }
    pid := backgroundPidV63,level := RoomRecordLevelV259(pid)
    if (!pid || !level)
    {
        FonInfoPushV385("TEST GD2: cần vào map trước.")
        return false
    }
    FarmButtonStopV1()
    CoordSavedLoadV15(currentProfile)
    if (!IsObject(coordSavedV15) || !coordSavedV15.Length())
    {
        FonInfoPushV385("TEST GD2: map đang chọn chưa có tọa độ đã lưu.")
        return false
    }
    row := Max(1,Min(row,coordSavedV15.Length()))
    for _,point in coordSavedV15
    {
        if (point.level!=level)
        {
            FonInfoPushV385("TEST GD2: tuyến đang chọn khác map hiện tại.")
            return false
        }
    }
    FarmRuntimeResetV535("GD2_TEST_START")
    farmGD2TestV644 := {pid:pid,level:level,row:row,starting:true,previousOwner:previousOwner}
    farmControlOwnerV186 := "TEST",mapWorkflowV185 := false
    coordYellowRowV350 := row
    GuiControl, 1:, FarmGD2TestButtonV644, Dừng
    autoMonsterAttackOn := true
    oldResume := farmResumeInternalV70,farmResumeInternalV70 := true
    Gosub, AutoMonsterAttackToggle
    farmResumeInternalV70 := oldResume
    if (!IsObject(farmGD2TestV644))
        return false
    farmGD2TestV644.starting := false
    if (!autoMonsterAttackOn || stage2StartPendingV381)
        return FarmGD2TestStopV644("TEST GD2: chưa khởi động được, kiểm tra game và tuyến đã lưu.")
    FarmWatchStartV5()
    FonInfoPushV385("TEST GD2: chạy từ dòng vàng " . row . " đến cuối tuyến.")
    return true
}

AutoMonsterAttackToggle:
if (farmUserPausedV2026 && autoMonsterAttackOn)
    return
if (autoMonsterAttackOn)
    farmManualStoppedV2026 := false
if (autoMonsterAttackOn)
    FarmElapsedStartV1350()
else if (!FarmControlRunningV186() && !IsObject(scosEntryV162) && !IsObject(stageTwoV166)
    && !IsObject(mapWorkflowV185) && !IsObject(farmMapPauseV52))
    FarmElapsedStopV1350()
if (autoMonsterAttackOn)
{
    if (!farmResumeInternalV70)
        mapLoadFailureV402 := false
    if (farmControlOwnerV186!="BO")
        FonTrackingEnableV410()
    if (!BOCoordinateBlockedV471())
    {
        SetTimer, CoordCurrentTimerV15, 500
        CoordCurrentReadV15()
    }
}
startYellowV367 := FarmStartRowV394(),startYellowMapV367 := routeMapIdV21
if (autoMonsterAttackOn && FarmStartApplyYellowV2())
    startYellowV367 := FarmStartRowV394(),startYellowMapV367 := routeMapIdV21
if (!autoMonsterAttackOn)
{
    farmStartRetryV237 := false
}
if (autoMonsterAttackOn && !farmResumeInternalV70)
    farmCubeSortOnceV253 := false
if (autoMonsterAttackOn)
    pickupStashListV217 := {}
if (autoMonsterAttackOn && IsObject(sigTownV148))
    SigTownCancelV148("USER_RESTARTED_FARM")
if (autoMonsterAttackOn && IsObject(roomRecordV108) && roomRecordV108.insertMode)
{
    if (!RoomInsertStopV125())
    {
        FarmStartWaitV237("RECORD_INSERT_BUSY")
        return
    }
}
if (!autoMonsterAttackOn && IsObject(roomExploreV89))
    RoomExploreEndV89("FARM_OFF")
portalBuffV85 := false
MovementCtrlSetV78(false,0,"AutoMonsterAttackToggle")
if (autoMonsterAttackOn && !BackgroundBindV63(backgroundHwndV63))
{
    FarmStartWaitV237("GAME_BIND_NOT_READY")
    return
}
if (autoMonsterAttackOn)
    FarmSkillBaselineEnsureV621(backgroundPidV63)
if (autoMonsterAttackOn && !BossSearchActiveV430() && !Stage2MapRequestV381())
{
    if (!autoMonsterAttackOn)
        return
    stage2StartPendingV381 := true
    SetTimer, Stage2StartWaitTimerV381, 250
    PortalLogWriteV66("STAGE2_START_WAIT reason=NO_SELECTED_ROUTE", "STAGE2_ROUTE_WAIT",2000)
    return
}
stage2StartPendingV381 := false
SetTimer, Stage2StartWaitTimerV381, Off
if (autoMonsterAttackOn && coordSavedV15.Length())
    farmLoadedMapV56 := {pid:backgroundPidV63,profile:currentProfile,mapId:routeMapIdV21
        ,level:coordSavedV15[1].level}

if (autoMonsterAttackOn && !pickupImageOn && Stage2FightEnabledV9())
    PickupEnabledSetV71(true,false,false)

if (autoMonsterAttackOn)
{
    if (IsObject(mapWorkflowV185) && mapWorkflowV185.map="SCOS" && mapWorkflowV185.testRows>0)
    {
        while (coordSavedV15.Length()>mapWorkflowV185.testRows)
            coordSavedV15.Pop()
        AutoMonsterAttackLogV2("TEST_ROUTE_LIMIT map=SCOS rows=" . coordSavedV15.Length() . " saved_file=UNCHANGED")
    }
    CoordBoxRefreshV15(true)
}
if (autoMonsterAttackOn)
    Stage2FlowSelectCainV380()
else
    Stage2FlowConfigureV380()
if (autoMonsterAttackOn && farmBuffModeV509!=1)
    FarmBuffStartV509()
FarmCastSyncV88(autoMonsterAttackOn)
if (autoMonsterAttackOn)
{
    PickupEnabledSetV71(true,true,false)
    farmResumeArmedV70 := true
    SetTimer, FarmResumeTimerV70, 500
}
coordGoV59 := false
SetTimer, CoordGoTimerV59, Off
entryBuffAlreadyDoneV233 := scosStartFarmV162 && IsObject(mapStage1BuffDoneV248)
    && mapStage1BuffDoneV248.pid=backgroundPidV63
startAlreadyFarmV757 := autoMonsterAttackOn && FarmStartInFarmV757(backgroundPidV63)
reviveBuffPendingV34 := autoMonsterAttackOn && !IsObject(roomExploreV89) && !entryBuffAlreadyDoneV233 && !startAlreadyFarmV757
if (startAlreadyFarmV757)
{
    entryBuffPendingV20 := false
    PortalLogWriteV66("START_IN_FARM_READY next=KEEP_YELLOW_ROUTE revive_buff=SKIP")
}
portalExitPendingV69 := false
portalBackPendingV74 := false
farmLastCombatTickV72 := A_TickCount
farmReviveV32 := false
deathlordRetryAtV31 := 0
farmLeftSkillV30 := -1, farmLeftPidV30 := 0, farmSetAttemptV30 := false
if (autoMonsterAttackOn)
coordCastCountV50 := 0, coordCastPendingV50 := false, coordCastLastRowV50 := 0
coordManualRowV59 := 0
userSelectedRowV351 := FarmStartRowV394()
mapRunResumeV210 := false,coordRunSelectedV210 := false
CoordRouteResetV16()
if (autoMonsterAttackOn && ScosOrderedRouteV234())
    coordRouteV16.yellow := 1
if (userSelectedRowV351>0)
{
    coordRouteV16.resumeRowV210 := userSelectedRowV351
    coordRouteV16.startAtYellowV367 := true
    farmStartChoiceV2 := false
    coordRouteV16.pid := backgroundPidV63
    coordRouteV16.startLevel := coordSavedV15[userSelectedRowV351].level
    coordRouteV16.portalArrivalPendingV307 := false
    coordRouteV16.yellow := userSelectedRowV351
    coordRunSelectedV210 := false
    mapRunResumeV210 := false
    PortalLogWriteV66("FARM_START_FROM_YELLOW row=" . userSelectedRowV351
        . " level=" . coordSavedV15[userSelectedRowV351].level)
}
coordMoveDoneV14 := false, coordMoveTriesV14 := 0, coordNoTargetSinceV14 := 0
if (autoMonsterAttackOn)
{
    PacketWatchStopV1()
    AutoMonsterAttackLogV2("START route=ACTIVE_SAVED_ROWS from=CURRENT_POSITION travel_attack_radius=CONFIGURED arrival=NEXT_LEG last_point=TOWN_SIG_STOP auto_log=MANUAL_ONLY")
}
else
    AutoMonsterAttackLogV2("STOP checkbox=OFF")
if (autoMonsterAttackOn)
{
    farmStartRetryV237 := false
    farmPickupBlockedV57 := false
    SetTimer, AutoMonsterAttackTimer, 250
    FarmPickupSyncV57(0,0,-1,true)
}
else
{
    SetTimer, AutoMonsterAttackTimer, Off
    FarmPickupSyncV57()
}
return

FarmStartWaitV237(reason)
{
    FarmRestartOnErrorV238(reason)
}

FarmStage3RequestV313(cause)
{
    global farmManualStoppedV2026
    if (farmManualStoppedV2026)
        return false
    global mapWorkflowV185,farmResetWatchEnabledV217,farmStage3PendingV237,farmRestartReasonV238
    if (!IsObject(mapWorkflowV185) || mapWorkflowV185.stage!=2)
        return false
    if ((cause="STUCK" && !farmResetWatchEnabledV217) || (cause!="COMPLETE" && cause!="STUCK"))
        return false
    FarmCombatYieldV237()
    PickupEnabledSetV71(false,true,false)
    farmRestartReasonV238 := cause
    FarmMapJournalFinishV940("GD2_" . cause)
    if (StageTwoArmV166(cause="STUCK" || ContinuousMapEnabledV168()))
    {
        farmStage3PendingV237 := false
        SetTimer, FarmStage3RetryTimerV237, Off
        MapStageSetV185(3)
        FonInfoPushV385("GĐ2 xong — chuyển GĐ3: Save & Exit và tạo phòng bằng DLL.")
    }
    else
    {
        farmStage3PendingV237 := true
        SetTimer, FarmStage3RetryTimerV237, 2000
        FonInfoPushV385("GĐ2 xong — đang chờ nhận cửa sổ game để bắt đầu GĐ3.")
    }
    return true
}

FarmRestartOnErrorV238(reason)
{
    global farmManualStoppedV2026
    if (farmManualStoppedV2026)
        return false
    global scosEntryV162,stageTwoV166,autoMonsterAttackOn,farmStartRetryV237
    if (IsObject(stageTwoV166))
    {
        stageTwoV166.phase := "RECOVER",stageTwoV166.until := A_TickCount+120000
        stageTwoV166.at := A_TickCount,stageTwoV166.retryAtV237 := A_TickCount+1000
        PortalLogWriteV66("STAGE3_RETRY_CURRENT_STEP reason=" . reason)
        return
    }
    if (IsObject(scosEntryV162))
    {
        scosEntryV162.until := A_TickCount+180000,scosEntryV162.retryAtV237 := A_TickCount+1000
        PortalLogWriteV66("STAGE1_RETRY_CURRENT_STEP phase=" . scosEntryV162.phase . " reason=" . reason . " stage3=OFF","STAGE1_RETRY",2000)
        ToolTipInfoV386("GĐ1: " . reason . " — giữ bước hiện tại.")
        SetTimer, RemoveToolTip, -4000
        return
    }
    FarmStartKeepV697(reason)
}

FarmErrorKeepV769(reason)
{
    global farmStartRetryV237,mapWorkflowV185
    if (!FarmControlRunningV186() && !IsObject(mapWorkflowV185))
        return false
    farmStartRetryV237 := true
    FarmRestartOnErrorV238(reason)
    FarmWatchStateV688()
    PortalLogWriteV66("FARM_ERROR_KEPT reason=" . reason . " run=ON context=PRESERVED next=EXISTING_RECOVERY","FARM_ERROR_KEPT",1000)
    return false
}

FarmStartKeepV697(reason)
{
    global
    farmStartRetryV237 := true
    FarmWatchStateV688()
    Gosub, MapControlButtonStatusV171
    FonInfoPushV385("[START] Vẫn bật; chờ phục hồi khi đứng yên: " . reason)
    PortalLogWriteV66("START_REQUEST_KEPT owner=" . farmControlOwnerV186 . " reason=" . reason)
    return true
}


FarmResumeTimerV70:
if (farmUserPausedV2026)
    return
if (farmManualStoppedV2026)
{
    SetTimer, FarmResumeTimerV70, Off
    return
}
if (!farmResumeArmedV70)
{
    SetTimer, FarmResumeTimerV70, Off
    return
}
if (!BackgroundValidV63() || autoMonsterAttackBusy || xRunning || zRunning || gameItemActionOwner!="")
    return
resumePidV70 := backgroundPidV63
resumeBaseV70 := D2GetModuleBaseV35(resumePidV70,"D2Client.dll")
resumeHV70 := resumeBaseV70 ? D2OpenProcess(resumePidV70) : 0
if (!resumeHV70)
    return
try
{
    resumePlayerV70 := D2ReadU32(resumeHV70,resumeBaseV70+0x11BBFC)
    resumePathV70 := resumePlayerV70 ? D2ReadU32(resumeHV70,resumePlayerV70+0x2C) : 0
    if (!MonsterBossProbeReadV1(resumeHV70,resumePathV70,0x20,resumePbV70))
        return
    resumeLevelV70 := CoordLevelV14(resumeHV70,NumGet(resumePbV70,0x1C,"UInt"))
    resumeModeV70 := D2ReadU32(resumeHV70,resumePlayerV70+0x10)
    if (autoMonsterAttackOn && outsideLevelV22!="" && resumeLevelV70=outsideLevelV22)
        farmResumeOutsideV70 := true
    if (!farmResumeOutsideV70 || townLevelV22="" || resumeLevelV70!=townLevelV22
        || (resumeModeV70!=1 && resumeModeV70!=5))
        return
    farmResumeOutsideV70 := false
    if (!autoMonsterAttackOn)
    {
        farmResumeInternalV70 := true
        autoMonsterAttackOn := true
        try
            Gosub, AutoMonsterAttackToggle
        finally
            farmResumeInternalV70 := false
    }
    if (autoMonsterAttackOn && !IsObject(farmReviveV32))
        reviveBuffPendingV34 := true
    PortalLogWriteV66("FARM_TOWN_RECOVER auto=" . autoMonsterAttackOn . " next=TOWN_BUFF_THEN_PORTAL_THEN_FARM")
}
finally
    DllCall("CloseHandle","Ptr",resumeHV70)
return

AutoMonsterAttackTimer:
if (farmUserPausedV2026)
    return
if (farmManualStoppedV2026)
{
    SetTimer, AutoMonsterAttackTimer, Off
    return
}
; Revive is dispatched by the one Farm timer. START-while-dead uses this timer too.
if (IsObject(farmDeadStartV695))
{
    FarmDeadStartTickV695()
    return
}
; On death, Esc is always handled before buff, pickup, movement or fighting.
if (FarmReviveDeadPriorityV62())
    return
; Timer danh khong xen vao qua trinh da ban giao nhat.
if (FarmControlRunningV186() && IsObject(farmCenterCycleV741)
    && farmCenterCycleV741.phase="PICKUP_BUSY")
    return
if (A_TickCount<farmErrorRetryAtV740 || RemoteThreadBusyV740(D2GetActiveGamePidV95()))
    return
try
{
if (buffSequenceRunningV555 || farmBuffExclusiveV621)
    return
pidCheck := D2GetActiveGamePidV95()
if (pidCheck)
{
    currentMapLevel := RoomRecordLevelV259(pidCheck)
    CheckAndRestoreBackgroundFarm(pidCheck, currentMapLevel)
}
	
if (!autoMonsterAttackOn || autoMonsterAttackBusy)
{
    if (!autoMonsterAttackOn)
        FarmAttackHoldReleaseV15()
    return
}
if (farmControlOwnerV186="CAIN" && !IsObject(scosEntryV162)
    && !IsObject(stageTwoV166) && !IsObject(sigTownV148) && !IsObject(farmReviveV32))
{
    global cainAttachRetryAtV379
    if (!cainAttachRetryAtV379 || A_TickCount-cainAttachRetryAtV379>=1000)
    {
        cainAttachRetryAtV379 := A_TickCount
        CainStage2AttachV379()
    }
    return
}
if (petLearnOnV12 || packetWatchArmedV1 || zRunning || xRunning || gameItemActionOwner!="" || !IsGameActive())
{
    FarmAttackHoldReleaseV15()
    if (petLearnOnV12 || packetWatchArmedV1 || zRunning || xRunning || !IsGameActive())
    {
        monsterChaseV44 := false
        if (IsObject(coordRouteV16))
            coordRouteV16.stuckProbe := false
    }
    AutoMonsterAttackLogV2("WAIT active=" . IsGameActive() . " capture=" . packetWatchArmedV1
        . " buff=" . (zRunning || xRunning) . " owner=" . gameItemActionOwner, true)
    return
}
autoMonsterAttackBusy := true
farmAttackUsedV15 := false
try
    AutoMonsterAttackScanV1()
catch e
{
    if (IsObject(scosEntryV162) && scosEntryV162.map="BO")
        BOErrorReportV463(scosEntryV162,e.Message,"FARM line=" . e.Line . " function=" . e.What)
    else
        FarmRuntimeErrorV740(e)
}
finally
{
    autoMonsterAttackBusy := false
    if (!farmAttackUsedV15 && !FarmAttackKeepV15())
        FarmAttackHoldReleaseV15()
}
}
catch e
    FarmRuntimeErrorV740(e)
return

AutoMonsterAttackViewV1(h, base, hwnd, playerPath)
{
    if (!MonsterBossProbeReadV1(h, base+0xDBC48, 8, sizeBuf)
        || !MonsterBossProbeReadV1(h, base+0x11995C, 8, offsetBuf)
        || !MonsterBossProbeReadV1(h, playerPath, 0x20, playerBuf))
        return false
    gw := NumGet(sizeBuf,0,"UInt"), gh := NumGet(sizeBuf,4,"UInt")
    ox := NumGet(offsetBuf,4,"Int"), oy := NumGet(offsetBuf,0,"Int")
    if (gw<320 || gh<240 || gw>8192 || gh>8192)
        return false
    playerSX := NumGet(playerBuf,8,"Int")-ox
    playerSY := NumGet(playerBuf,12,"Int")-oy
    if (Abs(playerSX-gw/2)>80 || playerSY<gh/4 || playerSY>gh*3/4)
        return false
    VarSetCapacity(rect,16,0)
    if (!DllCall("GetClientRect","Ptr",hwnd,"Ptr",&rect))
        return false
    cw := NumGet(rect,8,"Int"), ch := NumGet(rect,12,"Int")
    if (cw<320 || ch<240)
        return false
    return {gw:gw,gh:gh,cw:cw,ch:ch,ox:ox,oy:oy}
}

AutoMonsterAttackPointV1(ByRef pb, view)
{
    sx := NumGet(pb,8,"Int")-view.ox
    sy := NumGet(pb,12,"Int")-view.oy-8
    if (sx<16 || sx>view.gw-16 || sy<32 || sy>view.gh-64)
        return false
    return {x:Round(sx*view.cw/view.gw),y:Round(sy*view.ch/view.gh)}
}

AutoMonsterAttackScanV1(infoOnly := false)
{
    global farmManualStoppedV2026
    if (farmManualStoppedV2026 && !infoOnly)
        return false
    routePointsV724 := FarmRoutePointsV724()
    if (!infoOnly && VizBossActiveV687())
        return false
    if (!infoOnly && FarmCommonRouteActiveV3() && !Stage2FightEnabledV9())
        return false

    global roomExploreV89,portalBuffV85,coordCastPendingV50
    global autoMonsterAttackOn,zRunning,xRunning,gameItemActionOwner,packetWatchArmedV1,farmLastCombatTickV72
    global monsterLockUntilDeadV145,viewIdV54,viewPosV291,farmResetWatchEnabledV217,monsterLockRoomSecV622
    global farmControlOwnerV186,stage2FlowV380,QCastOn,cycleOn,farmCombatAreaV590,farmItemLockV625,farmFightLockV626
    global pickupImageOn,pickupGroupActiveV26,pickupRadius,pickupRoundResetV1
    global cainNoFightV361,cainPauseFarmV361,cainBossUidV361,cainBossKilledV361,cainBossClassV361
    global scosEntryV162,farmReviveV32
    global currentAttackUidV520,currentAttackClassV520,currentAttackX_V520,currentAttackY_V520,currentAttackAtV520,currentAttackDistV523
    global monsterExcludeClassesV11,coordNoTargetSinceV14,coordRouteV16,monsterCombatUidV45,monsterRadiusV48,monsterChaseV44,combatMoveLastV48,monsterRoadAreaV51,chaseCheckSecV9
    global farmScanListV682,farmScanSelectedV682,farmGroundItemCountV710
    global farmCenterCycleV741,farmScanLimitV771
    static cachePid := 0, cacheBase := 0
    static nonBossBurstCountsV1 := {}
    if (cainPauseFarmV361 && !infoOnly)
        return
    pid := D2GetActiveGamePidV95()
    if (!pid)
    {
        AutoMonsterAttackLogV2("SKIP reason=NO_ACTIVE_GAME_PID", true)
        return
    }
    hwnd := GameTargetHwndV63()
    if (pid!=cachePid || !cacheBase)
    {
        cachePid := pid
        cacheBase := D2GetModuleBaseV35(pid,"D2Client.dll")
    }
    h := cacheBase ? DllCall("OpenProcess","UInt",0x0410,"Int",0,"UInt",pid,"Ptr") : 0
    if (!h)
    {
        AutoMonsterAttackLogV2("SKIP reason=OPEN_READ_PROCESS base=" . cacheBase . " error=" . A_LastError, true)
        return
    }
    previousAreaV590 := farmCombatAreaV590
    try
    {
        player := D2ReadU32(h,cacheBase+0x11BBFC)
        playerPath := player ? D2ReadU32(h,player+0x2C) : 0
        if (!MonsterBossProbeReadV1(h,playerPath,0x20,pb))
        {
            AutoMonsterAttackLogV2("SKIP reason=PLAYER_PATH_READ", true)
            return
        }
        playerMode := D2ReadU32(h,player+0x10)
        liveStage2LevelV381 := CoordLevelV14(h,NumGet(pb,0x1C,"UInt"))
        if (!infoOnly)
            PortalLogWriteV66("COMBAT_SCAN_CONTEXT level=" . liveStage2LevelV381 . " owner=" . farmControlOwnerV186
                . " fight=" . Stage2FightEnabledV9() . " no_fight=" . cainNoFightV361 . " pause=" . cainPauseFarmV361
                . " recovery=" . IsObject(coordRouteV16.escapeV84) . " cast4=" . QCastOn . " cycle6=" . cycleOn,"COMBAT_SCAN_CONTEXT",1000)
        if (!infoOnly && BOCommonActiveV444(pid))
        {
            observedRoomV462 := D2ReadU32(h,NumGet(pb,0x1C,"UInt")+0x10)
            if (observedRoomV462)
                BossSearchRoomsObserveV432(stage2FlowV380.searchV430,observedRoomV462)
        }

        ; Single revive dispatcher inside the normal Farm scan.
        if (!infoOnly && FarmReviveTickV32(h,player,pb,pid,hwnd,cacheBase,playerPath,playerMode))
            return
        ; ITEM_ESCAPE_20261029: continue recovery every farm tick, before
        ; route-center / combat can dispatch the old item destination.
        if (!infoOnly && FarmItemEscapeActiveV20261029(pid))
        {
            escapePhaseV20261029 := farmItemLockV625.returnGoalV655.routeV392.escapeV84.phase
            FarmItemReturnV648(h,pb,pid,liveStage2LevelV381
                ,NumGet(pb,2,"UShort"),NumGet(pb,6,"UShort"))
            PortalLogWriteV66("FARM_ITEM_ESCAPE_EXCLUSIVE_TICK pid=" . pid
                . " phase_before=" . escapePhaseV20261029
                . " still_active=" . (FarmItemEscapeActiveV20261029(pid) ? 1 : 0)
                ,"FARM_ITEM_ESCAPE_EXCLUSIVE_TICK",1000)
            return
        }
        if (!infoOnly)
            FarmParentBeginV767(pid,liveStage2LevelV381)
        if (!infoOnly && FarmCenterCheckV741(h,player,pid,true))
            return

        if (!infoOnly && playerMode!=0 && playerMode!=17
            && !FarmReviveTownLevelV295(liveStage2LevelV381)
            && !Stage2MapWaitV381(pid,liveStage2LevelV381))
        {
            if (!stage2WaitReportedV385)
            {
                stage2WaitReportedV385 := 1
                FonInfoPushV385("[GĐ2] Chưa có lộ trình đang nạp cho level=" . liveStage2LevelV381)
            }
            return
        }
        stage2WaitReportedV385 := 0

        itemDoneV380 := !infoOnly && Stage2ItemCheckV380(h,player,pid)
        if (!infoOnly && CainQuestReturnV369(h,player,pid))
            return
        if (itemDoneV380)
            return
        cainGd4ActiveV376 := FarmItemFlowRunningV427(pid,liveStage2LevelV381)
        if (!infoOnly && FarmStage2DoneCurrentV372(pid) && !cainGd4ActiveV376)
            return

        if (!infoOnly && FarmMapAltTickV199(h,player,pb,pid))
            return
        if (!infoOnly)
            RoomStandLogV114(h,player,pb,pid,playerMode)
        if (!infoOnly && IsObject(roomExploreV89) && playerMode!=0 && playerMode!=17)
        {
            if (PortalExitTickV69(h,player,pb,pid))
                return
            if (IsObject(portalBuffV85) && FarmPortalBuffTickV85(h,player,pid))
                return
            if (!coordCastPendingV50 && AutoBuffEnsureV513(h,player,pid))
                return
        }
        if (!infoOnly && Stage2FightEnabledV9() && !ScosOrderedRouteV234() && RoomExploreTickV89(h,player,pb,pid,playerMode))
            return
        if (playerMode=0 || playerMode=17)
            return
        if (!infoOnly && BossSearchActiveV430(pid,liveStage2LevelV381) && farmControlOwnerV186!="BO")
        {
            invV430 := D2ReadU32(h,player+0x60)
            cursorV430 := invV430 ? PickupCursorV4(h,invV430) : false
            if (!IsObject(cursorV430) || cursorV430.unit)
                return
            if (StateBuffTickV17(h,player,pb,pid) || CombatRecoverTickV48(h,pb,pid,false))
                return
            if (Stage2FightEnabledV9())
                BossSearchTickV430(h,player,pb,pid)
            else if (Stage2PickupEnabledV9())
                FarmPickupFirstV75()
            return
        }
        px := NumGet(pb,2,"UShort"), py := NumGet(pb,6,"UShort")
        CoordDisplayPositionV1(px,py)
        room := NumGet(pb,0x1C,"UInt")
        if (!room)
        {
            AutoMonsterAttackLogV2("SKIP reason=ROOM_NOT_READY", true)
            return
        }
        if (!infoOnly && FarmStandResetTickV246(px,py,CoordLevelV14(h,room),pid))
            return
        inv := D2ReadU32(h,player+0x60)
        cursor := inv ? PickupCursorV4(h,inv) : -1
        if (!IsObject(cursor) || cursor.unit)
        {
            AutoMonsterAttackLogV2("SKIP reason=CURSOR_CHECK valid=" . IsObject(cursor) . " held=" . (IsObject(cursor) ? cursor.unit : -1), true)
            return
        }
        if (!infoOnly && BOFinalRouteActiveV451(pid))
        {
            BOFinalHuntTickV454(h,player,pb,pid)
            return
        }
        if (!infoOnly && RoomCoordinateModeV116() && !CainHuntLockedV404(pid,liveStage2LevelV381))
        {
            CoordRouteObserveV18(h,pb,pid)
            if (playerMode=4 || playerMode=7 || playerMode=8 || playerMode=9 || playerMode=10 || playerMode=11 || playerMode=12 || playerMode=13 || playerMode=14 || playerMode=15 || playerMode=18)
                coordRouteV16.lastBattleV118 := A_TickCount, coordRouteV16.stuckProbe := false
        }

        if (!infoOnly && !Stage2FightEnabledV9())
        {
            monsterCombatUidV45 := 0,monsterRoadAreaV51 := false,monsterChaseV44 := false
            CoordRouteObserveV18(h,pb,pid)
            if (Stage2PickupEnabledV9() && FarmPickupFirstV75())
                return
            if (!CoordStuckTickV84(h,pb,pid))
                CoordMoveWhenClearV14(h,pb,pid)
            return
        }

        if (!infoOnly && CainHuntLockedV404(pid,liveStage2LevelV381))
        {
            if (StateBuffTickV17(h,player,pb,pid))
                return
            if (CombatRecoverTickV48(h,pb,pid,false))
                return
            if (CainHuntBossTickV403(h,player,pb,pid))
                return
        }
        if (!infoOnly && farmControlOwnerV186="LIB" && LibFarmLevelV292(CoordLevelV14(h,NumGet(pb,0x1C,"UInt"))))
        {
            CoordRouteObserveV18(h,pb,pid)
            if (IsObject(coordRouteV16) && routePointsV724.Length()>0
                && coordRouteV16.phase="DONE" && coordRouteV16.anchor>=routePointsV724.Length())
            {
                PortalLogWriteV66("LIB_ROUTE_END last_row=" . coordRouteV16.anchor . " next=TOWN_SIG_THEN_STAGE3")
                MapStage2RouteFinishV185()
                return
            }
        }

        if (!infoOnly && cainNoFightV361)
        {
            if (StateBuffTickV17(h,player,pb,pid))
                return
            monsterCombatUidV45 := 0,monsterRoadAreaV51 := false
            CoordRouteObserveV18(h,pb,pid)
            if (!CoordStuckTickV84(h,pb,pid))
                CoordMoveWhenClearV14(h,pb,pid)
            return
        }
        if (!infoOnly && StateBuffTickV17(h,player,pb,pid))
            return
        if (!infoOnly && playerMode!=0 && playerMode!=17 && !IsObject(farmReviveV32)
            && !FarmReviveTownLevelV295(CoordLevelV14(h,NumGet(pb,0x1C,"UInt")))
            && CombatRecoverTickV48(h,pb,pid,false))
            return
        if (!infoOnly && CainHuntBossTickV403(h,player,pb,pid))
            return
        if (!infoOnly)
        {
            CoordRouteObserveV18(h,pb,pid)
        }


        if (!infoOnly && !IsObject(roomExploreV89) && PortalExitTickV69(h,player,pb,pid))
            return

        if (!infoOnly && BOCommonActiveV444(pid))
        {
            BOCombatRouteRebaseV488(pb,stage2FlowV380.searchV430)
            BOItemCenterUpdateV447(h,player,pb,pid)
        }
        scosScanV240 := CoordLevelV14(h,NumGet(pb,0x1C,"UInt"))=270
        scanRadiusV20 := MonsterScanRadiusV20(liveStage2LevelV381)
        if (IsObject(farmFightLockV626) && (farmFightLockV626.pid!=pid
            || farmFightLockV626.player!=player || farmFightLockV626.level!=liveStage2LevelV381))
            farmFightLockV626 := false
        if (IsObject(farmItemLockV625) && (farmItemLockV625.pid!=pid
            || farmItemLockV625.player!=player || farmItemLockV625.level!=liveStage2LevelV381))
            farmItemLockV625 := false
        if (!pickupImageOn || !Stage2PickupEnabledV9())
            farmItemLockV625 := false
        if (!infoOnly)
            farmGroundItemCountV710 := 0
        itemScanV902 := FarmFlowScanGroundItemsV902(h,player,pid,room,liveStage2LevelV381,px,py,infoOnly)
        itemOnRoad := itemScanV902.found,itemCx := itemScanV902.x,itemCy := itemScanV902.y
        attackArea := MonsterAttackAreaV48(h,pb)
        if (!infoOnly && !BOCommonActiveV444(pid) && !itemOnRoad
            && !FarmCenterPolicyV741(pid,liveStage2LevelV381))
        {
            savedAreaV627 := FarmRouteCombatAreaV627(pid,player,liveStage2LevelV381)
            if (IsObject(savedAreaV627))
                attackArea := savedAreaV627
        }
        playerCycleV741 := !infoOnly && FarmCenterPolicyV741(pid,liveStage2LevelV381)
        ; Farm B->C chi danh tai B: tin hieu item KHONG tao tam danh moi.
        ; ITEM_MOVE/PICKUP duoc FarmCenterCheck xu ly truoc bo quet quai.
        if (playerCycleV741)
        {
            ; Tai diem: tam quet = toa do diem. Gap quai tren duong:
            ; tam quet = vi tri nhan vat LUC PHAT HIEN, giu den khi danh sach.
            scanRadiusV20 := Max(1,MonsterRadiusGetV239())
            centerBCV910 := FarmCenterPendingV741(pid) ? farmCenterCycleV741 : FarmCenterCaptureV741(pid)
            roadCenterV2026 := IsObject(centerBCV910) && (centerBCV910.phase="ROAD_ATTACK"
                || (centerBCV910.phase="ATTACK" && centerBCV910.dispatchOriginV1190="ROAD_ATTACK"))
            centerXV910 := roadCenterV2026 ? centerBCV910.roadX_V2026
                : IsObject(centerBCV910) ? centerBCV910.x : px
            centerYV910 := roadCenterV2026 ? centerBCV910.roadY_V2026
                : IsObject(centerBCV910) ? centerBCV910.y : py
            attackArea := {x:centerXV910,y:centerYV910,radiusSq:scanRadiusV20**2
                ,source:(roadCenterV2026 ? "ROAD_PLAYER_CENTER" : "ROUTE_POINT_CENTER")
                ,row:(IsObject(centerBCV910) ? centerBCV910.row : 0)}
        }
        farmCombatAreaV590 := {pid:pid,level:liveStage2LevelV381,area:attackArea}

        rooms := (playerCycleV741 || itemOnRoad || IsObject(farmFightLockV626)) ? MonsterLoadedRoomsV20(h,room)
            : RoomFarmBoundaryV235() ? [room] : MonsterLoadedRoomsV20(h,room)
        seenRooms := {}, seenUnits := {}
        target := false, lockedTarget := false, bestPriorityV221 := false
        bestDist := 0x7FFFFFFF, total := 0, start := A_TickCount
        scanListV682 := []
        combatScanCompleteV626 := true
        ; V947: thong ke quai nam sat/duoi chan (khoang cach <= 2 o),
        ; KHONG bo qua quai trung toa do. Bao ly do neu loc khoi danh sach.
        nearFootSeenV947 := 0,nearFootEligibleV947 := 0
        nearFootClassV947 := 0,nearFootRetryV947 := 0
        nearFootAreaV947 := 0,nearFootRoadV947 := 0
        monsterPathErrorV947 := 0
        boRawNearV446 := 0,boExcludedNearV446 := 0,boRetryNearV446 := 0
        for _, r in rooms
        {
            if (seenRooms.HasKey(r))
                continue
            seenRooms[r] := true
            if (!MonsterBossProbeReadV1(h,r+0x74,4,combatHeadV626))
            {
                combatScanCompleteV626 := false
                continue
            }
            u := NumGet(combatHeadV626,0,"UInt")
            Loop, 1024
            {
                if (!u || seenUnits.HasKey(u) || total>=2048 || A_TickCount-start>150)
                    break
                seenUnits[u] := true
                total++
                if (!MonsterBossProbeReadV1(h,u,0xEC,ub))
                {
                    combatScanCompleteV626 := false
                    break
                }
                next := NumGet(ub,0xE8,"UInt")
                typ := NumGet(ub,0,"UInt"), mode := NumGet(ub,0x10,"UInt")
                uid := NumGet(ub,0x0C,"UInt"), path := NumGet(ub,0x2C,"UInt")
                if (typ=1 && uid && mode!=0 && mode!=12 && !MonsterBossProbeReadV1(h,path,0x20,mb))
                {
                    monsterPathErrorV947++
                    combatScanCompleteV626 := false
                    u := next
                    continue
                }
                if (typ=1 && uid && mode!=0 && mode!=12)
                {
                    x := NumGet(mb,2,"UShort"), y := NumGet(mb,6,"UShort")
                    dist := (x-px)*(x-px)+(y-py)*(y-py)
                    classV11 := NumGet(ub,4,"UInt")
                    excludedV11 := MonsterClassExcludedV11(classV11,h,u)
                    if (dist<=4)
                    {
                        nearFootSeenV947++
                        if (excludedV11)
                            nearFootClassV947++
                        else if (MonsterRetryExcludedV44(uid,x,y,CoordLevelV14(h,NumGet(mb,0x1C,"UInt")),pid))
                            nearFootRetryV947++
                        else if (!MonsterInsideAreaV48(x,y,attackArea))
                            nearFootAreaV947++
                        else if (!MonsterRoadEligibleV52(px,py,x,y))
                            nearFootRoadV947++
                        else
                            nearFootEligibleV947++
                    }
                    if (!infoOnly && BOCommonActiveV444(pid) && MonsterInsideAreaV48(x,y,attackArea))
                    {
                        boRawNearV446++
                        if (excludedV11)
                            boExcludedNearV446++
                        retryNearV446 := MonsterRetryExcludedV44(uid,x,y,CoordLevelV14(h,NumGet(mb,0x1C,"UInt")),pid)
                        if (retryNearV446)
                            boRetryNearV446++
                        PortalLogWriteV66("BO_NEAR_MONSTER uid=" . uid . " class=" . classV11
                            . " distance=" . Round(Sqrt(dist),2) . " excluded_class=" . excludedV11
                            . " retry_excluded=" . retryNearV446 . " mode=" . mode,"BO_NEAR_MONSTER_" . uid,1000)
                    }
                    if ((playerCycleV741 || itemOnRoad || !RoomFarmBoundaryV235() || RoomMonsterSameRoomV113(h,mb,pb))
                        && !excludedV11 && !MonsterRetryExcludedV44(uid,x,y,CoordLevelV14(h,NumGet(mb,0x1C,"UInt")),pid)
                        && MonsterInsideAreaV48(x,y,attackArea)
                        && (MonsterRoadEligibleV52(px,py,x,y)
                            || (uid=monsterCombatUidV45 && BossPriorityHasV221(classV11))))
                    {
                        candidate := {unit:u,uid:uid,path:path,dist:dist,x:x,y:y,level:CoordLevelV14(h,NumGet(mb,0x1C,"UInt")),priority:BossPriorityHasV221(classV11),cls:classV11}
                        if (!infoOnly)
                            scanListV682.Push(candidate)
                        if (monsterCombatUidV45 && uid=monsterCombatUidV45)
                            lockedTarget := candidate
                        rank := MonsterRoadRankV52(px,py,x,y,dist)
                        if ((candidate.priority && !bestPriorityV221) || (candidate.priority=bestPriorityV221 && rank<bestDist))
                            bestDist := rank, target := candidate,bestPriorityV221 := candidate.priority
                    }
                }
                u := next
                if (A_Index=1024 && u)
                    combatScanCompleteV626 := false
            }
            if (total>=2048 || A_TickCount-start>80)
            {
                combatScanCompleteV626 := false
                break
            }
        }
        combatScanCompleteV626 := FarmScanCompleteV742(combatScanCompleteV626,total,A_TickCount-start)
        if (infoOnly)
            return
        farmScanListV682 := scanListV682
        farmScanSelectedV682 := IsObject(target) ? target.uid : 0
        if (FarmCenterPendingV741(pid) && (IsObject(target) || !combatScanCompleteV626))
        {
            ; Co quai hoac luot quet khong day du: khong dem tiep chuoi quet rong.
            farmCenterCycleV741.attackEmptyCountV906 := 0
            farmCenterCycleV741.attackEmptyAtV906 := 0
        }
        parentInfoV771 := FarmCenterPendingV741(pid) ? farmCenterCycleV741 : false
                if (IsObject(parentInfoV771))
        {
            rowB := parentInfoV771.row
            rowC := IsObject(parentInfoV771.forwardV756) ? parentInfoV771.forwardV756.row : rowB + 1
            parentInfoTextV771 := (parentInfoV771.phase="ATTACK_FIRST" || parentInfoV771.phase="ATTACK_MORE" || parentInfoV771.phase="ATTACK")
                ? (IsObject(target) ? "ĐANG ĐÁNH | quét quái không giới hạn" : "ĐANG TÌM QUÁI | quét tiếp đến khi hết mục tiêu")
                : parentInfoV771.phase="ROAD_ATTACK" ? "QUÁI CẢN ĐƯỜNG | DỪNG ĐI, ĐÁNH QUANH NHÂN VẬT"
                : parentInfoV771.phase="ITEM_MOVE" ? "ĐANG ĐI VỀ VẬT PHẨM / XÉT KẸT"
                : parentInfoV771.phase="ITEM_ATTACK" ? "ĐANG ĐÁNH QUÁI QUANH VẬT PHẨM BK/2"
                : parentInfoV771.phase="PICKUP" ? "ĐÃ SẠCH QUÁI QUANH ĐỒ / CHỜ NHẶT"
                : parentInfoV771.phase="PICKUP_BUSY" ? "ĐANG NHẶT / CẤT VẬT PHẨM"
                : parentInfoV771.phase="CHECK" ? "ĐANG KIỂM TRA VỊ TRÍ DÒNG " . rowB
                : parentInfoV771.phase="RETURN" ? "ĐANG ĐIỀU CHỈNH VỊ TRÍ DÒNG " . rowB . " / " . rowC
                : parentInfoV771.phase="MOVE" ? "ĐANG CHUYỂN SANG DÒNG TIẾP THEO " . rowC
                : "QUY TRÌNH DÒNG " . rowB . " → " . rowC . ": " . parentInfoV771.phase
        }
        else
            parentInfoTextV771 := IsObject(target) ? "ĐÃ CHỌN MỤC TIÊU ĐÁNH" : "CHƯA CÓ QUÁI HỢP LỆ TRONG BK"
        FarmCombatViewV624(pid,target,parentInfoTextV771)
        ; V947: ghi DUNG MOI LAN QUET THUC TE, KHONG gioi han 1 lan/giay.
        ; Nhip timer la 250ms nhung khi busy thi khong co quet: log chi ghi cac lan THUC SU quet.
        scanPhaseV947 := IsObject(parentInfoV771) ? parentInfoV771.phase : "OTHER"
        scanRowV947 := IsObject(parentInfoV771) ? parentInfoV771.row : 0
        scanEmptyV947 := IsObject(parentInfoV771) ? parentInfoV771.attackEmptyCountV906 : 0
        scanDurationV947 := A_TickCount-start
        PortalLogWriteV66("COMBAT_SCAN_RESULT level=" . liveStage2LevelV381 . " row=" . scanRowV947
            . " phase=" . scanPhaseV947 . " rooms=" . seenRooms.Count()
            . " units=" . total . " candidates=" . scanListV682.Length()
            . " complete=" . combatScanCompleteV626 . " scan_ms=" . scanDurationV947
            . " area=" . attackArea.source . " center=" . attackArea.x . "," . attackArea.y
            . " player=" . px . "," . py . " empty_count=" . scanEmptyV947
            . " near_foot=" . nearFootSeenV947 . " foot_eligible=" . nearFootEligibleV947
            . " foot_skip_class=" . nearFootClassV947 . " foot_skip_retry=" . nearFootRetryV947
            . " foot_skip_area=" . nearFootAreaV947 . " foot_skip_road=" . nearFootRoadV947
            . " path_read_fail=" . monsterPathErrorV947
            . " target_uid=" . (IsObject(target) ? target.uid : 0)
            . " target_class=" . (IsObject(target) ? target.cls : 0), "COMBAT_SCAN_RESULT",0)
        if (combatScanCompleteV626 && !IsObject(target) && FarmParentAttackEmptyV767(pid))
            return
        incomingV711 := MonsterStuckIncomingV711(h,pid,liveStage2LevelV381,scanListV682,px,py)
        if (IsObject(incomingV711))
        {
            target := incomingV711,lockedTarget := incomingV711
            farmScanSelectedV682 := target.uid
        }
        if (BOCommonActiveV444(pid))
        {
            if (monsterCombatUidV45 && IsObject(lockedTarget))
                target := lockedTarget
            boScanCompleteV446 := combatScanCompleteV626
            BOCommonPublishV446(pid,target,boScanCompleteV446,px,py)
            PortalLogWriteV66("BO_SHARED_SCAN radius=" . scanRadiusV20 . " raw_near=" . boRawNearV446
                . " excluded_near=" . boExcludedNearV446 . " retry_near=" . boRetryNearV446
                . " target_uid=" . (IsObject(target) ? target.uid : 0) . " complete=" . boScanCompleteV446
                . " engine=COMMON_SCOS_CAIN","BO_SHARED_SCAN",1000)
            if (IsObject(target))
            {
                boCombatV479 := stage2FlowV380.searchV430
                monsterCombatUidV45 := target.uid
                if (BOCombatStopWalkV482(h,player,pb,boCombatV479))
                    return
                BossSearchHoldAttackV436(h,player,pb,boCombatV479,target)
                PortalLogWriteV66("BO_COMBAT_FIRST uid=" . target.uid . " class=" . target.cls
                    . " distance=" . Round(Sqrt(target.dist),2) . " movement=PAUSED pickup=WAIT", "BO_COMBAT_FIRST",1000)
                return
            }
            if (!boScanCompleteV446)
                return
            if (!IsObject(target))
            {
                if (BOPickupPriorityV421(h,player,pb,pid))
                    return
                boCombatV479 := stage2FlowV380.searchV430
                if (boCombatV479.afterCombatPickupV486)
                {
                    if (BOPickupPriorityV421(h,player,pb,pid))
                        return
                    if (BOCommonPickupGateV444(h,player,pb,pid)="WAIT")
                        return
                    boCombatV479.itemCenterV447 := false
                    BOCombatRouteRebaseV488(pb,boCombatV479,true)
                    boCombatV479.afterCombatPickupV486 := false,boCombatV479.fightOriginV488 := false
                    PortalLogWriteV66("BO_AFTER_COMBAT_PICKUP_DONE next=NEW_ZIGZAG_FROM_LIVE_POSITION")
                }
                BOCommonMoveV444(h,pb,pid)
                return
            }
        }

        if (playerCycleV741 && !IsObject(target) && combatScanCompleteV626)
        {
            if (!FarmCombatResumeV742(pid))
                return
        }
        if (!itemOnRoad && !IsObject(target) && IsObject(farmFightLockV626))
        {
            if (FarmRouteCombatClearV627(h,player,pid,pb))
                return
        }
        combatLocked := false
        if (monsterCombatUidV45 && !playerCycleV741)
        {
            if (IsObject(lockedTarget))
            {
                if (MonsterLockEligibleV308(lockedTarget.cls))
                    target := lockedTarget, combatLocked := true
                else
                    monsterCombatUidV45 := 0,monsterRoadAreaV51 := false,monsterChaseV44 := false
            }
            else
            {
                if (!combatScanCompleteV626)
                    return
                AutoMonsterAttackLogV2("COMBAT_UNLOCK uid=" . monsterCombatUidV45 . " reason=TARGET_GONE_EXCLUDED_OR_OUTSIDE_RADIUS")
                monsterCombatUidV45 := 0, monsterRoadAreaV51 := false
            }
        }
        if (farmControlOwnerV186="CAIN" && cainBossUidV361 && !cainBossKilledV361
            && combatScanCompleteV626)
        {
            bossSeen := false
            for _,r in rooms
            {
                uu := D2ReadU32(h,r+0x74)
                Loop, 4096
                {
                    if (!uu)
                        break
                    if (D2ReadU32(h,uu)=1 && D2ReadU32(h,uu+0x0C)=cainBossUidV361)
                    {
                        mm := D2ReadU32(h,uu+0x10)
                        if (mm!=0 && mm!=12)
                            bossSeen := true
                        break
                    }
                    nn := D2ReadU32(h,uu+0xE8)
                    if (nn=uu)
                        break
                    uu := nn
                }
                if (bossSeen)
                    break
            }
            if (!bossSeen)
            {
                cainBossKilledV361 := true
                AutoMonsterAttackLogV2("CAIN_BOSS_KILLED uid=" . cainBossUidV361 . " class=" . cainBossClassV361 . " next=OPEN_TOWN_PORTAL")
            }
        }
        if (IsObject(target) || !combatScanCompleteV626)
            farmLastCombatTickV72 := A_TickCount
        if (CombatLowHPAlternateV299(h,pb,pid,target))
        {
            PortalLogWriteV66("COMBAT_SKIP reason=HP_ALTERNATE target_uid=" . target.uid,"COMBAT_POST_SCAN_SKIP",1000)
            return
        }
        if (combatScanCompleteV626 && !IsObject(target))
        {
            if (CoordCastTickV50(h,player,pid))
                return
        }
        if (!ScosOrderedRouteV234() && IsObject(roomExploreV89) && IsObject(target) && target.dist>25)
        {
            monsterCombatUidV45 := 0, monsterRoadAreaV51 := false, monsterChaseV44 := false
            coordRouteV16.bypass := false
            coordNoTargetSinceV14 := A_TickCount-250
            AutoMonsterAttackLogV2("ROOM_APPROACH_MONSTER uid=" . target.uid . " distance=" . Round(Sqrt(target.dist),2)
                . " attack_distance=5 action=WALK_TO_NEAREST_MONSTER",true)
            CoordMoveWhenClearV14(h,pb,pid)
            return
        }
        travelling := IsObject(coordRouteV16) && coordRouteV16.phase="NEXT"
        engageLimitSq := travelling ? scanRadiusV20*scanRadiusV20 : 0
        if (itemOnRoad || IsObject(farmFightLockV626))
            engageLimitSq := 8589672450
                if (!IsObject(target) || (travelling && !scosScanV240 && !combatLocked && target.dist>engageLimitSq))
        {
            if (!IsObject(target) && Stage2PickupEnabledV9())
            {
                if (!infoOnly && itemOnRoad && FarmItemReturnV648(h,pb,pid,liveStage2LevelV381,px,py))
                    return
                if (FarmPickupFirstV75())
                    return
            }
            if (itemOnRoad)
                return
            if (IsObject(target))
                AutoMonsterAttackLogV2("TEST_CONTINUE_MOVE reason=NEAREST_MONSTER_TOO_FAR uid=" . target.uid
                    . " distance=" . Round(Sqrt(target.dist),2) . " engage_radius=CONFIGURED phase=TRAVEL priority=MOVE",true)
            else
                AutoMonsterAttackLogV2("SCAN reason=NO_LIVE_TARGET rooms=" . seenRooms.Count() . " units=" . total, true)
            if (CoordStuckTickV84(h,pb,pid))
                return
            if (IsObject(coordRouteV16) && coordRouteV16.phase="NEXT" && !coordRouteV16.firstMoveAttempted)
            {
                coordRouteV16.firstMoveAttempted := true
                coordNoTargetSinceV14 := A_TickCount-250
            }
            CoordMoveWhenClearV14(h,pb,pid)
            return
        }
        ; Combat scan khong duoc xoa timer xet ket dang di nhat vat pham.
        itemMovingV1801 := FarmCenterPendingV741(pid) && IsObject(farmCenterCycleV741)
            && farmCenterCycleV741.phase="ITEM_MOVE"
        if (IsObject(farmItemLockV625) && !itemMovingV1801)
            farmItemLockV625.returnGoalV655 := false
        if (IsObject(coordRouteV16) && !itemMovingV1801)
            coordRouteV16.escapeV84 := false,coordRouteV16.stuckProbe := false
        if (cainNoFightV361)
        {
            AutoMonsterAttackLogV2("CAIN_SKIP_TRASH uid=" . target.uid . " class=" . target.cls . " continue_route=1",true)
            CoordMoveWhenClearV14(h,pb,pid)
            return
        }
        if (farmControlOwnerV186="CAIN" && !cainNoFightV361 && BossPriorityHasV221(target.cls))
        {
            if (cainBossUidV361 != target.uid)
            {
                cainBossUidV361 := target.uid
                cainBossClassV361 := target.cls
                cainBossKilledV361 := false
                AutoMonsterAttackLogV2("CAIN_BOSS_ENGAGE uid=" . target.uid . " class=" . target.cls)
            }
        }
        AutoMonsterAttackLogV2("TARGET_SELECTED uid=" . target.uid . " boss_priority=" . target.priority . " class=" . target.cls . " distance=" . Round(Sqrt(target.dist),2)
            . " radius=" . scanRadiusV20 . " bypass=" . (IsObject(coordRouteV16) ? coordRouteV16.bypass : 0)
            . " closest_goal=" . (IsObject(coordRouteV16) ? coordRouteV16.closestGoalDistance : -1) . " route_movement=PAUSED",true)
        targetHP := MonsterBossProbeHPV2(h,D2ReadU32(h,target.unit+0x5C))
        hpRaw := targetHP.ok ? targetHP.raw : -1

        ; Active farm target: start the configured stuck clock even if a key or
        ; packet is temporarily blocked by game focus or packet dispatch.
        if (!MonsterChaseProgressV44(target.uid,px,py,target.dist,hpRaw,target.x,target.y,target.level,pid,h,target.unit,true))
        {
            currentAttackDistV523 := Round(Sqrt(target.dist),1)
            AttackIdTipV12(D2ReadU32(h,target.unit+4),currentAttackDistV523)
            monsterCombatUidV45 := 0, monsterRoadAreaV51 := false
            if (IsObject(roomExploreV89))
            {
                RoomWalkBlockedV107(roomExploreV89,"MONSTER_NO_PROGRESS")
                AutoMonsterAttackLogV2("ROOM_TARGET_BLOCKED uid=" . target.uid . " teleport=OFF next=RETURN_PREVIOUS_ROOM")
                return
            }
            if (IsObject(coordRouteV16))
            {
                coordRouteV16.bypass := true
                if (coordRouteV16.phase="CLEAR" && coordRouteV16.next<routePointsV724.Length())
                    coordRouteV16.next++, coordRouteV16.phase := "NEXT"
                coordRouteV16.lastDispatch := 0
            }
            coordNoTargetSinceV14 := A_TickCount-250
            if (IsObject(coordRouteV16))
                coordRouteV16.escapeV84 := false,coordRouteV16.stuckProbe := false
            ; At B: skip the stuck monster and rescan other B targets next tick.
            ; Only the normal empty-area confirmation is allowed to start MOVE to C.
            if (!playerCycleV741 && !itemOnRoad && !IsObject(farmFightLockV626))
                CoordMoveWhenClearV14(h,pb,pid)
            return
        }
        coordNoTargetSinceV14 := 0
        if (IsObject(coordRouteV16))
            coordRouteV16.stuckProbe := false
        CoordRouteBattleV16()
        if (!autoMonsterAttackOn || zRunning || xRunning
            || gameItemActionOwner!="" || GameTargetHwndV63()!=hwnd)
            return
        if (!MonsterBossProbeReadV1(h,target.unit,0x30,finalUnit))
            return
        finalMode := NumGet(finalUnit,0x10,"UInt")
        if (NumGet(finalUnit,0,"UInt")!=1 || NumGet(finalUnit,0x0C,"UInt")!=target.uid
            || finalMode=0 || finalMode=12)
            return
        path := NumGet(finalUnit,0x2C,"UInt")
        if (!MonsterBossProbeReadV1(h,path,0x20,mb))
            return
        lockEligibleV308 := MonsterLockEligibleV308(NumGet(finalUnit,4,"UInt"))
        if (!lockEligibleV308 && monsterCombatUidV45=target.uid)
            monsterCombatUidV45 := 0,monsterRoadAreaV51 := false
        finalX := NumGet(mb,2,"UShort"), finalY := NumGet(mb,6,"UShort")
        finalDistance := (finalX-px)*(finalX-px)+(finalY-py)*(finalY-py)
                bossLockActiveV1 := combatLocked && BossPriorityHasV221(target.cls)
        if ((!playerCycleV741 && !itemOnRoad && RoomFarmBoundaryV235() && !RoomMonsterSameRoomV113(h,mb,pb))
            || (travelling && !scosScanV240 && !combatLocked && finalDistance>engageLimitSq)
            || (!MonsterInsideAreaV48(finalX,finalY,attackArea) || !MonsterRoadEligibleV52(px,py,finalX,finalY)))
            return
        Critical, On
        if (autoMonsterAttackOn && !packetWatchArmedV1 && !zRunning && !xRunning
            && gameItemActionOwner="" && GameTargetHwndV63()=hwnd && D2GetActiveGamePidV95()=pid)
        {
            queued := AutoMonsterPacketSendV1(pid,target.unit,target.uid)
            ; Queued=0 is NOT combat progress. MonsterChaseProgressV44 above
            ; owns the single configured combat-stuck timeout and UID/room lock.
            ; Do not run a second watchdog that could change B combat prematurely.
            if (queued)
            {
                currentAttackDistV523 := Round(Sqrt(target.dist),1)
                AttackIdTipV12(NumGet(finalUnit,4,"UInt"),currentAttackDistV523)
                currentAttackUidV520 := target.uid
                currentAttackClassV520 := NumGet(finalUnit,4,"UInt")
                currentAttackX_V520 := finalX
                currentAttackY_V520 := finalY
                currentAttackAtV520 := A_TickCount
            }
            if (queued && FarmCenterPendingV741(pid))
                farmCenterCycleV741.attacked := true
            if (queued && IsObject(monsterChaseV44) && monsterChaseV44.uid=target.uid)
            {
                if (!monsterChaseV44.since)
                    monsterChaseV44.since := A_TickCount
                monsterChaseV44.queued++
            }
            if (queued && lockEligibleV308 && monsterCombatUidV45!=target.uid)
            {
                monsterCombatUidV45 := target.uid
                if (travelling)
                    monsterRoadAreaV51 := {x:px,y:py,radiusSq:scanRadiusV20*scanRadiusV20,source:"ROAD_ENCOUNTER",row:0,level:CoordLevelV14(h,room)}
                AutoMonsterAttackLogV2("COMBAT_LOCK uid=" . target.uid . " class=" . target.cls . " reason=KEEP_CURRENT_TARGET coordinate_movement=PAUSED until=TARGET_GONE_OUTSIDE_RADIUS_OR_ROOM_LOCK")
            }
            if (queued && !lockEligibleV308)
            {
                monsterCombatUidV45 := 0,monsterRoadAreaV51 := false,monsterChaseV44 := false
                burstKeyV1 := pid . "|" . CoordLevelV14(h,room) . "|" . target.uid
                burstCountV1 := nonBossBurstCountsV1.HasKey(burstKeyV1) ? nonBossBurstCountsV1[burstKeyV1]+1 : 1
                if (burstCountV1>=2)
                {
                    nonBossBurstCountsV1.Delete(burstKeyV1)
                    MonsterStuckUidSkipV711(target.uid,CoordLevelV14(h,room),pid)
                    AutoMonsterAttackLogV2("NON_BOSS_BURST_DONE uid=" . target.uid . " attacks=2 tracking=OFF skip_seconds=" . Max(1,monsterLockRoomSecV622) . " next=ROUTE_OR_NEXT_TARGET",true)
                }
                else
                    nonBossBurstCountsV1[burstKeyV1] := burstCountV1
            }
            if (queued && !lockEligibleV308 && RoomFarmBoundaryV235())
            {
                coordRouteV16.stuckProbe := false
                AutoMonsterAttackLogV2("ROOM_FREE_ATTACK uid=" . target.uid . " target_lock=OFF next=FRESH_NEAREST_SCAN",true)
            }
            AutoMonsterAttackLogV2("AUTO_NATIVE_RIGHT_CLICK uid=" . target.uid . " class=" . NumGet(finalUnit,4,"UInt")
                . " method=D2CLIENT_RIGHT_DOWN_UP queued=" . queued
                . " priority=" . (target.priority ? "LISTED_BOSS_ID" : "NEAREST_TO_PLAYER") . " phase=" . (travelling ? "TRAVEL_CLOSE_COMBAT" : "FOCUS_COMBAT")
                . " scan=ALL_LOADED_ROOMS radius_map=" . scanRadiusV20 . " area=" . (IsObject(attackArea) ? attackArea.source : "TRAVEL_NEAR_PLAYER")
                . " distance=" . Round(Sqrt(target.dist),2) . " mouse_moved=0")
        }
        Critical, Off
    }
    finally
    {
        farmCombatAreaV590 := previousAreaV590
        Critical, Off
        DllCall("CloseHandle","Ptr",h)
    }
}

PacketWatchTimerV1:
if (!ManualLogActiveV81())
{
    SetTimer, PacketWatchTimerV1, Off
    return
}
Critical, On
if (!packetWatchArmedV1 || !pickupCubeTraceUntil || A_TickCount>=pickupCubeTraceUntil)
{
    PacketWatchStopV1()
    Critical, Off
    return
}
if (!IsObject(packetWatchV1))
{
    pidPacket := D2GetActiveGamePidV95()
    if (pidPacket)
        PacketWatchStartV1(pidPacket)
}
if (IsObject(packetWatchV1))
    PacketWatchPollV1()
Critical, Off
return

PacketWatchLogV1(message)
{
    if (!ManualLogActiveV81())
        return
    global pickupCubeTraceUntil,sigCubeCaptureV151,wpCaptureV161
    if (!pickupCubeTraceUntil || A_TickCount>=pickupCubeTraceUntil)
        return
    log := IsObject(wpCaptureV161) ? A_ScriptDir . "\Auto-GSF-Cong-Len-Map.log" : DebugTraceFile(IsObject(sigCubeCaptureV151) ? "cube" : "packet")
    ManualLogAppendV81(A_Now . " tick=" . A_TickCount . " | " . message . "`r`n", log, "UTF-8")
}

PacketWatchGetContextV1(hThread, ByRef context)
{
    VarSetCapacity(context,716,0)
    NumPut(0x10017,context,0,"UInt")
    fn := A_PtrSize=8 ? "Wow64GetThreadContext" : "GetThreadContext"
    return DllCall(fn,"Ptr",hThread,"Ptr",&context)
}

PacketWatchSetContextV1(hThread, ByRef context)
{
    fn := A_PtrSize=8 ? "Wow64SetThreadContext" : "SetThreadContext"
    return DllCall(fn,"Ptr",hThread,"Ptr",&context)
}

PacketWatchStartV1(pid)
{
    if (!ManualLogActiveV81())
        return false
    global packetWatchV1, packetWatchArmedV1, nativeAttackProbeV5
    base := D2GetModuleBaseV35(pid,nativeAttackProbeV5 ? "D2Client.dll" : "D2Net.dll")
    h := base ? DllCall("OpenProcess","UInt",0x0410,"Int",0,"UInt",pid,"Ptr") : 0
    if (!h)
    {
        PacketWatchLogV1("CAPTURE_ERROR stage=OPEN_PROCESS err=" . A_LastError)
        packetWatchArmedV1 := false
        return false
    }
    if (nativeAttackProbeV5 && !NativeAttackBuildV5(h,base))
    {
        PacketWatchLogV1("ATTACK_PROBE_SKIP reason=DLL_BUILD_MISMATCH")
        DllCall("CloseHandle","Ptr",h)
        packetWatchArmedV1 := false
        return false
    }
    if (!DllCall("DebugActiveProcess","UInt",pid))
    {
        PacketWatchLogV1("CAPTURE_ERROR stage=DEBUG_ATTACH err=" . A_LastError . " packet_capture=NOT_STARTED")
        DllCall("CloseHandle","Ptr",h)
        packetWatchArmedV1 := false
        return false
    }
    packetWatchV1 := {pid:pid,h:h,send:base+(nativeAttackProbeV5 ? 0x1A060 : 0x7650),attackProbe:nativeAttackProbeV5,threads:{},count:0
        ,initialBreak:false,initialWowBreak:false,lastRight:false,failed:false,mainTid:0}
    if (!DllCall("DebugSetProcessKillOnExit","Int",false))
    {
        PacketWatchLogV1("CAPTURE_ERROR stage=KEEP_GAME_ALIVE err=" . A_LastError)
        PacketWatchStopV1()
        return false
    }
    PacketWatchLogV1("ATTACHED pid=" . pid . " send_entry=" . V92Hex(packetWatchV1.send)
        . " attack_probe=" . nativeAttackProbeV5 . " capture=ACTUAL_FUNCTION_ARGUMENTS no_packet_sent_by_probe=1")
    return true
}

PacketWatchThreadV1(tid)
{
    global packetWatchV1
    w := packetWatchV1
    if (w.threads.HasKey(tid))
        return w.threads[tid]
    ht := DllCall("OpenThread","UInt",0x1A,"Int",false,"UInt",tid,"Ptr")
    if (!ht || !PacketWatchGetContextV1(ht,context))
    {
        if (ht)
            DllCall("CloseHandle","Ptr",ht)
        PacketWatchLogV1("THREAD_SKIP tid=" . tid . " reason=CONTEXT_READ err=" . A_LastError)
        return false
    }
    dr7 := NumGet(context,24,"UInt")
    if (dr7 & 3)
    {
        PacketWatchLogV1("THREAD_SKIP tid=" . tid . " reason=DR0_ALREADY_USED")
        DllCall("CloseHandle","Ptr",ht)
        return false
    }
    t := {h:ht,dr0:NumGet(context,4,"UInt"),dr6:NumGet(context,20,"UInt"),dr7:dr7}
    NumPut(w.send,context,4,"UInt")
    NumPut(0,context,20,"UInt")
    NumPut((dr7 & 0xFFF0FFFC) | 1,context,24,"UInt")
    if (!PacketWatchSetContextV1(ht,context))
    {
        PacketWatchLogV1("THREAD_SKIP tid=" . tid . " reason=CONTEXT_SET err=" . A_LastError)
        DllCall("CloseHandle","Ptr",ht)
        return false
    }
    w.threads[tid] := t
    PacketWatchLogV1("THREAD_ARMED tid=" . tid)
    return t
}

PacketWatchPollV1()
{
    global packetWatchV1
    if (!IsObject(packetWatchV1))
        return
    w := packetWatchV1
    Loop, 64
    {
        VarSetCapacity(event,192,0)
        if (!DllCall("WaitForDebugEvent","Ptr",&event,"UInt",0))
            break
        code := NumGet(event,0,"UInt"), pid := NumGet(event,4,"UInt"), tid := NumGet(event,8,"UInt")
        uoff := A_PtrSize=8 ? 16 : 12
        status := 0x10002
        try
        {
            if (code=3 || code=2)
            {
                if (code=3)
                {
                    fileHandle := NumGet(event,uoff,"Ptr")
                    if (fileHandle)
                        DllCall("CloseHandle","Ptr",fileHandle)
                }
                if (code=3)
                {
                    w.mainTid := tid
                    PacketWatchThreadV1(tid)
                    PacketWatchLogV1("MAIN_THREAD tid=" . tid . " tool_actions=PAUSED")
                }
            }
            else if (code=6)
            {
                fileHandle := NumGet(event,uoff,"Ptr")
                if (fileHandle)
                    DllCall("CloseHandle","Ptr",fileHandle)
            }
            else if (code=4)
            {
                if (w.threads.HasKey(tid))
                {
                    DllCall("CloseHandle","Ptr",w.threads[tid].h)
                    w.threads.Delete(tid)
                }
            }
            else if (code=1)
            {
                exception := NumGet(event,uoff,"UInt")
                status := 0x80010001
                if ((exception=0x80000004 || exception=0x4000001E) && w.threads.HasKey(tid))
                {
                    t := w.threads[tid]
                    exceptionAddress := NumGet(event,uoff+(A_PtrSize=8 ? 16 : 12),"Ptr")
                    if (exceptionAddress=w.send)
                    {
                        status := 0x10002
                        w.failed := true
                        PacketWatchLogV1("BREAKPOINT_HIT tid=" . tid)
                    }
                    if (PacketWatchGetContextV1(t.h,context)
                        && NumGet(context,184,"UInt")=w.send && (NumGet(context,20,"UInt") & 1))
                    {
                        status := 0x10002
                        w.failed := false
                        esp := NumGet(context,196,"UInt")
                        if (w.attackProbe)
                            NativeAttackCaptureV5(w,esp)
                        else if (MonsterBossProbeReadV1(w.h,esp,16,args))
                        {
                            len := NumGet(args,4,"UInt"), arg1 := NumGet(args,8,"UInt")
                            ptr := NumGet(args,12,"UInt")
                            right := GetKeyState("RButton","P")
                            MouseGetPos, mouseXPacket, mouseYPacket
                            if (len>0 && len<=4096 && MonsterBossProbeReadV1(w.h,ptr,Min(len,128),packet))
                            {
                                w.count++
                                PacketWatchLogV1("SEND n=" . w.count . " tid=" . tid . " len=" . len
                                    . " arg1=" . arg1 . " opcode=" . Format("{:02X}",NumGet(packet,0,"UChar"))
                                    . " hex=" . MonsterBossProbeHexV1(packet,Min(len,128))
                                    . " truncated=" . (len>128) . " physical_RButton=" . right
                                    . " active_game=" . (D2GetActiveGamePidV95()=w.pid)
                                    . " mouse=" . mouseXPacket . "," . mouseYPacket)
                            }
                            else
                                PacketWatchLogV1("SEND_READ_FAIL len=" . len . " ptr=" . V92Hex(ptr))
                        }
                        NumPut(NumGet(context,192,"UInt") | 0x10000,context,192,"UInt")
                        NumPut(NumGet(context,20,"UInt") & 0xFFFFFFFE,context,20,"UInt")
                        if (!PacketWatchSetContextV1(t.h,context))
                        {
                            w.failed := true
                            PacketWatchLogV1("CAPTURE_ERROR stage=RESUME_CONTEXT tid=" . tid . " err=" . A_LastError)
                        }
                    }
                }
                else if (exception=0x80000003 && !w.initialBreak)
                {
                    w.initialBreak := true
                    status := 0x10002
                }
                else if (exception=0x4000001F && !w.initialWowBreak)
                {
                    w.initialWowBreak := true
                    status := 0x10002
                }
            }
            else if (code=5)
            {
                w.failed := true
                PacketWatchLogV1("PROCESS_EXIT code=" . NumGet(event,uoff,"UInt"))
            }
        }
        catch packetProbeError
        {
            w.failed := true
            PacketWatchLogV1("CAPTURE_ERROR stage=EVENT_PROCESSING message=" . packetProbeError.Message)
        }
        finally
        {
            if (!DllCall("ContinueDebugEvent","UInt",pid,"UInt",tid,"UInt",status))
            {
                w.failed := true
                PacketWatchLogV1("CAPTURE_ERROR stage=CONTINUE_DEBUG_EVENT err=" . A_LastError)
            }
        }
        if (w.failed)
        {
            PacketWatchStopV1()
            return
        }
    }
    right := GetKeyState("RButton","P")
    if (right && !w.lastRight && D2GetActiveGamePidV95()=w.pid)
    {
        MouseGetPos, mxPacket, myPacket
        PacketWatchLogV1("MANUAL_RBUTTON_DOWN mouse=" . mxPacket . "," . myPacket)
    }
    w.lastRight := right
}

PacketWatchStopV1()
{
    global packetWatchV1, packetWatchArmedV1, nativeAttackProbeV5
    nativeAttackProbeV5 := false
    packetWatchArmedV1 := false
    BackgroundHotkeyV63("~*RButton","","Off UseErrorLevel")
    SetTimer, PacketWatchTimerV1, Off
    if (!IsObject(packetWatchV1))
        return
    w := packetWatchV1
    for tid,t in w.threads
    {
        suspended := DllCall("SuspendThread","Ptr",t.h,"UInt")
        if (suspended!=0xFFFFFFFF)
        {
            try
            {
                if (PacketWatchGetContextV1(t.h,context))
                {
                    NumPut(t.dr0,context,4,"UInt")
                    NumPut(t.dr6,context,20,"UInt")
                    NumPut(t.dr7,context,24,"UInt")
                    if (!PacketWatchSetContextV1(t.h,context))
                        PacketWatchLogV1("RESTORE_ERROR tid=" . tid . " err=" . A_LastError)
                }
                else
                    PacketWatchLogV1("RESTORE_ERROR tid=" . tid . " reason=CONTEXT_READ")
            }
            finally
                DllCall("ResumeThread","Ptr",t.h)
        }
        DllCall("CloseHandle","Ptr",t.h)
    }
    detached := DllCall("DebugActiveProcessStop","UInt",w.pid)
    PacketWatchLogV1("CAPTURE_END packets=" . w.count . " failed=" . w.failed . " detach_ok=" . detached . " tool_actions=RESUMED")
    DllCall("CloseHandle","Ptr",w.h)
    packetWatchV1 := false
}

PacketWatchRightButtonV2:
if (!packetWatchArmedV1 || !IsGameActive())
    return
MouseGetPos, clickPacketX, clickPacketY
PacketWatchLogV1("MANUAL_RBUTTON_DOWN source=PASS_THROUGH_HOTKEY mouse=" . clickPacketX . "," . clickPacketY)
return

AutoMonsterPacketCleanupTimerV1:
AutoMonsterPacketCleanupV1()
return

AutoMonsterPacketCleanupV1(onExit := false)
{
    global autoMonsterPacketPendingV1,farmAttackHoldV15,autoMonsterAttackOn,backgroundPidV63
    pending := autoMonsterPacketPendingV1
    if (onExit)
    {
        if (IsObject(farmAttackHoldV15))
            farmAttackHoldV15.releaseV15 := true
        if (IsObject(pending) && pending.holdDownV15)
            pending.releaseV15 := true
    }
    if (!IsObject(pending))
    {
        if (IsObject(farmAttackHoldV15) && farmAttackHoldV15.releaseV15)
            return FarmAttackHoldReleaseV15()
        SetTimer, AutoMonsterPacketCleanupTimerV1, Off
        return !RemoteThreadBusyV740(backgroundPidV63)
    }
    wait := DllCall("WaitForSingleObject","Ptr",pending.thread,"UInt",0)
    if (wait!=0 && RemoteProcessEndedV740(pending.process))
    {
        DllCall("CloseHandle","Ptr",pending.thread)
        DllCall("CloseHandle","Ptr",pending.process)
        autoMonsterPacketPendingV1 := false,farmAttackHoldV15 := false
        SetTimer, AutoMonsterPacketCleanupTimerV1, Off
        return false
    }
    if (wait!=0 && !onExit && pending.HasKey("setAt") && A_TickCount-pending.setAt>1500)
    {
        if (!pending.timeoutReportedV655)
        {
            pending.timeoutReportedV655 := true
            DebugTraceWrite("packet","PENDING_TIMEOUT_TRACKED kind=" . pending.kind . " uid=" . pending.uid)
            FonInfoPushV385("Lệnh game chưa kết thúc; giữ thứ tự lệnh, Đứng lâu xử lý nếu không phục hồi.")
        }
        return false
    }
    if (wait!=0 && !onExit)
        return false
    if (wait=0 && pending.holdDownV15)
    {
        DllCall("CloseHandle","Ptr",pending.thread)
        farmAttackHoldV15 := pending
        autoMonsterPacketPendingV1 := false
        SetTimer, AutoMonsterPacketCleanupTimerV1, Off
        if (onExit || pending.releaseV15 || !autoMonsterAttackOn)
            return FarmAttackHoldReleaseV15()
        return true
    }
    if (wait=0)
    {
        if (pending.moveCall && MonsterBossProbeReadV1(pending.process,pending.remote+(pending.resultOffsetV503 ? pending.resultOffsetV503 : 192),24,moveResult))
        {
            prepResult := NumGet(moveResult,0,"UInt"), helperResult := NumGet(moveResult,4,"UInt")
            AutoMonsterAttackLogV2("MAP_MOVE_THREAD_END prepare_return=" . prepResult
                . " helper_return=" . (helperResult=0xFFFFFFFF ? "NOT_CALLED" : helperResult)
                . " prepared_point=" . NumGet(moveResult,8,"UInt") . "," . NumGet(moveResult,12,"UInt")
                . " path_points=" . NumGet(moveResult,16,"UInt") . " path_type=" . NumGet(moveResult,20,"UInt")
                . " effect=UNCONFIRMED")
        }
        if (pending.dispatchV9 && MonsterBossProbeReadV1(pending.process,pending.remote+192,24,resultV9))
            NativeDispatchLogV10(pending.autoCall,"NATIVE_RIGHT_DISPATCH_RESULT uid=" . pending.uid
                . " down_return=" . NumGet(resultV9,0,"UInt") . " up_return=" . NumGet(resultV9,4,"UInt")
                . " prepared_flags=" . NumGet(resultV9,8,"UInt") . " resolved_target=" . V92Hex(NumGet(resultV9,12,"UInt"))
                . " prepared_skill=" . V92Hex(NumGet(resultV9,16,"UInt")) . " attack_gate_before=" . NumGet(resultV9,20,"UInt")
                . " return_is_not_cast_confirmation=1")
        if (!pending.autoCall && (pending.kind="UNIT_TEST" || pending.kind="MAP_TEST"))
        {
            testPidV8 := DllCall("GetProcessId","Ptr",pending.process,"UInt")
            testBaseV8 := D2GetModuleBaseV35(testPidV8,"D2Client.dll")
            if (testBaseV8)
                NativeAttackStateV8(pending.process,testBaseV8,"AFTER_CALL")
        }
        DllCall("VirtualFreeEx","Ptr",pending.process,"Ptr",pending.remote,"UPtr",0,"UInt",0x8000)
        DllCall("GetExitCodeThread","Ptr",pending.thread,"UIntP",exitCode)
        if (pending.dispatchV9)
            NativeDispatchLogV10(pending.autoCall,"NATIVE_" . (pending.autoCall ? "AUTO_UNIT" : pending.kind="UNIT_TEST" ? "UNIT" : "MAP") . "_THREAD_END uid=" . pending.uid
                . " exit_code=" . exitCode . " completed=1 effect=UNCONFIRMED")
        else if (pending.portalCall)
            PortalLogWriteV66("PORTAL_DLL_THREAD_END uid=" . pending.uid . " exit_code=" . exitCode . " completed=1 effect=WAIT_MAP_CHANGE")
        else if (pending.moveCall)
            AutoMonsterAttackLogV2("MAP_MOVE_THREAD_EXIT exit_code=" . exitCode . " completed=1 effect=UNCONFIRMED")
        else
            AutoMonsterAttackLogV2("AUTO_CLIENT_CLICK_THREAD_END uid=" . pending.uid . " exit_code=" . exitCode . " completed=1 hit=UNCONFIRMED")
    }
    DllCall("CloseHandle","Ptr",pending.thread)
    DllCall("CloseHandle","Ptr",pending.process)
    autoMonsterPacketPendingV1 := false
    SetTimer, AutoMonsterPacketCleanupTimerV1, Off
    return (wait=0)
}

RoomStandLogV114(h,player,ByRef pb,pid,mode)
{
    global coordSavedV15
    global roomExploreV89,coordRouteV16,coordCastPendingV50,portalBuffV85,portalExitPendingV69,portalBackPendingV74
    global xRunning,zRunning,gameItemActionOwner,monsterRetryUntilV44,monsterRadiusV48,autoMonsterAttackOn
    static last := 0
    if (!ManualLogActiveV81() || A_TickCount-last<1000)
        return
    last := A_TickCount
    px := NumGet(pb,2,"UShort"), py := NumGet(pb,6,"UShort"), room1 := NumGet(pb,0x1C,"UInt")
    room2 := room1 ? D2ReadU32(h,room1+0x10) : 0, level := CoordLevelV14(h,room1)
    r := roomExploreV89, route := coordRouteV16, file := RoomProfileFileV108()
    RoomExploreLogV89("ROOM_STAND_STATE pid=" . pid . " farm=" . autoMonsterAttackOn . " room_farm=" . IsObject(r) . " coordinate_map=" . RoomCoordinateModeV116()
        . " map=" . level . " room2=" . V92Hex(room2) . " player=" . px . "," . py . " mode=" . mode . " file=" . file
        . " yellow_row=" . CoordYellowIndexV48() . " replay_index=" . r.routeReplayIndex . " phase=" . route.phase
        . " goal_room=" . V92Hex(r.target) . " goal_uid=" . r.goalUid . " goal_kind=" . r.goalKind
        . " walking_ms=" . r.travelMs . " returning=" . r.backtracking . " fallback=" . r.routeFallback
        . " portal_pending=" . coordCastPendingV50 . " clear_pending=" . r.pendingClearRoom
        . " portal_buff=" . IsObject(portalBuffV85) . " portal_exit=" . IsObject(portalExitPendingV69)
        . " portal_back=" . IsObject(portalBackPendingV74) . " x_running=" . xRunning . " z_running=" . zRunning . " item_owner=" . gameItemActionOwner)
    if (RoomCoordinateModeV116() && IsObject(route) && route.next>=1 && route.next<=coordSavedV15.Length())
    {
        goalV124 := coordSavedV15[route.next]
        RoomExploreLogV89("ROOM_STAND_COORD_NEXT row=" . route.next . " room_number=" . goalV124.roomNumber
            . " center=" . goalV124.x . "," . goalV124.y . " anchor=" . route.anchor)
    }
    if (!IsObject(r) && !RoomCoordinateModeV116())
    {
        section := "Route-" . level
        IniRead, format, %file%, %section%, Format, MISSING
        IniRead, count, %file%, %section%, Count, 0
        RoomExploreLogV89("ROOM_STAND_ROUTE_NOT_ACTIVE file_exists=" . (FileExist(file)!="") . " format=" . format . " count=" . count
            . " reason=CHECK_MAP_LEVEL_OR_START_ROOM_IN_SAVED_ROUTE")
    }
    if (IsObject(r.routeReplay) && r.routeReplayIndex<=r.routeReplay.Length())
    {
        step := r.routeReplay[r.routeReplayIndex], known := 0, loaded := 0
        for address,node in r.nodes
            if (node.routeNumber=step.number)
                known := address, loaded := node.r1!=0
        RoomExploreLogV89("ROOM_STAND_NEXT row=" . r.routeReplayIndex . " room_number=" . step.number
            . " center=" . step.x . "," . step.y . " known_room=" . V92Hex(known) . " loaded=" . loaded
            . " blocked=" . r.closedBranches.HasKey(known) . " total=" . r.routeReplay.Length())
    }
    node := RoomExploreReadV89(h,room2,level)
    if (!IsObject(node))
    {
        RoomExploreLogV89("ROOM_STAND_SCAN reason=CURRENT_ROOM_READ_FAILED")
        return
    }
    scan := RoomLiveGoalV90(h,node,px,py)
    reason := scan.incomplete ? "SCAN_INCOMPLETE" : scan.count ? (IsObject(scan.best) ? "LIVE_CURRENT_ROOM_MONSTER" : "LIVE_BUT_NO_ELIGIBLE_TARGET") : "CURRENT_ROOM_CLEAR"
    RoomExploreLogV89("ROOM_STAND_SCAN live=" . scan.count . " incomplete=" . scan.incomplete . " reason=" . reason
        . " nearest_uid=" . scan.best.uid . " nearest_xy=" . scan.best.x . "," . scan.best.y
        . " rect=" . node.x . "," . node.y . "," . node.w . "," . node.h)
    u := node.r1 ? D2ReadU32(h,node.r1+0x74) : 0, seen := {}, n := 0, shown := 0
    while (u && n<256 && shown<12 && !seen.HasKey(u))
    {
        seen[u] := true, n++
        if (!MonsterBossProbeReadV1(h,u,0xEC,ub))
            break
        next := NumGet(ub,0xE8,"UInt"), typ := NumGet(ub,0,"UInt"), cls := NumGet(ub,4,"UInt"), uid := NumGet(ub,12,"UInt"), unitMode := NumGet(ub,16,"UInt")
        if (typ=1 && unitMode!=0 && unitMode!=12)
        {
            shown++, valid := MonsterBossProbeReadV1(h,NumGet(ub,0x2C,"UInt"),0x20,mp)
            mx := valid ? NumGet(mp,2,"UShort") : -1, my := valid ? NumGet(mp,6,"UShort") : -1
            same := valid && RoomMonsterSameRoomV113(h,mp,pb)
            retry := IsObject(monsterRetryUntilV44) && monsterRetryUntilV44.HasKey(uid) ? Max(0,monsterRetryUntilV44[uid]-A_TickCount) : 0
            RoomExploreLogV89("ROOM_STAND_MONSTER uid=" . uid . " class=" . cls . " mode=" . unitMode . " xy=" . mx . "," . my
                . " path_valid=" . valid . " same_room=" . same . " pet=" . MonsterClassExcludedV11(cls,h,u)
                . " distance=" . (valid ? Round(Sqrt((mx-px)**2+(my-py)**2),1) : -1) . " radius=" . monsterRadiusV48 . " retry_ms=" . retry)
        }
        u := next
    }
}

RoomMonsterSameRoomV113(h,ByRef monsterPath,ByRef playerPath)
{
    monsterRoom1 := NumGet(monsterPath,0x1C,"UInt"), playerRoom1 := NumGet(playerPath,0x1C,"UInt")
    if (!monsterRoom1 || !playerRoom1)
        return false
    monsterRoom2 := D2ReadU32(h,monsterRoom1+0x10), playerRoom2 := D2ReadU32(h,playerRoom1+0x10)
    return monsterRoom2 && monsterRoom2=playerRoom2
}

RoomAttackRoomValidV113(pid,unit,uid)
{
    global roomExploreV89
    base := D2GetModuleBaseV35(pid,"D2Client.dll"), h := base ? D2OpenProcess(pid) : 0
    if (!h)
        return false
    try
    {
        player := D2ReadU32(h,base+0x11BBFC)
        if (!player || !MonsterBossProbeReadV1(h,unit,0x30,ub)
            || NumGet(ub,0,"UInt")!=1 || NumGet(ub,12,"UInt")!=uid
            || NumGet(ub,16,"UInt")=0 || NumGet(ub,16,"UInt")=12)
            return false
        if (!MonsterBossProbeReadV1(h,NumGet(ub,0x2C,"UInt"),0x20,mp)
            || !MonsterBossProbeReadV1(h,D2ReadU32(h,player+0x2C),0x20,pp))
            return false
        playerRoom1 := NumGet(pp,0x1C,"UInt")
        if (roomExploreV89.skipCombatRoom && playerRoom1 && D2ReadU32(h,playerRoom1+0x10)=roomExploreV89.skipCombatRoom)
            return false
        allowed := RoomMonsterSameRoomV113(h,mp,pp)
        if (!allowed)
            AutoMonsterAttackLogV2("ROOM_ATTACK_SKIP uid=" . uid . " reason=MONSTER_IN_OTHER_ROOM",true)
        return allowed
    }
    finally
        DllCall("CloseHandle","Ptr",h)
}

CainLockedBossAttackValidV406(pid,unit,uid)
{
    global cainHuntRouteV403
    if (!CainHuntActiveV403() || !IsObject(cainHuntRouteV403) || cainHuntRouteV403.pid!=pid
        || !IsObject(cainHuntRouteV403.boss) || cainHuntRouteV403.boss.uid!=uid)
        return false
    boss := cainHuntRouteV403.boss
    base := D2GetModuleBaseV35(pid,"D2Client.dll"),h := base ? D2OpenProcess(pid) : 0
    if (!h)
        return false
    try
    {
        player := D2ReadU32(h,base+0x11BBFC)
        if (!player || !MonsterBossProbeReadV1(h,unit,0x30,ub)
            || NumGet(ub,0,"UInt")!=1 || NumGet(ub,0x0C,"UInt")!=uid
            || NumGet(ub,4,"UInt")!=boss.cls || NumGet(ub,0x10,"UInt")=0 || NumGet(ub,0x10,"UInt")=12)
            return false
        if (!MonsterBossProbeReadV1(h,NumGet(ub,0x2C,"UInt"),0x20,mp)
            || !MonsterBossProbeReadV1(h,D2ReadU32(h,player+0x2C),0x20,pp))
            return false
        return CoordLevelV14(h,NumGet(mp,0x1C,"UInt"))=CainHuntLevelV422()
            && CoordLevelV14(h,NumGet(pp,0x1C,"UInt"))=CainHuntLevelV422()
    }
    finally
        DllCall("CloseHandle","Ptr",h)
}

FarmCombatViewV624(pid,target,message)
{
    global farmCombatViewV624
    farmCombatViewV624 := {pid:pid,uid:IsObject(target) ? target.uid : 0
        ,cls:IsObject(target) ? target.cls : 0,text:message,at:A_TickCount}
}

FarmCombatSendResultV624(pid,unit,uid,sent)
{
    global farmCombatViewV624
    c := farmCombatViewV624
    cls := IsObject(c) && c.pid=pid && c.uid=uid ? c.cls : 0
    FarmCombatViewV624(pid,{uid:uid,cls:cls},sent ? "đang đánh" : "có quái; lệnh đánh chưa gửi")
    return sent
}

AutoMonsterPacketSendV1(pid, unit, uid)
{
    global farmBuffExclusiveV621
    if (farmBuffExclusiveV621)
    {
        AutoMonsterAttackLogV2("COMBAT_SEND_BLOCK reason=BUFF_EXCLUSIVE uid=" . uid)
        return false
    }
    global roomExploreV89,autoMonsterAttackOn,farmAttackHoldV15,farmAttackUsedV15
    global farmApproachV722
    closeV722 := IsObject(farmApproachV722) && farmApproachV722.pid=pid
        && IsObject(farmApproachV722.target) && farmApproachV722.target.uid=uid
        && farmApproachV722.target.unit=unit && A_TickCount-farmApproachV722.at<500
    if (!FarmCenterPolicyV741(pid) && !closeV722 && RoomFarmBoundaryV235() && !CainLockedBossAttackValidV406(pid,unit,uid)
        && !RoomAttackRoomValidV113(pid,unit,uid))
    {
        AutoMonsterAttackLogV2("COMBAT_SEND_BLOCK reason=ROOM_BOUNDARY uid=" . uid)
        return false
    }
    if (!NativeDispatchReadyV10(true) || D2GetActiveGamePidV95()!=pid)
    {
        AutoMonsterAttackLogV2("COMBAT_SEND_BLOCK reason=DISPATCH_NOT_READY uid=" . uid . " active=" . D2GetActiveGamePidV95() . " expected=" . pid)
        return false
    }
    farmAttackUsedV15 := true
    if (!AutoMonsterPacketCleanupV1())
    {
        AutoMonsterAttackLogV2("COMBAT_SEND_BLOCK reason=PACKET_OR_THREAD_BUSY uid=" . uid)
        return false
    }

    if (autoMonsterAttackOn)
    {
        if (!FarmCenterPolicyV741(pid))
            return Form6AttackV716(pid,unit,uid)
        global farmCenterCycleV741
        if (FarmCenterPendingV741(pid))
        {
            global farmItemLockV625
            if (FarmParentNextV767(farmCenterCycleV741.phase)="")
            {
                AutoMonsterAttackLogV2("COMBAT_SEND_BLOCK reason=CENTER_PHASE uid=" . uid . " phase=" . farmCenterCycleV741.phase)
                return false
            }
            cycleV741 := farmCenterCycleV741
        }
        else
            cycleV741 := FarmCenterCaptureV741(pid)
        if (!IsObject(cycleV741))
        {
            AutoMonsterAttackLogV2("COMBAT_SEND_BLOCK reason=CENTER_CAPTURE uid=" . uid)
            return false
        }
        nextParentV767 := FarmParentNextV767(cycleV741.phase)
        if (nextParentV767="")
            nextParentV767 := "ATTACK_MORE"
        ; Keep the source phase while Form6Attack temporarily requires ATTACK.
        ; Normal farm dispatch continues to validate against fixed B.
        originPhaseV1190 := cycleV741.phase
        cycleV741.dispatchOriginV1190 := originPhaseV1190
        farmCenterCycleV741 := cycleV741,cycleV741.phase := "ATTACK"
        try
            return Form6AttackV716(pid,unit,uid)
        finally
        {
            if (farmCenterCycleV741=cycleV741)
                cycleV741.phase := nextParentV767
            cycleV741.dispatchOriginV1190 := ""
        }
    }

    holdModeV17 := autoMonsterAttackOn && FarmAttackRowFiveV18()
    held := farmAttackHoldV15
    if (IsObject(held))
    {
        if (holdModeV17 && held.pid=pid && held.uid=uid && held.unit=unit && !held.releaseV15)
        {
            if (FarmAttackAimV16(held))
                return true
            FarmAttackHoldReleaseV15()
            return false
        }
        FarmAttackHoldReleaseV15()
        return false
    }
    if (autoMonsterAttackOn)
    {
        if (!LastAttackSkillV20())
        {
            FarmCombatViewV624(pid,{uid:uid},"có quái; chưa chọn được F cuối")
            return false
        }
        return FarmCombatSendResultV624(pid,unit,uid,NativeMapTestV5(true,{pid:pid,unit:unit,uid:uid,holdRightV15:holdModeV17}))
    }
    return FarmCombatSendResultV624(pid,unit,uid,NativeMapTestV5(true,{pid:pid,unit:unit,uid:uid}))
}
AutoMonsterAttackLogV2(message, throttle := false)
{
    if (!ManualLogActiveV81())
        return
    FarmInfoEventV4(message)
    global autoMonsterExportV2, pickupCubeTraceUntil
    if (RegExMatch(message,"^(MAP_MOVE_|NATIVE_|AUTO_NATIVE_|AUTO_CLIENT_|COMBAT_|LOW_HP_|ROUTE_|REVIVE_|FARM_|START|STOP)"))
        PortalLogWriteV66("FARM_ACTION " . message)
    if (!pickupCubeTraceUntil || A_TickCount>=pickupCubeTraceUntil)
        return
    static last := 0
    if (throttle && A_TickCount-last<2000)
        return
    last := A_TickCount
    log := TxtRootPathV816("Auto-GSF-Tu-Danh.txt")
    ManualLogAppendV81(A_Now . " tick=" . A_TickCount . " | " . message . "`r`n", log, "UTF-8")
    if (autoMonsterExportV2)
    {
        DebugTraceWrite("packet", "AUTO_DIAGNOSTIC " . message)
        DebugTraceWrite("monster", "AUTO_DIAGNOSTIC " . message)
    }
}

AutoGSFDrawTabV3(wParam, lParam, msg, hwnd)
{
    global AutoGSFTabHwndV3
    if (CoordDrawRowV17(lParam))
        return true
    if (!lParam || !AutoGSFTabHwndV3 || NumGet(lParam+0,0,"UInt")!=101)
        return
    hwndOffset := A_PtrSize=8 ? 24 : 20
    dcOffset := A_PtrSize=8 ? 32 : 24
    rectOffset := A_PtrSize=8 ? 40 : 28
    if (NumGet(lParam+0,hwndOffset,"Ptr")!=AutoGSFTabHwndV3)
        return
    item := NumGet(lParam+0,8,"UInt")
    if (item>3)
        return
    dc := NumGet(lParam+0,dcOffset,"Ptr")
    rect := lParam+rectOffset
    selected := (NumGet(lParam+0,16,"UInt") & 1)
    color := item=0 ? 0xFFD9B8 : item=1 ? 0xF0D1E5 : item=2 ? 0xD1F0DA : 0xB8E8FF
    brush := DllCall("gdi32\CreateSolidBrush","UInt",color,"Ptr")
    saved := DllCall("gdi32\SaveDC","Ptr",dc,"Int")
    try
    {
        DllCall("user32\FillRect","Ptr",dc,"Ptr",rect,"Ptr",brush)
        DllCall("user32\DrawEdge","Ptr",dc,"Ptr",rect,"UInt",5,"UInt",15)
        font := DllCall("SendMessage","Ptr",AutoGSFTabHwndV3,"UInt",0x31,"Ptr",0,"Ptr",0,"Ptr")
        if (font)
            DllCall("gdi32\SelectObject","Ptr",dc,"Ptr",font,"Ptr")
        DllCall("gdi32\SetBkMode","Ptr",dc,"Int",1)
        DllCall("gdi32\SetTextColor","Ptr",dc,"UInt",0)
        caption := item=0 ? "1. BUFF" : item=1 ? "2. NHẶT ĐỒ" : item=2 ? "3. FARM" : "4. LIST ITEM"
        DllCall("user32\DrawTextW","Ptr",dc,"WStr",caption,"Int",-1,"Ptr",rect,"UInt",0x25)
        if (NumGet(lParam+0,16,"UInt") & 0x10)
        {
            VarSetCapacity(focusRect,16,0)
            Loop, 4
                NumPut(NumGet(rect+0,(A_Index-1)*4,"Int"),focusRect,(A_Index-1)*4,"Int")
            DllCall("user32\InflateRect","Ptr",&focusRect,"Int",-4,"Int",-4)
            DllCall("user32\DrawFocusRect","Ptr",dc,"Ptr",&focusRect)
        }
    }
    finally
    {
        if (saved)
            DllCall("gdi32\RestoreDC","Ptr",dc,"Int",saved)
        if (brush)
            DllCall("gdi32\DeleteObject","Ptr",brush)
    }
    return true
}

CharacterDLLProbeTimerV3:
if (!ManualLogActiveV81())
{
    SetTimer, CharacterDLLProbeTimerV3, Off
    return
}
if (!pickupCubeTraceUntil || A_TickCount>=pickupCubeTraceUntil)
{
    SetTimer, CharacterDLLProbeTimerV3, Off
    return
}
if (!IsGameActive() || !IsObject(characterDLLProbeV3) || characterDLLProbeV3.busy)
    return
characterDLLProbeV3.busy := true
try
    CharacterDLLProbeScanV3()
catch probeErrorV3
    DebugTraceWrite("character", "ERROR message=" . probeErrorV3.Message)
finally
    characterDLLProbeV3.busy := false
return

CharacterDLLProbeScanV3()
{
    global characterDLLProbeV3, zRunning, xRunning, currentProfile
    pid := D2GetActiveGamePidV95()
    if (!pid)
        return
    h := DllCall("OpenProcess","UInt",0x0410,"Int",0,"UInt",pid,"Ptr")
    if (!h)
    {
        DebugTraceWrite("character","OPEN_READ_FAIL error=" . A_LastError)
        return
    }
    try
    {
        base := D2GetModuleBaseV35(pid,"D2Client.dll")
        player := base ? D2ReadU32(h,base+0x11BBFC) : 0
        if (!MonsterBossProbeReadV1(h,player,0xEC,ub) || NumGet(ub,0,"UInt")!=0)
        {
            DebugTraceWrite("character","PLAYER_NOT_READY pid=" . pid)
            return
        }
        data := NumGet(ub,0x14,"UInt"), path := NumGet(ub,0x2C,"UInt")
        name := MonsterBossProbeReadV1(h,data,16,nb) ? StrGet(&nb,16,"CP0") : "UNREADABLE"
        xy := MonsterBossProbeReadV1(h,path,0x20,pb) ? NumGet(pb,2,"UShort") . "," . NumGet(pb,6,"UShort") : "UNREADABLE"
        levelIdV16 := CoordLevelV14(h,D2ReadU32(h,path+0x1C))
        townCandidateV16 := levelIdV16=1 || levelIdV16=40 || levelIdV16=75 || levelIdV16=103 || levelIdV16=109
        DebugTraceWrite("character", "POSITION level_id=" . levelIdV16 . " town_candidate=" . townCandidateV16
            . " town_rule=BASE_GAME_IDS_VERIFY_MEDIAN xy=" . xy . " mode=" . NumGet(ub,0x10,"UInt")
            . " z_buff_running=" . zRunning . " x_buff_running=" . xRunning . " profile=" . currentProfile)
        stats := NumGet(ub,0x5C,"UInt"), skills := NumGet(ub,0xA8,"UInt")
        text := "PLAYER pid=" . pid . " ptr=" . V92Hex(player) . " name=" . name
            . " uid=" . NumGet(ub,0xC,"UInt") . " class_id=" . NumGet(ub,4,"UInt")
            . " mode=" . NumGet(ub,0x10,"UInt") . " xy=" . xy . " stats=" . V92Hex(stats) . " skills=" . V92Hex(skills)
        if (MonsterBossProbeReadV1(h,stats,0x100,sb))
        {
            text .= "`r`nSTAT_ROOT_RAW=" . MonsterBossProbeHexV1(sb,0x100)
            for _, off in [0x48,0x24]
            {
                arr := NumGet(sb,off,"UInt"), count := NumGet(sb,off+4,"UShort"), capacity := NumGet(sb,off+6,"UShort")
                if (count<1 || count>1024 || capacity<count || !MonsterBossProbeReadV1(h,arr,count*8,ab))
                    continue
                text .= "`r`nSTATS source=+" . Format("{:02X}",off) . " count=" . count
                Loop, %count%
                {
                    at := (A_Index-1)*8
                    layer := NumGet(ab,at,"UShort"), id := NumGet(ab,at+2,"UShort"), value := NumGet(ab,at+4,"Int")
                    text .= "`r`nSTAT id=" . id . " layer=" . layer . " value=" . value
                    if (layer=0 && (id=6 || id=7 || id=8 || id=9))
                        text .= " fixed256=" . Round(value/256,2)
                }
                break
            }
            queue := [stats], seen := {}
            for _, off in [0x3C,0x40]
            {
                ptr := NumGet(sb,off,"UInt")
                if (ptr>=0x10000)
                    queue.Push(ptr)
            }
            index := 1
            while (index<=queue.Length() && index<=64)
            {
                node := queue[index], index++
                if (seen.HasKey(node) || !MonsterBossProbeReadV1(h,node,0x80,lb))
                    continue
                if (node!=stats && (NumGet(lb,8,"UInt")>5 || NumGet(lb,0x14,"UInt")>4096))
                    continue
                seen[node] := true
                text .= "`r`nSTATE_LIST_PROBE ptr=" . V92Hex(node)
                    . " state_at14=" . NumGet(lb,0x14,"UInt") . " skill_at1C=" . NumGet(lb,0x1C,"UInt")
                    . " level_at20=" . NumGet(lb,0x20,"UInt") . " expiry_at18=" . NumGet(lb,0x18,"UInt")
                    . " interpretation=UNCONFIRMED raw=" . MonsterBossProbeHexV1(lb,0x80)
                for _, off in [0x3C,0x40]
                {
                    ptr := NumGet(lb,off,"UInt")
                    if (ptr>=0x10000 && !seen.HasKey(ptr))
                        queue.Push(ptr)
                }
            }
        }
        if (MonsterBossProbeReadV1(h,skills,0x20,kb))
        {
            text .= "`r`nSKILL_ROOT_RAW=" . MonsterBossProbeHexV1(kb,0x20)
            for _, entry in [{slot:"FIRST",off:4},{slot:"LEFT",off:8},{slot:"RIGHT",off:12}]
            {
                skill := NumGet(kb,entry.off,"UInt")
                text .= "`r`nSKILL_SLOT_PROBE slot=" . entry.slot . " ptr=" . V92Hex(skill)
                    . " " . CharacterSkillProbeV3(h,skill)
            }
            skill := NumGet(kb,4,"UInt"), seenSkills := {}
            Loop, 128
            {
                if (!skill || seenSkills.HasKey(skill) || !MonsterBossProbeReadV1(h,skill,0x40,ks))
                    break
                seenSkills[skill] := true
                text .= "`r`nSKILL_LIST_PROBE ptr=" . V92Hex(skill) . " " . CharacterSkillProbeV3(h,skill)
                skill := NumGet(ks,4,"UInt")
            }
        }
        if (text!=characterDLLProbeV3.lastSnapshot)
        {
            DebugTraceWrite("character",text)
            characterDLLProbeV3.lastSnapshot := text
        }
        modules := ["D2Client.dll","D2Common.dll","D2Net.dll","D2Game.dll","D2Win.dll"]
        i := characterDLLProbeV3.moduleIndex
        if (i<=modules.Length())
        {
            module := modules[i]
            CharacterDLLExportsV3(h,pid,module)
            characterDLLProbeV3.moduleIndex := i+1
        }
    }
    finally
        DllCall("CloseHandle","Ptr",h)
}

CharacterSkillProbeV3(h,skill)
{
    if (!MonsterBossProbeReadV1(h,skill,0x40,b))
        return "READ_FAIL"
    row := NumGet(b,0,"UInt")
    id := MonsterBossProbeReadV1(h,row,0x20,t) ? NumGet(t,0,"UShort") : -1
    return "candidate_skill_id=" . id . " level_at28=" . NumGet(b,0x28,"UInt")
        . " interpretation=PROBE raw=" . MonsterBossProbeHexV1(b,0x40)
}

CharacterDLLExportsV3(h,pid,module)
{
    base := D2GetModuleBaseV35(pid,module)
    if (!MonsterBossProbeReadV1(h,base,0x40,dos) || NumGet(dos,0,"UShort")!=0x5A4D)
    {
        DebugTraceWrite("character","DLL_NOT_READY name=" . module)
        return
    }
    pe := NumGet(dos,0x3C,"UInt")
    if (pe>0x100000 || !MonsterBossProbeReadV1(h,base+pe,0x108,nt)
        || NumGet(nt,0,"UInt")!=0x4550 || NumGet(nt,24,"UShort")!=0x10B)
    {
        DebugTraceWrite("character","DLL_HEADER_INVALID name=" . module)
        return
    }
    size := NumGet(nt,24+56,"UInt"), expRva := NumGet(nt,24+96,"UInt"), expSize := NumGet(nt,24+100,"UInt")
    out := "DLL name=" . module . " base=" . V92Hex(base) . " timestamp=" . NumGet(nt,8,"UInt")
        . " image_size=" . size . " machine=" . Format("{:04X}",NumGet(nt,4,"UShort"))
    if (expRva && expRva<size && MonsterBossProbeReadV1(h,base+expRva,40,eb))
    {
        ordinalBase := NumGet(eb,16,"UInt"), n := NumGet(eb,20,"UInt"), nn := NumGet(eb,24,"UInt")
        fns := NumGet(eb,28,"UInt"), names := NumGet(eb,32,"UInt"), ords := NumGet(eb,36,"UInt")
        out .= " exports=" . n . " named=" . nn . " ordinal_base=" . ordinalBase
        named := {}
        if (nn>0 && nn<=4096 && names<size && ords<size
            && MonsterBossProbeReadV1(h,base+names,nn*4,np) && MonsterBossProbeReadV1(h,base+ords,nn*2,op))
        {
            Loop, %nn%
            {
                rva := NumGet(np,(A_Index-1)*4,"UInt"), ordinalIndex := NumGet(op,(A_Index-1)*2,"UShort")
                if (rva<size && MonsterBossProbeReadV1(h,base+rva,128,nameBuf))
                    named[ordinalIndex] := StrGet(&nameBuf,128,"CP0")
            }
        }
        if (n>0 && n<=4096 && fns<size && MonsterBossProbeReadV1(h,base+fns,n*4,fb))
        {
            Loop, %n%
            {
                index := A_Index-1, rva := NumGet(fb,index*4,"UInt")
                if (!rva || rva>=size)
                    continue
                out .= "`r`nEXPORT ordinal=" . (ordinalBase+index) . " name=" . (named.HasKey(index) ? named[index] : "ORDINAL_ONLY")
                    . " rva=" . V92Hex(rva) . " address=" . V92Hex(base+rva)
                    . " forwarded=" . (rva>=expRva && rva<expRva+expSize)
            }
        }
    }
    else
        out .= " exports=NONE_OR_UNREADABLE"
    if (module="D2Client.dll")
    {
        candidates := [{name:"ClickMap_COORDS",rva:0x1BF20},{name:"SetSelectedUnit_UNIT_PTR",rva:0x51860}
            ,{name:"GetSelectedUnit",rva:0x51A80},{name:"Attack_STRUCT",rva:0x1A060}]
        for _, fn in candidates
        {
            read := fn.rva<size && MonsterBossProbeReadV1(h,base+fn.rva,128,code)
            out .= "`r`nINTERNAL_FUNCTION_CANDIDATE name=" . fn.name . " reference=1.13c address=" . V92Hex(base+fn.rva)
                . " verified_in_this_build=0 readable=" . read . " bytes=" . (read ? MonsterBossProbeHexV1(code,128) : "READ_FAIL")
        }
    }
    DebugTraceWrite("character",out)
}

AutoMonsterAttackApplyStateV4()
{
    global autoMonsterAttackOn,configGuiVisible,autoMonsterToggleKeyV13,petLearnKeyV13,coordGetKeyV14,coordPointTextV14,farmNaoKeyV181
    global farmResetWatchEnabledV217,farmResetWatchMinutesV217
    MonsterKeysBindV13()
    GuiControl,, PetLearnKeyInputV13, % MouseKeyDisplayV616(petLearnKeyV13="" ? "None" : petLearnKeyV13)
    GuiControl,, FarmResetWatchCheckV217, %farmResetWatchEnabledV217%
    GuiControl,, FarmResetWatchMinutesV217, %farmResetWatchMinutesV217%
    CoordBoxRefreshV15(true)
    if (autoMonsterAttackOn)
        SetTimer, AutoMonsterAttackTimer, 250
    else
        SetTimer, AutoMonsterAttackTimer, Off
}


NativeAttackBuildV5(h,base)
{
    if (!MonsterBossProbeReadV1(h,base,64,dos))
        return false
    nt := base+NumGet(dos,0x3C,"UInt")
    if (!MonsterBossProbeReadV1(h,nt,84,pe)
        || NumGet(pe,0,"UInt")!=0x4550 || NumGet(pe,4,"UShort")!=0x14C
        || NumGet(pe,8,"UInt")!=1268107838 || NumGet(pe,80,"UInt")!=1265664)
        return false
    expected := "A14CBCB86F8B0D24B8BC6F83C0CF83EC283BC80F8F160A0000837C2430015355"
    if (!MonsterBossProbeReadV1(h,base+0x1A060,32,code))
        return false
    if (NumGet(code,1,"UInt")!=base+0xDBC4C || NumGet(code,7,"UInt")!=base+0x11B824)
        return false
    NumPut(0x6FB8BC4C,code,1,"UInt"), NumPut(0x6FBCB824,code,7,"UInt")
    return MonsterBossProbeHexV1(code,32)=expected
}

NativeAttackCaptureV5(w,esp)
{
    global nativeMapTemplateV5, nativeUnitTemplateV7
    if (!MonsterBossProbeReadV1(w.h,esp,12,args))
        return
    ptr := NumGet(args,4,"UInt"), targetMode := NumGet(args,8,"UInt")
    if (!MonsterBossProbeReadV1(w.h,ptr,28,a))
        return
    flags := NumGet(a,0,"UInt"), player := NumGet(a,4,"UInt"), unit := NumGet(a,8,"UInt")
    tx := NumGet(a,12,"UInt"), ty := NumGet(a,16,"UInt")
    uid := unit ? D2ReadU32(w.h,unit+12) : 0
    type := unit ? D2ReadU32(w.h,unit) : -1
    w.count++
    PacketWatchLogV1("NATIVE_ATTACK n=" . w.count . " flags=" . flags . " target_mode=" . targetMode
        . " player=" . V92Hex(player) . " target=" . V92Hex(unit) . " type=" . type . " uid=" . uid
        . " map=" . tx . "," . ty . " right_physical=" . GetKeyState("RButton","P")
        . " raw28=" . MonsterBossProbeHexV1(a,28))
    base := D2GetModuleBaseV35(w.pid,"D2Client.dll")
    if (unit && type=1 && targetMode=1 && GetKeyState("RButton","P")
        && player=D2ReadU32(w.h,base+0x11BBFC) && (flags=134 || flags=138)
        && NumGet(a,20,"UInt")=1 && NumGet(a,24,"UInt")=2)
    {
        nativeUnitTemplateV7 := {pid:w.pid,player:player,flags:flags,aux1:1,aux2:2,source:"LIVE_RIGHT_UNIT_CAPTURE"}
        PacketWatchLogV1("NATIVE_UNIT_TEMPLATE_READY flags=" . flags . " aux1=1 aux2=2 target_mode=1")
    }
    if (!unit && targetMode=0 && GetKeyState("RButton","P")
        && player=D2ReadU32(w.h,base+0x11BBFC) && tx>0 && ty>0 && tx<65536 && ty<65536
        && NumGet(a,20,"UInt")=0 && NumGet(a,24,"UInt")=0)
    {
        nativeMapTemplateV5 := {pid:w.pid,player:player,flags:flags}
        PacketWatchLogV1("NATIVE_MAP_TEMPLATE_READY flags=" . flags . " source=OBSERVED_RIGHT_GROUND_CLICK")
    }
}

NativeMapTestV5(attackUnit := false, autoTarget := false)
{
    MovementCtrlSetV78(false,0,"NativeMapTestV5")
    global nativeMapTemplateV5, nativeUnitTemplateV7, autoMonsterPacketPendingV1
    autoCall := IsObject(autoTarget)
    if (!NativeDispatchReadyV10(autoCall))
    {
        NativeDispatchLogV10(autoCall,"NATIVE_UNIT_BLOCK reason=DISPATCH_NOT_READY")
        return false
    }
    t := {pid:0,player:0,flags:6,source:"VERIFIED_DLL_RIGHT_DOWN_DISPATCH"}
    kind := autoCall ? "AUTO_UNIT" : attackUnit ? "UNIT" : "MAP"
    if (!IsObject(t) || IsObject(autoMonsterPacketPendingV1))
    {
        NativeDispatchLogV10(autoCall,"NATIVE_" . kind . "_SKIP reason=TEMPLATE_NOT_READY_OR_THREAD_BUSY")
        if (!autoCall)
        {
        ToolTipInfoV386("Chưa có mẫu click phù hợp hoặc phép thử trước chưa xong.")
        SetTimer, RemoveToolTip, -3500
        }
        return false
    }
    pid := D2GetActiveGamePidV95()
    if (!pid || (autoCall && pid!=autoTarget.pid) || (t.pid && pid!=t.pid))
        return false
    base := D2GetModuleBaseV35(pid,"D2Client.dll")
    h := DllCall("OpenProcess","UInt",0x043A,"Int",0,"UInt",pid,"Ptr")
    if (!h)
        return false
    remote := 0, owned := false
    try
    {
        if (!NativeRightClickBuildV9(h,base))
        {
            NativeDispatchLogV10(autoCall,"NATIVE_DISPATCH_SKIP reason=DLL_SIGNATURE_MISMATCH")
            return false
        }
        if (!autoCall)
            NativeAttackStateV8(h,base,"BEFORE_CALL")
        player := D2ReadU32(h,base+0x11BBFC)
        if ((t.player && player!=t.player) || !MonsterBossProbeReadV1(h,player,0x64,p))
            return false
        mode := NumGet(p,16,"UInt"), path := NumGet(p,0x2C,"UInt")
        if (mode=0 || mode=17 || !MonsterBossProbeReadV1(h,path,0x20,pb))
            return false
        inv := NumGet(p,0x60,"UInt")
        cursor := inv ? PickupCursorV4(h,inv) : false
        if (!IsObject(cursor) || cursor.unit)
            return false
        px := NumGet(pb,2,"UShort"), py := NumGet(pb,6,"UShort")
        unit := 0, uid := 0
        tx := px+2, ty := py-1
        if (px<1 || py<2 || tx>65535)
            return false
        if (attackUnit)
        {
            if (autoCall)
            {
                if (!MonsterBossProbeReadV1(h,autoTarget.unit,0x30,selected)
                    || NumGet(selected,0,"UInt")!=1 || NumGet(selected,12,"UInt")!=autoTarget.uid
                    || NumGet(selected,16,"UInt")=0 || NumGet(selected,16,"UInt")=12
                    || !MonsterBossProbeReadV1(h,NumGet(selected,0x2C,"UInt"),0x20,selectedPath))
                    return false
                target := {unit:autoTarget.unit,uid:autoTarget.uid,x:NumGet(selectedPath,2,"UShort"),y:NumGet(selectedPath,6,"UShort")}
            }
            else
                target := NativeNearestUnitV7(h,pb)
            if (!IsObject(target))
            {
                NativeDispatchLogV10(autoCall,"NATIVE_UNIT_SKIP reason=NO_LIVE_MONSTER_IN_LOADED_ROOMS")
                if (!autoCall)
                {
                ToolTipInfoV386("Chưa có quái sống gần nhân vật để thử.")
                SetTimer, RemoveToolTip, -3500
                }
                return false
            }
            unit := target.unit, uid := target.uid, tx := target.x, ty := target.y
            if (MonsterClassExcludedV11(D2ReadU32(h,unit+4),h,unit))
                return false
        }
        if (!NativeRightSkillValidV9(h,base,player))
        {
            NativeDispatchLogV10(autoCall,"NATIVE_UNIT_BLOCK reason=RIGHT_SKILL_INVALID")
            return false
        }
        remote := DllCall("VirtualAllocEx","Ptr",h,"Ptr",0,"UPtr",256,"UInt",0x3000,"UInt",0x40,"Ptr")
        if (!remote || remote>0xFFFFFFFF)
            return false
        VarSetCapacity(blob,256,0)
        codeHex := NativeRightClickCodeV9(remote,base,player,autoCall && autoTarget.holdRightV15)
        codeLen := StrLen(codeHex)//2
        if (codeLen>128)
            return false
        Loop, %codeLen%
            NumPut("0x" . SubStr(codeHex,(A_Index-1)*2+1,2),blob,A_Index-1,"UChar")
        NumPut(6,blob,128,"UInt"), NumPut(player,blob,132,"UInt")
        holdMapV16 := autoCall && autoTarget.holdRightV15
        NumPut(holdMapV16 ? 0 : unit,blob,136,"UInt")
        NumPut(tx,blob,140,"UInt"), NumPut(ty,blob,144,"UInt")
        if (!DllCall("WriteProcessMemory","Ptr",h,"Ptr",remote,"Ptr",&blob,"UPtr",256,"UPtrP",written) || written!=256)
            return false
        DllCall("FlushInstructionCache","Ptr",h,"Ptr",remote,"UPtr",codeLen)
        if (D2GetActiveGamePidV95()!=pid || !NativeDispatchReadyV10(autoCall))
            return false
        if (attackUnit)
        {
            if (!MonsterBossProbeReadV1(h,unit,0x30,finalUnit)
                || NumGet(finalUnit,0,"UInt")!=1 || NumGet(finalUnit,12,"UInt")!=uid
                || NumGet(finalUnit,16,"UInt")=0 || NumGet(finalUnit,16,"UInt")=12)
                return false
            if (autoCall)
            {
                livePlayerV239 := D2ReadU32(h,base+0x11BBFC)
                fixedOKV1190 := livePlayerV239 && FarmFixedAttackValidV626(h,livePlayerV239,unit,uid,pid)
                radiusOKV1190 := fixedOKV1190 && ScosAttackRadiusValidV239(h,livePlayerV239,unit,uid)
                boOKV1190 := !BOCommonActiveV444(pid) || (radiusOKV1190 && BOAttackInRadiusV488(h,livePlayerV239,unit,pid))
                if (!fixedOKV1190 || !radiusOKV1190 || !boOKV1190)
                {
                    NativeDispatchLogV10(autoCall,"NATIVE_AUTO_UNIT_GUARD_BLOCK uid=" . uid
                        . " fixed=" . fixedOKV1190 . " radius=" . radiusOKV1190 . " bo=" . boOKV1190)
                    return false
                }
            }
        }
        thread := DllCall("CreateRemoteThread","Ptr",h,"Ptr",0,"UPtr",0,"Ptr",remote,"Ptr",0,"UInt",0,"UIntP",tid,"Ptr")
        if (!thread)
            return false
        autoMonsterPacketPendingV1 := {process:h,remote:remote,thread:thread,uid:uid,kind:kind . "_TEST",dispatchV9:true,autoCall:autoCall,setAt:A_TickCount}
        if (autoCall && autoTarget.holdRightV15)
        {
            autoMonsterPacketPendingV1.holdDownV15 := true
            autoMonsterPacketPendingV1.pid := pid,autoMonsterPacketPendingV1.base := base
            autoMonsterPacketPendingV1.player := player,autoMonsterPacketPendingV1.unit := unit
            autoMonsterPacketPendingV1.birth := BackgroundBirthV63(pid)
        }
        owned := true
        if (autoCall && attackUnit)
            AttackInfoRememberV550(pid,NumGet(finalUnit,4,"UInt"),uid,tx,ty,px,py)
        SetTimer, AutoMonsterPacketCleanupTimerV1, 50
        NativeDispatchLogV10(autoCall,"NATIVE_" . kind . "_TEST_DISPATCH player_map=" . px . "," . py . " target_map=" . tx . "," . ty
            . " target_mode=" . (attackUnit ? 1 : 0) . " uid=" . uid . " unit=" . V92Hex(unit)
            . " flags=6 struct_size=32 down_rva=0x1BC40 up_rva=0x18A00"
            . " method=" . (holdMapV16 ? "RIGHT_HOLD_MAP_AIM" : "D2CLIENT_RIGHT_DOWN_UP")
            . " mouse_moved=0 template_source=" . t.source . " effect=UNCONFIRMED")
        if (!autoCall)
        {
        ToolTipInfoV386(attackUnit ? "Đã gọi đánh thẳng quái 1 lần - ID " . uid : "Đã gọi thử 1 lần tại map (+2,-1). Xem log click phải.")
        SetTimer, RemoveToolTip, -2500
        }
        return true
    }
    finally
    {
        if (!owned)
        {
            NativeDispatchLogV10(autoCall,"NATIVE_" . kind . "_TEST_SKIP reason=VALIDATION_OR_DISPATCH_FAILED error=" . A_LastError)
            if (remote)
                DllCall("VirtualFreeEx","Ptr",h,"Ptr",remote,"UPtr",0,"UInt",0x8000)
            DllCall("CloseHandle","Ptr",h)
        }
    }
}


NativeTestReadyV6()
{
    global autoMonsterAttackOn, zRunning, xRunning, gameItemActionOwner
    reason := !IsGameActive() ? "Chưa ở cửa sổ game" : autoMonsterAttackOn ? "Hãy tắt Tự tìm quái và đánh"
        : (zRunning || xRunning) ? "Đang chạy buff - chờ buff xong" : gameItemActionOwner!="" ? "Đang xử lý vật phẩm - chờ thao tác xong" : ""
    if (reason="")
        return true
    PacketWatchLogV1("NATIVE_TEST_BLOCKED reason=" . reason . " game_active=" . IsGameActive()
        . " auto_attack=" . autoMonsterAttackOn . " z_running=" . zRunning . " x_running=" . xRunning
        . " item_owner=" . gameItemActionOwner)
    ToolTipInfoV386("Chưa bắt đầu dò: " . reason)
    SetTimer, RemoveToolTip, -3500
    return false
}


NativeNearestUnitV7(h, ByRef pb)
{
    px := NumGet(pb,2,"UShort"), py := NumGet(pb,6,"UShort"), room := NumGet(pb,0x1C,"UInt")
    if (!room)
        return false
    rooms := MonsterLoadedRoomsV20(h,room), seenRooms := {}, seenUnits := {}
    best := false, bestDist := 0x7FFFFFFF, total := 0, start := A_TickCount
    for _,r in rooms
    {
        if (seenRooms.HasKey(r))
            continue
        seenRooms[r] := true
        u := D2ReadU32(h,r+0x74)
        Loop, 1024
        {
            if (!u || seenUnits.HasKey(u) || total>=2048 || A_TickCount-start>80)
                break
            seenUnits[u] := true, total++
            if (!MonsterBossProbeReadV1(h,u,0xEC,ub))
                break
            next := NumGet(ub,0xE8,"UInt"), mode := NumGet(ub,16,"UInt")
            uid := NumGet(ub,12,"UInt"), path := NumGet(ub,0x2C,"UInt")
            if (NumGet(ub,0,"UInt")=1 && uid && mode!=0 && mode!=12
                && MonsterBossProbeReadV1(h,path,0x20,mb))
            {
                x := NumGet(mb,2,"UShort"), y := NumGet(mb,6,"UShort")
                dist := (x-px)*(x-px)+(y-py)*(y-py)
                if (x>0 && y>0 && dist<bestDist)
                {
                    bestDist := dist
                    best := {unit:u,uid:uid,x:x,y:y}
                }
            }
            u := next
        }
        if (total>=2048 || A_TickCount-start>80)
            break
    }
    return best
}


NativeAttackDumpV8()
{
    global monsterExcludeClassesV11
    pid := D2GetActiveGamePidV95(), base := pid ? D2GetModuleBaseV35(pid,"D2Client.dll") : 0
    h := base ? DllCall("OpenProcess","UInt",0x0410,"Int",0,"UInt",pid,"Ptr") : 0
    if (!h)
    {
        PacketWatchLogV1("NATIVE_EXPORT_ERROR pid=" . pid . " base=" . V92Hex(base) . " error=" . A_LastError)
        return false
    }
    try
    {
        PacketWatchLogV1("NATIVE_CODE_DUMP_BEGIN pid=" . pid . " base=" . V92Hex(base) . " read_only=1")
        NativeAttackStateV8(h,base,"READ_ONLY_DUMP")
        RoomExportV19(h,base)
        PacketWatchLogV1("NATIVE_EXPORT build_verified=" . NativeRightClickBuildV9(h,base) . " exclusions=" . monsterExcludeClassesV11)
        for _,block in [{rva:0x186A0,size:32},{rva:0x1A010,size:80},{rva:0x1BC40,size:128},{rva:0x18A00,size:192},{rva:0x1A060,size:64},{rva:0x29F30,size:112}]
        {
            ok := MonsterBossProbeReadV1(h,base+block.rva,block.size,code)
            PacketWatchLogV1("NATIVE_CODE rva=" . V92Hex(block.rva) . " bytes=" . (ok ? MonsterBossProbeHexV1(code,block.size) : "READ_FAIL"))
        }
        PacketWatchLogV1("NATIVE_CODE_DUMP_END read_only=1")
        return true
    }
    finally
        DllCall("CloseHandle","Ptr",h)
}

NativeAttackStateV8(h,base,phase)
{
    player := D2ReadU32(h,base+0x11BBFC)
    ok := player && MonsterBossProbeReadV1(h,player,0xAC,p)
    path := ok ? NumGet(p,0x2C,"UInt") : 0
    info := ok ? NumGet(p,0xA8,"UInt") : 0
    right := info ? D2ReadU32(h,info+12) : 0
    left := info ? D2ReadU32(h,info+8) : 0
    skillRow := right ? D2ReadU32(h,right) : 0
    skillOK := skillRow && MonsterBossProbeReadV1(h,skillRow,2,sid)
    dimsOK := MonsterBossProbeReadV1(h,base+0xDBC48,8,dims)
    mouseOK := MonsterBossProbeReadV1(h,base+0x11B824,8,mouse)
    PacketWatchLogV1("NATIVE_STATE phase=" . phase . " player=" . V92Hex(player) . " unit_read=" . ok
        . " mode=" . (ok ? NumGet(p,16,"UInt") : -1) . " frame=" . (ok ? NumGet(p,0x44,"UInt") : -1)
        . " right_skill_ptr=" . V92Hex(right) . " right_skill_id=" . (skillOK ? NumGet(sid,0,"UShort") : -1)
        . " left_skill_ptr=" . V92Hex(left)
        . " internal_mouse=" . (mouseOK ? NumGet(mouse,4,"Int") . "," . NumGet(mouse,0,"Int") : "READ_FAIL")
        . " game_size=" . (dimsOK ? NumGet(dims,0,"UInt") . "," . NumGet(dims,4,"UInt") : "READ_FAIL")
        . " path=" . V92Hex(path))
}

NativeRightClickBuildV9(h,base)
{
    if (!NativeAttackBuildV5(h,base))
        return false
    if (!MonsterBossProbeReadV1(h,base+0x1BC40,15,down)
        || MonsterBossProbeHexV1(down,15)!="8BCEE899C9FFFF85C0746D8B460450")
        return false
    if (!MonsterBossProbeReadV1(h,base+0x18A00,8,up)
        || MonsterBossProbeHexV1(up,8)!="5356E8D9FBFFFF8B")
        return false
    return true
}

NativeRightSkillValidV9(h,base,player)
{
    info := D2ReadU32(h,player+0xA8)
    skill := info ? D2ReadU32(h,info+12) : 0
    row := skill ? D2ReadU32(h,skill) : 0
    if (!row || !MonsterBossProbeReadV1(h,row,2,skillIdBytes))
    {
        PacketWatchLogV1("NATIVE_DISPATCH_SKIP reason=NO_RIGHT_SKILL")
        return false
    }
    id := NumGet(skillIdBytes,0,"UShort")
    tablesRef := D2ReadU32(h,base+0xCE474)
    tables := tablesRef ? D2ReadU32(h,tablesRef) : 0
    count := tables ? D2ReadU32(h,tables+0xBA0) : 0
    rows := tables ? D2ReadU32(h,tables+0xB98) : 0
    if (!rows || count<1 || count>65536 || id>=count)
    {
        PacketWatchLogV1("NATIVE_DISPATCH_SKIP reason=INVALID_RIGHT_SKILL_TABLE id=" . id . " count=" . count)
        return false
    }
    return true
}

NativeRightClickCodeV9(remote,base,player,holdOnly := false)
{
    hex := "60BE" . NativeLE32V9(player) . "B8" . NativeLE32V9(base+0x29F30) . "FFD0A3" . NativeLE32V9(remote+212)
    hex .= "BE" . NativeLE32V9(remote+128) . "B8" . NativeLE32V9(base+0x1BC40) . "FFD0A3" . NativeLE32V9(remote+192)
    hex .= "8B16" . "8915" . NativeLE32V9(remote+200)
    hex .= "8B5608" . "8915" . NativeLE32V9(remote+204)
    hex .= "8B561C" . "8915" . NativeLE32V9(remote+208)
    if (holdOnly)
        return hex . "6131C0C20400"
    hex .= "B9" . NativeLE32V9(remote+128) . "C70112000000"
    hex .= "C705" . NativeLE32V9(base+0x11C2F8) . "00000000"
    hex .= "C705" . NativeLE32V9(base+0x11C2F4) . "00000000"
    hex .= "B8" . NativeLE32V9(base+0x18A00) . "FFD0A3" . NativeLE32V9(remote+196)
    hex .= "6131C0C20400"
    return hex
}

NativeLE32V9(value)
{
    out := ""
    Loop, 4
        out .= Format("{:02X}",(value>>((A_Index-1)*8)) & 255)
    return out
}

NativeDispatchReadyV10(autoCall := false)
{
    global autoMonsterAttackOn, packetWatchArmedV1, zRunning, xRunning, gameItemActionOwner, petLearnOnV12,buffSequenceOnV555
    if (!autoCall)
        return NativeTestReadyV6()
    return (autoMonsterAttackOn || buffSequenceOnV555 || CycCombatReadyV42() || ScosEntryBuffReadyV233(D2GetActiveGamePidV95()))
        && !petLearnOnV12 && IsGameActive() && !packetWatchArmedV1
        && !zRunning && !xRunning && gameItemActionOwner=""
}

NativeDispatchLogV10(autoCall,message)
{
    if (autoCall)
        AutoMonsterAttackLogV2(message)
    else
        PacketWatchLogV1(message)
}

PortalCastNormalizeV50(key)
{
    key := NormalizeOptionalKey(key)
    if (key="M3" || key="Mouse3")
        return "MButton"
    return key
}

CoordCastMarkV50(row)
{
    global roomExploreV89
    if (IsObject(roomExploreV89))
        return false
    global coordCastCountV50, coordCastPendingV50, coordCastLastRowV50, portalCastEveryV52, lastAttackPendingV20, pestiPointPendingV28
    if (row=coordCastLastRowV50)
        return
    coordCastLastRowV50 := row
    pestiPointPendingV28 := true
    lastAttackPendingV20 := true
    coordCastCountV50++
    if (coordCastCountV50>=portalCastEveryV52)
        coordCastPendingV50 := true, coordCastCountV50 := 0
}

PortalExitCancelV69()
{
    global portalExitPendingV69
    portalExitPendingV69 := false
}

PortalExitStartV69(h,player,pid)
{
    global portalExitPendingV69,townLevelV22
    portalExitPendingV69 := false
    path := D2ReadU32(h,player+0x2C)
    if (!MonsterBossProbeReadV1(h,path,0x20,pb))
        return false
    level := CoordLevelV14(h,NumGet(pb,0x1C,"UInt"))
    return level && level!=townLevelV22
}

PortalExitTickV69(h,player,ByRef pb,pid)
{
    global portalExitPendingV69
    portalExitPendingV69 := false
    return false
}

PortalBackReadyV74(h,player,pid)
{
    global portalBackPendingV74
    portalBackPendingV74 := false
    return true
}

CoordCastTickV50(h,player,pid,roomClearV97 := false)
{
    if (CainIntermediateMapV370(pid))
        return false
    global roomExploreV89

    if (IsObject(roomExploreV89) && !roomClearV97)
        return false
    global farmLastCombatTickV72, monsterCombatUidV45, combatRecoverV48,combatMildRecoverV299, portalBackPendingV74
    global coordCastPendingV50, coordCastLastRowV50, portalCastKeyV50, portalCastEveryV52, reviveBuffPendingV34, deathlordRetryAtV31
    global portalBuffV85, coordRouteV16, portalBuffDeferredV998, farmCenterCycleV741
    global pestiPointPendingV28, lastAttackPendingV20
    if (!coordCastPendingV50)
    {
        portalBackPendingV74 := false
        return false
    }
    ; V1002: cac timer scan khong duoc mo cong som o diem N khi dang quet danh.
    if (IsObject(farmCenterCycleV741) && farmCenterCycleV741.pid=pid
        && farmCenterCycleV741.route=coordRouteV16
        && coordCastLastRowV50=farmCenterCycleV741.row
        && farmCenterCycleV741.phase!="PORTAL_CAST")
        return false
    if (monsterCombatUidV45 || IsObject(combatRecoverV48) || A_TickCount-farmLastCombatTickV72<1500)
    {
        if (roomClearV97)
            AutoMonsterAttackLogV2("ROOM_PORTAL_WAIT reason=COMBAT_OR_QUIET_DELAY uid=" . monsterCombatUidV45
                . " recovery=" . IsObject(combatRecoverV48) . " quiet_ms=" . (A_TickCount-farmLastCombatTickV72),true)
        return false
    }
    if (portalCastKeyV50="")
    {
        if (roomClearV97)
            AutoMonsterAttackLogV2("ROOM_PORTAL_SKIP reason=PORTAL_KEY_EMPTY")
        coordCastPendingV50 := false, portalBackPendingV74 := false
        return false
    }
    if (!NativeDispatchReadyV10(true) || D2GetActiveGamePidV95()!=pid || !AutoMonsterPacketCleanupV1())
        return false
    mode := D2ReadU32(h,player+0x10)
    if (mode!=1 && mode!=5)
        return false
    if (!PortalBackReadyV74(h,player,pid))
        return true
    if (!PortalExitStartV69(h,player,pid))
        return false
    if (!BuffCheckedSendV29(portalCastKeyV50))
    {
        PortalExitCancelV69()
        return true
    }
    portalBackPendingV74 := false
    ; V998: voi luong B->C, diem N chi MO CONG, KHONG BUFF.
    ; De buff den N+1 sau khi luong chinh xac nhan quet danh xong.
    deferBuffV998 := IsObject(farmCenterCycleV741) && farmCenterCycleV741.pid=pid
        && farmCenterCycleV741.route=coordRouteV16 && farmCenterCycleV741.phase="PORTAL_CAST"
    if (deferBuffV998)
    {
        portalBuffDeferredV998 := {pid:pid,route:coordRouteV16,epoch:farmCenterCycleV741.epoch
            ,fromRow:farmCenterCycleV741.row,row:farmCenterCycleV741.row+1}
        ; Khong de StateBuffTick buff qua co pending cu ngay tai diem mo cong.
        pestiPointPendingV28 := false,lastAttackPendingV20 := false
        PortalLogWriteV66("ROUTE_PORTAL_CAST key=" . portalCastKeyV50
            . " row=" . farmCenterCycleV741.row . " after=COMBAT_CLEAR next=ROUTE_BUFF_AT_ROW_" . portalBuffDeferredV998.row)
    }
    else
    {
        ; Cac luong khac giu nguyen hanh vi mo cong + buff cu.
        portalBuffV85 := {pid:pid,route:coordRouteV16,phase:"FORM1",startTickV1301:A_TickCount}
        PortalLogWriteV66("ROUTE_PORTAL_CAST key=" . portalCastKeyV50
            . " combat_quiet_ms=" . (A_TickCount-farmLastCombatTickV72) . " next=BUFF_AT_CURRENT_COORDINATE")
    }
    coordCastPendingV50 := false
    reviveBuffPendingV34 := false
    deathlordRetryAtV31 := 0
    AutoMonsterAttackLogV2("ROUTE_CAST_KEY key=" . portalCastKeyV50 . " every_saved_points=" . portalCastEveryV52 . " presses=1 effect=UNCONFIRMED")
    return true
}


FarmStuckCombatProgressV247()
{
    global coordRouteV16
    FarmWatchProgressV5()
    if (IsObject(coordRouteV16))
        coordRouteV16.standProbeV246 := false
}

FarmStandResetTickV246(x,y,level,pid)
{
    FarmWatchObserveV5(pid,level,x,y)
    return false
}

FarmScanLimitChangedV771:
GuiControlGet, liveFarmScanLimitV771,, FarmScanLimitInputV771
if (RegExMatch(liveFarmScanLimitV771,"^\d+$") && liveFarmScanLimitV771>=1 && liveFarmScanLimitV771<=999)
    farmScanLimitV771 := liveFarmScanLimitV771+0
return

MonsterRadiusChangedV239:
MonsterRadiusGetV239()
return

MonsterRadiusGetV239()
{
    global monsterRadiusV48
    GuiControlGet, visibleRadiusV239,, MonsterRadiusInputV48
    if (RegExMatch(visibleRadiusV239,"^\d+$") && visibleRadiusV239>=1 && visibleRadiusV239<=200)
        monsterRadiusV48 := visibleRadiusV239+0
    return monsterRadiusV48
}

; Gia tri BK tam cu duoc giu ngam cho cac profile/luong ngoai B->C.
; Khong con edit BK tam tren GUI: o hien tai la BK quet doc lap.
ItemCenterRadiusGetV810()
{
    global itemCenterRadiusV810
    return Max(1, Min(200, itemCenterRadiusV810+0))
}

PickupFailTeleRadiusGetV1253()
{
    global pickupFailTeleRadiusV1253
    if (ProfileControlExistsV365("PickupFailTeleRadiusInputV1253"))
    {
        GuiControlGet, radiusFromGuiV1253, 1:, PickupFailTeleRadiusInputV1253
        if (RegExMatch(radiusFromGuiV1253,"^\d+$") && radiusFromGuiV1253>=1 && radiusFromGuiV1253<=100)
            pickupFailTeleRadiusV1253 := radiusFromGuiV1253+0
    }
    return Max(1,Min(100,pickupFailTeleRadiusV1253+0))
}

PickupScanRadiusGetV810()
{
    global pickupScanRadiusV810
    GuiControlGet, scanRadiusInputV810, 1:, PickupScanRadiusInputV810
    if (RegExMatch(scanRadiusInputV810,"^\d+$") && scanRadiusInputV810>=1 && scanRadiusInputV810<=400)
        pickupScanRadiusV810 := scanRadiusInputV810+0
    return Max(1, Min(400, pickupScanRadiusV810+0))
}

MoveDelayGetV810()
{
    global moveDelayMsV810, MoveDelayInputV810
    GuiControlGet, tempMoveDelayV810,, MoveDelayInputV810
    if (RegExMatch(tempMoveDelayV810, "^\d+$") && tempMoveDelayV810>=0 && tempMoveDelayV810<=5000)
        moveDelayMsV810 := tempMoveDelayV810+0
    return Max(0, Min(5000, moveDelayMsV810+0))
}

MoveDelayChangedV810:
moveDelayMsV810 := MoveDelayGetV810()
moveDelaySectionV810 := ProfileSection(currentProfile)
try IniWrite, %moveDelayMsV810%, % ProfileConfigPathV364(moveDelaySectionV810), %moveDelaySectionV810%, MoveDelayMs
return

MonsterScanRadiusV20(level)
{
    global farmControlOwnerV186
    baseRadius := MonsterRadiusGetV239()
    return !BOCommonActiveV444() && !BOFinalRouteActiveV451() && CainHuntActiveV403() && level=CainHuntLevelV422() ? baseRadius*2 : baseRadius
}

ScosCoordRadiusAreaV240(px,py,level)
{
    global coordRouteV16
    radius := MonsterRadiusGetV239()
    row := IsObject(coordRouteV16) ? coordRouteV16.yellow : 0
    valid := px>0 && py>0 && level=270
    return {x:px,y:py,radiusSq:valid ? radius*radius : 0,radius:radius,row:row
        ,valid:valid,source:"PLAYER_RADIUS"}
}

FarmRouteCombatAreaV627(pid,player,level)
{
    routePointsV724 := FarmRoutePointsV724()
    global coordRouteV16,farmFightLockV626
    r := coordRouteV16,count := routePointsV724.Length()
    if (!IsObject(r) || !count || r.pid!=pid || r.startLevel!=level)
    {
        farmFightLockV626 := false
        return false
    }
    if (!r.combatRowV627)
    {
        row := r.yellow>=1 && r.yellow<=count ? r.yellow : r.next
        if (row<1 || row>count || routePointsV724[row].level!=level)
            return false
        r.combatRowV627 := row
    }
    row := r.combatRowV627
    if (row>count)
    {
        farmFightLockV626 := false
        return {x:0,y:0,radiusSq:0,source:"SAVED_ROUTE_CLEARED",row:0}
    }
    point := routePointsV724[row]
    if (point.level!=level)
        return {x:0,y:0,radiusSq:0,source:"SAVED_ROUTE_MAP_MISMATCH",row:0}
    if (!IsObject(farmFightLockV626) || farmFightLockV626.routeV627!=r
        || farmFightLockV626.row!=row || farmFightLockV626.x!=point.x || farmFightLockV626.y!=point.y)
    {
        radius := MonsterScanRadiusV20(level)
        farmFightLockV626 := {pid:pid,player:player,level:level,x:point.x,y:point.y
            ,radiusSq:radius*radius,source:"SAVED_ROUTE_COMBAT_CENTER",row:row,routeV627:r}
        r.anchor := row-1,r.next := row,r.phase := "NEXT",r.forwardFloorV303 := row-1
        AutoMonsterAttackLogV2("COMBAT_ROUTE_CENTER row=" . row . " center=" . point.x . "," . point.y . " radius=" . radius)
    }
    return farmFightLockV626
}

FarmRouteCombatClearV627(h,player,pid,ByRef pb)
{
    routePointsV724 := FarmRoutePointsV724()
    global coordRouteV16,farmFightLockV626,monsterCombatUidV45,monsterRoadAreaV51,monsterChaseV44
    global coordNoTargetSinceV14,coordCastCountV50,coordCastLastRowV50,coordCastPendingV50
    global portalCastEveryV52,portalCastKeyV50,portalBuffV85,roomExploreV89
    r := coordRouteV16,c := farmFightLockV626
    if (!IsObject(r) || !IsObject(c) || c.pid!=pid || c.routeV627!=r || c.row!=r.combatRowV627)
        return false
    distance := (NumGet(pb,2,"UShort")-c.x)**2+(NumGet(pb,6,"UShort")-c.y)**2
    last := c.row=routePointsV724.Length()
    if (distance>25)
        return false
    portalRow := coordCastLastRowV50!=c.row && coordCastCountV50+1>=Max(1,portalCastEveryV52)
        && portalCastKeyV50!="" && !IsObject(roomExploreV89) && !CainIntermediateMapV370(pid)
    if (portalRow && distance>25)
        return false
    AutoMonsterPacketCleanupV1()
    monsterCombatUidV45 := 0,monsterRoadAreaV51 := false,monsterChaseV44 := false
    if (!IsObject(roomExploreV89) && !CainIntermediateMapV370(pid))
    {
        CoordCastMarkV50(c.row)
        if (coordCastPendingV50)
        {
            CoordCastTickV50(h,player,pid)
            if (coordCastPendingV50 || IsObject(portalBuffV85))
                return true
        }
    }
    r.anchor := c.row,r.yellow := c.row,r.combatRowV627 := c.row+1,r.next := c.row+1
    r.phase := last ? "DONE" : "NEXT",r.forwardFloorV303 := r.anchor
    r.battlePending := false,r.lastDispatch := 0,r.legRow := 0,r.firstMoveAttempted := false
    r.escapeV84 := false,r.stuckProbe := false,r.bypass := false
    coordNoTargetSinceV14 := A_TickCount-250
    farmFightLockV626 := false
    AutoMonsterAttackLogV2("COMBAT_ROUTE_CLEARED row=" . c.row . " next=" . (last ? "DONE" : r.next))
    CoordBoxRefreshV15()
    return !last
}

FarmFixedAttackValidV626(h,player,unit,uid,pid)
{
    global farmItemLockV625,farmFightLockV626,farmApproachV722,autoMonsterAttackOn,farmCenterCycleV741
    itemGuardV750 := IsObject(farmItemLockV625) && farmItemLockV625.pid=pid && farmItemLockV625.player=player
    if (!itemGuardV750 && FarmCenterPolicyV741(pid))
    {
        if (!FarmCenterPendingV741(pid))
            return FarmPlayerTargetValidV741(h,player,unit,uid,pid)
        c := farmCenterCycleV741
        if (c.phase="ATTACK_FIRST" || c.phase="ATTACK_MORE" || c.phase="ATTACK"
            || c.phase="ROAD_ATTACK")
        {
            ; Khi danh quai can duong, Form6 phai kiem tra dung BK nhan vat
            ; da khoa, khong duoc loai muc tieu vi nam ngoai BK diem cu.
            roadV2026 := c.phase="ROAD_ATTACK"
                || (c.phase="ATTACK" && c.dispatchOriginV1190="ROAD_ATTACK")
            area := {pid:pid,player:player,level:c.level
                ,x:(roadV2026 ? c.roadX_V2026 : c.x)
                ,y:(roadV2026 ? c.roadY_V2026 : c.y)
                ,radiusSq:Max(1,MonsterRadiusGetV239())**2}
        }
        else
            return false
    }
    else
        area := IsObject(farmItemLockV625) ? farmItemLockV625 : farmFightLockV626
    if (!IsObject(area) || area.pid!=pid || area.player!=player)
        return true
    if (!MonsterBossProbeReadV1(h,D2ReadU32(h,player+0x2C),0x20,pp)
        || !MonsterBossProbeReadV1(h,unit,0x30,ub) || NumGet(ub,0,"UInt")!=1 || NumGet(ub,12,"UInt")!=uid
        || !MonsterBossProbeReadV1(h,NumGet(ub,0x2C,"UInt"),0x20,mp))
        return false
    if (CoordLevelV14(h,NumGet(pp,0x1C,"UInt"))!=area.level)
        return true
    if (!itemGuardV750 && autoMonsterAttackOn && Stage2FightEnabledV9() && IsObject(farmApproachV722)
        && farmApproachV722.pid=pid && farmApproachV722.player=player && farmApproachV722.level=area.level
        && A_TickCount-farmApproachV722.at<500 && CoordLevelV14(h,NumGet(mp,0x1C,"UInt"))=area.level
        && (NumGet(mp,2,"UShort")-NumGet(pp,2,"UShort"))**2+(NumGet(mp,6,"UShort")-NumGet(pp,6,"UShort"))**2<=farmApproachV722.radiusSq)
        return true
    return CoordLevelV14(h,NumGet(mp,0x1C,"UInt"))=area.level
        && MonsterInsideAreaV48(NumGet(mp,2,"UShort"),NumGet(mp,6,"UShort"),area)
}

ScosAttackRadiusValidV239(h,player,unit,uid)
{
    global monsterCombatUidV45,monsterRoadAreaV51,monsterChaseV44,farmCombatAreaV590,monsterRadiusV48
    global farmApproachV722,autoMonsterAttackOn
    playerPath := D2ReadU32(h,player+0x2C)
    if (!MonsterBossProbeReadV1(h,playerPath,0x20,pp))
        return false
    level := CoordLevelV14(h,NumGet(pp,0x1C,"UInt"))
    if (!level)
        return false
    if (level!=270 || BossSearchActiveV430(D2GetActiveGamePidV95(),level))
        return true
    if (!MonsterBossProbeReadV1(h,unit,0x30,u) || NumGet(u,0,"UInt")!=1 || NumGet(u,12,"UInt")!=uid
        || NumGet(u,16,"UInt")=0 || NumGet(u,16,"UInt")=12
        || !MonsterBossProbeReadV1(h,NumGet(u,0x2C,"UInt"),0x20,mp))
        return false
    px := NumGet(pp,2,"UShort"),py := NumGet(pp,6,"UShort")
    mx := NumGet(mp,2,"UShort"),my := NumGet(mp,6,"UShort")
    area := IsObject(farmCombatAreaV590) && farmCombatAreaV590.pid=D2GetActiveGamePidV95()
        && farmCombatAreaV590.level=level ? farmCombatAreaV590.area : ScosCoordRadiusAreaV240(px,py,level)
    radius := Sqrt(area.radiusSq)
    distCenterSq := (mx-area.x)**2+(my-area.y)**2
    distPlayerSq := (mx-px)**2+(my-py)**2
    targetLevel := CoordLevelV14(h,NumGet(mp,0x1C,"UInt"))
    stuckZoneV243 := MonsterStuckZoneExcludedV243(uid,mx,my,targetLevel,D2GetActiveGamePidV95())
    bkSq := Max(1,monsterRadiusV48)**2
    inCenterRadius := targetLevel=level && area.radiusSq>0 && distCenterSq<=area.radiusSq
    inPlayerRadius := distPlayerSq <= bkSq
    closeV722 := autoMonsterAttackOn && Stage2FightEnabledV9() && IsObject(farmApproachV722)
        && farmApproachV722.pid=D2GetActiveGamePidV95() && farmApproachV722.player=player
        && farmApproachV722.level=level && A_TickCount-farmApproachV722.at<500
        && targetLevel=level && distPlayerSq<=farmApproachV722.radiusSq
    global farmItemLockV625
    itemGuardV750 := IsObject(farmItemLockV625) && farmItemLockV625.pid=D2GetActiveGamePidV95()
        && farmItemLockV625.player=player && farmItemLockV625.level=level
    if (itemGuardV750 && !FarmCenterPolicyV741(D2GetActiveGamePidV95(),level))
        ok := targetLevel=level && MonsterInsideAreaV48(mx,my,farmItemLockV625) && !stuckZoneV243
    else if (FarmCenterPolicyV741(D2GetActiveGamePidV95(),level))
        ok := targetLevel=level && inCenterRadius && !stuckZoneV243
    else
        ok := (inCenterRadius || closeV722) && inPlayerRadius && !stuckZoneV243
    if (!ok && monsterCombatUidV45=uid)
        monsterCombatUidV45 := 0,monsterRoadAreaV51 := false,monsterChaseV44 := false
    result := ok ? "ALLOW"
        : !inCenterRadius ? "BLOCK_OUTSIDE_CENTER_RADIUS"
        : !inPlayerRadius ? "BLOCK_FAR_FROM_PLAYER"
        : stuckZoneV243 ? "BLOCK_STUCK_ZONE" : "BLOCK_OTHER"
    PortalLogWriteV66("SCOS_ATTACK_RADIUS_CHECK uid=" . uid . " center=" . area.x . "," . area.y . " coord_row=" . area.row
        . " player=" . px . "," . py . " target=" . mx . "," . my
        . " dist_center=" . Round(Sqrt(distCenterSq),2) . " dist_player=" . Round(Sqrt(distPlayerSq),2)
        . " center_radius=" . radius . " player_radius=" . Sqrt(bkSq)
        . " target_level=" . targetLevel . " result=" . result,"SCOS_RADIUS_" . uid,1000)
    return ok
}

MonsterAttackAreaV48(h,ByRef pb)
{
    routePointsV724 := FarmRoutePointsV724()
    global roomExploreV89,monsterRadiusV48
    if (BOCommonActiveV444())
    {
        return BOCombatAreaV447(pb)
    }
    level := CoordLevelV14(h,NumGet(pb,0x1C,"UInt"))
    global farmItemLockV625,farmFightLockV626
    if (IsObject(farmItemLockV625) && farmItemLockV625.pid=D2GetActiveGamePidV95() && farmItemLockV625.level=level)
        return farmItemLockV625
    if (IsObject(farmFightLockV626) && farmFightLockV626.pid=D2GetActiveGamePidV95() && farmFightLockV626.level=level)
        return farmFightLockV626
    scanRadiusV20 := MonsterScanRadiusV20(level)
    if (level=270)
        return ScosCoordRadiusAreaV240(NumGet(pb,2,"UShort"),NumGet(pb,6,"UShort"),level)
    if (IsObject(roomExploreV89))
        return {x:NumGet(pb,2,"UShort"),y:NumGet(pb,6,"UShort"),radiusSq:scanRadiusV20*scanRadiusV20,source:"ROOM_TEST_RADIUS",row:0}
    global coordRouteV16,monsterRadiusV48,monsterCombatUidV45,monsterRoadAreaV51
    level := CoordLevelV14(h,NumGet(pb,0x1C,"UInt"))
    r := coordRouteV16
    if (IsObject(r) && r.phase="DONE")
        return {x:NumGet(pb,2,"UShort"),y:NumGet(pb,6,"UShort"),radiusSq:8589672450,source:"FREE_LOADED_MAP",row:0}
    if (IsObject(r) && r.phase="NEXT")
{
    idx := r.next
    if (idx>=1 && idx<=routePointsV724.Length())
    {
        p := routePointsV724[idx]
        if (p.level=level)
            return {x:NumGet(pb,2,"UShort"),y:NumGet(pb,6,"UShort")
                ,radiusSq:scanRadiusV20*scanRadiusV20,source:"ROAD_PLAYER_CENTER",row:idx}
    }
    return {x:0,y:0,radiusSq:0,source:"NO_ROUTE_DESTINATION",row:0}
}
    if (IsObject(r))
    {
        idx := r.anchor
        if (!idx)
            idx := r.next
        if (idx>=1 && idx<=routePointsV724.Length())
        {
            p := routePointsV724[idx]
            if (p.level=level)
                return {x:p.x,y:p.y,radiusSq:scanRadiusV20*scanRadiusV20,source:"SAVED_COORDINATE",row:idx+1}
        }
    }
    return {x:0,y:0,radiusSq:0,source:"NO_SAVED_COORDINATE",row:0}
}

MonsterInsideAreaV48(x,y,area)
{
    if (!IsObject(area))
        return true
    return (x-area.x)*(x-area.x)+(y-area.y)*(y-area.y)<=area.radiusSq
}


CombatRetreatPointV62(h,ByRef pb,target,turn := 0)
{
    routePointsV724 := FarmRoutePointsV724()
    global coordRouteV16,goalDetourV14,monsterRadiusV48,monsterExcludeClassesV11
    step := MapMoveDistanceGetV51()
    if (!step)
        return false
    px := NumGet(pb,2,"UShort"), py := NumGet(pb,6,"UShort")
    room := NumGet(pb,0x1C,"UInt")
    level := CoordLevelV14(h,room)
    if (!room || !level)
        return false

    sumDx := 0, sumDy := 0, count := 0
    seen := {}
    radiusSq := monsterRadiusV48 * monsterRadiusV48
    for _, r in MonsterLoadedRoomsV20(h, room)
    {
        u := D2ReadU32(h, r+0x74)
        Loop, 1024
        {
            if (!u || seen.HasKey(u))
                break
            seen[u] := true
            if (D2ReadU32(h,u)=1)
            {
                mode := D2ReadU32(h,u+0x10)
                cls := D2ReadU32(h,u+4)
                uid := D2ReadU32(h,u+0x0C)
                if (mode!=0 && mode!=12 && uid && !MonsterClassExcludedV11(cls,h,u))
                {
                    mpath := D2ReadU32(h,u+0x2C)
                    if (MonsterBossProbeReadV1(h,mpath,0x20,mb))
                    {
                        mx := NumGet(mb,2,"UShort")
                        my := NumGet(mb,6,"UShort")
                        mlevel := CoordLevelV14(h,NumGet(mb,0x1C,"UInt"))
                        if (mlevel = level)
                        {
                            dSq := (mx-px)**2 + (my-py)**2
                            if (dSq <= radiusSq)
                            {
                                d := Sqrt(dSq)
                                if (d > 0)
                                {
                                    sumDx += (px-mx)/d
                                    sumDy += (py-my)/d
                                    count++
                                }
                            }
                        }
                    }
                }
            }
            nx := D2ReadU32(h,u+0xE8)
            if (nx=u)
                break
            u := nx
        }
    }

    dx := 0, dy := 0
    if (count > 0)
    {
        len := Sqrt(sumDx*sumDx + sumDy*sumDy)
        if (len > 0.001)
        {
            dx := sumDx / len
            dy := sumDy / len
        }
    }
    if (!dx && !dy)
    {
        if (IsObject(target) && MonsterBossProbeReadV1(h,target.path,0x20,tb))
        {
            dx := px-NumGet(tb,2,"UShort")
            dy := py-NumGet(tb,6,"UShort")
        }
        if (!dx && !dy)
            dx := 1
    }
    if (turn)
    {
        oldDx := dx
        dx := turn>0 ? -dy : dy
        dy := turn>0 ? oldDx : -oldDx
    }
    length := Sqrt(dx*dx+dy*dy)
    if (length < 0.001)
        length := 1
    tx := Max(1,Min(65535,Round(px+step*dx/length)))
    ty := Max(1,Min(65535,Round(py+step*dy/length)))
    area := MonsterAttackAreaV48(h,pb)
    if (IsObject(area) && area.radiusSq>0 && area.source!="FREE_LOADED_MAP")
    {
        bound := Sqrt(area.radiusSq)*0.85
        gx := tx-area.x, gy := ty-area.y, goalDist := Sqrt(gx*gx+gy*gy)
        if (goalDist>bound)
        tx := Round(area.x+gx*bound/goalDist), ty := Round(area.y+gy*bound/goalDist)
        if ((tx-px)*(tx-px)+(ty-py)*(ty-py)<4)
        tx := Round(area.x-dy*bound/length), ty := Round(area.y+dx*bound/length)
        if (!MonsterInsideAreaV48(tx,ty,area))
        tx := area.x, ty := area.y
    }
    if (IsObject(coordRouteV16) && coordRouteV16.phase="NEXT" && coordRouteV16.next>=1
        && coordRouteV16.next<=routePointsV724.Length() && coordRouteV16.closestGoalDistance>=0)
    {
        goal := routePointsV724[coordRouteV16.next]
        bound := coordRouteV16.closestGoalDistance+goalDetourV14
        gx := tx-goal.x, gy := ty-goal.y, retreatDist := Sqrt(gx*gx+gy*gy)
        if (retreatDist>bound && retreatDist>0)
        tx := Round(goal.x+gx*bound/retreatDist), ty := Round(goal.y+gy*bound/retreatDist)
    }
    return {x:tx,y:ty}
}

CombatLowHPAlternateV299(h,ByRef pb,pid,target)
{
    global roomExploreV89
    global combatMildRecoverV299, potHPThreshold, monsterCombatUidV45, monsterChaseV44,monsterLockUntilDeadV145
    if (!IsObject(combatMildRecoverV299) && !IsObject(target) && !monsterCombatUidV45)
        return false
    lifePlayerV305 := D2ReadU32(h,D2GetModuleBaseV35(pid,"D2Client.dll")+0x11BBFC)
    lifeV305 := MonsterBossProbeHPV2(h,D2ReadU32(h,lifePlayerV305+0x5C))
    hp := lifeV305.ok ? lifeV305.hp : D2GetCurrentHPV1()
    fullEnoughV305 := lifeV305.ok && lifeV305.maxraw>0 && lifeV305.raw>=lifeV305.maxraw*0.9
    PortalLogWriteV66("FARM_HP_DECISION branch=ALTERNATE hp=" . hp . " max=" . lifeV305.maxhp
        . " verified=" . lifeV305.ok . " threshold1=" . potHPThreshold
        . " band=" . CombatHPBandV305(hp,fullEnoughV305) . " full90=" . fullEnoughV305,"FARM_HP_ALTERNATE",1000)
    if (hp=0)
        return true
    if (hp<0 && !IsObject(combatMildRecoverV299))
        return false
    if (CombatHPBandV305(hp,fullEnoughV305)="NORMAL")
    {
        combatMildRecoverV299 := false
        return false
    }
    level := CoordLevelV14(h,NumGet(pb,0x1C,"UInt"))
    px := NumGet(pb,2,"UShort"), py := NumGet(pb,6,"UShort")
    if (!level)
        return true
    if (!IsObject(combatMildRecoverV299) || combatMildRecoverV299.level!=level)
        combatMildRecoverV299 := {phase:"ATTACK",level:level,last:0,turn:0,lastX:px,lastY:py,stuck:0,attackWait:0}
    r := combatMildRecoverV299
    if (!NativeDispatchReadyV10(true) || D2GetActiveGamePidV95()!=pid || !AutoMonsterPacketCleanupV1()
        || (r.last && A_TickCount-r.last<250))
        return true
    if (r.phase="ATTACK" && IsObject(target))
    {
        if (!MonsterBossProbeReadV1(h,target.unit,0x30,ub))
            return true
        mode := NumGet(ub,0x10,"UInt")
        if (NumGet(ub,0,"UInt")!=1 || NumGet(ub,0x0C,"UInt")!=target.uid || mode=0 || mode=12)
            r.phase := "MOVE"
        else
        {
            if (target.level=270)
            {
                targetHPV243 := MonsterBossProbeHPV2(h,D2ReadU32(h,target.unit+0x5C))
                if (!MonsterChaseProgressV44(target.uid,px,py,target.dist,targetHPV243.ok ? targetHPV243.raw : -1
                    ,target.x,target.y,target.level,pid,h,target.unit))
                {
                    monsterCombatUidV45 := 0
                    r.phase := "MOVE",r.last := 0
                    return true
                }
            }
            player := D2ReadU32(h,D2GetModuleBaseV35(pid,"D2Client.dll")+0x11BBFC)
            if (AutoMonsterPacketSendV1(pid,target.unit,target.uid))
            {
                monsterCombatUidV45 := MonsterLockEligibleV308(NumGet(ub,4,"UInt")) ? target.uid : 0
                if (target.level=270 && IsObject(monsterChaseV44) && monsterChaseV44.uid=target.uid)
                {
                    if (!monsterChaseV44.since)
                        monsterChaseV44.since := A_TickCount
                    monsterChaseV44.queued++
                }
                else
                    monsterChaseV44 := false
                r.phase := "MOVE", r.last := A_TickCount, r.attackWait := 0
                AutoMonsterAttackLogV2("LOW_HP_ATTACK_ONCE uid=" . target.uid . " next=EVADE hp=" . hp)
                return true
            }
            else
            {
                if (!r.attackWait)
                    r.attackWait := A_TickCount
                if (A_TickCount-r.attackWait>=1000)
                    r.phase := "MOVE", r.attackWait := 0
            }
            if (r.phase!="MOVE")
                return true
        }
    }
    if (px=r.lastX && py=r.lastY)
        r.stuck++
    else
        r.stuck := 0, r.turn := 0
    if (r.stuck>=3)
        r.turn := r.turn=1 ? -1 : 1, r.stuck := 0
    point := CombatRetreatPointV62(h,pb,target,r.turn)
    if (!IsObject(point))
        return true
    if (NativeMovePointV14(pid,point.x,point.y,level))
    {
        r.lastX := px, r.lastY := py, r.last := A_TickCount, r.phase := "ATTACK"
        AutoMonsterAttackLogV2("LOW_HP_EVADE_ONCE destination=" . point.x . "," . point.y . " next=ATTACK hp=" . hp)
    }
    return true
}

CombatRecoverScanV298(h,ByRef pb)
{
    global monsterRadiusV48
    px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort")
    level := CoordLevelV14(h,NumGet(pb,0x1C,"UInt"))
    radius := Max(1,monsterRadiusV48),seen := {},count := 0,started := A_TickCount
    result := {count:0,complete:true,dx:0,dy:0,nearest:false,radius:radius}
    for _,room in MonsterLoadedRoomsV20(h,NumGet(pb,0x1C,"UInt"))
    {
        u := D2ReadU32(h,room+0x74)
        Loop, 1024
        {
            if (!u || seen.HasKey(u))
                break
            if (count>=2048 || A_TickCount-started>80)
            {
                result.complete := false
                return result
            }
            seen[u] := true,count++
            if (!MonsterBossProbeReadV1(h,u,0xEC,ub))
            {
                result.complete := false
                break
            }
            next := NumGet(ub,0xE8,"UInt"),mode := NumGet(ub,0x10,"UInt")
            if (NumGet(ub,0,"UInt")=1 && mode!=0 && mode!=12
                && !MonsterClassExcludedV11(NumGet(ub,4,"UInt"),h,u))
            {
                path := NumGet(ub,0x2C,"UInt")
                if (!MonsterBossProbeReadV1(h,path,0x20,mb))
                    result.complete := false
                else if (CoordLevelV14(h,NumGet(mb,0x1C,"UInt"))=level)
                {
                    x := NumGet(mb,2,"UShort"),y := NumGet(mb,6,"UShort")
                    dx := px-x,dy := py-y,dist := dx*dx+dy*dy
                    if (dist<=radius*radius)
                    {
                        result.count++
                        weight := Max(1,dist)
                        result.dx += dx/weight,result.dy += dy/weight
                        if (!IsObject(result.nearest) || dist<result.nearest.dist)
                            result.nearest := {x:x,y:y,dist:dist}
                    }
                }
            }
            u := next
            if (A_Index=1024 && u)
                result.complete := false
        }
    }
    return result
}

CombatHPBandV305(hp,fullEnough:=false)
{
    global potHPThreshold,potHPThreshold2V299
    if (fullEnough)
        return "NORMAL"
    if (hp<0)
        return "UNKNOWN"
    if (potHPThreshold2V299>0 && hp<potHPThreshold2V299)
        return "ESCAPE"
    if (potHPThreshold>0 && hp<=potHPThreshold)
        return "ALTERNATE"
    return "NORMAL"
}

CombatRoomsTouchV305(a,b)
{
    overlapX := Min(a.x+a.w,b.x+b.w)-Max(a.x,b.x)
    overlapY := Min(a.y+a.h,b.y+b.h)-Max(a.y,b.y)
    return (overlapY>0 && (a.x+a.w=b.x || b.x+b.w=a.x))
        || (overlapX>0 && (a.y+a.h=b.y || b.y+b.h=a.y))
}

CombatEscapeNeighborV305(h,ByRef pb,r)
{
    routePointsV724 := FarmRoutePointsV724()
    global chaseCheckSecV9
    room1 := NumGet(pb,0x1C,"UInt"),current := D2ReadU32(h,room1+0x10)
    px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort")
    if (current!=r.escapeRoomV305)
    {
        r.previousRoomV305 := r.escapeRoomV305,r.escapeRoomV305 := current
        r.roomGoalV305 := false,r.roomProbeAtV305 := A_TickCount,r.roomProbeXV305 := px,r.roomProbeYV305 := py
    }
    moved := (px-r.roomProbeXV305)**2+(py-r.roomProbeYV305)**2>1
    blocked := !moved && A_TickCount-r.roomProbeAtV305>=Max(0.1,chaseCheckSecV9)*1000
    if (moved)
        r.roomProbeAtV305 := A_TickCount,r.roomProbeXV305 := px,r.roomProbeYV305 := py
    if (IsObject(r.roomGoalV305) && !blocked)
        return r.roomGoalV305
    if (blocked && IsObject(r.roomGoalV305))
    {
        r.blockedRoomsV305[r.roomGoalV305.room] := A_TickCount+3000
        r.roomGoalV305 := false,r.roomProbeAtV305 := A_TickCount
    }
    node := RoomExploreReadV89(h,current,r.level)
    if (!IsObject(node))
        return false
    best := false,bestRank := 1.0e30
    for _,address in node.links
    {
        other := RoomExploreReadV89(h,address,r.level)
        if (!IsObject(other) || !CombatRoomsTouchV305(node,other)
            || (r.blockedRoomsV305.HasKey(address) && A_TickCount<r.blockedRoomsV305[address]))
            continue
        onward := 0
        for _,nextAddress in other.links
        {
            if (nextAddress=current)
                continue
            nextRoom := RoomExploreReadV89(h,nextAddress,r.level,true)
            if (IsObject(nextRoom) && CombatRoomsTouchV305(other,nextRoom))
                onward++
        }
        point := {x:other.cx,y:other.cy,room:address},distance := 1.0e30
        for _,saved in routePointsV724
        {
            if (saved.level!=r.level || saved.x<other.x || saved.x>=other.x+other.w
                || saved.y<other.y || saved.y>=other.y+other.h)
                continue
            d := (px-saved.x)**2+(py-saved.y)**2
            if (d<distance)
                point.x := saved.x,point.y := saved.y,distance := d
        }
        rank := (onward ? 0 : 1000000000)+(address=r.previousRoomV305 ? 100000000 : 0)
            +Sqrt((px-point.x)**2+(py-point.y)**2)
        if (rank<bestRank)
            best := point,bestRank := rank
    }
    r.roomGoalV305 := best
    if (IsObject(best))
        AutoMonsterAttackLogV2("LOW_HP_ADJACENT_ROOM from=" . V92Hex(current) . " to=" . V92Hex(best.room)
            . " destination=" . best.x . "," . best.y . " prefer=ONWARD_EXIT_RECHECK_AFTER_ENTRY",true)
    return best
}

CombatRecoverTickV48(h,ByRef pb,pid,target)
{
    routePointsV724 := FarmRoutePointsV724()
    global combatRecoverV48,combatMildRecoverV299,potHPThreshold,potHPThreshold2V299,monsterCombatUidV45,monsterChaseV44,monsterRoadAreaV51
    global coordRouteV16,coordNoTargetSinceV14,farmLastCombatTickV72,monsterRadiusV48,teleportKeyV55,teleportIntervalSecV56
    player := D2ReadU32(h,D2GetModuleBaseV35(pid,"D2Client.dll")+0x11BBFC)
    life := MonsterBossProbeHPV2(h,D2ReadU32(h,player+0x5C))
    hp := life.ok ? life.hp : D2GetCurrentHPV1()
    fullEnough := life.ok && life.maxraw>0 && life.raw>=life.maxraw*0.9
    band := CombatHPBandV305(hp,fullEnough)
    PortalLogWriteV66("FARM_HP_DECISION branch=ESCAPE hp=" . hp . " max=" . life.maxhp
        . " verified=" . life.ok . " threshold1=" . potHPThreshold . " threshold2=" . potHPThreshold2V299
        . " band=" . band . " full90=" . fullEnough,"FARM_HP_ESCAPE",1000)
    if (!IsObject(combatRecoverV48) && (hp<=0 || band!="ESCAPE"))
        return false
    level := CoordLevelV14(h,NumGet(pb,0x1C,"UInt"))
    if (!level)
        return IsObject(combatRecoverV48)
    px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort")
    if (!IsObject(combatRecoverV48) || combatRecoverV48.level!=level || combatRecoverV48.pid!=pid)
    {
        row := 0,center := {x:px,y:py}
        orbitRadius := Max(0.7,monsterRadiusV48-1),orbitIndex := 0,bestDistance := -1
        Loop, 8
        {
            angle := (A_Index-1)*0.7853981633974483
            ox := Round(center.x+orbitRadius*Cos(angle)),oy := Round(center.y+orbitRadius*Sin(angle))
            distance := (px-ox)**2+(py-oy)**2
            if (bestDistance<0 || distance<bestDistance)
                bestDistance := distance,orbitIndex := A_Index-1
        }
        combatRecoverV48 := {pid:pid,level:level,last:0,moving:false,retreatRow:row
            ,center:center,orbitIndex:orbitIndex,orbitRadius:orbitRadius,probeX:px,probeY:py,probeTick:A_TickCount
            ,escapeAttempts:0,escapeLast:0,escapeDone:false,escapeFromX:px,escapeFromY:py,escapeRetryAt:0
            ,escapeRoomV305:0,previousRoomV305:0,roomGoalV305:false,blockedRoomsV305:{},roomProbeAtV305:0}
        combatMildRecoverV299 := false
        AutoMonsterAttackLogV2("LOW_HP_RECOVER_BEGIN hp=" . hp . " threshold2=" . potHPThreshold2V299
            . " next=TELEPORT_THEN_ADJACENT_ROOM_ESCAPE center=" . center.x . "," . center.y . " row=" . row)
    }
    r := combatRecoverV48
    monsterCombatUidV45 := 0,monsterChaseV44 := false,monsterRoadAreaV51 := false
    farmLastCombatTickV72 := A_TickCount
    if (IsObject(coordRouteV16))
        coordRouteV16.stuckProbe := false,coordRouteV16.moveProbe := false,coordRouteV16.lastDispatch := 0
    if (hp<0)
        return true
    if (!NativeDispatchReadyV10(true) || D2GetActiveGamePidV95()!=pid || !AutoMonsterPacketCleanupV1())
        return true
    if (band!="ESCAPE" && band!="UNKNOWN")
    {
        if (r.moving)
        {
            if (NativeMovePointV14(pid,px,py,level,false,false,true,false,{recover:r,stop:true}))
                r.moving := false
            return true
        }
        combatRecoverV48 := false,combatMildRecoverV299 := false,coordNoTargetSinceV14 := 0
        CoordResumeNearestV303(h,pb,pid,"AFTER_HP2_RECOVERY")
        AutoMonsterAttackLogV2("LOW_HP_RECOVER_DONE hp=" . life.hp . "/" . life.maxhp . " reason=CURRENT_HP_BAND band=" . band . " full90=" . fullEnough . " next=RESUME_CURRENT_BAND")
        return false
    }
    escapePointV305 := CombatEscapeNeighborV305(h,pb,r)
    if (IsObject(escapePointV305))
        r.center := {x:escapePointV305.x,y:escapePointV305.y}
    if (!r.escapeDone && teleportKeyV55!="")
    {
        if (r.escapeLast && A_TickCount-r.escapeLast>=300)
        {
            scan := CombatRecoverScanV298(h,pb)
            if (scan.complete && !scan.count)
                r.escapeDone := true
        }
        if (r.escapeAttempts>=3)
            r.escapeDone := true
        teleCooldown := Max(3,teleportIntervalSecV56)*1000
        if (!r.escapeDone && (!r.escapeLast || A_TickCount-r.escapeLast>=teleCooldown)
            && (!r.escapeRetryAt || A_TickCount>=r.escapeRetryAt))
        {
            if (CombatRecoverTeleportV302(h,pb,pid,r))
            {
                r.last := 0,r.probeX := px,r.probeY := py,r.probeTick := A_TickCount
                return true
            }
            r.escapeRetryAt := A_TickCount+300
        }
    }
    if (IsObject(escapePointV305))
    {
        if (!r.last || A_TickCount-r.last>=250)
            if (NativeMovePointV14(pid,escapePointV305.x,escapePointV305.y,level,false,false,true,false,{recover:r}))
                r.last := A_TickCount,r.moving := true
        return true
    }
    currentRoomV305 := RoomExploreReadV89(h,D2ReadU32(h,NumGet(pb,0x1C,"UInt")+0x10),level,true)
    if (IsObject(currentRoomV305))
        r.center := {x:currentRoomV305.cx,y:currentRoomV305.cy}
    else
        r.center := {x:px,y:py}
    if (r.last && A_TickCount-r.last<250)
        return true
    r.orbitRadius := Max(0.7,monsterRadiusV48-1)
    angle := r.orbitIndex*0.7853981633974483
    tx := Round(r.center.x+r.orbitRadius*Cos(angle)),ty := Round(r.center.y+r.orbitRadius*Sin(angle))
    reached := (px-tx)**2+(py-ty)**2<=4
    blocked := A_TickCount-r.probeTick>=1000 && (px-r.probeX)**2+(py-r.probeY)**2<=1
    if (reached || blocked)
    {
        r.orbitIndex := Mod(r.orbitIndex+1,8)
        angle := r.orbitIndex*0.7853981633974483
        tx := Round(r.center.x+r.orbitRadius*Cos(angle)),ty := Round(r.center.y+r.orbitRadius*Sin(angle))
        r.probeX := px,r.probeY := py,r.probeTick := A_TickCount
    }
    else if ((px-r.probeX)**2+(py-r.probeY)**2>1)
        r.probeX := px,r.probeY := py,r.probeTick := A_TickCount
    if (IsObject(currentRoomV305))
    {
        tx := Max(currentRoomV305.x+1,Min(currentRoomV305.x+currentRoomV305.w-2,tx))
        ty := Max(currentRoomV305.y+1,Min(currentRoomV305.y+currentRoomV305.h-2,ty))
    }
    if (NativeMovePointV14(pid,tx,ty,level,false,false,true,false,{recover:r}))
    {
        r.last := A_TickCount,r.moving := true
        AutoMonsterAttackLogV2("LOW_HP_RECOVER_ORBIT row=" . r.retreatRow . " center=" . r.center.x . "," . r.center.y
            . " destination=" . tx . "," . ty . " radius=" . monsterRadiusV48 . " hp=" . hp . " blocked=" . blocked,true)
    }
    return true
}

CombatRecoverTeleportV302(h,ByRef pb,pid,r)
{
    global combatRecoverV48,autoMonsterAttackOn,teleportKeyV55,backgroundAimV64
    if (combatRecoverV48!=r || !autoMonsterAttackOn || teleportKeyV55=""
        || r.escapeAttempts>=3 || D2GetActiveGamePidV95()!=pid
        || !NativeDispatchReadyV10(true) || !AutoMonsterPacketCleanupV1())
        return false
    hwnd := GameTargetHwndV63(),base := D2GetModuleBaseV35(pid,"D2Client.dll")
    player := D2ReadU32(h,base+0x11BBFC),path := player ? D2ReadU32(h,player+0x2C) : 0
    if (!path || CoordLevelV14(h,NumGet(pb,0x1C,"UInt"))!=r.level)
        return false
    view := AutoMonsterAttackViewV1(h,base,hwnd,path)
    if (!IsObject(view) || view.gw<=64 || view.gh<=128)
        return false
    px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort")
    dx := r.center.x-px,dy := r.center.y-py
    if (dx*dx+dy*dy<1)
    {
        scan := CombatRecoverScanV298(h,pb)
        dx := scan.dx,dy := scan.dy
        if (dx*dx+dy*dy<0.000001)
            dx := -1,dy := 0
    }
    failedMove := r.escapeAttempts && (px-r.escapeFromX)**2+(py-r.escapeFromY)**2<25
    turn := failedMove ? (r.escapeAttempts=1 ? 1.047197551196598 : -1.047197551196598) : 0
    rx := dx*Cos(turn)-dy*Sin(turn),ry := dx*Sin(turn)+dy*Cos(turn)
    sx := (rx-ry)*16,sy := (rx+ry)*8,length := Sqrt(sx*sx+sy*sy)
    if (length<0.001)
        return false
    ux := sx/length,uy := sy/length
    playerSX := Max(16,Min(view.gw-16,NumGet(pb,8,"Int")-view.ox))
    playerSY := Max(32,Min(view.gh-64,NumGet(pb,12,"Int")-view.oy))
    reachX := Abs(ux)<0.000001 ? 1000000 : (ux>0 ? view.gw-16-playerSX : 16-playerSX)/ux
    reachY := Abs(uy)<0.000001 ? 1000000 : (uy>0 ? view.gh-64-playerSY : 32-playerSY)/uy
    reach := Min(reachX,reachY)
    if (reach<1)
        return false
    clientX := Round((playerSX+ux*reach)*view.cw/view.gw)
    clientY := Round((playerSY+uy*reach)*view.ch/view.gh)
    try
    {
        if (!GameTargetAimV63(clientX,clientY))
            return false
        Sleep, 30
        if (combatRecoverV48!=r || !autoMonsterAttackOn || GameTargetHwndV63()!=hwnd
            || D2GetActiveGamePidV95()!=pid || !NativeDispatchReadyV10(true) || !AutoMonsterPacketCleanupV1())
            return false
        r.escapeAttempts++,r.escapeLast := A_TickCount,r.escapeFromX := px,r.escapeFromY := py
        sent := BuffCheckedSendV29(teleportKeyV55)
        AutoMonsterAttackLogV2("LOW_HP_ESCAPE_TELEPORT attempt=" . r.escapeAttempts . "/3 aim_client=" . clientX . "," . clientY
            . " previous_cast_no_move=" . failedMove . " sent=" . sent . " effect=WAIT_POSITION_CHANGE")
        return sent
    }
    finally
        backgroundAimV64 := false
}

ScosOrderedRouteV234()
{
    routePointsV724 := FarmRoutePointsV724()

    return IsObject(routePointsV724) && routePointsV724.Length()>0
        && (routePointsV724[1].level=270 || BOFinalRouteActiveV451())
}

CoordYellowIndexV48()
{
    global coordSavedV15,roomExploreV89,coordGoV59,scosEntryV162,coordYellowRowV350,coordRouteV16
    if (IsObject(coordGoV59))
        return coordGoV59.row
    if (IsObject(roomExploreV89) && roomExploreV89.savedRouteOnly)
        return roomExploreV89.displayRow
    if (IsObject(coordRouteV16) && coordRouteV16.pid && coordRouteV16.yellow>=1
        && coordRouteV16.yellow<=coordSavedV15.Length()
        && coordSavedV15[coordRouteV16.yellow].level=coordRouteV16.startLevel)
        return coordRouteV16.yellow
    return coordYellowRowV350>=1 && coordYellowRowV350<=coordSavedV15.Length() ? coordYellowRowV350 : 0
}


MonsterStuckZoneExcludedV243(uid,x,y,level,pid)
{
    global monsterStuckZonesV243,routeMapIdV21
    if (!IsObject(monsterStuckZonesV243))
        return false
    for _,zone in monsterStuckZonesV243
    {
        if (zone.HasKey("until") && A_TickCount >= zone.until)
            continue
        if (zone.pid!=pid || zone.level!=level || zone.mapId!=routeMapIdV21)
            continue
            
        if (zone.kind="ROOM")
        {
            if (x>=zone.x && x<zone.x+zone.w && y>=zone.y && y<zone.y+zone.h)
                return true
        }
        else if (zone.kind="UID")
        {
            if (uid=zone.uid)
                return true
        }
        else if (zone.kind="RADIUS")
        {
            if ((x-zone.x)**2+(y-zone.y)**2<=zone.radiusSq)
                return true
        }
    }
    return false
}


MonsterRoomAtV655(h,pid,level,x,y)
{
    live := MapLiveIdentityV399(pid,level)
    if (!IsObject(live))
        return false
    room := D2ReadU32(h,live.levelPtr+0x10),seen := {}
    Loop, 4096
    {
        if (!room || seen.HasKey(room))
            break
        seen[room] := true
        node := RoomExploreReadV89(h,room,level,true)
        if (IsObject(node) && x>=node.x && x<node.x+node.w && y>=node.y && y<node.y+node.h)
            return node
        room := D2ReadU32(h,room+0x24)
    }
    return false
}

MonsterStuckRoomAddV548(h,unit,uid,targetX,targetY,level,pid,playerX,playerY)
{
    global monsterStuckZonesV243, routeMapIdV21, monsterLockRoomSecV622
    lockMs := Max(1, monsterLockRoomSecV622) * 1000
    lockUntil := A_TickCount + lockMs
    
    if (!IsObject(monsterStuckZonesV243))
        monsterStuckZonesV243 := []
    
    room1 := 0, node := false
    if (h && unit && MonsterBossProbeReadV1(h,unit,0x30,ub) && NumGet(ub,0x2C,"UInt"))
    {
        path := NumGet(ub,0x2C,"UInt")
        if (MonsterBossProbeReadV1(h,path,0x20,pathBuf))
        {
            room1 := NumGet(pathBuf,0x1C,"UInt")
            if (room1)
                node := RoomExploreReadV89(h,D2ReadU32(h,room1+0x10),level,true)
        }
    }
    
    if (!IsObject(node) || targetX<node.x || targetX>=node.x+node.w || targetY<node.y || targetY>=node.y+node.h)
        node := MonsterRoomAtV655(h,pid,level,targetX,targetY)
    if (!IsObject(node))
    {
        AutoMonsterAttackLogV2("TARGET_ROOM_UNREADABLE uid=" . uid . " action=RETRY_ROOM_READ no_radius_or_uid_lock=1",true)
        return false
    }

    for _,zone in monsterStuckZonesV243
        if (zone.kind="ROOM" && zone.pid=pid && zone.level=level
            && zone.mapId=routeMapIdV21 && zone.room=node.r2)
        {
            zone.until := lockUntil
            return true
        }
            
    monsterStuckZonesV243.Push({kind:"ROOM",pid:pid,level:level,mapId:routeMapIdV21
        ,room:node.r2,x:node.x,y:node.y,w:node.w,h:node.h,until:lockUntil})
    
    AutoMonsterAttackLogV2("TARGET_STUCK_ROOM_LOCK trigger_uid=" . uid . " room=" . V92Hex(node.r2)
        . " rect=" . node.x . "," . node.y . "," . node.w . "," . node.h
        . " duration=" . lockMs . "ms")
    FonInfoPushV385("Đánh không tiến triển: tạm khóa phòng " . monsterLockRoomSecV622 . " giây; tiếp tục lộ trình.")
    return true
}

MonsterStuckZonesResetV243()
{
    global monsterStuckZonesV243,monsterProgressByUidV591
    monsterStuckZonesV243 := [],monsterProgressByUidV591 := {}
}

MonsterRetryExcludedV44(uid,x := -1,y := -1,level := 0,pid := 0)
{
    global monsterRetryUntilV44
    if (MonsterStuckZoneExcludedV243(uid,x,y,level,pid))
        return true
    if (!IsObject(monsterRetryUntilV44) || !monsterRetryUntilV44.HasKey(uid))
        return false
    if (A_TickCount<monsterRetryUntilV44[uid])
        return true
    monsterRetryUntilV44.Delete(uid)
    return false
}


; Road-farm send watchdog. Kept separate from MonsterChaseProgressV44's HP
; progress clock: an ally can reduce target HP while OUR dispatch is queued=0.

; Save only the most recently skipped combat-stuck monster for the Info view.
; cls means monster class ID, NOT its per-spawn UID. dist is real map distance.
FarmStuckSkipRememberV1234(uid,cls:=-1,dist:=-1,pid:=0)
{
    global farmStuckSkipInfoV1234,farmScanListV682,farmCombatViewV624
    global currentAttackPidV550,currentAttackUidV520,currentAttackClassV520,currentAttackDistV523
    global monsterChaseV44
    if (!uid)
        return false
    if (IsObject(farmScanListV682))
    {
        for _, mobV1234 in farmScanListV682
        {
            if (mobV1234.uid=uid)
            {
                if (cls<0)
                    cls := mobV1234.cls
                if (dist<0)
                    dist := Sqrt(mobV1234.dist)
                break
            }
        }
    }
    if (IsObject(monsterChaseV44) && monsterChaseV44.uid=uid
        && (!pid || monsterChaseV44.pid=pid) && dist<0)
        dist := monsterChaseV44.distance
    if (IsObject(farmCombatViewV624) && farmCombatViewV624.uid=uid
        && (!pid || farmCombatViewV624.pid=pid) && cls<0)
        cls := farmCombatViewV624.cls
    if (currentAttackUidV520=uid && (!pid || currentAttackPidV550=pid))
    {
        if (cls<0)
            cls := currentAttackClassV520
        if (dist<0)
            dist := currentAttackDistV523
    }
    ; A new monster REPLACES the old display value; never accumulate entries.
    farmStuckSkipInfoV1234 := {uid:uid,cls:cls,dist:dist,at:A_TickCount}
    return true
}

MonsterStuckUidSkipV711(uid,level,pid)
{
    global monsterStuckZonesV243,routeMapIdV21,monsterLockRoomSecV622
    global monsterCombatUidV45,monsterRoadAreaV51,monsterChaseV44
    global currentAttackUidV520,currentAttackAtV520,monsterProgressByUidV591
    if (!IsObject(monsterStuckZonesV243))
        monsterStuckZonesV243 := []
    until := A_TickCount+Max(1,monsterLockRoomSecV622)*1000
    found := false
    for _,zone in monsterStuckZonesV243
        if (zone.kind="UID" && zone.uid=uid && zone.pid=pid && zone.level=level && zone.mapId=routeMapIdV21)
            zone.until := until,found := true
    if (!found)
        monsterStuckZonesV243.Push({kind:"UID",uid:uid,pid:pid,level:level,mapId:routeMapIdV21,until:until})
    if (monsterCombatUidV45=uid)
        monsterCombatUidV45 := 0,monsterRoadAreaV51 := false
    if (IsObject(monsterChaseV44) && monsterChaseV44.uid=uid)
        monsterChaseV44 := false
    ; Clear stale attack/watchdog state or it reports the same skipped UID
    ; repeatedly while the selector is supposed to choose another monster.
    if (currentAttackUidV520=uid)
        currentAttackUidV520 := 0,currentAttackAtV520 := 0
    keyV917 := pid . "|" . level . "|" . uid
    if (IsObject(monsterProgressByUidV591) && monsterProgressByUidV591.HasKey(keyV917))
        monsterProgressByUidV591.Delete(keyV917)
    FarmAttackHoldReleaseV15()
}

MonsterStuckIncomingV711(h,pid,level,candidates,playerX:=0,playerY:=0)
{
    global monsterChaseV44,monsterCombatUidV45,monsterRadiusV48,monsterRoadAreaV51
    global monsterProgressByUidV591,farmCloseRadiusV391,chaseCheckSecV9
    c := monsterChaseV44
    ; Only switch after the configured timeout, including stalled packet sending.
    if (chaseCheckSecV9<=0)
        return false
    if (!IsObject(c) || c.pid!=pid || c.level!=level || monsterCombatUidV45!=c.uid
        || !c.since || (c.queued<1 && !c.farmWatchV1181)
        || A_TickCount-c.since<Max(1,chaseCheckSecV9)*1000
        || A_TickCount-c.seenAtV591>1500)
        return false
    current := false,near := false
    radiusSq := Max(1,farmCloseRadiusV391)**2
    for _,a in candidates
    {
        if (a.uid=c.uid)
            current := a
        else if (a.level=level && a.dist<=radiusSq && (!IsObject(near) || a.dist<near.dist))
            near := a
    }
    if (!IsObject(current) || !IsObject(near))
        return false
    hp := MonsterBossProbeHPV2(h,D2ReadU32(h,current.unit+0x5C))
    if (hp.ok && (c.hp<0 || hp.raw<c.hp || c.distance-Sqrt(current.dist)>1))
        return false
    oldUid := c.uid
    FarmStuckSkipRememberV1234(oldUid,current.cls,Sqrt(current.dist),pid)
    bkRadius := Max(1,monsterRadiusV48)
    skipDistanceV752 := MonsterSkipDistanceGetV752(bkRadius)
    bkHalfSq := skipDistanceV752*skipDistanceV752
    isClose := current.dist <= bkHalfSq
    monsterProgressByUidV591.Delete(pid . "|" . level . "|" . oldUid)
    if (isClose)
    {
        MonsterStuckUidSkipV711(oldUid,level,pid)
        PortalLogWriteV66("COMBAT_STUCK_SWITCH old_uid=" . oldUid . " new_uid=" . near.uid
            . " scope=UID dist_sq=" . Round(current.dist,1) . " half_bk_sq=" . Round(bkHalfSq,1))
    }
    else
    {
        if (monsterCombatUidV45=oldUid)
            monsterCombatUidV45 := 0,monsterRoadAreaV51 := false
        if (IsObject(monsterChaseV44) && monsterChaseV44.uid=oldUid)
            monsterChaseV44 := false
        FarmAttackHoldReleaseV15()
        roomOkV1172 := MonsterStuckRoomAddV548(h,current.unit,oldUid,current.x,current.y,level,pid,playerX,playerY)
        if (!roomOkV1172)
            MonsterStuckUidSkipV711(oldUid,level,pid)
        PortalLogWriteV66("COMBAT_STUCK_SWITCH old_uid=" . oldUid . " new_uid=" . near.uid
            . " scope=" . (roomOkV1172 ? "ROOM" : "UID_FALLBACK") . " dist_sq=" . Round(current.dist,1) . " half_bk_sq=" . Round(bkHalfSq,1))
    }
    monsterCombatUidV45 := near.uid
    FonInfoPushV385("Kẹt đánh: bỏ qua " . (isClose ? "quái UID " : "phòng chứa quái UID ") . oldUid . ", chuyển sang quái gần " . near.uid . ".")
    return near
}

MonsterChaseProgressV44(uid,x,y,distSq,hpRaw := -1,targetX := -1,targetY := -1,targetLevel := 0,pid := 0,h := 0,unit := 0,farmWatchV1181 := false)
{
    global monsterChaseV44, chaseCheckSecV9
    global monsterProgressByUidV591, monsterStuckZonesV243, routeMapIdV21
    global monsterCombatUidV45, monsterRoadAreaV51, monsterRadiusV48

    if (!IsObject(monsterProgressByUidV591))
        monsterProgressByUidV591 := {}

    keyV591 := pid . "|" . targetLevel . "|" . uid
    c := monsterProgressByUidV591[keyV591]

    if (!IsObject(c) || c.unitV591!=unit || A_TickCount-c.seenAtV591>30000)
    {
        if (monsterProgressByUidV591.Count()>=256)
        {
            oldestKeyV591 := "",oldestAtV591 := A_TickCount
            for oldKeyV591,oldV591 in monsterProgressByUidV591
                if (oldV591.seenAtV591<=oldestAtV591)
                    oldestKeyV591 := oldKeyV591,oldestAtV591 := oldV591.seenAtV591
            if (oldestKeyV591!="")
                monsterProgressByUidV591.Delete(oldestKeyV591)
        }
        ; V917: selected Farm combat targets must start the no-progress clock
        ; even if a blocked/remote attack command never enters the send queue.
        farmSelectedV917 := farmWatchV1181 || (pid && FarmCenterPendingV741(pid))
        c := {uid:uid, x:x, y:y, hp:hpRaw, distance:Sqrt(distSq)
            ,since:(farmSelectedV917 ? A_TickCount : 0), queued:0,farmWatchV1181:farmSelectedV917
            ,targetX:targetX, targetY:targetY, level:targetLevel, pid:pid
            ,unitV591:unit, seenAtV591:A_TickCount}
        monsterProgressByUidV591[keyV591] := c
        monsterChaseV44 := c
        return true
    }

    c.seenAtV591 := A_TickCount
    monsterChaseV44 := c
    distanceNow := Sqrt(distSq)

    hpChangedV592 := hpRaw>=0 && c.hp>=0 && hpRaw<c.hp
    ; Movement towards a distant monster is progress even if its HP is unreadable.
    distanceChangedV592 := c.distance-distanceNow>1

    if (hpChangedV592 || distanceChangedV592)
    {
        if (hpRaw>=0 && c.hp>=0 && hpRaw<c.hp)
            FarmStuckCombatProgressV247()
        c.x := x, c.y := y, c.hp := hpRaw, c.distance := distanceNow
        c.since := 0, c.queued := 0
        return true
    }

    if (hpRaw>=0 && c.hp<0)
    {
        c.hp := hpRaw, c.distance := distanceNow, c.since := 0, c.queued := 0
        return true
    }

    if (hpRaw>=0)
        c.hp := hpRaw

    ; V917: Farm monitors selected targets without requiring a successful
    ; attack packet. Other modes keep their original send-based threshold.
    farmSelectedV917 := farmWatchV1181 || (pid && FarmCenterPendingV741(pid))
    c.farmWatchV1181 := farmSelectedV917
    if (!c.since)
    {
        if (!farmSelectedV917)
            return true
        c.since := A_TickCount
    }
    if (c.queued<1 && !farmSelectedV917)
        return true
    ; 20261029 LOG FIX: packet=0 KHONG co nghia la danh bi ket.
    ; Khong khoa phong / bo qua UID khi CHUA QUEUE DUOC LENH DANH NAO.
    ; Luon giu lai muc tieu va thu gui lai; log tach loi GUI LENH voi loi DANH KHONG MAT MAU.
    if (farmSelectedV917 && c.queued<1)
    {
        if (chaseCheckSecV9>0 && A_TickCount-c.since>=Max(1,chaseCheckSecV9)*1000)
        {
            c.noSendRoundsV2026 := c.HasKey("noSendRoundsV2026") ? c.noSendRoundsV2026+1 : 1
            PortalLogWriteV66("FARM_COMBAT_NO_PACKET_RETRY uid=" . uid
                . " level=" . targetLevel . " distance=" . Round(distanceNow,2)
                . " packets=0 round=" . c.noSendRoundsV2026
                . " action=KEEP_TARGET_RETRY_SEND_NO_SKIP")
            if (c.noSendRoundsV2026=3)
                FonInfoPushV385("Chua gui duoc lenh danh UID " . uid
                    . ". Giu muc tieu va thu lai; kiem tra COMBAT_SEND_BLOCK trong log.")
            c.since := A_TickCount
        }
        return true
    }

    if (chaseCheckSecV9 > 0 && A_TickCount - c.since >= Max(1, chaseCheckSecV9) * 1000)
    {
        if (hpRaw < 0 || c.hp < 0 || hpRaw == c.hp)
        {
            bkRadius := Max(1, monsterRadiusV48)
            skipDistanceV752 := MonsterSkipDistanceGetV752(bkRadius)
            bkHalfSq := skipDistanceV752*skipDistanceV752
            isClose := distSq <= bkHalfSq
            ; Remember the stuck monster before clearing the combat target.
            stuckClsV1234 := (h && unit) ? D2ReadU32(h,unit+4) : -1
            FarmStuckSkipRememberV1234(uid,stuckClsV1234,distanceNow,pid)
            ; Mark the actual stuck target, not just the last packet UID.
            PortalLogWriteV66("FARM_COMBAT_STUCK_REAL uid=" . uid
                . " level=" . targetLevel . " distance=" . Round(distanceNow,2)
                . " timeout_sec=" . chaseCheckSecV9
                . " elapsed_ms=" . (A_TickCount-c.since)
                . " packets=" . c.queued . " farm_watch=" . c.farmWatchV1181
                . " hp_readable=" . (hpRaw>=0)
                . " action=" . (isClose ? "SKIP_UID" : "SKIP_ROOM_OR_UID")
                ,"FARM_COMBAT_STUCK_REAL_" . uid,1000)
            monsterProgressByUidV591.Delete(keyV591)
            monsterChaseV44 := false
            if (isClose)
            {
                MonsterStuckUidSkipV711(uid,targetLevel,pid)
                FonInfoPushV385("Bỏ qua quái UID " . uid . ": đánh không tiến triển sau "
                    . chaseCheckSecV9 . " giây (trong ngưỡng khóa quái); ưu tiên quái gần rồi tiếp tục lộ trình.")
                AutoMonsterAttackLogV2("TARGET_STUCK_NO_DAMAGE uid=" . uid . " time=" . chaseCheckSecV9
                    . "s hp_readable=" . (hpRaw>=0) . " dist_sq=" . Round(distSq,1) . " half_bk_sq=" . Round(bkHalfSq,1)
                    . " uid_locked=1 room_locked=0")
            }
            else
            {
                if (monsterCombatUidV45=uid)
                    monsterCombatUidV45 := 0,monsterRoadAreaV51 := false
                FarmAttackHoldReleaseV15()
                roomLockedV917 := MonsterStuckRoomAddV548(h,unit,uid,targetX,targetY,targetLevel,pid,x,y)
                ; If the remote monster room cannot be resolved, never leave
                ; the target eligible for immediate reselection.
                if (!roomLockedV917)
                    MonsterStuckUidSkipV711(uid,targetLevel,pid)
                FonInfoPushV385("Bỏ qua phòng chứa quái UID " . uid . ": đánh không tiến triển sau "
                    . chaseCheckSecV9 . " giây (ngoài ngưỡng khóa quái); ưu tiên phòng khác rồi tiếp tục lộ trình.")
                AutoMonsterAttackLogV2("TARGET_STUCK_NO_DAMAGE uid=" . uid . " time=" . chaseCheckSecV9
                    . "s hp_readable=" . (hpRaw>=0) . " dist_sq=" . Round(distSq,1) . " half_bk_sq=" . Round(bkHalfSq,1)
                    . " uid_locked=" . (!roomLockedV917) . " room_locked=" . roomLockedV917)
            }
            return false
        }
    }

    return true
}
MonsterClassExcludedV11(classId,h := 0,unit := 0)
{
    global monsterExcludeClassesV11
    for _,token in StrSplit(RegExReplace(monsterExcludeClassesV11,"[;\s]+",","),",")
    {
        if (RegExMatch(token,"^\d+$") && token+0=classId)
            return true
    }
    return h && unit ? MonsterKnownNonCombatV544(h,unit,classId) : false
}

MonsterNonCombatTablesV544(h)
{
    static cached := false, checked := 0
    pid := h ? DllCall("GetProcessId","Ptr",h,"UInt") : 0
    if (!pid)
        return false
    if (IsObject(cached) && cached.pid=pid && cached.handle=h && A_TickCount-checked<100)
        return cached.mon ? cached : false
    checked := A_TickCount,cached := {pid:pid,handle:h,mon:0}
    base := D2GetModuleBaseV35(pid,"D2Common.dll")
    if (!base || !MonsterBossProbeReadV1(h,base,0x40,dos) || NumGet(dos,0,"UShort")!=0x5A4D)
        return false
    pe := NumGet(dos,0x3C,"UInt")
    if (pe<0x40 || pe>0x1000 || !MonsterBossProbeReadV1(h,base+pe,0x60,header)
        || NumGet(header,0,"UInt")!=0x4550 || NumGet(header,4,"UShort")!=0x14C
        || NumGet(header,8,"UInt")!=0x4B95C439 || NumGet(header,0x50,"UInt")!=0xA9000)
        return false
    if (!MonsterBossProbeReadV1(h,base+0x99E1C,4,ptr))
        return false
    root := NumGet(ptr,0,"UInt")
    if (!MonsterBossProbeReadV1(h,root+0xA78,0x24,tables))
        return false
    mon := NumGet(tables,0,"UInt"),count := NumGet(tables,8,"UInt")
    if (mon<0x10000 || count<1 || count>65535 || mon+count*0x1A8>0xFFFFFFFF)
        return false
    cached := {pid:pid,handle:h,mon:mon,monCount:count
        ,extra:NumGet(tables,0x18,"UInt"),extraCount:NumGet(tables,0x20,"UInt")}
    return cached
}

MonsterKnownNonCombatV544(h,unit,classId)
{
    tables := MonsterNonCombatTablesV544(h)
    if (!IsObject(tables) || classId<0 || classId>=tables.monCount
        || !MonsterBossProbeReadV1(h,unit,0x18,ub)
        || NumGet(ub,0,"UInt")!=1 || NumGet(ub,4,"UInt")!=classId)
        return false
    row := tables.mon+classId*0x1A8,data := NumGet(ub,0x14,"UInt")
    if (!MonsterBossProbeReadV1(h,data,4,md) || NumGet(md,0,"UInt")!=row
        || !MonsterBossProbeReadV1(h,row,0x1A,record) || NumGet(record,0,"UShort")!=classId)
        return false
    flags := NumGet(record,0xC,"UInt")
    if (flags & 0x8000)
        return false
    if ((flags & 0x300)=0x300)
        return true
    extraId := NumGet(record,0x18,"UShort")
    if (tables.extra<0x10000 || tables.extraCount<1 || tables.extraCount>65535
        || extraId>=tables.extraCount || tables.extra+tables.extraCount*0x134>0xFFFFFFFF
        || !MonsterBossProbeReadV1(h,tables.extra+extraId*0x134,8,extra)
        || NumGet(extra,0,"UShort")!=extraId)
        return false
    flags2 := NumGet(extra,4,"UInt")
    return (flags2 & 0x22000)=0x22000 && !(flags2 & 8)
}

NativeExportTimerV12:
if (!ManualLogActiveV81())
{
    SetTimer, NativeExportTimerV12, Off
    return
}
if (!pickupCubeTraceUntil || A_TickCount>=pickupCubeTraceUntil)
{
    SetTimer, NativeExportTimerV12, Off
    return
}
if (!IsGameActive())
    return
SetTimer, NativeExportTimerV12, Off
NativeAttackDumpV8()
return

PetLearnNearestV12(fromGuiV137 := false)
{
    global monsterExcludeClassesV11, petLearnOnV12, petLearnDoneV12, petExcludeFileV12
    global petLearnEnabledV12
    if (!petLearnEnabledV12)
        return false
    pid := fromGuiV137 ? CoordDisplayGamePidV1() : D2GetActiveGamePidV95()
    base := pid ? D2GetModuleBaseV35(pid,"D2Client.dll") : 0
    h := base ? DllCall("OpenProcess","UInt",0x0410,"Int",0,"UInt",pid,"Ptr") : 0
    if (!h)
        return false
    try
    {
        player := D2ReadU32(h,base+0x11BBFC)
        path := player ? D2ReadU32(h,player+0x2C) : 0
        if (!MonsterBossProbeReadV1(h,path,0x20,pb))
            return false
        target := PetBossHoveredUnitV223(h,base,pid)
        if (!IsObject(target))
            return false
        if (!MonsterBossProbeReadV1(h,target.unit,0x30,ub) || NumGet(ub,0,"UInt")!=1
            || NumGet(ub,12,"UInt")!=target.uid || NumGet(ub,16,"UInt")=0 || NumGet(ub,16,"UInt")=12)
            return false
        if (!petLearnOnV12 || petLearnDoneV12 || (!fromGuiV137 && D2GetActiveGamePidV95()!=pid))
            return false
        classId := NumGet(ub,4,"UInt")
        petLearnDoneV12 := true
        if (MonsterClassExcludedV11(classId))
        {
            ToolTipInfoV386("Class ID " . classId . " đã có — không thêm, không tìm con khác.")
            SetTimer, RemoveToolTip, -3000
            return true
        }
        oldList := monsterExcludeClassesV11
        monsterExcludeClassesV11 .= (Trim(monsterExcludeClassesV11)="" ? "" : ",") . classId
        if (!PetExcludeSaveV12())
        {
            monsterExcludeClassesV11 := oldList
            return false
        }
        PetExcludeRefreshV16()
        ToolTipInfoV386("Đã thêm đúng 1 Class ID: " . classId . " (con đang dưới chuột).")
        SetTimer, RemoveToolTip, -3000
        return true
    }
    finally
        DllCall("CloseHandle","Ptr",h)
}

PetExcludeLoadV12()
{
    global petExcludeFileV12, monsterExcludeClassesV11
    monsterExcludeClassesV11 := ""
    if (FileExist(petExcludeFileV12))
    {
        FileRead, content, %petExcludeFileV12%
        if (!ErrorLevel)
            monsterExcludeClassesV11 := RegExReplace(Trim(content," `t`r`n"),"\s+",",")
    }
    PetExcludeRefreshV16()
}

PetExcludeSaveV12()
{
    global petExcludeFileV12, monsterExcludeClassesV11
    content := "", seen := {}, normalized := ""
    for _,token in StrSplit(RegExReplace(monsterExcludeClassesV11,"[;\s]+",","),",")
    {
        if (!RegExMatch(token,"^\d+$"))
            continue
        id := token+0
        if (seen.HasKey(id))
            continue
        seen[id] := true
        content .= id . "`r`n"
        normalized .= (normalized="" ? "" : ",") . id
    }
    tmp := petExcludeFileV12 . ".tmp"
    file := FileOpen(tmp,"w","UTF-8-RAW")
    if (!IsObject(file))
        return false
    written := file.Write(content)
    file.Close()
    if (content!="" && written=0)
        return false
    try FileMove, %tmp%, %petExcludeFileV12%, 1
    if (ErrorLevel)
        return false
    monsterExcludeClassesV11 := normalized
    return true
}

FarmHotkeyForegroundV154(hotkeyName := "")
{
    global autoMonsterAttackOn,backgroundHwndV63
    if (autoMonsterAttackOn)
        return backgroundHwndV63 && WinActive("ahk_id " . backgroundHwndV63) && IsGameForegroundV63()
    return (WinActive("ahk_exe Game.exe") || WinActive("ahk_exe Diablo II.exe")
        || WinActive("ahk_exe D2.exe")) && IsGameForegroundV63()
}

AutoMonsterToggleKeyHandlerV13:
if (FarmControlRunningV186() && !IsObject(farmMapPauseV52) && farmControlOwnerV186!="SCOS")
    return
if (!FarmControlRunningV186())
    farmControlOwnerV186 := "SCOS"
MapKeyTraceV174(autoMonsterToggleKeyV13,"L_HANDLER_ENTER hotkey=" . A_ThisHotkey)
foregroundFarmKeyV82 := DllCall("GetForegroundWindow","Ptr")
WinGet, foregroundFarmPidV124, PID, ahk_id %foregroundFarmKeyV82%
if (!FarmHotkeyForegroundV154() || (autoMonsterAttackOn && foregroundFarmPidV124!=backgroundPidV63))
{
    AutoMonsterAttackLogV2("FARM_KEY_REJECT key=" . autoMonsterToggleKeyV13 . " reason=FOREGROUND_GAME_PID",true)
    return
}
if (farmKeyHeldV124)
    return
farmKeyHeldV124 := true
SetTimer, FarmKeyReleaseTimerV124, 30
AutoMonsterAttackLogV2("FARM_KEY_RECEIVED key=" . autoMonsterToggleKeyV13 . " before=" . autoMonsterAttackOn,true)
Gosub, MapControlActionV168
return

FarmStartLevelReadyV757(owner,level,mode)
{
    return level>0 && mode>0 && mode!=17 && !FarmReviveTownLevelV295(level)
        && FarmStartMapStageV737(owner,level)=2
}

FarmStartInFarmV757(pid)
{
    global farmControlOwnerV186
    base := pid ? D2GetModuleBaseV35(pid,"D2Client.dll") : 0
    h := base ? D2OpenProcess(pid) : 0
    if (!h)
        return false
    try
    {
        player := D2ReadU32(h,base+0x11BBFC)
        if (!player || !MonsterBossProbeReadV1(h,player+0x10,4,modeBytes))
            return false
        mode := NumGet(modeBytes,0,"UInt"),path := D2ReadU32(h,player+0x2C)
        if (!MonsterBossProbeReadV1(h,path,0x20,pb))
            return false
        level := CoordLevelV14(h,NumGet(pb,0x1C,"UInt"))
        owner := farmControlOwnerV186!="" ? farmControlOwnerV186 : "SCOS"
        return FarmStartLevelReadyV757(owner,level,mode)
    }
    finally
        DllCall("CloseHandle","Ptr",h)
}

FarmStartClearReviveBuffV757(level,mode,pid)
{
    global farmControlOwnerV186,reviveBuffPendingV34,entryBuffPendingV20
    global farmReviveV32,farmDeadStartV695
    if (!reviveBuffPendingV34 || IsObject(farmReviveV32) || IsObject(farmDeadStartV695))
        return false
    owner := farmControlOwnerV186!="" ? farmControlOwnerV186 : "SCOS"
    if (!FarmStartLevelReadyV757(owner,level,mode))
        return false
    reviveBuffPendingV34 := false,entryBuffPendingV20 := false
    PortalLogWriteV66("START_IN_FARM_BUFF_CLEAR level=" . level . " pid=" . pid . " next=KEEP_YELLOW_ROUTE")
    return true
}

FarmStartMapStageV737(mapName,level)
{
    global currentProfile
    if (level<=0)
        return 0
    plan := FarmMapPlanV10(mapName,level)
    if (IsObject(plan))
        return plan.final ? 2 : 1
    if (mapName="SCOS")
        return level=270 ? 2 : (level=109 || level=241) ? 1 : 0
    if (mapName="CAIN")
        return (level=183 || level=184 || level=185) ? 2 : 0
    if (mapName="NAO")
        return level=109 ? 1 : (!FarmReviveTownLevelV295(level) && level=NaoFarmLevelV312(level)) ? 2 : 0
    if (mapName="LIB")
        return level=103 ? 1 : (level>=263 && level<=266) ? 2 : 0
    if (mapName="BO")
    {
        if (FarmReviveTownLevelV295(level))
            return 1
        section := ProfileSection(currentProfile)
        IniRead, firstFarm, % ProfileConfigPathV364(section), %section%, BOFarmLevel2, 0
        IniRead, finalFarm, % ProfileConfigPathV364(section), %section%, BOFarmLevel4, 0
        return (firstFarm && level=firstFarm) || (finalFarm && level=finalFarm) ? 2 : 1
    }
    return 0
}

MapRunResumePrepareV210(mapName)
{
    global coordSavedV15,coordManualRowV59,coordPinnedYellowV136,autoMapTrackingV10
    global routeMapIdV21,backgroundPidV63,townLevelV22,mapWorkflowV185
    global mapRunResumeV210
    global coordRunSelectedV210,libRunChoiceV281,coordYellowRowV350
    mapRunResumeV210 := false
    level := FarmCurrentLevelV143()
    if (FarmStartMapStageV737(mapName,level)!=2)
        return 0
    if (MapScrollFarmV269(mapName) && IsObject(libRunChoiceV281) && libRunChoiceV281.mapId=routeMapIdV21)
        coordRunSelectedV210 := libRunChoiceV281
    oldMap := routeMapIdV21
    selected := FarmStartRowV394()
    oldPoint := selected>=1 && selected<=coordSavedV15.Length() ? coordSavedV15[selected] : false
    if (IsObject(coordRunSelectedV210) && coordRunSelectedV210.mapId=oldMap)
        selected := coordRunSelectedV210.row,oldPoint := coordRunSelectedV210
    requestedYellowV367 := coordYellowRowV350
    requestedMapV367 := routeMapIdV21
    CoordRouteResetV16()
    coordRunSelectedV210 := false
    if (!Stage2MapRequestV381(true))
        return -1
    if (!level && coordSavedV15.Length())
        level := coordSavedV15[1].level
    pid := backgroundPidV63,base := D2GetModuleBaseV35(pid,"D2Client.dll")
    h := base ? D2OpenProcess(pid) : 0
    if (!h)
        return -1
    try
    {
        player := D2ReadU32(h,base+0x11BBFC),path := player ? D2ReadU32(h,player+0x2C) : 0
        if (!MonsterBossProbeReadV1(h,path,0x20,pb)
            || CoordLevelV14(h,NumGet(pb,0x1C,"UInt"))!=level)
            return -1
        row := 0
        row := FarmStartRowV394()
        if (row && coordSavedV15[row].level!=level)
            row := 0
        if (!row)
            return 0
        mapWorkflowV185 := {map:mapName,stage:2,startLevel:109,testRows:0,resumeMapIdV210:routeMapIdV21}
        MapStageSetV185(2)
        point := coordSavedV15[row]
        mapRunResumeV210 := {row:row,mapId:routeMapIdV21,pid:pid,x:point.x,y:point.y,level:level}
        coordRunSelectedV210 := false
        PortalLogWriteV66("RUN_RESET_FROM_YELLOW row=" . row . " map=" . routeMapIdV21 . " level=" . level . " route=RELOADED")
        return 1
    }
    finally
        DllCall("CloseHandle","Ptr",h)
}

FarmRuntimeResetV535(reason)
{
    global
    local timer
    farmUserPausedV2026 := false,farmPauseTickV2026 := 0

    PickupFarmResetV762()
    sigTerminalErrorV762 := ""
    monsterProgressByUidV591 := {}
    farmItemLockV625 := false
    farmFightLockV626 := false
    farmSkillPairV620 := false
    farmRunEpochV535++
    farmPickupTimedSkippedV1602 := {}
    farmCenterCycleV741 := false
    SetTimer, FarmPickupHandoffTimerV901, Off
    farmDeadStartV695 := false
    farmStartRetryV237 := false,stage2StartPendingV381 := false
    farmStage3PendingV237 := false,sigFarmResumePendingV237 := false,farmRestartReasonV238 := ""
    mapFarmStartPendingV170 := false,mapStage1BuffDoneV248 := false
    for _,timer in ["Stage2StartWaitTimerV381","FarmStage3RetryTimerV237","SigFarmResumeV152"
        ,"MapFarmStartV170","FarmStopMoveTimerV124"]
        SetTimer, %timer%, Off
    farmStopMoveV124 := false,farmMapPauseV52 := false,cainPausedV10 := false
    cainNoFightV361 := false,cainPauseFarmV361 := false,cainAttachRetryAtV379 := 0
    farmResumeArmedV70 := false,farmResumeOutsideV70 := false
    farmReviveV32 := false,reviveBuffPendingV34 := false
    entryBuffPendingV20 := false,pestiPointPendingV28 := false,lastAttackPendingV20 := false
    portalBuffV85 := false,portalExitPendingV69 := false,portalBackPendingV74 := false
    coordCastCountV50 := 0,coordCastLastRowV50 := 0,coordCastPendingV50 := false
    coordMoveDoneV14 := false,coordMoveTriesV14 := 0,coordNoTargetSinceV14 := 0
    monsterCombatUidV45 := 0,monsterChaseV44 := false,monsterRoadAreaV51 := false
    combatRecoverV48 := false,combatMildRecoverV299 := false
    farmPickupGuardV4 := false,pickupFarmWorkV75 := false
    farmPickupBlockedV57 := false,farmPickupAllowedV57 := true
    farmCubeSortOnceV253 := false,farmStage2DoneV372 := false,mapLoadFailureV402 := false
    farmLoadedMapV56 := false,stage2FlowV380 := false,stage2MapFileV14 := false
    coordRouteV16 := false,mapRunResumeV210 := false,coordRunSelectedV210 := false
	FarmStuckInfoDisableV10(true)
    MovementCtrlSetV78(false,0,reason)
    PortalLogWriteV66("FARM_RUNTIME_RESET reason=" . reason . " epoch=" . farmRunEpochV535
        . " route=RELOAD_ON_START yellow=KEPT live_action_locks=OWNED_BY_HANDLER")
}

FarmStartPrepareV2(reuse := false)
{
    global farmManualStoppedV2026
    farmManualStoppedV2026 := false
    global farmStartChoiceV2,currentProfile,routeMapIdV21,coordSavedV15,farmRunEpochV535
    global coordTrackingEnabledV409, autoMapTrackingV10
    FarmElapsedStartV1350()
    
    if (!coordTrackingEnabledV409) 
    {
        if (FonTrackingEnableV410())
            PortalLogWriteV66("FARM_START_AUTO_FON next=BAT_TU_DONG")
        else
            PortalLogWriteV66("FARM_START_AUTO_FON_FAIL next=BI_CHAN_BOI_EDIT")
    } 
    else 
    {
        SetTimer, CoordCurrentTimerV15, 250
    }

    FarmSkillBaselineEnsureV621(CoordDisplayGamePidV1())
    FarmRuntimeResetV535("MANUAL_START")
    FarmStartRouteDiscardV698(true)
    FarmBuffStartV509()
    FarmWatchStartV5()
    fresh := FonEnsureLiveV410(CoordDisplayGamePidV1())
    row := fresh ? FarmStartRowV394() : 0
    point := row ? coordSavedV15[row] : false
    farmStartChoiceV2 := {pid:CoordDisplayGamePidV1(),epoch:farmRunEpochV535,profile:currentProfile,mapId:routeMapIdV21
        ,reloadPending:true,freshV698:fresh}
    if (IsObject(point))
        farmStartChoiceV2.row := row,farmStartChoiceV2.level := point.level
            ,farmStartChoiceV2.x := point.x,farmStartChoiceV2.y := point.y
}
FarmStartRouteDiscardV698(stopTracking := false)
{
    global
    coordRouteV16 := false,stage2MapFileV14 := false,stage2FlowV380 := false
    farmLoadedMapV56 := false,farmStage2DoneV372 := false
    farmStartChoiceV2 := false,mapRunResumeV210 := false,coordRunSelectedV210 := false,libRunChoiceV281 := false
    farmStopMoveV124 := false,coordMoveDoneV14 := false,coordMoveTriesV14 := 0
    SetTimer, FarmStopMoveTimerV124, Off
}

FarmStartPortalOriginV699(level)
{
    global farmControlOwnerV186
    return FarmRevivePortalSourceV746(level)
}


FarmStartStateV698(pid)
{
    global farmReviveV32,farmControlOwnerV186
    base := pid ? D2GetModuleBaseV35(pid,"D2Client.dll") : 0
    h := base ? D2OpenProcess(pid) : 0
    if (!h)
        return false
    try
    {
        player := D2ReadU32(h,base+0x11BBFC)
        if (!player || !MonsterBossProbeReadV1(h,player+0x10,4,modeBytes))
            return false
        mode := NumGet(modeBytes,0,"UInt")
        if (mode=0 || mode=17)
            return {dead:true,town:false,portal:false}
        ; START khong can doc cong / danh gia thanh khi nhan vat con song.
        ; Chuyen ngay sang nap INI cua map hien tai + dong vang.
        return {dead:false,town:false,portal:false}
    }
    finally
        DllCall("CloseHandle","Ptr",h)
}

FarmDeadStartBeginV695()
{
    global
    local live
    live := FarmStartStateV698(backgroundPidV63)
    if (!IsObject(live))
    {
        FarmStartKeepV697("WAIT_LIVE_PLAYER")
        return true
    }
    ; START chay truc tiep tu dong vang khi con song, khong uu tien cong chi vi dang o thanh.
    ; Neu nhan vat chet thi van chuyen qua duy nhat luong hoi sinh.
    if (!live.dead)
        return false
    FarmRuntimeResetV535("START_REVIVE_OR_TOWN_PORTAL")
    FarmStartRouteDiscardV698(true)
    farmDeadStartV695 := {pid:backgroundPidV63,hwnd:backgroundHwndV63,epoch:farmRunEpochV535}
    farmReviveV32 := {pid:backgroundPidV63,esc:false,step:0,last:0,origin:false
        ,seen:{},townBuffDone:false,deathSeenV296:live.dead,startPortalOriginV699:live.level}
    reviveBuffPendingV34 := false
    autoMonsterAttackOn := true
    SetTimer, AutoMonsterAttackTimer, 250
    Gosub, MapControlButtonStatusV171
    FonInfoPushV385(live.dead ? "[START] Hồi sinh trước; sau đó kiểm tra cổng trong thành."
        : "[START] Hoi sinh truoc khi nap map va chay tu dong vang.")
    return true
}

; START preflight also uses AutoMonsterAttackTimer, not a second revive timer.
FarmDeadStartTickV695()
{
global
if (farmUserPausedV2026)
    return
if (farmManualStoppedV2026)
{
    farmDeadStartV695 := false
    SetTimer, AutoMonsterAttackTimer, Off
    return
}
if (farmDeadStartBusyV695)
    return
farmDeadStartBusyV695 := true
try
{
    deadStartV695 := farmDeadStartV695
    if (!IsObject(deadStartV695) || !autoMonsterAttackOn
        || deadStartV695.epoch!=farmRunEpochV535)
    {
        farmDeadStartV695 := false
        SetTimer, AutoMonsterAttackTimer, Off
        return
    }
    if (!BackgroundValidV63() || backgroundPidV63!=deadStartV695.pid
        || backgroundHwndV63!=deadStartV695.hwnd || !IsGameActive())
        return
    deadBaseV695 := D2GetModuleBaseV35(deadStartV695.pid,"D2Client.dll")
    deadHV695 := deadBaseV695 ? D2OpenProcess(deadStartV695.pid) : 0
    if (!deadHV695)
        return
    try
    {
        deadPlayerV695 := D2ReadU32(deadHV695,deadBaseV695+0x11BBFC)
        if (!deadPlayerV695 || !MonsterBossProbeReadV1(deadHV695,deadPlayerV695+0x10,4,deadModeBytesV698))
            return
        deadModeV695 := NumGet(deadModeBytesV698,0,"UInt")
        deadPathV695 := D2ReadU32(deadHV695,deadPlayerV695+0x2C)
        if (deadModeV695=0 || deadModeV695=17)
        {
            VarSetCapacity(deadPBV695,0x20,0)
            FarmReviveTickV32(deadHV695,deadPlayerV695,deadPBV695,deadStartV695.pid
                ,deadStartV695.hwnd,deadBaseV695,deadPathV695,deadModeV695)
            return
        }
        if (!MonsterBossProbeReadV1(deadHV695,deadPathV695,0x20,deadPBV695))
            return
        FarmReviveTickV32(deadHV695,deadPlayerV695,deadPBV695,deadStartV695.pid
            ,deadStartV695.hwnd,deadBaseV695,deadPathV695,deadModeV695)
        return
    }
    finally
        DllCall("CloseHandle","Ptr",deadHV695)
}
finally
    farmDeadStartBusyV695 := false
}

FarmRoutePointsV724()
{
    global scosEntryV162,coordSavedV15
    c := IsObject(scosEntryV162) ? scosEntryV162.commonRouteV3 : false
    return IsObject(c) && IsObject(c.pointsV724) ? c.pointsV724 : coordSavedV15
}

CoordAdjacentRowV724(points,current,x,y,level)
{
    if (!IsObject(points) || !points.Length())
        return 0
    valid := current>=1 && current<=points.Length() && points[current].level=level
    first := valid ? Max(1,current-1) : 1,last := valid ? Min(points.Length(),current+1) : points.Length()
    best := valid ? current : 0
    bestSq := valid ? (x-points[current].x)**2+(y-points[current].y)**2 : 1.0e30
    Loop, % last-first+1
    {
        row := first+A_Index-1,p := points[row]
        if (p.level!=level)
            continue
        d := (x-p.x)**2+(y-p.y)**2
        if (d<bestSq)
            best := row,bestSq := d
    }
    return best
}

FarmStartApplyYellowV2()
{
    global farmStartChoiceV2,currentProfile,routeMapIdV21,coordSavedV15,farmRunEpochV535
    global coordYellowRowV350,coordPinnedYellowV136,coordLiveYellowV128,coordManualRowV59,coordNearbyRowV18
    c := farmStartChoiceV2,pid := CoordDisplayGamePidV1()
    if (!IsObject(c) || c.pid!=pid || c.epoch!=farmRunEpochV535 || c.profile!=currentProfile
        || c.mapId!=routeMapIdV21 || !c.row || RoomRecordLevelV259(pid)!=c.level)
        return false
    row := c.row,point := coordSavedV15[row]
    if (!IsObject(point) || point.x!=c.x || point.y!=c.y || point.level!=c.level)
        return false
    coordYellowRowV350 := row,coordPinnedYellowV136 := row,coordLiveYellowV128 := row
    coordManualRowV59 := row,coordNearbyRowV18 := row
    return true
}

FarmGoFullStopV2()
{
    global farmManualStoppedV2026,farmUserPausedV2026,farmPauseTickV2026
    farmUserPausedV2026 := false,farmPauseTickV2026 := 0
    farmManualStoppedV2026 := true
    stopPidV500 := CoordDisplayGamePidV1()
    if (stopPidV500)
        FarmSkillBaselineEnsureV621(stopPidV500,true)
    FarmWatchStopV5()
    CainAllStopV387(false)
    CoordBoxRefreshV15(true)
    ToolTip,,,,20
    Gosub, MapControlButtonStatusV171
    FonInfoPushV385("STOP cạnh Go: dừng Farm, chuyển nhặt thường, bật F-OFF.")
}

; V2026 - Farm START button: Start -> Pause -> Tiep. STOP remains a full reset.
FarmUserPauseToggleV2026(owner)
{
    global farmUserPausedV2026,farmPauseTickV2026,farmControlOwnerV186,farmManualStoppedV2026
    global scosEntryV162,stageTwoV166,coordRouteV16,farmCenterCycleV741
    global mapWorkflowV185,mapButtonStartV172,farmDeadStartV695,mapStage1BuffDoneV248
    global farmReviveV32,farmWatchV5,farmErrorRetryAtV740,farmLastCombatTickV72
    global farmMapJournalRunV940
    if (farmControlOwnerV186!=owner || (!FarmControlRunningV186() && !farmUserPausedV2026))
        return false
    if (!farmUserPausedV2026)
    {
        farmUserPausedV2026 := true
        farmPauseTickV2026 := A_TickCount
        FarmAttackHoldReleaseV15()
        MovementCtrlSetV78(false,0,"FARM_PAUSE")
        PortalLogWriteV66("FARM_PAUSE owner=" . owner . " state=PRESERVED")
        FonInfoPushV385("[PAUSE] " . owner . " — giu trang thai, bam nut lan nua de chay tiep.")
    }
    else
    {
        gapV2026 := Max(0,A_TickCount-farmPauseTickV2026)
        for _,stateV2026 in [scosEntryV162,stageTwoV166,coordRouteV16,farmCenterCycleV741
            ,mapWorkflowV185,mapButtonStartV172,farmDeadStartV695,mapStage1BuffDoneV248,farmReviveV32]
            FarmUserPauseShiftV2026(stateV2026,gapV2026)
        if (farmErrorRetryAtV740>10000000)
            farmErrorRetryAtV740 += gapV2026
        if (farmLastCombatTickV72>10000000)
            farmLastCombatTickV72 += gapV2026
        if (IsObject(farmWatchV5))
        {
            farmWatchV5.idleAtV650 := FarmWatchNowV688()
            farmWatchV5.standSampleV650 := false
        }
        farmUserPausedV2026 := false,farmPauseTickV2026 := 0
        farmManualStoppedV2026 := false
        PortalLogWriteV66("FARM_CONTINUE owner=" . owner . " pause_ms=" . gapV2026 . " state=PRESERVED")
        FonInfoPushV385("[TIEP] " . owner . " — chay tiep trang thai cu.")
    }
    Gosub, MapControlButtonStatusV171
    return true
}

FarmUserPauseShiftV2026(state,elapsed)
{
    if (!IsObject(state) || elapsed<=0)
        return
    for name,value in state
    {
        if (IsObject(value))
            continue
        if (!RegExMatch(name,"i)(until|tick|time|since|start|last|retry|next|deadline|stamp|at$)"))
            continue
        if (RegExMatch(value . "","^\d+$") && value>10000000 && value<A_TickCount+604800000)
            state[name] := value+elapsed
    }
}

FarmButtonStopV1()
{
    global farmControlOwnerV186,farmGD2TestV644,farmManualStoppedV2026,farmUserPausedV2026,farmPauseTickV2026
    farmUserPausedV2026 := false,farmPauseTickV2026 := 0
    farmManualStoppedV2026 := true
    FarmElapsedStopV1350()
    owner := IsObject(farmGD2TestV644) ? farmGD2TestV644.previousOwner : farmControlOwnerV186
    FarmWatchStopV5()
    CainAllStopV387(false)
    farmControlOwnerV186 := owner
    CoordBoxRefreshV15(true)
    Gosub, MapControlButtonStatusV171
    FonInfoPushV385("Đã dừng Farm; chuyển nhặt thường, bật F-OFF.")
    return true
}


MapControlActionV168:
if (FarmControlRunningV186() || IsObject(farmMapPauseV52) || cainPausedV10)
{
    FarmButtonStopV1()
    return
}
farmManualStoppedV2026 := false ; explicit START, including GO / hotkey
if (FarmStartForcedV702(farmControlOwnerV186!="" ? farmControlOwnerV186 : "SCOS"))
    return
if (SigBackgroundBindV179() && FarmDeadStartBeginV695())
    return
if (FarmStartHealthV536(farmControlOwnerV186!="" ? farmControlOwnerV186 : "SCOS"))
{
    if (!FarmControlRunningV186())
        FarmStartKeepV697("GAME_HEALTH_WAIT")
    return
}
if (!BackgroundBindV63(mapControlGuiStartV180 ? backgroundHwndV63 : 0))
{
    RecoveryStartMissingGameV492(farmControlOwnerV186!="" ? farmControlOwnerV186 : "SCOS")
    if (!FarmControlRunningV186())
        FarmStartKeepV697("GAME_BIND_NOT_READY")
    return
}
; START chung V2026: khong khoa vao thanh / level cua nut.
; Nap file INI cho map nhan vat DANG DUNG, giu dong vang neu cung map da chon.
startMapOwnerV737 := farmControlOwnerV186!="" ? farmControlOwnerV186 : "SCOS"
startMapPidV2026 := CoordDisplayGamePidV1()
startMapLevelV737 := FarmCurrentLevelV143()
if (!startMapPidV2026 || !startMapLevelV737)
{
    FonInfoPushV385("[START] Chua doc duoc nhan vat/map; khong the chay toa do.")
    return
}
if (!FonTrackingEnableV410())
{
    FonInfoPushV385("[START] F-ON dang bi khoa do sua toa do; vui long ket thuc sua.")
    return
}
if (!FonLoadMapV382("START_YELLOW",startMapPidV2026,startMapLevelV737))
{
    FonInfoPushV385("[START] Map " . startMapLevelV737 . " chua co INI phu hop; chua bat Farm.")
    PortalLogWriteV66("START_YELLOW_ABORT level=" . startMapLevelV737 . " reason=MAP_FILE_NOT_READY")
    return
}
if (!IsObject(coordSavedV15) || !coordSavedV15.Length() || coordSavedV15[1].level!=startMapLevelV737)
{
    FonInfoPushV385("[START] File toa do khong trung map dang dung; chua bat Farm.")
    return
}
startYellowRowV2026 := FarmStartRowV394()
FarmStartPrepareV2(mapControlGuiStartV180)
if (!pickupImageOn)
    PickupEnabledSetV71(true,false,false)
mapWorkflowV185 := {map:startMapOwnerV737,stage:2,startLevel:startMapLevelV737,testRows:0}
autoMonsterAttackOn := true
MapStageSetV185(2)
PortalLogWriteV66("START_YELLOW_DIRECT owner=" . startMapOwnerV737 . " level=" . startMapLevelV737
    . " row=" . startYellowRowV2026 . " mapId=" . routeMapIdV21 . " town_gate=NONE stage1=SKIPPED")
FonInfoPushV385("[START] Nap map " . startMapLevelV737 . ", Farm tu dong vang " . startYellowRowV2026)
Gosub, AutoMonsterAttackToggle
return

FarmKeyReleaseTimerV124:
farmPhysicalKeyV124 := RegExReplace(autoMonsterToggleKeyV13,"^[~*$<>!^+#]+")
if (farmPhysicalKeyV124="" || !GetKeyState(farmPhysicalKeyV124,"P"))
{
    farmKeyHeldV124 := false
    SetTimer, FarmKeyReleaseTimerV124, Off
}
return

