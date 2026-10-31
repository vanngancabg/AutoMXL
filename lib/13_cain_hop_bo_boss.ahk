; ==============================================================================
; FILE: 13_cain_hop_bo_boss.ahk (Dòng 42192 -> 47406 trong Gốc.ahk)
; CHỨC NĂNG: Logic chuyên biệt cho map CAIN, HOP, BO & Tìm Boss
; ==============================================================================
CainButtonActionV387()
{
    global scosEntryV162,coordSavedV15,backgroundPidV63,farmControlOwnerV186
    global clickCastOn,cycleOn,cainPausedV10,autoMapTrackingV10,mapLoadFailureV402
    if (farmControlOwnerV186="CAIN" && (FarmControlRunningV186() || cainPausedV10 || farmUserPausedV2026))
        return FarmUserPauseToggleV2026("CAIN")
    if (FarmControlRunningV186())
        return false
    farmControlOwnerV186 := "CAIN"
    if (FarmStartForcedV702("CAIN"))
        return true
    if (SigBackgroundBindV179() && FarmDeadStartBeginV695())
        return true
    if (FarmStartHealthV536("CAIN"))
    {
        if (!FarmControlRunningV186())
        {
            farmControlOwnerV186 := "CAIN"
            FarmStartKeepV697("GAME_HEALTH_WAIT")
        }
        return true
    }
    startLevelV737 := FarmCurrentLevelV143()
    if (startLevelV737 && !FarmStartMapStageV737("CAIN",startLevelV737))
    {
        ToolTipInfoV386("CAIN: map " . startLevelV737 . " không thuộc lộ trình của nút này.")
        SetTimer, RemoveToolTip, -3500
        return true
    }
    FarmStartPrepareV2()
    mapLoadFailureV402 := false
    if (!CainCaveMapV502(FarmCurrentLevelV143()))
    {
        if (IsObject(mapLoadFailureV402) && !FarmReviveTownLevelV295(FarmCurrentLevelV143()))
        {
            farmControlOwnerV186 := "CAIN"
            FarmStartKeepV697("CAIN_MAP_LOAD_WAIT")
            return true
        }
    }
    r := scosEntryV162
    if (!IsObject(r) && FarmControlRunningV186() && farmControlOwnerV186="CAIN")
    {
        CainStage2AttachV379()
        return true
    }
    if ((IsObject(r) && r.map="CAIN")
        || (FarmControlRunningV186() && farmControlOwnerV186="CAIN"))
    {
        CainPauseToggleV10(r)
        return true
    }
    level := FarmCurrentLevelV143()
    if (!FarmControlRunningV186() && FarmStartMapStageV737("CAIN",level)=2)
    {
        farmControlOwnerV186 := "CAIN"
        r := {map:"CAIN",pid:backgroundPidV63,until:A_TickCount+600000,phase:"MAP"
            ,row:1,last:0,pickup:false,startLevel:40,cainActiveV368:true
            ,cainLevelV19:level
            ,cainPhaseV383:"WAIT",cainPhaseV361:level=185 ? "RUN_GD4" : (level=184 ? "RUN_GD3" : "RUN_GD2")}
        r.cainSavedClickV387 := clickCastOn,r.cainSavedCycleV387 := cycleOn
        scosEntryV162 := r
        if (!CainStartLoadedV387(r))
        {
            scosEntryV162 := false
            FarmStartKeepV697("CAIN_ROUTE_LOAD_WAIT")
        }
        return true
    }
    return false
}

CainRouteReloadFromYellowV15(r)
{
    global coordCursorSnapshotV390,stage2MapFileV14
    if (!IsObject(r) || !r.pid)
        return false
    levelV506 := RoomRecordLevelV259(r.pid)
    if (r.map="CAIN" && CainCaveMapV502(levelV506))
        return IsObject(MapLiveIdentityV399(r.pid,levelV506))
    liveV15 := coordCursorSnapshotV390
    if (!IsObject(liveV15) || liveV15.pid!=r.pid || !liveV15.level)
        return false
    if (!Stage2MapWaitV381(r.pid,liveV15.level,true))
        return false
    PortalLogWriteV66("CAIN_MANUAL_ROUTE_NEW level=" . liveV15.level
        . " yellow=" . FarmStartRowV394() . " source=FON_LIVE")
    return true
}

CainPauseToggleV10(r)
{
    return FarmUserPauseToggleV2026("CAIN")
}

CainStartLoadedV387(r)
{
    global
    local row,level
    Critical, On
    if (!CainRouteReloadFromYellowV15(r))
    {
        Critical, Off
        return false
    }
    level := FarmCurrentLevelV143()
    if (CainCaveMapV502(level))
    {
        r.cainCaveV502 := false,r.cainPhaseV383 := "CAVE_MOVE",r.cainResumeStartV387 := false
        CainModeApplyV16(r,true,false)
        autoMonsterAttackOn := false,farmStopMoveV124 := false,coordGoV59 := false
        SetTimer, FarmStopMoveTimerV124, Off
        SetTimer, CoordGoTimerV59, Off
        SetTimer, AutoMonsterAttackTimer, Off
        SetTimer, CainResumeBuffTimerV387, Off
        SetTimer, ScosEntryTimerV162, 250
        Critical, Off
        FonInfoPushV385("[CAIN] Map " . level . ": chỉ lấy vị trí cổng/hang, di chuyển lần vách; không đánh/nhặt")
        return true
    }
    FarmStartApplyYellowV2()
    row := FarmStartRowV394()
    farmStartChoiceV2 := false
    if (!row)
    {
        Critical, Off
        return
    }
    level := coordSavedV15[row].level
    r.cainResumeStartV387 := true
    r.stage1BuffDoneV368 := false
    r.stage1PhaseV368 := r.phase
    cainPauseFarmV361 := false
    autoMonsterAttackOn := false
    farmMapPauseV52 := false
    farmStopMoveV124 := false,coordGoV59 := false
    SetTimer, FarmStopMoveTimerV124, Off
    SetTimer, CoordGoTimerV59, Off
    SetTimer, CoordGoInputTimerV139, Off
    CoordRouteResetV16()
    coordRouteV16.pid := r.pid,coordRouteV16.startLevel := level
    coordRouteV16.resumeRowV210 := row,coordRouteV16.startAtYellowV367 := true
    coordRouteV16.yellow := row
    farmStage2DoneV372 := false
    coordMoveDoneV14 := false,coordMoveTriesV14 := 0
    coordCastCountV50 := 0,coordCastLastRowV50 := 0
    coordCastPendingV50 := false,pestiPointPendingV28 := false,lastAttackPendingV20 := false
    reviveBuffPendingV34 := false,portalBuffV85 := false
    portalExitPendingV69 := false,portalBackPendingV74 := false
    deathlordRetryAtV31 := 0
    if (r.cainActiveV368)
    {
        r.cainPhaseV383 := "RUN"
        r.cainExitWaitV383 := 0,r.cainMoveAtV383 := 0,r.cainInteractAtV383 := 0
        CainModeApplyV16(r,true,false)
        r.cainModeV383 := Stage2FlowModeV380()
    }
    SetTimer, ScosEntryTimerV162, Off
    SetTimer, AutoMonsterAttackTimer, Off
    SetTimer, CainResumeBuffTimerV387, 50
    Critical, Off
    FonInfoPushV385("[CAIN START] Nạp mới file, dòng vàng " . row . " -> buff -> chạy/đánh/nhặt theo giai đoạn")
    return true
}

CainResumeBuffTimerV387:
if (farmUserPausedV2026)
    return
if (farmManualStoppedV2026)
{
    SetTimer, CainResumeBuffTimerV387, Off
    return
}
CainResumeBuffTickV387()
return

CainResumeBuffTickV387()
{
    global
    local r,h,base,player,ctx
    static busy := false
    r := scosEntryV162
    if (!IsObject(r) || r.map!="CAIN" || !r.cainResumeStartV387)
    {
        SetTimer, CainResumeBuffTimerV387, Off
        return
    }
    if (busy)
        return
    busy := true,h := 0
    try
    {
        if (!FonEnsureLiveV410(r.pid))
            return
        base := D2GetModuleBaseV35(r.pid,"D2Client.dll")
        h := base ? D2OpenProcess(r.pid) : 0
        player := h ? D2ReadU32(h,base+0x11BBFC) : 0
        if (!player)
            return
        ctx := {pid:r.pid,h:h,scosEntry:true,entryStateV42:r}
        if (!MapStage1BuffFirstV368(r,ctx,player))
            return
        if (scosEntryV162!=r || !r.cainResumeStartV387)
            return
        r.cainResumeStartV387 := false
        farmPickupBlockedV57 := false
        clickCastOn := false,cycleOn := r.cainSavedCycleV387
        Cycle6GuiSyncV525()
        if (r.cainActiveV368)
        {
            autoMonsterAttackOn := true
            farmResumeArmedV70 := true,farmResumeOutsideV70 := false
            CainModeApplyV16(r,false,true)
            FarmCastSyncV88(Stage2FightEnabledV9())
            FarmPickupSyncV57(0,0,-1,true)
            SetTimer, AutoMonsterAttackTimer, 250
            SetTimer, FarmResumeTimerV70, 500
        }
        else
            autoMonsterAttackOn := r.cainResumeAttackV387
        SetTimer, CainResumeBuffTimerV387, Off
        SetTimer, ScosEntryTimerV162, 250
        FonInfoPushV385("[CAIN] Buff xong - chạy hành trình mới từ dòng vàng")
    }
    finally
    {
        if (h)
            DllCall("CloseHandle","Ptr",h)
        busy := false
    }
}

CainAllStopV387(showNotice := true)
{
    global
    farmGD2TestV644 := false
    GuiControl, 1:, FarmGD2TestButtonV644, Run test
    if (sigBusyV147 && sigActiveModeV182="HOP")
        sigCancelV147 := true
    if (showNotice)
        FarmSkillBaselineEnsureV621(CoordDisplayGamePidV1(),true)
    autoMonsterAttackOn := false
    SetTimer, AutoMonsterAttackTimer, Off
    SetTimer, FarmPickupHandoffTimerV901, Off
    FarmWatchStateV688()
    SetTimer, FarmCrashWatchTimerV631, Off
    local orderedRowV740 := CoordYellowIndexV48()
    if (orderedRowV740>=1 && orderedRowV740<=coordSavedV15.Length())
        coordYellowRowV350 := orderedRowV740
    FarmRuntimeResetV535("FARM_STOP")
    farmStartChoiceV2 := false,farmStartHealthV536 := false
    FarmBuffStopV509()
    if (castManualToggleV1801)
        QCastOn := true
    FarmAttackHoldReleaseV15()
    local stoppedOwner := farmControlOwnerV186,timer
    cainPausedV10 := false
    autoMonsterAttackOn := false
    scosEntryV162 := false,stageTwoV166 := false
    mapButtonStartV172 := false,mapFarmStartPendingV170 := false,stage2StartPendingV381 := false
    farmResumeArmedV70 := false,farmResumeOutsideV70 := false
    farmStage3PendingV237 := false,sigFarmResumePendingV237 := false,farmRestartReasonV238 := ""
    if (IsObject(sigTownV148) && sigTownV148.auto)
        SigTownCancelV148("FARM_STOP")
    for _,timer in ["AutoMonsterAttackTimer","CainResumeBuffTimerV387","ScosEntryTimerV162"
        ,"StageTwoTimerV166","StageTwoTestArmTimerV167","StageTwoKeyLogTimerV164"
        ,"MapButtonStartTimerV172","MapFarmStartV170","Stage2StartWaitTimerV381"
        ,"MapStage2FlowTimerV372","FarmResumeTimerV70","FarmStage3RetryTimerV237","SigFarmResumeV152"
        ,"CoordGoTimerV59","CoordGoInputTimerV139"]
        SetTimer, %timer%, Off
    coordGoV59 := false,coordRouteV16 := false,roomExploreV89 := false
    stage2FlowV380 := false,farmStage2DoneV372 := false,cainHuntRouteV403 := false
    cainNoFightV361 := false,cainPauseFarmV361 := false,cainAttachRetryAtV379 := 0
    cainBossUidV361 := 0,cainBossClassV361 := 0,cainBossKilledV361 := false
    reviveBuffPendingV34 := false,farmReviveV32 := false
    portalBuffV85 := false,portalExitPendingV69 := false,portalBackPendingV74 := false
    farmMapPauseV52 := false,farmLoadedMapV56 := false
    farmControlOwnerV186 := "",mapWorkflowV185 := false
    mapRunResumeV210 := false,coordRunSelectedV210 := false
    coordCastCountV50 := 0,coordCastLastRowV50 := 0,coordCastPendingV50 := false
    pestiPointPendingV28 := false,lastAttackPendingV20 := false
    monsterCombatUidV45 := 0,monsterChaseV44 := false,monsterRoadAreaV51 := false
    combatRecoverV48 := false,combatMildRecoverV299 := false
    farmPickupBlockedV57 := false,farmPickupAllowedV57 := true,pickupFarmWorkV75 := false
    MovementCtrlSetV78(false,0,"FARM_STOP")
    farmStopMoveV124 := false
    SetTimer, FarmStopMoveTimerV124, Off
    if (coordTrackingEnabledV409 && !fonEditDepthV414)
        Gosub, CoordTrackingToggleV409
    ; STOP transfers pickup ownership to normal (non-Farm) pickup.
    farmPickupAllowedV57 := false, pickupFarmWorkV75 := false
    PickupEnabledSetV71(true,false,false)
    farmPickupAllowedV57 := false
    PortalLogWriteV66("FARM_STOP owner=" . stoppedOwner . " manual=" . farmManualStoppedV2026
        . " farm=OFF pickup=NORMAL fon=" . (coordTrackingEnabledV409 ? "ON" : "OFF") . " independent_features=KEPT")
    if (showNotice)
    {
        FonInfoPushV385("[STOP] Kết thúc " . (stoppedOwner!="" ? stoppedOwner : "lộ trình đang chạy"))
        ToolTipInfoV386("ĐÃ DỪNG LỘ TRÌNH " . stoppedOwner)
        SetTimer, RemoveToolTip, -2500
    }
}

CainHuntActiveV403()
{
    return CainHuntLevelV422()>0
}

CainHuntLevelV422()
{
    return FarmItemFlowLevelV427()
}

CainHuntClassesV423()
{
    if (BOFinalRouteActiveV451())
        return {1584:true}
    global bossPriorityClassesV221
    GuiControlGet, liveBossTextV403, 1:, BossPriorityListV221
    textV403 := ErrorLevel ? bossPriorityClassesV221 : liveBossTextV403
    idsV423 := {}
    for _,valueV423 in StrSplit(RegExReplace(textV403,"[,;\s]+",","),",")
    {
        valueV423 := Trim(valueV423)
        if (RegExMatch(valueV423,"^\d+$") && valueV423+0>0
            && !MonsterClassExcludedV11(valueV423+0))
            idsV423[valueV423+0] := true
    }
    return idsV423
}

CainHuntLockedV404(pid,level)
{
    global cainHuntRouteV403
    return level=CainHuntLevelV422() && CainHuntActiveV403() && IsObject(cainHuntRouteV403)
        && cainHuntRouteV403.pid=pid && IsObject(cainHuntRouteV403.boss)
}

CainHuntBossTickV403(h,player,ByRef pb,pid)
{
    if (BOCommonActiveV444(pid))
        return false
    global cainHuntRouteV403,monsterCombatUidV45,coordGoV59,monsterRadiusV48
    global scosEntryV162,gameItemActionOwner,packetWatchArmedV1,xRunning,zRunning,autoMonsterAttackOn
    global farmControlOwnerV186
    huntLevelV422 := CainHuntLevelV422()
    if (!CainHuntActiveV403() || CoordLevelV14(h,NumGet(pb,0x1C,"UInt"))!=huntLevelV422)
        return false
    room2V404 := D2ReadU32(h,NumGet(pb,0x1C,"UInt")+0x10)
    levelPtrV404 := room2V404 ? D2ReadU32(h,room2V404+0x58) : 0
    if (!levelPtrV404)
        return false
    if (!IsObject(cainHuntRouteV403) || cainHuntRouteV403.pid!=pid || cainHuntRouteV403.levelPtr!=levelPtrV404)
        cainHuntRouteV403 := {pid:pid,levelPtr:levelPtrV404,boss:false}
    wanted := CainHuntClassesV423()
    if (!wanted.Count())
    {
        CainHuntReleaseV407(IsObject(cainHuntRouteV403.boss) ? cainHuntRouteV403.boss.uid : 0)
        return false
    }
    if (IsObject(cainHuntRouteV403.boss) && !wanted.HasKey(cainHuntRouteV403.boss.cls))
        CainHuntReleaseV407(cainHuntRouteV403.boss.uid)
    lockedUID := IsObject(cainHuntRouteV403.boss) ? cainHuntRouteV403.boss.uid : 0
    px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort"),seen := {},target := false
    best := farmControlOwnerV186="BO" ? -1 : 1.0e30
    for _,room in MonsterLoadedRoomsV20(h,NumGet(pb,0x1C,"UInt"))
    {
        unit := D2ReadU32(h,room+0x74)
        Loop, 1024
        {
            if (!unit || seen.HasKey(unit) || seen.Count()>=4096)
                break
            seen[unit] := true
            if (!MonsterBossProbeReadV1(h,unit,0xEC,ub))
                break
            next := NumGet(ub,0xE8,"UInt"),uid := NumGet(ub,0x0C,"UInt"),cls := NumGet(ub,4,"UInt"),mode := NumGet(ub,0x10,"UInt")
            if (NumGet(ub,0,"UInt")=1 && wanted.HasKey(cls) && uid && (!lockedUID || uid=lockedUID))
            {
                if (mode=0 || mode=12)
                {
                    if (BOFinalRouteActiveV451(pid) && cls=1584)
                    {
                        scosEntryV162.boBossKilledV454 := true
                        PortalLogWriteV66("BO_FINAL_BOSS_DEAD class=1584 uid=" . uid . " next=SORT_TRANSFER_THEN_PICKUP")
                    }
                    if (uid=lockedUID)
                        cainHuntRouteV403.boss := false,monsterCombatUidV45 := 0
                }
                else if (MonsterBossProbeReadV1(h,NumGet(ub,0x2C,"UInt"),0x20,mb)
                    && CoordLevelV14(h,NumGet(mb,0x1C,"UInt"))=huntLevelV422)
                {
                    x := NumGet(mb,2,"UShort"),y := NumGet(mb,6,"UShort"),d := (x-px)**2+(y-py)**2
                    if ((farmControlOwnerV186="BO" && d>best) || (farmControlOwnerV186!="BO" && d<best))
                        target := {unit:unit,uid:uid,cls:cls,x:x,y:y,level:huntLevelV422,dist:d},best := d
                }
            }
            unit := next
        }
    }
    if (!IsObject(target))
    {
        CainHuntReleaseV407(lockedUID)
        return false
    }
    if (!lockedUID)
    {
        cainHuntRouteV403.approachPending := true,cainHuntRouteV403.combatProbe := false
        if (BOFinalRouteActiveV451(pid))
            PortalLogWriteV66("BO_FINAL_BOSS_LOCK class=1584 uid=" . target.uid . " route=PAUSED pickup=OFF until=DEAD")
        PortalLogWriteV66("CAIN_FINAL_BOSS_LOCK class=" . target.cls . " uid=" . target.uid)
    }
    cainHuntRouteV403.boss := target,monsterCombatUidV45 := target.uid
    if (gameItemActionOwner!="" || packetWatchArmedV1 || xRunning || zRunning || !autoMonsterAttackOn)
        return true
    hpInfoV405 := MonsterBossProbeHPV2(h,D2ReadU32(h,target.unit+0x5C))
    hpRawV405 := hpInfoV405.ok ? hpInfoV405.raw : -1
    blockedV405 := CainHuntCombatStuckV405(target,px,py,hpRawV405)
    PortalLogWriteV66("CAIN_BOSS_STATE level=huntLevelV422 class=" . target.cls . " uid=" . target.uid
        . " hp_raw=" . hpRawV405 . " distance=" . Round(Sqrt(target.dist),2)
        . " player=" . px . "," . py . " target=" . target.x . "," . target.y
        . " stuck=" . blockedV405 . " locked=1", "CAIN_BOSS_STATE",1000)
    farV405 := target.dist>MonsterScanRadiusV20(huntLevelV422)**2
    boRouteOnlyV458 := BOFinalRouteActiveV451(pid)
    if (boRouteOnlyV458)
    {
        cainHuntRouteV403.approachPending := false
        if (farV405)
        {
            monsterCombatUidV45 := 0
            PortalLogWriteV66("BO_FINAL_BOSS_WAIT_RADIUS uid=" . target.uid . " distance=" . Round(Sqrt(target.dist),2)
                . " movement=SAVED_XY_ONLY chase=OFF","BO_FINAL_BOSS_WAIT_RADIUS",1000)
            return false
        }
    }
    if (!boRouteOnlyV458 && (cainHuntRouteV403.approachPending || blockedV405 || farV405) && target.dist>4)
    {
        reasonV405 := blockedV405 ? "BOSS_HP_AND_DISTANCE_UNCHANGED" : cainHuntRouteV403.approachPending ? "BOSS_FOUND" : "BOSS_OUTSIDE_ATTACK_RADIUS"
        if (CainHuntTeleportV405(h,pb,pid,target,reasonV405))
            return true
    }
    if (!boRouteOnlyV458 && farV405)
        return CainHuntMoveV403(h,pb,pid,target)
    if (D2ReadU32(h,target.unit+0x0C)!=target.uid || D2ReadU32(h,target.unit+4)!=target.cls
        || D2ReadU32(h,target.unit+0x10)=0 || D2ReadU32(h,target.unit+0x10)=12)
        return true
    if (AutoMonsterPacketSendV1(pid,target.unit,target.uid))
    {
        AttackIdTipV12(target.cls,Round(Sqrt(target.dist),1))
        probeV405 := cainHuntRouteV403.combatProbe
        if (IsObject(probeV405) && probeV405.uid=target.uid)
        {
            if (!probeV405.since)
                probeV405.since := A_TickCount
            probeV405.queued++
        }
    }
    return true
}

CainHuntReleaseV407(uid)
{
    global cainHuntRouteV403,monsterCombatUidV45,monsterChaseV44,monsterRoadAreaV51
    if (!IsObject(cainHuntRouteV403))
        return
    cainHuntRouteV403.boss := false,cainHuntRouteV403.goal := false
    cainHuntRouteV403.combatProbe := false,cainHuntRouteV403.approachPending := false
    if (uid && monsterCombatUidV45=uid)
        monsterCombatUidV45 := 0,monsterChaseV44 := false,monsterRoadAreaV51 := false
    if (uid)
        PortalLogWriteV66("CAIN_FINAL_BOSS_RELEASE uid=" . uid . " reason=NOT_VISIBLE_OR_DEAD next=COMMON_FARM_ROUTE")
}

CainHuntRouteLoopV407()
{
    global coordRouteV16,coordSavedV15,coordNoTargetSinceV14,scosEntryV162
    huntLevelV422 := CainHuntLevelV422()
    r := coordRouteV16
    if (!CainHuntActiveV403() || !IsObject(r) || r.startLevel!=huntLevelV422 || r.phase!="DONE"
        || CainHuntLockedV404(r.pid,huntLevelV422) || !IsObject(coordSavedV15) || !coordSavedV15.Length())
        return false
    for _,point in coordSavedV15
        if (point.level!=huntLevelV422)
            return false
    r.anchor := 0,r.next := 1,r.yellow := 1,r.phase := "NEXT",r.forwardFloorV303 := 0
    r.tries := 0,r.bestDist := -1,r.lastDispatch := 0,r.moveProbe := false
    r.stuckProbe := false,r.escapeV84 := false,r.bypass := false,r.battlePending := false
    r.firstMoveAttempted := false,r.legRow := 0,r.closestGoalDistance := -1
    coordNoTargetSinceV14 := A_TickCount-250
    CoordBoxRefreshV15()
    PortalLogWriteV66("ITEM_HUNT_ROUTE_LOOP level=" . huntLevelV422 . " next_row=1 rows=" . coordSavedV15.Length())
    return true
}

CainHuntCombatStuckV405(target,px,py,hpRaw)
{
    global cainHuntRouteV403,chaseCheckSecV9
    c := cainHuntRouteV403.combatProbe,distance := Sqrt(target.dist)
    if (!IsObject(c) || c.uid!=target.uid)
    {
        cainHuntRouteV403.combatProbe := {uid:target.uid,x:px,y:py,hp:hpRaw,distance:distance,since:0,queued:0}
        return false
    }
    hpProgress := hpRaw>=0 && c.hp>=0 && hpRaw<c.hp
    if (hpProgress)
        FarmWatchProgressV5()
    closing := c.distance-distance>=1
    moved := (px-c.x)**2+(py-c.y)**2>4
    if (hpProgress || closing || moved)
    {
        c.x := px,c.y := py,c.hp := hpRaw,c.distance := distance,c.since := 0,c.queued := 0
        return false
    }
    if (hpRaw>=0 && c.hp<0)
        c.hp := hpRaw
    return c.queued>=2 && c.since && A_TickCount-c.since>=Max(1,chaseCheckSecV9)*1000
}

CainHuntTeleportV405(h,ByRef pb,pid,target,reason)
{
    if (CoordLevelV14(h,NumGet(pb,0x1C,"UInt"))=163)
        return false
    global cainHuntRouteV403,coordGoV59,coordManualTeleLastV296,coordRouteV16
    global teleportKeyV55,teleportIntervalSecV56,autoMonsterAttackOn
    if (!IsObject(cainHuntRouteV403) || !autoMonsterAttackOn || teleportKeyV55=""
        || CoordLevelV14(h,NumGet(pb,0x1C,"UInt"))!=CainHuntLevelV422())
        return false
    r := cainHuntRouteV403
    lastTele := Max(r.lastTele+0,coordManualTeleLastV296+0,IsObject(coordRouteV16) ? coordRouteV16.lastTeleport+0 : 0)
    if (lastTele && A_TickCount-lastTele<Max(3,teleportIntervalSecV56)*1000)
        return false
    if (r.teleRetryAt && A_TickCount<r.teleRetryAt)
        return false
    if ((target.x-NumGet(pb,2,"UShort"))**2+(target.y-NumGet(pb,6,"UShort"))**2<=4)
    {
        r.approachPending := false
        return false
    }
    goal := {pid:pid,level:target.level,x:target.x,y:target.y,row:0,requiredArrival:true,stop:false}
    priorGoal := coordGoV59,coordGoV59 := goal
    try
        sent := CoordGoTeleportV284(h,pb,goal)
    finally
        if (coordGoV59=goal)
            coordGoV59 := priorGoal
    if (cainHuntRouteV403!=r || !autoMonsterAttackOn)
        return false
    if (!sent)
    {
        r.teleRetryAt := A_TickCount+300
        return false
    }
    r.lastTele := A_TickCount,coordManualTeleLastV296 := r.lastTele
    r.teleRetryAt := 0,r.approachPending := false,r.combatProbe := false
    if (IsObject(coordRouteV16))
        coordRouteV16.lastTeleport := r.lastTele
    if (IsObject(r.goal) && IsObject(r.goal.routeV392))
        r.goal.routeV392.lastTeleport := r.lastTele
    PortalLogWriteV66("CAIN_BOSS_TELEPORT uid=" . target.uid . " class=" . target.cls
        . " destination=" . target.x . "," . target.y . " reason=" . reason . " next=RESCAN_ATTACK")
    return true
}

CainHuntMoveV403(h,ByRef pb,pid,target)
{
    global cainHuntRouteV403,coordGoV59
    if (CainHuntTeleportV405(h,pb,pid,target,"CHASE_LOCKED_BOSS"))
        return true
    if (!IsObject(cainHuntRouteV403.goal) || cainHuntRouteV403.goal.uid!=target.uid)
        cainHuntRouteV403.goal := {pid:pid,level:target.level,x:target.x,y:target.y,uid:target.uid,row:0,requiredArrival:true,stop:false}
    goal := cainHuntRouteV403.goal,goal.x := target.x,goal.y := target.y
    priorGoal := coordGoV59,coordGoV59 := goal
    try
    {
        if (!CoordGoFarmStuckV392(h,pb,goal))
            NativeMovePointV14(pid,target.x,target.y,target.level,true,false,true,goal)
    }
    finally
        if (coordGoV59=goal)
            coordGoV59 := priorGoal
    return true
}

CainFinalFarmBeginV388(r,enablePickup := true)
{
    global cainNoFightV361,cainPauseFarmV361,farmPickupBlockedV57,farmPickupAllowedV57,cainHuntRouteV403
    cainHuntRouteV403 := false
    r.cainPhaseV361 := "FLOW_ITEM"
    r.cainLevelV19 := 185
    r.cainFinalDoneV388 := false
    FarmItemFlowBeginV427(1839,7,false)
    r.cainModeV383 := "ITEM"
    r.cainPickupResumeV370 := true
    if (enablePickup)
        CainIntermediatePickupResumeV370(r)
    else
    {
        PickupEnabledSetV71(false,true,false)
        farmPickupBlockedV57 := true,farmPickupAllowedV57 := false
    }
    PortalLogWriteV66("CAIN_FINAL_BEGIN level=185 flow=FARM_ITEM class=1839 itemdata=07")
}

CainFinalFarmDoneV388(r,h,player)
{
    global scosEntryV162,sigTownV148,farmStage2DoneV372,cainPauseFarmV361,farmRestartReasonV238
    global xRunning,zRunning,gameItemActionOwner,packetWatchArmedV1,sigBusyV147
    if (!FarmItemFlowDoneV427())
        return false
    if (!r.cainFinalDoneV388)
    {
        r.cainFinalDoneV388 := true
        r.cainPhaseV383 := "DONE"
        MapStage2RouteFinishV185()
        FonInfoPushV385("[CAIN 185] GĐ2 DONE - đã nhặt thêm 1839/07; tiếp theo mở cổng về thành")
        PortalLogWriteV66("CAIN_FINAL_DONE result=STAGE2_ITEM_DONE next=RETURN_TOWN")
    }
    cainPauseFarmV361 := true
    if (xRunning || zRunning || gameItemActionOwner!="" || packetWatchArmedV1 || sigBusyV147
        || !AutoMonsterPacketCleanupV1())
        return true
    inv := D2ReadU32(h,player+0x60)
    cursor := inv ? PickupCursorV4(h,inv) : false
    if (!IsObject(cursor) || cursor.unit)
        return true
    if (IsObject(farmStage2DoneV372))
        farmStage2DoneV372.handled := true
    scosEntryV162 := false
    SetTimer, ScosEntryTimerV162, Off
    cainPauseFarmV361 := false
    if (FarmStage3RequestV313("COMPLETE"))
    {
        PortalLogWriteV66("CAIN_FINAL_HANDOFF next=STAGE3_DLL no_town=1")
        return true
    }
    FarmErrorKeepV769("CAIN_STAGE3_HANDOFF_FAILED")
    FarmCombatYieldV237()
    PickupEnabledSetV71(false,true,false)
    farmRestartReasonV238 := ""
    ToolTipInfoV386("CAIN: đã có vật cần — giữ phiên farm, chờ xử lý chuyển bước.")
    SetTimer, RemoveToolTip, -4000
    PortalLogWriteV66("CAIN_FINAL_HANDOFF next=ERROR_KEEP_FARM")
    return true
}

Stage2ItemBaselineInitV389()
{
    global stage2FlowV380
    r := stage2FlowV380
    if (!IsObject(r) || r.mode!="ITEM")
        return false
    h := D2OpenProcess(r.pid)
    if (!h)
        return false
    try
    {
        base := D2GetModuleBaseV35(r.pid,"D2Client.dll")
        player := base ? D2ReadU32(h,base+0x11BBFC) : 0
        count := Stage2ItemCountV380(h,player,r.itemClass,r.itemData)
        if (count<0 || stage2FlowV380!=r)
            return false
        Stage2ItemBaselineSetV389(r,count)
        if (!Stage2ItemCubeBaselineV420(h,player,r))
        {
            r.baselineReadyV389 := false
            return false
        }
        return true
    }
    finally
        DllCall("CloseHandle","Ptr",h)
}

Stage2ItemBaselineSetV389(r,count)
{
    r.baselineCountV389 := count
    r.currentCountV389 := count
    r.baselineReadyV389 := true
    PortalLogWriteV66("STAGE2_ITEM_BASELINE class=" . r.itemClass . " itemdata=" . r.itemData
        . " inventory_plus_cube=" . count . " done=REQUIRES_COUNT_INCREASE")
    FonInfoPushV385("[GĐ2 ITEM] Ban đầu: " . count . " món trong rương + cube; chờ nhặt thêm")
}

FarmCloseNoDamageV391(h,target,pid,hpRaw)
{
    global monsterChaseV44,chaseCheckSecV9,petLearnEnabledV12,monsterExcludeClassesV11,petExcludeDistanceV604
    c := monsterChaseV44
    if (!petLearnEnabledV12)
    {
        if (IsObject(c))
            c.petCloseProbeV603 := false
        return false
    }
    if (!IsObject(c) || c.uid!=target.uid || c.pid!=pid || c.level!=target.level)
        return false
    radiusV604 := petExcludeDistanceV604
    if (radiusV604<1 || target.dist>=radiusV604*radiusV604 || hpRaw<=0)
    {
        c.petCloseProbeV603 := false
        return false
    }
    w := c.petCloseProbeV603
    if (!IsObject(w) || w.hp!=hpRaw || A_TickCount-w.seen>1500)
    {
        c.petCloseProbeV603 := w := {hp:hpRaw,since:0,seen:A_TickCount}
        return false
    }
    w.seen := A_TickCount
    if (!w.since)
    {
        if (c.queued>0)
            w.since := A_TickCount
        return false
    }
    requiredMs := Max(1,chaseCheckSecV9)*1000
    if (A_TickCount-w.since<requiredMs)
        return false
    if (!MonsterBossProbeReadV1(h,target.unit,0x30,ub) || NumGet(ub,0,"UInt")!=1
        || NumGet(ub,12,"UInt")!=target.uid || NumGet(ub,16,"UInt")=0 || NumGet(ub,16,"UInt")=12
        || (target.cls && NumGet(ub,4,"UInt")!=target.cls))
    {
        c.petCloseProbeV603 := false
        return false
    }
    fresh := MonsterBossProbeHPV2(h,D2ReadU32(h,target.unit+0x5C))
    if (!fresh.ok || fresh.raw!=w.hp)
    {
        c.petCloseProbeV603 := false
        return false
    }
    cls := NumGet(ub,4,"UInt")
    if (!cls)
        return false
    if (!MonsterClassExcludedV11(cls))
    {
        previousList := monsterExcludeClassesV11
        monsterExcludeClassesV11 .= (Trim(monsterExcludeClassesV11)="" ? "" : ",") . cls
        if (!PetExcludeSaveV12())
        {
            monsterExcludeClassesV11 := previousList
            AutoMonsterAttackLogV2("PET_AUTO_ADD_FAILED class=" . cls . " uid=" . target.uid . " reason=SAVE_FAILED")
            return false
        }
        PetExcludeRefreshV16()
    }
    AutoMonsterAttackLogV2("PET_AUTO_ADDED class=" . cls . " uid=" . target.uid
        . " unchanged_ms=" . (A_TickCount-w.since) . " required_ms=" . requiredMs
        . " hp_raw=" . fresh.raw . " distance=" . Round(Sqrt(target.dist),1) . " max_distance=" . radiusV604 . " next=SKIP_CLASS")
    c.petCloseProbeV603 := false
    return true
}


CoordGoFarmStuckV392(h,ByRef pb,goal)
{
    global coordGoV59,coordManualTeleLastV296,coordSavedV15
    if (coordGoV59!=goal || goal.stop)
        return false
    px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort")
    if (!IsObject(goal.routeV392))
    {
        previous := coordSavedV15[goal.row-1]
        if (IsObject(previous) && previous.level=goal.level)
            previous := {x:previous.x,y:previous.y,level:previous.level}
        else
            previous := {x:px,y:py,level:goal.level}
        goal.pointsV392 := [previous,goal]
        goal.routeV392 := {pid:goal.pid,anchor:1,next:2,phase:"NEXT",lastTeleport:coordManualTeleLastV296
            ,startX:px,startY:py,startLevel:goal.level,stuckProbe:false}
    }
    r := goal.routeV392
    handled := CoordStuckTickV84(h,pb,goal.pid,goal)
    coordManualTeleLastV296 := r.lastTeleport
    return handled
}

CoordStuckMoveV392(pid,x,y,level,r,row,manualGoal := false)
{
    global coordGoV59
    if (IsObject(manualGoal))
    {
        if (!CoordRecoveryGoalValidV655(manualGoal) || manualGoal.stop)
            return false
        return NativeMovePointV14(pid,x,y,level,true,false,true,manualGoal)
    }
    return NativeMovePointV14(pid,x,y,level,false,false,false,false,{route:r,row:row})
}

HopButtonV556:
if (sigBusyV147 && sigActiveModeV182="HOP")
{
    sigCancelV147 := true
    return
}
if (sigBusyV147 || hopPromptV557)
    return
hopPromptV557 := true
InputBox, hopCountV557, HOP, Nhập tổng số thành phẩm cần ghép:, , 330, 145,,,,, 1
hopPromptV557 := false
if (ErrorLevel)
    return
if (!RegExMatch(Trim(hopCountV557),"^\d+$") || hopCountV557<1 || hopCountV557>9999)
{
    ToolTipInfoV386("HOP: nhập số lượng từ 1 đến 9999.")
    SetTimer, RemoveToolTip, -3000
    return
}
HopRunV556(hopCountV557+0)
return

HopInfoV557(text)
{
    global sigLastStopReasonV63
    sigLastStopReasonV63 := "HOP: " . text
    ToolTipInfoV386(sigLastStopReasonV63)
    FonInfoPushV385(sigLastStopReasonV63)
    SigLogV147("HOP " . text)
}

HopRulesV557()
{
    file := TxtRootPathV816("Rune.txt"),rules := [],seen := {}
    if (!FileExist(file))
    {
        FileAppend, 2354|02`r`n, %file%, UTF-8
        if (ErrorLevel)
            SigFailV147("HOP: không tạo được txt\Rune.txt cạnh tool")
    }
    FileRead, raw, %file%
    if (ErrorLevel)
        SigFailV147("HOP: không đọc được Rune.txt")
    Loop, Parse, raw, `n, `r
    {
        line := Trim(A_LoopField," `t" . Chr(0xFEFF))
        if (line="" || SubStr(line,1,1)="#" || SubStr(line,1,1)=";")
            continue
        if (!RegExMatch(line,"^(\d+)\s*\|\s*02$",m)
            || m1+0<=0 || m1+0=1204 || m1+0=1733 || m1+0=2439)
            SigFailV147("HOP: Rune.txt sai dòng " . A_Index . ": " . line)
        cls := m1+0
        if (!seen.HasKey(cls))
            rules.Push(cls),seen[cls] := true
    }
    if (!rules.Length())
        SigFailV147("HOP: Rune.txt chưa có dòng CLASS|02")
    return rules
}

HopLiveV557(ctx,item,loc:=-1,normalOnly:=true)
{
    all := SigSnapshotV147(ctx),a := all[item.uid]
    if (!IsObject(a) || a.cls!=item.cls || (normalOnly ? a.q!=2 : a.q!=item.q) || (loc>=0 && a.loc!=loc)
        || D2ReadU32(ctx.h,a.unit+0x10)=3 || D2ReadU32(ctx.h,a.unit+0x10)=5)
        SigFailV147("HOP: vật đã đổi trạng thái, CLASS=" . item.cls . " UID=" . item.uid)
    return a
}

HopFindV557(ctx,cls,loc,skip:=false)
{
    for uid,a in SigSnapshotV147(ctx)
        if (a.cls=cls && a.q=2 && a.loc=loc
            && (loc!=0 || a.owner=ctx.inv) && (!IsObject(skip) || !skip.HasKey(uid))
            && D2ReadU32(ctx.h,a.unit+0x10)!=3 && D2ReadU32(ctx.h,a.unit+0x10)!=5)
            return a
    return false
}

HopTextV557(ctx,item,normalOnly:=true)
{
    global pickupOptJobV12
    label := normalOnly ? "HOP" : "Sắp xếp"
    started := A_TickCount
    while (IsObject(pickupOptJobV12))
    {
        SigCheckV147(ctx)
        PickupOptPollV12()
        if (A_TickCount-started>3500)
            SigFailV147(label . ": đang chờ lượt đọc thông tin vật phẩm")
        Sleep, 30
    }
    item := HopLiveV557(ctx,item,-1,normalOnly)
    seed := D2ReadU32(ctx.h,item.data+0x14)
    job := PickupOptStartV12(ctx.pid,item.unit,item.cls,item.q,item.data,item.uid,seed,true)
    if (!IsObject(job))
        SigFailV147(label . ": chưa đọc được thông tin CLASS=" . item.cls)
    started := A_TickCount
    try
    {
        while (DllCall("WaitForSingleObject","Ptr",job.th,"UInt",0)!=0)
        {
            SigCheckV147(ctx)
            if (A_TickCount-started>3000)
                SigFailV147(label . ": đọc thông tin quá hạn")
            Sleep, 30
        }
        exitCode := 0
        if (!DllCall("GetExitCodeThread","Ptr",job.th,"UInt*",exitCode) || exitCode!=1)
            SigFailV147(label . ": game chưa trả thông tin vật phẩm")
        live := HopLiveV557(ctx,item,-1,normalOnly)
        if (live.unit!=item.unit || live.data!=item.data || D2ReadU32(ctx.h,live.data+0x14)!=seed)
            SigFailV147(label . ": vật thay đổi trong lúc đọc thông tin")
        return PickupOptCleanTextV12(PickupOptReadWideV12(job.hp,job.name,512)) . "`n"
            . PickupOptCleanTextV12(PickupOptReadWideV12(job.hp,job.stats,4096),true)
    }
    finally
    {
        if (DllCall("WaitForSingleObject","Ptr",job.th,"UInt",0)=0)
            DllCall("VirtualFreeEx","Ptr",job.hp,"Ptr",job.remote,"UPtr",0,"UInt",0x8000)
        DllCall("CloseHandle","Ptr",job.th),DllCall("CloseHandle","Ptr",job.hp)
    }
}

HopQuantityV557(ctx,item)
{
    text := HopTextV557(ctx,item)
    if (!RegExMatch(text,"im)\bQuantity\s*:?\s*([0-9][0-9,]*)",m))
        SigFailV147("HOP: chưa đọc được Quantity của CLASS=" . item.cls . "; chưa tách rune")
    value := StrReplace(m1,",")+0
    if (value<0 || value>10000000)
        SigFailV147("HOP: Quantity không hợp lệ")
    return value
}

HopCloseV557(ctx)
{
    global sigSendingKeyV147,sigCubeUiOpenV159
    if (!ctx.hopStashOpen && !sigCubeUiOpenV159)
        return
    SigCheckV147(ctx)
    sigSendingKeyV147 := true
    try
    {
        if (!GameTargetKeyV63("{Esc}"))
            SigFailV147("HOP: chưa đóng được cửa sổ đồ")
    }
    finally
        sigSendingKeyV147 := false
    ctx.hopStashOpen := false,sigCubeUiOpenV159 := false
    Sleep, 200
}

HopMoveV557(ctx,point,row)
{
    global coordGoV59,sigSendingKeyV147,chaseCheckSecV9
    HopCloseV557(ctx)
    GameItemActionEndV4("Cube")
    goal := {pid:ctx.pid,x:point.x,y:point.y,level:point.level,row:row,redirect:true
        ,requiredArrival:true,singleMove:false,manualInterrupt:false}
    SetTimer, CoordGoTimerV59, Off
    SetTimer, CoordGoInputTimerV139, Off
    coordGoV59 := goal,started := A_TickCount
    lastX := -1,lastY := -1,progressAt := started,lastSend := 0
    HopInfoV557("đi tọa độ " . row . " (" . point.x . "," . point.y . ")")
    try
    {
        Loop
        {
            SigCheckV147(ctx)
            if (coordGoV59!=goal)
                SigFailV147("HOP: đã dừng hoặc thay đổi lệnh di chuyển")
            path := D2ReadU32(ctx.h,ctx.player+0x2C)
            if (!MonsterBossProbeReadV1(ctx.h,path,0x20,pb)
                || CoordLevelV14(ctx.h,NumGet(pb,0x1C,"UInt"))!=point.level)
                SigFailV147("HOP: đã đổi map trong khi đi tọa độ")
            px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort")
            if ((px-point.x)**2+(py-point.y)**2<=4)
                break
            if (px!=lastX || py!=lastY)
                lastX := px,lastY := py,progressAt := A_TickCount
            mode := D2ReadU32(ctx.h,ctx.player+0x10)
            moving := mode=2 || mode=3 || mode=6
            if (A_TickCount-started>120000)
                SigFailV147("HOP: chưa đến tọa độ " . row . " sau 120 giây")
            sigSendingKeyV147 := true
            try
            {
                recovering := CoordGoFarmStuckV392(ctx.h,pb,goal)
                if (!recovering && (!lastSend || (!moving && A_TickCount-lastSend>=350)
                    || (moving && A_TickCount-progressAt>=Max(1,chaseCheckSecV9)*1000
                        && A_TickCount-lastSend>=350)))
                    if (NativeMovePointV14(ctx.pid,point.x,point.y,point.level,true,false,true,goal))
                        lastSend := A_TickCount
            }
            finally
                sigSendingKeyV147 := false
            Sleep, 150
        }
    }
    finally
    {
        if (coordGoV59=goal)
            CoordGoCancelV41(goal)
    }
    wait := A_TickCount
    while (!AutoMonsterPacketCleanupV1())
    {
        SigCheckV147(ctx)
        if (A_TickCount-wait>4000)
            SigFailV147("HOP: đang chờ lệnh di chuyển kết thúc")
        Sleep, 30
    }
    if (!GameItemActionBeginV4("Cube","cube",true))
        SigFailV147("HOP: chưa lấy được lượt xử lý Cube sau di chuyển")
}

HopOpenStashV557(ctx)
{
    if (ctx.hopStashOpen)
        return
    HopCloseV557(ctx)
    path := D2ReadU32(ctx.h,ctx.player+0x2C)
    if (!MonsterBossProbeReadV1(ctx.h,path,0x20,pb))
        SigFailV147("HOP: chưa đọc được vị trí thủ khố")
    stash := CycObjectV42(ctx.h,pb,267)
    level := CoordLevelV14(ctx.h,NumGet(pb,0x1C,"UInt")),started := A_TickCount
    if (!IsObject(stash))
        SigFailV147("HOP: không thấy thủ khố ở tọa độ cuối n")
    while (!SigTownInteractStashV342(ctx.pid,level,stash))
    {
        SigCheckV147(ctx)
        if (A_TickCount-started>4000)
            SigFailV147("HOP: chưa mở được thủ khố ở tọa độ cuối n")
        Sleep, 100
    }
    ctx.hopStashOpen := true
    Sleep, 600
    SigCheckV147(ctx)
}

HopGridInitV559(ctx)
{
    grid := {cells:{},items:{},width:0,height:0,serial:0}
    for uid,a in SigSnapshotV147(ctx)
        if (a.loc=0 && a.owner=ctx.inv && D2ReadU32(ctx.h,a.unit+0x10)=0)
        {
            size := TicketItemSizeV277(ctx,a.cls)
            if (a.x<0 || a.y<0 || a.x+size.w>32 || a.y+size.h>32)
                SigFailV147("HOP: vùng túi không hợp lệ khi quét ô trống")
            grid.width := Max(grid.width,a.x+size.w),grid.height := Max(grid.height,a.y+size.h)
            grid.serial += 1
            slot := {x:a.x,y:a.y,w:size.w,h:size.h,token:grid.serial,uid:uid}
            grid.items[uid] := slot
            Loop, % slot.h
            {
                yy := slot.y+A_Index-1
                Loop, % slot.w
                    grid.cells[(slot.x+A_Index-1) . "," . yy] := slot.token
            }
        }
    if (!grid.width || !grid.height)
        SigFailV147("HOP: chưa xác định được vùng túi để nhớ ô trống")
    ctx.hopGridV559 := grid
    SigLogV147("HOP_FREE_CELLS_SCAN_ONCE width=" . grid.width . " height=" . grid.height)
}

HopSlotFitsV559(grid,x,y,w,h,token:=0)
{
    if (x<0 || y<0 || x+w>grid.width || y+h>grid.height)
        return false
    Loop, %h%
    {
        yy := y+A_Index-1
        Loop, %w%
        {
            key := (x+A_Index-1) . "," . yy
            if (grid.cells.HasKey(key) && grid.cells[key]!=token)
                return false
        }
    }
    return true
}

HopSlotReserveV559(ctx,item,x:=-1,y:=-1)
{
    grid := ctx.hopGridV559,size := TicketItemSizeV277(ctx,item.cls)
    if (!IsObject(grid))
        SigFailV147("HOP: chưa quét ô trống đầu phiên")
    if (x<0)
    {
        found := false
        Loop, % grid.height
        {
            yy := A_Index-1
            Loop, % grid.width
            {
                xx := A_Index-1
                if (HopSlotFitsV559(grid,xx,yy,size.w,size.h))
                {
                    x := xx,y := yy,found := true
                    break
                }
            }
            if (found)
                break
        }
        if (!found)
            SigFailV147("HOP: hết ô trống đã nhớ cho vật CLASS=" . item.cls)
    }
    if (!HopSlotFitsV559(grid,x,y,size.w,size.h))
        SigFailV147("HOP: ô đã nhớ không đủ chỗ cho vật CLASS=" . item.cls)
    grid.serial += 1
    slot := {x:x,y:y,w:size.w,h:size.h,token:grid.serial,uid:item.uid}
    Loop, % slot.h
    {
        yy := slot.y+A_Index-1
        Loop, % slot.w
            grid.cells[(slot.x+A_Index-1) . "," . yy] := slot.token
    }
    grid.items[item.uid] := slot
    return slot
}

HopSlotReleaseV559(ctx,slot)
{
    grid := ctx.hopGridV559
    Loop, % slot.h
    {
        yy := slot.y+A_Index-1
        Loop, % slot.w
        {
            key := (slot.x+A_Index-1) . "," . yy
            if (grid.cells.HasKey(key) && grid.cells[key]=slot.token)
                grid.cells.Delete(key)
        }
    }
    if (grid.items.HasKey(slot.uid) && grid.items[slot.uid]=slot)
        grid.items.Delete(slot.uid)
}

HopReturnV559(ctx,item,slot:=false)
{
    grid := ctx.hopGridV559,size := TicketItemSizeV277(ctx,item.cls)
    if (!IsObject(slot))
        slot := HopSlotReserveV559(ctx,item)
    if (size.w>slot.w || size.h>slot.h
        || !HopSlotFitsV559(grid,slot.x,slot.y,slot.w,slot.h,slot.token))
        SigFailV147("HOP: ô trả vật đã nhớ không còn hợp lệ")
    cursor := PickupCursorV4(ctx.h,ctx.inv)
    if (!IsObject(cursor) || cursor.uid!=item.uid)
        SigLiftV147(ctx,item)
    bytes := [0x18],SigDwordV147(bytes,item.uid),SigDwordV147(bytes,slot.x)
    SigDwordV147(bytes,slot.y),SigDwordV147(bytes,0)
    SigPacketV147(ctx,bytes)
    live := SigWaitLocV147(ctx,item.uid,0,2000)
    if (!IsObject(live) || live.cls!=item.cls || live.q!=item.q || live.x!=slot.x || live.y!=slot.y)
        SigFailV147("HOP: chưa trả vật về ô đã nhớ " . slot.x . "," . slot.y . "; không dò ô khác")
    if (grid.items.HasKey(slot.uid) && grid.items[slot.uid]=slot)
        grid.items.Delete(slot.uid)
    slot.uid := item.uid,grid.items[item.uid] := slot
    SigLogV147("HOP_RETURN_SAVED_CELL uid=" . item.uid . " xy=" . slot.x . "," . slot.y)
    return slot
}

HopProductReturnV559(ctx,item,inputs)
{
    grid := ctx.hopGridV559,slots := [],size := TicketItemSizeV277(ctx,item.cls)
    for _,a in inputs
    {
        if (!grid.items.HasKey(a.uid))
            SigFailV147("HOP: không còn nhớ ô nguyên liệu UID=" . a.uid)
        slots.Push(grid.items[a.uid])
    }
    for _,slot in slots
        HopSlotReleaseV559(ctx,slot)
    for _,slot in slots
        if (HopSlotFitsV559(grid,slot.x,slot.y,size.w,size.h))
            return HopReturnV559(ctx,item,HopSlotReserveV559(ctx,item,slot.x,slot.y))
    SigFailV147("HOP: thành phẩm không vừa ô của ba nguyên liệu; giữ trong Cube")
}

HopStashTakeV557(ctx,item)
{
    HopOpenStashV557(ctx)
    live := HopLiveV557(ctx,item,4)
    home := {cls:live.cls,q:live.q,x:live.x,y:live.y,loc:live.loc}
    invHome := HopSlotReserveV559(ctx,live)
    cursor := PickupCursorV4(ctx.h,ctx.inv)
    if (!IsObject(cursor) || cursor.unit)
        SigFailV147("HOP: có vật trên chuột trước khi lấy thủ khố")
    bytes := [0x19],SigDwordV147(bytes,live.uid)
    SigPacketV147(ctx,bytes)
    if (!SigWaitLocV147(ctx,live.uid,4))
        SigFailV147("HOP: chưa nhấc được container trong thủ khố")
    HopReturnV559(ctx,live,invHome)
    return {item:HopLiveV557(ctx,live,0),home:home,invHome:invHome}
}

HopStashPutV557(ctx,record)
{
    HopOpenStashV557(ctx)
    item := HopLiveV557(ctx,record.item),home := record.home
    if (item.cls!=home.cls || item.q!=home.q)
        SigFailV147("HOP: container không khớp ô thủ khố đã nhớ")
    SigLiftV147(ctx,item)
    bytes := [0x18],SigDwordV147(bytes,item.uid),SigDwordV147(bytes,home.x)
    SigDwordV147(bytes,home.y),SigDwordV147(bytes,home.loc)
    SigPacketV147(ctx,bytes)
    started := A_TickCount
    Loop
    {
        all := SigSnapshotV147(ctx),live := all[item.uid],cursor := PickupCursorV4(ctx.h,ctx.inv)
        if (IsObject(live) && live.cls=home.cls && live.q=home.q && live.loc=home.loc
            && live.x=home.x && live.y=home.y && IsObject(cursor) && !cursor.unit)
        {
            HopSlotReleaseV559(ctx,record.invHome)
            return true
        }
        if (A_TickCount-started>3000)
            SigFailV147("HOP: chưa trả container " . home.cls . " về đúng ô thủ khố " . home.x . "," . home.y)
        Sleep, 50
    }
}

HopSplitV557(ctx,cube,record,count,quantity:=-1)
{
    item := HopLiveV557(ctx,record.item,0),items := [],expectedClass := -1
    if (SigCubeItemsV147(ctx).Length())
        SigFailV147("HOP: Cube chưa trống trước khi tách")
    SigToCubeV147(ctx,item,cube,true)
    Loop, %count%
    {
        SigCheckV147(ctx)
        if (quantity>=0 && quantity-A_Index<2)
            SigFailV147("HOP: không tách rune xuống dưới 2")
        outputs := SigTransmuteV147(ctx,[item],1,item)
        if (outputs.Length()!=1 || outputs[1].cls=item.cls
            || outputs[1].cls=1204 || (expectedClass>=0 && outputs[1].cls!=expectedClass))
            SigFailV147("HOP: sản phẩm tách không khớp; giữ vật trong Cube")
        expectedClass := outputs[1].cls,retained := false
        for _,a in SigCubeItemsV147(ctx)
            if (a.cls=item.cls && a.q=item.q)
                retained := a
        if (!IsObject(retained))
            SigFailV147("HOP: chưa xác nhận container còn lại sau tách")
        item := retained,record.item := retained
        HopReturnV559(ctx,outputs[1])
        items.Push(HopLiveProductV557(ctx,outputs[1],0))
    }
    if (quantity>=0)
    {
        started := A_TickCount
        while (HopQuantityV557(ctx,item)!=quantity-count)
        {
            if (A_TickCount-started>2500)
                SigFailV147("HOP: số rune còn lại chưa khớp; không tách thêm")
            Sleep, 100
        }
    }
    HopReturnV559(ctx,item,record.invHome)
    record.item := HopLiveV557(ctx,item,0)
    return items
}

HopLiveProductV557(ctx,item,loc)
{
    all := SigSnapshotV147(ctx),live := all[item.uid]
    if (!IsObject(live) || live.cls!=item.cls || live.q!=item.q || live.loc!=loc
        || (loc=0 && live.owner!=ctx.inv) || D2ReadU32(ctx.h,live.unit+0x10)!=0)
        SigFailV147("HOP: chưa xác nhận vật " . item.uid . " trong túi/Cube")
    return live
}

HopPickupV557(ctx,dropPoint)
{
    pickupSerialV754 := CubeResetProofSerialV754()
    HopInfoV557("nhặt nhanh đúng những món đã thả từ Cube")
    started := A_TickCount
    Loop
    {
        SigCheckV147(ctx)
        all := SigSnapshotV147(ctx),pending := 0,ground := false
        for uid,a in ctx.hopDropped
        {
            live := all[uid]
            if (IsObject(live) && live.cls=a.cls && live.q=a.q
                && (live.loc=3 || (live.loc=0 && live.owner=ctx.inv))
                && D2ReadU32(ctx.h,live.unit+0x10)!=3 && D2ReadU32(ctx.h,live.unit+0x10)!=5)
                continue
            pending++
            if (!IsObject(ground))
                ground := SigGroundV147(ctx)
            found := ground[uid]
            if (!IsObject(found))
                continue
            if (found.cls!=a.cls || found.q!=a.q
                || (found.x-dropPoint.x)**2+(found.y-dropPoint.y)**2>225)
                SigFailV147("HOP: món đã thả không khớp vị trí/CLASS UID=" . uid)
            SigPickV147(ctx,found)
        }
        if (!pending)
            break
        if (A_TickCount-started>120000)
            SigFailV147("HOP: vẫn còn " . pending . " món chưa nhặt được; chưa báo Done")
        Sleep, 60
    }
    all := SigSnapshotV147(ctx)
    for uid,a in ctx.hopDropped
        if (!IsObject(all[uid]) || all[uid].cls!=a.cls || all[uid].q!=a.q
            || (all[uid].loc!=0 && all[uid].loc!=3) || (all[uid].loc=0 && all[uid].owner!=ctx.inv)
            || D2ReadU32(ctx.h,all[uid].unit+0x10)=3 || D2ReadU32(ctx.h,all[uid].unit+0x10)=5)
            SigFailV147("HOP: chưa nhặt lại vật đã thả UID=" . uid . "; chưa báo Done")
    CubeResetConfirmV754(ctx.pid,dropPoint.level,ctx.h,ctx.player,pickupSerialV754)
    if (CubeResetPendingV754(ctx.pid))
        SigFailV147("HOP: chưa xác nhận Cube và đồ đã nhặt hết; giữ khóa reset")
}

HopRunV556(total)
{
    global sigBusyV147,sigCancelV147,sigActiveModeV182,sigBackgroundV179,sigSendingKeyV147
    global pickupTimerBusy,xRunning,zRunning,packetWatchArmedV1,buffSequenceOnV555
    global pickupRoundResetV1,sigLastStopReasonV63,coordGoV59
    if (sigBusyV147 || FarmControlRunningV186() || IsObject(coordGoV59) || pickupTimerBusy
        || xRunning || zRunning || packetWatchArmedV1 || buffSequenceOnV555)
    {
        HopInfoV557("dừng farm/buff và chờ thao tác đồ xong rồi bấm lại")
        SetTimer, RemoveToolTip, -3000
        return false
    }
    if (!SigBackgroundBindV179())
        return false
    oldBackground := sigBackgroundV179,sigBackgroundV179 := true
    if (!GameItemActionBeginV4("Cube","cube",true))
    {
        sigBackgroundV179 := oldBackground
        HopInfoV557("chưa xử lý được: có vật trên chuột hoặc thao tác đồ đang chạy")
        SetTimer, RemoveToolTip, -4000
        return false
    }
    sigBusyV147 := true,sigCancelV147 := false,sigActiveModeV182 := "HOP"
    GuiControl, 1:, HopButtonV556, HOP`nStop
    ctx := 0,done := 0,message := "",success := false
    try
    {
        rules := HopRulesV557(),ctx := SigOpenContextV149()
        path := D2ReadU32(ctx.h,ctx.player+0x2C)
        if (!MonsterBossProbeReadV1(ctx.h,path,0x20,pb))
            SigFailV147("HOP: chưa lấy được tọa độ nhân vật")
        level := CoordLevelV14(ctx.h,NumGet(pb,0x1C,"UInt"))
        if (!FarmReviveTownLevelV295(level))
            SigFailV147("HOP: chỉ chạy ở trong thành; không cần tải danh sách tọa độ")
        dropPoint := {x:NumGet(pb,2,"UShort"),y:NumGet(pb,6,"UShort"),level:level}
        ; Kiểm tra trước để không quăng đồ rồi mới biết thành này chưa tải thủ khố.
        stash := CycObjectV42(ctx.h,pb,267)
        if (!IsObject(stash))
            SigFailV147("HOP: chưa thấy thủ khố trong vùng đã tải; hãy đến gần thủ khố")
        cube := HopFindV557(ctx,1204,0)
        if (!IsObject(cube))
            SigFailV147("HOP: không có Cube 1204|02 trong túi")
        ctx.cubeUid := cube.uid,ctx.hopDropped := {}
        for _,a in SigCubeItemsV147(ctx)
            ctx.hopDropped[a.uid] := a
        ; Quăng Cube ngay tại vị trí đứng ở bất kỳ thành nào, nhặt lại Cube trống.
        HopInfoV557("quăng Cube và lấy lại Cube trống tại chỗ")
        SigCubeDropPickupV280(ctx,cube)
        if (SigCubeItemsV147(ctx).Length())
            SigFailV147("HOP: Cube nhặt lại chưa trống")
        cube := HopLiveV557(ctx,cube,0)
        ; Nếu thủ khố ở xa thì tự đến gần, không dùng map/tọa độ đã lưu.
        dist := Sqrt((stash.x-dropPoint.x)**2+(stash.y-dropPoint.y)**2)
        if (dist>15)
        {
            approach := {x:Round(stash.x+(dropPoint.x-stash.x)*6/dist)
                ,y:Round(stash.y+(dropPoint.y-stash.y)*6/dist),level:level}
            HopMoveV557(ctx,approach,"thủ khố")
        }
        HopGridInitV559(ctx)
        used := {}
        for _,runeClass in rules
        {
            Loop
            {
                if (done>=total)
                    break
                HopOpenStashV557(ctx)
                rune := HopFindV557(ctx,runeClass,4,used)
                if (!IsObject(rune))
                    break
                used[rune.uid] := true,quantity := HopQuantityV557(ctx,rune)
                if (quantity<=2)
                    continue
                second := HopFindV557(ctx,2439,4)
                if (!IsObject(second))
                    SigFailV147("HOP: thiếu container 2439|02 trong thủ khố")
                batch := Min(total-done,quantity-2)
                HopInfoV557("lấy 2 container; rune " . runeClass . " có " . quantity . ", tách " . batch . ", chừa 2")
                runeRecord := HopStashTakeV557(ctx,rune)
                secondRecord := HopStashTakeV557(ctx,second)
                HopCloseV557(ctx)
                one := HopSplitV557(ctx,cube,runeRecord,batch,quantity)
                two := HopSplitV557(ctx,cube,secondRecord,batch)
                HopOpenStashV557(ctx)
                HopStashPutV557(ctx,runeRecord)
                HopStashPutV557(ctx,secondRecord)
                HopCloseV557(ctx)
                cluster := HopFindV557(ctx,1733,0),clusterRecord := false
                if (!IsObject(cluster))
                {
                    HopOpenStashV557(ctx)
                    cluster := HopFindV557(ctx,1733,4)
                    if (!IsObject(cluster))
                        SigFailV147("HOP: thiếu Arcane Cluster 1733|02 trong túi/thủ khố")
                    clusterRecord := HopStashTakeV557(ctx,cluster)
                    HopCloseV557(ctx)
                }
                else
                {
                    if (!ctx.hopGridV559.items.HasKey(cluster.uid))
                        SigFailV147("HOP: chưa nhớ vị trí Arcane Cluster trong túi")
                    clusterRecord := {item:cluster,invHome:ctx.hopGridV559.items[cluster.uid]}
                }
                HopInfoV557("tách " . batch . " Arcane Crystal")
                three := HopSplitV557(ctx,cube,clusterRecord,batch)
                if (IsObject(clusterRecord.home))
                {
                    HopStashPutV557(ctx,clusterRecord)
                    HopCloseV557(ctx)
                }
                Loop, %batch%
                {
                    i := A_Index
                    a := HopLiveProductV557(ctx,one[i],0),b := HopLiveProductV557(ctx,two[i],0)
                    c := HopLiveProductV557(ctx,three[i],0)
                    if (a.uid=b.uid || b.uid=c.uid || a.uid=c.uid
                        || a.cls=b.cls || b.cls=c.cls || a.cls=c.cls)
                        SigFailV147("HOP: ba loại nguyên liệu không riêng biệt")
                    SigToCubeV147(ctx,a,cube,true)
                    SigToCubeV147(ctx,b,cube,true)
                    SigToCubeV147(ctx,c,cube,true)
                    products := SigTransmuteV147(ctx,[a,b,c],1)
                    if (products.Length()!=1 || products[1].cls=a.cls || products[1].cls=b.cls
                        || products[1].cls=c.cls || products[1].cls=1204)
                        SigFailV147("HOP: sản phẩm ghép không khớp; giữ trong Cube")
                    HopProductReturnV559(ctx,products[1],[a,b,c])
                    HopLiveProductV557(ctx,products[1],0)
                    done++
                    HopInfoV557("đã ghép " . done . "/" . total)
                }
            }
            if (done>=total)
                break
        }
        HopCloseV557(ctx)
        path := D2ReadU32(ctx.h,ctx.player+0x2C)
        if (!MonsterBossProbeReadV1(ctx.h,path,0x20,pb))
            SigFailV147("HOP: chưa lấy được tọa độ để trở lại điểm nhặt")
        if ((NumGet(pb,2,"UShort")-dropPoint.x)**2+(NumGet(pb,6,"UShort")-dropPoint.y)**2>1)
            HopMoveV557(ctx,dropPoint,"nhặt đồ")
        HopPickupV557(ctx,dropPoint)
        success := done=total
        message := success ? "Done — " . done . "/" . total . ", đã nhặt lại đồ."
            : "Đã ghép " . done . "/" . total . "; hết rune dùng được trong Rune.txt, đã nhặt lại đồ."
    }
    catch e
        message := "Dừng " . done . "/" . total . ": " . e.Message
    finally
    {
        if (IsObject(ctx))
            DllCall("CloseHandle","Ptr",ctx.h)
        sigBusyV147 := false,sigSendingKeyV147 := false,sigActiveModeV182 := ""
        sigBackgroundV179 := oldBackground,pickupRoundResetV1 := true
        GameItemActionEndV4("Cube")
        GuiControl, 1:, HopButtonV556, HOP
    }
    HopInfoV557(message)
    SetTimer, RemoveToolTip, -7000
    return success
}

FarmBOButtonV413:
roomMapLastButtonV22 := "BO"
if (farmControlOwnerV186="BO" && (FarmControlRunningV186() || farmUserPausedV2026))
{
    FarmUserPauseToggleV2026("BO")
    return
}
farmBOButtonDispatchV413 := true
try
    Gosub, MapControlButtonV168
finally
    farmBOButtonDispatchV413 := false
return

BOEntryArmV413(hwnd)
{
    global
    local level,section,firstFarm,finalFarm,stage
    if (!BackgroundBindV63(hwnd))
        return false
    level := FarmCurrentLevelV143()
    if (!level)
        return false
    PickupCtrlEndV26()
    PickupAutoGroupsRefreshV7()
    section := ProfileSection(currentProfile)
    IniRead, firstFarm, % ProfileConfigPathV364(section), %section%, BOFarmLevel2, 0
    IniRead, finalFarm, % ProfileConfigPathV364(section), %section%, BOFarmLevel4, 0
    stage := !FarmReviveTownLevelV295(level) && level=finalFarm && finalFarm ? 4
        : !FarmReviveTownLevelV295(level) && level=firstFarm && firstFarm ? 2 : 1
    scosEntryV162 := {map:"BO",pid:backgroundPidV63,until:A_TickCount+3600000
        ,phase:stage=1 ? "CUBE" : "LOAD",boStageV413:stage,pickup:pickupImageOn,row:1,last:0}
    if (stage!=4)
        BOCoordinateOffV471()
    boStartRSentV417 := GameTargetKeyV63("{r}")
    PortalLogWriteV66("BO_START fon=OFF key=R presses=1 queued=" . boStartRSentV417)
    PickupEnabledSetV71(false,true,false)
    cainPauseFarmV361 := true
    SetTimer, ScosEntryTimerV162, 250
    return true
}

BOFindMaterialV413(ctx,wanted,oldIds := false)
{
    all := SigSnapshotV147(ctx)
    for uid,a in all
        if (a.cls=wanted && a.q=7 && (a.loc=0 || a.loc=3)
            && (!IsObject(oldIds) || !oldIds.HasKey(uid)))
            return a
    for uid,a in SigGroundV147(ctx)
        if (a.cls=wanted && a.q=7 && (!IsObject(oldIds) || !oldIds.HasKey(uid)))
            return a
    return false
}

BOCombinedSigV459(ctx,cube)
{
    global sigBusyV147,sigActiveModeV182,sigTUV586,sigSUV510,sigSSUV13,sigSSSUV13
    rV467 := ctx.entryStateV42
    if (!ctx.boSigBeforeCubeV461 || !IsObject(rV467)
        || rV467.boStageV413!=1 || rV467.boStartSigAttemptedV467)
        return true
    rV467.boStartSigAttemptedV467 := true
    oldBusyV459 := sigBusyV147,oldModeV459 := sigActiveModeV182
    sigBusyV147 := true,sigActiveModeV182 := "SET_SU"
    ctx.boCombinedSigV459 := true
    try
    {
        if (!SetNoSigLoadV227(ctx))
            SigFailV147("Không đọc được danh sách Set không SIG")
        GuiControlGet, sigTUV586, 1:, SigTUInputV586
GuiControlGet, sigSUV510, 1:, SigSUInputV510
        GuiControlGet, sigSSUV13, 1:, SigSSUInputV13
        SigReserveReagentHomesV192(ctx)
        PortalLogWriteV66("BO_COMBINED_SIG_BEGIN cube_uid=" . cube.uid . " drop=ALREADY_DONE pickup=DEFER_UNTIL_PORTAL")
        SigGroupVerifiedV16(ctx,cube,5)
        SigGroupVerifiedV16(ctx,cube,7)
        for _,itemV459 in SigCubeItemsV147(ctx)
        {
            SigCheckV147(ctx)
            SigReturnV147(ctx,itemV459)
        }
        SigSortContainerV191(ctx)
        SigCheckV147(ctx)
        PortalLogWriteV66("BO_COMBINED_SIG_DONE sort=OK pickup_calls=0 next=PORTAL_MATERIAL_TO_CUBE")
        return true
    }
    finally
    {
        ctx.boCombinedSigV459 := false
        sigBusyV147 := oldBusyV459,sigActiveModeV182 := oldModeV459
    }
}

BOCubePortalV413(r,level)
{
    global
    if (pickupTimerBusy || sigBusyV147 || xRunning || zRunning || gameItemActionOwner!="")
        return false
    if (r.boStageV413=3 && !BossSearchHoldReadyV436(r.pid,level))
        return false
    local oldPickupV575 := pickupImageOn
    if (!GameItemActionBeginV4("BOCube","cube",true))
        return false
    PickupEnabledSetV71(false,true,false)
    local ctx := false,oldBg := sigBackgroundV179,cube := false,a,uid,all,material,path,pb,bytes,exits
    sigBackgroundV179 := true,sigCancelV147 := false
    try
    {
        ctx := SigOpenContextV149()
        ctx.scosEntry := true,ctx.entryStateV42 := r
        ctx.boSigBeforeCubeV461 := false
        SigSortContainerV191(ctx)
        SigCheckV147(ctx)
        PortalLogWriteV66("BO_PRE_CUBE_SORT stage=" . r.boStageV413 . " next=FIND_MATERIAL_THEN_DROP_PICKUP_CUBE")
        material := BOFindMaterialV413(ctx,r.boStageV413=1 ? 8 : 668)
        if (!IsObject(material))
            throw Exception("Không thấy vật liệu " . (r.boStageV413=1 ? "8/07" : "668/07 trong rương, cube hoặc dưới đất"))
        if (r.boStageV413=1)
        {
            if (material.loc=-1)
                SigPickV147(ctx,material)
            else if (material.loc=3)
                SigReturnV147(ctx,material)
            Ticket130ReserveV265(ctx,material)
            r.boFirstMaterialUidV475 := material.uid
            r.boFirstMaterialHomeV475 := ctx.returnHomesV265[material.uid]
            PortalLogWriteV66("BO_FIRST_MATERIAL_KEEP_INVENTORY uid=" . material.uid
                . " home=" . r.boFirstMaterialHomeV475.x . "," . r.boFirstMaterialHomeV475.y . " cube_drop=EXCLUDED")
        }
        all := SigSnapshotV147(ctx)
        for uid,a in all
            if (a.cls=1204 && a.loc=0 && a.owner=ctx.inv)
                cube := a
        if (!IsObject(cube))
            throw Exception("Không thấy cube trong rương")
        ctx.cubeUid := cube.uid
        if (SigCubeItemsV147(ctx).Length())
            SigCubeDropPickupV280(ctx,cube)
        if (SigCubeItemsV147(ctx).Length())
            throw Exception("Cube nhặt lại chưa trống")
        SigCheckV147(ctx)
        if (SigCubeItemsV147(ctx).Length())
            throw Exception("Cube còn đồ sau SIG; chưa mở cổng")
        material := BOFindMaterialV413(ctx,r.boStageV413=1 ? 8 : 668)
        if (!IsObject(material))
            throw Exception("Không thấy vật phẩm mở cổng sau SIG/Sort")
        if (r.boStageV413=1)
        {
            all := SigSnapshotV147(ctx)
            material := all[r.boFirstMaterialUidV475]
            if (!IsObject(material) || material.loc!=0 || material.owner!=ctx.inv)
                throw Exception("Vật mở cổng 1 không còn trong rương; không lấy vật khác thay thế")
            Ticket130ReserveV265(ctx,material)
            r.boFirstMaterialHomeV475 := ctx.returnHomesV265[material.uid]
            PortalLogWriteV66("BO_FIRST_MATERIAL_HOME uid=" . material.uid
                . " xy=" . r.boFirstMaterialHomeV475.x . "," . r.boFirstMaterialHomeV475.y
                . " size=" . r.boFirstMaterialHomeV475.w . "x" . r.boFirstMaterialHomeV475.h)
        }
        SigToCubeV147(ctx,material,cube,true)
        path := D2ReadU32(ctx.h,ctx.player+0x2C)
        if (!MonsterBossProbeReadV1(ctx.h,path,0x20,pb))
            throw Exception("Không đọc được vị trí trước khi cube")
        r.oldPortalsV413 := {}
        r.boPortalMaterialUidV469 := material.uid
        r.boCubeX_V469 := NumGet(pb,2,"UShort"),r.boCubeY_V469 := NumGet(pb,6,"UShort")
        exits := ScanExitObjectsV363(ctx.h,pb,NumGet(pb,2,"UShort"),NumGet(pb,6,"UShort"))
        for _,a in exits
            r.oldPortalsV413[a.typ . "|" . a.uid] := true
        bytes := [0x20],SigDwordV147(bytes,cube.uid)
        SigDwordV147(bytes,NumGet(pb,2,"UShort")),SigDwordV147(bytes,NumGet(pb,6,"UShort"))
        sourceRoom2V427 := D2ReadU32(ctx.h,NumGet(pb,0x1C,"UInt")+0x10)
        r.fromLevelPtrV427 := sourceRoom2V427 ? D2ReadU32(ctx.h,sourceRoom2V427+0x58) : 0
        r.fromLevelV413 := level,r.boCubeAttemptV487 := true
        r.boReturnCubeUidV477 := cube.uid,r.boTransmuteAtV477 := A_TickCount
        r.portalAtV413 := A_TickCount,r.enterAtV413 := 0
        r.boPickupDoneV413 := false,r.boPortalPickupStartedV468 := 0
        r.boEntranceV483 := false,r.boPortalPickupBackgroundSavedV483 := false
        SigPacketV147(ctx,bytes)
        r.boPortalPendingV487 := true
        r.phase := r.boStageV413=1 ? "RETURN_MATERIAL" : "PORTAL"
        sigCubeUiOpenV159 := true
        Sleep, 250
        SigCheckV147(ctx)
        SigPacketV147(ctx,[0x4F,0x18,0,0,0,0,0])
        SigCloseCubeV156()
        PortalLogWriteV66("BO_CUBE stage=" . r.boStageV413 . " material_class=" . material.cls . " live_uid=" . material.uid . " next=PICKUP_NEW_PORTAL")
    }
    finally
    {
        if (IsObject(ctx))
            DllCall("CloseHandle","Ptr",ctx.h)
        sigBackgroundV179 := oldBg
        GameItemActionEndV4("BOCube")
        if (!sigCancelV147)
            PickupEnabledSetV71(oldPickupV575,true,false)
    }
    return true
}

BOReturnFirstMaterialV477(r,ByRef pb,level,px,py)
{
    global sigBackgroundV179,scosEntryV162,pickupTimerBusy,sigBusyV147,sigCubeUiOpenV159
    if (pickupTimerBusy || sigBusyV147 || A_TickCount-r.boTransmuteAtV477<250)
        return false
    if (!GameItemActionBeginV4("BOReturnMaterial","cube"))
        return false
    ctx := false,previousBgV477 := sigBackgroundV179
    sigBackgroundV179 := true
    try
    {
        ctx := SigOpenContextV149()
        ctx.scosEntry := true,ctx.entryStateV42 := r,ctx.cubeUid := r.boReturnCubeUidV477
        livePathV478 := D2ReadU32(ctx.h,ctx.player+0x2C)
        if (!MonsterBossProbeReadV1(ctx.h,livePathV478,0x20,livePBV478)
            || CoordLevelV14(ctx.h,NumGet(livePBV478,0x1C,"UInt"))!=level)
            return false
        portalReadyV477 := false
        exitsV478 := ScanExitObjectsV363(ctx.h,livePBV478,NumGet(livePBV478,2,"UShort"),NumGet(livePBV478,6,"UShort"))
        for _,exitV477 in exitsV478
            if (!r.oldPortalsV413.HasKey(exitV477.typ . "|" . exitV477.uid)
                && (exitV477.typ=5 || exitV477.cls=59 || exitV477.cls=60))
            {
                portalReadyV477 := true
                break
            }
        if (!portalReadyV477)
        {
            PortalLogWriteV66("BO_RETURN_MATERIAL_WAIT reason=PORTAL_NOT_CONFIRMED objects=" . exitsV478.Length()
                . " room1=" . V92Hex(NumGet(livePBV478,0x1C,"UInt")) . " recube=OFF","BO_RETURN_MATERIAL_WAIT",1000)
            return false
        }
        ctx.returnHomesV265 := {}
        ctx.returnHomesV265[r.boFirstMaterialUidV475] := r.boFirstMaterialHomeV475
        allV477 := SigSnapshotV147(ctx),liveV477 := allV477[r.boFirstMaterialUidV475]
        cursorV477 := PickupCursorV4(ctx.h,ctx.inv)
        ownCursorV477 := IsObject(cursorV477) && cursorV477.unit && cursorV477.uid=r.boFirstMaterialUidV475
        if (IsObject(cursorV477) && cursorV477.unit && !ownCursorV477)
            return false
        if (ownCursorV477)
            liveV477 := cursorV477
        if (!ownCursorV477 && !(IsObject(liveV477) && liveV477.loc=0 && liveV477.owner=ctx.inv))
        {
            foundV477 := false
            for _,itemV477 in SigCubeItemsV147(ctx)
                if (itemV477.cls=8 && itemV477.q=7)
                    foundV477 := true
            if (!foundV477)
            {
                PortalLogWriteV66("BO_RETURN_MATERIAL_WAIT reason=LIVE_ITEM_NOT_READY recube=OFF","BO_RETURN_MATERIAL_WAIT",1000)
                return false
            }
            liveV477 := Ticket130RetainedV266(ctx,{uid:r.boFirstMaterialUidV475,cls:8,q:7})
            r.boFirstMaterialUidV475 := liveV477.uid
            r.boFirstMaterialHomeV475 := ctx.returnHomesV265[liveV477.uid]
        }
        if (!ownCursorV477 && liveV477.loc=3)
            sigCubeUiOpenV159 := true
        SigReturnV147(ctx,liveV477)
        SigCloseCubeV156()
        if (scosEntryV162!=r)
            return false
        r.phase := "PORTAL",r.portalAtV413 := A_TickCount
        PortalLogWriteV66("BO_FIRST_MATERIAL_RETURNED uid=" . liveV477.uid
            . " home=" . r.boFirstMaterialHomeV475.x . "," . r.boFirstMaterialHomeV475.y
            . " size=" . r.boFirstMaterialHomeV475.w . "x" . r.boFirstMaterialHomeV475.h
            . " method=VE139_RETAINED_HOME next=PICKUP_THEN_ENTER")
        return true
    }
    finally
    {
        if (IsObject(ctx))
            DllCall("CloseHandle","Ptr",ctx.h)
        sigBackgroundV179 := previousBgV477
        GameItemActionEndV4("BOReturnMaterial")
    }
}

BOEntranceFindV483(r,exits)
{
    pinned := r.boEntranceV483,best := false,bestDist := 1.0e30
    for _,a in exits
    {
        if (IsObject(pinned))
        {
            if (a.uid=pinned.uid && a.typ=pinned.typ && a.cls=pinned.cls)
            {
                r.boEntranceV483 := a
                return a
            }
            continue
        }
        if (r.oldPortalsV413.HasKey(a.typ . "|" . a.uid)
            || !(a.typ=5 || a.cls=59 || a.cls=60))
            continue
        dist := (a.x-r.boCubeX_V469)**2+(a.y-r.boCubeY_V469)**2
        if (dist<bestDist)
            best := a,bestDist := dist
    }
    if (IsObject(best))
    {
        r.boEntranceV483 := best
        PortalLogWriteV66("BO_PORTAL_PIN uid=" . best.uid . " type=" . best.typ
            . " xy=" . best.x . "," . best.y . " pending=UNTIL_CONFIRMED_TRANSFER")
    }
    return best
}

BOPortalCombatTickV483(r,ctx,player,ByRef pb)
{
    global stage2FlowV380,pickupTimerBusy,gameItemActionOwner
    if (r.boStageV413!=3 || pickupTimerBusy || gameItemActionOwner!="")
        return false
    if (!AutoMonsterPacketCleanupV1())
        return true
    s := IsObject(stage2FlowV380) ? stage2FlowV380.searchV430 : false
    if (!IsObject(s) || !BossSearchActiveV430(r.pid,r.fromLevelV413))
        return false
    scan := BossSearchScanV430(ctx.h,pb,s)
    if (!scan.known)
        return true
    radius := Max(1,MonsterRadiusGetV239()),target := false
    for _,a in scan.allV431
    {
        if (a.dist>radius*radius || (s.retryUIDs.HasKey(a.uid) && A_TickCount<s.retryUIDs[a.uid])
            || MonsterRetryExcludedV44(a.uid,a.x,a.y,a.level,r.pid))
            continue
        if (!IsObject(target) || a.dist<target.dist)
            target := a
    }
    if (!IsObject(target))
        return false
    r.stage1StuckV384 := false,r.last := 0
    mode := D2ReadU32(ctx.h,player+0x10)
    s.walkingV482 := mode=2 || mode=3 || mode=6
    if (!BOCombatStopWalkV482(ctx.h,player,pb,s))
        BossSearchHoldAttackV436(ctx.h,player,pb,s,target)
    PortalLogWriteV66("BO_PORTAL_COMBAT uid=" . target.uid . " distance=" . Round(Sqrt(target.dist),2)
        . " phase=PORTAL pending=KEPT next=RESUME_SAME_ENTRANCE","BO_PORTAL_COMBAT",1000)
    return true
}

BOConsumedPortalTransferV487(r,ctx,ByRef pb,level)
{
    global scosEntryV162,farmControlOwnerV186,ticketPickupWaitV279,pickupBackgroundV181
    if (scosEntryV162!=r || (r.boStageV413!=1 && r.boStageV413!=3)
        || !r.boCubeAttemptV487 || !r.fromLevelV413 || !level || FarmReviveTownLevelV295(level))
        return false
    room2 := D2ReadU32(ctx.h,NumGet(pb,0x1C,"UInt")+0x10)
    levelPtr := room2 ? D2ReadU32(ctx.h,room2+0x58) : 0
    if (level=r.fromLevelV413 && (!r.enterAtV413 || !r.fromLevelPtrV427 || !levelPtr || levelPtr=r.fromLevelPtrV427))
        return false
    previous := r.boStageV413
    r.boCubeConsumedV487 := true,r.boPortalPendingV487 := false,r.boCubeAttemptV487 := false
    r.boStageV413 := previous=1 ? 2 : 4
    r.phase := "EXIT_PORTAL",r.buffDoneV413 := false,r.boRouteReadyV419 := false
    r.boExitPortalV500 := false
    if (previous=1 || previous=3)
    {
        offsetV500 := Round(20/Sqrt(2))
        r.boExitPortalV500 := {level:level,x:NumGet(pb,2,"UShort")-offsetV500
            ,y:NumGet(pb,6,"UShort")-offsetV500,at:0}
        r.enterAtV413 := 0
        PortalLogWriteV66("BO_EXIT_PORTAL stage=" . r.boStageV413 . " target=" . r.boExitPortalV500.x . "," . r.boExitPortalV500.y
            . " direction=SCREEN_UP distance=20 next=WALK_THEN_BUFF")
    }
    if (r.boStageV413=4 && FarmFinalEntryPreparedV718(r,r.pid,level))
    {
        r.phase := "LOAD",r.buffDoneV413 := true,r.boExitPortalV500 := false
        PortalLogWriteV66("BO_FINAL_ENTRY buff=PREPARED_BEFORE_PORTAL next=FARM_NO_ARRIVAL_BUFF")
    }
    r.retryAtV237 := 0,r.errorTextV463 := "",r.errorAtV463 := 0,r.until := A_TickCount+3600000
    if (r.boPortalPickupBackgroundSavedV483)
        pickupBackgroundV181 := r.boPortalPickupBackgroundV468
    ticketPickupWaitV279 := false
    farmControlOwnerV186 := "BO"
    PickupEnabledSetV71(false,true,false)
    BOFarmMapRememberV417(r.boStageV413,level)
    FonInfoPushV385("[BO GĐ" . r.boStageV413 . "] Đã vào map " . level . " — cổng GĐ" . previous . " đã sử dụng")
    PortalLogWriteV66("BO_PORTAL_TRANSFER from=" . r.fromLevelV413 . " to=" . level
        . " completed_stage=" . previous . " next_stage=" . r.boStageV413 . " phase=" . r.phase . " material_check=OFF recube=0")
    return true
}

BOEntryTickV413(r,ctx,player,ByRef pb,level,px,py)
{
    global
    local target := false,a,all,uid,wanted,exitsV469,waitV468,sentV468,liveRoom2V427,liveLevelPtrV427
    if (level && scosEntryV162=r && BOConsumedPortalTransferV487(r,ctx,pb,level))
        return
    if (!level || scosEntryV162!=r || xRunning || zRunning || packetWatchArmedV1 || (gameItemActionOwner!="" && !(r.phase="PORTAL" && gameItemActionOwner="Pickup")))
        return
    if (r.phase="EXIT_PORTAL")
    {
        cainPauseFarmV361 := true
        exitV500 := r.boExitPortalV500
        if (!IsObject(exitV500) || level!=exitV500.level || !AutoMonsterPacketCleanupV1())
            return
        if ((px-exitV500.x)**2+(py-exitV500.y)**2>4)
        {
            if (!exitV500.at || A_TickCount-exitV500.at>=250)
            {
                sentV500 := NativeMovePointV14(r.pid,exitV500.x,exitV500.y,level,false,false,true,false,{entry:r})
                exitV500.at := A_TickCount
                PortalLogWriteV66("BO_EXIT_WALK stage=" . r.boStageV413 . " target=" . exitV500.x . "," . exitV500.y . " sent=" . sentV500
                    . " buff=WAIT portal_interact=OFF","BO_EXIT_WALK",1000)
            }
            return
        }
        modeV500 := D2ReadU32(ctx.h,player+0x10)
        if (modeV500=2 || modeV500=3 || modeV500=6)
        {
            NativeMovePointV14(r.pid,px,py,level,false,false,true,false,{entry:r,stop:true})
            return
        }
        if (modeV500!=1 && modeV500!=5)
            return
        r.phase := "LOAD",r.boArrivalXV472 := px,r.boArrivalYV472 := py
        r.stage1StuckV384 := false,r.last := 0
        PortalLogWriteV66("BO_EXIT_DONE stage=" . r.boStageV413 . " xy=" . px . "," . py . " next=BUFF_THEN_FARM portal_interact=OFF")
        return
    }
    if (r.phase="RETURN_MATERIAL")
    {
        BOReturnFirstMaterialV477(r,pb,level,px,py)
        return
    }
    if (r.phase="RECREATE")
    {
        PickupEnabledSetV71(false,true,false)
        FarmCastSyncV88(false)
        if (!AutoMonsterPacketCleanupV1() || pickupTimerBusy || sigBusyV147)
            return
        farmRestartReasonV238 := "COMPLETE"
        if (!StageTwoArmV166(true))
            return
        stageTwoV166.restartRunV17 := true
        if (!IsObject(mapWorkflowV185))
            mapWorkflowV185 := {map:"BO",stage:3,startLevel:level,testRows:0}
        MapStageSetV185(3)
        scosEntryV162 := false
        SetTimer, ScosEntryTimerV162, Off
        PortalLogWriteV66("BO_EXISTING_PORTAL_STAGE3 next=SAVE_EXIT_CREATE_RESTART_BO")
        return
    }
    if (r.phase="CUBE")
    {
        if (r.boCubeAttemptV487 && IsObject(r.oldPortalsV413))
        {
            target := BOEntranceFindV483(r,ScanExitObjectsV363(ctx.h,pb,px,py))
            if (r.boPortalPendingV487 || IsObject(target))
            {
                r.boPortalPendingV487 := true,r.phase := "PORTAL"
                PortalLogWriteV66("BO_CUBE_ALREADY_USED stage=" . r.boStageV413 . " next=ENTER_EXISTING_PORTAL recube=0")
                return
            }
        }
        cainPauseFarmV361 := true
        FarmCastSyncV88(false)
        if (r.boStageV413=1)
        {
            for _,a in ScanExitObjectsV363(ctx.h,pb,px,py)
                if (a.typ=2 && a.cls=60)
                {
                    r.phase := "RECREATE"
                    PortalLogWriteV66("BO_EXISTING_PORTAL_BEFORE_CUBE uid=" . a.uid
                        . " cube=SKIP enter=SKIP next=STAGE3_NEW_GAME")
                    return
                }
        }
        if (r.boStageV413=1)
        {
            if (!MapStage1SigReadyV374(r))
                return
            r.boStartSigAttemptedV467 := true
        }
        if (AutoMonsterPacketCleanupV1())
            BOCubePortalV413(r,level)
        return
    }
    if (r.phase="PORTAL")
    {
        liveRoom2V427 := D2ReadU32(ctx.h,NumGet(pb,0x1C,"UInt")+0x10)
        liveLevelPtrV427 := liveRoom2V427 ? D2ReadU32(ctx.h,liveRoom2V427+0x58) : 0
        r.until := Max(r.until,A_TickCount+60000)
        if (level!=r.fromLevelV413)
        {
            PortalLogWriteV66("BO_PORTAL_PENDING reason=OTHER_MAP_WITHOUT_CONFIRMED_ENTRANCE level=" . level
                . " source=" . r.fromLevelV413 . " stage=KEPT","BO_PORTAL_PENDING",1000)
            return
        }
        exitsV469 := ScanExitObjectsV363(ctx.h,pb,px,py)
        target := BOEntranceFindV483(r,exitsV469)
        if (BOPortalCombatTickV483(r,ctx,player,pb))
            return
        if ((!r.boPortalPickupStartedV468 || r.boPickupDoneV413) && A_TickCount-r.portalAtV413>45000)
        {
            r.portalAtV413 := A_TickCount
            PortalLogWriteV66("BO_PORTAL_PENDING reason=ENTER_DELAY stage=KEPT next=RETRY_SAME_ENTRANCE","BO_PORTAL_PENDING",1000)
        }
        if (!r.boPickupDoneV413)
        {
            if (!r.boPortalPickupStartedV468 || !IsObject(ticketPickupWaitV279)
                || ticketPickupWaitV279.pid!=r.pid || ticketPickupWaitV279.level!=level)
            {
                r.boPortalPickupStartedV468 := A_TickCount
                ticketPickupWaitV279 := {pid:r.pid,level:level,checks:0,emptyAt:0,done:false,scanAt:0,remaining:-1,active:true,resetProtectedV754:true,dropSerialV754:CubeResetProofSerialV754()}
                if (!pickupTimerBusy)
                    pickupRoundResetV1 := true
                if (!r.boPortalPickupBackgroundSavedV483)
                {
                    r.boPortalPickupBackgroundV468 := pickupBackgroundV181
                    r.boPortalPickupBackgroundSavedV483 := true
                }
                pickupBackgroundV181 := true
                if (!pickupImageOn)
                    PickupEnabledSetV71(true,true,false)
                PortalLogWriteV66("BO_PORTAL_PICKUP_BEGIN mode=ENTRY_SINGLE_TICK next=WAIT_FRESH_EMPTY_SCAN")
                return
            }
            if (!pickupImageOn)
            {
                PickupEnabledSetV71(true,true,false)
                pickupRoundResetV1 := true
                ticketPickupWaitV279 := {pid:r.pid,level:level,checks:0,emptyAt:0,done:false,scanAt:0,remaining:-1,active:true,resetProtectedV754:true,dropSerialV754:CubeResetProofSerialV754()}
                PortalLogWriteV66("BO_PORTAL_PICKUP_RESUME stage=KEPT next=FRESH_PICKUP_SCAN")
                return
            }
            if (!pickupTimerBusy && gameItemActionOwner="" && GameItemActionBeginV4("Pickup","cube"))
            {
                pickupTimerBusy := true
                try
                    PickupV61Tick()
                finally
                {
                    pickupTimerBusy := false
                    GameItemActionEndV4("Pickup")
                }
            }
            waitV468 := ticketPickupWaitV279
            if (IsObject(waitV468) && waitV468.pid=r.pid && waitV468.level=level
                && waitV468.done && !pickupTimerBusy && A_TickCount-waitV468.scanAt<1000)
            {
                if (!CubeResetVerifiedV754(r.pid,level,waitV468.dropSerialV754))
                    return
                r.boPickupDoneV413 := true,r.portalAtV413 := A_TickCount
                PickupEnabledSetV71(false,true,false)
                pickupBackgroundV181 := r.boPortalPickupBackgroundV468
                ticketPickupWaitV279 := false
                PortalLogWriteV66("BO_PORTAL_PICKUP_DONE next=FIND_ENTRANCE")
                return
            }
            PortalLogWriteV66("BO_PORTAL_PICKUP_WAIT remaining=" . waitV468.remaining
                . " checks=" . waitV468.checks . " reason=" . waitV468.blockReasonV468
                . " pickup_on=" . pickupImageOn . " busy=" . pickupTimerBusy,"BO_PORTAL_PICKUP_WAIT",1000)
            if (A_TickCount-r.boPortalPickupStartedV468>120000)
            {
                r.boPortalPickupStartedV468 := A_TickCount
                PortalLogWriteV66("BO_PORTAL_PENDING reason=PICKUP_DELAY detail=" . waitV468.blockReasonV468
                    . " stage=KEPT next=CONTINUE_PICKUP_THEN_ENTER","BO_PORTAL_PENDING",1000)
            }
            return
        }
        if (pickupTimerBusy || gameItemActionOwner!="")
            return
        exitsV469 := ScanExitObjectsV363(ctx.h,pb,px,py)
        target := BOEntranceFindV483(r,exitsV469)
        if (!IsObject(target))
        {
            if (IsObject(r.boEntranceV483))
            {
                ScosEntryMoveV162(ctx,r.boEntranceV483.x,r.boEntranceV483.y)
                PortalLogWriteV66("BO_PORTAL_PENDING reason=ENTRANCE_TEMPORARILY_UNLOADED uid=" . r.boEntranceV483.uid
                    . " next=RETURN_TO_SAVED_ENTRANCE","BO_PORTAL_PENDING",1000)
            }
            else
                PortalLogWriteV66("BO_PORTAL_WAIT reason=NO_ENTRANCE objects=" . exitsV469.Length() . " pickup=DONE stage=KEPT","BO_PORTAL_WAIT",1000)
            return
        }
        if ((px-target.x)**2+(py-target.y)**2>100)
        {
            ScosEntryMoveV162(ctx,target.x,target.y)
            return
        }
        modeV499 := D2ReadU32(ctx.h,player+0x10)
        if (modeV499=2 || modeV499=3 || modeV499=6)
        {
            stoppedV499 := NativeMovePointV14(r.pid,px,py,level,false,false,true,false,{entry:r,stop:true})
            PortalLogWriteV66("BO_PORTAL_STOP_WALK uid=" . target.uid . " sent=" . stoppedV499 . " next=INTERACT_SAME_ENTRANCE","BO_PORTAL_STOP_WALK",1000)
            return
        }
        if (modeV499!=1 && modeV499!=5)
        {
            PortalLogWriteV66("BO_PORTAL_WAIT reason=PLAYER_BUSY mode=" . modeV499 . " stage=KEPT","BO_PORTAL_BUSY",1000)
            return
        }
        if (!r.enterAtV413 || A_TickCount-r.enterAtV413>=1500)
        {
            sentV468 := EnterPortalInteractV363(r.pid,level,target)
            PortalLogWriteV66("BO_PORTAL_ENTER uid=" . target.uid . " queued=" . sentV468,"BO_PORTAL_ENTER",1000)
            if (sentV468)
                r.enterAtV413 := A_TickCount
        }
        return
    }
    if (r.phase="LOAD")
    {
        cainPauseFarmV361 := true
        if (!IsObject(MapLiveIdentityV399(r.pid,level)))
        {
            MapLoadFailedStopV397("BO_LIVE_ROOM_READ_FAILED")
            return
        }
        if (scosEntryV162!=r)
            return
        if (r.boStageV413=4 && IsObject(stage2FlowV380))
            stage2FlowV380.searchV430 := false
        if (r.boStageV413!=4)
            r.boRouteReadyV419 := true
        if (!r.buffDoneV413)
        {
            PortalLogWriteV66("BO_BUFF_POSITION stage=" . r.boStageV413 . " current=" . px . "," . py
                . " arrival=" . r.boArrivalXV472 . "," . r.boArrivalYV472 . " movement=BLOCKED","BO_BUFF_POSITION",1000)
            if (!RouteBuffSequenceV20(ctx.h,player,r.pid,true))
            {
                PortalLogWriteV66("BO_BUFF_WAIT stage=" . r.boStageV413 . " level=" . level
                    . " route_ready=1 farm=OFF","BO_BUFF_WAIT",1000)
                return
            }
            if (scosEntryV162!=r || cainPausedV10)
                return
            r.buffDoneV413 := true
            PortalLogWriteV66("BO_BUFF_DONE stage=" . r.boStageV413 . " next=FARM_ITEM")
        }
        if (r.boStageV413=4 && !r.boRouteReadyV419)
        {
            if (!Stage2MapWaitV381(r.pid,level,true))
                return
            if (scosEntryV162!=r)
                return
            r.boRouteReadyV419 := true
            PortalLogWriteV66("BO_FINAL_ROUTE_READY level=" . level . " start_row=" . FarmStartRowV394()
                . " next=STANDARD_FARM_ITEM_ROUTE")
        }
        wanted := r.boStageV413=2 ? 668 : 1825
        flowStartedV30 := r.boStageV413=4 ? FarmItemFlowBeginV427(wanted,7,false)
            : FarmBossItemBeginV430(wanted,7,false)
        if (!flowStartedV30)
        {
            MapLoadFailedStopV397(r.boStageV413=4 ? "BO_FINAL_ROUTE_FARM_START_FAILED" : "BO_BOSS_SEARCH_START_FAILED")
            return
        }
        r.oldItemsV413 := {}
        ctx.player := player,ctx.inv := D2ReadU32(ctx.h,player+0x60)
        for uid,a in SigSnapshotV147(ctx)
            if (a.cls=wanted && a.q=7)
                r.oldItemsV413[uid] := true
        r.phase := "FARM",r.farmLevelV413 := level
        if (r.boStageV413=4)
            r.boBossKilledV454 := false,r.boFinalPickupPreparedV454 := false,r.boFinalSortedV454 := false
        farmStage2DoneV372 := false
        mapStage1BuffDoneV248 := {pid:r.pid,map:"BO",level:level,buffDone:true}
        MapStageSetV185(2)
        autoMonsterAttackOn := true,scosStartFarmV162 := true
        try
            Gosub, AutoMonsterAttackToggle
        finally
            scosStartFarmV162 := false,mapStage1BuffDoneV248 := false
        if (scosEntryV162!=r || !autoMonsterAttackOn)
            return
        cainPauseFarmV361 := false
        if (r.boStageV413=4)
            PortalLogWriteV66("BO_FINAL_BOSS_HUNT route=SAVED_XY boss=1584 lock=UNTIL_DEAD pickup=AFTER_DEATH item=1825/07")
        FonInfoPushV385("[BO GĐ" . r.boStageV413 . "] Farm + nhặt " . wanted . "/07")
        return
    }
    if (r.phase="FARM")
    {
        if (!FarmItemFlowDoneV427())
        {
            return
        }
        cainPauseFarmV361 := true
        FarmCastSyncV88(false)
        PickupEnabledSetV71(false,true,false)
        if (r.boStageV413=2)
        {
            r.boStageV413 := 3,r.phase := "CUBE"
            r.boCubeAttemptV487 := false,r.boPortalPendingV487 := false,r.boCubeConsumedV487 := false
            r.fromLevelV413 := 0,r.fromLevelPtrV427 := 0,r.enterAtV413 := 0
            return
        }
        r.phase := "TOWN"
    }
    if (r.phase="TOWN")
    {
        if (!IsObject(stage2FlowV380) || !stage2FlowV380.done
            || !Stage2ItemNewInCubeV420(ctx.h,player,stage2FlowV380,true,true))
        {
            r.phase := "FARM"
            if (IsObject(stage2FlowV380))
                stage2FlowV380.done := false
            cainPauseFarmV361 := false
            PickupEnabledSetV71(true,true,false)
            return
        }
        if (pickupTimerBusy || !AutoMonsterPacketCleanupV1())
            return
        if (IsObject(farmStage2DoneV372))
            farmStage2DoneV372.handled := true
        scosEntryV162 := false
        SetTimer, ScosEntryTimerV162, Off
        cainPauseFarmV361 := false
        if (FarmStage3RequestV313("COMPLETE"))
        {
            PortalLogWriteV66("BO_DONE item=1825/07 next=STAGE3_DLL no_town=1")
            return
        }
        FarmErrorKeepV769("BO_STAGE3_HANDOFF_FAILED")
        FarmCombatYieldV237()
        PickupEnabledSetV71(false,true,false)
        farmRestartReasonV238 := ""
        ToolTipInfoV386("BO: đã có vật cuối — giữ phiên farm, chờ xử lý chuyển bước.")
        SetTimer, RemoveToolTip, -4000
        PortalLogWriteV66("BO_DONE item=1825/07 next=ERROR_KEEP_FARM")
        return
    }
}

BOFarmMapRememberV417(stage,level)
{
    global currentProfile
    if ((stage!=2 && stage!=4) || !level || FarmReviveTownLevelV295(level))
        return false
    section := ProfileSection(currentProfile),key := "BOFarmLevel" . stage
    try IniWrite, %level%, % ProfileConfigPathV364(section), %section%, %key%
    return !ErrorLevel
}

Stage2CommonPickupTargetV420(cls,q)
{
    global farmControlOwnerV186,stage2FlowV380,backgroundPidV63
    r := stage2FlowV380
    return IsObject(r) && r.owner=farmControlOwnerV186
        && r.pid=backgroundPidV63 && r.mode="ITEM" && !r.done
        && cls=r.itemClass && q+0=r.itemData
}

Stage2ItemCubeBaselineV420(h,player,r)
{
    inv := player ? D2ReadU32(h,player+0x60) : 0
    first := inv ? D2ReadU32(h,inv+0x10) : 0
    cursor := inv ? PickupCursorV4(h,inv) : false
    if (!first || !IsObject(cursor) || cursor.unit)
        return false
    all := V9SnapshotAllItems({h:h,inv:inv,first:first})
    if (!IsObject(all))
        return false
    r.initialItemUIDsV420 := {}
    for uid,item in all
        if (item.cls=r.itemClass && item.data && D2ReadU8V18(h,item.data)=r.itemData
            && (item.loc=3 || (item.loc=0 && item.owner=inv)))
            r.initialItemUIDsV420[uid] := true
    return true
}

Stage2ItemNewInCubeV420(h,player,r,allowExisting := false,requireNew := false)
{
    if ((!allowExisting || requireNew) && !IsObject(r.initialItemUIDsV420))
        return false
    inv := player ? D2ReadU32(h,player+0x60) : 0
    first := inv ? D2ReadU32(h,inv+0x10) : 0
    cursor := inv ? PickupCursorV4(h,inv) : false
    if (!first || !IsObject(cursor) || cursor.unit)
        return false
    all := V9SnapshotAllItems({h:h,inv:inv,first:first})
    if (!IsObject(all))
        return false
    for uid,item in all
        if (item.cls=r.itemClass && item.data
            && (item.loc=3 || ((allowExisting || FinalQuestItemV511(h,item)) && item.loc=0 && item.owner=inv))
            && D2ReadU8V18(h,item.data)=r.itemData && ((allowExisting && !requireNew) || !r.initialItemUIDsV420.HasKey(uid)))
        {
            r.completedItemUIDV420 := uid
            return true
        }
    return false
}

; ===== V843: isolated special map matching; loader for other maps is V68 =====

MapCollisionSampleV821(h,room1,rectKey)
{
    if (room1<0x10000)
        return false
    coll := D2ReadU32(h,room1+0x20)
    if (coll<0x10000)
        return false
    cx := D2ReadU32(h,coll),cy := D2ReadU32(h,coll+4)
    w := D2ReadU32(h,coll+8),hh := D2ReadU32(h,coll+12)
    mapPtr := D2ReadU32(h,coll+0x20)
    rect := StrSplit(rectKey,"_")
    ; Reject unexpected headers so a memory pointer cannot be treated as a map.
    if (rect.Length()!=4 || cx!=rect[1]+0 || cy!=rect[2]+0
        || w!=rect[3]+0 || hh!=rect[4]+0
        || w<1 || hh<1 || w>200 || hh>200 || mapPtr<0x10000)
        return false
    bytesCount := Min(2048,w*hh*2)
    VarSetCapacity(bytes,bytesCount,0),got := 0
    if (!DllCall("ReadProcessMemory","Ptr",h,"Ptr",mapPtr,"Ptr",&bytes
        ,"UPtr",bytesCount,"UPtr*",got) || got!=bytesCount)
        return false
    hash := 2166136261
    Loop, %bytesCount%
        hash := Mod((hash ^ NumGet(bytes,A_Index-1,"UChar"))*16777619,4294967296)
    return {hash:Format("{:08X}",hash),bytes:bytesCount}
}

MapCollisionSnapshotV821(pid,level,requiredLevelPtr := 0)
{
    if (!pid || !(level=39 || level=183 || level=184 || (level>=263 && level<=266)))
        return false
    base := D2GetModuleBaseV35(pid,"D2Client.dll")
    h := base ? D2OpenProcess(pid) : 0
    if (!h)
        return false
    try
    {
        player := D2ReadU32(h,base+0x11BBFC),path := player ? D2ReadU32(h,player+0x2C) : 0
        r1 := path ? D2ReadU32(h,path+0x1C) : 0
        r2 := r1 ? D2ReadU32(h,r1+0x10) : 0
        lp := r2 ? D2ReadU32(h,r2+0x58) : 0
        if (!lp || (requiredLevelPtr && lp!=requiredLevelPtr)
            || D2ReadU32(h,lp+0x1D0)!=level)
            return false
        expected := D2ReadU32(h,lp+0x08)
        address := D2ReadU32(h,lp+0x10)
        if (expected<1 || expected>4096 || address<0x10000)
            return false
        snapshot := {level:level,levelPtr:lp,totalRooms:expected,hashes:{}
            ,loadedRooms:0,failedSamples:0,chainRooms:0
            ,seedA:D2ReadU32(h,lp+0x1C4),seedB:D2ReadU32(h,lp+0x1C8)}
        seen := {},start := A_TickCount
        while (address)
        {
            if (seen.HasKey(address) || seen.Count()>=4096 || A_TickCount-start>3500)
                return false
            seen[address] := true
            if (!MonsterBossProbeReadV1(h,address,0x60,b)
                || NumGet(b,0x58,"UInt")!=lp)
                return false
            x := NumGet(b,0x34,"UInt")*5,y := NumGet(b,0x38,"UInt")*5
            w := NumGet(b,0x3C,"UInt")*5,hh := NumGet(b,0x40,"UInt")*5
            if (!w || !hh || w>1000 || hh>1000)
                return false
            key := x . "_" . y . "_" . w . "_" . hh
            loadedR1 := NumGet(b,0x30,"UInt")
            if (loadedR1>=0x10000 && D2ReadU32(h,loadedR1+0x10)=address)
            {
                snapshot.loadedRooms++
                sample := MapCollisionSampleV821(h,loadedR1,key)
                if (IsObject(sample))
                    snapshot.hashes[key] := sample
                else
                    snapshot.failedSamples++
            }
            address := NumGet(b,0x24,"UInt")
        }
        snapshot.chainRooms := seen.Count()
        if (snapshot.chainRooms!=expected || !seen.HasKey(r2))
            return false
        endR1 := D2ReadU32(h,path+0x1C)
        endR2 := endR1 ? D2ReadU32(h,endR1+0x10) : 0
        if (!endR2 || D2ReadU32(h,endR2+0x58)!=lp)
            return false
        return snapshot
    }
    finally
        DllCall("CloseHandle","Ptr",h)
}

; LIB 130/133/136/139: chon INI CHI MOT LAN luc vua vao cong.
; Map duoc luu trong RAM kem mapId + diem + dong vang. Ve town/chet/qua cong
; ve LAI cung map: khong matching room, khong tu load file tu vi tri hien tai.
LibFarmPinMatchesV2026(pid,level)
{
    global libFarmPinnedMapV2026,currentProfile,libScrollTierV290
    p := libFarmPinnedMapV2026
    return (level>=263 && level<=266) && IsObject(p) && p.pid=pid && p.level=level
        && p.birth=BackgroundBirthV63(pid) && p.profile=currentProfile
        && p.tier=libScrollTierV290 && IsObject(p.points) && p.points.Length()>0
}

LibFarmEntryReadyV2026(pid,level,levelPtr,x,y)
{
    global lib263EntryV841
    e := lib263EntryV841
    ; Khong su dung toa do nhan vat da chay xa de doan file ban do.
    return (level>=263 && level<=266) && IsObject(e) && e.from103
        && e.pid=pid && e.level=level && e.levelPtr=levelPtr
        && A_TickCount-e.at<=15000
        && (x-e.x)**2+(y-e.y)**2<=30*30
}

LibFarmPinSaveV2026(pid,level,levelPtr)
{
    global libFarmPinnedMapV2026,currentProfile,libScrollTierV290
    global coordSavedV15,routeMapIdV21,coordYellowRowV350,coordMapStateV381
    ; Core da xac nhan portal-entry luc bat dau load + verify cung level o cuoi.
    ; Khong kiem tra lai timeout 15s sau khi doc file/hinh hoc mat thoi gian.
    if (!IsObject(coordSavedV15) || !coordSavedV15.Length())
        return false
    file := IsObject(coordMapStateV381) ? coordMapStateV381.fileV10 : ""
    stamp := IsObject(coordMapStateV381) ? coordMapStateV381.fileStampV10 : ""
    row := Max(1,Min(coordSavedV15.Length(),coordYellowRowV350))
    libFarmPinnedMapV2026 := {pid:pid,birth:BackgroundBirthV63(pid),profile:currentProfile
        ,tier:libScrollTierV290,level:level,mapId:routeMapIdV21,levelPtr:levelPtr
        ,points:coordSavedV15.Clone(),yellow:row,file:file,stamp:stamp}
    PortalLogWriteV66("LIB_FON_PIN_FIRST level=" . level . " tier=" . libScrollTierV290
        . " map=" . routeMapIdV21 . " points=" . coordSavedV15.Length()
        . " yellow=" . row . " next=YELLOW_ONLY")
    return true
}

LibFarmPinYellowV2026(pid,level)
{
    global libFarmPinnedMapV2026,coordRouteV16,coordYellowRowV350,routeMapIdV21
    if (!LibFarmPinMatchesV2026(pid,level))
        return false
    p := libFarmPinnedMapV2026
    if (routeMapIdV21!=p.mapId)
        return false
    r := coordRouteV16
    row := IsObject(r) && r.pid=pid && r.startLevel=level && r.yellow>=1
        ? r.yellow : coordYellowRowV350
    if (row>=1 && row<=p.points.Length() && row>p.yellow)
    {
        p.yellow := row
        PortalLogWriteV66("LIB_FON_YELLOW_ONLY level=" . level . " map=" . p.mapId
            . " yellow=" . p.yellow, "LIB_FON_YELLOW", 350)
    }
    return true
}

LibFarmPinRestoreV2026(pid,level,levelPtr:=0)
{
    global libFarmPinnedMapV2026,currentProfile,routeMapIdV21,coordSavedV15
    global coordPointLevelV14,coordPointTextV14,coordMapReadyV381,coordMapStateV381
    global coordMapSerialV381,coordYellowRowV350,coordPinnedYellowV136
    global coordLiveYellowV128,coordNearbyRowV18,coordManualRowV59,fonCursorV724
    global coordMapAcceptedV381,routePreviewV401,mapLoadFailureV402,roomMapSelectionResetV111
    if (!LibFarmPinMatchesV2026(pid,level))
        return false
    p := libFarmPinnedMapV2026
    identity := MapLiveIdentityV399(pid,level)
    if (!IsObject(identity) || (levelPtr && identity.levelPtr!=levelPtr))
        return false
    good := coordMapReadyV381 && IsObject(coordMapStateV381) && coordMapStateV381.loaded
        && coordMapStateV381.pid=pid && coordMapStateV381.level=level
        && coordMapStateV381.levelPtrV395=identity.levelPtr
        && coordMapStateV381.mapId=p.mapId && routeMapIdV21=p.mapId
        && IsObject(coordSavedV15) && coordSavedV15.Length()=p.points.Length()
        && coordSavedV15[1].x=p.points[1].x && coordSavedV15[1].y=p.points[1].y
    if (good)
    {
        LibFarmPinYellowV2026(pid,level)
        return true
    }
    ; Sau ve town / load map khac, khoi phuc CHINH mapId + points da khoa.
    ; Khong chay FonLoadMapCore, RoomMapRead, Lib263Pick hay MapGatesFilter.
    routeMapIdV21 := p.mapId,coordSavedV15 := p.points.Clone()
    coordPointLevelV14 := level
    coordPointTextV14 := coordSavedV15[1].x . "," . coordSavedV15[1].y
    yellow := Max(1,Min(coordSavedV15.Length(),p.yellow))
    coordYellowRowV350 := yellow,coordLiveYellowV128 := yellow
    coordPinnedYellowV136 := yellow,coordNearbyRowV18 := yellow,coordManualRowV59 := yellow
    coordMapSerialV381 += 1
    coordMapStateV381 := {key:pid . "|" . currentProfile . "|" . level
        ,pid:pid,level:level,profile:currentProfile,loaded:true,mapId:p.mapId
        ,retryAt:0,serial:coordMapSerialV381,levelPtrV395:identity.levelPtr
        ,fileV10:p.file,fileStampV10:p.stamp,layoutV841:"",layoutCheckedAtV841:A_TickCount}
    coordMapReadyV381 := true,coordMapAcceptedV381 := false
    routePreviewV401 := false,mapLoadFailureV402 := false,roomMapSelectionResetV111 := false
    fonCursorV724 := {pid:pid,birth:BackgroundBirthV63(pid),profile:currentProfile
        ,level:level,mapId:p.mapId,levelPtr:identity.levelPtr,row:yellow
        ,playerX:identity.x,playerY:identity.y,count:p.points.Length()
        ,firstX:p.points[1].x,firstY:p.points[1].y
        ,lastX:p.points[p.points.Length()].x,lastY:p.points[p.points.Length()].y}
    FonLoadErrorHideV385()
    PortalLogWriteV66("LIB_FON_RESTORE_PIN level=" . level . " tier=" . p.tier
        . " map=" . p.mapId . " yellow=" . yellow . " reason=RETURN_FROM_PORTAL reload=NO")
    CoordBoxRefreshV15(true)
    return true
}

Lib263EntryObserveV841(pid,level,x,y,levelPtr)
{
    global lib263EntryV841
    static previousPid := 0,previousLevel := 0
    if (level>=263 && level<=266 && pid && levelPtr && x && y)
    {
        if (!IsObject(lib263EntryV841) || lib263EntryV841.pid!=pid
            || lib263EntryV841.level!=level || lib263EntryV841.levelPtr!=levelPtr)
        {
            lib263EntryV841 := {pid:pid,level:level,levelPtr:levelPtr,x:x,y:y
                ,at:A_TickCount,from103:(previousPid=pid && previousLevel=103) ? 1 : 0}
            PortalLogWriteV66("LIB_ENTRY_CAPTURE level=" . level . " xy=" . x . "," . y
                . " from103=" . lib263EntryV841.from103 . " level_ptr=" . V92Hex(levelPtr))
        }
    }
    else if (level<263 || level>266)
        lib263EntryV841 := false
    previousPid := pid,previousLevel := level
}

Lib263AnchorV841(pid,levelPtr,x,y)
{
    global lib263EntryV841
    if (IsObject(lib263EntryV841) && lib263EntryV841.pid=pid
        && lib263EntryV841.levelPtr=levelPtr)
        return lib263EntryV841
    ; First load is protected by LibFarmEntryReadyV2026. Never infer a new
    ; layout from a position far inside the dungeon.
    return {pid:pid,levelPtr:levelPtr,x:x,y:y,from103:0}
}

Lib263PickV841(candidates,pid,levelPtr,x,y)
{
    global currentProfile
    if (!IsObject(candidates) || !candidates.Length())
        return false
    anchor := Lib263AnchorV841(pid,levelPtr,x,y)
    primary := [],others := []
    for _,entry in candidates
    {
        file := RoomProfileFileV108(currentProfile,entry.id)
        SplitPath, file,,,,stem
        ; The five known LIB layouts win over duplicate 130-map archives.
        if (RegExMatch(stem,"i)^LIB-Map263-[1-5]$"))
            primary.Push(entry)
        else
            others.Push(entry)
    }
    if (primary.Length())
    {
        chosen := Lib263PickFromListV841(primary,anchor)
        if (IsObject(chosen))
            return chosen
    }
    return Lib263PickFromListV841(others,anchor)
}

Lib263PickFromListV841(candidates,anchor)
{
    best := false,bestD2 := 1.0e30,secondD2 := 1.0e30
    for _,entry in candidates
    {
        if (!IsObject(entry.data) || !IsObject(entry.data.points) || !entry.data.points.Length())
            continue
        pt := entry.data.points[1]
        d2 := (anchor.x-pt.x)*(anchor.x-pt.x)+(anchor.y-pt.y)*(anchor.y-pt.y)
        PortalLogWriteV66("LIB263_ENTRY_COMPARE route_id=" . entry.id
            . " spawn=" . anchor.x . "," . anchor.y
            . " saved_first=" . pt.x . "," . pt.y
            . " dist=" . Round(Sqrt(d2),2))
        if (d2<bestD2)
            secondD2 := bestD2,bestD2 := d2,best := entry
        else if (d2<secondD2)
            secondD2 := d2
    }
    if (!IsObject(best) || bestD2>30*30
        || (secondD2<1.0e29 && Sqrt(secondD2)-Sqrt(bestD2)<12))
        return false
    PortalLogWriteV66("LIB263_ENTRY_PICK route_id=" . best.id
        . " distance=" . Round(Sqrt(bestD2),2) . " from103=" . anchor.from103)
    return best
}

ScosFixedPickV841(candidates,currentId)
{
    if (!IsObject(candidates) || !candidates.Length())
        return false
    for _,entry in candidates
        if (entry.id=currentId)
            return entry
    return candidates.Length()=1 ? candidates[1] : false
}

BoHashThresholdGetV830()
{
    global currentProfile,boHashThresholdV830
    section := ProfileSection(currentProfile)
    IniRead, saved, % ProfileConfigPathV364(section), %section%, BoHashThreshold, 80
    if (!RegExMatch(saved,"^\d+$") || saved<1 || saved>100)
        saved := 80
    boHashThresholdV830 := saved+0
    return boHashThresholdV830
}

BoHashListFromSnapshotV830(snapshot)
{
    list := []
    if (!IsObject(snapshot) || !IsObject(snapshot.hashes))
        return list
    text := ""
    for rect,sample in snapshot.hashes
        if (IsObject(sample) && RegExMatch(sample.hash,"^[A-Fa-f0-9]{8}$"))
        {
            hashInputV834 := sample.hash
            StringUpper, upperHashV834, hashInputV834
            text .= upperHashV834 . "`n"
        }
    Sort, text
    Loop, Parse, text, `n, `r
        if (A_LoopField!="")
            list.Push(A_LoopField)
    return list
}

BoHashReadV830(file,level)
{
    if (!FileExist(file))
        return false
    ; Check an independent HASH index first, then legacy embedded INI metadata.
    indexV846 := file . ".hash.ini"
    if (FileExist(indexV846))
        file := indexV846
    section := "HashRecognition-" . level
    IniRead, readLevel, %file%, %section%, LevelID, -1
    IniRead, readRooms, %file%, %section%, TotalRooms, -1
    IniRead, readMax, %file%, %section%, TongHashMax, -1
    IniRead, readOriginal, %file%, %section%, OriginalHashCount, -1
    IniRead, readCount, %file%, %section%, StableCount, -1
    if (readLevel!=level || readRooms<1 || readMax<1 || readOriginal<1
        || readMax!=readOriginal || readCount<1 || readCount>readMax)
        return false
    hashes := []
    Loop, %readCount%
    {
        key := "H_" . A_Index
        IniRead, value, %file%, %section%, %key%, ERROR
        if (!RegExMatch(value,"^[A-Fa-f0-9]{8}$"))
            return false
        StringUpper, upperHashV834, value
        hashes.Push(upperHashV834)
    }
    return {rooms:readRooms+0,max:readMax+0,hashes:hashes}
}

BoHashOverlapV830(known,observed,ByRef common)
{
    common := [],stock := {},found := 0
    for _,hash in observed
        stock[hash] := (stock.HasKey(hash) ? stock[hash] : 0)+1
    for _,hash in known
        if (stock.HasKey(hash) && stock[hash]>0)
        {
            stock[hash]--
            common.Push(hash)
            found++
        }
    return found
}

BoHashFindV830(snapshot,forRecord := 1)
{
    global routeMapsV21,currentProfile
    if (!IsObject(snapshot) || (snapshot.level!=39 && snapshot.level!=183 && snapshot.level!=184)
        || !IsObject(snapshot.hashes))
        return {status:"NO_DATA"}
    observed := BoHashListFromSnapshotV830(snapshot)
    count := observed.Length()
    if (!count)
        return {status:"NO_DATA"}
    ; V849: H% belongs ONLY to the TẠO / recording path.
    ; Loading requires the entire saved stable HASH multiset to be present.
    if (forRecord)
        pct := BoHashThresholdGetV830()
    best := false, bestScore := -1, ties := 0
    for _,entry in routeMapsV21
    {
        file := RoomProfileFileV108(currentProfile,entry.id)
        if (!FonFileAllowedV846(file,snapshot.level))
            continue
        ; Loading must ignore HASH sidecars whose route INI has no saved points.
        ; A newly created but unfinished map is RECORD-only, not a load target.
        if (!forRecord)
        {
            routeV852 := RoomMapReadV109(file,false,snapshot.level)
            if (!IsObject(routeV852) || !routeV852.points.Length())
                continue
        }
        saved := BoHashReadV830(file,snapshot.level)
        if (!IsObject(saved))
        {
            PortalLogWriteV66("HASH_SKIP level=" . snapshot.level . " id=" . entry.id . " reason=NO_SIGNATURE file=" . file)
            continue
        }
        if (forRecord && (saved.rooms!=snapshot.totalRooms || saved.max!=count))
        {
            PortalLogWriteV66("HASH_SKIP level=" . snapshot.level . " id=" . entry.id
                . " reason=COUNT_MISMATCH rooms=" . saved.rooms . "/" . snapshot.totalRooms
                . " hashes=" . saved.max . "/" . count)
            continue
        }
        n := BoHashOverlapV830(saved.hashes,observed,common)
        if (!forRecord)
        {
            ; Only HASH values decide the load: do not apply H%, room counts,
            ; or original hash-count gates here. Compare as a multiset so a
            ; repeated saved HASH must occur that many times in live data.
            PortalLogWriteV66("HASH_LOAD_COMPARE id=" . entry.id . " level=" . snapshot.level
                . " saved_stable=" . saved.hashes.Length() . " matched=" . n
                . " live_hashes=" . count . " rule=ALL_SAVED_HASH_VALUES")
            if (n!=saved.hashes.Length())
                continue
            ; Multiple matching signatures are ambiguous; never pick arbitrarily.
            ties++
            if (!IsObject(best))
                best := {status:"MATCH",id:entry.id,file:file,snapshot:snapshot}
            continue
        }
        ; TẠO: keep the exact original room/hash counts and original-max
        ; denominator when applying H% and filtering stable values.
        score := 100.0*n/saved.max
        PortalLogWriteV66("HASH_CREATE_COMPARE id=" . entry.id . " level=" . snapshot.level . " rooms=" . snapshot.totalRooms
            . " total_hash=" . count . " saved_stable=" . saved.hashes.Length()
            . " matched=" . n . " pct=" . Round(score,2) . " threshold=" . pct)
        if (score+0.00001<pct)
            continue
        if (score>bestScore+0.00001)
        {
            best := {status:"MATCH",id:entry.id,file:file,common:common,score:score,snapshot:snapshot}
            bestScore := score,ties := 1
        }
        else if (Abs(score-bestScore)<0.00001)
            ties++
    }
    if (ties>1)
        return {status:"AMBIGUOUS",matches:ties}
    if (IsObject(best))
        return best
    return {status:"NEW",snapshot:snapshot,observed:observed}
}

; V852: only the BO level uses a guarded, read-only partial HASH fallback.
; When the player returns from town, collision samples from distant rooms
; may be unloaded even though the same Room2 map layout still exists.
; Never choose a map based on the geometry alone or an ambiguous match.
BoHashLoadPartialV852(snapshot,candidates,pid)
{
    global currentProfile
    if (!IsObject(snapshot) || snapshot.level!=39 || !IsObject(candidates)
        || !candidates.Length() || !pid || !IsObject(snapshot.hashes))
        return {status:"NO_DATA"}
    liveV852 := MapRoomLayoutReadV270(pid,39)
    if (!IsObject(liveV852) || liveV852.partial || liveV852.layout=""
        || liveV852.levelPtr!=snapshot.levelPtr)
    {
        PortalLogWriteV66("HASH_PARTIAL_WAIT level=39 reason=LIVE_LAYOUT_NOT_READY", "HASH_PARTIAL_WAIT",2000)
        return {status:"NOT_READY"}
    }
    observedV852 := BoHashListFromSnapshotV830(snapshot)
    if (!observedV852.Length())
        return {status:"NO_DATA"}
    chosenV852 := false,matchesV852 := 0
    for _,candidateV852 in candidates
    {
        dataV852 := candidateV852.data
        if (!IsObject(dataV852) || dataV852.partial || dataV852.roomLayout=""
            || dataV852.roomLayout!=liveV852.layout)
            continue
        fileV852 := RoomProfileFileV108(currentProfile,candidateV852.id)
        savedV852 := BoHashReadV830(fileV852,39)
        if (!IsObject(savedV852) || savedV852.rooms!=snapshot.totalRooms)
            continue
        matchedV852 := BoHashOverlapV830(savedV852.hashes,observedV852,commonV852)
        ; Require 70% of the smaller HASH set, with at least four samples
        ; when available. Layout equality is an additional independent guard.
        smallerV852 := Min(savedV852.hashes.Length(),observedV852.Length())
        neededV852 := Max(Min(4,smallerV852),Ceil(smallerV852*0.70))
        PortalLogWriteV66("HASH_PARTIAL_COMPARE level=39 id=" . candidateV852.id
            . " saved=" . savedV852.hashes.Length() . " live=" . observedV852.Length()
            . " matched=" . matchedV852 . " needed=" . neededV852
            . " rooms=" . snapshot.totalRooms . " layout=EXACT")
        if (matchedV852<neededV852)
            continue
        matchesV852++
        chosenV852 := candidateV852
    }
    if (matchesV852>1)
    {
        PortalLogWriteV66("HASH_PARTIAL_REJECT level=39 reason=AMBIGUOUS matches=" . matchesV852)
        return {status:"AMBIGUOUS",matches:matchesV852}
    }
    if (matchesV852=1)
    {
        PortalLogWriteV66("HASH_PARTIAL_MATCH level=39 id=" . chosenV852.id
            . " method=HASH_PLUS_EXACT_FULL_LAYOUT")
        return {status:"MATCH",id:chosenV852.id}
    }
    return {status:"NEW"}
}

BoHashWriteV830(file,snapshot,stable,originalCount)
{
    if (!FileExist(file) || !IsObject(snapshot) || !IsObject(stable)
        || stable.Length()<1 || originalCount<stable.Length())
        return false
    ; Never modify the user's route INI: only maintain the independent HASH index.
    indexV846 := file . ".hash.ini"
    temp := indexV846 . ".tmp"
    if (FileExist(temp))
        try FileDelete, %temp%
    section := "HashRecognition-" . snapshot.level
    try IniWrite, BO_FNV32_MULTISET_V830, %temp%, %section%, Format
    try IniWrite, % snapshot.level, %temp%, %section%, LevelID
    try IniWrite, % snapshot.totalRooms, %temp%, %section%, TotalRooms
    try IniWrite, % originalCount, %temp%, %section%, TongHashMax
    try IniWrite, % originalCount, %temp%, %section%, OriginalHashCount
    count := stable.Length()
    try IniWrite, %count%, %temp%, %section%, StableCount
    for i,hash in stable
    {
        key := "H_" . i
        try IniWrite, %hash%, %temp%, %section%, %key%
        if (ErrorLevel)
            return false
    }
    IniRead, verifyCount, %temp%, %section%, StableCount, ERROR
    IniRead, verifyMax, %temp%, %section%, TongHashMax, ERROR
    if (verifyCount!=count || verifyMax!=originalCount)
        return false
    try FileMove, %temp%, %indexV846%, 1
    return !ErrorLevel
}

BoHashAutoTargetV830(pid,level)
{
    global currentProfile,routeMapIdV21,routeMapNextV21,routeMapsV21,coordPointLevelV14
    if (!pid || (level!=39 && level!=183 && level!=184))
        return false
    RoomMapsSyncV110(true,level)
    snapshot := MapCollisionSnapshotV821(pid,level)
    result := BoHashFindV830(snapshot)
    if (!IsObject(result) || result.status="NO_DATA")
    {
        ToolTipInfoV386("Chưa lấy được HASH tầng " . level . "; chưa tạo map khi thiếu dữ liệu.")
        SetTimer, RemoveToolTip, -4500
        return false
    }
    if (result.status="AMBIGUOUS")
    {
        ToolTipInfoV386("HASH đạt ngưỡng ở nhiều map. Không lọc/tạo map để tránh nhầm.")
        SetTimer, RemoveToolTip, -4000
        return false
    }
    if (result.status="MATCH")
    {
        saved := BoHashReadV830(result.file,level)
        if (!IsObject(saved) || !RouteMapActivateV21(result.id))
        {
            ToolTipInfoV386("Không chọn được INI HASH đã nhận diện; giữ nguyên dữ liệu.")
            return false
        }
        if (!BoHashWriteV830(result.file,snapshot,result.common,saved.max))
        {
            ToolTipInfoV386("Đã chọn INI, nhưng lỗi lưu bộ HASH. Bộ cũ được giữ.")
            return false
        }
        PortalLogWriteV66("HASH_REUSE level=" . level . " id=" . result.id . " pct=" . Round(result.score,2)
            . " stable=" . result.common.Length() . " hash_max=" . saved.max . " file=" . result.file)
        return true
    }
    ; Before creating a blank file, permit a one-time verified legacy association.
    if (result.status="NEW")
    {
        legacyCandidatesV846 := []
        for _,legacyEntryV846 in routeMapsV21
        {
            legacyFileV846 := RoomProfileFileV108(currentProfile,legacyEntryV846.id)
            if (!FonFileAllowedV846(legacyFileV846,level))
                continue
            legacyDataV846 := RoomMapReadV109(legacyFileV846,false,level)
            if (IsObject(legacyDataV846) && legacyDataV846.points.Length())
                legacyCandidatesV846.Push({id:legacyEntryV846.id,data:legacyDataV846})
        }
        migratedV846 := BoHashBindLegacyV846(snapshot,legacyCandidatesV846,pid,level)
        if (IsObject(migratedV846) && migratedV846.status="MATCH")
            return RouteMapActivateV21(migratedV846.id)
        if (IsObject(migratedV846) && migratedV846.status="AMBIGUOUS")
        {
            ToolTipInfoV386("Có nhiều INI cũ trùng bố cục; không tự tạo hoặc chọn nhầm HASH.")
            return false
        }
    }
    ; Completely unknown signature: ONLY NOW create a new empty map identity.
    ; No Route-* points are written here; pressing TẠO will seed point 1 later.
    owner := RoomMapButtonNameV22(level)
    baseName := owner . "-Map" . level
    directory := MapRouteDirectoryV408(owner,level)
    try FileCreateDir, %directory%
    if (!InStr(FileExist(directory),"D"))
        return false
    name := RoomMapNamedNumberV293(baseName)
    file := directory . "\" . name . ".ini"
    if (FileExist(file))
        return false
    try IniWrite, %name%, %file%, Map, Name
    try IniWrite, %baseName%, %file%, Map, RecordBaseName
    try IniWrite, 1, %file%, Map, AutoName
    try IniWrite, %owner%, %file%, Map, AutoButton
    try IniWrite, %level%, %file%, Map, AutoLevel
    try IniWrite, %level%, %file%, Map, RecordedLevel
    ; V850: store the chosen number before recording begins; do not let
    ; RoomRecordNameFinalizeV54 allocate a different number on STOP.
    if (RegExMatch(name,"-(\d+)$",hashNumberV850))
        try IniWrite, %hashNumberV8501%, %file%, Map, RecordNumber
    if (!BoHashWriteV830(file,snapshot,result.observed,result.observed.Length()))
    {
        try FileDelete, %file%
        return false
    }
    newId := routeMapNextV21++
    section := RouteMapSectionForV656(currentProfile,newId)
    try IniWrite, %file%, % ProfileConfigPathV364(section), %section%, RoomMapFile
    try IniWrite, 0, % ProfileConfigPathV364(section), %section%, CoordSavedCount
    routeMapsV21.Push({id:newId,name:name})
    if (!RouteMapActivateV21(newId))
        return false
    PortalLogWriteV66("HASH_CREATE level=" . level . " id=" . newId . " total_rooms=" . snapshot.totalRooms
        . " hash_max=" . result.observed.Length() . " file=" . file)
    return true
}

; V846: migrate a pre-HASH INI only if FULL map geometry identifies exactly
; one candidate. A failed or ambiguous match never changes routes or HASH.
BoHashBindLegacyV846(snapshot,candidates,pid,level)
{
    global currentProfile
    if (!IsObject(snapshot) || !IsObject(candidates) || !candidates.Length()
        || (level!=39 && level!=183 && level!=184))
        return {status:"NO_DATA"}
    observed := BoHashListFromSnapshotV830(snapshot)
    if (!observed.Length())
        return {status:"NO_DATA"}
    geometry := MapRoomLayoutReadV270(pid,level)
    if (!IsObject(geometry) || geometry.partial || geometry.layout="")
    {
        PortalLogWriteV66("HASH_LEGACY_SKIP level=" . level . " reason=LIVE_GEOMETRY_NOT_READY")
        return {status:"NOT_READY"}
    }
    eligible := []
    for _,candidate in candidates
    {
        file := RoomProfileFileV108(currentProfile,candidate.id)
        if (IsObject(BoHashReadV830(file,level)))
            continue
        ; Only a saved FULL geometry is an admissible association.
        ; Never attach a signature merely because the level or one spawn matches.
        if (candidate.data.roomLayout!="" && candidate.data.roomLayout=geometry.layout)
            eligible.Push({id:candidate.id,file:file})
        else if (candidate.data.roomLayout="" && candidates.Length()=1)
        {
            ; Exactly the same V68 legacy condition: only ONE candidate and
            ; its route lies entirely inside at least TWO distinct live rooms.
            legacyFitV846 := MapRoutePointsFitRoomsV841(candidate.data.points,geometry)
            if (legacyFitV846.ok && legacyFitV846.rooms>=2)
                eligible.Push({id:candidate.id,file:file})
        }
    }
    if (eligible.Length()!=1)
    {
        PortalLogWriteV66("HASH_LEGACY_SKIP level=" . level . " reason="
            . (eligible.Length()=0 ? "NO_EXACT_OLD_LAYOUT" : "AMBIGUOUS_OLD_LAYOUT")
            . " eligible=" . eligible.Length())
        return {status:eligible.Length()>1 ? "AMBIGUOUS" : "NO_MATCH"}
    }
    if (!BoHashWriteV830(eligible[1].file,snapshot,observed,observed.Length()))
    {
        PortalLogWriteV66("HASH_LEGACY_SKIP level=" . level . " reason=SIDECAR_WRITE_FAILED")
        return {status:"WRITE_FAILED"}
    }
    PortalLogWriteV66("HASH_LEGACY_OK level=" . level . " id=" . eligible[1].id
        . " rooms=" . snapshot.totalRooms . " hash_count=" . observed.Length()
        . " file=" . eligible[1].file)
    return {status:"MATCH",id:eligible[1].id,file:eligible[1].file}
}


BoHashThresholdChangedV830:
GuiControlGet, editBoHashV830, 1:, BoHashThresholdInputV830
if (!RegExMatch(editBoHashV830,"^\d+$") || editBoHashV830<1 || editBoHashV830>100)
    return
boHashThresholdV830 := editBoHashV830+0
sectionBoHashV830 := ProfileSection(currentProfile)
try IniWrite, %boHashThresholdV830%, % ProfileConfigPathV364(sectionBoHashV830), %sectionBoHashV830%, BoHashThreshold
; V851: show the exact minimum for TẠO, based on original HASH count.
; This never changes Load matching or saved signatures.
if (routeMapIdV21)
{
    thresholdFileV851 := RoomProfileFileV108(currentProfile,routeMapIdV21)
    thresholdLevelV851 := MapRouteHintV400(thresholdFileV851)
    if (thresholdLevelV851=39 || thresholdLevelV851=183 || thresholdLevelV851=184)
    {
        thresholdSavedV851 := BoHashReadV830(thresholdFileV851,thresholdLevelV851)
        if (IsObject(thresholdSavedV851))
        {
            neededV851 := Ceil(thresholdSavedV851.max*boHashThresholdV830/100)
            ToolTipInfoV386("TẠO: " . boHashThresholdV830 . "% cần " . neededV851 . "/" . thresholdSavedV851.max
                . " HASH gốc; còn " . thresholdSavedV851.hashes.Length() . " HASH ổn định. LOAD không dùng H%.")
            SetTimer, RemoveToolTip, -3500
        }
    }
}
return


; ===== END special map matching =====

RoomRecordNewTargetV424()
{
    global currentProfile,routeMapIdV21,routeMapsV21,routeMapNextV21,coordCurrentLevelV400
    pid := CoordDisplayGamePidV1(),level := pid ? RoomRecordLevelV259(pid) : 0
    if (!level)
    {
        ToolTipInfoV386("Chưa đọc được map hiện tại để tạo file lộ trình mới.")
        SetTimer, RemoveToolTip, -3000
        return false
    }
    coordCurrentLevelV400 := level
    ; Explicit record-button handling only; no effect on ordinary-map F-ON loader.
    if (level=39 || level=183 || level=184)
        return BoHashAutoTargetV830(pid,level)
    if (level=263 || level=241 || level=270)
    {
        RoomMapsSyncV110(true,level,true)
        knownV843 := []
        for _,entV843 in routeMapsV21
        {
            fileV843 := RoomProfileFileV108(currentProfile,entV843.id)
            if (!MapRouteFileInScopeV408(fileV843,level))
                continue
            dataV843 := RoomMapReadV109(fileV843,false,level)
            if (IsObject(dataV843) && dataV843.points.Length())
                knownV843.Push({id:entV843.id,data:dataV843})
        }
        chosenV843 := false
        if (level=263)
        {
            liveV843 := MapLiveIdentityV399(pid,level)
            if (IsObject(liveV843))
                chosenV843 := Lib263PickV841(knownV843,pid,liveV843.levelPtr,liveV843.x,liveV843.y)
        }
        else
            chosenV843 := ScosFixedPickV841(knownV843,routeMapIdV21)
        if (IsObject(chosenV843))
        {
            PortalLogWriteV66("RECORD_REUSE_EXISTING level=" . level . " route=" . chosenV843.id . " action=SHOW_ONLY")
            return RouteMapActivateV21(chosenV843.id)
        }
    }
    selected := routeMapIdV21 ? RoomProfileFileV108(currentProfile,routeMapIdV21) : ""
    if (selected!="" && FileExist(selected) && MapRouteHintV400(selected)=level
        && MapRouteFileInScopeV408(selected,level))
    {
        routeSection := "Route-" . level
        IniRead, emptyCount, %selected%, %routeSection%, Count, INVALID
        if (emptyCount="0")
            return true
        IniRead, selectedSectionsV424, %selected%
        if (!RegExMatch(selectedSectionsV424,"m)^Route-\d+\r?$"))
            return true
    }
    owner := RoomMapButtonNameV22(level),baseName := owner . "-Map" . level
    directory := MapRouteDirectoryV408(owner,level)
    try FileCreateDir, %directory%
    if (!InStr(FileExist(directory),"D"))
        return false
    RoomMapsSyncV110(true,level)
    name := RoomMapNamedNumberV293(baseName)
    file := directory . "\" . name . ".ini"
    if (FileExist(file))
        return false
    try IniWrite, %name%, %file%, Map, Name
    if (ErrorLevel)
        return false
    metadata := {RecordBaseName:baseName,AutoName:1,AutoButton:owner,AutoLevel:level,RecordedLevel:level}
    if (RegExMatch(name,"-(\d+)$",numberV424))
        metadata.RecordNumber := numberV4241+0
    for key,value in metadata
    {
        try IniWrite, %value%, %file%, Map, %key%
        if (ErrorLevel)
        {
            try FileDelete, %file%
            return false
        }
    }
    newId := routeMapNextV21++
    section := RouteMapSectionForV656(currentProfile,newId)
    try IniWrite, %file%, % ProfileConfigPathV364(section), %section%, RoomMapFile
    if (ErrorLevel)
    {
        try FileDelete, %file%
        routeMapNextV21 := newId
        return false
    }
    try IniWrite, 0, % ProfileConfigPathV364(section), %section%, CoordSavedCount
    routeMapsV21.Push({id:newId,name:name})
    RouteMapActivateV21(newId)
    PortalLogWriteV66("ROOM_RECORD_NEW_TARGET level=" . level . " route_id=" . newId
        . " file=" . file . " old_files=PRESERVED")
    return true
}

BOMapDirectoryNormalizeV426()
{
    global mapRelocatedFilesV412
    static doneV426 := false
    if (doneV426)
        return
    destinationDirV426 := A_ScriptDir . "\Map\BO"
    try FileCreateDir, %destinationDirV426%
    if (!InStr(FileExist(destinationDirV426),"D"))
        return
    if (!IsObject(mapRelocatedFilesV412))
        mapRelocatedFilesV412 := {}
    for _,oldDirV426 in [A_ScriptDir . "\Map\MAP\BO",A_ScriptDir . "\Map\MAP"]
    {
        patternV426 := oldDirV426 . "\*.ini"
        Loop, Files, %patternV426%, F
        {
            sourceV426 := A_LoopFileFullPath
            IniRead, ownerV426, %sourceV426%, Map, AutoButton, %A_Space%
            if (oldDirV426=A_ScriptDir . "\Map\MAP" && ownerV426!="BO"
                && !RegExMatch(A_LoopFileName,"i)^BO-"))
                continue
            destinationV426 := destinationDirV426 . "\" . A_LoopFileName
            if (FileExist(destinationV426))
                continue
            try FileMove, %sourceV426%, %destinationV426%, 0
            if (!ErrorLevel)
            {
                mapRelocatedFilesV412[sourceV426] := destinationV426
                PortalLogWriteV66("BO_MAP_PATH_NORMALIZED from=" . sourceV426 . " to=" . destinationV426)
            }
        }
    }
    doneV426 := true
}

FarmItemFlowBeginV427(wantClass,wantData := 7,startEngine := true,searchBoss := false,bossIDs := "")
{
    global
    if (wantClass<=0 || wantData<0 || !BackgroundValidV63() || !FarmCurrentLevelV143())
        return false
    if (!Stage2FlowConfigureV380("ITEM",wantClass,wantData,true))
        return false
    if (searchBoss && !BossSearchBeginV430(backgroundPidV63,FarmCurrentLevelV143(),bossIDs))
        return false
    cainNoFightV361 := false,cainPauseFarmV361 := false
    farmPickupBlockedV57 := false,farmPickupAllowedV57 := true
    if (searchBoss && !pickupImageOn)
        PickupEnabledSetV71(true,true,false)
    if (!startEngine)
        return true
    autoMonsterAttackOn := true,farmResumeInternalV70 := true
    try
        Gosub, AutoMonsterAttackToggle
    finally
        farmResumeInternalV70 := false
    return autoMonsterAttackOn && Stage2FlowModeV380()="ITEM"
}

FarmItemFlowLevelV427()
{
    global stage2FlowV380,backgroundPidV63,farmControlOwnerV186
    r := stage2FlowV380
    return IsObject(r) && r.flowNameV427="FARM_ITEM" && r.mode="ITEM" && !r.done
        && r.pid=backgroundPidV63 && r.owner=farmControlOwnerV186 ? r.levelV427+0 : 0
}

FarmItemFlowRunningV427(pid,level)
{
    global stage2FlowV380
    return FarmItemFlowLevelV427()>0 && level=FarmItemFlowLevelV427()
        && stage2FlowV380.pid=pid
}

FarmItemFlowDoneV427()
{
    global stage2FlowV380,backgroundPidV63,farmControlOwnerV186
    r := stage2FlowV380
    if (!IsObject(r) || r.flowNameV427!="FARM_ITEM" || r.mode!="ITEM"
        || r.pid!=backgroundPidV63 || r.owner!=farmControlOwnerV186)
        return false
    if (r.done)
        return true
    base := D2GetModuleBaseV35(r.pid,"D2Client.dll"),h := base ? D2OpenProcess(r.pid) : 0
    if (!h)
        return false
    try
    {
        player := D2ReadU32(h,base+0x11BBFC)
        return player ? Stage2ItemCheckV380(h,player,r.pid) : false
    }
    finally
        DllCall("CloseHandle","Ptr",h)
}


FarmBossItemBeginV430(wantClass,wantData := 7,startEngine := true,bossIDs := "")
{
    return FarmItemFlowBeginV427(wantClass,wantData,startEngine,true,bossIDs)
}

BossSearchBeginV430(pid,level,bossIDs := "")
{
    global stage2FlowV380,farmControlOwnerV186,backgroundPidV63
    if (!IsObject(stage2FlowV380) || pid!=backgroundPidV63 || stage2FlowV380.pid!=pid
        || stage2FlowV380.owner!=farmControlOwnerV186 || !level || FarmReviveTownLevelV295(level))
        return false
    identity := MapLiveIdentityV399(pid,level)
    if (!IsObject(identity))
        return false
    CoordRouteResetV16()
    stage2FlowV380.searchV430 := {pid:pid,owner:farmControlOwnerV186,level:level,levelPtr:identity.levelPtr
        ,phase:"SEARCH",bossIDs:bossIDs,boss:false,targetRoom:0,blockedRooms:{},retryUIDs:{},motion:false,lastMove:0,lastTele:0}
    PortalLogWriteV66("BOSS_SEARCH_BEGIN owner=" . farmControlOwnerV186 . " level=" . level . " route=NONE")
    return true
}

BossSearchActiveV430(pid := 0,level := 0)
{
    global stage2FlowV380,backgroundPidV63,farmControlOwnerV186
    if (!pid)
        pid := backgroundPidV63
    s := IsObject(stage2FlowV380) ? stage2FlowV380.searchV430 : false
    return IsObject(s) && s.pid=pid && pid=backgroundPidV63 && s.owner=farmControlOwnerV186
        && (!level || s.level=level)
}

BossSearchIdentityV430(pid,level)
{
    global stage2FlowV380
    if (!BossSearchActiveV430(pid,level))
        return false
    identity := MapLiveIdentityV399(pid,level)
    return IsObject(identity) && identity.levelPtr=stage2FlowV380.searchV430.levelPtr
}

BossSearchOwnsMapV430(pid,level)
{
    global scosEntryV162
    if (IsObject(scosEntryV162) && scosEntryV162.map="BO" && scosEntryV162.pid=pid
        && scosEntryV162.boStageV413=4)
        return false
    return !FarmReviveTownLevelV295(level) && (BossSearchActiveV430(pid,level)
        || (IsObject(scosEntryV162) && scosEntryV162.map="BO" && scosEntryV162.pid=pid))
}

BossSearchScanV430(h,ByRef pb,s)
{
    result := {known:false,groups:{},boss:false,allV431:[]},seen := {},wanted := {}
    px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort"),bestBoss := 1.0e30
    for _,room in MonsterLoadedRoomsV20(h,NumGet(pb,0x1C,"UInt"))
    {
        if (!MonsterBossProbeReadV1(h,room,0x78,rb))
            return result
        room2 := NumGet(rb,0x10,"UInt")
        if (CoordLevelV14(h,room)!=s.level)
            continue
        if (!result.groups.HasKey(room2))
            result.groups[room2] := {count:0,best:false}
        unit := NumGet(rb,0x74,"UInt")
        while (unit)
        {
            if (seen.HasKey(unit))
                break
            if (seen.Count()>=4096 || !MonsterBossProbeReadV1(h,unit,0xEC,ub))
                return result
            seen[unit] := true
            cls := NumGet(ub,4,"UInt"),mode := NumGet(ub,16,"UInt"),uid := NumGet(ub,12,"UInt")
            if (NumGet(ub,0,"UInt")=1 && uid && mode!=0 && mode!=12 && !MonsterClassExcludedV11(cls,h,unit))
            {
                if (!MonsterBossProbeReadV1(h,NumGet(ub,0x2C,"UInt"),0x20,mb))
                    return result
                actual := NumGet(mb,0x1C,"UInt")
                if (!actual || !MonsterBossProbeReadV1(h,actual+0x10,4,ar))
                    return result
                actual2 := NumGet(ar,0,"UInt"),level := CoordLevelV14(h,actual)
                if (level=s.level)
                {
                    x := NumGet(mb,2,"UShort"),y := NumGet(mb,6,"UShort"),dist := (x-px)**2+(y-py)**2
                    retry := s.retryUIDs.HasKey(uid) && A_TickCount<s.retryUIDs[uid]
                    candidate := {unit:unit,uid:uid,cls:cls,x:x,y:y,level:level,room2:actual2,dist:dist,priority:false}
                    result.allV431.Push(candidate)
                    if (candidate.priority && !retry && (!IsObject(s.boss) || uid=s.boss.uid))
                    {
                        if (dist<bestBoss)
                            result.boss := candidate,bestBoss := dist
                    }
                    if (!s.blockedRooms.HasKey(actual2) && !retry
                        && !MonsterRetryExcludedV44(uid,x,y,level,s.pid))
                    {
                        if (!result.groups.HasKey(actual2))
                            result.groups[actual2] := {count:0,best:false}
                        group := result.groups[actual2],group.count++
                        if (!IsObject(group.best) || (candidate.priority && !group.best.priority)
                            || (candidate.priority=group.best.priority && dist<group.best.dist))
                            group.best := candidate
                    }
                }
            }
            unit := NumGet(ub,0xE8,"UInt")
        }
    }
    result.known := true
    return result
}

BossSearchReleaseV430(s,reason)
{
    global monsterCombatUidV45,monsterChaseV44,monsterRoadAreaV51
    s.boss := false,s.motion := false,s.targetRoom := 0,s.targetUIDV440 := 0,s.phase := "SEARCH",s.exploreV432 := false,s.leftDetourV433 := false
    monsterCombatUidV45 := 0,monsterChaseV44 := false,monsterRoadAreaV51 := false
    PortalLogWriteV66("BOSS_SEARCH_RESCAN reason=" . reason . " next=BOSS_THEN_ADJACENT_MONSTERS")
}

BossSearchSkipV430(s,target,reason)
{
    if (IsObject(s.cleanupV431) && !s.cleanupV431.done)
    {
        s.retryUIDs[target.uid] := A_TickCount+30000
        s.motion := false
        PortalLogWriteV66("BOSS_ITEM_CLEANUP_RETRY uid=" . target.uid . " reason=" . reason
            . " done=0 item_use=WAIT")
        return
    }
    if (target.uid)
        s.retryUIDs[target.uid] := A_TickCount+3000
    else
        s.blockedRooms[target.room2] := A_TickCount+3000
    PortalLogWriteV66("BOSS_SEARCH_SKIP room=" . V92Hex(target.room2) . " uid=" . target.uid
        . " boss=" . target.priority . " reason=" . reason . " next=OTHER_ROOM")
    BossSearchReleaseV430(s,reason)
}

BossSearchMoveV430(h,ByRef pb,s,target,hpRaw := -1,attackStuck := false)
{
    if (s.tubeV14)
        return FarmTubeMoveV14(h,pb,s,target)
    global chaseCheckSecV9,teleportIntervalSecV56,teleportKeyV55,coordGoV59,coordManualTeleLastV296,boMoveMinimumV456,moveDelayMsV810
    global monsterLockRoomSecV622
    px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort"),dist := Sqrt(target.dist)
    p := s.motion,motionKey := s.phase="BOSS" ? "UID|" . target.uid : "ROOM|" . target.room2
    if (BossSearchLeftTickV433(h,pb,s,target,motionKey))
        return true
    if (!IsObject(p) || p.key!=motionKey)
        s.motion := p := {key:motionKey,uid:target.uid,dist:dist,hp:hpRaw,since:0,queued:0,teleAttempts:0,teleAt:0,probeX:px,probeY:py}
    if (s.owner!="BO" && (p.dist-dist>=1 || (p.uid=target.uid && hpRaw>=0 && p.hp>=0 && hpRaw<p.hp)))
        p.dist := dist,p.hp := hpRaw,p.since := 0,p.queued := 0,p.teleAttempts := 0,p.teleAt := 0
    stuckWaitV420 := Max(1,chaseCheckSecV9)*1000
    stuck := attackStuck || (p.since && p.queued && A_TickCount-p.since>=stuckWaitV420)
    if (s.owner="BO")
    {
        stuck := false
        if (p.since && p.queued>=2 && A_TickCount-p.since>=stuckWaitV420)
        {
            travelledV456 := Sqrt((px-p.probeX)**2+(py-p.probeY)**2)
            stuck := travelledV456<Max(5,boMoveMinimumV456)
            PortalLogWriteV66("BO_MOVE_WINDOW distance=" . Round(travelledV456,2) . " minimum=" . boMoveMinimumV456
                . " sent=" . p.queued . " elapsed_ms=" . (A_TickCount-p.since) . " stuck=" . stuck)
            if (!stuck)
                p.since := 0,p.queued := 0,p.probeX := px,p.probeY := py,p.dist := dist
        }
    }
    if (stuck)
    {
        if (s.owner="BO")
        {
            if (target.room2 && target.room2+0 > 0 && !IsObject(s.cleanupV431))
            {
                currentRoom := D2ReadU32(h,NumGet(pb,0x1C,"UInt")+0x10)
                if (target.room2 != currentRoom)
                {
                    lockDuration := Max(1, monsterLockRoomSecV622) * 1000
                    s.blockedRooms[target.room2] := A_TickCount + lockDuration
                    s.exploreV432 := false
                    s.motion := false
                    s.leftDetourV433 := false
                    
                    if (s.previousRoomV432 && s.previousRoomV432 != target.room2 && s.previousRoomV432 != currentRoom)
                    {
                        s.backtrackingV432 := true
                        s.preferNewRoomsV507 := false
                        PortalLogWriteV66("BO_STUCK_LOCK_BACK room=" . V92Hex(target.room2) . " duration_ms=" . lockDuration . " next=BACK")
                        return true
                    }
                    else
                    {
                        s.backtrackingV432 := false
                        s.zigzagV474 := {dx:1,dy:0,goal:false,leg:0}
                        PortalLogWriteV66("BO_STUCK_LOCK_ZIGZAG room=" . V92Hex(target.room2) . " duration_ms=" . lockDuration . " next=ZIGZAG")
                        return BOZigzagTickV474(h,pb,s)
                    }
                }
            }
            if (s.preferNewRoomsV507 && s.phase="EXPLORE")
            {
                if (BOFirstMapTeleportV485(h,pb,s,target))
                {
                    s.motion := false,s.commonScanV446 := false
                    return true
                }
                return BORoomCrossRetryV507(s,"CROSSING_BLOCKED")
            }
            if (BOFirstMapTeleportV485(h,pb,s,target))
            {
                s.motion := false,s.commonScanV446 := false
                return true
            }
            BossSearchLeftBeginV433(s,target,px,py,motionKey)
            return true
        }
        if (s.owner!="BO" && s.phase="EXPLORE" && BossSearchEdgeAdvanceV432(s))
            return true
        if (s.owner!="BO" && s.phase!="EXPLORE" && BossSearchFollowEdgeV435(h,pb,s,target,p))
            return true
        if (!p.leftTriedV433)
        {
            p.leftTriedV433 := true
            if (BossSearchLeftBeginV433(s,target,px,py,motionKey,s.owner="BO" ? 120 : 95))
                return true
        }
        if (s.owner!="BO" && !p.rightTriedV434)
        {
            p.rightTriedV434 := true
            if (BossSearchLeftBeginV433(s,target,px,py,motionKey,-95))
                return true
        }
        if (p.teleAt && A_TickCount-p.teleAt<Max(1,chaseCheckSecV9)*1000)
            return true
        if (p.teleAttempts>=2 || teleportKeyV55="")
        {
            BossSearchSkipV430(s,target,"WALK_AND_TELE_NO_PROGRESS")
            return true
        }
        last := Max(s.lastTele+0,coordManualTeleLastV296+0)
        if (last && A_TickCount-last<Max(3,teleportIntervalSecV56)*1000)
            return true
        goal := {pid:s.pid,level:s.level,x:target.x,y:target.y,row:0,requiredArrival:true,stop:false}
        priorGoal := coordGoV59,coordGoV59 := goal
        try
            sent := CoordGoTeleportV284(h,pb,goal)
        finally
            if (coordGoV59=goal)
                coordGoV59 := priorGoal
        p.teleAttempts++,p.teleAt := A_TickCount
        if (sent)
            s.lastTele := A_TickCount,coordManualTeleLastV296 := s.lastTele
        PortalLogWriteV66("BOSS_SEARCH_TELE uid=" . target.uid . " attempt=" . p.teleAttempts . " queued=" . sent)
        return true
    }
    if (A_TickCount-s.lastMove<Max(0,moveDelayMsV810))
        return true
    if (NativeMovePointV14(s.pid,target.x,target.y,s.level,false,false,true,false,{searchV430:s}))
    {
        s.lastMove := A_TickCount,p.queued++
        if (!p.since)
            p.since := A_TickCount,p.probeX := px,p.probeY := py
    }
    return true
}

BossSearchAttackV430(h,player,ByRef pb,s,target)
{
    global monsterChaseV44,chaseCheckSecV9,farmCloseRadiusV391
    hp := MonsterBossProbeHPV2(h,D2ReadU32(h,target.unit+0x5C)),hpRaw := hp.ok ? hp.raw : -1
    c := monsterChaseV44
    if (IsObject(c) && c.uid=target.uid && c.pid=s.pid && c.level=s.level
        && c.queued>=2 && c.since && A_TickCount-c.since>=Max(1,chaseCheckSecV9)*1000
        && target.dist>farmCloseRadiusV391*farmCloseRadiusV391
        && (hpRaw<0 || c.hp<0 || hpRaw>=c.hp))
        return BossSearchMoveV430(h,pb,s,target,hpRaw,true)
    s.motion := false,s.leftDetourV433 := false,s.exploreV432 := false
    return BossSearchHoldAttackV436(h,player,pb,s,target)
}

BossSearchTickV430(h,player,ByRef pb,pid)
{
    global stage2FlowV380,monsterCombatUidV45,autoMonsterAttackOn,xRunning,zRunning,gameItemActionOwner,packetWatchArmedV1
    s := stage2FlowV380.searchV430
    if (!BossSearchActiveV430(pid,s.level) || stage2FlowV380.done)
        return true
    if (!autoMonsterAttackOn || xRunning || zRunning || packetWatchArmedV1 || gameItemActionOwner!=""
        || !AutoMonsterPacketCleanupV1())
        return true
    current := D2ReadU32(h,NumGet(pb,0x1C,"UInt")+0x10)
    if (D2ReadU32(h,current+0x58)!=s.levelPtr || CoordLevelV14(h,NumGet(pb,0x1C,"UInt"))!=s.level)
    {
        MapLoadFailedStopV397("BOSS_SEARCH_LIVE_MAP_CHANGED")
        return true
    }
    for room,until in s.blockedRooms
        if (A_TickCount>=until)
            s.blockedRooms.Delete(room)
    BossSearchRoomsObserveV432(s,current)
    scan := BossSearchScanV430(h,pb,s)
    if (!scan.known)
    {
        if (IsObject(s.cleanupV431))
            s.cleanupV431.emptyAt := 0
        return true
    }
    if (IsObject(s.cleanupV431))
        return BossSearchCleanupTickV431(h,player,pb,s,scan)
    if (Stage2PickupEnabledV9())
    {
        FarmPickupFirstV75()
        cursor := PickupCursorV4(h,D2ReadU32(h,player+0x60))
        if (!IsObject(cursor) || cursor.unit || gameItemActionOwner!="")
            return true
    }
    target := false
    for _,a in scan.allV431
    {
        if ((s.retryUIDs.HasKey(a.uid) && A_TickCount<s.retryUIDs[a.uid])
            || MonsterRetryExcludedV44(a.uid,a.x,a.y,a.level,s.pid))
            continue
        if (!IsObject(target) || a.dist<target.dist)
            target := a
    }
    if (IsObject(target))
    {
        if (s.targetUIDV440!=target.uid)
        {
            s.motion := false,s.leftDetourV433 := false,s.exploreV432 := false
            s.targetUIDV440 := target.uid
        }
        s.targetRoom := target.room2,s.phase := "FIGHT"
        return BossSearchAttackV430(h,player,pb,s,target)
    }
    node := RoomExploreReadV89(h,current,s.level)
    if (!IsObject(node))
        return true
    s.targetUIDV440 := 0
    return BossSearchExploreTickV432(h,pb,s,node)

}

BOFirstFarmMapV497(s)
{
    global scosEntryV162
    r := scosEntryV162
    return IsObject(r) && r.map="BO" && r.pid=s.pid && r.boStageV413=2 && r.phase="FARM"
}

BOChaseHeadingRememberV497(ByRef pb,s)
{
    global pickupRadius
    origin := s.chaseOriginV497
    if (!BOFirstFarmMapV497(s) || !IsObject(origin) || IsObject(s.chaseHeadingV497))
        return false
    px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort")
    previous := s.chasePositionV497
    s.chasePositionV497 := {x:px,y:py}
    if ((px-origin.x)**2+(py-origin.y)**2<=Max(1,pickupRadius)**2)
        return false
    dx := IsObject(previous) ? px-previous.x : px-origin.x
    dy := IsObject(previous) ? py-previous.y : py-origin.y
    length := Sqrt(dx*dx+dy*dy)
    if (length<1)
    {
        dx := px-origin.x,dy := py-origin.y,length := Sqrt(dx*dx+dy*dy)
    }
    if (length<1)
        return false
    s.chaseHeadingV497 := {dx:dx/length,dy:dy/length}
    PortalLogWriteV66("BO_CHASE_HEADING_SAVED live_xy=" . px . "," . py
        . " heading=" . Round(dx/length,3) . "," . Round(dy/length,3)
        . " pickup_radius=" . pickupRadius . " next=KEEP_HEADING_AFTER_PICKUP")
    return true
}

BOCombatRouteRebaseV488(ByRef pb,s,force := false)
{
    if (!force)
    {
        BOChaseHeadingRememberV497(pb,s)
        return false
    }
    origin := s.fightOriginV488
    px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort"),radius := Max(1,MonsterRadiusGetV239())
    if (!force && (!IsObject(origin) || (px-origin.x)**2+(py-origin.y)**2<=radius*radius))
        return false
    sweep := s.zigzagV474,detour := s.leftDetourV433
    dx := IsObject(sweep) ? sweep.dx : IsObject(detour) ? detour.dx : 1
    dy := IsObject(sweep) ? sweep.dy : IsObject(detour) ? detour.dy : 0
    heading := s.chaseHeadingV497
    resumedChase := force && BOFirstFarmMapV497(s) && IsObject(heading)
    if (resumedChase)
    {
        dx := heading.dx,dy := heading.dy
        s.zigzagSideV474 := {x:-dy,y:dx}
        PortalLogWriteV66("BO_PICKUP_RESUME_CHASE heading=" . Round(dx,3) . "," . Round(dy,3)
            . " horizontal=PERPENDICULAR_TO_CHASE vertical=ALONG_CHASE old_coordinate=DISCARDED")
    }
    if (force)
        s.chaseHeadingV497 := false,s.chaseOriginV497 := false,s.chasePositionV497 := false
    s.zigzagV474 := {dx:dx,dy:dy,goal:false,leg:0}
    s.motion := false,s.leftDetourV433 := false,s.exploreV432 := false,s.unvisitedSearchV462 := false
    s.fightOriginV488 := {x:px,y:py}
    PortalLogWriteV66("BO_ROUTE_REBASE live_xy=" . px . "," . py . " reason=" . (force ? "PICKUP_FINISHED" : "COMBAT_DRIFT_OVER_BK")
        . " old_coordinate=DISCARDED next=" . (resumedChase ? "ZIGZAG_ALONG_SAVED_CHASE_HEADING" : "NEW_ZIGZAG_FROM_LIVE_POSITION"))
    return true
}

BOAttackInRadiusV488(h,player,unit,pid)
{
    if (!MonsterBossProbeReadV1(h,D2ReadU32(h,player+0x2C),0x20,pb)
        || !MonsterBossProbeReadV1(h,D2ReadU32(h,unit+0x2C),0x20,mb))
        return false
    level := CoordLevelV14(h,NumGet(pb,0x1C,"UInt"))
    if (!BossSearchActiveV430(pid,level) || CoordLevelV14(h,NumGet(mb,0x1C,"UInt"))!=level)
        return false
    x := NumGet(mb,2,"UShort"),y := NumGet(mb,6,"UShort")
    areaV503 := BOCombatAreaV447(pb)
    ok := Abs(x-areaV503.x)+Abs(y-areaV503.y)<=areaV503.radius
    if (!ok)
        PortalLogWriteV66("BO_ATTACK_RADIUS_REJECT uid=" . D2ReadU32(h,unit+12) . " next=RESCAN_WITHOUT_CHASE","BO_ATTACK_RADIUS_REJECT",1000)
    return ok
}

BOCombatAreaV447(ByRef pb)
{
    global stage2FlowV380,pickupRadius
    s := stage2FlowV380.searchV430,c := s.itemCenterV447
    if (IsObject(c))
    {
        c.radius := Max(1,pickupRadius)
        return {x:c.x,y:c.y,radius:c.radius,radiusSq:c.radius*c.radius,source:"BO_GROUND_ITEM_PICKUP_RADIUS",row:0}
    }
    radius := Max(1,pickupRadius),origin := s.fightOriginV488
    cx := IsObject(origin) ? origin.x : NumGet(pb,2,"UShort")
    cy := IsObject(origin) ? origin.y : NumGet(pb,6,"UShort")
    return {x:cx,y:cy,radius:radius,radiusSq:radius*radius,source:"BO_FIXED_PICKUP_RADIUS",row:0}
}

BOItemCenterUpdateV447(h,player,ByRef pb,pid)
{
    global stage2FlowV380,pickupRadius,pickupRoundResetV1,monsterCombatUidV45,monsterChaseV44,monsterRoadAreaV51
    r := stage2FlowV380,s := r.searchV430
    if (IsObject(s.itemCenterV447))
        return true
    seen := {},best := false,bestDist := 1.0e30
    px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort")
    for _,room in MonsterLoadedRoomsV20(h,NumGet(pb,0x1C,"UInt"))
    {
        unit := D2ReadU32(h,room+0x74)
        Loop, 4096
        {
            if (!unit || seen.HasKey(unit))
                break
            seen[unit] := true
            if (!MonsterBossProbeReadV1(h,unit,0xEC,ub))
                return false
            next := NumGet(ub,0xE8,"UInt"),mode := NumGet(ub,0x10,"UInt")
            data := NumGet(ub,0x14,"UInt"),uid := NumGet(ub,0x0C,"UInt")
            cls := NumGet(ub,4,"UInt")
            if (NumGet(ub,0,"UInt")=4 && uid && cls!=1214 && (mode=3 || mode=5) && data
                && PickupFileHasRuleV97(cls,D2ReadU8V18(h,data),data,h,unit))
            {
                path := NumGet(ub,0x2C,"UInt")
                if (path && MonsterBossProbeReadV1(h,path,0x14,ip))
                {
                    x := NumGet(ip,0x0C,"UInt"),y := NumGet(ip,0x10,"UInt")
                    dist := Abs(x-px)+Abs(y-py)
                    if (x && y && dist<=pickupRadius && dist<bestDist)
                        best := {uid:uid,cls:cls,x:x,y:y,radius:Max(1,pickupRadius)},bestDist := dist
                }
            }
            unit := next
        }
    }
    if (!IsObject(best))
        return false
    s.itemCenterV447 := best,s.motion := false,s.exploreV432 := false,s.leftDetourV433 := false
    s.commonScanV446 := false,s.pickupPassV441 := false,s.phase := "ITEM_CLEAR"
    s.afterCombatPickupV486 := true
    monsterCombatUidV45 := 0,monsterChaseV44 := false,monsterRoadAreaV51 := false
    pickupRoundResetV1 := true
    if (AutoMonsterPacketCleanupV1())
        NativeMovePointV14(pid,px,py,s.level,false,false,true,false,{searchV430:s,stop:true})
    PortalLogWriteV66("BO_ITEM_CENTER_LOCK uid=" . best.uid . " class=" . best.cls
        . " center=" . best.x . "," . best.y . " radius=" . best.radius
        . " route=HOLD next=CLEAR_ITEM_RADIUS_THEN_PICKUP")
    return true
}

BOCommonPublishV446(pid,target,complete,px,py)
{
    global stage2FlowV380
    s := stage2FlowV380.searchV430
    s.commonScanV446 := {at:A_TickCount,complete:complete,target:IsObject(target)}
    if (IsObject(target))
    {
        if (!s.afterCombatPickupV486)
        {
            s.fightOriginV488 := {x:px,y:py}
            if (BOFirstFarmMapV497(s))
            {
                s.chaseOriginV497 := {x:px,y:py},s.chasePositionV497 := {x:px,y:py}
                s.chaseHeadingV497 := false
            }
        }
        s.phase := "FIGHT",s.pickupPassV441 := false,s.afterCombatPickupV486 := true
        s.prePickupSortedV448 := false,s.prePickupDoneV448 := false,s.prePickupAtV448 := 0
        s.motion := false
        d := s.leftDetourV433
        if (IsObject(d))
            d.since := 0,d.queued := 0,d.last := 0
    }
}

BOCombatStopWalkV482(h,player,ByRef pb,s)
{
    if (!s.walkingV482)
        return false
    mode := D2ReadU32(h,player+0x10)
    if (mode!=2 && mode!=3 && mode!=6)
    {
        s.walkingV482 := false
        return false
    }
    px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort")
    if (NativeMovePointV14(s.pid,px,py,s.level,false,false,true,false,{searchV430:s,stop:true}))
        PortalLogWriteV66("BO_ZIGZAG_COMBAT_STOP live_xy=" . px . "," . py . " next=ATTACK_THEN_RESUME_SAME_LEG")
    return true
}

BOCommonClearV446(pid)
{
    global stage2FlowV380
    if (!BOCommonActiveV444(pid))
        return false
    c := stage2FlowV380.searchV430.commonScanV446
    return IsObject(c) && c.complete && !c.target && A_TickCount-c.at<500
}

BOPrePickupV448(h,player,pid,s)
{
    global gameItemActionOwner,pickupTimerBusy,scosEntryV162
    wasReadyV453 := s.prePickupDoneV448
    if (pickupTimerBusy || gameItemActionOwner!="" || !AutoMonsterPacketCleanupV1())
        return false
    if (!s.prePickupAtV448)
        s.prePickupAtV448 := A_TickCount
    if (!GameItemActionBeginV4("BOPrePickup","cube",true))
        return false
    errorV448 := "",clearV448 := "WAIT"
    try
    {
        if (!s.prePickupSortedV448)
        {
            ctx := {pid:pid,h:h,player:player,inv:D2ReadU32(h,player+0x60)
                ,scosEntry:true,entryStateV42:scosEntryV162}
            SigSortContainerV191(ctx)
            SigCheckV147(ctx)
            s.prePickupSortedV448 := true
            PortalLogWriteV66("BO_PRE_PICKUP_SORT_DONE next=SELECT_GROUND_ITEM")
        }
        clearV448 := "CLEAR"
    }
    catch e
        errorV448 := e.Message
    finally
        GameItemActionEndV4("BOPrePickup")
    if (errorV448!="")
    {
        PortalLogWriteV66("BO_PRE_PICKUP_WAIT reason=" . errorV448 . " stop=0 next=RETRY_SORT_AND_TRANSFER","BO_PRE_PICKUP_WAIT",1000)
        return false
    }
    if (clearV448!="CLEAR")
    {
        PortalLogWriteV66("BO_FINAL_TRANSFER_WAIT result=" . clearV448 . " stop=0 next=VERIFY_OR_RETRY","BO_FINAL_TRANSFER_WAIT",1000)
        return false
    }
    s.prePickupDoneV448 := true
    if (wasReadyV453)
        return true
    PortalLogWriteV66("BO_PRE_PICKUP_READY sort=OK next=SELECT_AND_CHECK_PICKUP")
    return false
}

BOErrorReportV463(r,reason,source := "")
{
    global scosEntryV162,cainPauseFarmV361
    if (!IsObject(r) || r.map!="BO" || scosEntryV162!=r)
        return false
    messageV463 := "BO GĐ" . r.boStageV413 . "/" . r.phase . ": " . reason
    if (source!="")
        messageV463 .= " | " . source
    if (r.errorTextV463=messageV463 && A_TickCount-r.errorAtV463<2000)
        return true
    r.errorTextV463 := messageV463,r.errorAtV463 := A_TickCount
    r.retryAtV237 := A_TickCount+1000
    if (r.until<A_TickCount+60000)
        r.until := A_TickCount+60000
    if (r.phase="FARM")
        cainPauseFarmV361 := false
    FonInfoPushV385("[BO LỖI] " . messageV463)
    PortalLogWriteV66("BO_ERROR_RETAINED stage=" . r.boStageV413 . " phase=" . r.phase
        . " reason=" . reason . " source=" . source . " auto_stop=0 state=KEPT next=RECHECK_CURRENT_STEP")
    return true
}

BOFinalHuntTickV454(h,player,ByRef pb,pid)
{
    global scosEntryV162,coordCastPendingV50,pestiPointPendingV28,lastAttackPendingV20
    global monsterCombatUidV45,monsterChaseV44,monsterRoadAreaV51
    r := scosEntryV162
    r.boPickupPriorityV503 := true
    try
        pickupFirstV503 := FarmPickupFirstV75()
    finally
        r.boPickupPriorityV503 := false
    if (pickupFirstV503)
        return true
    if (StateBuffTickV17(h,player,pb,pid) || CombatRecoverTickV48(h,pb,pid,false))
        return true
    if (!r.boBossKilledV454)
    {
        if (CainHuntBossTickV403(h,player,pb,pid))
            return true
        if (r.boBossKilledV454)
            return true
        monsterCombatUidV45 := 0,monsterChaseV44 := false,monsterRoadAreaV51 := false
        CoordRouteObserveV18(h,pb,pid)
        if (!CoordStuckTickV84(h,pb,pid))
            CoordMoveWhenClearV14(h,pb,pid)
        PortalLogWriteV66("BO_FINAL_FIND_BOSS class=1584 pickup=WAIT_FOR_DEATH"
            ,"BO_FINAL_FIND_BOSS",1000)
        return true
    }
    if (!r.boFinalPickupPreparedV454)
    {
        if (!GameItemActionBeginV4("BOFinalPrePickup","cube",true))
            return true
        try
        {
            ctx := {pid:pid,h:h,player:player,inv:D2ReadU32(h,player+0x60)
                ,scosEntry:true,entryStateV42:r}
            if (!r.boFinalSortedV454)
            {
                SigSortContainerV191(ctx)
                SigCheckV147(ctx)
                r.boFinalSortedV454 := true
            }
            r.boFinalPickupPreparedV454 := true
        }
        finally
            GameItemActionEndV4("BOFinalPrePickup")
        return true
    }
    FarmPickupFirstV75()
    return true
}

BOBuffPointV454(hwnd)
{
    ; Doc chinh PID cua cua so game dang nhan buff (foreground/background).
    if (!hwnd)
        return false
    WinGet, pid, PID, ahk_id %hwnd%
    if (!pid)
        return false
    base := D2GetModuleBaseV35(pid,"D2Client.dll")
    h := base ? D2OpenProcess(pid) : 0
    if (!h)
        return false
    try
    {
        player := D2ReadU32(h,base+0x11BBFC),path := player ? D2ReadU32(h,player+0x2C) : 0
        if (!MonsterBossProbeReadV1(h,path,0x20,pb))
            return false
        view := AutoMonsterAttackViewV1(h,base,hwnd,path)
        if (!IsObject(view))
            return false
        xV454 := Round((NumGet(pb,8,"Int")-view.ox)*view.cw/view.gw)
        yV454 := Round((NumGet(pb,12,"Int")-view.oy)*view.ch/view.gh)
        if (xV454<16 || xV454>=view.cw-16 || yV454<16 || yV454>=view.ch-16)
            return false
        return {x:xV454,y:yV454}
    }
    finally
        DllCall("CloseHandle","Ptr",h)
}

BOFinalRouteActiveV451(pid := 0)
{
    global scosEntryV162,backgroundPidV63,farmControlOwnerV186
    if (!pid)
        pid := backgroundPidV63
    return farmControlOwnerV186="BO" && IsObject(scosEntryV162)
        && scosEntryV162.map="BO" && scosEntryV162.pid=pid
        && scosEntryV162.boStageV413=4 && scosEntryV162.phase="FARM"
}

BOCommonActiveV444(pid := 0)
{
    global stage2FlowV380,backgroundPidV63,farmControlOwnerV186
    if (!pid)
        pid := backgroundPidV63
    return farmControlOwnerV186="BO" && BossSearchActiveV430(pid)
}

BOPickupPriorityV421(h,player,ByRef pb,pid)
{
    global stage2FlowV380,pickupImageOn,pickupRadius,pickupFarmWorkV75,pickupRoundResetV1
    s := stage2FlowV380.searchV430
    if (!pickupImageOn || !Stage2PickupEnabledV9())
        return false
    px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort"),seen := {},found := false
    for _,room in MonsterLoadedRoomsV20(h,NumGet(pb,0x1C,"UInt"))
    {
        unit := D2ReadU32(h,room+0x74)
        Loop, 1024
        {
            if (!unit || seen.HasKey(unit))
                break
            seen[unit] := true
            if (D2ReadU32(h,unit)=4 && (D2ReadU32(h,unit+0x10)=3 || D2ReadU32(h,unit+0x10)=5))
            {
                data := D2ReadU32(h,unit+0x14),cls := D2ReadU32(h,unit+4),path := D2ReadU32(h,unit+0x2C)
                if (data && path)
                {
                    ix := D2ReadU32(h,path+0x0C),iy := D2ReadU32(h,path+0x10)
                    if (cls!=1214 && Abs(ix-px)+Abs(iy-py)<=pickupRadius
                        && PickupFileHasRuleV97(cls,D2ReadU8V18(h,data),data,h,unit))
                    {
                        found := true
                        break
                    }
                }
            }
            next := D2ReadU32(h,unit+0xE8)
            if (next=unit)
                break
            unit := next
        }
        if (found)
            break
    }
    if (!found && !pickupFarmWorkV75)
    {
        s.pickupHoldV421 := false
        return false
    }
    if (!s.pickupHoldV421)
    {
        s.pickupHoldV421 := true,s.motion := false,s.leftDetourV433 := false
        s.prePickupSortedV448 := false,s.prePickupDoneV448 := false,s.prePickupAtV448 := 0
        pickupRoundResetV1 := true
    }
    s.commonScanV446 := false
    modeV503 := D2ReadU32(h,player+0x10)
    s.walkingV482 := modeV503=2 || modeV503=3 || modeV503=6
    if (BOCombatStopWalkV482(h,player,pb,s))
        return true
    if (!BOPrePickupV448(h,player,pid,s))
        return true
    s.pickupPriorityV421 := true
    try
        working := FarmPickupFirstV75()
    finally
        s.pickupPriorityV421 := false
    PortalLogWriteV66("BO_PICKUP_PRIORITY matching_drop=" . found . " working=" . working
        . " movement=PAUSED","BO_PICKUP_PRIORITY",1000)
    return pickupImageOn && (found || working)
}

BOCommonPickupGateV444(h,player,ByRef pb,pid)
{
    global stage2FlowV380,ticketPickupWaitV279,pickupRoundResetV1
    s := stage2FlowV380.searchV430
    if (!BOCommonClearV446(pid))
        return "WAIT"
    s.phase := "PICKUP"
    global pickupImageOn
    if (!pickupImageOn)
        return "WAIT"
    if (!BOPrePickupV448(h,player,pid,s))
        return "WAIT"
    if (!s.pickupPassV441)
    {
        s.pickupPassV441 := true
        ticketPickupWaitV279 := {pid:pid,level:s.level,checks:0,emptyAt:0,done:false,scanAt:0,remaining:-1,active:true}
        pickupRoundResetV1 := true
    }
    pickupWorkingV448 := FarmPickupFirstV75()
    if (!pickupImageOn)
    {
        s.prePickupDoneV448 := false,s.prePickupSortedV448 := false
        PortalLogWriteV66("BO_PICKUP_PAUSED pickup=OFF stop=0 next=WAIT_FOR_PICKUP_ON_THEN_SORT_TRANSFER","BO_PICKUP_PAUSED",1000)
        return "WAIT"
    }
    if (pickupWorkingV448 || !BossSearchPickupDoneV438(pid))
        return "WAIT"
    if (!BOPickupAllowedV441(h,player,pid))
        return "WAIT"
    if (Stage2ItemCheckV380(h,player,pid))
        return "WAIT"
    return "CLEAR"
}

BOCommonMoveV444(h,ByRef pb,pid)
{
    global stage2FlowV380
    s := stage2FlowV380.searchV430
    if (IsObject(s.itemCenterV447))
        return false
    if (!BOCommonClearV446(pid) || s.afterCombatPickupV486)
    {
        PortalLogWriteV66("BO_MOVE_WAIT reason=FRESH_SCAN_OR_PICKUP_PROOF clear=" . BOCommonClearV446(pid)
            . " pickup_done=" . BossSearchPickupDoneV438(pid),"BO_MOVE_WAIT",1000)
        return false
    }
    current := D2ReadU32(h,NumGet(pb,0x1C,"UInt")+0x10)
    if (D2ReadU32(h,current+0x58)!=s.levelPtr)
    {
        PortalLogWriteV66("BO_MOVE_WAIT reason=LIVE_MAP_CHANGED","BO_MOVE_WAIT",1000)
        return false
    }
    BossSearchRoomsObserveV432(s,current)
    node := RoomExploreReadV89(h,current,s.level)
    if (!IsObject(node))
        return false
    if (!s.preferNewRoomsV507)
    {
        s.preferNewRoomsV507 := true,s.motion := false,s.exploreV432 := false
        PortalLogWriteV66("BO_NEW_ROOM_MODE visited=" . s.roomVisitsV432.Count() . " zigzag=OFF old_room_fallback=OFF")
    }
    s.leftDetourV433 := false,s.zigzagV474 := false
    movedV482 := BossSearchExploreTickV432(h,pb,s,node)
    s.commonScanV446 := false
    return movedV482
}

BORoomCrossRetryV507(s,reason)
{
    e := s.exploreV432
    if (!IsObject(e))
        return true
    if (BossSearchEdgeAdvanceV432(s))
    {
        PortalLogWriteV66("BO_NEW_ROOM_CROSS_RETRY from=" . V92Hex(e.from) . " to=" . V92Hex(e.to)
            . " variant=" . e.variant . " reason=" . reason . " zigzag=OFF")
        return true
    }
    BOBlockCurrentPassageV473(s)
    s.exploreV432 := false,s.motion := false,s.leftDetourV433 := false,s.zigzagV474 := false
    s.unvisitedSearchV462 := false,s.phase := "SEARCH"
    PortalLogWriteV66("BO_NEW_ROOM_EDGE_SKIP from=" . V92Hex(e.from) . " to=" . V92Hex(e.to)
        . " reason=" . reason . " next=OTHER_NEW_ROOM visited=PRESERVED zigzag=OFF")
    return true
}

BOCommonFinishReadyV444(h,player,s)
{
    return BOCommonClearV446(s.pid) && BossSearchPickupDoneV438(s.pid)
        && BOPickupAllowedV441(h,player,s.pid)
}

BOPickupAllowedV441(h,player,pid)
{
    global stage2FlowV380,scosEntryV162
    if (!IsObject(scosEntryV162) || scosEntryV162.map!="BO"
        || scosEntryV162.pid!=pid || scosEntryV162.phase!="FARM")
        return true
    if (scosEntryV162.boPickupPriorityV503)
        return true
    if (scosEntryV162.boStageV413=4)
        return scosEntryV162.boBossKilledV454 ? true : false
    if (!BossSearchActiveV430(pid))
        return false
    s := stage2FlowV380.searchV430
    if (s.pickupPriorityV421)
        return true
    if (!s.afterCombatPickupV486)
        return false
    if (s.phase!="PICKUP")
        return false
    return BOCommonClearV446(pid)
}


BossSearchCleanupReadyV431(h,player,r)
{
    global ticketPickupWaitV279,pickupRoundResetV1
    if (!IsObject(r.searchV430))
        return true
    s := r.searchV430
    if (s.owner="BO")
        return BOCommonFinishReadyV444(h,player,s)
    if (IsObject(s.cleanupV431))
        return s.cleanupV431.done && BossSearchPickupDoneV438(s.pid)
    path := D2ReadU32(h,player+0x2C)
    if (!MonsterBossProbeReadV1(h,path,0x20,pb))
        return false
    room := NumGet(pb,0x1C,"UInt"),room2 := room ? D2ReadU32(h,room+0x10) : 0
    if (CoordLevelV14(h,room)!=s.level || D2ReadU32(h,room2+0x58)!=s.levelPtr)
        return false
    radius := s.owner="BO" ? MonsterRadiusGetV239() : MonsterScanRadiusV20(s.level)
    if (radius<=0)
        return false
    s.cleanupV431 := {x:NumGet(pb,2,"UShort"),y:NumGet(pb,6,"UShort"),radius:radius
        ,radiusSq:radius*radius,done:false,emptyAt:0}
    ticketPickupWaitV279 := {pid:s.pid,level:s.level,checks:0,emptyAt:0,done:false,scanAt:0,remaining:-1,active:true}
    pickupRoundResetV1 := true
    s.phase := "CLEANUP",s.boss := false,s.motion := false,s.targetRoom := 0
    PortalLogWriteV66("BOSS_ITEM_READY class=" . r.itemClass . " in_cube=1 done=0"
        . " cleanup_center=" . s.cleanupV431.x . "," . s.cleanupV431.y . " radius=" . radius
        . " next=CLEAR_RADIUS_BEFORE_USE_OR_NEXT_STAGE")
    return false
}

BossSearchCleanupTickV431(h,player,ByRef pb,s,scan)
{
    c := s.cleanupV431
    if (!IsObject(c) || !scan.known)
        return true
    if (s.owner!="BO")
        FarmPickupFirstV75()
    target := false,count := 0,best := 1.0e30
    for _,a in scan.allV431
    {
        if ((a.x-c.x)**2+(a.y-c.y)**2>c.radiusSq
            && (s.owner!="BO" || a.dist>c.radiusSq))
            continue
        count++
        if (s.retryUIDs.HasKey(a.uid) && A_TickCount<s.retryUIDs[a.uid])
            continue
        if (!IsObject(target) || (a.priority && !target.priority)
            || (a.priority=target.priority && a.dist<best))
            target := a,best := a.dist
    }
    if (count)
    {
        c.done := false,c.emptyAt := 0
        if (s.owner="BO")
            s.phase := "FIGHT"
        if (IsObject(target))
            BossSearchHoldAttackV436(h,player,pb,s,target)
        PortalLogWriteV66("BOSS_ITEM_CLEANUP remaining=" . count . " radius=" . c.radius
            . " done=0 item_use=WAIT","BOSS_ITEM_CLEANUP",1000)
        return true
    }
    if (s.owner="BO")
    {
        s.phase := "PICKUP"
        FarmPickupFirstV75()
    }
    if (!c.emptyAt)
        c.emptyAt := A_TickCount
    else if (A_TickCount-c.emptyAt>=500)
    {
        c.done := true,s.motion := false
        PortalLogWriteV66("BOSS_ITEM_CLEANUP_DONE remaining=0 confirmed=FULL_LIVE_SCANS"
            . " next=ITEM_DONE_THEN_CALLER_NEXT_STAGE")
    }
    return true
}

BossSearchRoomsObserveV432(s,current)
{
    if (!IsObject(s.roomVisitsV432))
        s.roomVisitsV432 := {},s.currentRoomV432 := 0,s.previousRoomV432 := 0,s.stepsV432 := 0
    if (s.currentRoomV432=current)
        return
    old := s.currentRoomV432
    if (s.owner="BO" && old && IsObject(s.blockedPassagesV473))
        s.blockedPassagesV473.Delete(BOBlockedPassageKeyV473(old,current))
    s.previousRoomV432 := old,s.currentRoomV432 := current
    s.roomVisitsV432[current] := s.roomVisitsV432.HasKey(current) ? s.roomVisitsV432[current]+1 : 1
    if (s.owner="BO")
        PortalLogWriteV66("BO_ROOM_VISITED room=" . V92Hex(current) . " unique_visited=" . s.roomVisitsV432.Count())
    if (s.owner="BO" && IsObject(s.leftDetourV433))
        return
    if (IsObject(s.exploreV432))
    {
        s.stepsV432++
        PortalLogWriteV66("BOSS_SEARCH_EMPTY_ROOM_ENTER from=" . V92Hex(old) . " to=" . V92Hex(current)
            . " steps=" . s.stepsV432 . " next=RESCAN_BOSS_AND_MONSTERS")
        s.exploreV432 := false,s.motion := false,s.leftDetourV433 := false
        if (s.phase="EXPLORE")
            s.phase := "SEARCH"
    }
}

BossSearchPassageV432(a,b,px,py,variant := 0)
{
    if (!IsObject(a) || !IsObject(b))
        return false
    loY := Max(a.y,b.y)+1,hiY := Min(a.y+a.h,b.y+b.h)-2
    loX := Max(a.x,b.x)+1,hiX := Min(a.x+a.w,b.x+b.w)-2
    insetX := Min(6,b.w-2),insetY := Min(6,b.h-2),axis := ""
    if (hiY>=loY && a.x+a.w=b.x)
        fixed := b.x+insetX,axis := "Y",lo := loY,hi := hiY,along := py
    else if (hiY>=loY && b.x+b.w=a.x)
        fixed := b.x+b.w-1-insetX,axis := "Y",lo := loY,hi := hiY,along := py
    else if (hiX>=loX && a.y+a.h=b.y)
        fixed := b.y+insetY,axis := "X",lo := loX,hi := hiX,along := px
    else if (hiX>=loX && b.y+b.h=a.y)
        fixed := b.y+b.h-1-insetY,axis := "X",lo := loX,hi := hiX,along := px
    else if (px<b.x || px>=b.x+b.w)
        fixed := px<b.x ? b.x+insetX : b.x+b.w-1-insetX,axis := "Y",lo := b.y+1,hi := b.y+b.h-2,along := py
    else if (py<b.y || py>=b.y+b.h)
        fixed := py<b.y ? b.y+insetY : b.y+b.h-1-insetY,axis := "X",lo := b.x+1,hi := b.x+b.w-2,along := px
    if (axis="" || hi<lo)
        return false
    along := variant=1 ? lo : variant=2 ? hi : variant=3 ? Round(lo+(hi-lo)*0.25)
        : variant=4 ? Round(lo+(hi-lo)*0.75) : Max(lo,Min(hi,along))
    return axis="Y" ? {x:fixed,y:along} : {x:along,y:fixed}
}

BossSearchEdgeAdvanceV432(s)
{
    e := s.exploreV432
    if (!IsObject(e) || e.variant>=4)
        return false
    e.variant++,s.motion := false,s.leftDetourV433 := false
    PortalLogWriteV66("BOSS_SEARCH_FOLLOW_EDGE to=" . V92Hex(e.to) . " variant=" . e.variant . " next=WALK_SIDE")
    return true
}

BOBlockedPassageKeyV473(a,b)
{
    return a<b ? a . "|" . b : b . "|" . a
}

BOBlockedPassageV473(s,a,b)
{
    return s.owner="BO" && IsObject(s.blockedPassagesV473)
        && s.blockedPassagesV473.HasKey(BOBlockedPassageKeyV473(a,b))
}

BOBlockCurrentPassageV473(s)
{
    e := s.exploreV432
    if (!IsObject(e) || !e.from || !e.to)
        return
    if (!IsObject(s.blockedPassagesV473))
        s.blockedPassagesV473 := {}
    key := BOBlockedPassageKeyV473(e.from,e.to)
    previousV473 := s.blockedPassagesV473[key]
    nextVariantV473 := Max(e.variant+1,IsObject(previousV473) ? previousV473.variant : 1)
    failedPointsV473 := IsObject(previousV473) ? previousV473.points : {}
    failedGoalV473 := BossSearchPassageV432(e.a,e.b,e.x,e.y,e.variant)
    if (IsObject(failedGoalV473))
        failedPointsV473[failedGoalV473.x . "|" . failedGoalV473.y] := true
    s.blockedPassagesV473[key] := {variant:nextVariantV473,points:failedPointsV473}
    s.unvisitedSearchV462 := false
    PortalLogWriteV66("BO_BLOCKED_PASSAGE from=" . V92Hex(e.from) . " to=" . V92Hex(e.to)
        . " failed_variant=" . e.variant . " next=OTHER_CONNECTION visited=PRESERVED")
}

BOUnvisitedNextV462(h,s,node,px,py)
{
    searchV462 := s.unvisitedSearchV462
    if (!IsObject(searchV462) || searchV462.current!=node.r2)
    {
        searchV462 := {current:node.r2,queue:[{room:node.r2,first:0}],seen:{},index:1}
        searchV462.seen[node.r2] := true
        s.unvisitedSearchV462 := searchV462
    }
    queueV462 := searchV462.queue,seenV462 := searchV462.seen,indexV462 := searchV462.index
    startedV462 := A_TickCount
    while (indexV462<=queueV462.Length() && seenV462.Count()<2048)
    {
        entryV462 := queueV462[indexV462],indexV462++
        hereV462 := entryV462.room=node.r2 ? node : RoomExploreReadV89(h,entryV462.room,s.level)
        if (!IsObject(hereV462))
            continue
        for _,nextV462 in hereV462.links
        {
            if (seenV462.HasKey(nextV462) || s.blockedRooms.HasKey(nextV462)
                || BOBlockedPassageV473(s,entryV462.room,nextV462))
                continue
            otherV462 := RoomExploreReadV89(h,nextV462,s.level)
            if (!IsObject(otherV462))
                continue
            firstV462 := entryV462.first ? entryV462.first : nextV462
            hopV462 := firstV462=nextV462 ? otherV462 : RoomExploreReadV89(h,firstV462,s.level)
            passageV462 := BossSearchPassageV432(node,hopV462,px,py)
            if (!IsObject(passageV462))
                continue
            seenV462[nextV462] := true
            if (!s.roomVisitsV432.HasKey(nextV462))
            {
                PortalLogWriteV66("BO_UNVISITED_TARGET current=" . V92Hex(node.r2) . " first_hop=" . V92Hex(firstV462)
                    . " target_unvisited=" . V92Hex(nextV462) . " visited=" . s.roomVisitsV432.Count())
                s.unvisitedSearchV462 := false
                return {node:hopV462,goal:passageV462,frontier:nextV462}
            }
            queueV462.Push({room:nextV462,first:firstV462})
        }
        if (A_TickCount-startedV462>120)
        {
            searchV462.index := indexV462
            PortalLogWriteV66("BO_UNVISITED_SEARCH_WAIT read_rooms=" . seenV462.Count(),"BO_UNVISITED_SEARCH_WAIT",1000)
            return {waiting:true}
        }
    }
    s.unvisitedSearchV462 := false
    return false
}

BossSearchExploreTickV432(h,ByRef pb,s,node)
{
    px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort"),current := node.r2
    e := s.exploreV432
    if (!IsObject(e) || e.from!=current || s.blockedRooms.HasKey(e.to))
    {
        best := 1.0e30,picked := false,pickedGoal := false,pickedVariantV473 := 0
        if (s.owner="BO")
        {
            unvisitedV462 := BOUnvisitedNextV462(h,s,node,px,py)
            if (IsObject(unvisitedV462) && unvisitedV462.waiting)
                return true
            if (IsObject(unvisitedV462))
                picked := unvisitedV462.node,pickedGoal := unvisitedV462.goal
        }
        if (!IsObject(picked))
        for _,next in node.links
        {
            if (s.blockedRooms.HasKey(next) || BOBlockedPassageV473(s,current,next)
                || (s.owner="BO" && s.preferNewRoomsV507 && s.roomVisitsV432.HasKey(next)))
                continue
            other := RoomExploreReadV89(h,next,s.level)
            goal := BossSearchPassageV432(node,other,px,py)
            if (!IsObject(goal))
                continue
            visits := s.roomVisitsV432.HasKey(next) ? s.roomVisitsV432[next] : 0
            rank := s.owner="BO"
                ? visits*100000000+(next=s.previousRoomV432 ? 10000 : 0)+(goal.x-px)**2+(goal.y-py)**2
                : visits*1000000+(next=s.previousRoomV432 ? 1000000000 : 0)+(goal.x-px)**2+(goal.y-py)**2
            if (rank<best)
                best := rank,picked := other,pickedGoal := goal
        }
        if (!IsObject(picked) && s.owner="BO")
        {
            for _,next in node.links
            {
                failedV473 := s.blockedPassagesV473[BOBlockedPassageKeyV473(current,next)]
                if (!IsObject(failedV473) || failedV473.variant>4 || s.blockedRooms.HasKey(next)
                    || (s.preferNewRoomsV507 && s.roomVisitsV432.HasKey(next)))
                    continue
                other := RoomExploreReadV89(h,next,s.level)
                goal := false
                while (failedV473.variant<=4)
                {
                    goal := BossSearchPassageV432(node,other,px,py,failedV473.variant)
                    if (IsObject(goal) && !failedV473.points.HasKey(goal.x . "|" . goal.y))
                        break
                    failedV473.variant++,goal := false
                }
                if (!IsObject(goal))
                    continue
                picked := other,pickedGoal := goal,pickedVariantV473 := failedV473.variant
                PortalLogWriteV66("BO_PASSAGE_ALTERNATIVE from=" . V92Hex(current) . " to=" . V92Hex(next)
                    . " variant=" . pickedVariantV473 . " reason=NO_OTHER_CONNECTION")
                break
            }
        }
                if (!IsObject(picked))
        {
            if (s.owner="BO")
            {
                if (!IsObject(s.zigzagV474))
                    s.zigzagV474 := {dx:1,dy:0,goal:false,leg:0}
                return BOZigzagTickV474(h,pb,s)
            }
            if (s.owner!="BO")
                s.blockedRooms := {}
            PortalLogWriteV66("BOSS_SEARCH_ROOM_WAIT current=" . V92Hex(current)
                . " neighbors=" . node.links.Length() . " reason=NO_READABLE_UNBLOCKED_LINK","BOSS_SEARCH_ROOM_WAIT",2000)
            return true
        }
        s.exploreV432 := e := {from:current,to:picked.r2,a:node,b:picked,x:px,y:py,variant:pickedVariantV473}
        s.motion := false,s.phase := "EXPLORE",s.targetRoom := picked.r2
        PortalLogWriteV66("BOSS_SEARCH_EMPTY_ROOM_SELECT from=" . V92Hex(current) . " to=" . V92Hex(picked.r2)
            . " goal=" . pickedGoal.x . "," . pickedGoal.y . " monster_required=0 route=NONE")
    }
    goal := BossSearchPassageV432(e.a,e.b,e.x,e.y,e.variant)
    if (!IsObject(goal))
    {
        s.blockedRooms[e.to] := A_TickCount+3000
        BossSearchReleaseV430(s,"UNREADABLE_ROOM_SIDE")
        return true
    }
    dist := (goal.x-px)**2+(goal.y-py)**2
    if (dist<=4 && current!=e.to)
    {
        if (s.owner="BO")
        {
            if (s.preferNewRoomsV507)
                return BORoomCrossRetryV507(s,"POINT_REACHED_ROOM_NOT_ENTERED")
            turnSeedV426 := {x:px+(goal.x-e.x),y:py+(goal.y-e.y)}
            if (turnSeedV426.x=px && turnSeedV426.y=py)
                turnSeedV426.y := py-1
            global chaseCheckSecV9
            if (!e.sideWaitV452)
                e.sideWaitV452 := A_TickCount
            if (A_TickCount-e.sideWaitV452<Max(1,chaseCheckSecV9)*1000)
                return true
            if (!IsObject(s.leftDetourV433))
                BossSearchLeftBeginV433(s,turnSeedV426,px,py,"ROOM|" . e.to)
            return BossSearchLeftTickV433(h,pb,s,turnSeedV426,"ROOM|" . e.to)
        }
        if (!BossSearchEdgeAdvanceV432(s))
        {
            s.blockedRooms[e.to] := A_TickCount+3000
            BossSearchReleaseV430(s,"SIDE_REACHED_WITHOUT_ROOM_TRANSFER")
        }
        return true
    }
    target := {uid:0,cls:0,room2:e.to,x:goal.x,y:goal.y,level:s.level,dist:dist,priority:false}
    return BossSearchMoveV430(h,pb,s,target)
}

BORecoveryBeginV452(s,target,px,py,key)
{
    BOBlockCurrentPassageV473(s)
    dx := target.x-px,dy := target.y-py
    oldSweepV481 := s.zigzagV474
    if (IsObject(oldSweepV481))
    {
        dx := oldSweepV481.dx,dy := oldSweepV481.dy
        PortalLogWriteV66("BO_ZIGZAG_SKIP_REMAINDER live_xy=" . px . "," . py
            . " cancelled_goal=" . target.x . "," . target.y . " original_heading=" . dx . "," . dy
            . " next=SIDE_2BK_THEN_REVERSE_SAME_AXIS")
    }
    if (!dx && !dy)
        return false
    if (BOFirstFarmMapV497(s))
    {
        length := Sqrt(dx*dx+dy*dy)
        dx := dx/length,dy := dy/length
    }
    else if (Abs(dx)>=Abs(dy))
        dx := dx>=0 ? 1 : -1,dy := 0
    else
        dy := dy>=0 ? 1 : -1,dx := 0
    if (!IsObject(s.zigzagSideV474))
        s.zigzagSideV474 := {x:-dy,y:dx}
    side := s.zigzagSideV474
    pairSignV504 := s.turnPairLastV504 ? -s.turnPairLastV504 : 1
    crossV504 := dx*side.y-dy*side.x
    if ((crossV504>=0 ? 1 : -1)!=pairSignV504)
        side := {x:-side.x,y:-side.y}
    s.zigzagSideV474 := side
    d := {key:key,stage:"SIDE_1",originX:px,originY:py,dx:dx,dy:dy,pairSignV504:pairSignV504
        ,sideX:side.x,sideY:side.y,radius:Max(1,MonsterRadiusGetV239())
        ,since:0,last:0,queued:0,probeX:px,probeY:py,attempt:1}
    s.zigzagV474 := false,s.motion := false,s.exploreV432 := false
    s.leftDetourV433 := d
    PortalLogWriteV66("BO_ZIGZAG_PAIR_BEGIN pair=" . (pairSignV504=1 ? "TT" : "PP")
        . " previous=" . (s.turnPairLastV504=1 ? "TT" : s.turnPairLastV504=-1 ? "PP" : "NONE") . " same_pair=BLOCKED")
    BORecoveryGoalV452(d,px,py,"SIDE_1")
    return true
}

BORecoveryGoalV452(d,px,py,stage)
{
    d.stage := stage
    multiplier := 2
    sign := 1
    d.tx := Round(d.originX+d.sideX*d.radius*multiplier*sign)
    d.ty := Round(d.originY+d.sideY*d.radius*multiplier*sign)
    d.since := 0,d.last := 0,d.queued := 0,d.probeX := px,d.probeY := py
    PortalLogWriteV66("BO_ZIGZAG_SIDE attempt=" . d.attempt . " distance=" . d.radius*multiplier
        . " from=" . px . "," . py . " goal=" . d.tx . "," . d.ty . " next=REVERSE")
}

BOZigzagReverseV474(s,d,px,py)
{
    if ((px-d.originX)**2+(py-d.originY)**2>=4)
        s.teleAttemptedV505 := false,s.teleProbeV504 := false
    s.turnPairLastV504 := d.pairSignV504
    if ((px-d.originX)*d.sideX+(py-d.originY)*d.sideY<0)
        s.zigzagSideV474 := {x:-d.sideX,y:-d.sideY}
    s.zigzagV474 := {dx:-d.dx,dy:-d.dy,goal:false,leg:0}
    s.unvisitedSearchV462 := false
    BossSearchReleaseV430(s,"ZIGZAG_SIDE_DONE_REVERSE")
    s.commonScanV446 := false
    PortalLogWriteV66("BO_ZIGZAG_REVERSE from=" . px . "," . py . " heading=" . -d.dx . "," . -d.dy
        . " old_room_target=RELEASED")
}

BOZigzagCornerV480(s,d,px,py)
{
    s.turnPairLastV504 := d.pairSignV504
    angle := 45 * ATan(1) * 4 / 180
    c := Cos(angle), s_val := Sin(angle)
    nextDx := d.dx * c - d.dy * s_val
    nextDy := d.dx * s_val + d.dy * c
    s.zigzagV474 := {dx:nextDx,dy:nextDy,goal:false,leg:0}
    s.zigzagSideV474 := {x:-nextDy,y:nextDx}
    BossSearchReleaseV430(s,"ZIGZAG_SIDE_BLOCKED_TURN_45")
    s.commonScanV446 := false
    PortalLogWriteV66("BO_ZIGZAG_CORNER_45 from=" . px . "," . py
        . " new_heading=" . Round(nextDx,3) . "," . Round(nextDy,3) . " next=CONTINUE_ZIGZAG")
}
BORecoveryTickV452(h,ByRef pb,s)
{
    global chaseCheckSecV9,boMoveMinimumV456
    d := s.leftDetourV433
    if (!IsObject(d))
        return false
    px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort")
    if ((px-d.tx)**2+(py-d.ty)**2<=4)
    {
        BOZigzagReverseV474(s,d,px,py)
        return true
    }
    if (d.since && d.queued>=2 && A_TickCount-d.since>=Max(1,chaseCheckSecV9)*1000)
    {
        travelled := Sqrt((px-d.probeX)**2+(py-d.probeY)**2)
        PortalLogWriteV66("BO_SIDE_MOVE_WINDOW distance=" . Round(travelled,2) . " minimum=" . boMoveMinimumV456
            . " elapsed_ms=" . (A_TickCount-d.since) . " stuck=" . (travelled<Max(5,boMoveMinimumV456)))
        if (travelled<Max(5,boMoveMinimumV456))
        {
            PortalLogWriteV66("BO_ZIGZAG_SIDE_BLOCKED live_xy=" . px . "," . py
                . " planned_distance=" . d.radius*2 . " next=TURN_SWEEP_AXIS_90")
            if (BOFirstMapTeleportV485(h,pb,s,{x:d.tx,y:d.ty}))
                d.since := 0,d.queued := 0,d.probeX := px,d.probeY := py
            else
                BOZigzagCornerV480(s,d,px,py)
            return true
        }
        d.since := 0,d.queued := 0,d.probeX := px,d.probeY := py
    }
    if (A_TickCount-d.last>=250 && NativeMovePointV14(s.pid,d.tx,d.ty,s.level,false,false,true,false,{searchV430:s}))
    {
        d.last := A_TickCount,d.queued++
        if (!d.since)
            d.since := A_TickCount,d.probeX := px,d.probeY := py
    }
    return true
}

BOFirstMapTeleportV485(h,ByRef pb,s,target)
{
    global scosEntryV162,teleportKeyV55,teleportIntervalSecV56,coordManualTeleLastV296,coordGoV59,chaseCheckSecV9
    r := scosEntryV162
    if (!IsObject(r) || r.map!="BO" || r.pid!=s.pid || r.boStageV413!=2 || r.phase!="FARM")
        return false
    if (!BOCommonClearV446(s.pid))
        return true
    if (teleportKeyV55="")
    {
        PortalLogWriteV66("BO_TELE_FIRST_SKIP reason=TELE_KEY_EMPTY next=ZIGZAG","BO_TELE_FIRST_SKIP",1000)
        return false
    }
    px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort"),probeV504 := s.teleProbeV504
    if (IsObject(probeV504))
    {
        movedV504 := (px-probeV504.x)**2+(py-probeV504.y)**2>=4
        if (!movedV504 && A_TickCount-probeV504.at<Max(0.5,chaseCheckSecV9)*1000)
            return true
        s.teleProbeV504 := false
        if (!movedV504)
        {
            PortalLogWriteV66("BO_TELE_FIRST_NO_PROGRESS next=ZIGZAG xy=" . px . "," . py)
            return false
        }
        PortalLogWriteV66("BO_TELE_FIRST_PROGRESS xy=" . px . "," . py . " next=CONTINUE_WALK")
        return true
    }
    if (s.teleAttemptedV505)
    {
        PortalLogWriteV66("BO_TELE_ONCE_ALREADY_TRIED next=ZIGZAG","BO_TELE_ONCE_ALREADY_TRIED",1000)
        return false
    }
    s.teleAttemptedV505 := true
    last := Max(s.lastTele+0,coordManualTeleLastV296+0)
    if (last && A_TickCount-last<Max(3,teleportIntervalSecV56)*1000)
    {
        PortalLogWriteV66("BO_TELE_FIRST_SKIP reason=COOLDOWN next=ZIGZAG","BO_TELE_FIRST_SKIP",1000)
        return false
    }
    goal := {pid:s.pid,level:s.level,x:target.x,y:target.y,row:0,requiredArrival:true,stop:false,autoCallV504:true}
    prior := coordGoV59,coordGoV59 := goal
    try
        sent := CoordGoTeleportV284(h,pb,goal)
    finally
        if (coordGoV59=goal)
            coordGoV59 := prior
    if (sent)
    {
        s.lastTele := A_TickCount,coordManualTeleLastV296 := s.lastTele
        s.teleProbeV504 := {x:px,y:py,at:A_TickCount}
    }
    PortalLogWriteV66("BO_FIRST_MAP_STUCK_TELE goal=" . target.x . "," . target.y
        . " queued=" . sent . " readiness=AUTO_FARM next=" . (sent ? "VERIFY_MOVEMENT" : "ZIGZAG"))
    return sent
}

BOZigzagTickV474(h,ByRef pb,s)
{
    sweep := s.zigzagV474
    if (!IsObject(sweep))
        return false
    px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort")
    goal := sweep.goal
    if (!IsObject(goal) || (px-goal.x)**2+(py-goal.y)**2<=4)
    {
        if (s.tubeV14 && IsObject(goal))
            s.blockedV14 := 0
        if (IsObject(goal) && (px-goal.startXV505)**2+(py-goal.startYV505)**2>=4)
            s.teleAttemptedV505 := false,s.teleProbeV504 := false
        step := Min(Max(3,MapMoveDistanceGetV51()),Max(1,MonsterRadiusGetV239())*2)
        if (s.tubeV14)
        {
            side := sweep.leg && Mod(sweep.leg,2) ? -1 : 1
            sweep.dx := (s.forwardXV14-s.forwardYV14*side)/Sqrt(2)
            sweep.dy := (s.forwardYV14+s.forwardXV14*side)/Sqrt(2)
        }
        sweep.leg++,s.motion := false
        PortalLogWriteV66("BO_ZIGZAG_CHECKPOINT leg=" . sweep.leg . " live_xy=" . px . "," . py
            . " next_step=" . step . " scan=FRESH_BEFORE_MOVE")
        sweep.goal := goal := {uid:0,cls:0,room2:"ZIGZAG_" . sweep.leg,startXV505:px,startYV505:py
            ,x:Round(px+sweep.dx*step),y:Round(py+sweep.dy*step),level:s.level,priority:false}
    }
    goal.dist := (goal.x-px)**2+(goal.y-py)**2
    s.phase := "ZIGZAG"
    return BossSearchMoveV430(h,pb,s,goal)
}

BossSearchLeftBeginV433(s,target,px,py,key,turnAngle := 95)
{
    if (s.owner="BO")
        return BORecoveryBeginV452(s,target,px,py,key)
    dx := target.x-px,dy := target.y-py,len := Sqrt(dx*dx+dy*dy)
    if (len<1)
        return false
    angle := turnAngle*ATan(1)*4/180,step := Max(3,MapMoveDistanceGetV51())
    tx := Round(px+(dx*Cos(angle)+dy*Sin(angle))*step/len)
    ty := Round(py+(-dx*Sin(angle)+dy*Cos(angle))*step/len)
    if (tx<1 || tx>65535 || ty<1 || ty>65535)
        return false
    s.leftDetourV433 := {angle:turnAngle,key:key,x:px,y:py,tx:tx,ty:ty,since:0,last:0,queued:0,probeX:px,probeY:py}
    PortalLogWriteV66("MONSTER_SEARCH_TURN angle=" . turnAngle . " from=" . px . "," . py . " goal=" . tx . "," . ty)
    return true
}

BossSearchLeftTickV433(h,ByRef pb,s,target,key)
{
    if (s.owner="BO")
        return BORecoveryTickV452(h,pb,s)
    global chaseCheckSecV9
    d := s.leftDetourV433
    if (!IsObject(d))
        return false
    if (d.key!=key)
    {
        s.leftDetourV433 := false
        return false
    }
    px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort")
    if ((px-d.x)**2+(py-d.y)**2>=4)
    {
        s.leftDetourV433 := false
        if (IsObject(s.motion))
            s.motion.since := 0,s.motion.queued := 0,s.motion.dist := Sqrt(target.dist)
        PortalLogWriteV66("MONSTER_SEARCH_TURN_RECOVERED angle=" . d.angle . " next=CONTINUE_ORIGINAL_DIRECTION")
        return true
    }
    if (d.since && d.queued && A_TickCount-d.since>=Max(1,chaseCheckSecV9)*1000)
    {
        s.leftDetourV433 := false
        PortalLogWriteV66("MONSTER_SEARCH_TURN_BLOCKED angle=" . d.angle . " next=" . (d.angle=95 ? "RIGHT_95" : "TELE"))
        return false
    }
    if (A_TickCount-d.last>=250 && NativeMovePointV14(s.pid,d.tx,d.ty,s.level,false,false,true,false,{searchV430:s}))
    {
        d.last := A_TickCount,d.queued++
        if (!d.since)
            d.since := A_TickCount
    }
    return true
}

BossSearchNoDamageV434(h,target,pid,hpRaw)
{
    return FarmCloseNoDamageV391(h,target,pid,hpRaw)
}


BossSearchFollowEdgeV435(h,ByRef pb,s,target,p)
{
    global chaseCheckSecV9
    current := D2ReadU32(h,NumGet(pb,0x1C,"UInt")+0x10)
    node := RoomExploreReadV89(h,current,s.level)
    if (!IsObject(node))
        return false
    if (!IsObject(p.edgeV435))
    {
        best := 1.0e30,picked := false
        for _,next in node.links
        {
            other := RoomExploreReadV89(h,next,s.level)
            point := BossSearchPassageV432(node,other,NumGet(pb,2,"UShort"),NumGet(pb,6,"UShort"))
            if (!IsObject(point))
                continue
            rank := (point.x-target.x)**2+(point.y-target.y)**2
            if (rank<best)
                best := rank,picked := other
        }
        if (!IsObject(picked))
            return false
        p.edgeV435 := {from:current,a:node,b:picked,variant:0,since:0,last:0}
    }
    e := p.edgeV435
    if (e.from!=current || e.variant>4)
        return false
    px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort")
    goal := BossSearchPassageV432(e.a,e.b,px,py,e.variant)
    if (!IsObject(goal))
        return false
    if ((goal.x-px)**2+(goal.y-py)**2<=4
        || (e.since && A_TickCount-e.since>=Max(1,chaseCheckSecV9)*1000))
    {
        e.variant++,e.since := 0
        return e.variant<=4
    }
    if (A_TickCount-e.last>=250
        && NativeMovePointV14(s.pid,goal.x,goal.y,s.level,false,false,true,false,{searchV430:s}))
    {
        e.last := A_TickCount
        if (!e.since)
        {
            e.since := A_TickCount
            PortalLogWriteV66("MONSTER_SEARCH_FOLLOW_EDGE variant=" . e.variant . " next=LEFT_95_THEN_RIGHT_95_THEN_TELE")
        }
    }
    return true
}

BossSearchHoldAttackV436(h,player,ByRef pb,s,target)
{
    global xRunning,zRunning,packetWatchArmedV1,gameItemActionOwner,monsterChaseV44,monsterCombatUidV45
    if (xRunning || zRunning || packetWatchArmedV1 || gameItemActionOwner!=""
        || !BossSearchActiveV430(s.pid,s.level) || !AutoMonsterPacketCleanupV1())
        return true
    hp := MonsterBossProbeHPV2(h,D2ReadU32(h,target.unit+0x5C))
    hpRaw := hp.ok ? hp.raw : -1
    if (BossSearchNoDamageV434(h,target,s.pid,hpRaw))
        return true
    if (!MonsterChaseProgressV44(target.uid,NumGet(pb,2,"UShort"),NumGet(pb,6,"UShort"),target.dist
        ,hpRaw,target.x,target.y,target.level,s.pid,h,target.unit))
    {
        monsterCombatUidV45 := 0
        return true
    }
    if (!MonsterBossProbeReadV1(h,target.unit,0x30,ub) || NumGet(ub,0,"UInt")!=1
        || NumGet(ub,12,"UInt")!=target.uid || NumGet(ub,4,"UInt")!=target.cls
        || NumGet(ub,16,"UInt")=0 || NumGet(ub,16,"UInt")=12)
        return true
    if (AutoMonsterPacketSendV1(s.pid,target.unit,target.uid))
    {
        AttackIdTipV12(target.cls,Round(Sqrt(target.dist),1))
        if (IsObject(monsterChaseV44) && monsterChaseV44.uid=target.uid)
        {
            if (!monsterChaseV44.since)
                monsterChaseV44.since := A_TickCount
            monsterChaseV44.queued++
        }
    }
    return true
}

BossSearchHoldReadyV436(pid,level)
{
    global stage2FlowV380
    r := stage2FlowV380,s := IsObject(r) ? r.searchV430 : false
    c := IsObject(s) ? s.cleanupV431 : false
    if (!IsObject(c))
        return true
    if (!BossSearchActiveV430(pid,level))
        return false
    base := D2GetModuleBaseV35(pid,"D2Client.dll"),h := base ? D2OpenProcess(pid) : 0
    if (!h)
        return false
    try
    {
        player := D2ReadU32(h,base+0x11BBFC)
        path := player ? D2ReadU32(h,player+0x2C) : 0
        if (!MonsterBossProbeReadV1(h,path,0x20,pb)
            || CoordLevelV14(h,NumGet(pb,0x1C,"UInt"))!=level)
            return false
        scan := BossSearchScanV430(h,pb,s)
        if (!scan.known)
        {
            c.done := false,c.emptyAt := 0
            return false
        }
        for _,a in scan.allV431
            if ((a.x-c.x)**2+(a.y-c.y)**2<=c.radiusSq
                || (s.owner="BO" && a.dist<=c.radiusSq))
            {
                c.done := false,c.emptyAt := 0
                break
            }
        if (c.done)
            return true
        BossSearchCleanupTickV431(h,player,pb,s,scan)
        return c.done
    }
    finally
        DllCall("CloseHandle","Ptr",h)
}


BOFinalItemActiveV442(pid)
{
    global farmControlOwnerV186,scosEntryV162
    return farmControlOwnerV186="BO" && IsObject(scosEntryV162)
        && scosEntryV162.map="BO" && scosEntryV162.pid=pid && BackgroundValidV63()
}

PickupCharmCubeMarkedV571(ctx,item,ByRef ready)
{
    global pickupOptRulesV12
    ready := true,hasRule := false
    for _,rule in pickupOptRulesV12
        if (rule.cubeCharmV571)
            hasRule := true
    if (!hasRule)
        return false
    q := D2ReadU8V18(ctx.h,item.data),flags := D2ReadU32(ctx.h,item.data+0x18)
    for _,rule in pickupOptRulesV12
    {
        if (!rule.cubeCharmV571)
            continue
        if ((rule.HasKey("exactClassV638") || rule.charmV571 || rule.setV574) && !rule.stats.Length() && !rule.tiers.Count())
        {
            if (PickupOptRuleMatchV12(rule,q,flags,"","","",ctx.h,item.cls))
            {
                ready := true
                return true
            }
            continue
        }
        PickupOptPollV12()
        info := PickupOptReadV12(ctx.h,item.unit,item.cls,q,item.data,flags)
        if (!IsObject(info) || !info.ok)
        {
            ready := false
            continue
        }
        if (PickupOptRuleMatchV12(rule,q,flags,info.name,info.stats,"",ctx.h,item.cls))
        {
            ready := true
            return true
        }
    }
    return false
}

PickupCubeRouteV574(ctx,item)
{
    relic := false
    if (D2ReadU8V18(ctx.h,item.data)=7)
    {
        started := A_TickCount
        Loop
        {
            relic := PickupRelicNameV567(ctx,item.cls,ready)
            if (ready)
                break
            SigCheckV147(ctx)
            if (A_TickCount-started>=3000)
                SigFailV147("Chuyển Cube: chưa phân biệt được Relic/Charm; chưa di chuyển đồ")
            Sleep, 30
        }
    }
    SigLogV147("CUBE_RULE_ROUTE uid=" . item.uid . " class=" . item.cls
        . " mode=" . (relic ? "RELIC_SHARED_ALLOWANCE" : "EXACT_ITEM"))
    return PickupRelicSwapV567(ctx,item,!relic)
}

PickupRelicNameV567(ctx,cls,ByRef ready)
{
    global consumableClassRAMV7
    ConsumablePickupGroupV7(ctx.h,cls)
    key := ctx.pid . "|" . cls
    ready := IsObject(consumableClassRAMV7) && consumableClassRAMV7.HasKey(key)
    return ready && RegExMatch(PickupOptCleanTextV12(consumableClassRAMV7[key]),"i)\bRelic\b")
}

PickupRelicMarkedV567(ctx,item,ByRef ready)
{
    global pickupOptRulesV12,consumableClassRAMV7
    ready := true,hasRule := false
    for _,rule in pickupOptRulesV12
        if (rule.cubeRelicV567)
            hasRule := true
    if (!hasRule)
        return false
    if (!PickupRelicNameV567(ctx,item.cls,ready))
        return false
    q := D2ReadU8V18(ctx.h,item.data),flags := D2ReadU32(ctx.h,item.data+0x18)
    base := consumableClassRAMV7[ctx.pid . "|" . item.cls]
    for _,rule in pickupOptRulesV12
    {
        if (!rule.cubeRelicV567)
            continue
        if (!rule.stats.Length() && !rule.tiers.Count())
        {
            if (PickupOptRuleMatchV12(rule,q,flags,"","",base,ctx.h,item.cls))
            {
                ready := true
                return true
            }
            continue
        }
        PickupOptPollV12()
        info := PickupOptReadV12(ctx.h,item.unit,item.cls,q,item.data,flags)
        if (!IsObject(info) || !info.ok)
        {
            ready := false
            continue
        }
        if (PickupOptRuleMatchV12(rule,q,flags,info.name,info.stats,base,ctx.h,item.cls))
        {
            ready := true
            return true
        }
    }
    return false
}

PickupRelicStoredV567(ctx,item)
{
    all := SigSnapshotV147(ctx),live := all[item.uid]
    if (!IsObject(live) || live.cls!=item.cls || live.q!=item.q
        || D2ReadU32(ctx.h,live.unit+0x10)!=0)
        return false
    return live
}

PickupRelicSwapV567(ctx,item,charmMode:=false)
{
    global pickupStashListV217
    label := charmMode ? "Vật phẩm" : "Relic"
    SigCheckV147(ctx)
    ground := SigGroundV147(ctx)
    if (!ground.HasKey(item.uid) || ground[item.uid].cls!=item.cls)
        SigFailV147(label . " [cube]: vật dưới đất đã thay đổi")
    item := ground[item.uid],cube := false,original := false,home := false,success := false
    all := SigSnapshotV147(ctx)
    for uid,a in all
        if (a.cls=1204 && a.q=2 && a.loc=0 && a.owner=ctx.inv && D2ReadU32(ctx.h,a.unit+0x10)=0)
        {
            cube := a
            break
        }
    started := A_TickCount
    Loop
    {
        waiting := false
        for uid,a in all
        {
            if (a.loc!=0 || a.owner!=ctx.inv || uid=item.uid || a.cls=1204
                || D2ReadU32(ctx.h,a.unit+0x10)!=0)
                continue
            if (charmMode && (a.cls!=item.cls || a.q!=item.q))
                continue
                        
            ready := true
            if (charmMode || PickupRelicNameV567(ctx,a.cls,ready))
            {
                original := a
                break
            }
            if (!ready)
                waiting := true
        }
        if (IsObject(original) || !waiting)
            break
        SigCheckV147(ctx)
        if (A_TickCount-started>3000)
            SigFailV147(label . " [cube]: chưa nhận diện xong vật phẩm trong túi, chưa di chuyển đồ")
        Sleep, 30
        ConsumableNamePollV7()
    }
    if (!IsObject(cube) && IsObject(original))
        SigFailV147(label . " [cube]: cần Cube trong túi trước khi đổi tạm vật phẩm")
    if (IsObject(cube))
        ctx.cubeUid := cube.uid
    try
    {
        if (IsObject(original))
        {
            home := {uid:original.uid,cls:original.cls,q:original.q,x:original.x,y:original.y}
            SigLogV147("ITEM_SWAP_BEGIN ground_uid=" . item.uid . " original_uid=" . original.uid
                . " original_class=" . original.cls . " home=" . home.x . "," . home.y)
            SigToCubeV147(ctx,original,cube,true)
        }
        bytes := [0x16],SigDwordV147(bytes,4),SigDwordV147(bytes,item.uid),SigDwordV147(bytes,0)
        SigPacketV147(ctx,bytes)
        fresh := SigWaitLocV147(ctx,item.uid,0,2500)
        if (!IsObject(fresh) || fresh.cls!=item.cls || fresh.q!=item.q)
            SigFailV147(label . " [cube]: chưa xác nhận vật phẩm mới vào túi")
                if (!IsObject(original))
{
    UniqueRememberPickedV18(ctx.h,fresh)
    if (IsObject(pickupStashListV217))
        pickupStashListV217.Delete(item.uid)
    success := true
    SigLogV147("CUBE_RULE_PICK_TO_INVENTORY uid=" . item.uid . " class=" . item.cls . " destination=INVENTORY reason=NO_MATCHING_OLD_ITEM")
    return true
}
        SigToCubeV147(ctx,fresh,cube,true)
        if (IsObject(original))
        {
            original := PickupRelicStoredV567(ctx,original)
            if (!IsObject(original) || original.loc!=3)
                SigFailV147(label . " [cube]: chưa tìm lại đúng UID vật phẩm ban đầu trong Cube")
            Ticket130HomeV265(ctx,original,home)
        }
        newLive := PickupRelicStoredV567(ctx,item)
        if (!IsObject(newLive) || newLive.loc!=3)
            SigFailV147(label . " [cube]: chưa xác nhận vật phẩm mới trong Cube")
        if (IsObject(home))
        {
            all := SigSnapshotV147(ctx),old := all[home.uid]
            if (!IsObject(old) || old.cls!=home.cls || old.q!=home.q || old.loc!=0 || old.owner!=ctx.inv || old.x!=home.x || old.y!=home.y)
                SigFailV147(label . " [cube]: Vật phẩm ban đầu chưa về đúng ô cũ")
        }
        UniqueRememberPickedV18(ctx.h,newLive)
        if (IsObject(pickupStashListV217))
        {
            pickupStashListV217.Delete(item.uid)
            if (IsObject(home))
                pickupStashListV217.Delete(home.uid)
        }
        success := true
        SigLogV147("ITEM_SWAP_DONE new_uid=" . item.uid . " new_location=CUBE original_uid=" . home.uid . " original_location=SAVED_INVENTORY_CELL")
        FonInfoPushV385(label . " mới vào Cube; vật ban đầu đã trả về ô cũ.")
        return true
    }
    finally
    {
        if (!success && IsObject(home))
        {
            try
            {
                all := SigSnapshotV147(ctx),old := all[home.uid],newItem := all[item.uid]
                cursor := PickupCursorV4(ctx.h,ctx.inv)
                newInBag := IsObject(newItem) && newItem.loc=0 && newItem.owner=ctx.inv
                    && D2ReadU32(ctx.h,newItem.unit+0x10)=0
                if (IsObject(old) && (old.loc=3 || (IsObject(cursor) && cursor.uid=home.uid))
                    && !newInBag && IsObject(cursor) && (!cursor.unit || cursor.uid=home.uid))
                    Ticket130HomeV265(ctx,old,home)
            }
            catch restoreError
                SigLogV147("ITEM_SWAP_RESTORE_WAIT original_uid=" . home.uid . " reason=" . restoreError.Message)
            FonInfoPushV385(label . " [cube] chưa xong; đã giữ đồ, kiểm tra vật gốc UID " . home.uid . ".")
        }
        try
        {
            cursor := PickupCursorV4(ctx.h,ctx.inv)
            if (IsObject(cursor) && !cursor.unit)
                SigCloseCubeV156()
        }
        catch closeError
            SigLogV147("ITEM_SWAP_CLOSE_WAIT reason=" . closeError.Message)
    }
}

PickupRelicRoundV567(h,player,pid,item)
{
    global sigBusyV147,sigCancelV147,sigActiveModeV182,sigBackgroundV179,sigSendingKeyV147
    global xRunning,zRunning,pickupImageOn
    inv := D2ReadU32(h,player+0x60)
    if (!inv)
        return "WAIT"
    ctx := {pid:pid,h:h,player:player,inv:inv,first:D2ReadU32(h,inv+0x10)}
    charmCube := PickupCharmCubeMarkedV571(ctx,item,ready)
    if (!ready)
        return "WAIT"
    marked := charmCube ? true : PickupRelicMarkedV567(ctx,item,ready)
    if (!ready)
        return "WAIT"
    if (!marked)
        return "PASS"
    if (sigBusyV147 || xRunning || zRunning || !AutoMonsterPacketCleanupV1())
        return "WAIT"
    priorCancel := sigCancelV147,priorMode := sigActiveModeV182,priorBackground := sigBackgroundV179
    sigBusyV147 := true,sigCancelV147 := false,sigBackgroundV179 := true,sigActiveModeV182 := charmCube ? "CHARM_CUBE" : "RELIC_CUBE"
    try
    {
        if (charmCube)
            PickupCubeRouteV574(ctx,item)
        else
            PickupRelicSwapV567(ctx,item)
        return "DONE"
    }
    catch e
    {
        DebugTraceWrite("pickup","CUBE_RULE_ERROR uid=" . item.uid . " class=" . item.cls . " reason=" . e.Message)
        PickupEnabledSetV71(false,true,false)
        ToolTipInfoV386(e.Message . " — nhặt đã tắt, không quăng đồ.")
        SetTimer, RemoveToolTip, -5000
        return "ERROR"
    }
    finally
    {
        sigBusyV147 := false,sigCancelV147 := priorCancel,sigActiveModeV182 := priorMode
        sigBackgroundV179 := priorBackground,sigSendingKeyV147 := false
    }
}

PickupFailedInventoryReadyV551(h,player,pid,groundUid,groundUnit)
{
    global labInventoryOnlyV311
    if (Lab1SingleRunV310() && labInventoryOnlyV311)
        return true
    if (!MonsterBossProbeReadV1(h,groundUnit,0x18,ub)
        || NumGet(ub,0,"UInt")!=4 || NumGet(ub,12,"UInt")!=groundUid)
        return true
    cls := NumGet(ub,4,"UInt"),data := NumGet(ub,0x14,"UInt")
    if (cls=1204)
        return true
    if (!MonsterBossProbeReadV1(h,data,0x2C,id))
        return false
    quality := NumGet(id,0,"UChar")
    fileIndex := quality=7 ? NumGet(id,0x28,"UInt") : -1
    cleared := PickupMatchingInventoryClearV551(h,player,pid,cls,quality,groundUid,fileIndex)
    V104CubeLog("FAILED_PICKUP_MATCHING_INVENTORY class=" . cls . " itemdata=" . quality
        . " file_index=" . fileIndex . " ground_uid=" . groundUid . " result=" . cleared)
    return cleared="CLEAR"
}


BossSearchPickupDoneV438(pid)
{
    global ticketPickupWaitV279
    w := ticketPickupWaitV279
    return IsObject(w) && w.pid=pid && w.done
}

FarmWatchNowV688()
{
    return DllCall("GetTickCount64","Int64")
}

FarmWatchStateV688()
{
    global farmWatchV5,farmControlOwnerV186,mapWorkflowV185
    if (!IsObject(farmWatchV5))
        farmWatchV5 := {owner:"",pid:0,hwnd:0,birth:"",enabled:false,period:60000
            ,idleAtV650:FarmWatchNowV688(),retryAtV688:0}
    w := farmWatchV5
    owner := farmControlOwnerV186!="" ? farmControlOwnerV186 : mapWorkflowV185.map
    if (owner!="")
        w.owner := owner
    return w
}


PickupFarmBudgetActiveV762(pid)
{
    global pickupImageOn
    if (!pid || !pickupImageOn)
        return false
    level := RoomRecordLevelV259(pid)
    return level>0 && !FarmReviveTownLevelV295(level)
}

PickupFarmResetV762()
{
    global pickupFarmAttemptsV762
    pickupFarmAttemptsV762 := {}
}

PickupFarmKeyV762(pid,uid)
{
    global farmRunEpochV535
    return pid . "|" . farmRunEpochV535 . "|" . uid
}

PickupFarmStateV762(pid,uid,cls:=0)
{
    global pickupFarmAttemptsV762
    if (!IsObject(pickupFarmAttemptsV762))
        pickupFarmAttemptsV762 := {}
    key := PickupFarmKeyV762(pid,uid)
    if (!pickupFarmAttemptsV762.HasKey(key))
        pickupFarmAttemptsV762[key] := {uid:uid,cls:cls,tries:0,lastAt:0,skip:false,skipUntil:0}
    state := pickupFarmAttemptsV762[key]
    if (cls)
        state.cls := cls
    return state
}

PickupFarmSkipV762(pid,uid,cls,reason,durationMs:=0)
{
    global pickupContextModeV765,sigFailedItemsV765
    if (pickupContextModeV765 = "SIG")
    {
        if (!IsObject(sigFailedItemsV765))
            sigFailedItemsV765 := {}
        if (!sigFailedItemsV765.HasKey(uid))
        {
            sigFailedItemsV765[uid] := {uid:uid,cls:cls,reason:reason,at:A_TickCount}
            DebugTraceWrite("pickup","SIG_PICKUP_FAIL uid=" . uid . " class=" . cls . " reason=" . reason)
            FonInfoPushV385("[SIG] Chưa nhặt được UID " . uid . " class " . cls
                . " — " . reason . ". Tiếp tục quét và thử nhặt; chưa báo Done.")
        }
        return true
    }
    state := PickupFarmStateV762(pid,uid,cls)
    ; Farm: khong bo qua BAT KY vat pham nao nam trong danh sach nhat.
    ; Khi pickup / teleport loi, giai phong trang thai de quet lai va TELE tiep.
    ; SIG giu nguyen luong rieng o phia tren.
    if (PickupFarmBudgetActiveV762(pid))
    {
        state.skip := false, state.skipUntil := 0
        state.tries := 0, state.lastAt := 0, state.startedAtV940 := 0
        DebugTraceWrite("pickup","FARM_PICKUP_RETRY_NO_SKIP uid=" . uid
            . " class=" . cls . " reason=" . reason . " next=RESCAN_AND_TELE")
        return false
    }
    if (state.skip)
        return true
    state.skip := true
    state.skipUntil := A_TickCount+Max(1000,durationMs)
    DebugTraceWrite("pickup","FARM_PICKUP_SKIP uid=" . uid . " class=" . cls
        . " reason=" . reason . " until=" . state.skipUntil)
    FonInfoPushV385("[Nhặt farm] Bỏ qua UID " . uid . " trong lượt farm này; " . reason)
    return true
}

