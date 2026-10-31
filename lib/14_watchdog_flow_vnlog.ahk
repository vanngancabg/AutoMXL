; ==============================================================================
; FILE: 14_watchdog_flow_vnlog.ahk (Dòng 47407 -> 52721 trong Gốc.ahk)
; CHỨC NĂNG: Watchdog chống đứng, Form 6, Sắp Rương/Kho, Chu kỳ Tâm & Log tiếng Việt
; ==============================================================================
PickupFarmIgnoredV762(pid,uid)
{
    global pickupFarmAttemptsV762,pickupContextModeV765,sigFailedItemsV765
    if (pickupContextModeV765!="SIG"
        && FarmPickupTimedIgnoreV1602(pid,RoomRecordLevelV259(pid),uid))
        return true
    ; SIG records unresolved pickup failures for its DONE proof, but must
    ; keep scanning and trying the same UID while it remains on the ground.
    if (pickupContextModeV765 = "SIG")
        return false
    ; Farm khong dung danh sach UID skip (ke ca skip cu cua cac lan retry).
    if (PickupFarmBudgetActiveV762(pid))
        return false
    if (!IsObject(pickupFarmAttemptsV762))
        return false
    key := PickupFarmKeyV762(pid,uid)
    if (!pickupFarmAttemptsV762.HasKey(key))
        return false
    state := pickupFarmAttemptsV762[key]
    if (!PickupFarmBudgetActiveV762(pid))
        return false
    if (state.skip && state.skipUntil && A_TickCount>=state.skipUntil)
    {
        state.skip := false,state.tries := 0,state.lastAt := 0,state.startedAtV940 := 0
    }
    return state.skip
}

PickupFarmTryV762(pid,uid,cls:=0)
{
    if (!PickupFarmBudgetActiveV762(pid))
        return true
    if (PickupFarmIgnoredV762(pid,uid))
        return false
    state := PickupFarmStateV762(pid,uid,cls)
    ; Ba lan gui loi KHONG phai ly do bo qua item farm.
    ; Nghi ngan giua cac dot roi thu lai de con co the TELE xu ly loi.
    if (state.tries>=3)
    {
        if (A_TickCount-state.lastAt<350)
            return false
        state.tries := 0
    }
    if (state.tries && A_TickCount-state.lastAt<100)
        return false
    state.tries++
    state.lastAt := A_TickCount
    DebugTraceWrite("pickup","FARM_PICKUP_TRY uid=" . uid . " attempt=" . state.tries . "/3")
    return true
}

PickupFarmForgetV762(pid,uid)
{
    global pickupFarmAttemptsV762
    if (IsObject(pickupFarmAttemptsV762))
        pickupFarmAttemptsV762.Delete(PickupFarmKeyV762(pid,uid))
}

PickupFarmSkipUnitV762(h,unit)
{
    global pickupFarmAttemptsV762
    if (!IsObject(pickupFarmAttemptsV762) || !pickupFarmAttemptsV762.Count())
        return false
    mode := D2ReadU32(h,unit+0x10)
    if (mode!=3 && mode!=5)
        return false
    return PickupFarmIgnoredV762(D2GetProcessIdFromHandle(h),D2ReadU32(h,unit+0x0C))
}

SigEntryStopV762(r,reason)
{
    global sigTerminalErrorV762,sigLastStopReasonV63
    if (reason="")
        reason := "Không khởi động được SIG"
    r.stage1SigBlockedV654 := false,r.sigErrorHoldV769 := true
    SigLogV147("SIG_ENTRY_ABORT attempts=" . r.sigAttemptsV762 . " reason=" . reason . " next=ERROR_KEEP_FARM")
    FarmErrorKeepV769("SIG_ENTRY_FAILED " . reason)
    sigTerminalErrorV762 := reason
    sigLastStopReasonV63 := reason
    FonInfoPushV385("[SIG] Lỗi; phiên farm vẫn bật, chờ xử lý: " . reason)
    ToolTipInfoV386("SIG đã dừng: " . reason . " — giữ đồ, không gửi lặp.")
    SetTimer, RemoveToolTip, -10000
    return false
}

CubeResetProofSerialV754()
{
    global cubeResetSerialV754
    return cubeResetSerialV754
}

CubeResetPendingV754(pid:=0)
{
    global cubeResetHoldsV754
    if (!IsObject(cubeResetHoldsV754))
        return false
    for _,state in cubeResetHoldsV754
        if (!pid || state.pid=pid)
            return true
    return false
}

CubeResetHoldV754(pid,h,player,uid)
{
    global cubeResetHoldsV754,cubeResetSerialV754
    if (!IsObject(cubeResetHoldsV754))
        cubeResetHoldsV754 := {}
    SigProtectionArmV761(pid)
    level := RoomRecordLevelV259(pid)
    path := D2ReadU32(h,player+0x2C)
    x := D2ReadU16(h,path+2),y := D2ReadU16(h,path+6)
    cubeResetSerialV754++
    key := pid . "|" . level . "|" . uid
    cubeResetHoldsV754[key] := {pid:pid,level:level,uid:uid,serial:cubeResetSerialV754
        ,x:x,y:y,checks:0,emptyAt:0}
    FarmWatchSigGateV753(FarmWatchStateV688(),FarmWatchNowV688())
    PortalLogWriteV66("CUBE_RESET_HOLD uid=" . uid . " next=WAIT_VERIFIED_PICKUP")
}

CubeResetConfirmV754(pid,level,h,player,serial,onlyUid:=0)
{
    global cubeResetHoldsV754
    if (!level || !CubeResetPendingV754(pid) || RoomRecordLevelV259(pid)!=level)
        return false
    inv := D2ReadU32(h,player+0x60)
    cursor := PickupCursorV4(h,inv)
    if (!inv || !IsObject(cursor) || cursor.unit)
        return false
    all := V9SnapshotAllItems({h:h,inv:inv,first:D2ReadU32(h,inv+0x10)})
    cleared := false
    for key,state in cubeResetHoldsV754.Clone()
    {
        if (state.pid!=pid || state.level!=level || state.serial>serial || (onlyUid && state.uid!=onlyUid))
            continue
        cube := all[state.uid]
        if (!IsObject(cube) || cube.cls!=1204 || cube.loc!=0 || cube.owner!=inv
            || D2ReadU32(h,cube.unit+0x10)=3 || D2ReadU32(h,cube.unit+0x10)=5)
            continue
        if (cubeResetHoldsV754[key].serial!=state.serial)
            continue
        cubeResetHoldsV754.Delete(key)
        cleared := true
        PortalLogWriteV66("CUBE_RESET_PICKUP_DONE uid=" . state.uid . " next=RESUME_IDLE_WHEN_WORK_FINISHED")
    }
    if (cleared)
        FarmWatchSigGateV753(FarmWatchStateV688(),FarmWatchNowV688())
    return cleared
}

CubeResetVerifiedV754(pid,level,serial)
{
    if (!CubeResetPendingV754(pid))
        return true
    base := D2GetModuleBaseV35(pid,"D2Client.dll")
    h := base ? D2OpenProcess(pid) : 0
    if (!h)
        return false
    try
    {
        player := D2ReadU32(h,base+0x11BBFC)
        if (!player)
            return false
        CubeResetConfirmV754(pid,level,h,player,serial)
        return !CubeResetPendingV754(pid)
    }
    finally
        DllCall("CloseHandle","Ptr",h)
}

CubeResetNormalScanV754(pid,level,h,player,serial,clear,px,py)
{
    global cubeResetHoldsV754,sigBusyV147,sigActiveModeV182,ticketPickupWaitV279
    if (!CubeResetPendingV754(pid) || sigBusyV147 || sigActiveModeV182!=""
        || IsObject(ticketPickupWaitV279))
        return
    ready := false,readySerial := 0,readyUid := 0
    for _,state in cubeResetHoldsV754
    {
        if (state.pid!=pid || state.level!=level || state.serial>serial)
            continue
        if (!clear || state.x<1 || state.y<1 || (px-state.x)**2+(py-state.y)**2>1)
        {
            state.checks := 0,state.emptyAt := 0
            continue
        }
        if (!state.emptyAt)
            state.emptyAt := A_TickCount
        state.checks++
        if (state.checks>=3 && A_TickCount-state.emptyAt>=1200)
            ready := true,readySerial := state.serial,readyUid := state.uid
    }
    if (ready)
        CubeResetConfirmV754(pid,level,h,player,readySerial,readyUid)
}

SigProtectionArmV761(pid)
{
    global sigProtectionSessionV761,sigSessionSerialV761,backgroundPidV63,backgroundBirthV63,backgroundHwndV63
    if (!pid)
        return sigSessionSerialV761+0
    state := sigProtectionSessionV761
    if (!IsObject(state) || state.ended)
    {
        birth := BackgroundBirthV63(pid)
        if (birth="" && pid=backgroundPidV63)
            birth := backgroundBirthV63
        sigSessionSerialV761++
        sigProtectionSessionV761 := {pid:pid,birth:birth,hwnd:pid=backgroundPidV63 ? backgroundHwndV63 : 0
            ,roomName:GameRoomLiveNameV252(pid),serial:sigSessionSerialV761,nextProbe:0,ended:false}
    }
    return sigSessionSerialV761+0
}

SigProtectionEvidenceV761(state,code,now)
{
    if (code="PROCESS_EXITED" || code="PROCESS_REPLACED" || code="NEW_ROOM")
        return true
    definite := code="WINDOW_LOST" || code="LEFT_SESSION" || code="UNEXPECTED_LOBBY"
        || code="STAGE3_LOBBY" || code="CRASH_DIALOG"
    if (!definite)
    {
        state.evidenceCode := "",state.evidenceAt := 0,state.evidenceReads := 0
        return false
    }
    if (state.evidenceCode!=code)
        state.evidenceCode := code,state.evidenceAt := now,state.evidenceReads := 0
    state.evidenceReads++
    return state.evidenceReads>=2 && now-state.evidenceAt>=2000
}

SigProtectionEndedV761(pid)
{
    global sigProtectionSessionV761
    return IsObject(sigProtectionSessionV761) && sigProtectionSessionV761.pid=pid && sigProtectionSessionV761.ended
}

SigProtectionProcessCodeV761(state)
{
    if (!state.pid)
        return ""
    Process, Exist, % state.pid
    if (!ErrorLevel)
        return "PROCESS_EXITED"
    birth := BackgroundBirthV63(state.pid)
    if (state.birth!="" && birth!="" && state.birth!=birth)
        return "PROCESS_REPLACED"
    if (state.birth="" && birth!="")
        state.birth := birth
    return ""
}

SigProtectionMenuCodeV761(state)
{
    ui := RecoveryMenuSnapshotV528(state)
    if (!IsObject(ui) || !ui.ok)
        return ""
    if (ui.login || ui.menu || ui.character || ui.splash)
        return "LEFT_SESSION"
    lobby := StageThreeUiV533(state)
    if (IsObject(lobby) && lobby.ok
        && (IsObject(lobby.roles.openCreate) || IsObject(lobby.roles.createRoom)))
        return "UNEXPECTED_LOBBY"
    return ""
}

SigProtectionPurgeV761(state)
{
    global sigResetPendingV753,sigPostPickupV655,ticketPickupWaitV279,cubeResetHoldsV754,scosEntryV162
    sigResetPendingV753 := false
    if (IsObject(sigPostPickupV655) && sigPostPickupV655.pid=state.pid)
        sigPostPickupV655 := false
    if (IsObject(ticketPickupWaitV279) && ticketPickupWaitV279.pid=state.pid)
        ticketPickupWaitV279 := false
    if (IsObject(cubeResetHoldsV754))
        for key,hold in cubeResetHoldsV754.Clone()
            if (hold.pid=state.pid)
                cubeResetHoldsV754.Delete(key)
    if (IsObject(scosEntryV162) && scosEntryV162.pid=state.pid)
        scosEntryV162.stage1SigBlockedV654 := false,scosEntryV162.sigFailLoggedV374 := false
}

SigProtectionReleaseV761(state,reason)
{
    global sigProtectionSessionV761,sigSessionSerialV761,sigResetPendingV753,sigPostPickupV655
    global ticketPickupWaitV279,cubeResetHoldsV754,sigBusyV147,sigCancelV147,sigActiveModeV182,sigSendingKeyV147
    global sigLastStopReasonV63,scosEntryV162,pickupRoundResetV1,farmWatchV5
    if (!IsObject(state) || state.ended)
        return false
    if (IsObject(sigProtectionSessionV761) && sigProtectionSessionV761!=state)
        return false
    activeCallback := sigBusyV147 || sigActiveModeV182!=""
        || (IsObject(ticketPickupWaitV279) && ticketPickupWaitV279.pid=state.pid)
    state.ended := true
    sigSessionSerialV761++
    sigCancelV147 := true
    SigProtectionPurgeV761(state)
    if (!activeCallback)
        sigActiveModeV182 := "",sigSendingKeyV147 := false
    sigLastStopReasonV63 := "Phiên game cũ đã kết thúc; đã xóa trạng thái SIG cũ"
    pickupRoundResetV1 := true
    if (IsObject(farmWatchV5))
    {
        ; Only the end of a protected SIG session restarts the idle interval.
        ; Losing an unrelated game session must not erase elapsed standing time.
        if (farmWatchV5.sigPausedV753)
            farmWatchV5.idleAtV650 := FarmWatchNowV688()
        farmWatchV5.sigPausedV753 := false
        farmWatchV5.retryAtV688 := 0
        farmWatchV5.standSampleV650 := false
    }
    PortalLogWriteV66("SIG_SESSION_RELEASE reason=" . reason . " pid=" . state.pid . " old_contexts=INVALIDATED next=RECOVERY_ALLOWED")
    return true
}

SigProtectionWatchV761()
{
    global sigProtectionSessionV761,backgroundPidV63,sigPostPickupV655,ticketPickupWaitV279,scosEntryV162
    global sigBusyV147,sigActiveModeV182,sigCancelV147
    static busy := false
    if (busy)
        return false
    busy := true
    try
    {
        if (IsObject(sigProtectionSessionV761) && sigProtectionSessionV761.ended
            && !sigBusyV147 && sigActiveModeV182="" && !IsObject(ticketPickupWaitV279))
        {
            SigProtectionPurgeV761(sigProtectionSessionV761)
            sigCancelV147 := false
        }
        blocked := IsObject(scosEntryV162) && scosEntryV162.stage1SigBlockedV654
        if (!SigResetProtectedV753() && !blocked)
            return false
        state := sigProtectionSessionV761
        if (!IsObject(state))
        {
            pid := backgroundPidV63
            if (IsObject(sigPostPickupV655))
                pid := sigPostPickupV655.pid
            else
                if (IsObject(ticketPickupWaitV279))
                    pid := ticketPickupWaitV279.pid
            if (!pid)
                return false
            SigProtectionArmV761(pid)
            state := sigProtectionSessionV761
        }
        if (state.ended)
            return false
        now := FarmWatchNowV688()
        if (now<state.nextProbe)
            return false
        state.nextProbe := now+1000
        code := SigProtectionProcessCodeV761(state)
        if (code="")
        {
            probe := FarmWatchProbeV541(state)
            code := probe.code
        }
        if (code="DLL_READ_UNKNOWN" || code="DLL_VERSION_UNKNOWN" || code="CHARACTER_UNREADABLE"
            || code="NO_PLAYER_STALLED" || code="MODAL_WITHOUT_GAME")
        {
            menuCode := SigProtectionMenuCodeV761(state)
            if (menuCode!="")
                code := menuCode
        }
        if (code="IN_GAME")
        {
            name := GameRoomLiveNameV252(state.pid)
            if (state.roomName!="" && name!="" && name!=state.roomName)
                code := "NEW_ROOM"
            else
                if (state.roomName="" && name!="")
                    state.roomName := name
        }
        if (!SigProtectionEvidenceV761(state,code,now))
            return false
        return SigProtectionReleaseV761(state,code)
    }
    finally
        busy := false
}

SigResetProtectedV753()
{
    global sigBusyV147,sigSendingKeyV147,sigActiveModeV182,ticketPickupWaitV279
    global sigPostPickupV655,sigResetPendingV753,ticket130BusyV265
    return SigPickupOwnedV764() || CubeResetPendingV754() || ticket130BusyV265 || sigResetPendingV753 || IsObject(sigPostPickupV655)
        || sigBusyV147 || sigSendingKeyV147 || sigActiveModeV182!=""
        || (IsObject(ticketPickupWaitV279) && ticketPickupWaitV279.active
            && (ticketPickupWaitV279.sigScopeV654 || ticketPickupWaitV279.resetProtectedV754))
}

; Only an executing SIG / SIG-owned pickup is character activity.
; sigResetPending, sigPostPickup and Cube reset holds are SAFETY flags,
; never proof the character is acting (Farm may already be running).
FarmWatchSigActiveV753()
{
    global sigBusyV147,sigActiveModeV182,ticketPickupWaitV279
    if (sigBusyV147 || sigActiveModeV182!="" || SigPickupOwnedV764())
        return true
    return IsObject(ticketPickupWaitV279) && ticketPickupWaitV279.active
        && (ticketPickupWaitV279.sigScopeV654 || ticketPickupWaitV279.resetProtectedV754)
}

; A confirmed real action overrides a pending watchdog wait, regardless
; of which workflow left that wait in place. Do not touch the live
; SIG/Cube/pickup safety locks: this is only the standing watchdog state.
FarmWatchRealActivityV1080(w,now)
{
    w.idleAtV650 := now
    w.retryAtV688 := 0
    w.activeThisTickV691 := true
    if (w.sigPausedV753 || FarmWatchSigActiveV753())
    {
        w.sigWaitBypassedV1080 := true
        w.sigPausedV753 := false
    }
}

FarmWatchSigGateV753(w,now)
{
    sigActive := FarmWatchSigActiveV753()
    ; Once the SIG job truly ends, future independent SIG jobs can pause
    ; the counter again; an old waiting flag must not block a live farmer.
    if (!sigActive)
        w.sigWaitBypassedV1080 := false
    if (sigActive && w.sigWaitBypassedV1080)
        return false
    if (sigActive)
    {
        ; Working SIG is character activity. Keep a live baseline so that
        ; movement/attack can immediately override a stale SIG wait.
        w.idleAtV650 := now
        w.retryAtV688 := 0
        w.sigPausedV753 := true
        w.activeThisTickV691 := true
        return true
    }
    if (w.sigPausedV753)
    {
        ; A completed SIG starts a fresh inactivity interval; no time jump.
        w.idleAtV650 := now
        w.retryAtV688 := 0
        w.workProgressV736 := false
        w.sigPausedV753 := false
        w.activeThisTickV691 := false
        return true
    }
    return false
}

FarmWatchAttackingV688(sample,pid,uid,at,tick)
{
    if (!IsObject(sample))
        return false
    if (sample.mode=7 || sample.mode=8)
        return true
    skillAttack := (sample.mode>=10 && sample.mode<=16) || sample.mode=18
    return skillAttack && pid=sample.pid && uid>0 && at>0 && tick-at>=0 && tick-at<1200
}

FarmWatchIdleStateV688(w,sample,attacking,now)
{
    if (!w.enabled)
    {
        w.activeThisTickV691 := false
        w.standSampleV650 := false
        return false
    }
    ; Always examine real character activity BEFORE inspecting any wait.
    ; This is what releases the watchdog from a stale SIG/wait flag.
    if (IsObject(sample))
    {
        w.sampleMissingAtV650 := 0
        previous := w.standSampleV650
        same := IsObject(previous) && previous.pid=sample.pid && previous.birth=sample.birth
        moved := same && ((sample.x-previous.x)**2+(sample.y-previous.y)**2>=1)
        attackMode := sample.mode=7 || sample.mode=8 || sample.mode=9
            || (sample.mode>=10 && sample.mode<=16) || sample.mode=18
        animated := same && attackMode && (previous.mode!=sample.mode || previous.frame!=sample.frame)
        w.standSampleV650 := sample
        if (moved || animated)
        {
            FarmWatchRealActivityV1080(w,now)
            return false
        }
    }
    else if (!w.sampleMissingAtV650)
        w.sampleMissingAtV650 := now

    ; Do not interrupt a working SIG. A confirmed resumed action above
    ; bypasses only the stale watchdog wait, never SIG's item protection.
    if (FarmWatchSigGateV753(w,now))
        return false
    w.activeThisTickV691 := false
    ; Missing player, first sample or a stationary character are all idle.
    return now-w.idleAtV650>=w.period
}

; One shared activity refresh for the watchdog timer and every automatic
; stage/reconnect wait: none may act on a stale standing clock.
FarmWatchRefreshActivityV1080(w,ByRef sample := "",force := false)
{
    global currentAttackUidV520,currentAttackAtV520,currentAttackPidV550
    now := FarmWatchNowV688()
    if (!force && w.HasKey("watchProbedAtV1080") && now-w.watchProbedAtV1080<250)
    {
        sample := w.watchSampleV1080
        return w.watchIdleDueV1080
    }
    sample := false
    try
        sample := FarmStandSampleV650(w)
    attacking := FarmWatchAttackingV688(sample,currentAttackPidV550,currentAttackUidV520
        ,currentAttackAtV520,A_TickCount)
    now := FarmWatchNowV688()
    due := FarmWatchIdleStateV688(w,sample,attacking,now)
    w.watchSampleV1080 := sample
    w.watchProbedAtV1080 := now
    w.watchIdleDueV1080 := due
    return due
}

FarmWatchItemsV736(h,player)
{
    inv := D2ReadU32(h,player+0x60)
    if (!inv || !MonsterBossProbeReadV1(h,inv,0x24,ib))
        return ""
    first := NumGet(ib,0x10,"UInt"),cursor := NumGet(ib,0x20,"UInt")
    queue := [first,cursor],seen := {},items := {},index := 1
    while (index<=queue.Length())
    {
        if (index>8192)
            return ""
        unit := queue[index],index++
        if (!unit || seen.HasKey(unit))
            continue
        seen[unit] := true
        if (!MonsterBossProbeReadV1(h,unit,0xEC,ub))
            return ""
        typ := NumGet(ub,0,"UInt"),data := NumGet(ub,0x14,"UInt")
        for _,offset in [0xE4,0xE8]
        {
            next := NumGet(ub,offset,"UInt")
            if (next && !seen.HasKey(next))
                queue.Push(next)
        }
        if (typ!=4 || !data)
            continue
        if (!MonsterBossProbeReadV1(h,data,0xDC,db))
            return ""
        uid := NumGet(ub,0x0C,"UInt"),path := NumGet(ub,0x2C,"UInt")
        if (!uid || !path || !MonsterBossProbeReadV1(h,path,0x14,pb))
            return ""
        items[uid] := NumGet(ub,4,"UInt") . ":" . NumGet(ub,0x10,"UInt")
            . ":" . NumGet(db,0x45,"UChar") . ":" . NumGet(db,0x5C,"UInt")
            . ":" . NumGet(pb,0x0C,"UInt") . ":" . NumGet(pb,0x10,"UInt")
        for _,offset in [0x60,0x64,0x6C,0x70,0x84,0xAC,0xB0,0xB4,0xC8,0xD8]
        {
            next := NumGet(db,offset,"UInt")
            if (next && !seen.HasKey(next) && D2ReadU32(h,next)=4)
                queue.Push(next)
        }
    }
    result := "cursor=" . cursor
    for uid,item in items
        result .= "|" . uid . ":" . item
    if (!PickupReadU32V4(h,inv+0x20,checkCursor) || checkCursor!=cursor)
        return ""
    return result
}

FarmWatchStartV5()
{
    w := FarmWatchStateV688()
    FarmWatchSettingsV5()
    ; Starting Farm is not character activity: preserve the standing clock.
    w.standSampleV650 := false
    w.sampleMissingAtV650 := 0
    w.healthEvidenceV541 := false
    w.retryAtV688 := 0
}

FarmWatchStopV5()
{
    w := FarmWatchStateV688()
    ; Stopping Farm is not character activity either.
    w.standSampleV650 := false
    w.sampleMissingAtV650 := 0
}

FarmWatchSettingsV5()
{
    global farmResetWatchEnabledV217,farmResetWatchMinutesV217
    w := FarmWatchStateV688()
    enable := farmResetWatchEnabledV217 ? true : false
    minutes := Max(1,Min(60,farmResetWatchMinutesV217))
    if (w.enabled!=enable)
    {
        ; Only reset the idle clock when the user changes the enabled state.
        ; A timer tick must not restart the countdown every second.
        w.idleAtV650 := FarmWatchNowV688()
        w.standSampleV650 := false
        w.sampleMissingAtV650 := 0
        w.workProgressV736 := false
        w.retryAtV688 := 0
        w.activeThisTickV691 := false
    }
    w.enabled := enable
    w.period := minutes*60000
}

FarmWatchProgressV5()
{
    global farmWatchV5
    if (IsObject(farmWatchV5) && farmWatchV5.enabled)
    {
        ; This hook is only called after confirmed HP progress.
        now := FarmWatchNowV688()
        farmWatchV5.progressAt := now
        ; HP changes alone are not proof that this character attacked/moved.
        ; The live character sampler is the sole source for resetting standing.
    }
}

FarmWatchObserveV5(pid,level,x,y)
{
    global farmWatchV5,farmControlOwnerV186,backgroundPidV63,backgroundHwndV63,backgroundBirthV63
    w := farmWatchV5
    if (!IsObject(w) || !pid || !level || !x || !y)
        return
    if (farmControlOwnerV186!="")
        w.owner := farmControlOwnerV186
    birth := pid=backgroundPidV63 ? backgroundBirthV63 : BackgroundBirthV63(pid)
    if (pid=backgroundPidV63)
        w.pid := pid,w.hwnd := backgroundHwndV63,w.birth := backgroundBirthV63
    ; First sight of a character/session is just a baseline, not movement.
    if (!w.HasKey("x") || w.samplePid!=pid || w.sampleBirthV650!=birth
        || w.sampleMissingAtV650 || !IsObject(w.standSampleV650))
    {
        w.samplePid := pid,w.sampleBirthV650 := birth
        w.level := level,w.x := x,w.y := y
        return
    }
    if (w.level!=level || (x-w.x)**2+(y-w.y)**2>=1)
    {
        ; Only changed coordinates/map from the same live character prove movement.
        now := FarmWatchNowV688()
        w.progressAt := now,w.level := level,w.x := x,w.y := y
        if (w.enabled)
            FarmWatchRealActivityV1080(w,now)
    }
}


FarmWatchStuckBeginV679(episode,pid,kind,started:=0)
{
    return false
}


FarmStuckWatchTimerV679:
if (farmUserPausedV2026)
    return
FarmWatchStuckDueV679()
return

FarmWatchStuckDueV679()
{
    return
}

FarmWatchPhaseV541()
{
    global stageTwoV166,scosEntryV162,sigTownV148,mapWorkflowV185,autoMonsterAttackOn
    if (IsObject(stageTwoV166))
        return "STAGE3:" . stageTwoV166.phase . ":" . stageTwoV166.loginStepV489
    if (IsObject(scosEntryV162))
        return "ENTRY:" . scosEntryV162.map . ":" . scosEntryV162.phase . ":" . scosEntryV162.boStageV413 . ":" . scosEntryV162.cainPhaseV383
    if (IsObject(sigTownV148))
        return "TOWN:" . sigTownV148.step
    return autoMonsterAttackOn ? "FARM" : "IDLE"
}

FarmWatchResultV541(code,reason,candidate := false,confirmMs := 0,samples := 1)
{
    return {code:code,reason:reason,candidate:candidate,confirmMs:confirmMs,samples:samples}
}

FarmWatchDialogTextV541(dialog)
{
    WinGet, children, ControlListHwnd, ahk_id %dialog%
    text := "",count := 0
    Loop, Parse, children, `n, `r
    {
        child := A_LoopField+0
        WinGetClass, cls, ahk_id %child%
        if (cls!="Static")
            continue
        if (++count>8)
            break
        VarSetCapacity(buf,2048,0),answer := 0
        if (DllCall("SendMessageTimeoutW","Ptr",child,"UInt",0xD,"UPtr",1024,"Ptr",&buf
            ,"UInt",34,"UInt",100,"PtrP",answer,"Ptr"))
            text .= " " . StrGet(&buf,"UTF-16")
    }
    return text
}

FarmWatchProbeV541(w,windowOnlyV631 := false)
{
    global backgroundPidV63,backgroundHwndV63,backgroundBirthV63,stageTwoV166
    pid := w.pid ? w.pid : backgroundPidV63
    birth := w.birth!="" ? w.birth : backgroundBirthV63
    hwnd := w.hwnd ? w.hwnd : backgroundHwndV63
    if (!pid || birth="")
        return FarmWatchResultV541("NO_IDENTITY","Chưa xác định được tiến trình game; không kết luận game lỗi")
    Process, Exist, %pid%
    if (!ErrorLevel)
        return FarmWatchResultV541("PROCESS_EXITED","Tiến trình game đã đóng/crash",true)
    liveBirth := BackgroundBirthV63(pid)
    if (liveBirth="")
        return FarmWatchResultV541("PROCESS_READ_UNKNOWN","Chưa đọc được danh tính tiến trình game")
    if (liveBirth!=birth)
        return FarmWatchResultV541("PROCESS_REPLACED","Tiến trình game cũ đã kết thúc",true)
    WinGet, windowsV541, List, ahk_pid %pid%
    Loop, %windowsV541%
    {
        dialog := windowsV541%A_Index%
        WinGetClass, cls, ahk_id %dialog%
        if (cls!="#32770" || !DllCall("IsWindowVisible","Ptr",dialog))
            continue
        WinGetTitle, title, ahk_id %dialog%
        body := FarmWatchDialogTextV541(dialog)
        if (RegExMatch(title . " " . body,"i)unhandled exception|access[_ ]violation|assertion (?:failure|failed)|fatal error|c0000005|diablo ii exception|application error|unrecoverable internal error|bad inventory data|out of memory"))
            return FarmWatchResultV541("CRASH_DIALOG","Game hiện thông báo crash/exception",true,500,2)
    }
    contact := {pid:pid,hwnd:hwnd,birth:birth}
    if (!RecoveryGameWindowContactV498(contact))
        return FarmWatchResultV541("WINDOW_LOST","Không còn cửa sổ game trong đúng tiến trình",true,2000,2)
    hwnd := contact.hwnd,w.hwnd := hwnd
    WinGet, minmax, MinMax, ahk_id %hwnd%
    if (minmax=-1)
        return FarmWatchResultV541("MINIMIZED","Game đang thu nhỏ; không coi là lỗi")
    answer := 0
    if (DllCall("IsHungAppWindow","Ptr",hwnd)
        || !DllCall("SendMessageTimeoutW","Ptr",hwnd,"UInt",0,"Ptr",0,"Ptr",0,"UInt",34,"UInt",500,"PtrP",answer,"Ptr"))
        return FarmWatchResultV541("WINDOW_HUNG","Cửa sổ game liên tục không phản hồi",true,3000,3)
    if (windowOnlyV631)
        return FarmWatchResultV541("WINDOW_RESPONDING","Cửa sổ game còn phản hồi")
    base := D2GetModuleBaseV35(pid,"D2Client.dll"),h := base ? D2OpenProcess(pid) : 0
    if (!h)
        return FarmWatchResultV541("DLL_READ_UNKNOWN","Không đọc được DLL game; chưa đủ bằng chứng để đóng game")
    try
    {
        if (!RecoveryMenuModuleV528(h,base,0x4B95CA3E,0x135000))
            return FarmWatchResultV541("DLL_VERSION_UNKNOWN","DLL game khác phiên bản; không coi lỗi đọc là game treo")
        player := D2ReadU32(h,base+0x11BBFC),path := player ? D2ReadU32(h,player+0x2C) : 0
        if (player && MonsterBossProbeReadV1(h,path,0x20,pb))
        {
            level := CoordLevelV14(h,NumGet(pb,0x1C,"UInt"))
            x := NumGet(pb,2,"UShort"),y := NumGet(pb,6,"UShort")
            if (level && x && y)
            {
                FarmWatchObserveV5(pid,level,x,y)
                mode := D2ReadU32(h,player+0x10)
                if (mode=0 || mode=17)
                    return FarmWatchResultV541("DEAD_OR_REVIVING","Nhân vật đang chết/hồi sinh; giữ luồng hồi sinh")
                return FarmWatchResultV541("IN_GAME","Game còn nhân vật/map hợp lệ; đứng yên không phải bằng chứng lỗi")
            }
        }
        ui := RecoveryMenuSnapshotV528(contact)
        if (ui.ok && !ui.modal && (ui.login || ui.menu || ui.character || ui.splash))
            return FarmWatchResultV541("LEFT_SESSION","Game đã văng về màn hình đăng nhập/chọn nhân vật",true,3000,2)
        if (!ui.ok)
            return FarmWatchResultV541("CHARACTER_UNREADABLE","Không đọc được nhân vật trong luồng đang chơi",true,30000,3)
        multi := D2GetModuleBaseV35(pid,"D2Multi.dll"),lobby := false
        if (multi && RecoveryMenuModuleV528(h,multi,0x4B95C235,0x3F000))
            for _,control in ui.controls
                if (control.type=6 && (control.callback=multi+0x15380 || control.callback=multi+0x142C0))
                    lobby := true
        if (lobby && IsObject(stageTwoV166) && stageTwoV166.pid=pid)
            return FarmWatchResultV541("STAGE3_LOBBY","GĐ3 đang ở sảnh/tạo phòng; tiếp tục GĐ3")
        if (lobby)
            return FarmWatchResultV541("UNEXPECTED_LOBBY","Game đã ra sảnh ngoài luồng tạo phòng",true,3000,2)
        if (ui.modal)
            return FarmWatchResultV541("MODAL_WITHOUT_GAME","Game mắc ở thông báo/chờ kết nối và không có nhân vật",true,30000,3)
        return FarmWatchResultV541("NO_PLAYER_STALLED","Game không vào lại được map/nhân vật trong cùng một bước",true,30000,3)
    }
    finally
        DllCall("CloseHandle","Ptr",h)
}

FarmWatchConfirmV541(state,probe)
{
    if (!probe.candidate)
    {
        state.healthEvidenceV541 := false
        return false
    }
    key := state.pid . "|" . state.birth . "|" . probe.code . "|" . FarmWatchPhaseV541()
    e := state.healthEvidenceV541
    if (!IsObject(e) || e.key!=key)
        state.healthEvidenceV541 := e := {key:key,at:A_TickCount,reads:0}
    e.reads++
    return e.reads>=probe.samples && A_TickCount-e.at>=probe.confirmMs
}

FarmWatchHealthV5(w)
{
    probe := FarmWatchProbeV541(w)
    w.healthProbeV541 := probe
    return probe.candidate ? probe.reason : ""
}

FarmStandSampleV650(w)
{
    global backgroundPidV63,backgroundHwndV63
    global sigBusyV147,gameItemActionOwner,xRunning,zRunning,buffSequenceRunningV555
    pid := backgroundPidV63 ? backgroundPidV63 : w.pid
    birth := pid ? BackgroundBirthV63(pid) : ""
    if (birth="")
    {
        pid := CoordDisplayGamePidV1()
        birth := pid ? BackgroundBirthV63(pid) : ""
    }
    if (pid && birth!="")
    {
        w.pid := pid,w.birth := birth
        contact := {pid:pid,birth:birth,hwnd:backgroundPidV63=pid ? backgroundHwndV63 : w.hwnd}
        if (RecoveryGameWindowContactV498(contact))
            w.hwnd := contact.hwnd
    }
    base := birth!="" ? D2GetModuleBaseV35(pid,"D2Client.dll") : 0
    h := base ? D2OpenProcess(pid) : 0
    if (!h)
        return false
    try
    {
        player := D2ReadU32(h,base+0x11BBFC)
        path := player ? D2ReadU32(h,player+0x2C) : 0
        if (!player || !MonsterBossProbeReadV1(h,path,0x20,pb))
            return false
        level := CoordLevelV14(h,NumGet(pb,0x1C,"UInt"))
        x := NumGet(pb,2,"UShort"),y := NumGet(pb,6,"UShort")
        if (!level || !x || !y || BackgroundBirthV63(pid)!=birth)
            return false
        if (!MonsterBossProbeReadV1(h,player,0x48,unitSampleV736))
            return false
        itemSampleV736 := FarmWatchItemsV736(h,player)
        workingV736 := sigBusyV147 || gameItemActionOwner!="" || xRunning || zRunning || buffSequenceRunningV555
        return {pid:pid,birth:birth,hwnd:w.hwnd,level:level,x:x,y:y
            ,mode:NumGet(unitSampleV736,0x10,"UInt"),frame:NumGet(unitSampleV736,0x44,"UInt")
            ,items:itemSampleV736,working:workingV736}
    }
    finally
        DllCall("CloseHandle","Ptr",h)
}

FarmWatchDueV5()
{
    global currentAttackUidV520,currentAttackAtV520,currentAttackPidV550
    global stageTwoV166,mapWorkflowV185
    static busy := false
    if (busy)
        return
    busy := true
    try
    {
        w := FarmWatchStateV688()
        FarmWatchSettingsV5()
        SigProtectionWatchV761()
        ; Farm ON/OFF does not decide whether the character is standing.
        if (!w.enabled)
            return
        ; Always read the character first, even while a recovery or SIG
        ; workflow is waiting for a status that may never arrive.
        idleDue := FarmWatchRefreshActivityV1080(w,sample,true)
        now := FarmWatchNowV688()
        if (IsObject(stageTwoV166) && stageTwoV166.loginRecoveryV489)
            return  ; Existing recovery owns reconnect; the clock is still refreshed.
        if (w.sigPausedV753)
            return
        FarmWatchCombatStuckV903(w)
        if (!w.activeThisTickV691)
        {
            try
                BackgroundRefreshV690(w)
        }
        if (idleDue)
        {
            ; If the character cannot be read (disconnected/menu/crash), that
            ; is NOT movement and must not cancel the timeout. The recovery
            ; flow then relaunches Game.exe and logs back in with saved settings.
            reason := IsObject(sample) ? "không đánh và không di chuyển"
                : "không đọc được nhân vật / có thể mất kết nối"
            PortalLogWriteV66("FARM_STAND_TIMEOUT idle_ms=" . (now-w.idleAtV650)
                . " sample=" . (IsObject(sample) ? "LIVE" : "MISSING")
                . " next=STAGE4", "FARM_STAND_TIMEOUT",5000)
            FarmWatchRecoverV5(w,"Đứng " . (w.period/60000) . " phút: " . reason)
        }
    }
    finally
        busy := false
}

; Independent once-per-second backstop for the existing per-target stuck handler.
; Does not interrupt pickup, recover game, or change the configured stuck interval.
FarmWatchCombatStuckV903(w)
{
    ; Independently detect a stalled attack. Do not depend on c.since/c.queued,
    ; which can stay zero when the attack loop is busy.
    ; Only detect here; reuse the existing stuck handler unchanged.
    global autoMonsterAttackOn,monsterChaseV44,chaseCheckSecV9
    global farmPickupPhaseV806,currentAttackPidV550,currentAttackUidV520,currentAttackAtV520
    global monsterCombatUidV45
    if (!IsObject(w))
        return false
    if (!autoMonsterAttackOn || farmPickupPhaseV806 || !w.pid)
    {
        w.combatStallProbeV903 := false
        return false
    }
    ; BC_LOG_FIX: once the B fight is over, the last attack UID stays cached.
    ; Do not report the same stale UID as a combat stall during MOVE C,
    ; ITEM_MOVE or pickup. Real route/item stuck checks still run separately.
    global farmCenterCycleV741
    if (FarmCenterPendingV741(w.pid)
        && farmCenterCycleV741.phase!="ATTACK"
        && farmCenterCycleV741.phase!="ATTACK_FIRST"
        && farmCenterCycleV741.phase!="ATTACK_MORE"
        && farmCenterCycleV741.phase!="ROAD_ATTACK"
        && farmCenterCycleV741.phase!="ITEM_ATTACK")
    {
        w.combatStallProbeV903 := false
        return false
    }
    now := A_TickCount
    uid := currentAttackUidV520, pid := currentAttackPidV550
    ; A selected attack must still be active, not a stale target from an old fight.
    if (!uid || pid!=w.pid || !currentAttackAtV520)
    {
        w.combatStallProbeV903 := false
        return false
    }
    c := monsterChaseV44
    level := (IsObject(c) && c.pid=pid && c.uid=uid) ? c.level : 0
    ; A remote/rapidly changed target can lose monsterChaseV44 before
    ; the backstop fires; use the live Farm cycle level for the UID lock.
    if (!level && FarmCenterPendingV741(pid))
        level := farmCenterCycleV741.level
    hp := (IsObject(c) && c.pid=pid && c.uid=uid) ? c.hp : -1
    probe := w.combatStallProbeV903
    if (!IsObject(probe) || probe.uid!=uid || probe.pid!=pid)
    {
        w.combatStallProbeV903 := {uid:uid,pid:pid,level:level,hp:hp,since:now}
        return false
    }
    if (level)
        probe.level := level
    ; HP decreasing means combat progressed: reset the timeout.
    if (hp>=0 && (probe.hp<0 || hp<probe.hp))
    {
        probe.hp := hp, probe.since := now
        return false
    }
    if (hp>=0)
        probe.hp := hp
    if (now-probe.since<Max(1,chaseCheckSecV9)*1000)
        return false
    ; Timeout reached. Without the real map level a UID lock cannot match
    ; MonsterRetryExcludedV44 and the same monster is targeted again.
    if (!probe.level)
    {
        PortalLogWriteV66("FARM_COMBAT_STUCK_INPUT uid=" . uid
            . " action=WAIT_LEVEL_UNKNOWN", "FARM_COMBAT_STUCK_LEVEL",1000)
        return false
    }
    FarmStuckSkipRememberV1234(uid,-1,-1,pid)
    w.combatStallProbeV903 := false
    MonsterStuckUidSkipV711(uid,probe.level,pid)
    PortalLogWriteV66("FARM_COMBAT_STUCK_INPUT uid=" . uid
        . " level=" . probe.level . " check_sec=" . chaseCheckSecV9
        . " action=SKIP_UID_AND_RESUME")
    FonInfoPushV385("Xét kẹt đánh đủ " . chaseCheckSecV9 . " giây: bỏ qua quái UID " . uid . ", tiếp tục farm.")
    return true
}

FarmWatchRecoverV5(w,reason,confirmedWindowV631 := false)
{
    global farmWatchV5,stageTwoV166,mapWorkflowV185,farmControlOwnerV186,farmRestartReasonV238
    global recoveryGamePathV489,farmStopMoveV124
    ; Re-read actual movement/attacks before starting recovery. A pending
    ; wait/retry must never win over newly observed character activity.
    FarmWatchRefreshActivityV1080(w,recoverySampleV1080)
    now := FarmWatchNowV688()
    if (w.sigPausedV753 || now-w.idleAtV650<w.period)
        return false
    if (w.recoveringV631 || now<w.retryAtV688
        || (IsObject(stageTwoV166) && stageTwoV166.loginRecoveryV489))
        return false
    w.recoveringV631 := true
    w.retryAtV688 := now+5000
    try
    {
        RecoveryLoginSettingsSaveV489()
        if (!FileExist(RecoveryGameExecutableV735(recoveryGamePathV489)))
        {
            FonInfoPushV385(reason . ". Cần đúng đường dẫn Game.exe; bộ đếm vẫn chạy và tự thử lại.")
            return false
        }
        owner := farmControlOwnerV186!="" ? farmControlOwnerV186 : w.owner
        resumeMap := owner!="" && owner!="TEST"
        r := {pid:w.pid,hwnd:w.hwnd,birth:w.birth,phase:"RECOVER",at:A_TickCount
            ,until:A_TickCount+180000,tries:0,continuous:resumeMap,restartRunV17:resumeMap
            ,recoveryOnlyV688:!resumeMap}
        ; Use the up-to-date watchdog state, not a stale SIG wait token.
        FarmWatchRefreshActivityV1080(w,recoverySampleV1080)
        if (w.sigPausedV753 || FarmWatchNowV688()-w.idleAtV650<w.period)
            return false
        farmStopMoveV124 := false
        SetTimer, FarmStopMoveTimerV124, Off
        farmControlOwnerV186 := owner,farmRestartReasonV238 := "STUCK"
        mapWorkflowV185 := resumeMap ? {map:owner,stage:3,startLevel:0,testRows:0} : false
        stageTwoV166 := r
        if (!RecoveryLoginBeginV489(r,"IDLE_TIMEOUT",true))
        {
            if (stageTwoV166=r)
                stageTwoV166 := false
            return false
        }
        w.retryAtV688 := now+w.period
        FonInfoPushV385(reason . ". Đang phục hồi game.")
        SetTimer, StageTwoTimerV166, 250
        return true
    }
    finally
        w.recoveringV631 := false
}

FarmMainFlowV8(r,ctx,player,level,px,py,finishMap := true,key := "",points := false,ByRef pathBuffer := false)
{
    global scosEntryV162
    if (scosEntryV162!=r)
        return false
    if (!finishMap)
    {
        ctx.playerV10 := player
        return FarmCommonRouteTickV3(r,ctx,pathBuffer,level,key,points,false,true)
    }
    FarmCommonRouteEndV3(r)
    return MapEntryFirstBuffFinishV248(r,ctx,player,level,px,py,false)
}

FarmNoFightFlowV8(r,ctx,ByRef pb,level,key,points := false,handoff := false)
{
    return FarmCommonRouteTickV3(r,ctx,pb,level,key,points,handoff)
}

FarmSigFlowV8(r)
{
    return MapStage1SigReadyV374(r)
}


FarmGoldFlowV8(r,ctx,player,ByRef pb,px,py)
{
    global scosEntryV162
    if (scosEntryV162!=r)
        return false
    g := r.goldActionV8
    if (!IsObject(g))
        r.goldActionV8 := g := {pid:r.pid,phase:"WP",stashRouteDoneV230:true,entryGoldV315:true}
    state := g.goldStepV229
    message := state="OPEN_WAIT" ? "Cất tiền: đã gửi lệnh mở rương, đang chờ để gửi tiền."
        : state="VERIFY" ? "Cất tiền: đã gửi tiền, đang chờ số dư xác nhận."
        : state="CLOSE" ? "Cất tiền: đã xác nhận tiền vào rương, đang đóng rương."
        : "Cất tiền: đang mở rương ở gần nhân vật."
    FarmGoldInfoV9(g,message)
    return !ScosGoldBeforeWpV229(g,ctx,player,pb,px,py,true)
}


FarmWaypointFlowV8(r,ctx,ByRef pb,level,px,py,wpClass,destination)
{
    global scosEntryV162
    if (scosEntryV162!=r)
        return false
    w := r.wpFlowV8
    if (!IsObject(w))
        r.wpFlowV8 := w := {phase:"OPEN",at:0}
    if (w.phase="SELECT_WAIT")
    {
        if (A_TickCount-w.at<3000)
            return false
        w.phase := "OPEN"
    }
    if (w.phase="OPEN_WAIT")
    {
        if (A_TickCount-w.at<500)
            return false
        if (A_TickCount-w.at>5000)
        {
            w.phase := "OPEN"
            PortalLogWriteV66("WP_TIMEOUT reason=MENU_NOT_OPENED next=RETRY_OPEN")
            return false
        }
        if (!MapStage9V373(ctx,level,{uid:w.uid},"WP",destination))
            return false
        WpCloseAfterSelectV331("SHARED_WP")
        if (scosEntryV162!=r)
            return false
        w.phase := "SELECT_WAIT",w.at := A_TickCount
        return false
    }
    wp := wpClass ? CycObjectV42(ctx.h,pb,wpClass) : TranFindWaypointV358(ctx.h,pb,px,py)
    if (!IsObject(wp))
    {
        if (r.map="CAIN" && level=168)
            return FarmCainGateV14(r,ctx,pb,level,px,py)
        return false
    }
    if ((px-wp.x)**2+(py-wp.y)**2>400)
    {
        distance := Sqrt((px-wp.x)**2+(py-wp.y)**2)
        approach := {x:Round(wp.x+(px-wp.x)*5/distance),y:Round(wp.y+(py-wp.y)*5/distance)}
        FarmNoFightFlowV8(r,ctx,pb,level,"WP_" . wp.uid,[approach])
        return false
    }
    FarmCommonRouteEndV3(r)
    if (MapStage9V373(ctx,level,wp,"WP"))
    {
        w.uid := wp.uid,w.phase := "OPEN_WAIT",w.at := A_TickCount
        FonInfoPushV385("Đã mở WP; đang chọn map " . destination . ".")
    }
    return false
}

FarmGoldInfoV9(r,message)
{
    if (r.infoAtV9 && A_TickCount-r.infoAtV9<3000)
        return
    r.infoTextV9 := message,r.infoAtV9 := A_TickCount
    FonInfoPushV385(message)
}


FarmCommonCombatV10()
{
    global scosEntryV162
    return IsObject(scosEntryV162.commonRouteV3) && scosEntryV162.commonRouteV3.fightOn
}

FarmMapPlanV10(map,level)
{
    if (map="CYC")
    {
        if (level=75 || level=109)
            return {town:true,gold:true,fight:false,wp:level=75 ? 237 : 429,next:137}
        if (level=137)
            return {fight:false,exitClass:194,next:164,kind:"OBJECT"}
        if (level=164)
            return {fight:true,exitClass:60,next:150,kind:"OBJECT"}
        if (level=150)
            return {final:true}
    }
    else if (map="UBU")
    {
        if (level=75)
            return {town:true,gold:true,fight:false,wp:237,next:140}
        if (level=140)
            return {fight:true,exitClass:0,next:147,kind:"HANG"}
        if (level=147)
            return {fight:false,exitClass:0,next:148,kind:"HANG"}
        if (level=148)
            return {final:true}
    }
    else if (map="TRAN")
    {
        if (level=40)
            return {town:true,gold:false,fight:false,wp:0,next:146}
        if (level=146)
            return {final:true}
    }
    else if (map="CAIN")
    {
        if (level=40)
            return {town:true,gold:true,fight:false,wp:0,next:168}
        if (level=168)
            return {town:false,waypoint:true,fight:true,wp:0,next:183}
    }
        else if (map="M3000")
    {
        if (level=75)
            return {town:true,gold:true,fight:false,wp:237,next:140}
        if (level=109)
            return {town:true,gold:true,fight:false,wp:429,next:75}
        if (level=140)
            return {fight:true,exitClass:60,next:141,kind:"PORTAL"}
        if (level=141)
            return {final:true}
    }
    else if (map="VIZ")
    {
        if (level=75)
            return {town:true,gold:true,fight:false,wp:237,next:154}
        if (level=109)
            return {town:true,gold:true,fight:false,wp:429,next:75}
        if (level=154)
            return {final:true, viz:true}
    }
    return false
}

FarmMapAssemblyV10(r,ctx,player,ByRef pb,level,px,py,map)
{
    global scosEntryV162,farmControlOwnerV186,coordSavedV15
    if (scosEntryV162!=r || !level)
        return false
    plan := FarmMapPlanV10(map,level)
    if (!IsObject(plan))
    {
        FonInfoPushV385(map . ": map " . level . " không thuộc lộ trình đã ghép.")
        return false
    }
    farmControlOwnerV186 := map,ctx.entryStateV42 := r
    if (r.assemblyLevelV10!=level)
    {
        FarmCommonRouteEndV3(r)
        r.assemblyLevelV10 := level,r.assemblyStepV10 := plan.town ? "SIG" : "ROUTE"
        r.assemblyRouteV10 := false,r.goldVisitV8 := false,r.wpFlowV8 := false,r.exitFlowV10 := false
        r.phase := plan.town ? "WP" : "COMBAT"
        FonInfoPushV385(map . ": đã vào map " . level . ".")
    }
    r.until := A_TickCount+300000
    
    if (plan.final)
    {
        if (map="VIZ") 
        {
            result := FarmMainFlowV8(r,ctx,player,level,px,py,false,"VIZ_MAP",false,pb)
            if (result == "DONE" && scosEntryV162==r) 
            {
                r.vizRoute := coordSavedV15.Clone()
                FarmCommonRouteEndV3(r)
                r.phase := "SEARCH"
                Stage2FlowConfigureV380("ITEM",1830,7,true)
                MapStageSetV185(2)
                autoMonsterAttackOn := true
                SetTimer, AutoMonsterAttackTimer, Off
                farmPickupBlockedV57 := false,farmPickupAllowedV57 := true
                PickupEnabledSetV71(true,true,false)
                FonInfoPushV385("Viz: lộ trình DONE; tìm boss 1629.")
            }
            return true
        }
        return FarmMainFlowV8(r,ctx,player,level,px,py)
    }
    
    if (r.assemblyStepV10="SIG")
    {
        if (!FarmSigFlowV8(r))
            return false
        r.assemblyStepV10 := "ROUTE"
        return false
    }
    if (r.assemblyStepV10="ROUTE")
    {
        key := map . "_MAP_" . level
        result := plan.fight ? FarmMainFlowV8(r,ctx,player,level,px,py,false,key,false,pb)
            : FarmNoFightFlowV8(r,ctx,pb,level,key)
        if (result!="DONE" || scosEntryV162!=r)
            return false
        r.assemblyRouteV10 := coordSavedV15.Clone()
        FarmCommonRouteEndV3(r)
        r.assemblyStepV10 := "EXIT"
        return false
    }
    if (r.assemblyStepV10="EXIT")
    {
        if (plan.town || plan.waypoint)
            return FarmWaypointFlowV8(r,ctx,pb,level,px,py,plan.wp,plan.next)
        return FarmExitFlowV10(r,ctx,player,pb,level,px,py,plan)
    }
    return false
}

FarmExitFlowV10(r,ctx,player,ByRef pb,level,px,py,plan)
{
    global scosEntryV162
    if (scosEntryV162!=r)
        return false
    e := r.exitFlowV10
    if (!IsObject(e))
        r.exitFlowV10 := e := {at:0,target:false}
    target := e.target
    if (IsObject(target))
        target := plan.kind="HANG" ? UbuExitV62(ctx.h,pb,target.x,target.y,1,target.cls)
            : CycObjectV42(ctx.h,pb,plan.exitClass,target.x,target.y,1)
    if (!IsObject(target))
    {
        points := r.assemblyRouteV10
        last := IsObject(points) && points.Length() ? points[points.Length()] : {x:px,y:py}
        target := plan.kind="HANG" ? UbuExitV62(ctx.h,pb,last.x,last.y,50)
            : CycObjectV42(ctx.h,pb,plan.exitClass,last.x,last.y,50)
        if (!IsObject(target))
            target := plan.kind="HANG" ? UbuExitV62(ctx.h,pb,px,py,100)
                : CycObjectV42(ctx.h,pb,plan.exitClass,px,py,100)
        if (!IsObject(target))
            return false
    }
    e.target := target
    if ((px-target.x)**2+(py-target.y)**2>100)
    {
        key := "EXIT_" . level . "_" . target.uid
        points := [{x:target.x,y:target.y}]
        if (plan.fight)
            FarmMainFlowV8(r,ctx,player,level,px,py,false,key,points,pb)
        else
            FarmNoFightFlowV8(r,ctx,pb,level,key,points)
        return false
    }
    FarmCommonRouteEndV3(r)
    if (e.at && A_TickCount-e.at<1500)
        return false
    if (MapStage9V373(ctx,level,target))
    {
        e.at := A_TickCount
        FonInfoPushV385(r.map . ": đang vào lối sang map " . plan.next . ".")
    }
    return false
}


FarmSharedSigMapV781(map)
{
    return map="SCOS" || map="NAO" || map="CYC" || map="UBU" || map="M3000" || map="LIB"
}

FarmSharedGoldExitReadyV781(r,ctx,ByRef pb,level)
{
    global scosEntryV162
    if (scosEntryV162!=r || !FarmSharedSigMapV781(r.map)
        || !r.entryGoldV315 || r.goldAlongDoneV12 || !FarmReviveTownLevelV295(level))
        return true
    player := ctx.playerV12
    if (!player)
        return false
    px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort")
    gold := ScosGoldReadV229(ctx.h,player)
    if (!IsObject(gold))
        return false
    if ((!gold.gold || gold.bank>=gold.limit) && !TownStorePendingV628(ctx,player,r))
    {
        r.goldAlongDoneV12 := true
        return true
    }
    ; Keep the FAUT deposit/verification/close sequence. If the saved route
    ; did not pass within five tiles of the chest, go to it before leaving town.
    stash := CycObjectV42(ctx.h,pb,267)
    if (!IsObject(stash))
    {
        if (!r.goldBeforeExitAtV781)
            r.goldBeforeExitAtV781 := A_TickCount
        if (A_TickCount-r.goldBeforeExitAtV781>15000)
            throw Exception("Cất tiền: chưa tìm thấy rương 267 trước khi rời thành")
        return false
    }
    r.goldBeforeExitAtV781 := 0
    distance := Sqrt((px-stash.x)**2+(py-stash.y)**2)
    if (distance>20)
    {
        MapStage1MoveV374(ctx,Round(stash.x+(px-stash.x)*5/distance)
            ,Round(stash.y+(py-stash.y)*5/distance))
        return false
    }
    if (!FarmGoldFlowV8(r,ctx,player,pb,px,py))
        return false
    r.goldAlongDoneV12 := true
    PortalLogWriteV66("FARM_SHARED_GOLD_DONE map=" . r.map . " level=" . level . " next=CONTINUE_ROUTE")
    return true
}

FarmGoldAlongRouteV12(r,ctx,ByRef pb,level)
{
    global scosEntryV162,coordRouteV16,autoMonsterAttackOn
    if (scosEntryV162!=r || !r.entryGoldV315 || r.goldAlongDoneV12 || !FarmReviveTownLevelV295(level))
        return false
    c := r.commonRouteV3
    if (!IsObject(c) || c.fightOn || !IsObject(coordRouteV16))
        return false
    player := ctx.playerV12,px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort")
    if (!player || !px || !py)
        return false
    if (!r.goldAlongBusyV12)
    {
        gold := ScosGoldReadV229(ctx.h,player)
        if (!IsObject(gold))
            return true
        if ((!gold.gold || gold.bank>=gold.limit) && !TownStorePendingV628(ctx,player,r))
        {
            r.goldAlongDoneV12 := true
            return false
        }
        stash := CycObjectV42(ctx.h,pb,267)
        if (!IsObject(stash) || (px-stash.x)**2+(py-stash.y)**2>25)
            return false
        r.goldAlongBusyV12 := true,r.goldActionV8 := false
        autoMonsterAttackOn := false
        MapStage1MoveV374(ctx,px,py)
        FonInfoPushV385("Đang đi qua rương trong tầm cất tiền: cất tại đây rồi đi tiếp.")
        return true
    }
    if (!FarmGoldFlowV8(r,ctx,player,pb,px,py))
        return true
    if (scosEntryV162!=r || r.commonRouteV3!=c)
        return true
    r.goldAlongBusyV12 := false,r.goldAlongDoneV12 := true
    autoMonsterAttackOn := true
    FonInfoPushV385("Đã cất tiền; tiếp tục lộ trình, không quay lại rương.")
    return false
}

PickupMatchingInventoryClearV551(h,player,pid,itemClass,itemData,groundUid,fileIndex := -1)
{
    global pickupStashListV217
    static lastTry := 0,lastUid := 0,lastPid := 0
    inv := D2ReadU32(h,player+0x60),first := inv ? D2ReadU32(h,inv+0x10) : 0
    cursor := inv ? PickupCursorV4(h,inv) : false
    if (!inv || !IsObject(cursor) || cursor.unit)
        return "WAIT"
    if (!first)
        return "CLEAR"
    all := V9SnapshotAllItems({pid:pid,h:h,inv:inv,first:first})
    if (!IsObject(all))
        return "WAIT"
    for uid,item in all
    {
        if (item.cls!=itemClass || item.loc!=0 || item.owner!=inv || !item.data
            || D2ReadU8V18(h,item.data)!=itemData || uid=groundUid)
            continue
        if (fileIndex>=0)
        {
            if (!MonsterBossProbeReadV1(h,item.data+0x28,4,indexBytes))
                return "WAIT"
            if (NumGet(indexBytes,0,"UInt")!=fileIndex)
                continue
        }
        if (lastPid=pid && lastUid=uid && A_TickCount-lastTry<750)
            return "WAIT"
        lastTry := A_TickCount,lastUid := uid,lastPid := pid,item.uid := uid
        result := PickupMoveToCubeV2(h,pid,inv,item)
        if (result="MOVED" && IsObject(pickupStashListV217))
            pickupStashListV217.Delete(uid)
        FonInfoPushV385(result="MOVED" ? "Đã chuyển vật phẩm cần nhặt từ rương vào cube; tiếp tục nhặt vật phẩm dưới đất."
            : "Chưa chuyển được vật phẩm vào cube; giữ bước chuyển, chưa về thành.")
        return result="MOVED" ? "MOVED" : "WAIT"
    }
    return "CLEAR"
}

FarmCainGateV14(r,ctx,ByRef pb,level,px,py)
{
    global scosEntryV162
    if (scosEntryV162!=r)
        return false
    exit := CainFindExitV383(ctx.h,pb,px,py)
    if (!IsObject(exit))
        return false
    if ((px-exit.x)**2+(py-exit.y)**2>100)
    {
        FarmMainFlowV8(r,ctx,ctx.playerV12,level,px,py,false,"CAIN_EXIT_" . exit.uid,[{x:exit.x,y:exit.y}],pb)
        return false
    }
    FarmCommonRouteEndV3(r)
    if (!r.cainGateAtV14 || A_TickCount-r.cainGateAtV14>=1500)
        if (MapStage9V373(ctx,level,exit))
            r.cainGateAtV14 := A_TickCount
    return false
}

FarmTubeMoveV14(h,ByRef pb,s,target)
{
    return CainWallFollowV506(h,pb,s,target.portalV14 ? target : false)
}

CainWallGridV506(h,ByRef pb)
{
    static cacheV506 := {key:"", at:0, g:0}
    room := NumGet(pb,0x1C,"UInt"),px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort")
    cacheKeyV506 := DllCall("GetProcessId","Ptr",h,"UInt") . "|" . room
    if (cacheV506.key=cacheKeyV506 && A_TickCount-cacheV506.at<500 && IsObject(cacheV506.g)
        && px>=cacheV506.g.x && px<cacheV506.g.x+cacheV506.g.n
        && py>=cacheV506.g.y && py<cacheV506.g.y+cacheV506.g.n)
        return cacheV506.g
    radius := 20,n := radius*2+1
    g := {x:px-radius,y:py-radius,n:n,cells:[],known:[],distance:[],nearest:false,maps:0}
    Loop, % n*n
        g.cells.Push(0x27),g.known.Push(false),g.distance.Push(0)
    for _,r1 in MonsterLoadedRoomsV20(h,room)
    {
        coll := D2ReadU32(h,r1+0x20)
        if (!coll || !MonsterBossProbeReadV1(h,coll,0x24,header))
            continue
        ox := NumGet(header,0,"Int"),oy := NumGet(header,4,"Int")
        w := NumGet(header,8,"UInt"),hh := NumGet(header,12,"UInt"),data := NumGet(header,32,"UInt")
        if (!data || w<1 || hh<1 || w>1024 || hh>1024 || w*hh>262144
            || ox<0 || oy<0 || ox>65535 || oy>65535)
            continue
        x1 := Max(g.x,ox),x2 := Min(g.x+n-1,ox+w-1)
        y1 := Max(g.y,oy),y2 := Min(g.y+n-1,oy+hh-1)
        if (x1>x2 || y1>y2 || !MonsterBossProbeReadV1(h,data,w*hh*2,raw))
            continue
        g.maps++
        Loop, % y2-y1+1
        {
            wy := y1+A_Index-1
            Loop, % x2-x1+1
            {
                wx := x1+A_Index-1,i := (wy-g.y)*n+wx-g.x+1
                mask := NumGet(raw,((wy-oy)*w+wx-ox)*2,"UShort")
                g.cells[i] := mask,g.known[i] := true
                g.distance[i] := (mask & 0x21) ? 0 : 99
                d := (wx-px)**2+(wy-py)**2
                if ((mask & 1) && (!IsObject(g.nearest) || d<g.nearest.d))
                    g.nearest := {x:wx,y:wy,d:d}
            }
        }
    }
    center := radius*n+radius+1
    if (!g.maps || !g.known[center] || (g.cells[center] & 0x21))
        return false
    Loop, % n
    {
        yy := A_Index
        Loop, % n
        {
            xx := A_Index,i := (yy-1)*n+xx
            d := g.distance[i]
            if (xx>1)
                d := Min(d,g.distance[i-1]+1)
            if (yy>1)
            {
                d := Min(d,g.distance[i-n]+1)
                if (xx>1)
                    d := Min(d,g.distance[i-n-1]+1)
                if (xx<n)
                    d := Min(d,g.distance[i-n+1]+1)
            }
            g.distance[i] := d
        }
    }
    Loop, % n
    {
        yy := n-A_Index+1
        Loop, % n
        {
            xx := n-A_Index+1,i := (yy-1)*n+xx,d := g.distance[i]
            if (xx<n)
                d := Min(d,g.distance[i+1]+1)
            if (yy<n)
            {
                d := Min(d,g.distance[i+n]+1)
                if (xx>1)
                    d := Min(d,g.distance[i+n-1]+1)
                if (xx<n)
                    d := Min(d,g.distance[i+n+1]+1)
            }
            g.distance[i] := d
        }
    }
    cacheV506 := {key:cacheKeyV506, at:A_TickCount, g:g}
    return g
}

CainWallCellV506(g,x,y)
{
    xx := Round(x)-g.x,yy := Round(y)-g.y
    if (xx<0 || yy<0 || xx>=g.n || yy>=g.n)
        return {known:false,blocked:true,gap:0,wall:false}
    i := yy*g.n+xx+1
    return {known:g.known[i],blocked:!g.known[i] || (g.cells[i] & 0xC21)
        ,gap:g.distance[i],wall:g.known[i] && (g.cells[i] & 0x21)}
}

CainWallLineV506(g,x,y,tx,ty,gap := 1)
{
    steps := Ceil(Max(Abs(tx-x),Abs(ty-y)))
    if (!steps)
        return true
    Loop, % steps
    {
        c := CainWallCellV506(g,x+(tx-x)*A_Index/steps,y+(ty-y)*A_Index/steps)
        if (c.blocked || c.gap<gap)
            return false
    }
    return true
}

CainWallFollowV506(h,ByRef pb,s,portal := false)
{
    global scosEntryV162,chaseCheckSecV9
    if (!CainCaveMapV502(s.level) || !BossSearchActiveV430(s.pid,s.level)
        || !IsObject(scosEntryV162) || scosEntryV162.cainTubeV14!=s)
        return false
    px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort")
    if (!IsObject(s.wallFollowV506))
        s.wallFollowV506 := {dx:s.forwardXV14,dy:s.forwardYV14,goal:false,visits:{},blocked:{},last:0,side:1,oriented:false,recent:[]}
    f := s.wallFollowV506
    if (IsObject(f.goal))
    {
        if (px!=f.px || py!=f.py)
            f.px := px,f.py := py,f.movedAt := A_TickCount
        if ((px-f.goal.x)**2+(py-f.goal.y)**2<=2)
        {
            f.dx := f.goal.dx,f.dy := f.goal.dy
            f.recent.Push({x:f.goal.fromX,y:f.goal.fromY})
            if (f.recent.Length()>10)
                f.recent.RemoveAt(1)
            f.goal := false
            key := Floor(px/3) . ":" . Floor(py/3)
            f.visits[key] := f.visits[key]+1
        }
        else if (f.sent && A_TickCount-f.movedAt>=Max(0.5,chaseCheckSecV9)*1000)
        {
            f.blocked[f.goal.key] := A_TickCount+5000
            PortalLogWriteV66("CAIN_COLLISION_STUCK xy=" . px . "," . py . " next=REPLAN_WALL tele=OFF","CAIN_COLLISION_STUCK",1000)
            f.goal := false
        }
        else
        {
            if (!f.sent && A_TickCount-f.last>=250)
            {
                f.last := A_TickCount
                if (NativeMovePointV14(s.pid,f.goal.x,f.goal.y,s.level,false,false,true,false,{searchV430:s}))
                    f.sent := true,f.movedAt := A_TickCount
                else
                    PortalLogWriteV66("CAIN_COLLISION_SEND_WAIT xy=" . px . "," . py . " target=" . f.goal.x . "," . f.goal.y,"CAIN_COLLISION_SEND_WAIT",1500)
            }
            return true
        }
    }
    g := CainWallGridV506(h,pb)
    if (!IsObject(g))
    {
        FonInfoPushV385("Cain " . s.level . ": chưa đọc được ô va chạm; chờ dữ liệu phòng.")
        PortalLogWriteV66("CAIN_COLLISION_WAIT level=" . s.level . " xy=" . px . "," . py . " tele=OFF","CAIN_COLLISION_WAIT",2000)
        return false
    }
    center := CainWallCellV506(g,px,py),minGap := Min(2,Max(1,center.gap))
    if (IsObject(portal) && (portal.x-px)*f.dx+(portal.y-py)*f.dy>=0
        && CainWallLineV506(g,px,py,portal.x,portal.y,1))
    {
        dx := portal.x-px,dy := portal.y-py,len := Sqrt(dx*dx+dy*dy)
        best := {x:Round(px+dx*Min(6,len)/len),y:Round(py+dy*Min(6,len)/len),dx:dx/len,dy:dy/len,key:"PORTAL"}
    }
    else
    {
        best := false,bestScore := 1.0e30
        if (!f.oriented && center.gap<=5 && IsObject(g.nearest))
        {
            wx := g.nearest.x-px,wy := g.nearest.y-py,len := Sqrt(wx*wx+wy*wy)
            if (len>0)
            {
                dx := wy/len,dy := -wx/len
                if (dx*f.dx+dy*f.dy<0)
                    dx := -dx,dy := -dy,f.side := -1
                f.dx := dx,f.dy := dy,f.oriented := true,f.started := true
            }
        }
        Loop, 6
        {
            pass := Mod(A_Index-1,3)+1
            minimumForward := A_Index<=3 ? 0.70 : -0.001
            reach := pass=1 ? 5 : 2
            checkGap := pass=3 ? 1 : minGap
            Loop, 16
            {
                angle := (A_Index-1)*0.3926990817,dx := Cos(angle),dy := Sin(angle)
                tx := Round(px+dx*reach),ty := Round(py+dy*reach),key := tx . ":" . ty
                ax := tx-px,ay := ty-py,actualLen := Sqrt(ax*ax+ay*ay)
                if (actualLen<1)
                    continue
                dx := ax/actualLen,dy := ay/actualLen
                forward := dx*f.dx+dy*f.dy
                if (forward<minimumForward)
                    continue
                retraces := false
                for _,old in f.recent
                    if ((tx-old.x)**2+(ty-old.y)**2<=2)
                    {
                        retraces := true
                        break
                    }
                if (retraces)
                    continue
                if ((f.blocked.HasKey(key) && A_TickCount<f.blocked[key])
                    || !CainWallLineV506(g,px,py,tx,ty,checkGap))
                    continue
                c := CainWallCellV506(g,tx,ty),sideGap := 12
                Loop, 11
                {
                    left := CainWallCellV506(g,tx-f.side*dy*A_Index,ty+f.side*dx*A_Index)
                    if (!left.known)
                        break
                    if (left.wall)
                    {
                        sideGap := A_Index
                        break
                    }
                }
                forward := dx*f.dx+dy*f.dy
                visits := f.visits[Floor(tx/3) . ":" . Floor(ty/3)]+0
                if (!f.started)
                    score := (1-forward)*5+c.gap*2+visits*2
                else
                    score := Abs(sideGap-3.5)*2+Abs(c.gap-3.5)+(1-forward)*3+visits*2
                if (score<bestScore)
                    bestScore := score,best := {x:tx,y:ty,dx:dx,dy:dy,key:key}
            }
            if (IsObject(best))
                break
        }
    }
    if (!IsObject(best))
    {
        PortalLogWriteV66("CAIN_COLLISION_NO_STEP level=" . s.level . " xy=" . px . "," . py . " gap=" . center.gap . " tele=OFF","CAIN_COLLISION_NO_STEP",1500)
        return false
    }
    best.fromX := px,best.fromY := py
    f.goal := best,f.px := px,f.py := py,f.movedAt := A_TickCount,f.sent := false,f.last := 0
    PortalLogWriteV66("CAIN_COLLISION_WALL_MOVE level=" . s.level . " from=" . px . "," . py . " target=" . best.x . "," . best.y
        . " gap=" . center.gap . " desired_gap=3-4 maps=" . g.maps . " forward_only=1 wall_side=" . f.side . " tele=OFF","CAIN_COLLISION_WALL_MOVE",1000)
    if (NativeMovePointV14(s.pid,best.x,best.y,s.level,false,false,true,false,{searchV430:s}))
        f.sent := true,f.last := A_TickCount
    return true
}


FarmAttackHoldingV15()
{
    global farmAttackHoldV15,autoMonsterPacketPendingV1
    return IsObject(farmAttackHoldV15) || (IsObject(autoMonsterPacketPendingV1) && autoMonsterPacketPendingV1.holdDownV15)
}

FarmAttackHoldReleaseV15()
{
    global farmAttackHoldV15,autoMonsterPacketPendingV1
    if (IsObject(farmAttackHoldV15) && farmAttackHoldV15.form6V716)
        return Form6ReleaseV716()
    pending := autoMonsterPacketPendingV1
    if (IsObject(pending))
    {
        if (pending.holdDownV15)
            pending.releaseV15 := true
        if (IsObject(farmAttackHoldV15))
            farmAttackHoldV15.releaseV15 := true
        return !pending.holdDownV15 && !pending.holdUpV15 && !IsObject(farmAttackHoldV15)
    }
    held := farmAttackHoldV15
    if (!IsObject(held))
        return true
    held.releaseV15 := true
    if (held.birth="" || BackgroundBirthV63(held.pid)!=held.birth)
    {
        DllCall("VirtualFreeEx","Ptr",held.process,"Ptr",held.remote,"UPtr",0,"UInt",0x8000)
        DllCall("CloseHandle","Ptr",held.process)
        farmAttackHoldV15 := false
        return true
    }
    code := "60B9" . NativeLE32V9(held.remote+128) . "C70112000000"
    code .= "C705" . NativeLE32V9(held.base+0x11C2F8) . "00000000"
    code .= "C705" . NativeLE32V9(held.base+0x11C2F4) . "00000000"
    code .= "B8" . NativeLE32V9(held.base+0x18A00) . "FFD06131C0C20400"
    length := StrLen(code)//2
    VarSetCapacity(blob,128,0)
    Loop, %length%
        NumPut("0x" . SubStr(code,(A_Index-1)*2+1,2),blob,A_Index-1,"UChar")
    SetTimer, AutoMonsterPacketCleanupTimerV1, 50
    if (!DllCall("WriteProcessMemory","Ptr",held.process,"Ptr",held.remote,"Ptr",&blob,"UPtr",128,"UPtrP",written) || written!=128)
        return false
    DllCall("FlushInstructionCache","Ptr",held.process,"Ptr",held.remote,"UPtr",length)
    thread := DllCall("CreateRemoteThread","Ptr",held.process,"Ptr",0,"UPtr",0,"Ptr",held.remote,"Ptr",0,"UInt",0,"UIntP",tid,"Ptr")
    if (!thread)
        return false
    autoMonsterPacketPendingV1 := {process:held.process,remote:held.remote,thread:thread,uid:held.uid
        ,kind:"RIGHT_UP",holdUpV15:true,setAt:A_TickCount,autoCall:true}
    farmAttackHoldV15 := false
    return false
}

FarmAttackKeepV15()
{
    global farmAttackHoldV15,autoMonsterAttackOn,monsterCombatUidV45
    if (IsObject(farmAttackHoldV15) && farmAttackHoldV15.form6V716)
        return Form6KeepV716(farmAttackHoldV15)
    held := farmAttackHoldV15
    if (!IsObject(held) || held.releaseV15 || !autoMonsterAttackOn || !Stage2FightEnabledV9()
        || !FarmAttackRowFiveV18()
        || monsterCombatUidV45!=held.uid || D2GetActiveGamePidV95()!=held.pid)
        return false
    if (!MonsterBossProbeReadV1(held.process,held.unit,0x14,unit))
        return false
    return NumGet(unit,0,"UInt")=1 && NumGet(unit,12,"UInt")=held.uid
        && NumGet(unit,16,"UInt")!=0 && NumGet(unit,16,"UInt")!=12
}

FarmAttackReleaseWaitV15()
{
    if (FarmAttackHoldReleaseV15())
        return true
    at := A_TickCount
    while (A_TickCount-at<750)
    {
        AutoMonsterPacketCleanupV1()
        if (FarmAttackHoldReleaseV15())
            return true
        Sleep, 10
    }
    return false
}


FarmAttackAimV16(held)
{
    if (held.form6V716)
        return Form6AimNextV716(held)
    hwnd := GameTargetHwndV63()
    WinGet, pid, PID, ahk_id %hwnd%
    if (!hwnd || pid!=held.pid || !MonsterBossProbeReadV1(held.process,held.unit,0x30,unit)
        || NumGet(unit,0,"UInt")!=1 || NumGet(unit,12,"UInt")!=held.uid
        || NumGet(unit,16,"UInt")=0 || NumGet(unit,16,"UInt")=12
        || !MonsterBossProbeReadV1(held.process,NumGet(unit,0x2C,"UInt"),0x20,path))
        return false
    playerPath := D2ReadU32(held.process,held.player+0x2C)
    view := AutoMonsterAttackViewV1(held.process,held.base,hwnd,playerPath)
    point := IsObject(view) ? AutoMonsterAttackPointV1(path,view) : false
    if (!IsObject(point))
        return false
    VarSetCapacity(xy,8,0)
    NumPut(NumGet(path,2,"UShort"),xy,0,"UInt")
    NumPut(NumGet(path,6,"UShort"),xy,4,"UInt")
    if (!DllCall("WriteProcessMemory","Ptr",held.process,"Ptr",held.remote+140,"Ptr",&xy,"UPtr",8,"UPtrP",written) || written!=8)
        return false
    lp := ((Round(point.y)&65535)<<16)|(Round(point.x)&65535)
    aimed := GameTargetMessageV63(hwnd,0x200,2,lp)
    if (aimed && MonsterBossProbeReadV1(held.process,playerPath,0x20,pp))
        AttackInfoRememberV550(pid,NumGet(unit,4,"UInt"),held.uid,NumGet(path,2,"UShort"),NumGet(path,6,"UShort")
            ,NumGet(pp,2,"UShort"),NumGet(pp,6,"UShort"))
    return aimed
}


FarmAttackRowFiveV18()
{
    global FKey1,FKey2,FKey3,FKey4,FKey5
    Loop, 5
    {
        row := A_Index
        if (!QuickBuffHasKey(FKey%row%))
            return false
    }
    return true
}


Form6ModeChangedV716:
Form6ReleaseV716()
GuiControlGet, form6HoldSelectedV716, 1:, Form6HoldV716
form6ModeV716 := form6HoldSelectedV716 ? 2 : 1
Form6RefreshV716()
return

Form6InputChangedV716:
Form6ReadV716()
return

Form6ReadV716()
{
    global form6KeyV716,form6CountV716
    if (ProfileControlExistsV365("Form6KeyInputV716"))
    {
        GuiControlGet, value, 1:, Form6KeyInputV716
        value := NormalizeOptionalKey(value)
        if (value="" || GetKeyVK(value) || GetKeySC(value))
            form6KeyV716 := value
    }
    if (ProfileControlExistsV365("Form6CountInputV716"))
    {
        GuiControlGet, value, 1:, Form6CountInputV716
        if (RegExMatch(value,"^\d+$") && value>=1 && value<=2048)
            form6CountV716 := value+0
    }
}

Form6RefreshV716()
{
    global form6KeyV716,form6CountV716,form6ModeV716
    GuiControl, 1:, Form6KeyInputV716, % MouseKeyDisplayV616(form6KeyV716)
    GuiControl, 1:, Form6CountInputV716, %form6CountV716%
    GuiControl, 1:, Form6ClickV716, % form6ModeV716=1 ? 1 : 0
    GuiControl, 1:, Form6HoldV716, % form6ModeV716=2 ? 1 : 0
}

Form6SaveV716(section)
{
    global form6KeyV716,form6CountV716,form6ModeV716
    Form6ReadV716()
    try IniWrite, %form6KeyV716%, % ProfileConfigPathV364(section), %section%, Form6AttackKey
    try IniWrite, %form6CountV716%, % ProfileConfigPathV364(section), %section%, Form6TargetCount
    try IniWrite, %form6ModeV716%, % ProfileConfigPathV364(section), %section%, Form6AttackMode
}

Form6LoadV716(section)
{
    global form6KeyV716,form6CountV716,form6ModeV716
    Form6ReleaseV716()
    IniRead, form6KeyV716, % ProfileConfigPathV364(section), %section%, Form6AttackKey,%A_Space%
    IniRead, form6CountV716, % ProfileConfigPathV364(section), %section%, Form6TargetCount, 4
    IniRead, form6ModeV716, % ProfileConfigPathV364(section), %section%, Form6AttackMode, 1
    form6KeyV716 := NormalizeOptionalKey(form6KeyV716)
    if (form6KeyV716!="" && !GetKeyVK(form6KeyV716) && !GetKeySC(form6KeyV716))
        form6KeyV716 := ""
    if (!RegExMatch(form6CountV716,"^\d+$") || form6CountV716<1 || form6CountV716>2048)
        form6CountV716 := 4
    if (form6ModeV716!=2)
        form6ModeV716 := 1
    Form6RefreshV716()
}

Form6ReleaseV716()
{
    global farmAttackHoldV15
    held := farmAttackHoldV15
    if (!IsObject(held) || !held.form6V716)
        return true
    held.releaseV15 := true
    if (held.downV716 && BackgroundBirthV63(held.pid)=held.birth && DllCall("IsWindow","Ptr",held.hwnd))
    {
        WinGet, originalPidV716, PID, % "ahk_id " . held.hwnd
        if (originalPidV716=held.pid && !DllCall("PostMessage","Ptr",held.hwnd,"UInt",0x205,"UPtr",0,"Ptr",held.lp))
            return false
    }
    DllCall("CloseHandle","Ptr",held.process)
    farmAttackHoldV15 := false
    return true
}

Form6KeepV716(held)
{
    global autoMonsterAttackOn,form6ModeV716,farmRunEpochV535
    return autoMonsterAttackOn && form6ModeV716=2 && !held.releaseV15 && !held.doneV716
        && Stage2FightEnabledV9() && held.epoch=farmRunEpochV535
        && D2GetActiveGamePidV95()=held.pid && BackgroundBirthV63(held.pid)=held.birth
        && A_TickCount-held.lastAimV716<750
}

Form6PointV716(held,target)
{
    if (!MonsterBossProbeReadV1(held.process,target.unit,0x30,ub)
        || NumGet(ub,0,"UInt")!=1 || NumGet(ub,12,"UInt")!=target.uid
        || NumGet(ub,16,"UInt")=0 || NumGet(ub,16,"UInt")=12
        || MonsterClassExcludedV11(NumGet(ub,4,"UInt"),held.process,target.unit)
        || !MonsterBossProbeReadV1(held.process,NumGet(ub,0x2C,"UInt"),0x20,path))
    {
        AutoMonsterAttackLogV2("COMBAT_FORM6_BLOCK reason=TARGET_INVALID uid=" . target.uid)
        return false
    }
    player := D2ReadU32(held.process,held.base+0x11BBFC)
    playerPath := player ? D2ReadU32(held.process,player+0x2C) : 0
    if (!playerPath || !MonsterBossProbeReadV1(held.process,playerPath,0x20,pb))
    {
        AutoMonsterAttackLogV2("COMBAT_FORM6_BLOCK reason=PLAYER_PATH_INVALID uid=" . target.uid)
        return false
    }
    if (CoordLevelV14(held.process,NumGet(path,0x1C,"UInt"))!=CoordLevelV14(held.process,NumGet(pb,0x1C,"UInt")))
    {
        AutoMonsterAttackLogV2("COMBAT_FORM6_BLOCK reason=TARGET_LEVEL_MISMATCH uid=" . target.uid)
        return false
    }
    if (!FarmFixedAttackValidV626(held.process,player,target.unit,target.uid,held.pid))
    {
        AutoMonsterAttackLogV2("COMBAT_FORM6_BLOCK reason=FIXED_CENTER_REJECT uid=" . target.uid)
        return false
    }
    if (!ScosAttackRadiusValidV239(held.process,player,target.unit,target.uid))
    {
        AutoMonsterAttackLogV2("COMBAT_FORM6_BLOCK reason=RADIUS_REJECT uid=" . target.uid)
        return false
    }
    if (BOCommonActiveV444(held.pid) && !BOAttackInRadiusV488(held.process,player,target.unit,held.pid))
    {
        AutoMonsterAttackLogV2("COMBAT_FORM6_BLOCK reason=BO_RADIUS_REJECT uid=" . target.uid)
        return false
    }
    view := AutoMonsterAttackViewV1(held.process,held.base,held.hwnd,playerPath)
    pointVTrace := IsObject(view) ? AutoMonsterAttackPointV1(path,view) : false
    if (!IsObject(pointVTrace))
        AutoMonsterAttackLogV2("COMBAT_FORM6_BLOCK reason=SCREEN_PROJECTION uid=" . target.uid)
    return pointVTrace
}

Form6AimNextV716(held)
{
    global farmCenterCycleV741
    if (IsObject(farmCenterCycleV741) && farmCenterCycleV741.pid=held.pid && farmCenterCycleV741.phase!="ATTACK")
    {
        AutoMonsterAttackLogV2("COMBAT_FORM6_BLOCK reason=AIM_CENTER_PHASE uid=" . held.uid . " phase=" . farmCenterCycleV741.phase)
        return false
    }
    if (held.releaseV15 || held.doneV716 || !NativeDispatchReadyV10(true)
        || D2GetActiveGamePidV95()!=held.pid || BackgroundBirthV63(held.pid)!=held.birth)
    {
        AutoMonsterAttackLogV2("COMBAT_FORM6_BLOCK reason=AIM_GUARD uid=" . held.uid . " release=" . held.releaseV15 . " done=" . held.doneV716 . " next=" . held.nextV716)
        return false
    }
    while (held.nextV716<=held.rowsV716.Length())
    {
        target := held.rowsV716[held.nextV716]
        point := Form6PointV716(held,target)
        if (!IsObject(point))
        {
            AutoMonsterAttackLogV2("COMBAT_FORM6_BLOCK reason=POINT_REJECT uid=" . target.uid . " next=" . held.nextV716)
            held.nextV716++
            continue
        }
        held.lp := ((Round(point.y)&65535)<<16)|(Round(point.x)&65535)
        if (!GameTargetMessageV63(held.hwnd,0x200,held.downV716 ? 2 : 0,held.lp))
        {
            AutoMonsterAttackLogV2("COMBAT_FORM6_BLOCK reason=MOUSE_MOVE_MESSAGE uid=" . target.uid)
            return false
        }
        if (!held.downV716)
        {
            held.downV716 := true
            if (!GameTargetMessageV63(held.hwnd,0x204,2,held.lp))
            {
                Form6ReleaseV716()
                AutoMonsterAttackLogV2("COMBAT_FORM6_BLOCK reason=RIGHT_DOWN_MESSAGE uid=" . target.uid)
                return false
            }
        }
        held.unit := target.unit,held.uid := target.uid,held.lastAimV716 := A_TickCount
        held.nextV716++,held.doneV716 := held.nextV716>held.rowsV716.Length()
        return true
    }
    held.doneV716 := true
    AutoMonsterAttackLogV2("COMBAT_FORM6_BLOCK reason=NO_VALID_TARGETS uid=" . held.uid)
    Form6ReleaseV716()
    return false
}

Form6AttackV716(pid,unit,uid)
{
    ; V20261029: one live Farm attack dispatch. Avoid the separate held-mouse
    ; screen-projection route, which can reject a valid unit with queued=0.
    ; The Form6 mode selector stays for profile compatibility; automatic Farm
    ; always sends a native right-click on the selected live unit.
    global farmAttackHoldV15,form6KeyV716,form6ModeV716
    if (IsObject(farmAttackHoldV15))
        FarmAttackHoldReleaseV15()
    if (QuickBuffHasKey(form6KeyV716))
    {
        if (!QuickBuffSend(form6KeyV716))
        {
            AutoMonsterAttackLogV2("COMBAT_SEND_BLOCK reason=SKILL_KEY_NOT_SENT uid=" . uid . " key=" . form6KeyV716)
            return false
        }
    }
    else if (!LastAttackSkillV20())
    {
        AutoMonsterAttackLogV2("COMBAT_SEND_BLOCK reason=LAST_SKILL_NOT_SENT uid=" . uid)
        return false
    }
    ; The skill key is posted asynchronously. Let the game thread process it
    ; before NativeRightSkillValidV9 reads the selected right-hand skill.
    Sleep, 90
    if (!NativeDispatchReadyV10(true) || D2GetActiveGamePidV95()!=pid)
    {
        AutoMonsterAttackLogV2("COMBAT_SEND_BLOCK reason=NOT_READY_AFTER_SKILL uid=" . uid)
        return false
    }
    sentV20261029 := NativeMapTestV5(true,{pid:pid,unit:unit,uid:uid})
    if (!sentV20261029)
        AutoMonsterAttackLogV2("COMBAT_SEND_BLOCK reason=NATIVE_UNIT_SEND_FAILED uid=" . uid . " mode=" . form6ModeV716)
    return FarmCombatSendResultV624(pid,unit,uid,sentV20261029)
}

InventoryArrangeButtonV576:
if (sigBusyV147 && sigActiveModeV182="ARRANGE")
{
    sigCancelV147 := true
    return
}
InventoryArrangeRunV576()
return

InventoryArrangeFitsV576(slots,uid,x,y,w,h,width:=15,height:=10)
{
    if (x<0 || y<0 || x+w>width || y+h>height)
        return false
    for id,a in slots
        if (id!=uid && x<a.x+a.w && x+w>a.x && y<a.y+a.h && y+h>a.y)
            return false
    return true
}

InventoryArrangeFreeV576(slots,item,rightUp:=true)
{
    Loop, % 15-item.w+1
    {
        x := rightUp ? 15-item.w-(A_Index-1) : A_Index-1
        Loop, % 10-item.h+1
        {
            y := rightUp ? 10-item.h-(A_Index-1) : A_Index-1
            if (InventoryArrangeFitsV576(slots,item.uid,x,y,item.w,item.h))
                return {x:x,y:y,w:item.w,h:item.h}
        }
    }
    return false
}

InventoryArrangeBeforeV576(a,b)
{
    if (a.group!=b.group)
        return a.group<b.group
    if (a.group=1 && a.level!=b.level)
        return a.level<b.level
    if (a.group=2 && a.orderV581!=b.orderV581)
        return a.orderV581<b.orderV581
    if (a.group!=1 && a.w*a.h!=b.w*b.h)
        return a.w*a.h>b.w*b.h
    if (a.cls!=b.cls)
        return a.cls<b.cls
    return a.uid<b.uid
}

InventoryArrangeBufferV579(ByRef current,targets,ByRef moves)
{
    Loop, 14
    {
        bx := A_Index-1
        Loop, 9
        {
            by := A_Index-1
            if (!InventoryArrangeFitsV576(targets,-579,bx,by,2,2))
                continue
            buffer := {x:bx,y:by,w:2,h:2},trial := current.Clone(),clearing := [],possible := true
            for uid,a in current
            {
                if (!(bx<a.x+a.w && bx+2>a.x && by<a.y+a.h && by+2>a.y))
                    continue
                blocked := trial.Clone(),blocked[-579] := buffer
                temp := InventoryArrangeFreeV576(blocked,{uid:uid,w:a.w,h:a.h},false)
                if (!IsObject(temp))
                {
                    possible := false
                    break
                }
                clearing.Push({uid:uid,x:temp.x,y:temp.y}),trial[uid] := temp
            }
            if (!possible)
                continue
            current := trial
            for _,move in clearing
                moves.Push(move)
            SigLogV147("ARRANGE_BUFFER x=" . bx . " y=" . by . " size=2x2 clearing_moves=" . clearing.Length())
            return buffer
        }
    }
    throw Exception("Sắp xếp: chưa dọn được vùng trống 4 ô (2x2); chưa di chuyển đồ")
}

InventoryArrangeBufferSlotV579(current,item,buffer)
{
    if (item.w>2 || item.h>2)
        return false
    Loop, % 3-item.w
    {
        x := buffer.x+A_Index-1
        Loop, % 3-item.h
        {
            y := buffer.y+A_Index-1
            if (InventoryArrangeFitsV576(current,item.uid,x,y,item.w,item.h))
                return {x:x,y:y,w:item.w,h:item.h}
        }
    }
    return false
}

InventoryArrangePlanV576(items)
{
    targets := {},current := {},moves := [],charmColumnV578 := 14,charmBottomV578 := 10
    for _,a in items
    {
        current[a.uid] := {x:a.x,y:a.y,w:a.w,h:a.h}
        if (!InventoryArrangeFitsV576(targets,a.uid,a.x,a.y,a.w,a.h))
        {
            if (a.x<0 || a.y<0 || a.x+a.w>15 || a.y+a.h>10)
                throw Exception("Sắp xếp: vật nằm ngoài lưới 15 x 10 trong ảnh")
        }
        if (a.group=0)
        {
            if (!InventoryArrangeFitsV576(targets,a.uid,0,0,a.w,a.h))
                throw Exception("Sắp xếp: có nhiều Cube hoặc ô Cube bị trùng")
            targets[a.uid] := {x:0,y:0,w:a.w,h:a.h}
        }
        else
        {
            target := false
            if (a.group=1)
            {
                while (charmColumnV578>=0 && !IsObject(target))
                {
                    yyV578 := charmBottomV578-a.h
                    while (yyV578>=0)
                    {
                        if (InventoryArrangeFitsV576(targets,a.uid,charmColumnV578,yyV578,a.w,a.h))
                        {
                            target := {x:charmColumnV578,y:yyV578,w:a.w,h:a.h}
                            charmBottomV578 := yyV578
                            break
                        }
                        yyV578--
                    }
                    if (!IsObject(target))
                        charmColumnV578--,charmBottomV578 := 10
                }
            }
            else
                target := InventoryArrangeFreeV576(targets,a)
            if (!IsObject(target))
                throw Exception("Sắp xếp: bố cục không đủ ô cho CLASS " . a.cls)
            targets[a.uid] := target
        }
    }
    needsMove := false
    for uid,a in current
        if (a.x!=targets[uid].x || a.y!=targets[uid].y)
            needsMove := true
    if (!needsMove)
        return {targets:targets,moves:moves}
    bufferV579 := InventoryArrangeBufferV579(current,targets,moves),firstV579 := false
    for _,a in items
    {
        now := current[a.uid],dst := targets[a.uid]
        if (a.group!=1 || a.w*a.h>2 || (now.x=dst.x && now.y=dst.y))
            continue
        if (!IsObject(firstV579) || now.x>current[firstV579.uid].x
            || (now.x=current[firstV579.uid].x && now.y+now.h>current[firstV579.uid].y+current[firstV579.uid].h))
            firstV579 := a
    }
    if (IsObject(firstV579))
    {
        temp := InventoryArrangeBufferSlotV579(current,firstV579,bufferV579)
        if (!IsObject(temp))
            throw Exception("Sắp xếp: 4 ô tạm chưa trống cho charm đầu tiên")
        moves.Push({uid:firstV579.uid,x:temp.x,y:temp.y}),current[firstV579.uid] := temp
    }
    buffered := {},limit := items.Length()*6+200
    Loop, %limit%
    {
        remaining := 0,progress := false
        for _,a in items
        {
            now := current[a.uid],dst := targets[a.uid]
            if (now.x=dst.x && now.y=dst.y)
                continue
            remaining++
            if (InventoryArrangeFitsV576(current,a.uid,dst.x,dst.y,a.w,a.h))
            {
                moves.Push({uid:a.uid,x:dst.x,y:dst.y})
                current[a.uid] := dst.Clone(),progress := true
            }
        }
        if (!remaining)
            return {targets:targets,moves:moves}
        if (progress)
        {
            buffered := {}
            continue
        }
        moved := false
        for _,a in items
        {
            now := current[a.uid],dst := targets[a.uid]
            if ((now.x=dst.x && now.y=dst.y) || buffered.HasKey(a.uid))
                continue
            occupied := current.Clone(),occupied.Delete(a.uid)
            occupied[a.uid] := now
            probe := {uid:-1,w:a.w,h:a.h}
            temp := InventoryArrangeBufferSlotV579(occupied,probe,bufferV579)
            if (!IsObject(temp))
            {
                occupied[-579] := bufferV579
                temp := InventoryArrangeFreeV576(occupied,probe,false)
            }
            if (!IsObject(temp))
                continue
            moves.Push({uid:a.uid,x:temp.x,y:temp.y})
            current[a.uid] := temp,buffered[a.uid] := true,moved := true
            break
        }
        if (!moved)
            throw Exception("Sắp xếp: thiếu ô trống tạm để đổi chỗ; chưa di chuyển đồ")
    }
    throw Exception("Sắp xếp: chưa tính được thứ tự đổi chỗ; chưa di chuyển đồ")
}

InventoryArrangeRunV576()
{
    global sigBusyV147,sigCancelV147,sigActiveModeV182,sigBackgroundV179,sigSendingKeyV147
    global pickupImageOn,pickupTimerBusy,xRunning,zRunning,buffSequenceRunningV555,pickupRoundResetV1
    if (sigBusyV147 || pickupTimerBusy || xRunning || zRunning || buffSequenceRunningV555)
    {
        ToolTipInfoV386("Sắp xếp: chờ thao tác buff/nhặt hiện tại xong rồi bấm lại")
        SetTimer, RemoveToolTip, -3000
        return false
    }
    if (!SigBackgroundBindV179())
        return false
    oldBg := sigBackgroundV179,oldPickup := pickupImageOn
    sigBackgroundV179 := true
    if (!GameItemActionBeginV4("Cube","cube",true))
    {
        sigBackgroundV179 := oldBg
        return false
    }
    sigBusyV147 := true,sigCancelV147 := false,sigActiveModeV182 := "ARRANGE"
    PickupEnabledSetV71(false,true,false)
    GuiControl, 1:, InventoryArrangeButtonV576, Dừng Xếp
    ctx := false,success := false,restoreSlot := false,message := "",stepV577 := "OPEN_CONTEXT",readUidV577 := 0,readClassV577 := -1
    try
    {
        ctx := SigOpenContextV149()
        FonInfoPushV385("Sắp xếp: Sort item to cont")
        stepV577 := "SORT_TO_CONTAINER"
        SigSortContainerV191(ctx)
        stepV577 := "SNAPSHOT"
        items := [],before := SigSnapshotV147(ctx)
        orderV581 := {"1920|7":1,"1734|2":2,"1735|2":3,"1736|2":4,"2168|2":5,"2149|2":6,"1733|2":7,"2346|2":8}
        SigLogV147("ARRANGE_SNAPSHOT total=" . before.Count() . " inventory=" . V92Hex(ctx.inv))
        for uid,a in before
        {
            if (a.loc!=0 || a.owner!=ctx.inv || D2ReadU32(ctx.h,a.unit+0x10)!=0)
                continue
            readUidV577 := uid,readClassV577 := a.cls,stepV577 := "ITEM_SIZE"
            size := TicketItemSizeV277(ctx,a.cls)
            a.w := size.w,a.h := size.h,a.group := 4,a.level := 0
            if (a.cls=1204)
                a.group := 0
            else if (orderV581.HasKey(a.cls . "|" . a.q))
                a.group := 2,a.orderV581 := orderV581[a.cls . "|" . a.q]
            else
            {
                if (PickupIsCharmV571(ctx.h,a.cls))
                {
                    stepV577 := "CHARM_LEVEL"
                    a.group := 1,text := HopTextV557(ctx,a,false)
                    if (RegExMatch(text,"im)\bRequired\s+Level\s*:?\s*(\d+)",m))
                        a.level := m1+0
                }
            }
            inserted := false
            for index,b in items
                if (InventoryArrangeBeforeV576(a,b))
                {
                    items.InsertAt(index,a),inserted := true
                    break
                }
            if (!inserted)
                items.Push(a)
            if (Mod(items.Length(),8)=0)
                FonInfoPushV385("Sắp xếp: đọc " . items.Length() . " vật phẩm")
        }
        if (!items.Length())
            SigFailV147("Sắp xếp: không thấy đồ trong rương ngoài")
        stepV577 := "PLAN_LAYOUT"
        SigLogV147("ARRANGE_ITEMS count=" . items.Length() . " cube_target=0,0 grid=15x10")
        plan := InventoryArrangePlanV576(items),expected := {}
        SigLogV147("ARRANGE_PLAN moves=" . plan.moves.Length())
        for _,a in items
            expected[a.uid] := {cls:a.cls,x:a.x,y:a.y,w:a.w,h:a.h}
        for index,move in plan.moves
        {
            stepV577 := "VERIFY_BEFORE_MOVE",readUidV577 := move.uid
            SigCheckV147(ctx)
            all := SigSnapshotV147(ctx)
            for uid,a in all
                if (a.loc=0 && a.owner=ctx.inv && !expected.HasKey(uid))
                    SigFailV147("Sắp xếp: có vật mới trong rương; dừng để tính lại bố cục")
            for uid,a in expected
            {
                live := all[uid]
                if (!IsObject(live) || live.cls!=a.cls || live.loc!=0 || live.owner!=ctx.inv || live.x!=a.x || live.y!=a.y)
                    SigFailV147("Sắp xếp: đồ thay đổi trong lúc chạy; dừng kiểm tra UID " . uid)
            }
            item := all[move.uid],restoreSlot := expected[move.uid].Clone(),restoreSlot.uid := move.uid
            stepV577 := "MOVE_ITEM",readClassV577 := item.cls
            SigLogV147("ARRANGE_MOVE uid=" . move.uid . " class=" . item.cls . " from=" . restoreSlot.x . "," . restoreSlot.y . " to=" . move.x . "," . move.y)
            Ticket130HomeV265(ctx,item,move)
            expected[move.uid].x := move.x,expected[move.uid].y := move.y,restoreSlot := false
            if (Mod(index,5)=0)
                FonInfoPushV385("Sắp xếp: " . index . "/" . plan.moves.Length())
        }
        stepV577 := "VERIFY_FINAL"
        all := SigSnapshotV147(ctx)
        for uid,dst in plan.targets
            if (!IsObject(all[uid]) || all[uid].loc!=0 || all[uid].owner!=ctx.inv || all[uid].x!=dst.x || all[uid].y!=dst.y)
                SigFailV147("Sắp xếp: chưa xác nhận đúng ô UID " . uid)
        SigLogV147("ARRANGE_DONE items=" . items.Length() . " cube_target=0,0 verified=1")
        success := true,message := "Sắp xếp xong: Cube → Charm theo level → các vật theo thứ tự đã chỉ định → đồ khác"
    }
    catch e
    {
        message := e.Message
        SigLogV147("ARRANGE_ERROR step=" . stepV577 . " uid=" . readUidV577 . " class=" . readClassV577 . " reason=" . e.Message . " what=" . e.What . " line=" . e.Line)
        FonInfoPushV385("Sắp xếp dừng ở " . stepV577 . ": " . e.Message)
        if (IsObject(ctx) && IsObject(restoreSlot) && !sigCancelV147)
        {
            try
            {
                cursor := PickupCursorV4(ctx.h,ctx.inv)
                if (IsObject(cursor) && cursor.uid=restoreSlot.uid)
                    Ticket130HomeV265(ctx,cursor,restoreSlot)
            }
            catch restoreError
                message .= " — kiểm tra vật trên chuột UID " . restoreSlot.uid
        }
    }
    finally
    {
        canRestore := !sigCancelV147
        if (IsObject(ctx))
        {
            cursor := PickupCursorV4(ctx.h,ctx.inv)
            canRestore := canRestore && IsObject(cursor) && !cursor.unit
            DllCall("CloseHandle","Ptr",ctx.h)
        }
        sigBusyV147 := false,sigSendingKeyV147 := false,sigActiveModeV182 := ""
        sigBackgroundV179 := oldBg,pickupRoundResetV1 := true
        GameItemActionEndV4("Cube")
        if (canRestore)
            PickupEnabledSetV71(oldPickup,true,false)
        GuiControl, 1:, InventoryArrangeButtonV576, Dừng Sắp
    }
    ToolTipInfoV386(message)
    SetTimer, RemoveToolTip, -6000
    return success
}
TransferStashButtonV630:
if (sigActiveModeV182="TRANSFER")
{
    sigCancelV147 := true
    return
}
if (sigBusyV147)
{
    ToolTipInfoV386("Chuyển Kho: đang có thao tác đồ khác.")
    return
}
TransferStashRunV631()
return

TransferStashRunV631()
{
    global sigBusyV147,sigCancelV147,sigActiveModeV182,sigBackgroundV179,sigSendingKeyV147
    global pickupTimerBusy,pickupRoundResetV1
    if (!SigBackgroundBindV179() || !IsGameActive())
        return false
    if (pickupTimerBusy || !AutoMonsterPacketCleanupV1() || !GameItemActionBeginV4("Cube","cube",true))
    {
        ToolTipInfoV386("Chuyển Kho: chờ thao tác đồ hiện tại xong rồi thử lại.")
        return false
    }
    oldBg := sigBackgroundV179,oldSending := sigSendingKeyV147
    ctx := false,success := false,message := "",held := false
    sigBusyV147 := true,sigCancelV147 := false,sigActiveModeV182 := "TRANSFER",sigBackgroundV179 := true
    GuiControl, 1:, TransferStashButtonV630, Dừng Chuyển
    try
    {
        ctx := SigOpenContextV149(),ctx.transferStashV631 := true
        path := D2ReadU32(ctx.h,ctx.player+0x2C)
        if (!path || !MonsterBossProbeReadV1(ctx.h,path,0x20,pb))
            throw Exception("Chưa đọc được vị trí nhân vật để tìm kho.")
        stash := CycObjectV42(ctx.h,pb,267)
        if (!IsObject(stash))
            throw Exception("Chưa quét thấy kho để chuyển.")
        if ((stash.x-NumGet(pb,2,"UShort"))**2+(stash.y-NumGet(pb,6,"UShort"))**2>400)
            throw Exception("Cần đứng gần kho để chuyển.")
        r := {storeDoneV628:false,storeSourcesV629:{},pid:ctx.pid}
        if (!TownStoreRunV628(r,ctx,ctx.player))
            throw Exception("Chưa chạy xong chuyển kho.")
        success := true
        message := "Đã kiểm tra/cất tiền và chuyển " . (r.storeMovedV631+0) . " món theo danh sách."
    }
    catch e
        message := "Lỗi chuyển kho: " . e.Message
    finally
    {
        if (IsObject(ctx))
        {
            cursor := PickupCursorV4(ctx.h,ctx.inv)
            held := !IsObject(cursor) || cursor.unit
            DllCall("CloseHandle","Ptr",ctx.h)
        }
        sigBusyV147 := false,sigCancelV147 := false,sigActiveModeV182 := ""
        sigBackgroundV179 := oldBg,sigSendingKeyV147 := oldSending,pickupRoundResetV1 := true
        GameItemActionEndV4("Cube")
        if (held)
            PickupEnabledSetV71(false,true,false)
        GuiControl, 1:, TransferStashButtonV630, Chuyển Khố
    }
    ToolTipInfoV386(message)
    return success
}
TownStoreKeyV631(ctx,spec)
{
    global sigSendingKeyV147,sigTownSendingV148
    SigCheckV147(ctx)
    oldSending := sigSendingKeyV147,oldTownSending := sigTownSendingV148
    sigSendingKeyV147 := true,sigTownSendingV148 := true
    try
        return GameTargetKeyV63(spec)
    finally
        sigSendingKeyV147 := oldSending,sigTownSendingV148 := oldTownSending
}

TownStoreNativeWaitV631(ctx)
{
    started := A_TickCount
    while (!AutoMonsterPacketCleanupV1())
    {
        SigCheckV147(ctx)
        if (A_TickCount-started>4000)
            throw Exception("Chuyển Kho: lệnh mở thủ khố chưa hoàn tất.")
        Sleep, 25
    }
}

FarmCrashWatchTimerV631:
if (farmUserPausedV2026)
    return
FarmCrashWatchTickV631()
return

FarmCrashWatchTickV631()
{
    return
}


TownStoreLiveStoredV635(ctx,item)
{
    SigCheckV147(ctx)
    cursor := PickupCursorV4(ctx.h,ctx.inv)
    if (!IsObject(cursor) || cursor.unit)
        return false
    all := SigSnapshotV147(ctx),live := all[item.uid]
    if (!IsObject(live))
        live := SigLiveItemV148(ctx,item.uid,item.unit)
    return IsObject(live) && live.uid=item.uid && live.cls=item.cls && live.q=item.q
        && live.loc=4 && D2ReadU32(ctx.h,live.unit+0x10)=0
}

TownStoreUiReadV676(ctx)
{
    SigCheckV147(ctx)
    base := D2GetModuleBaseV35(ctx.pid,"D2Client.dll")
    if (!base || !RecoveryMenuModuleV528(ctx.h,base,0x4B95CA3E,0x135000)
        || !MonsterBossProbeReadV1(ctx.h,base+0xBE424,8,code))
        throw Exception("Chuyển Kho: chưa đọc được hàm trạng thái UI; chưa xác nhận đóng kho")
    if (NumGet(code,0,"UChar")!=0x8B || NumGet(code,1,"UChar")!=0x04
        || NumGet(code,2,"UChar")!=0x85 || NumGet(code,7,"UChar")!=0xC3)
        throw Exception("Chuyển Kho: hàm trạng thái UI khác bản hỗ trợ; chưa xác nhận đóng kho")
    table := NumGet(code,3,"UInt")
    if (table<base || table+0x98>base+0x135000
        || !MonsterBossProbeReadV1(ctx.h,table,0x98,flags))
        throw Exception("Chuyển Kho: không đọc được trạng thái kho/Cube")
    stash := NumGet(flags,0x19*4,"UInt"),cube := NumGet(flags,0x1A*4,"UInt")
    menu := NumGet(flags,0x09*4,"UInt")
    if (stash>1 || cube>1 || menu>1)
        throw Exception("Chuyển Kho: trạng thái UI không hợp lệ; chưa xác nhận đóng kho")
    return {stash:stash,cube:cube,menu:menu}
}

TownStoreCloseBatchV636(r,ctx)
{
    global sigCubeUiOpenV159,cubeTransferDelayMs
    r.storeUiClosedV633 := false
    started := A_TickCount,lastSend := 0,stable := 0,sends := 0
    Loop
    {
        ui := TownStoreUiReadV676(ctx)
        if (ui.menu)
            throw Exception("Chuyển Kho: menu game đang mở; chưa cho chạy bước tiếp theo")
        if (!ui.stash && !ui.cube)
        {
            stable++
            if (stable>=2)
            {
                ctx.townStoreStashOpenV631 := false,sigCubeUiOpenV159 := false
                r.storeUiClosedV633 := true
                SigLogV147("TOWN_STORE_UI_CLOSED verified=LIVE_UI stash=0 cube=0 menu=0 esc_count=" . sends)
                return true
            }
        }
        else
        {
            stable := 0
            if (sends<3 && (!lastSend || A_TickCount-lastSend>=1000))
            {
                cursor := PickupCursorV4(ctx.h,ctx.inv)
                if (!IsObject(cursor) || cursor.unit)
                    throw Exception("Chuyển Kho: chuột chưa trống; chưa gửi lệnh đóng kho")
                if (!TownStoreKeyV631(ctx,"{Esc}"))
                    throw Exception("Chuyển Kho: chưa gửi được lệnh đóng kho/Cube")
                sends++,lastSend := A_TickCount
                SigLogV147("TOWN_STORE_UI_CLOSE_SENT stash=" . ui.stash . " cube=" . ui.cube . " attempt=" . sends . " next=VERIFY_LIVE_UI")
            }
        }
        if (A_TickCount-started>=4000)
            throw Exception("Chuyển Kho: kho/Cube chưa đóng; chưa cho di chuyển hoặc mở cổng")
        Sleep, % Max(50,Min(200,cubeTransferDelayMs))
    }
}

TownStoreMoneyV636(ctx)
{
    global sigCancelV147
    before := ScosGoldReadV229(ctx.h,ctx.player)
    if (!IsObject(before))
        throw Exception("Chuyển Kho: chưa đọc được tiền, chưa gửi lệnh cất")
    amount := Min(before.gold,Max(0,before.limit-before.bank))
    if (amount<=0)
    {
        SigLogV147("TOWN_STORE_GOLD_SKIP wallet=" . before.gold . " bank=" . before.bank . " limit=" . before.limit)
        return true
    }
    bytes := ScosGoldPacketV231(amount)
    SigPacketV147(ctx,bytes)
    started := A_TickCount
    Loop
    {
        SigCheckV147(ctx)
        if (sigCancelV147)
            throw Exception("Đã dừng cất tiền")
        now := ScosGoldReadV229(ctx.h,ctx.player)
        if (IsObject(now) && before.gold-now.gold=amount && now.bank-before.bank=amount)
        {
            SigLogV147("TOWN_STORE_GOLD_CONFIRMED amount=" . amount . " wallet=" . now.gold . " bank=" . now.bank)
            return true
        }
        if (A_TickCount-started>4000)
            throw Exception("Chuyển Kho: chưa xác nhận tiền vào kho; không gửi lặp")
        Sleep, 100
    }
}


PickupCatalogArrangeV638()
{
    global pickupCatalogNamesV11
    groups := [],others := [],node := TV_GetChild(0)
    while (node)
    {
        row := PickupCatalogCopyV638(node)
        if (row.name="Angelic")
        {
        }
        else if (row.children.Length() || RegExMatch(row.name,"i)^(?:Rune|Gem|Shrine|Oil|Unique|Charm|Material|Signet|Cycle|Arcane|Corrupted)$"))
            groups.Push(row)
        else
            others.Push(row)
        node := TV_GetNext(node)
    }
    groups := PickupCatalogRowsSortV638(groups),others := PickupCatalogRowsSortV638(others)
    TV_Delete(),pickupCatalogNamesV11 := {}
    for _,row in groups
        PickupCatalogRestoreV638(row)
    if (others.Length())
    {
        otherRoot := PickupCatalogNodeV11("Khác",0,false)
        for _,row in others
            PickupCatalogRestoreV638(row,otherRoot)
    }
}

PickupCatalogCopyV638(node)
{
    global pickupCatalogNamesV11
    row := {name:pickupCatalogNamesV11[node],children:[]},child := TV_GetChild(node)
    while (child)
    {
        row.children.Push(PickupCatalogCopyV638(child))
        child := TV_GetNext(child)
    }
    return row
}

PickupCatalogRestoreV638(row,parent:=0)
{
    node := PickupCatalogNodeV11(row.name,parent,false)
    for _,child in row.children
        PickupCatalogRestoreV638(child,node)
    TV_Modify(node,"Sort -Expand")
    return node
}


PickupCatalogRowsSortV638(rows)
{
    order := "",result := []
    for index,row in rows
        order .= row.name . "`t" . index . "`n"
    Sort, order
    Loop, Parse, order, `n, `r
        if (RegExMatch(A_LoopField,"`t(\d+)$",m))
            result.Push(rows[m1+0])
    return result
}

TownStoreGroundStageV639(ctx,item)
{
    SigCheckV147(ctx)
    if (item.cls=1204)
        throw Exception("Chuyển Kho: giữ Cube để luồng nhặt thường lấy lại")
    ground := SigGroundV147(ctx),live := ground[item.uid]
    if (!IsObject(live) || live.cls!=item.cls || live.q!=item.q
        || D2ReadU32(ctx.h,live.data+0x14)!=item.storeSeedV629)
        throw Exception("Chuyển Kho: vật dưới đất đã đổi, chưa nhặt")
    TownStoreInventorySlotV629(ctx,item)
    cursor := PickupCursorV4(ctx.h,ctx.inv)
    if (!IsObject(cursor) || cursor.unit)
        throw Exception("Chuyển Kho: chuột chưa trống trước khi nhặt")
    bytes := [0x16],SigDwordV147(bytes,4),SigDwordV147(bytes,item.uid),SigDwordV147(bytes,0)
    SigLogV147("TOWN_STORE_GROUND_PICK uid=" . item.uid . " class=" . item.cls . " packet=16/4/uid/0")
    SigPacketV147(ctx,bytes)
    staged := SigWaitLocV147(ctx,item.uid,0,4000,item.unit)
    if (!IsObject(staged) || staged.cls!=item.cls || staged.q!=item.q
        || D2ReadU32(ctx.h,staged.data+0x14)!=item.storeSeedV629)
        throw Exception("Chuyển Kho: chưa xác nhận đúng vật dưới đất đã vào túi")
    return staged
}

TownStoreReadCloseV641(r,ctx)
{
    global sigCubeUiOpenV159
    ctx.storeOccupiedV641 := false
    TownStoreOpenV629(ctx,sigCubeUiOpenV159)
    previous := "",stable := 0,started := A_TickCount
    Loop
    {
        SigCheckV147(ctx)
        occupied := {},fingerprint := "",count := 0
        for uid,a in SigSnapshotV147(ctx)
            if (a.loc=4 && D2ReadU32(ctx.h,a.unit+0x10)=0)
            {
                size := TicketItemSizeV277(ctx,a.cls)
                if (a.x<0 || a.y<0 || a.x+size.w>14 || a.y+size.h>14)
                    throw Exception("Chuyển Kho: tọa độ đồ trong kho ngoài vùng ô 0–13; dừng đọc")
                count++,fingerprint .= uid . ":" . a.x . "," . a.y . ";"
                Loop, % size.h
                {
                    yy := a.y+A_Index-1
                    Loop, % size.w
                        occupied[(a.x+A_Index-1) . "," . yy] := true
                }
            }
        stable := fingerprint=previous ? stable+1 : 0,previous := fingerprint
        if (stable>=2)
            break
        if (A_TickCount-started>3000)
            throw Exception("Chuyển Kho: dữ liệu kho chưa ổn định; chưa chuyển đồ")
        Sleep, 150
    }
    ctx.storeOccupiedV641 := occupied
    SigLogV147("TOWN_STORE_GRID_READ ui=OPEN items=" . count . " occupied_cells=" . occupied.Count() . " next=CLOSE_THEN_PACKET")
    TownStoreMoneyV636(ctx)
    TownStoreCloseBatchV636(r,ctx)
    SigLogV147("TOWN_STORE_GRID_READY ui=CLOSED occupied_cells=" . occupied.Count())
}

TownStoreCommitV641(ctx,item,slot,size)
{
    all := SigSnapshotV147(ctx),a := all[item.uid]
    if (!IsObject(a))
        a := SigLiveItemV148(ctx,item.uid,item.unit)
    x := IsObject(a) && a.x>=0 && a.x+size.w<=14 ? a.x : slot.x
    y := IsObject(a) && a.y>=0 && a.y+size.h<=14 ? a.y : slot.y
    Loop, % size.h
    {
        yy := y+A_Index-1
        Loop, % size.w
            ctx.storeOccupiedV641[(x+A_Index-1) . "," . yy] := true
    }
    SigLogV147("TOWN_STORE_GRID_RESERVED uid=" . item.uid . " xy=" . x . "," . y . " size=" . size.w . "x" . size.h)
    return true
}

CoordEscapeVectorV661(dx,dy,direction:=1,px:=0,py:=0)
{
    if (IsObject(direction))
        return {x:direction.x-px,y:direction.y-py}
    if (direction="PLUS45" || direction="MINUS45")
    {
        sign := direction="PLUS45" ? 1 : -1,c := Sqrt(0.5)
        return {x:(dx-sign*dy)*c,y:(sign*dx+dy)*c}
    }
    if (direction="LEFT")
        return {x:dy,y:-dx}
    if (direction="RIGHT")
        return {x:-dy,y:dx}
    return {x:dx*direction,y:dy*direction}
}

CoordWalkEscapeSetV661(e,stage,px,py)
{
    global chaseCheckSecV9
    e.walkRecoveryV642 := true
    e.phase := "T1",e.phaseAt := A_TickCount
    e.probeX := px,e.probeY := py
    e.probeDist := Sqrt((px-e.point.x)**2+(py-e.point.y)**2)
    e.lastSend := 0,e.teleSent := false,e.teleAt := 0
    e.teleProbeX := px,e.teleProbeY := py
    if (e.HasKey("targetX"))
        e.Delete("targetX")
    AutoMonsterAttackLogV2("STUCK_PHASE name=T1 row=" . e.row . " from=" . px . "," . py)
}

CoordWalkEscapeAdvanceV661(e,px,py)
{
    switch e.phase
    {
        case "T1": next := "W1"
        case "W1": next := "B2"
        case "B2": next := "W2"
        case "W2": next := "T2"
        case "T2": next := "W2b"
        case "W2b": next := "B3"
        case "B3": next := "W3"
        case "W3": next := "T3"
        case "T3": next := "W3b"
        default: next := "BB"
    }
    e.phase := next,e.phaseAt := A_TickCount
    e.probeX := px,e.probeY := py
    e.probeDist := Sqrt((px-e.point.x)**2+(py-e.point.y)**2)
    e.lastSend := 0,e.teleSent := false,e.teleAt := 0
    if (e.HasKey("targetX"))
        e.Delete("targetX")
    AutoMonsterAttackLogV2("STUCK_PHASE name=" . next . " row=" . e.row)
}

CoordWalkEscapeTickV642(h,ByRef pb,pid,r,e,point,manualGoal:=false,arrivalRadiusV1251:=5)
{
    global chaseCheckSecV9,teleportIntervalSecV56,teleportKeyV55,boMoveMinimumV456,coordSavedV15
    px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort"),now := A_TickCount
    manual := CoordRecoveryGoalValidV655(manualGoal)
    waitMs := Max(1,chaseCheckSecV9)*1000
    goalDist := Sqrt((px-point.x)**2+(py-point.y)**2)
    if (!manual)
        FarmTeleWalkObserveV2026(r,px,py)
    initial := Sqrt((e.stuckX-point.x)**2+(e.stuckY-point.y)**2)
    if (initial-goalDist >= Max(5,boMoveMinimumV456))
    {
        CoordWalkEscapeResumeV642(r,e,"RECOVERY_PROGRESS")
        return false
    }
    if (e.phase="B2" || e.phase="B3")
    {
        if (!e.HasKey("targetX"))
        {
            dx := e.returnXV608-px,dy := e.returnYV608-py
            if (dx*dx+dy*dy<1)
                dx := 1,dy := 0
            side := e.phase="B2" ? "PLUS45" : "MINUS45"
            vector := CoordEscapeVectorV661(dx,dy,side)
            length := Sqrt(vector.x**2+vector.y**2)
            e.targetX := Round(px+vector.x*5/length)
            e.targetY := Round(py+vector.y*5/length)
            e.backProbeX := px,e.backProbeY := py
            AutoMonsterAttackLogV2("STUCK_BACK side=" . side . " row=" . e.row
                . " from=" . px . "," . py . " target=" . e.targetX . "," . e.targetY)
        }
        dist := Sqrt((px-e.targetX)**2+(py-e.targetY)**2)
        travelled := Sqrt((px-e.backProbeX)**2+(py-e.backProbeY)**2)
        if (dist<=1 || travelled>=5 || now-e.phaseAt>=waitMs)
        {
            CoordWalkEscapeAdvanceV661(e,px,py)
            return true
        }
        if (!e.lastSend || now-e.lastSend>=200)
        {
            moveSentV2026 := CoordStuckMoveV392(pid,e.targetX,e.targetY,point.level,r,e.row,manualGoal)
            if (moveSentV2026 && !manual)
                FarmTeleWalkDispatchedV2026(r,px,py)
            e.lastSend := now
        }
        return true
    }
    if (e.phase="BB")
    {
        dist := Sqrt((px-e.returnXV608)**2+(py-e.returnYV608)**2)
        if (dist<=5)
        {
            CoordWalkEscapeResumeV642(r,e,"RESTART_B_TO_C")
            return false
        }
        ; A blocked return-to-B gets one more complete escape sequence.
        if (now-e.phaseAt>=waitMs)
        {
            if (!e.extraEscapeV903)
            {
                e.extraEscapeV903 := true
                CoordWalkEscapeSetV661(e,"T1",px,py)
                AutoMonsterAttackLogV2("STUCK_MOVE_RETRY_EXTRA row=" . e.row . " attempt=2")
                return true
            }
            CoordWalkEscapeResumeV642(r,e,"RECOVERY_RETRY_EXHAUSTED")
            return false
        }
        if (!e.lastSend || now-e.lastSend>=200)
        {
            moveSentV2026 := CoordStuckMoveV392(pid,e.returnXV608,e.returnYV608,point.level,r,e.row,manualGoal)
            if (moveSentV2026 && !manual)
                FarmTeleWalkDispatchedV2026(r,px,py)
            e.lastSend := now
        }
        return true
    }
    if (SubStr(e.phase,1,1)="T")
    {
        if (teleportKeyV55="" || point.level=163)
        {
            CoordWalkEscapeAdvanceV661(e,px,py)
            return true
        }
        if (!e.teleSent)
        {
            ; Farm: if the previous Tele has not been followed by real walking,
            ; skip another Tele and try the recovery walking phase instead.
            if (!manual && r.teleRequiresWalkV2026)
            {
                PortalLogWriteV66("BC_STUCK_TELE_SKIPPED row=" . e.row
                    . " reason=NO_WALK_AFTER_PREVIOUS_TELE next=WALK", "BC_STUCK_TELE_SKIPPED", 1000)
                CoordWalkEscapeAdvanceV661(e,px,py)
                return true
            }
            beforeX := px,beforeY := py
            sent := manual ? CoordGoTeleportToV303(h,pb,manualGoal,1)
                : CoordTeleportStuckV55(h,pb,pid,point,1)
            if (sent)
            {
                r.lastTeleport := A_TickCount
                e.teleSent := true,e.teleAt := now
                e.teleProbeX := beforeX,e.teleProbeY := beforeY
                if (!manual)
                {
                    r.teleRequiresWalkV2026 := true
                    r.teleWalkCommandAtV2026 := 0
                }
                return true
            }
            if (now-e.phaseAt>=500)
                CoordWalkEscapeAdvanceV661(e,px,py)
            return true
        }
        if (now-e.teleAt<350)
            return true
        CoordWalkEscapeAdvanceV661(e,px,py)
        return true
    }
    if (goalDist<=Max(1,arrivalRadiusV1251))
    {
        CoordWalkEscapeResumeV642(r,e,"ARRIVED_C")
        return false
    }
    if (goalDist < e.probeDist-1)
    {
        e.probeDist := goalDist
        e.phaseAt := A_TickCount
    }
    if (now-e.phaseAt>=waitMs)
    {
        CoordWalkEscapeAdvanceV661(e,px,py)
        return true
    }
    if (!e.lastSend || now-e.lastSend>=200)
    {
        moveSentV2026 := CoordStuckMoveV392(pid,point.x,point.y,point.level,r,e.row,manualGoal)
        if (moveSentV2026 && !manual)
            FarmTeleWalkDispatchedV2026(r,px,py)
        e.lastSend := now
    }
    return true
}


FarmPreBuffCombatCheckV710(h,player,ByRef pb,pid,finished := false)
{
    routePointsV724 := FarmRoutePointsV724()
    global gameItemActionOwner,xRunning,zRunning,farmBuffExclusiveV621,monsterRadiusV48,moveDelayMsV810
    global farmRunEpochV535,form6KeyV716,scosEntryV162,farmControlOwnerV186
    static origin := false,lastAttackAt := 0,lastMoveAt := 0

    if (finished)
    {
        origin := false,lastAttackAt := 0,lastMoveAt := 0
        return false
    }
    room := NumGet(pb,0x1C,"UInt")
    px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort")
    level := room ? CoordLevelV14(h,room) : 0
    if (!pid || !player || !level || !px || !py)
        return true
    if (!IsObject(origin) || origin.pid!=pid || origin.player!=player
        || origin.level!=level || origin.epoch!=farmRunEpochV535)
    {
        origin := {pid:pid,player:player,level:level,epoch:farmRunEpochV535
            ,x:px,y:py,radiusSq:(Max(1,monsterRadiusV48)/2)**2}
        lastAttackAt := 0,lastMoveAt := 0
        PortalLogWriteV66("PRE_BUFF_BEGIN center=" . px . "," . py
            . " radius=" . Sqrt(origin.radiusSq) . " return_before_buff=1")
    }
    returnX := origin.x,returnY := origin.y
    if (farmControlOwnerV186="SCOS" && level=270)
    {
        buffPoint := IsObject(scosEntryV162) && scosEntryV162.map="SCOS"
            && scosEntryV162.pid=pid ? scosEntryV162.scosInwardV696.point : false
        if (!IsObject(buffPoint))
            buffPoint := ScosMap3NextPointV696(routePointsV724)
        if (!IsObject(buffPoint) || buffPoint.row!=2)
            return true
        returnX := buffPoint.x,returnY := buffPoint.y
    }
    if (xRunning || zRunning || gameItemActionOwner!="" || farmBuffExclusiveV621)
        return true
    playerMode := D2ReadU32(h,player+0x10)
    if (playerMode=0 || playerMode=17)
        return true

    best := false,bestDist := 0x7FFFFFFF,seen := {},scanComplete := true
    rooms := MonsterLoadedRoomsV20(h,room)
    if (!IsObject(rooms) || !rooms.Length())
        return true
    for _,loadedRoom in rooms
    {
        if (!MonsterBossProbeReadV1(h,loadedRoom+0x74,4,head))
        {
            scanComplete := false
            continue
        }
        u := NumGet(head,0,"UInt")
        Loop, 1024
        {
            if (!u || seen.HasKey(u))
                break
            seen[u] := true
            if (!MonsterBossProbeReadV1(h,u,0xEC,ub))
            {
                scanComplete := false
                break
            }
            unit := u,u := NumGet(ub,0xE8,"UInt")
            uid := NumGet(ub,0x0C,"UInt"),mode := NumGet(ub,0x10,"UInt")
            if (NumGet(ub,0,"UInt")=1 && uid && mode!=0 && mode!=12
                && !MonsterClassExcludedV11(NumGet(ub,4,"UInt"),h,unit))
            {
                if (!MonsterBossProbeReadV1(h,NumGet(ub,0x2C,"UInt"),0x20,mb))
                    scanComplete := false
                else
                {
                    x := NumGet(mb,2,"UShort"),y := NumGet(mb,6,"UShort")
                    centerDist := (x-origin.x)**2+(y-origin.y)**2
                    dist := (x-px)**2+(y-py)**2
                    if (centerDist<=origin.radiusSq && dist<bestDist)
                        best := {unit:unit,uid:uid,x:x,y:y,dist:dist,cls:NumGet(ub,4,"UInt")}
                            ,bestDist := dist
                }
            }
            if (u=unit || (A_Index=1024 && u))
            {
                scanComplete := false
                break
            }
        }
    }
    if (IsObject(best))
    {
        if (!NativeDispatchReadyV10(true) || !AutoMonsterPacketCleanupV1())
            return true
        if (A_TickCount-lastAttackAt>=250)
        {
            if (QuickBuffHasKey(form6KeyV716))
            {
                if (!QuickBuffSend(form6KeyV716))
                    return true
            }
            else if (!LastAttackSkillV20())
                return true
            if (NativeMapTestV5(true,{pid:pid,unit:best.unit,uid:best.uid}))
            {
                lastAttackAt := A_TickCount
                AttackIdTipV12(best.cls,Round(Sqrt(best.dist),1))
                PortalLogWriteV66("PRE_BUFF_ATTACK uid=" . best.uid
                    . " center=" . origin.x . "," . origin.y . " radius=" . Sqrt(origin.radiusSq))
            }
        }
        return true
    }
    if (!scanComplete)
    {
        if (!origin.preBuffSkipAt) 
            origin.preBuffSkipAt := A_TickCount
        if (A_TickCount - origin.preBuffSkipAt > 1500) 
            return false
        return true
    }
    if (!FarmAttackHoldReleaseV15() || !AutoMonsterPacketCleanupV1())
        return true
    if ((px-returnX)**2+(py-returnY)**2>1)
    {
        if (NativeDispatchReadyV10(true) && A_TickCount-lastMoveAt>=Max(0,moveDelayMsV810))
        {
            if (NativeMovePointV14(pid,returnX,returnY,level,false,false,true,false,false))
            {
                lastMoveAt := A_TickCount
                PortalLogWriteV66("PRE_BUFF_RETURN to=" . returnX . "," . returnY . " buff=WAIT")
            }
        }
        return true
    }
    if (playerMode=2 || playerMode=3 || playerMode=6)
        return true
    return false
}

CheckAndRestoreBackgroundFarm(pid, currentLevel)
{
    global outsideLevelV22, backgroundHwndV63
    static lastFarmLevel := 0

    if (currentLevel != 0 && currentLevel == outsideLevelV22 && lastFarmLevel != outsideLevelV22)
    {
        PortalLogWriteV66("MAP_FARM_RESTORE_BACKGROUND level=" . currentLevel . " -> Kich hoat lai chay nen.")
        
        if (backgroundHwndV63 && DllCall("IsWindow", "Ptr", backgroundHwndV63))
        {
            DllCall("PostMessage", "Ptr", backgroundHwndV63, "UInt", 0x1C, "UPtr", 1, "Ptr", 0)
            DllCall("PostMessage", "Ptr", backgroundHwndV63, "UInt", 0x6, "UPtr", 1, "Ptr", 0)
            
            WinGet, minmax, MinMax, ahk_id %backgroundHwndV63%
            if (minmax == -1)
            {
                DllCall("ShowWindowAsync", "Ptr", backgroundHwndV63, "Int", 4)
            }
        }
    }
    lastFarmLevel := currentLevel
}
D2GetProcessIdFromHandle(hProcess)
{
    return DllCall("GetProcessId", "Ptr", hProcess, "UInt")
}
CoordWalkEscapeResumeV642(r,e,reason)
{
    r.retryV611 := false
    if (e.HasKey("targetX"))
        e.Delete("targetX")
    FarmStuckResumeV608(r)
    ; Chi voi duong di NHAT, khong xem het chuoi thoat ket la da thanh cong.
    ; Truyen BLOCKED cho FarmPickupMoveResultV905 de thoat dich tam va ve C.
    if (reason="RECOVERY_RETRY_EXHAUSTED" && r.HasKey("itemMoveV910") && r.itemMoveV910)
        r.phase := "BLOCKED"
    AutoMonsterAttackLogV2("STUCK_DONE row=" . e.row . " phase=" . e.phase
        . " reason=" . reason . " next=" . (r.phase="BLOCKED" ? "ITEM_STUCK" : "RESUME_SAME_COORDINATE"))
    return false
}

GD1IdentifyButtonV643:
if (SigBackgroundBindV179())
{
    gd1IdentifyPidV643 := D2GetActiveGamePidV95()
    RouteRecorderIdentityV658("Đưa chuột lên NPC, kho, WP hoặc cổng trong game; đọc sau 3 giây.")
    ToolTipInfoV386("Đưa chuột lên NPC, kho, WP hoặc cổng trong game; đọc sau 3 giây.")
    SetTimer, GD1IdentifyTimerV643, -3000
}
return

GD1IdentifyTimerV643:
GD1IdentifyReadV643(gd1IdentifyPidV643)
return

GD1IdentifyReadV643(pid)
{
    global GD1IdentityTextV643,backgroundPidV63
    if (!pid || D2GetActiveGamePidV95()!=pid)
        return
    base := D2GetModuleBaseV35(pid,"D2Client.dll"),h := base ? D2OpenProcess(pid) : 0
    if (!h)
        return
    try
    {
        player := D2ReadU32(h,base+0x11BBFC),path := player ? D2ReadU32(h,player+0x2C) : 0
        unit := D2ReadU32(h,base+0x11B834)
        if (!MonsterBossProbeReadV1(h,path,0x20,pb) || !unit || !MonsterBossProbeReadV1(h,unit,0x18,ub))
        {
            RouteRecorderIdentityV658("Chưa nhận diện được; bấm Nhận Diện và giữ chuột trên đối tượng trong game.")
            ToolTipInfoV386("Chưa nhận diện được đối tượng; bấm Nhận Diện và giữ chuột trên đối tượng trong game.")
            return
        }
        kind := NumGet(ub,0,"UInt"),cls := NumGet(ub,4,"UInt"),uid := NumGet(ub,12,"UInt")
        if (kind!=1 && kind!=2 && kind!=4 && kind!=5)
            return
        level := CoordLevelV14(h,NumGet(pb,0x1C,"UInt"))
        targetPath := D2ReadU32(h,unit+0x2C)
        if (!MonsterBossProbeReadV1(h,targetPath,0x18,tp))
            return
        x := kind=1 ? NumGet(tp,2,"UShort") : NumGet(tp,0x0C,"UInt")
        y := kind=1 ? NumGet(tp,6,"UShort") : NumGet(tp,0x10,"UInt")
        label := kind=1 ? "NPC / Quái" : kind=4 ? "Vật phẩm" : cls=267 ? "Kho" : "Cổng / WP / Đối tượng"
        text := label . "`r`nlevel=" . level . " type=" . kind . " class=" . cls . " uid=" . uid
            . " x=" . x . " y=" . y
        if (kind=4)
        {
            data := NumGet(ub,0x14,"UInt")
            text .= " itemdata=" . Format("{:02X}",D2ReadU8V18(h,data))
        }
        text .= "`r`nplayer=" . NumGet(pb,2,"UShort") . "," . NumGet(pb,6,"UShort")
        Clipboard := text
        if (RouteRecorderIdentityV658(text . "`r`nĐã copy thông tin."))
            return
        Gui, GD1IdentityV643:New, +AlwaysOnTop +ToolWindow, Nhận diện GD1 - đã copy
        Gui, GD1IdentityV643:Font, s10, Segoe UI
        Gui, GD1IdentityV643:Add, Edit, x10 y10 w470 h125 Multi ReadOnly vGD1IdentityTextV643, %text%
        Gui, GD1IdentityV643:Show, w490 h145
    }
    finally
        DllCall("CloseHandle","Ptr",h)
}

GD1IdentityV643GuiClose:
GD1IdentityV643GuiEscape:
Gui, GD1IdentityV643:Destroy
return
RetiredThreadCleanupV690:
    RetiredThreadCleanupV690Tick()
return

RetiredThreadCleanupV690Tick()
{
    global retiredThreadsV690
    static busy := false
    if (busy)
        return
    if (!IsObject(retiredThreadsV690) || !retiredThreadsV690.Count())
    {
        SetTimer, RetiredThreadCleanupV690, Off
        return
    }
    busy := true
    try
    {
        for key,entry in retiredThreadsV690.Clone()
        {
            done := DllCall("WaitForSingleObject","Ptr",entry.th,"UInt",0)=0
            dead := RemoteProcessEndedV740(entry.h)
            if (!done && !dead)
                continue
            if (done && !dead)
                DllCall("VirtualFreeEx","Ptr",entry.h,"Ptr",entry.remote,"UPtr",0,"UInt",0x8000)
            DllCall("CloseHandle","Ptr",entry.th)
            DllCall("CloseHandle","Ptr",entry.h)
            retiredThreadsV690.Delete(key)
        }
        if (!IsObject(retiredThreadsV690) || !retiredThreadsV690.Count())
            SetTimer, RetiredThreadCleanupV690, Off
    }
    finally
        busy := false
}

RemoteThreadFinishV740(h,th,remote,wait)
{
    global retiredThreadsV690
    if (th && wait!=0)
    {
        previous := A_IsCritical
        Critical, On
        if (!IsObject(retiredThreadsV690))
            retiredThreadsV690 := {}
        pid := DllCall("GetProcessId","Ptr",h,"UInt")
        retiredThreadsV690[h . "|" . remote] := {h:h,th:th,remote:remote,pid:pid,at:A_TickCount}
        SetTimer, RetiredThreadCleanupV690, 100
        if (previous)
            Critical, %previous%
        else
            Critical, Off
        DebugTraceWrite("packet","REMOTE_TIMEOUT_TRACKED pid=" . pid . " next=WAIT_THREAD_OR_PROCESS_EXIT")
        return false
    }
    if (remote)
        DllCall("VirtualFreeEx","Ptr",h,"Ptr",remote,"UPtr",0,"UInt",0x8000)
    if (th)
        DllCall("CloseHandle","Ptr",th)
    if (h)
        DllCall("CloseHandle","Ptr",h)
    return wait=0
}

RemoteThreadBusyV740(pid)
{
    global retiredThreadsV690
    RetiredThreadCleanupV690Tick()
    for _,entry in retiredThreadsV690
        if (!pid || !entry.pid || entry.pid=pid)
            return true
    return false
}

FarmRuntimeErrorV740(e)
{
    global farmErrorRetryAtV740
    static lastNotice := 0
    farmErrorRetryAtV740 := A_TickCount+1000
    if (!lastNotice || A_TickCount-lastNotice>=3000)
    {
        lastNotice := A_TickCount
        try DebugTraceWrite("farm","FARM_RETRY_ERROR message=" . e.Message . " line=" . e.Line . " function=" . e.What)
        try FonInfoPushV385("Farm gặp lỗi tạm thời; giữ phiên và thử lại sau 1 giây.")
    }
}

RemoteProcessEndedV740(h)
{
    code := 259
    return DllCall("GetExitCodeProcess","Ptr",h,"UIntP",code) && code!=259
}


FarmCenterPolicyV741(pid,level:=0)
{
    global autoMonsterAttackOn,coordRouteV16,roomExploreV89,cainNoFightV361
    if (!autoMonsterAttackOn || !Stage2FightEnabledV9() || cainNoFightV361 || IsObject(roomExploreV89))
        return false
    r := coordRouteV16,points := FarmRoutePointsV724()
    if (!IsObject(r) || r.pid!=pid || !IsObject(points) || !points.Length()
        || (level && r.startLevel!=level) || (BossSearchActiveV430(pid) && !BOFinalRouteActiveV451(pid)))
        return false
    row := r.combatRowV627>=1 && r.combatRowV627<=points.Length() ? r.combatRowV627 : r.next
    return row>=1 && row<=points.Length() && points[row].level=r.startLevel && r.phase!="DONE"
}

FarmCenterCaptureV741(pid)
{
    global coordRouteV16,farmRunEpochV535
    if (!FarmCenterPolicyV741(pid))
        return false
    r := coordRouteV16,points := FarmRoutePointsV724()
    if (r.phase="NEXT" && r.next>=1 && r.next<=points.Length())
        row := r.next
    else
        row := r.combatRowV627>=1 && r.combatRowV627<=points.Length() ? r.combatRowV627 : r.next
    p := points[row]
    c := {pid:pid,epoch:farmRunEpochV535,route:r,row:row,level:p.level,x:p.x,y:p.y
        ,radius:Max(1,MonsterRadiusGetV239()),phase:"ATTACK",attacked:false,pickupPass:0}
    return c
}

FarmCenterPendingV741(pid)
{
    global farmCenterCycleV741,farmRunEpochV535,coordRouteV16,autoMonsterAttackOn
    c := farmCenterCycleV741
    if (!IsObject(c) || c.pid!=pid)
        return false
    points := FarmRoutePointsV724(),p := points[c.row]
    if (!autoMonsterAttackOn || c.epoch!=farmRunEpochV535 || c.route!=coordRouteV16
        || !IsObject(p) || p.level!=c.level || p.x!=c.x || p.y!=c.y)
    {
        farmCenterCycleV741 := false
        return false
    }
    return true
}

FarmCenterNextV756(c)
{
    points := FarmRoutePointsV724(),row := c.row+1,p := points[row]
    ; V1190: Dòng kế tiếp trùng tọa độ vẫn là một dòng lộ trình hợp lệ.
    ; Không trả false khi C trùng B: false trước đây bị hiểu nhầm là HẾT TUYẾN,
    ; làm Scos dòng 116=117 (5180,10660) chuyển GD3 quá sớm.
    if (!IsObject(p) || row>points.Length() || p.level!=c.level || p.x<1 || p.y<1)
        return false
    return {row:row,level:p.level,x:p.x,y:p.y}
}

FarmCenterGoalValidV756(c)
{
    if (!IsObject(c.forwardV756))
        return true
    live := FarmCenterNextV756(c),goal := c.forwardV756
    return IsObject(live) && live.row=goal.row && live.level=goal.level
        && live.x=goal.x && live.y=goal.y
}

; ROUTE 1->2->3: Khong nhay dong. Chi xac nhan den diem khi vao ban kinh diem do.
; B->C: Chi mot tieu chuan den C, dung BK danh tren giao dien Form 6.
; Dung chung cho CHECK, MOVE, TELE, va xu ly vuot C.
FarmCenterArrivedV756(px,py,gx,gy)
{
    radiusV756 := Max(1,MonsterRadiusGetV239())
    return (px-gx)**2+(py-gy)**2<=radiusV756*radiusV756
}

FarmCenterAdvanceV756(h,player,pid,c,px,py)
{
    global coordRouteV16,farmCenterCycleV741,farmFightLockV626
    global coordNoTargetSinceV14,coordCastPendingV50,portalBuffV85,roomExploreV89
    global monsterCombatUidV45,monsterRoadAreaV51,monsterChaseV44,farmScanListV682,farmScanSelectedV682
    if (FarmItemRoutePausedV903(pid))
        return false
    if (!FarmCenterPendingV741(pid) || farmCenterCycleV741!=c || !IsObject(c.forwardV756)
        || !FarmCenterGoalValidV756(c))
        return false
    goal := c.forwardV756
    ; B->C: vao ban kinh danh da cai thi coi nhu den, giao cho luong danh chinh.
    if (!FarmCenterArrivedV756(px,py,goal.x,goal.y))
        return false
    ; MOVE chi kiem tra da gan C, khong mo cong / danh / buff.
    ; Dieu kien mo cong duoc LUONG CHINH xet sau khi nhan DONE.
    if (!FarmCenterPendingV741(pid) || farmCenterCycleV741!=c || !FarmCenterGoalValidV756(c))
        return false
    ; V991: vi tri (px,py) da duoc doc/kiem tra level o luong goi.
    ; Khong doc lai path lan 2: doc loi tam thoi khong duoc lam mat MOVE DONE.
    r := coordRouteV16
    r.anchor := c.row,r.yellow := goal.row,r.combatRowV627 := goal.row,r.next := goal.row
    r.phase := "NEXT",r.forwardFloorV303 := c.row
    r.battlePending := false,r.lastDispatch := 0,r.legRow := 0,r.firstMoveAttempted := false
    r.escapeV84 := false,r.stuckProbe := false,r.bypass := false,r.moveProbe := false
    r.startAtYellowV367 := false,r.lastArrivalV343 := A_TickCount
    coordNoTargetSinceV14 := A_TickCount-250
    ; V970: handoff minh bach. MOVE bao DONE/ARRIVED va giu cycle cho
    ; FarmCenterCheckV741 (luong farm chinh) tu chon PRE_BUFF hay ATTACK_FIRST.
    c.row := goal.row,c.x := goal.x,c.y := goal.y,c.forwardV756 := false
    c.phase := "MOVE_DONE",c.moveStateV905 := "DONE",c.moveResultV905 := "ARRIVED"
    c.attackStateV905 := "RUNNING",c.attackResultV905 := ""
    c.attackEmptyCountV906 := 0,c.attackEmptyAtV906 := 0
    c.attacked := false,c.roadWatchV914 := false
    ; Sang diem moi: khong dung ket qua Tele va bo dem retry cua diem cu.
    c.teleProbeV2026 := false,c.teleAvoidUntilV2026 := 0
    c.teleWalkPendingV2026 := false,c.preferredTeleRowV2026 := 0
    r.teleRequiresWalkV2026 := false,r.teleWalkCommandAtV2026 := 0
    farmFightLockV626 := false
    monsterCombatUidV45 := 0,monsterRoadAreaV51 := false,monsterChaseV44 := false
    farmScanListV682 := [],farmScanSelectedV682 := 0
    PortalLogWriteV66("BC_MOVE_DONE row=" . goal.row
        . " result=ARRIVED next=MAIN_CHECK_PORTAL_OR_NORMAL_ATTACK")
    FarmCombatViewV624(pid,false,"MOVE DONE tại C; giao cho luồng chính kiểm tra mở cổng")
    CoordBoxRefreshV15()
    return true
}

FarmFlowScanGroundItemsV902(h,player,pid,room,level,px,py,infoOnly)
{
    global farmCenterCycleV741,farmItemLockV625,farmFightLockV626
    global pickupImageOn,pickupGroupActiveV26,pickupRadius,pickupRoundResetV1
    global farmGroundItemCountV710,monsterCombatUidV45,monsterChaseV44,monsterRoadAreaV51
        itemLockSeenV625 := false,itemScanCompleteV625 := true
        itemOnRoad := false,itemCx := 0,itemCy := 0,itemBestV590 := 0x7FFFFFFF
        deferItemGuardV768 := !infoOnly && FarmCenterPendingV741(pid)
            && !farmCenterCycleV741.attacked
        ; Trong luong diem B->C, chi timer nhat rieng duoc tao tin do moi.
        ; Bo quet FARM chi kiem tra lai do da duoc khoa, khong chiem quyen tai tam khac.
        if (!infoOnly && pickupImageOn && !pickupGroupActiveV26 && Stage2PickupEnabledV9() && !BOCommonActiveV444(pid)
            && (!FarmCenterPolicyV741(pid,level) || IsObject(farmItemLockV625)))
        {
            itemScanSeen := {}
            itemScanRadiusSqV625 := PickupScanRadiusGetV810()**2
            for _,ir in MonsterLoadedRoomsV20(h,room)
            {
                if (!MonsterBossProbeReadV1(h,ir+0x74,4,itemHeadV625))
                {
                    itemScanCompleteV625 := false
                    continue
                }
                iu := NumGet(itemHeadV625,0,"UInt")
                Loop, 1024
                {
                    if (!iu || itemScanSeen.HasKey(iu))
                        break
                    itemScanSeen[iu] := true
                    if (!MonsterBossProbeReadV1(h,iu,0xEC,itemUnitV625))
                    {
                        itemScanCompleteV625 := false
                        break
                    }
                    if (D2ReadU32(h,iu)=4)
                    {
                        idata := D2ReadU32(h,iu+0x14),imode := D2ReadU32(h,iu+0x10),icls := D2ReadU32(h,iu+4)
                        if (idata && icls!=1214 && (imode=3 || imode=5))
                        {
                            iip := D2ReadU32(h,iu+0x2C)
                            if (iip && MonsterBossProbeReadV1(h,iip,0x14,itemPathV625))
                            {
                                iix := NumGet(itemPathV625,0x0C,"UInt"),iiy := NumGet(itemPathV625,0x10,"UInt")
                                idist := (iix-px)**2+(iiy-py)**2
                                lockDistV625 := IsObject(farmItemLockV625)
                                    ? (iix-farmItemLockV625.x)**2+(iiy-farmItemLockV625.y)**2 : idist
                                lockRadiusSqV625 := IsObject(farmItemLockV625) ? farmItemLockV625.pickupRadiusSqV648 : pickupRadius*pickupRadius
                                itemDetectRadiusSqV625 := IsObject(farmItemLockV625)
                                    ? lockRadiusSqV625 : itemScanRadiusSqV625
                                if (lockDistV625<=itemDetectRadiusSqV625
                                    && !FarmPickupTimedIgnoreV1602(pid,level,D2ReadU32(h,iu+0x0C))
                                    && PickupFileHasRuleV97(icls,D2ReadU8V18(h,idata),idata,h,iu))
                                {
                                    farmGroundItemCountV710++
                                    itemLockSeenV625 := true
                                    if (!deferItemGuardV768 && idist<itemBestV590)
                                    {
                                        itemOnRoad := true,itemCx := iix,itemCy := iiy,itemBestV590 := idist
                                        itemBestUidV1602 := D2ReadU32(h,iu+0x0C),itemBestClsV1602 := icls
                                    }
                                }
                            }
                            else
                                itemScanCompleteV625 := false
                        }
                    }
                    inx := D2ReadU32(h,iu+0xE8)
                    if (inx=iu)
                    {
                        itemScanCompleteV625 := false
                        break
                    }
                    iu := inx
                    if (A_Index=1024 && iu)
                        itemScanCompleteV625 := false
                }
            }
            if (IsObject(farmItemLockV625) && !itemLockSeenV625 && itemScanCompleteV625)
            {
                ; V918: ONE missed ground-item scan must not cancel Farm's temporary
                ; target while ITEM_MOVE/ITEM_ATTACK/PICKUP owns the move/attack.
                ; Only the shared pickup handoff may finish this workflow.
                farmItemOwnedV918 := FarmCenterPendingV741(pid)
                    && (farmCenterCycleV741.phase="ITEM_MOVE"
                        || farmCenterCycleV741.phase="ITEM_ATTACK"
                        || farmCenterCycleV741.phase="PICKUP"
                        || farmCenterCycleV741.phase="PICKUP_BUSY")
                if (farmItemOwnedV918)
                    PortalLogWriteV66("BC_ITEM_LOCK_KEEP phase=" . farmCenterCycleV741.phase
                        . " center=" . farmItemLockV625.x . "," . farmItemLockV625.y
                        . " reason=SCAN_MISS_WAIT_PICKUP_DONE", "BC_ITEM_LOCK_KEEP", 1000)
                else
                {
                    farmItemLockV625 := false
                    AutoMonsterAttackLogV2("ITEM_GUARD_UNLOCK reason=NO_WANTED_GROUND_ITEMS_IN_FIXED_CIRCLE")
                }
            }
            if (!IsObject(farmItemLockV625) && itemOnRoad)
            {
                pickupRoundResetV1 := true
                farmFightLockV626 := false
                itemGuardRadiusV648 := ItemCenterRadiusGetV810()
                farmItemLockV625 := {pid:pid,player:player,level:level,x:itemCx,y:itemCy
                    ,uid:itemBestUidV1602,cls:itemBestClsV1602,startedAtV1602:A_TickCount
                    ,radiusSq:itemGuardRadiusV648*itemGuardRadiusV648,pickupRadiusSqV648:Max(1,pickupRadius)**2
                    ,source:"ITEM_PICKUP_LOCK",row:0}
                monsterCombatUidV45 := 0,monsterChaseV44 := false,monsterRoadAreaV51 := false
                AutoMonsterPacketCleanupV1()
                AutoMonsterAttackLogV2("ITEM_GUARD_LOCK center=" . itemCx . "," . itemCy . " combat_radius=" . itemGuardRadiusV648 . " pickup_radius=" . Max(1,pickupRadius))
            }
        }
        if (IsObject(farmItemLockV625))
        {
            if (itemLockSeenV625 && itemCx>0 && itemCy>0)
                farmItemLockV625.pickupX := itemCx,farmItemLockV625.pickupY := itemCy
            itemOnRoad := true,itemCx := farmItemLockV625.x,itemCy := farmItemLockV625.y
        }
        return {found:itemOnRoad,x:itemCx,y:itemCy,complete:itemScanCompleteV625}
}

FarmParentNextV767(phase)
{
    global farmCenterCycleV741
    ; ITEM_ATTACK: giu tam vat pham trong suot cac lan gui lenh danh va kiem tra ket.
    if (phase="ITEM_ATTACK" && IsObject(farmCenterCycleV741))
        return "ITEM_ATTACK"
    if (phase="ROAD_ATTACK" && IsObject(farmCenterCycleV741))
        return "ROAD_ATTACK"
    return (phase="ATTACK_FIRST" || phase="ATTACK_MORE") && IsObject(farmCenterCycleV741) ? "ATTACK_MORE" : ""
}

FarmParentBeginV767(pid,level)
{
    global farmCenterCycleV741,farmTownBuffRearmV1002,portalBuffDeferredV998
    global farmRunEpochV535,currentProfile,routeMapIdV21,farmControlOwnerV186
    if (FarmCenterPendingV741(pid) || !FarmCenterPolicyV741(pid,level))
        return false
    c := FarmCenterCaptureV741(pid)
    if (!IsObject(c))
        return false
    rearmV1002 := farmTownBuffRearmV1002
    if (IsObject(rearmV1002) && rearmV1002.pid=pid && rearmV1002.level=c.level
        && rearmV1002.row=c.row && rearmV1002.profile=currentProfile
        && rearmV1002.mapId=routeMapIdV21 && rearmV1002.owner=farmControlOwnerV186)
    {
        portalBuffDeferredV998 := {pid:pid,route:c.route,epoch:farmRunEpochV535
            ,fromRow:rearmV1002.fromRow,row:c.row}
        farmTownBuffRearmV1002 := false
        PortalLogWriteV66("FARM_TOWN_BUFF_RESUME row=" . c.row . " from=" . rearmV1002.fromRow)
    }
    c.phase := "ATTACK_FIRST",c.attacked := false,c.pickupPass := 0
    c.attackStateV905 := "RUNNING", c.attackResultV905 := ""
    c.attackEmptyCountV906 := 0, c.attackEmptyAtV906 := 0
    farmCenterCycleV741 := c
    PortalLogWriteV66("BC_ENGINE_BUILD=20261029_ROAD_FON_PICKUP_TELE_WALK_FIRST"
        . " row=" . c.row . " level=" . c.level)
    return true
}

FarmParentAttackEmptyV767(pid)
{
    global farmCenterCycleV741,farmScanListV682,farmItemLockV625,coordRouteV16,portalBuffDeferredV998
    global coordCastPendingV50,coordCastLastRowV50,portalCastKeyV50
    global monsterCombatUidV45,monsterRoadAreaV51,monsterChaseV44,chaseCheckSecV9
    if (!FarmCenterPendingV741(pid))
        return false
    c := farmCenterCycleV741
    if (c.phase!="ATTACK_FIRST" && c.phase!="ATTACK_MORE"
        && c.phase!="ITEM_ATTACK" && c.phase!="ROAD_ATTACK")
        return false
    if (IsObject(farmScanListV682) && farmScanListV682.Length())
        return false
    ; Quet rong >=3 luot day du lien tiep thi chuyen sang buoc tiep theo ngay.
    ; Quai xuat hien / quet khong day du se reset bo dem o luong quet.
    if (!c.attackEmptyAtV906 || A_TickCount-c.attackEmptyAtV906>750)
    {
        c.attackEmptyAtV906 := A_TickCount
        c.attackEmptyCountV906 := 1
    }
    else if (A_TickCount-c.attackEmptyAtV906>=200)
        c.attackEmptyAtV906 := A_TickCount, c.attackEmptyCountV906++
    if (c.attackEmptyCountV906<3)
        return true
    PortalLogWriteV66("BC_ATTACK_AREA_EMPTY_CONFIRMED row=" . c.row
        . " phase=" . c.phase . " empty_scans=" . c.attackEmptyCountV906)
    ; Quet rong da xac nhan: bo UID tan cong cu de khong chan CoordCastTickV50.
    monsterCombatUidV45 := 0,monsterRoadAreaV51 := false,monsterChaseV44 := false
    FarmAttackHoldReleaseV15()
    ; Dung tam quet nhan vat: danh sach quai can duong xong -> di tiep C.
    ; Khong tang dong vang, khong doi dich C, khong quay ve diem B.
    if (c.phase="ROAD_ATTACK")
    {
        c.phase := "MOVE",c.roadX_V2026 := 0,c.roadY_V2026 := 0
        c.attackEmptyCountV906 := 0,c.attackEmptyAtV906 := 0
        rRoadV2026 := coordRouteV16
        if (IsObject(rRoadV2026) && rRoadV2026.pid=pid)
            rRoadV2026.battlePending := false,rRoadV2026.stuckProbe := false
                ,rRoadV2026.lastDispatch := 0,rRoadV2026.firstMoveAttempted := false
        PortalLogWriteV66("BC_ROAD_CLEAR row=" . c.row . " next="
            . (IsObject(c.forwardV756) ? c.forwardV756.row : 0) . " resume=MOVE")
        return true
    }
    ; Quet sach tai diem moi xet cong/buff/di tiep. Tin hieu item duoc xu ly rieng.
    if (c.phase!="ITEM_ATTACK")
    {
        ; V1002: cong o diem N CHI duoc mo sau khi quet rong on dinh.
        if (coordCastPendingV50 && coordCastLastRowV50=c.row && portalCastKeyV50!="")
            c.portalCastReadyV1002 := true
        ; V998: chi mo khoa BUFF o N+1 khi quet danh tai diem nay da sach.
        pendingV998 := portalBuffDeferredV998
        if (IsObject(pendingV998) && pendingV998.pid=pid && pendingV998.route=c.route
            && pendingV998.epoch=c.epoch && pendingV998.row=c.row)
            c.portalBuffReadyV998 := true
        c.attackEmptyCountV906 := 0
        c.phase := "CHECK"
        return true
    }
    ; Chi ITEM_ATTACK (sau khi DEN VI TRI DO) moi duoc giao quyen nhat.
    ; If the lock vanishes during the combat scan, do not complete the Farm row.
    ; FarmCenterCheckV741 can restore the original center on the next tick.
    if (!IsObject(farmItemLockV625))
    {
        PortalLogWriteV66("BC_ITEM_LOCK_MISSING phase=ITEM_ATTACK next=RECOVER_NOT_C")
        return true
    }
    c.attackStateV905 := "DONE"
    c.attackResultV905 := "AREA_CLEAR_CONFIRMED"
    c.phase := Stage2PickupEnabledV9() ? "PICKUP" : "CHECK"
    PortalLogWriteV66("BC_ITEM_AREA_CLEAR center=" . farmItemLockV625.x . "," . farmItemLockV625.y . " next=PICKUP")
    return true
}

FarmCenterCheckV741(h,player,pid,mainTurnV768:=false)
{
    global farmCenterCycleV741,autoMonsterAttackOn,farmRunEpochV535,coordRouteV16,farmItemLockV625
    global monsterCombatUidV45,monsterRoadAreaV51,monsterChaseV44
    global portalBuffV85,coordCastPendingV50,coordCastLastRowV50,portalCastKeyV50,pickupImageOn,pickupRadius
    global portalBuffDeferredV998,pestiPointPendingV28,lastAttackPendingV20
    global farmTownResumeSaveV1002,currentProfile,routeMapIdV21,farmControlOwnerV186
    if (!FarmCenterPendingV741(pid))
        return false
    c := farmCenterCycleV741
    FarmPortalBuffDeadlineV1301(pid,"CENTER_TICK")
    ; V1002: luu diem dang di truoc khi co the bi cham cong ve thanh.
    ; Khong dong vao route, anchor, bo dem hoac luong MOVE.
    saveRowV1002 := c.phase="MOVE" && IsObject(c.forwardV756) ? c.forwardV756.row : c.row
    ; Neu da mo cong o N va danh xong, quay lai phai tiep N+1.
    if (c.phase="CHECK" && IsObject(portalBuffDeferredV998)
        && portalBuffDeferredV998.pid=pid && portalBuffDeferredV998.route=c.route
        && portalBuffDeferredV998.fromRow=c.row && !coordCastPendingV50)
        saveRowV1002 := portalBuffDeferredV998.row
    farmTownResumeSaveV1002 := {pid:pid,level:c.level,row:saveRowV1002
        ,profile:currentProfile,mapId:routeMapIdV21,owner:farmControlOwnerV186,at:A_TickCount}
    ; LUONG 2: timer nhat bao do bat ke luc danh B hay di C.
    ; Phai DI TOI VAT PHAM truoc, KHONG danh quanh do tu xa.
    if (FarmItemRoutePausedV903(pid) && c.phase!="ITEM_MOVE" && c.phase!="ITEM_ATTACK"
        && c.phase!="PICKUP" && c.phase!="PICKUP_BUSY")
    {
        c.resumeAfterItemV2026 := c.phase
        monsterCombatUidV45 := 0,monsterRoadAreaV51 := false,monsterChaseV44 := false
        c.phase := "ITEM_MOVE",c.attackStateV905 := "RUNNING",c.attackResultV905 := ""
        c.fencePickupV1185 := false
        c.attackEmptyCountV906 := 0,c.attackEmptyAtV906 := 0
        ; Dung thu trang thai ket cua C trong khi dinh tam la do.
        if (IsObject(coordRouteV16) && coordRouteV16.pid=pid)
            coordRouteV16.escapeV84 := false,coordRouteV16.stuckProbe := false
        FarmAttackHoldReleaseV15()
        PortalLogWriteV66("BC_ITEM_SIGNAL center=" . farmItemLockV625.x . "," . farmItemLockV625.y . " first=ITEM_MOVE")
    }
    if (c.phase="ITEM_MOVE")
        return FarmCenterStepV766(h,player,pid)  ; toi do se goi nhat ngay, khong danh
    if (c.phase="ITEM_ATTACK")
    {
        ; Legacy phase tu phien cu: khong tao BK danh item. Phuc hoi ve
        ; ITEM_MOVE neu van co item lock, nguoc lai quay ve CHECK route.
        if (FarmItemRoutePausedV903(pid))
        {
            c.phase := "ITEM_MOVE"
            PortalLogWriteV66("BC_ITEM_LEGACY_RECOVER next=ITEM_MOVE")
        }
        else
        {
            c.phase := "CHECK"
            PortalLogWriteV66("BC_ITEM_LEGACY_RECOVER next=CHECK item=GONE")
        }
        return true
    }
    ; Item da nhat xong/het tin hieu: quay lai danh quai tai tam dang do,
    ; khong di thang C neu truoc luc nhat dang danh quai can duong/B.
    if (c.phase="CHECK" && c.resumeAfterItemV2026!="")
    {
        resumeV2026 := c.resumeAfterItemV2026,c.resumeAfterItemV2026 := ""
        if (resumeV2026="ROAD_ATTACK" || resumeV2026="ATTACK_FIRST"
            || resumeV2026="ATTACK_MORE")
        {
            c.phase := resumeV2026
            c.attackEmptyCountV906 := 0,c.attackEmptyAtV906 := 0
            PortalLogWriteV66("BC_ITEM_RESUME phase=" . c.phase . " row=" . c.row)
            return false
        }
        if (resumeV2026="MOVE")
        {
            c.phase := "MOVE"
            PortalLogWriteV66("BC_ITEM_RESUME phase=MOVE goal="
                . (IsObject(c.forwardV756) ? c.forwardV756.row : 0))
            return true
        }
    }
    ; MOVE DONE: luong chinh kiem tra input mo cong.
    ; Diem N: QUET DANH SACH ROI MO CONG, KHONG DANH LAI SAU CONG.
    ; Diem N+1: quet sach quai quanh diem roi moi buff.
    if (c.phase="MOVE_DONE")
    {
        ; V991: MOVE DONE chi duoc giao cho luong chinh, khong cho callback phu tieu thu.
        if (!mainTurnV768)
            return true
        if (c.moveStateV905!="DONE" || c.moveResultV905!="ARRIVED")
            return true
        ; Danh dau dung DONG DICH C (khong dung dong xuat phat B).
        CoordCastMarkV50(c.row)
        if (coordCastPendingV50 && portalCastKeyV50!="")
            PortalLogWriteV66("BC_MOVE_DONE_MAIN row=" . c.row
                . " portal=YES next=NORMAL_ATTACK_CLEAR_THEN_PORTAL")
        if (coordCastPendingV50 && portalCastKeyV50="")
            coordCastPendingV50 := false
        pendingV998 := portalBuffDeferredV998
        if (IsObject(pendingV998) && pendingV998.pid=pid && pendingV998.route=c.route
            && pendingV998.epoch=c.epoch && pendingV998.row=c.row)
        {
            ; Diem N+1: DANH TRUOC, BUFF SAU. Khong buff qua co pending thuong.
            pestiPointPendingV28 := false,lastAttackPendingV20 := false
            PortalLogWriteV66("BC_PORTAL_BUFF_NEXT_ARRIVED row=" . c.row . " next=SCAN_ATTACK_THEN_BUFF")
        }
        c.phase := "ATTACK_FIRST"
        PortalLogWriteV66("BC_MOVE_DONE_MAIN row=" . c.row
            . " portal=NO next=NORMAL_MONSTER_SCAN")
        return false
    }
    ; V1002: chi luong chinh sau khi danh rong xac nhan moi mo cong tai N.
    if (c.phase="CHECK" && c.portalCastReadyV1002)
    {
        c.portalCastReadyV1002 := false
        if (coordCastPendingV50 && coordCastLastRowV50=c.row && portalCastKeyV50!="")
        {
            c.phase := "PORTAL_CAST"
            PortalLogWriteV66("BC_PORTAL_AFTER_CLEAR row=" . c.row . " next=CAST_THEN_ROUTE")
            return true
        }
    }
    if (c.phase="PORTAL_CAST")
    {
        if (coordCastPendingV50)
        {
            ; Goi ham mo cong hien tai, KHONG goi tu luong MOVE.
            CoordCastTickV50(h,player,pid)
            return true
        }
        ; V1002: da danh sach TRUOC khi mo cong; khong click danh tai cho sau cong.
        ; Luong buff ngoai route neu co van giu xu ly cu.
        c.phase := IsObject(portalBuffV85) ? "PORTAL_BUFF" : "CHECK"
        PortalLogWriteV66("BC_PORTAL_CAST_FINISHED row=" . c.row . " next=" . c.phase)
        return true
    }
    if (c.phase="PORTAL_BUFF")
    {
        if (IsObject(portalBuffV85))
        {
            FarmPortalBuffTickV85(h,player,pid)
            return true
        }
        c.phase := "CHECK"
        PortalLogWriteV66("BC_PORTAL_BUFF_DONE row=" . c.row . " next=ROUTE_CHECK")
        return true
    }
    ; N+1: giu nguyen thoi diem buff, thay chuoi noi bo bang Form 1/3/5/6.
    if (c.phase="CHECK" && c.portalBuffReadyV998)
    {
        pendingV998 := portalBuffDeferredV998
        c.portalBuffReadyV998 := false
        if (IsObject(pendingV998) && pendingV998.pid=pid && pendingV998.route=c.route
            && pendingV998.epoch=c.epoch && pendingV998.row=c.row)
        {
            portalBuffDeferredV998 := false
            ; N+1 danh sach xong: bat day buff day du, co chuyen set phu/kill 1/kill 2.
            portalBuffV85 := {pid:pid,route:coordRouteV16,phase:"FORM1",buffSetPhuV1001:1,startTickV1301:A_TickCount}
            c.phase := "PORTAL_BUFF"
            PortalLogWriteV66("BC_PORTAL_BUFF_NEXT_START from=" . pendingV998.fromRow
                . " row=" . c.row . " order=ATTACK_CLEAR_THEN_BUFF_FORM1_FORM3_FORM5_FORM6")
            return true
        }
    }
    ; ITEM_ATTACK duoc quet/danh trong timer FARM voi ban kinh BK/2 quanh do.
    if (c.phase="ITEM_ATTACK" || c.phase="ATTACK" || c.phase="ATTACK_FIRST"
        || c.phase="ATTACK_MORE" || c.phase="ROAD_ATTACK")
        return false
    if (c.phase="MOVE")
    {
        ; FIX: neu B can mo cong, khong duoc vao worker MOVE va lap BLOCK mai.
        ; Quet quai da ket thuc o B; chi chuyen sang PORTAL_CAST de goi ham cast GOC.
        if (coordCastPendingV50 && coordCastLastRowV50<=c.row)
        {
            c.phase := "PORTAL_CAST",c.portalCastReadyV1002 := false
            PortalLogWriteV66("BC_PORTAL_FROM_MOVE row=" . c.row
                . " cast_mark_row=" . coordCastLastRowV50
                . " next=CoordCastTickV50 before_C", "BC_PORTAL_FROM_MOVE", 300)
            return true
        }
        ; Giu cycle B->C va dich C trong toan bo qua trinh di + xet ket.
        if (!mainTurnV768)
            return true
        ; Den C thi nhan C, giao cho luong danh BK tai C (khong bo qua diem).
        ; Neu packet/remote dispatch dang ban nhung da gan C, van bao DONE.
        if (IsObject(c.forwardV756)
            && MonsterBossProbeReadV1(h,D2ReadU32(h,player+0x2C),0x20,movePbV991)
            && CoordLevelV14(h,NumGet(movePbV991,0x1C,"UInt"))=c.level
            && FarmCenterArrivedV756(NumGet(movePbV991,2,"UShort"),NumGet(movePbV991,6,"UShort")
                ,c.forwardV756.x,c.forwardV756.y))
        {
            FarmCenterAdvanceV756(h,player,pid,c,NumGet(movePbV991,2,"UShort"),NumGet(movePbV991,6,"UShort"))
            return true
        }
        ; Trong khi di: quet BK quanh nhan vat truoc MOI lenh di chuyen.
        ; Gap quai -> khoa tam tai vi tri nhan vat, dung di va danh het.
        roadScanV2026 := FarmApproachScanV722(h,player,pid,true)
        if (!IsObject(roadScanV2026) || !roadScanV2026.complete)
        {
            PortalLogWriteV66("BC_MOVE_SCAN_WAIT row=" . c.row
                . " reason=MONSTER_SCAN_INCOMPLETE", "BC_MOVE_SCAN_WAIT", 1000)
            return true
        }
        if (IsObject(roadScanV2026.target))
        {
            c.roadX_V2026 := roadScanV2026.x,c.roadY_V2026 := roadScanV2026.y
            c.phase := "ROAD_ATTACK",c.attackEmptyCountV906 := 0,c.attackEmptyAtV906 := 0
            c.attacked := false
            if (IsObject(coordRouteV16) && coordRouteV16.pid=pid)
                coordRouteV16.stuckProbe := false,coordRouteV16.escapeV84 := false
            MovementCtrlSetV78(false,0,"FarmRoadEncounterV2026")
            PortalLogWriteV66("BC_ROAD_ATTACK center=" . c.roadX_V2026 . "," . c.roadY_V2026
                . " uid=" . roadScanV2026.target.uid . " goal="
                . (IsObject(c.forwardV756) ? c.forwardV756.row : 0)
                . " next=KILL_ALL_THEN_RESUME_MOVE")
            return false  ; Tra quyen cho CUNG bo quet/danh Form6 chinh o tick nay.
        }
        ; Khong co quai tren duong moi di tiep; khong tick buff/cong tai MOVE.
        if (!FarmCenterRoutePrepareV910(pid,c))
        {
            PortalLogWriteV66("BC_MOVE_PREPARE_FAIL row=" . c.row
                . " goal=" . (IsObject(c.forwardV756) ? c.forwardV756.row : 0)
                . " phase=MOVE next=CHECK", "BC_MOVE_PREPARE_FAIL", 1000)
            c.phase := "CHECK"
            return true
        }
        ; MOVE chi di chuyen; danh quai duoc xu ly tai tam Farm chinh.
        ; Move-stuck recovery is handled by CoordStuckTickV84 in the MOVE worker.
        ; Chi them log de xac dinh timer MOVE co chay va co gui lenh hay khong.
        PortalLogWriteV66("BC_MOVE_TICK B=" . c.row
            . " C=" . (IsObject(c.forwardV756) ? c.forwardV756.row : 0)
            . " phase=" . c.phase, "BC_MOVE_TICK", 1000)
        ; Tren duong da quet rong moi di; vao BK C se doi tam sang C de danh.
        moveSentV1113 := FarmCenterWalkResumeV765(pid,c)
        if (!moveSentV1113 && c.phase="MOVE")
            PortalLogWriteV66("BC_MOVE_WAIT_DISPATCH B=" . c.row
                . " C=" . (IsObject(c.forwardV756) ? c.forwardV756.row : 0)
                . " reason=MOVE_WORKER_RETURN_FALSE", "BC_MOVE_WAIT_DISPATCH", 1000)
        return true
    }
    if (c.phase!="CHECK" && c.phase!="RETURN")
        return FarmCenterStepV766(h,player,pid)
    ; CHECK chua xu ly xong (vi packet/buff dang ban) thi GIU CHECK.
    ; Chi FarmFlowRouteAdvanceV900 duoc quyen doi thanh MOVE sau khi da xac dinh C.
    return FarmCenterStepV766(h,player,pid)
}

FarmCenterStepV766(h,player,pid)
{
    global farmCenterCycleV741,farmScanListV682,farmScanSelectedV682
    global xRunning,zRunning,gameItemActionOwner,farmBuffExclusiveV621,buffSequenceRunningV555
    global monsterCombatUidV45,monsterRoadAreaV51,monsterChaseV44,teleportIntervalSecV56
    global farmItemLockV625,pickupRoundResetV1,pickupImageOn,pickupRadius
    if (!FarmCenterPendingV741(pid))
        return false
    c := farmCenterCycleV741
    if (c.phase="PICKUP_BUSY")
        return FarmFlowPickupBusyV900(pid,c)
    if (c.phase="ITEM_MOVE" && (xRunning || zRunning || gameItemActionOwner!=""
        || farmBuffExclusiveV621 || buffSequenceRunningV555))
        PortalLogWriteV66("BC_ITEM_MOVE_WAIT owner=" . gameItemActionOwner
            . " buff=" . (xRunning || zRunning || farmBuffExclusiveV621 || buffSequenceRunningV555)
            . " reason=CONTROL_BUSY","BC_ITEM_MOVE_WAIT",1000)
    if (c.phase="ATTACK" || xRunning || zRunning || gameItemActionOwner!=""
        || farmBuffExclusiveV621 || buffSequenceRunningV555)
        return true
    if (!MonsterBossProbeReadV1(h,D2ReadU32(h,player+0x2C),0x20,pp))
        return true
    level := CoordLevelV14(h,NumGet(pp,0x1C,"UInt")),mode := D2ReadU32(h,player+0x10)
    if (level!=c.level || mode=0 || mode=17 || FarmReviveTownLevelV295(level))
    {
        farmCenterCycleV741 := false
        return false
    }
    if (!FarmAttackReleaseWaitV15() || !AutoMonsterPacketCleanupV1() || RemoteThreadBusyV740(pid))
    {
        if (c.phase="RETURN" && farmCenterCycleV741=c)
            farmCenterCycleV741 := false
        return true
    }
    if (!FarmCenterPendingV741(pid) || farmCenterCycleV741!=c)
        return true
    if (c.phase="ITEM_MOVE")
        return FarmFlowApproachItemV910(h,player,pid,c)
    if (c.phase="PICKUP")
        return FarmFlowApproachPickupV900(h,player,pid,c)
    return FarmFlowRouteAdvanceV900(h,player,pid,c)
}

; Luong nhat rieng chi chay trong PICKUP_BUSY; het nhat thi tra lai timer farm.
FarmPickupHandoffTimerV901:
if (farmUserPausedV2026)
    return
if (farmManualStoppedV2026)
{
    SetTimer, FarmPickupHandoffTimerV901, Off
    return
}
if (!autoMonsterAttackOn)
{
    SetTimer, FarmPickupHandoffTimerV901, Off
    return
}
handPidV901 := D2GetActiveGamePidV95()
if (!handPidV901 || !FarmCenterPendingV741(handPidV901)
    || farmCenterCycleV741.phase!="PICKUP_BUSY")
{
    SetTimer, FarmPickupHandoffTimerV901, Off
    if (autoMonsterAttackOn)
        SetTimer, AutoMonsterAttackTimer, 250
    return
}
handoffCycleV905 := farmCenterCycleV741
FarmFlowPickupBusyV900(handPidV901,handoffCycleV905)
if (IsObject(handoffCycleV905) && handoffCycleV905.phase!="PICKUP_BUSY")
{
    if (handoffCycleV905.pickupStateV905!="DONE")
        handoffCycleV905.pickupResultV905 := "INTERRUPTED"
    PortalLogWriteV66("FARM_PICKUP_DONE result=" . handoffCycleV905.pickupResultV905, "FARM_PICKUP_DONE", 500)
}
if (!FarmCenterPendingV741(handPidV901)
    || farmCenterCycleV741.phase!="PICKUP_BUSY")
{
    SetTimer, FarmPickupHandoffTimerV901, Off
    if (autoMonsterAttackOn)
        SetTimer, AutoMonsterAttackTimer, 250
}
return

FarmFlowPickupBusyV900(pid,c)
{
    global farmManualStoppedV2026
    if (farmManualStoppedV2026)
        return false
    global farmItemLockV625,pickupImageOn,pickupFarmWorkV75,pickupTimerBusy,gameItemActionOwner
    if (!pickupImageOn || !Stage2PickupEnabledV9())
    {
        farmItemLockV625 := false
        c.pickupStateV905 := "DONE",c.pickupResultV905 := "DISABLED"
        c.phase := "CHECK"
        return true
    }
    ; Da ban giao: dung ham nhat chung, khong lap lai dieu kien combat / buff / remote.
    ; Ham FarmPickupFirstV75 tu quan ly tranh trung thao tac vat pham.
    workingV905 := FarmPickupFirstV75()
    if (workingV905 || pickupFarmWorkV75 || pickupTimerBusy || gameItemActionOwner!="")
    {
        c.pickupIdleAtV905 := 0
        c.pickupActiveSeenV905 := true
        return true
    }
    ; CHI timer nhat duoc phat DONE tu D2ScanRoomItemsV61 khi da quet va xu ly queue.
    ; Khong tu suy dien DONE vi ham nhat tam thoi tra false.
    return true
}

; Giao tiep luong di chuyen -> farm: DONE chi khi da den dich hoac thoat loi.
; Khong suy dien DONE tu ket qua true/false cua lenh phat di chuyen.
FarmPickupMoveResultV905(h,ByRef pp,pid,level,px,py)
{
    global farmItemLockV625,pickupRadius
    area := farmItemLockV625
    if (!IsObject(area) || area.pid!=pid || area.level!=level)
        return {state:"DONE",result:"TARGET_LOST"}
    x := area.pickupX>0 ? area.pickupX : area.x
    y := area.pickupY>0 ? area.pickupY : area.y
    distanceSqV1185 := (px-x)**2+(py-y)**2
    if (!area.startedAtV1602)
        area.startedAtV1602 := A_TickCount
    ; Neu bi ket, FarmItemReturnV648 goi truc tiep CoordStuckStartV84.
    ; Khong co nhanh FENCE_PICKUP cu khi item van dang o xa.
    pickupArrivalRadiusV1302 := Min(9,Max(1,pickupRadius))
    if (distanceSqV1185<=pickupArrivalRadiusV1302**2)
    {
        area.returnGoalV655 := false
        return {state:"DONE",result:"ARRIVED"}
    }
    FarmItemReturnV648(h,pp,pid,level,px,py)
    ; Duong di chua toi item thi khong giao nhat tu xa. BLOCKED duoc
    ; FarmItemReturnV648 khoi dong lai thoat ket sau cooldown ngan.
    return {state:"RUNNING",result:"MOVE_OR_DIRECT_ESCAPE"}
}

; B->C / ITEM_MOVE: toi tam do -> nhat chung truc tiep, khong danh quanh do.
; FarmItemReturnV648 goi xet ket di chuyen va quay lai nhat sau khi thoat.
FarmFlowApproachItemV910(h,player,pid,c)
{
    global farmManualStoppedV2026
    if (farmManualStoppedV2026)
        return false
    global farmItemLockV625,monsterCombatUidV45,monsterRoadAreaV51,monsterChaseV44
    if (!IsObject(farmItemLockV625) || farmItemLockV625.pid!=pid
        || farmItemLockV625.level!=c.level)
    {
        c.phase := "CHECK"
        PortalLogWriteV66("BC_ITEM_MOVE_CANCEL reason=TARGET_LOST next=C")
        return true
    }
    if (!MonsterBossProbeReadV1(h,D2ReadU32(h,player+0x2C),0x20,pp)
        || CoordLevelV14(h,NumGet(pp,0x1C,"UInt"))!=c.level)
        return true
    px := NumGet(pp,2,"UShort"),py := NumGet(pp,6,"UShort")
    result := FarmPickupMoveResultV905(h,pp,pid,c.level,px,py)
    c.moveStateV905 := result.state,c.moveResultV905 := result.result
    if (result.state!="DONE")
        return true
    if (result.result!="ARRIVED")
    {
        ; Loi khac: khong treo tuyen C.
        farmItemLockV625 := false
        c.phase := "CHECK"
        PortalLogWriteV66("BC_ITEM_MOVE_DONE result=" . result.result . " next=C")
        return true
    }
    ; Chi nhat khi da THUC SU den trong ban kinh item.
    c.fencePickupV1185 := false
    ; Den do la nhat NGAY: khong quet/danh quai BK/2 quanh vat pham nua.
    ; Giu lock do va goal C cho den khi ham nhat chung bao DONE.
    c.itemTargetV918 := {pid:pid,player:farmItemLockV625.player,level:c.level
        ,x:farmItemLockV625.x,y:farmItemLockV625.y}
    monsterCombatUidV45 := 0,monsterRoadAreaV51 := false,monsterChaseV44 := false
    c.phase := "PICKUP",c.attackStateV905 := "DONE",c.attackResultV905 := "ITEM_COMBAT_SKIPPED"
    c.attackEmptyCountV906 := 0,c.attackEmptyAtV906 := 0
    PortalLogWriteV66("BC_ITEM_ARRIVED center=" . farmItemLockV625.x . "," . farmItemLockV625.y
        . " next=PICKUP_DIRECT no_item_combat=1")
    ; Ban giao ngay cho nhat chung, khong de timer route/tele chen giua.
    return FarmFlowApproachPickupV900(h,player,pid,c)
}

FarmFlowApproachPickupV900(h,player,pid,c)
{
    global farmManualStoppedV2026
    if (farmManualStoppedV2026)
        return false
    global farmItemLockV625,monsterCombatUidV45,monsterRoadAreaV51,monsterChaseV44,pickupRoundResetV1,pickupImageOn
    if (c.attackStateV905!="DONE" || !Stage2PickupEnabledV9() || !pickupImageOn || !IsObject(farmItemLockV625))
    {
        farmItemLockV625 := false
        c.phase := "CHECK"
        return true
    }
    if (!MonsterBossProbeReadV1(h,D2ReadU32(h,player+0x2C),0x20,pp)
        || CoordLevelV14(h,NumGet(pp,0x1C,"UInt"))!=c.level)
        return true
    px := NumGet(pp,2,"UShort"),py := NumGet(pp,6,"UShort")
    if (IsObject(farmItemLockV625) && farmItemLockV625.pid=pid
        && farmItemLockV625.level=c.level && !c.fencePickupV1185)
    {
        moveResultV905 := FarmPickupMoveResultV905(h,pp,pid,c.level,px,py)
        c.moveStateV905 := moveResultV905.state
        c.moveResultV905 := moveResultV905.result
        if (moveResultV905.state!="DONE")
            return true
        if (moveResultV905.result!="ARRIVED")
        {
            ; Ket/loi cung DONE, nhung khong ban giao nhat sai vi tri.
            PortalLogWriteV66("FARM_ITEM_MOVE_DONE result=" . moveResultV905.result, "FARM_ITEM_MOVE_DONE", 500)
            farmItemLockV625 := false
            c.phase := "CHECK"
            return true
        }
    }
    if (!IsObject(farmItemLockV625))
    {
        c.moveStateV905 := "DONE", c.moveResultV905 := "TARGET_LOST"
        c.phase := "CHECK"
        return true
    }
    ; Chi sau MOVE DONE ARRIVED moi giao quyen nhat.
    monsterCombatUidV45 := 0,monsterRoadAreaV51 := false,monsterChaseV44 := false
    c.phase := "PICKUP_BUSY",c.pickupPass := 0
    c.pickupStateV905 := "RUNNING",c.pickupResultV905 := ""
    pickupRoundResetV1 := true
    SetTimer, AutoMonsterAttackTimer, Off
    FarmAttackHoldReleaseV15()
    SetTimer, FarmPickupHandoffTimerV901, 20
    PortalLogWriteV66("FARM_PICKUP_HANDOFF phase=PICKUP_BUSY attack_timer=OFF pickup_timer=ON"
        . " fence=" . (c.fencePickupV1185 ? 1 : 0)
        . " next=" . (c.fencePickupV1185 ? "TRY_PICK_THEN_TELE_IF_GROUND" : "NORMAL_PICKUP")
        ,"FARM_PICKUP_HANDOFF",500)
    return FarmFlowPickupBusyV900(pid,c)
}

FarmFlowRouteAdvanceV900(h,player,pid,c)
{
    global farmCenterCycleV741,coordCastPendingV50,coordCastLastRowV50,portalCastKeyV50
    ; Sau scan B, portal tai B la thao tac BAT BUOC truoc khi tien ve C.
    if (c.phase="CHECK" && coordCastPendingV50 && coordCastLastRowV50<=c.row)
    {
        c.phase := "PORTAL_CAST",c.portalCastReadyV1002 := false
        PortalLogWriteV66("BC_PORTAL_CHECK_TO_CAST row=" . c.row
            . " cast_mark_row=" . coordCastLastRowV50
            . " next=CoordCastTickV50", "BC_PORTAL_CHECK_TO_CAST", 300)
        return true
    }
    if (!MonsterBossProbeReadV1(h,D2ReadU32(h,player+0x2C),0x20,pp)
        || CoordLevelV14(h,NumGet(pp,0x1C,"UInt"))!=c.level)
        return true
    px := NumGet(pp,2,"UShort"),py := NumGet(pp,6,"UShort")
    c.radius := Max(1,MonsterRadiusGetV239())
    if (!FarmCenterGoalValidV756(c))
    {
        c.forwardV756 := false,c.phase := "CHECK",c.teleAt := 0
        return true
    }
    if (!IsObject(c.forwardV756))
        c.forwardV756 := FarmCenterNextV756(c)
    if (IsObject(c.forwardV756))
    {
        goal := c.forwardV756
        ; Khong bo qua C: bat buoc vao ban kinh C va quet danh tai C.
        if (FarmCenterArrivedV756(px,py,goal.x,goal.y))
        {
            ; V1190: hai dòng cùng tọa độ -> nhận đến C, tăng dòng vàng,
            ; KHÔNG coi C trùng B là hết map.
            if (goal.x=c.x && goal.y=c.y)
                PortalLogWriteV66("BC_ROUTE_SAME_COORD from_row=" . c.row
                    . " to_row=" . goal.row
                    . " next=ADVANCE_TO_FOLLOWING_ROW", "BC_ROUTE_SAME_COORD", 300)
            FarmCenterAdvanceV756(h,player,pid,c,px,py)
            return true
        }
        c.phase := "MOVE"
        return true
    }
    ; V1190: Không có điểm tiếp theo chưa có nghĩa là hết tuyến.
    ; Chỉ cho DONE khi đúng dòng cuối. Lỗi map / trùng tọa độ / thiếu dữ liệu
    ; phải giữ farm chờ xử lý, tuyệt đối không Save&Exit ở giữa tuyến.
    pointsV1190 := FarmRoutePointsV724()
    countV1190 := IsObject(pointsV1190) ? pointsV1190.Length() : 0
    if (!countV1190 || c.row!=countV1190)
    {
        PortalLogWriteV66("BC_ROUTE_NEXT_BLOCKED row=" . c.row
            . " total=" . countV1190 . " next_row=" . (c.row+1)
            . " reason=NOT_REAL_ROUTE_END action=KEEP_FARM_NO_GD3"
            , "BC_ROUTE_NEXT_BLOCKED", 2000)
        return true
    }
    ; Điểm cuối thực sự: đã đánh sạch và nhặt xong tại dòng cuối.
    global coordRouteV16
    r := coordRouteV16
    if (IsObject(r) && r.pid=pid && c.route=r && !FarmItemRoutePausedV903(pid))
    {
        r.anchor := c.row,r.yellow := c.row,r.next := c.row
        r.combatRowV627 := 0,r.phase := "DONE",r.forwardFloorV303 := c.row
        r.escapeV84 := false,r.stuckProbe := false,r.battlePending := false
        PortalLogWriteV66("BC_ROUTE_DONE last_row=" . c.row . " total=" . countV1190 . " next=GD3")
        CoordBoxRefreshV15()
    }
    farmCenterCycleV741 := false
    if (IsObject(r) && r.pid=pid && r.phase="DONE")
        MapStage2RouteFinishV185()
    return false
}


FarmPlayerTargetValidV741(h,player,unit,uid,pid)
{
    if (!MonsterBossProbeReadV1(h,D2ReadU32(h,player+0x2C),0x20,pp)
        || !MonsterBossProbeReadV1(h,unit,0x30,ub) || NumGet(ub,0,"UInt")!=1 || NumGet(ub,12,"UInt")!=uid
        || NumGet(ub,16,"UInt")=0 || NumGet(ub,16,"UInt")=12
        || !MonsterBossProbeReadV1(h,NumGet(ub,0x2C,"UInt"),0x20,mp))
        return false
    level := CoordLevelV14(h,NumGet(pp,0x1C,"UInt"))
    radius := Max(1,MonsterRadiusGetV239())
    return level && CoordLevelV14(h,NumGet(mp,0x1C,"UInt"))=level
        && (NumGet(mp,2,"UShort")-NumGet(pp,2,"UShort"))**2+(NumGet(mp,6,"UShort")-NumGet(pp,6,"UShort"))**2<=radius**2
}


FarmCenterRoutePrepareV910(pid,c)
{
    global coordRouteV16,coordNoTargetSinceV14
    global monsterCombatUidV45,monsterRoadAreaV51,monsterChaseV44
    if (!IsObject(c) || !FarmCenterGoalValidV756(c) || !IsObject(c.forwardV756)
        || !IsObject(coordRouteV16) || coordRouteV16!=c.route
        || coordRouteV16.pid!=pid)
        return false
    r := coordRouteV16,goal := c.forwardV756
    if (r.combatRowV627=c.row || r.anchor!=c.row || r.next!=goal.row)
    {
        r.combatRowV627 := 0,r.anchor := c.row,r.next := goal.row
        r.phase := "NEXT",r.forwardFloorV303 := c.row
        r.lastDispatch := 0,r.bestDist := -1,r.tries := 0
        r.legRow := 0,r.moveProbe := false,r.stuckProbe := false,r.escapeV84 := false
        r.battlePending := false,r.firstMoveAttempted := false
        coordNoTargetSinceV14 := A_TickCount-250
        monsterCombatUidV45 := 0,monsterRoadAreaV51 := false,monsterChaseV44 := false
        PortalLogWriteV66("BC_MOVE_START B=" . c.row . " C=" . goal.row . " target=" . goal.x . "," . goal.y)
    }
    return true
}


; V940 - Uu tien teleport den dich C / vat pham neu cooldown san sang,
; neu khong gui duoc thi de NativeMovePointV14 di bo va CoordStuckTickV84 xu ly ket.
FarmBCPreferredTeleportV940(h,ByRef pb,pid,c,goal)
{
    global teleportKeyV55,teleportIntervalSecV56,coordManualTeleLastV296
    global coordRouteV16,backgroundAimV64,coordCastPendingV50,coordCastLastRowV50,portalBuffV85
    global coordNoTargetSinceV14
    castBlocksV1172 := coordCastPendingV50 && IsObject(c) && coordCastLastRowV50<=c.row
    if (!IsObject(c) || !IsObject(goal) || (c.phase!="MOVE" && c.phase!="ITEM_MOVE")
        || teleportKeyV55="" || IsObject(portalBuffV85) || castBlocksV1172)
        return false
    if (!IsGameActive() || D2GetActiveGamePidV95()!=pid || !NativeDispatchReadyV10(true)
        || !AutoMonsterPacketCleanupV1())
        return false
    if (CoordLevelV14(h,NumGet(pb,0x1C,"UInt"))!=goal.level || goal.level=163)
        return false
    px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort")
    dx := goal.x-px,dy := goal.y-py
    distV940 := Sqrt(dx*dx+dy*dy)
    if (distV940<1 || FarmCenterArrivedV756(px,py,goal.x,goal.y))
        return false
    lastV940 := Max(c.lastTeleV940+0,coordManualTeleLastV296+0
        ,IsObject(coordRouteV16) ? coordRouteV16.lastTeleport+0 : 0)
    cdV940 := Max(1,teleportIntervalSecV56)*1000
    ; Tele chi co tac dung neu sau lan truoc nhan vat tien gan den C.
    ; Khong tin vao KEYDOWN_QUEUED nhu mot xac nhan da dich chuyen.
    if (IsObject(c.teleProbeV2026) && A_TickCount-c.teleProbeV2026.at>=350)
    {
        prevV2026 := c.teleProbeV2026
        c.teleProbeV2026 := false
        if (prevV2026.goalRow=goal.row && A_TickCount-prevV2026.at<=5000
            && distV940>=prevV2026.dist-2)
        {
            c.teleAvoidUntilV2026 := A_TickCount+6500
            PortalLogWriteV66("BC_TELE_NO_PROGRESS row=" . goal.row
                . " before=" . Round(prevV2026.dist,1) . " after=" . Round(distV940,1)
                . " fallback=NATIVE_MOVE_AND_STUCK retry_after_ms=6500")
        }
        else if (prevV2026.goalRow=goal.row && distV940<prevV2026.dist-2)
            c.teleAvoidUntilV2026 := 0
    }
    ; One preferred Tele per leg. Never use a cooldown expiry as a reason to Tele again.
    if (c.preferredTeleRowV2026=goal.row || IsObject(c.teleWalkPendingV2026))
        return false
    if (c.teleAvoidUntilV2026 && A_TickCount<c.teleAvoidUntilV2026)
        return false
    if (lastV940 && A_TickCount-lastV940<cdV940)
        return false
    if (!FarmAttackHoldReleaseWaitV940())
        return false
    baseV940 := D2GetModuleBaseV35(pid,"D2Client.dll")
    livePlayerV940 := baseV940 ? D2ReadU32(h,baseV940+0x11BBFC) : 0
    pathV940 := livePlayerV940 ? D2ReadU32(h,livePlayerV940+0x2C) : 0
    if (!pathV940 || !MonsterBossProbeReadV1(h,pathV940,0x20,pb)
        || CoordLevelV14(h,NumGet(pb,0x1C,"UInt"))!=goal.level)
        return false
    ; Doc lai vi tri sau thao tac release de tranh nham Tele tu vi tri cu.
    px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort")
    dx := goal.x-px,dy := goal.y-py
    distV940 := Sqrt(dx*dx+dy*dy)
    if (distV940<1 || FarmCenterArrivedV756(px,py,goal.x,goal.y))
        return false
    viewV940 := AutoMonsterAttackViewV1(h,baseV940,GameTargetHwndV63(),pathV940)
    if (!IsObject(viewV940))
        return false
    sxV940 := (dx-dy)*16,syV940 := (dx+dy)*8
    ; FIX: dist trong ma cu chua duoc gan -> huong/diem nham Tele khong hop le.
    reachV940 := Min(1,Max(1,MonsterRadiusGetV239())/distV940)
    axV940 := Max(16,Min(viewV940.gw-16,NumGet(pb,8,"Int")-viewV940.ox+sxV940*reachV940))
    ayV940 := Max(32,Min(viewV940.gh-64,NumGet(pb,12,"Int")-viewV940.oy+syV940*reachV940))
    try
    {
        if (!GameTargetAimV63(Round(axV940*viewV940.cw/viewV940.gw),Round(ayV940*viewV940.ch/viewV940.gh)))
            return false
        Sleep, 30
        if (!NativeDispatchReadyV10(true) || D2GetActiveGamePidV95()!=pid)
            return false
        sentV940 := BuffCheckedSendV29(teleportKeyV55)
        if (sentV940)
        {
            c.lastTeleV940 := A_TickCount,coordManualTeleLastV296 := A_TickCount
            c.teleProbeV2026 := {at:A_TickCount,dist:distV940,goalRow:goal.row}
            c.teleWalkPendingV2026 := {row:goal.row,at:A_TickCount,attempts:0}
            c.preferredTeleRowV2026 := goal.row
            if (IsObject(coordRouteV16) && coordRouteV16.pid=pid)
            {
                coordRouteV16.lastTeleport := A_TickCount
                coordRouteV16.stuckProbe := false,coordRouteV16.escapeV84 := false
                coordRouteV16.lastDispatch := 0,coordRouteV16.firstMoveAttempted := false
                coordRouteV16.teleRequiresWalkV2026 := true
                coordRouteV16.teleWalkCommandAtV2026 := 0
            }
            ; Do not start the stuck clock before a movement command is issued.
            coordNoTargetSinceV14 := A_TickCount-250
            PortalLogWriteV66("BC_TELE_SEND phase=" . c.phase . " destination=" . goal.x . "," . goal.y
                . " from=" . px . "," . py . " distance=" . Round(distV940,1)
                . " reach=" . Round(reachV940,3)
                . " aim=" . Round(axV940*viewV940.cw/viewV940.gw) . "," . Round(ayV940*viewV940.ch/viewV940.gh)
                . " cd_ms=" . cdV940 . " next=TELE_SETTLE_THEN_WALK")
        }
        return sentV940
    }
    finally
        backgroundAimV64 := false
}

FarmAttackHoldReleaseWaitV940()
{
    return FarmAttackHoldReleaseV15() && FarmAttackReleaseWaitV15()
}

; Route Tele gate: a queued Tele is NOT successful walking.
; Only a dispatched move, followed by >=2 tiles of real displacement, can release the Tele gate.
FarmTeleWalkDispatchedV2026(r,px,py)
{
    if (!IsObject(r) || !r.teleRequiresWalkV2026)
        return false
    if (!r.teleWalkCommandAtV2026)
    {
        r.teleWalkCommandAtV2026 := A_TickCount
        r.teleWalkStartXV2026 := px,r.teleWalkStartYV2026 := py
        PortalLogWriteV66("BC_TELE_WALK_DISPATCH row=" . r.next
            . " from=" . px . "," . py . " next=OBSERVE_WALK")
    }
    return true
}

FarmTeleWalkObserveV2026(r,px,py)
{
    if (!IsObject(r) || !r.teleRequiresWalkV2026 || !r.teleWalkCommandAtV2026)
        return false
    movedV2026 := Sqrt((px-r.teleWalkStartXV2026)**2+(py-r.teleWalkStartYV2026)**2)
    if (movedV2026<2)
        return false
    r.teleRequiresWalkV2026 := false,r.teleWalkCommandAtV2026 := 0
    PortalLogWriteV66("BC_TELE_WALK_CONFIRMED row=" . r.next
        . " moved=" . Round(movedV2026,1) . " now=" . px . "," . py)
    return true
}

FarmCenterWalkResumeV765(pid,c)
{
    global coordRouteV16,autoMonsterAttackOn,farmRunEpochV535
    global coordNoTargetSinceV14,monsterCombatUidV45,portalBackPendingV74,chaseCheckSecV9
    if (FarmItemRoutePausedV903(pid))
    {
        PortalLogWriteV66("BC_MOVE_BLOCK reason=ITEM_PRIORITY", "BC_MOVE_BLOCK", 1000)
        return false
    }
    global coordCastPendingV50,coordCastLastRowV50,portalBuffV85,portalExitPendingV69,farmBuffExclusiveV621,buffSequenceRunningV555
    FarmPortalBuffDeadlineV1301(pid,"MOVE_WORKER")
    castBlocksV1172 := coordCastPendingV50 && IsObject(c) && coordCastLastRowV50<=c.row
    if (!autoMonsterAttackOn || !IsObject(c) || c.pid!=pid || c.epoch!=farmRunEpochV535
        || c.route!=coordRouteV16 || !FarmCenterGoalValidV756(c)
        || D2GetActiveGamePidV95()!=pid || !NativeDispatchReadyV10(true)
        || RemoteThreadBusyV740(pid) || castBlocksV1172 || IsObject(portalBuffV85)
        || IsObject(portalExitPendingV69) || farmBuffExclusiveV621 || buffSequenceRunningV555)
    {
        whyV1113 := "SEND_OR_REMOTE_GUARD"
        if (!autoMonsterAttackOn)
            whyV1113 := "FARM_OFF"
        else if (!IsObject(c))
            whyV1113 := "CYCLE_MISSING"
        else if (c.pid!=pid || c.epoch!=farmRunEpochV535 || c.route!=coordRouteV16)
            whyV1113 := "CYCLE_ID_MISMATCH"
        else if (!FarmCenterGoalValidV756(c))
            whyV1113 := "GOAL_INVALID"
        else if (D2GetActiveGamePidV95()!=pid)
            whyV1113 := "GAME_PID_CHANGED"
        else if (castBlocksV1172)
            whyV1113 := "PORTAL_CAST_PENDING"
        else if (IsObject(portalBuffV85))
            whyV1113 := "PORTAL_BUFF_BUSY"
        else if (IsObject(portalExitPendingV69))
            whyV1113 := "PORTAL_EXIT_BUSY"
        else if (farmBuffExclusiveV621 || buffSequenceRunningV555)
            whyV1113 := "BUFF_EXCLUSIVE"
        else if (!NativeDispatchReadyV10(true))
            whyV1113 := "NATIVE_DISPATCH_NOT_READY"
        PortalLogWriteV66("BC_MOVE_BLOCK reason=" . whyV1113
            . " cast=" . coordCastPendingV50 . " buff=" . IsObject(portalBuffV85)
            . " exclusive=" . farmBuffExclusiveV621 . " sequence=" . buffSequenceRunningV555
            . " cast_row=" . coordCastLastRowV50 . " B=" . (IsObject(c) ? c.row : 0)
            . " pid=" . pid, "BC_MOVE_BLOCK", 1000)
        return false
    }
    base := D2GetModuleBaseV35(pid,"D2Client.dll"),h := base ? D2OpenProcess(pid) : 0
    if (!h)
    {
        PortalLogWriteV66("BC_MOVE_BLOCK reason=OPEN_PROCESS_FAIL", "BC_MOVE_BLOCK", 1000)
        return false
    }
    try
    {
        player := D2ReadU32(h,base+0x11BBFC)
        if (!player || !MonsterBossProbeReadV1(h,D2ReadU32(h,player+0x2C),0x20,pb)
            || CoordLevelV14(h,NumGet(pb,0x1C,"UInt"))!=c.level
            || !FarmAttackReleaseWaitV15() || !AutoMonsterPacketCleanupV1())
        {
            PortalLogWriteV66("BC_MOVE_BLOCK reason=PLAYER_PATH_LEVEL_OR_PACKET_BUSY", "BC_MOVE_BLOCK", 1000)
            return false
        }
        px := NumGet(pb,2,"UShort"),py := NumGet(pb,6,"UShort")
        ; Giu dich C trong suot qua trinh di; khong tu nhay qua D.
        if (IsObject(c.forwardV756)
            && FarmCenterArrivedV756(px,py,c.forwardV756.x,c.forwardV756.y))
        {
            ; V948: da o gan tam C thi khong phat them tele/di bo.
            ; Chi cho quy trinh cast/buff va ban giao quet quai tai C.
            if (FarmCenterAdvanceV756(h,player,pid,c,px,py))
                return true
            PortalLogWriteV66("BC_ARRIVAL_WAIT row=" . c.forwardV756.row
                . " xy=" . px . "," . py . " goal=" . c.forwardV756.x . "," . c.forwardV756.y
                . " cast_pending=" . coordCastPendingV50 . " portal_buff=" . IsObject(portalBuffV85)
                . " reason=WAIT_FINISH_HANDOFF", "BC_ARRIVAL_WAIT", 1000)
            return true
        }
        CoordRouteObserveV18(h,pb,pid)
        rWalkV2026 := coordRouteV16
        if (IsObject(rWalkV2026) && rWalkV2026.pid=pid)
            FarmTeleWalkObserveV2026(rWalkV2026,px,py)
        postTeleV2026 := c.teleWalkPendingV2026
        if (IsObject(postTeleV2026) && IsObject(c.forwardV756))
        {
            if (postTeleV2026.row!=c.forwardV756.row)
                c.teleWalkPendingV2026 := false
            else
            {
                ; Give the Tele animation a short settle period, never a stuck timeout.
                ; On every following tick, attempt the actual route move before stuck.
                if (A_TickCount-postTeleV2026.at<350)
                    return true
                walkSentV2026 := CoordMoveWhenClearV14(h,pb,pid)
                postTeleV2026.attempts++
                if (walkSentV2026)
                {
                    c.teleWalkPendingV2026 := false
                    if (IsObject(rWalkV2026) && rWalkV2026.pid=pid)
                    {
                        FarmTeleWalkDispatchedV2026(rWalkV2026,px,py)
                        rWalkV2026.stuckProbe := {x:px,y:py,since:A_TickCount
                            ,dist:Sqrt((px-c.forwardV756.x)**2+(py-c.forwardV756.y)**2)
                            ,goalRow:c.forwardV756.row}
                        rWalkV2026.firstMoveAttempted := true
                    }
                    PortalLogWriteV66("BC_TELE_WALK_RESUME row=" . c.forwardV756.row
                        . " result=MOVE_DISPATCHED next=CHECK_REAL_PROGRESS")
                }
                else
                    PortalLogWriteV66("BC_TELE_WALK_RETRY row=" . c.forwardV756.row
                        . " attempts=" . postTeleV2026.attempts
                        . " reason=MOVE_NOT_READY no_retele=1", "BC_TELE_WALK_RETRY", 1000)
                return true
            }
        }
        ; Arm the EXISTING coordinate-stuck timer from MOVE state itself.
        ; Previously it was armed only when CoordStuckMoveV392 sent a command,
        ; so repeated send failures could prevent stuck handling indefinitely.
        routeStuckV1202 := coordRouteV16
        if (IsObject(c.forwardV756) && IsObject(routeStuckV1202)
            && routeStuckV1202.phase="NEXT" && routeStuckV1202.pid=pid
            && routeStuckV1202.next=c.forwardV756.row
            && routeStuckV1202.firstMoveAttempted
            && !IsObject(routeStuckV1202.escapeV84) && !IsObject(routeStuckV1202.stuckProbe))
        {
            distStuckV1202 := Sqrt((px-c.forwardV756.x)**2+(py-c.forwardV756.y)**2)
            routeStuckV1202.stuckProbe := {x:px,y:py,since:A_TickCount
                ,dist:distStuckV1202,goalRow:routeStuckV1202.next}
            PortalLogWriteV66("BC_MOVE_STUCK_CLOCK_BEGIN row=" . c.forwardV756.row
                . " xy=" . px . "," . py . " goal=" . c.forwardV756.x . "," . c.forwardV756.y
                . " timeout_sec=" . chaseCheckSecV9,"BC_MOVE_STUCK_CLOCK_BEGIN",1000)
        }
        ; Existing teleport and move-stuck handlers stay unchanged.
        ; V948: het cooldown uu tien TELE, neu khong gui duoc moi di bo/xet ket.
        if (IsObject(c.forwardV756) && FarmBCPreferredTeleportV940(h,pb,pid,c,c.forwardV756))
            return true
        if (CoordStuckTickV84(h,pb,pid))
        {
            PortalLogWriteV66("BC_MOVE_STUCK_HANDLING row=" . (IsObject(c.forwardV756) ? c.forwardV756.row : 0), "BC_MOVE_STUCK_HANDLING", 1000)
            return true
        }
        moveOkV1113 := CoordMoveWhenClearV14(h,pb,pid)
        if (moveOkV1113 && IsObject(routeStuckV1202) && routeStuckV1202.pid=pid)
        {
            routeStuckV1202.firstMoveAttempted := true
            FarmTeleWalkDispatchedV2026(routeStuckV1202,px,py)
            if (!IsObject(routeStuckV1202.stuckProbe))
                routeStuckV1202.stuckProbe := {x:px,y:py,since:A_TickCount
                    ,dist:Sqrt((px-c.forwardV756.x)**2+(py-c.forwardV756.y)**2)
                    ,goalRow:c.forwardV756.row}
        }
        if (!moveOkV1113)
        {
            PortalLogWriteV66("BC_MOVE_NO_DISPATCH reason=ROUTE_MOVE_RETURN_FALSE"
                . " phase=" . coordRouteV16.phase . " anchor=" . coordRouteV16.anchor
                . " next=" . coordRouteV16.next . " combatRow=" . coordRouteV16.combatRowV627
                . " sinceIdleMs=" . (coordNoTargetSinceV14 ? A_TickCount-coordNoTargetSinceV14 : -1)
                . " combatUid=" . monsterCombatUidV45 . " portalBack=" . IsObject(portalBackPendingV74)
                . " px=" . px . " py=" . py, "BC_MOVE_NO_DISPATCH", 1000)
        }
        return moveOkV1113
    }
    finally
        DllCall("CloseHandle","Ptr",h)
}

FarmScanCompleteV742(readsOK,total,elapsed)
{
    return readsOK && total<2048 && elapsed<=150
}

FarmCombatResumeV742(pid)
{
    global monsterCombatUidV45,monsterRoadAreaV51,monsterChaseV44
    global coordRouteV16,coordNoTargetSinceV14,farmCenterCycleV741
    if (FarmCenterPendingV741(pid))
        return false
    if (!FarmAttackReleaseWaitV15() || !AutoMonsterPacketCleanupV1() || RemoteThreadBusyV740(pid))
        return false
    monsterCombatUidV45 := 0,monsterRoadAreaV51 := false,monsterChaseV44 := false
    r := coordRouteV16
    if (IsObject(r) && r.pid=pid && r.battlePending)
    {
        r.battlePending := false,r.lastDispatch := 0,r.firstMoveAttempted := false
        coordNoTargetSinceV14 := A_TickCount-250
        PortalLogWriteV66("COMBAT_CLEAR_RESUME row=" . r.next . " next=PICKUP_THEN_ROUTE","COMBAT_CLEAR_RESUME",500)
    }
    return true
}


FarmReviveYellowV743(row,count)
{
    if (row>=1 && row<=count)
        return row
    return 0
}

; V61: Xoa tien do ROUTE cu (KHONG xoa file map tren dia),
; lam mat hieu luc cache F-ON de sau khi vao khu Farm, F-ON doc lai
; map dung level boi canh hien tai va GD2 chay tu dong vang moi.
; Chi goi khi da hoi sinh xong, o thanh, va khong con cong.
FarmReviveNoPortalNewRouteV61(r,pid,level)
{
    global farmReviveV32,stage2MapFileV14,stage2FlowV380,farmStage2DoneV372
    global libFarmPinnedMapV2026,farmControlOwnerV186
    global farmLoadedMapV56,mapRunResumeV210,coordRunSelectedV210
    global coordMapReadyV381,coordMapAcceptedV381,coordMapStateV381
    global coordMapSerialV381,fonCursorV724,coordMoveDoneV14
    global farmStartChoiceV2,mapLoadFailureV402
    if (farmReviveV32!=r || !r.deathSeenV296 || !FarmReviveTownLevelV295(level))
        return false
    if (r.noPortalRouteResetV61)
        return true
    if (farmControlOwnerV186="LIB")
        libFarmPinnedMapV2026 := false  ; Khong co cong cu -> map moi phai pick tai spawn moi.
    CoordRouteResetV16()
    stage2MapFileV14 := false,stage2FlowV380 := false,farmStage2DoneV372 := false
    farmLoadedMapV56 := false,mapRunResumeV210 := false,coordRunSelectedV210 := false
    farmStartChoiceV2 := false,coordMoveDoneV14 := false
    coordMapReadyV381 := false,coordMapAcceptedV381 := false,coordMapStateV381 := false
    fonCursorV724 := false,coordMapSerialV381 += 1,mapLoadFailureV402 := false
    r.noPortalRouteResetV61 := true
    PortalLogWriteV66("REVIVE_NO_PORTAL_ROUTE_RESET pid=" . pid . " town=" . level
        . " old_route=DISCARDED map_file=KEPT next=STAGE1_THEN_FON_RELOAD_FROM_YELLOW")
    return true
}

FarmReviveResumeV743(h,player,ByRef pb,pid,r)
{
    global farmReviveV32,autoMonsterAttackOn,scosEntryV162,farmControlOwnerV186
    global farmRunEpochV535,farmCenterCycleV741,monsterCombatUidV45,monsterChaseV44,monsterRoadAreaV51
    global coordSavedV15,coordRouteV16,coordYellowRowV350,coordPinnedYellowV136,coordManualRowV59
    global coordLiveYellowV128,coordNearbyRowV18,stage2MapFileV14,stage2FlowV380,farmStartChoiceV2
    global farmDeadStartV695,reviveBuffPendingV34,entryBuffPendingV20,cainPauseFarmV361,cainNoFightV361
    global coordCastPendingV50,coordCastCountV50,coordCastLastRowV50
    global currentProfile,routeMapIdV21
    if (farmReviveV32!=r || !BackgroundValidV63() || D2GetActiveGamePidV95()!=pid)
        return false
    level := CoordLevelV14(h,NumGet(pb,0x1C,"UInt")),mode := D2ReadU32(h,player+0x10)
    if (!level || mode=0 || mode=17 || !FarmAttackReleaseWaitV15() || !AutoMonsterPacketCleanupV1())
        return false
    owner := farmControlOwnerV186!="" ? farmControlOwnerV186 : "SCOS",epoch := farmRunEpochV535
    town := FarmReviveTownLevelV295(level)
    known := FarmStartMapStageV737(owner,level)>0 || (owner="CAIN" && (level=168 || CainCaveMapV502(level)))
    if (!town && !known)
    {
        PortalLogWriteV66("REVIVE_LIVE_MAP_WAIT owner=" . owner . " level=" . level . " reason=NOT_OWNER_ROUTE","REVIVE_LIVE_MAP_WAIT",2000)
        return false
    }
    if (!r.reloadPreparedV743)
    {
        if (IsObject(scosEntryV162.commonRouteV3))
            FarmCommonRouteEndV3(scosEntryV162)
        scosEntryV162 := false
        SetTimer, ScosEntryTimerV162, Off
        stage2MapFileV14 := false,stage2FlowV380 := false,farmStartChoiceV2 := false
        farmCenterCycleV741 := false,monsterCombatUidV45 := 0,monsterChaseV44 := false,monsterRoadAreaV51 := false
        cainPauseFarmV361 := false,cainNoFightV361 := false
        autoMonsterAttackOn := true
        SetTimer, AutoMonsterAttackTimer, 250
        r.reloadPreparedV743 := true
    }
    routeFree := town || (owner="BO" && !FarmReviveBOFinalV743(level))
        || (owner="CAIN" && CainCaveMapV502(level))
    if (!routeFree)
    {
        identity := MapLiveIdentityV399(pid,level)
        if (!IsObject(identity))
            return false
        if (!r.mapLoadedV743 || r.loadedLevelV743!=level || r.loadedPtrV743!=identity.levelPtr)
        {
            FonTrackingEnableV410()
            ; LIB sau hoi sinh: doc lai LO TRINH DA KHOA TRONG RAM, khong nap lai INI.
            if (!FonLoadMapV382("REVIVE_LIVE_MAP",pid,level,NumGet(pb,2,"UShort"),NumGet(pb,6,"UShort")))
                return false
            if (farmReviveV32!=r || epoch!=farmRunEpochV535 || RoomRecordLevelV259(pid)!=level)
                return false
            r.mapLoadedV743 := true,r.loadedLevelV743 := level,r.loadedPtrV743 := identity.levelPtr
        }
        ; V1002: tra ve dung diem truoc khi bam nham cong, thay vi bat dau lai tu 1.
        if (r.accidentalPortalV1002 && r.resumeLevelV725=level
            && r.resumeRowV725>=1 && r.resumeRowV725<=coordSavedV15.Length()
            && IsObject(coordSavedV15[r.resumeRowV725])
            && coordSavedV15[r.resumeRowV725].level=level)
        {
            coordYellowRowV350 := r.resumeRowV725
            PortalLogWriteV66("FARM_TOWN_PORTAL_RESTORE level=" . level . " row=" . coordYellowRowV350)
        }
        yellow := FarmReviveYellowV743(coordYellowRowV350,coordSavedV15.Length())
        if (!yellow || coordSavedV15[yellow].level!=level
            || !Stage2MapWaitV381(pid,level,!LibFarmPinMatchesV2026(pid,level)))
            return false
    }
    else
        yellow := 0
    if (farmReviveV32!=r || epoch!=farmRunEpochV535 || RoomRecordLevelV259(pid)!=level)
        return false
    attached := owner="CAIN" && !town && level!=168 ? CainStage2AttachV379()
        : MapStage1ArmV185(owner,GameTargetHwndV63())
    if (!attached)
    {
        autoMonsterAttackOn := true
        return false
    }
    if (farmReviveV32!=r || epoch!=farmRunEpochV535 || RoomRecordLevelV259(pid)!=level)
        return false
    if (yellow)
    {
        coordYellowRowV350 := yellow,coordPinnedYellowV136 := yellow,coordManualRowV59 := yellow
        coordLiveYellowV128 := yellow,coordNearbyRowV18 := yellow
        pointV745 := coordSavedV15[yellow]
        farmStartChoiceV2 := {pid:pid,epoch:epoch,profile:currentProfile,mapId:routeMapIdV21
            ,level:level,row:yellow,x:pointV745.x,y:pointV745.y,reloadPending:false}
        if (IsObject(coordRouteV16) && coordRouteV16.pid=pid && coordRouteV16.startLevel=level)
            coordRouteV16.resumeRowV210 := yellow,coordRouteV16.yellow := yellow,coordRouteV16.startAtYellowV367 := true
    }
    if (IsObject(scosEntryV162) && scosEntryV162.pid=pid)
    {
        scosEntryV162.reviveFarmWasOnV725 := false,scosEntryV162.reviveOwnerV725 := false
        if (r.townBuffDone && !town)
        {
            scosEntryV162.stage1BuffDoneV368 := true,scosEntryV162.stage1SigDoneV374 := true,scosEntryV162.preSigDoneV310 := true
            scosEntryV162.beforeFinalBuffV718 := {pid:pid,owner:owner,epoch:epoch,source:r.respawnLevelV296,destination:level,ready:true}
            if (owner="BO")
                scosEntryV162.buffDoneV413 := true
        }
    }
    farmReviveV32 := false,farmDeadStartV695 := false
    reviveBuffPendingV34 := false,entryBuffPendingV20 := false
    coordCastPendingV50 := false,coordCastCountV50 := 0,coordCastLastRowV50 := 0
    if (owner!="CAIN" || town || level=168)
    {
        autoMonsterAttackOn := false
        SetTimer, AutoMonsterAttackTimer, Off
    }
    SetTimer, ScosEntryTimerV162, 250
    PortalLogWriteV66("REVIVE_RESUME_LIVE_MAP owner=" . owner . " level=" . level . " yellow=" . yellow
        . " source=FON_LIVE forced_first_row=0 portal=" . r.returnKindV725)
    FonInfoPushV385("Hồi sinh: map " . level . (yellow ? ", chạy từ dòng vàng " . yellow : ", tiếp tục luồng map hiện tại") . ".")
    return true
}


FarmReviveBOFinalV743(level)
{
    global currentProfile
    section := ProfileSection(currentProfile)
    IniRead, finalLevelV743, % ProfileConfigPathV364(section), %section%, BOFarmLevel4, 0
    return finalLevelV743>0 && level=finalLevelV743
}


FarmRevivePortalSourceV746(level)
{
    return level>0 && !FarmReviveOnFarmV747(level)
}

FarmReviveOnFarmV747(level)
{
    global farmControlOwnerV186,outsideLevelV22
    if (level<=0)
        return false
    owner := farmControlOwnerV186
    if (owner="SCOS")
        return level=270
    if (owner="LIB")
        return level>=263 && level<=266
    if (owner="NAO")
        return level=155 || (Lab1SingleRunV310() && outsideLevelV22>0 && level=outsideLevelV22)
    if (owner="BO")
        return FarmReviveBOFinalV743(level)
    if (owner="CAIN")
        return level=185
    plan := FarmMapPlanV10(owner,level)
    if (IsObject(plan))
        return plan.final ? true : false
    if (owner="VIZ" || owner="TRAN" || owner="CYC" || owner="M3000" || owner="UBU")
        return false
    return outsideLevelV22>0 && level=outsideLevelV22
}

ManualLogVNStartV749()
{
    global manualLogVNStateV749,manualLogSessionV95,currentProfile,chaseCheckSecV9,monsterLockRoomSecV622
    manualLogVNStateV749 := {session:manualLogSessionV95,parts:[],size:0,trimmed:false,failed:false,lines:0
        ,started:A_Now,profile:currentProfile,checkSec:chaseCheckSecV9,lockSec:monsterLockRoomSecV622}
}

ManualLogVNFailedV749()
{
    global manualLogVNStateV749
    if (IsObject(manualLogVNStateV749))
        manualLogVNStateV749.failed := true
}

ManualLogVNAppendV749(message,channel)
{
    global manualLogVNStateV749,manualLogSessionV95
    r := manualLogVNStateV749
    if (!IsObject(r) || r.session!=manualLogSessionV95)
        return false
    block := ""
    Loop, Parse, message, `n, `r
    {
        line := A_LoopField
        if (Trim(line)="")
            continue
        if (StrLen(line)>8192)
            line := SubStr(line,1,8192) . " [Dòng dài: phần còn lại xem log gốc]"
        block .= "[" . channel . "] " . ManualLogVNLineV749(line) . "`r`n"
        r.lines++
        if (StrLen(block)>=32768)
        {
            ManualLogVNBufferV749(r,block)
            block := ""
        }
    }
    if (block!="")
        ManualLogVNBufferV749(r,block)
    return true
}

ManualLogVNBufferV749(r,block)
{
    last := r.parts.Length()
    if (last && StrLen(r.parts[last])+StrLen(block)<=32768)
        r.parts[last] .= block
    else
        r.parts.Push(block)
    r.size += StrLen(block)
    while (r.size>2000000 && r.parts.Length()>1)
    {
        old := r.parts.RemoveAt(1)
        r.size -= StrLen(old),r.trimmed := true
    }
    return true
}

ManualLogVNLineV749(line)
{
    prefix := "",body := line
    if (RegExMatch(line,"^(\d{14})(?:\s+tick=\d+)?\s*\|\s*(.*)$",m))
    {
        prefix := SubStr(m1,7,2) . "/" . SubStr(m1,5,2) . "/" . SubStr(m1,1,4)
            . " " . SubStr(m1,9,2) . ":" . SubStr(m1,11,2) . ":" . SubStr(m1,13,2) . " | "
        body := m2
    }
    if (RegExMatch(body,"^([A-Z][A-Z0-9_]+)(?=\s|$)",event))
    {
        label := ManualLogVNLookupV749("EVENT",event1)
        body := (label=event1 ? "Sự kiện chưa có diễn giải: " . event1 : label)
            . SubStr(body,StrLen(event1)+1)
    }
    out := "",pos := 1
    while (at := RegExMatch(body,"([A-Za-z_][A-Za-z_0-9]*)=(""[^""]*""|[^\s|]+)",field,pos))
    {
        out .= SubStr(body,pos,at-pos) . ManualLogVNLookupV749("FIELD",field1) . ": "
            . ManualLogVNLookupV749("VALUE",field2)
        pos := at+StrLen(field)
    }
    return prefix . out . SubStr(body,pos)
}

ManualLogVNLookupV749(kind,key)
{
    static initializedV751 := false,events := {},fields := {},values := {}
    if (!initializedV751)
    {
        events["COMBAT_PICKUP_CLEAR"] := "Đã hết lượt nhặt và quái bảo vệ đồ; tiếp theo kiểm tra tâm B"
        events["COMBAT_AFTER_ATTACK_PICKUP"] := "Sau đánh: chuyển sang xét nhặt và đánh quái theo tâm nhặt"
        events["START"] := "Bắt đầu ghi log"
        events["TRACE_START"] := "Bắt đầu ghi kênh"
        events["SESSION_END"] := "Kết thúc ghi log"
        events["CONFIG"] := "Cấu hình đang dùng"
        events["TARGET_SELECTED"] := "Chọn mục tiêu để đánh"
        events["TARGET_STUCK_NO_DAMAGE"] := "Mục tiêu không tiến triển: đã yêu cầu bỏ qua"
        events["TARGET_STUCK_ROOM_LOCK"] := "Tạm khóa phòng chứa mục tiêu bị kẹt"
        events["TARGET_ROOM_UNREADABLE"] := "Không đọc được phòng chứa mục tiêu; đang chờ đọc lại"
        events["COMBAT_LOCK"] := "Giữ mục tiêu đang đánh"
        events["COMBAT_UNLOCK"] := "Bỏ giữ mục tiêu"
        events["COMBAT_STUCK_SWITCH"] := "Bỏ qua mục tiêu kẹt và đổi sang mục tiêu gần"
        events["COMBAT_SCAN_CONTEXT"] := "Điều kiện lượt quét quái"
        events["COMBAT_SCAN_RESULT"] := "Kết quả quét quái"
        events["FON_MANUAL_REFRESH"] := "Load: bật lại F-ON và đọc map thực tế hiện tại"
        events["START_IN_FARM_READY"] := "Start: nhân vật đã ở map farm; giữ dòng vàng và bỏ chờ buff hồi sinh"
        events["START_IN_FARM_BUFF_CLEAR"] := "Đã bỏ cờ buff hồi sinh cũ vì nhân vật đang sống trong map farm"
        events["COMBAT_FORWARD_TO_C"] := "Vượt bán kính theo hướng B tới C; teleport tới C và chờ xác nhận"
        events["COMBAT_FORWARD_ARRIVED"] := "Đã vào bán kính quanh C; dừng tele, chuyển tâm đánh và dòng vàng sang C"
        events["COMBAT_CENTER_CHECK"] := "Kiểm tra vị trí so với tâm B"
        events["COMBAT_CENTER_INSIDE"] := "Nhân vật đang trong bán kính tâm B"
        events["COMBAT_CENTER_RETURN"] := "Đã gửi một lệnh tele chỉnh lệch B/C; tiếp tục đi và đánh, không lặp tele chờ tới đích"
        events["COMBAT_CLEAR_RESUME"] := "Đã hết mục tiêu hợp lệ; tiếp tục nhặt đồ rồi đi lộ trình"
        events["COMBAT_CENTER_TELE"] := "Gửi lệnh teleport về tâm B"
        events["COMBAT_CENTER_TELE_SENT"] := "Đã gửi lệnh teleport về tâm B; chờ kiểm tra vị trí"
        events["NATIVE_DISPATCH"] := "Gửi thao tác tới game"
        events["PORTAL_DLL_TARGET"] := "Chọn cổng đang tồn tại"
        events["PORTAL_DLL_TRY"] := "Thử gửi lệnh chui cổng"
        events["PORTAL_INTERACT_SENT"] := "Đã gửi lệnh tương tác cổng; chưa xác nhận chuyển map"
        events["RETURN_MAP_CONFIRMED"] := "Đã xác nhận đổi map sau khi vào cổng"
        events["REVIVE_ESC"] := "Gửi Esc sau khi chết"
        events["REVIVE_STATE"] := "Tình trạng hồi sinh"
        events["REVIVE_ALIVE"] := "Đã đọc được nhân vật sống sau hồi sinh"
        events["REVIVE_REOPEN_PORTAL"] := "Gửi phím mở lại cổng sau hồi sinh"
        events["REVIVE_NO_FARM_PORTAL"] := "Không thấy cổng farm sau các lượt kiểm tra"
        events["REVIVE_RESUME_LIVE_MAP"] := "Tiếp tục map hiện tại từ dòng vàng"
        events["REVIVE_RETURN_MAP_MISMATCH"] := "Map vừa vào khác map đang chờ"
        events["REVIVE_LIVE_MAP_WAIT"] := "Chờ dữ liệu map phù hợp để chạy tiếp"
        events["REVIVE_PORTAL_APPROACH"] := "Đi tới gần cổng hồi sinh"
        events["REVIVE_PORTAL_RESCAN_RETURN"] := "Quay về vị trí cổng đã thấy để quét lại"
        events["FARM_START_TOWN"] := "Bắt đầu kiểm tra cổng quay lại farm"
        events["REVIVE_TOWN_BUFF_DONE"] := "Đã xong buff trước khi chui cổng"
        events["REVIVE_RED_WAIT"] := "Chưa chọn được một cổng đỏ phù hợp"
        events["PORTAL_RECORD_FARM_CONFIRMED"] := "Đã quan sát thấy cổng farm mới"
        events["PORTAL_RECORD_FARM_TOWN_PAIR"] := "Đã ghép đầu cổng ở điểm hồi sinh"
        events["PORTAL_RECORD_FARM_TOWN_CONFIRMED"] := "Đã xác nhận đầu cổng farm tại điểm hồi sinh"
        events["PORTAL_RECORD_INITIAL_DEST"] := "Đã ghi nhận map đích của cổng vào"
        events["MAP_CHANGE"] := "Nhân vật đổi map"
        events["FON_LOAD_SCAN"] := "Tìm file lộ trình khớp map hiện tại"
        events["FON_LOAD_OK"] := "Đã nạp file lộ trình và dòng vàng"
        events["FON_LOAD_FAIL"] := "Chưa nạp được lộ trình cho map"
        events["FON_LOAD_BLOCKED"] := "Đang có lượt nạp map khác; chờ lượt sau"
        events["STAGE2_ROUTE_NEW"] := "Tạo lộ trình mới từ dòng vàng"
        events["STAGE2_ROUTE_BEGIN"] := "Bắt đầu chạy lộ trình đang nạp"
        events["FARM_START_FROM_YELLOW"] := "Bắt đầu farm từ dòng vàng"
        events["RUN_RESET_FROM_YELLOW"] := "Nạp lại lộ trình và bắt đầu từ dòng vàng"
        events["ROUTE_START_YELLOW"] := "Khởi động lộ trình tại dòng vàng"
        events["ROUTE_START"] := "Bắt đầu đi lộ trình"
        events["RUN_RESUME"] := "Tiếp tục lộ trình"
        events["ROUTE_MOVE"] := "Gửi lệnh di chuyển theo lộ trình"
        events["MAP_MOVE_DISPATCH"] := "Gửi lệnh đi tới tọa độ"
        events["MAP_MOVE_WAIT"] := "Lệnh di chuyển đang chờ"
        events["ROUTE_NO_PROGRESS"] := "Nhân vật chưa tiến tới đích"
        events["ROUTE_MOVE_OBSERVED"] := "Đối chiếu vị trí sau lệnh di chuyển"
        events["ROUTE_WAIT"] := "Chờ dữ liệu lộ trình"
        events["ROUTE_BATTLE"] := "Tạm ngừng đi lộ trình để đánh quái"
        events["ROUTE_RESUME_ORDERED"] := "Tiếp tục theo thứ tự lộ trình"
        events["MAP_STAGE1_START"] := "Bắt đầu giai đoạn đi vào khu farm"
        events["MAP_STAGE1_COMPLETE"] := "Hoàn thành giai đoạn đi vào khu farm"
        events["MAP_STAGE2_START"] := "Bắt đầu farm chính"
        events["MAP_STAGE2_DONE"] := "Đã hết lộ trình farm chính"
        events["MAP_STAGE3_START"] := "Bắt đầu xử lý sau farm"
        events["COMMON_ROUTE_BEGIN"] := "Bắt đầu đoạn lộ trình dùng chung"
        events["COMMON_ROUTE_DONE"] := "Đã hoàn thành đoạn lộ trình dùng chung"
        events["BO_COMBAT_FIRST"] := "BO: ưu tiên đánh quái, tạm ngừng di chuyển"
        events["BO_SHARED_SCAN"] := "BO: kết quả quét quái dùng chung"
        events["ITEM_GUARD_LOCK"] := "Tạm giữ vùng có đồ cần nhặt"
        events["ITEM_GUARD_UNLOCK"] := "Bỏ giữ vùng nhặt đồ"
        events["LOW_HP_ATTACK_ONCE"] := "Máu thấp: gửi một lượt đánh rồi né"
        events["SIG_SESSION_RELEASE"] := "Phiên game cũ đã kết thúc; xóa khóa SIG/nhặt cũ và cho phép phục hồi game"
        events["SIG_CATALYST_TO_CUBE"] := "Đã đưa đúng tem SIG vào Cube; tem được giữ lại sau khi ghép"
        events["FARM_PICKUP_TRY"] := "Thử nhặt vật phẩm trong lúc farm"
        events["FARM_PICKUP_SKIP"] := "Bỏ qua vật phẩm nhặt không được trong lượt farm này"
        events["SIG_ERROR_PICKUP_BEGIN"] := "SIG lỗi: nhặt lại đồ trước khi dừng"
        events["SIG_ERROR_PICKUP_DONE"] := "Đã thu hồi đồ sau lỗi SIG"
        events["SIG_ERROR_PICKUP_FAILED"] := "Chưa thu hồi xong đồ sau lỗi SIG"
        events["SIG_ENTRY_ABORT"] := "SIG đã dừng vì lỗi; giữ đồ, không chờ vô hạn"
        events["CUBE_RESET_HOLD"] := "Đã khóa reset trước khi quăng Cube; chờ nhặt lại Cube và đồ"
        events["CUBE_RESET_PICKUP_DONE"] := "Đã xác nhận nhặt xong sau khi quăng Cube; chờ thao tác đồ kết thúc"
        events["FARM_SIG_PAUSE"] := "Tạm dừng bộ đếm reset; chờ SIG và nhặt đồ xong"
        events["FARM_SIG_RESUME"] := "SIG và nhặt đồ đã xong; bộ đếm reset bắt đầu lại từ 0"
        events["STAGE4_SIG_DEFER"] := "Hoãn phục hồi game vì đang SIG hoặc nhặt đồ sau SIG"
        events["REMOTE_TIMEOUT_TRACKED"] := "Lệnh game chưa hoàn tất; giữ vùng nhớ và chờ xử lý xong"
        events["FARM_RETRY_ERROR"] := "Gặp lỗi tạm thời; chờ thử lại"
        events["SKIP"] := "Bỏ qua thao tác trong lượt này"
        events["WAIT"] := "Đang chờ"
        events["STOP"] := "Dừng thao tác"
        events["STATE"] := "Tình trạng hiện tại"
        fields["uid"] := "ID mục tiêu"
        fields["target_uid"] := "ID mục tiêu được chọn"
        fields["new_uid"] := "ID mục tiêu mới"
        fields["old_uid"] := "ID mục tiêu cũ"
        fields["trigger_uid"] := "ID quái gây kẹt"
        fields["class"] := "Loại đối tượng"
        fields["target_class"] := "Loại mục tiêu"
        fields["cls"] := "Loại đối tượng"
        fields["pid"] := "ID tiến trình game"
        fields["unit"] := "Địa chỉ đối tượng"
        fields["level"] := "ID map hiện tại"
        fields["source"] := "Nguồn"
        fields["destination"] := "Map đích"
        fields["expected"] := "Đang chờ"
        fields["actual"] := "Thực tế"
        fields["before"] := "Trước"
        fields["after"] := "Sau"
        fields["row"] := "Dòng lộ trình"
        fields["yellow"] := "Dòng vàng"
        fields["next"] := "Bước tiếp theo"
        fields["phase"] := "Giai đoạn"
        fields["step"] := "Bước"
        fields["attempt"] := "Lần thử"
        fields["reason"] := "Lý do"
        fields["queued"] := "Đã gửi lệnh (1=có, 0=chưa)"
        fields["sent"] := "Đã gửi (1=có, 0=chưa)"
        fields["result"] := "Kết quả"
        fields["confirmed"] := "Đã xác nhận"
        fields["known"] := "Đọc được dữ liệu"
        fields["complete"] := "Quét đủ dữ liệu"
        fields["radius"] := "Bán kính"
        fields["distance"] := "Khoảng cách"
        fields["dist_sq"] := "Khoảng cách bình phương"
        fields["half_bk_sq"] := "Nửa bán kính, bình phương"
        fields["hp_readable"] := "Đọc được máu"
        fields["hp"] := "Máu"
        fields["hp_raw"] := "Máu gốc"
        fields["time"] := "Thời gian xét"
        fields["since"] := "Mốc bắt đầu đếm"
        fields["elapsed"] := "Thời gian đã qua"
        fields["elapsed_ms"] := "Thời gian đã qua (ms)"
        fields["wait_ms"] := "Chờ (ms)"
        fields["duration"] := "Thời lượng"
        fields["retry_ms"] := "Chờ thử lại (ms)"
        fields["timeout"] := "Thời hạn"
        fields["locked"] := "Đang khóa"
        fields["uid_locked"] := "Khóa riêng quái"
        fields["room_locked"] := "Khóa phòng"
        fields["scope"] := "Phạm vi"
        fields["room"] := "Phòng"
        fields["rooms"] := "Số phòng"
        fields["units"] := "Số đối tượng"
        fields["owner"] := "Farm đang chạy"
        fields["map"] := "Map/lộ trình"
        fields["map_id"] := "ID map"
        fields["profile"] := "Hồ sơ"
        fields["key"] := "Phím"
        fields["mode"] := "Trạng thái"
        fields["state"] := "Tình trạng"
        fields["channel"] := "Kênh"
        fields["tick"] := "Mốc thời gian hệ thống"
        fields["x"] := "Tọa độ X"
        fields["y"] := "Tọa độ Y"
        fields["xy"] := "Tọa độ"
        fields["player"] := "Nhân vật"
        fields["player_xy"] := "Tọa độ nhân vật"
        fields["portal_xy"] := "Tọa độ cổng"
        fields["target"] := "Đích"
        fields["to"] := "Tới"
        fields["method"] := "Cách thực hiện"
        fields["movement"] := "Di chuyển"
        fields["pickup"] := "Nhặt đồ"
        fields["farm"] := "Farm"
        fields["fight"] := "Đánh quái"
        fields["no_fight"] := "Không đánh"
        fields["pause"] := "Tạm dừng"
        fields["item_owner"] := "Thao tác đang giữ quyền dùng đồ"
        fields["x_running"] := "Buff X đang chạy"
        fields["z_running"] := "Buff Z đang chạy"
        fields["last_try"] := "Lần thử gần nhất"
        fields["boss_priority"] := "Ưu tiên boss"
        fields["position_changed"] := "Vị trí đã đổi"
        fields["buff"] := "Buff"
        fields["forced_first_row"] := "Ép về dòng đầu"
        fields["next_left_ms"] := "Còn lại (ms)"
        fields["map_file"] := "File lộ trình"
        fields["file"] := "File"
        fields["ready"] := "Đã sẵn sàng"
        fields["selection"] := "Cách chọn"
        fields["action"] := "Thao tác"
        fields["until"] := "Đến khi"
        fields["segment_ms"] := "Khoảng chia file (ms)"
        fields["note"] := "Ghi chú"
        fields["combat"] := "Đánh quái"
        fields["center"] := "Tâm"
        fields["area"] := "Vùng quét"
        fields["lock_ms"] := "Thời gian khóa (ms)"
        values["USER_STOP"] := "Người dùng dừng log"
        values["UNTIL_STOP"] := "Tới khi dừng"
        values["FARM"] := "Farm"
        values["RED"] := "Cổng đỏ"
        values["MAP"] := "Map"
        values["UID"] := "Riêng một quái"
        values["ROOM"] := "Cả phòng"
        values["CHECK"] := "Kiểm tra"
        values["ATTACK"] := "Đánh"
        values["RETURN"] := "Quay về tâm"
        values["INSIDE"] := "Trong bán kính"
        values["OUTSIDE"] := "Ngoài bán kính"
        values["WAIT_MAP_CHANGE"] := "Chờ xác nhận đổi map"
        values["LIVE_MAP_YELLOW"] := "Nạp map hiện tại và lấy dòng vàng"
        values["PICKUP"] := "Nhặt sau khi đánh hết quái"
        values["CHECK_B"] := "Kiểm tra bán kính tâm B"
        values["PLAYER_SCAN"] := "Quét quanh nhân vật"
        values["PLAYER_SCAN_THEN_CHECK_B"] := "Quét quanh nhân vật rồi kiểm tra tâm B"
        values["PICKUP_THEN_ROUTE"] := "Nhặt đồ rồi đi lộ trình"
        values["FON_LIVE"] := "Dữ liệu map đang nạp"
        values["RESUME_COMBAT"] := "Tiếp tục đánh"
        values["NONE"] := "Không có"
        values["ON"] := "Bật"
        values["OFF"] := "Tắt"
        values["MISSING"] := "Chưa thấy"
        values["PRESENT"] := "Đang có"
        values["NORMAL"] := "Bình thường"
        values["NO_ROUTE_FILE"] := "Không có file lộ trình"
        values["NOT_OWNER_ROUTE"] := "Map chưa thuộc lộ trình của farm đang chạy"
        values["TARGET_GONE_EXCLUDED_OR_OUTSIDE_RADIUS"] := "Quái mất, bị loại hoặc ra ngoài bán kính"
        values["NO_WANTED_GROUND_ITEMS_IN_FIXED_CIRCLE"] := "Không còn đồ cần nhặt trong vùng"
        values["WAIT_THREAD_OR_PROCESS_EXIT"] := "Chờ lệnh game xong hoặc game đóng"
        values["NO_UNIQUE_RED_PORTAL"] := "Chưa có đúng một cổng đỏ phù hợp"
        values["BUILD_OR_INTERACT_SIGNATURE_MISMATCH"] := "Phiên bản game hoặc hàm tương tác không khớp"
        values["NO_SELECTED_ROUTE"] := "Chưa chọn lộ trình"
        values["READ_FAILED"] := "Không đọc được dữ liệu"
        values["TARGET_GONE"] := "Mục tiêu không còn"
        values["KEEP_CURRENT_TARGET"] := "Tiếp tục giữ mục tiêu hiện tại"
        values["PAUSED"] := "Tạm ngừng"
        values["WAIT"] := "Chờ"
        values["DONE"] := "Hoàn tất"
        values["NEXT"] := "Điểm tiếp theo"
        values["CLEAR"] := "Quét/đánh quanh điểm"
        values["START"] := "Bắt đầu"
        values["SIG"] := "Xử lý SIG"
        values["WP"] := "Waypoint"
        values["PORTAL"] := "Cổng"
        values["PORTAL_WAIT"] := "Chờ cổng"
        values["FON"] := "Bộ nạp map"
        values["NEAREST_CURRENT_PLAYER"] := "Gần nhân vật nhất"
        values["RETRY_ROOM_READ"] := "Thử đọc lại phòng"
        values["STANDARD_GD2"] := "Luồng farm chuẩn"
        values["NO_LIVE_TARGET"] := "Không có quái sống hợp lệ"
        initializedV751 := true
    }
    table := kind="EVENT" ? events : kind="FIELD" ? fields : values
    return table.HasKey(key) ? table[key] : key
}

ManualLogVNStopV749(show := true)
{
    global manualLogVNStateV749,manualLogVNDisplayV749,ManualLogVNTextV749,ManualLogVNHwndV749
    global ManualLogVNHintV749,ManualLogVNCopyButtonV749,ManualLogVNCloseButtonV749
    r := manualLogVNStateV749
    manualLogVNStateV749 := false
    if (!show || !IsObject(r))
        return false
    text := "DIỄN GIẢI LOG TIẾNG VIỆT`r`nPhiên: " . r.session . " | Hồ sơ: " . r.profile
        . "`r`nXét kẹt: " . r.checkSec . " giây | Thời gian khóa bỏ qua: " . r.lockSec . " giây."
        . "`r`nCó thể bôi đen để copy, hoặc bấm Copy tất cả. Đóng bảng sẽ bỏ bản diễn giải này."
        . "`r`nGửi lệnh thành công chưa có nghĩa là game đã di chuyển/đổi map. Các ID và số liệu được giữ nguyên."
        . "`r`nSự kiện chưa có bản diễn giải sẽ giữ tên gốc để đối chiếu; bảng không tự kết luận nguyên nhân lỗi."
    if (r.trimmed)
        text .= "`r`nPhiên dài: chỉ hiển thị phần log gần nhất để giới hạn bộ nhớ; log gốc vẫn đầy đủ."
    if (r.failed)
        text .= "`r`nMột số dòng không diễn giải được; hãy đối chiếu log gốc."
    text .= "`r`n`r`n"
    for _,part in r.parts
        text .= part
    if (!r.lines)
        text .= "Phiên này không có dòng log được ghi."
    manualLogVNDisplayV749 := text
    Gui, ManualLogVN:Destroy
    Gui, ManualLogVN:New, +Resize +MinSize640x360 +HwndManualLogVNHwndV749, Diễn giải log tiếng Việt
    Gui, ManualLogVN:Font, s10, Segoe UI
    Gui, ManualLogVN:Add, Text, x12 y10 w860 h22 vManualLogVNHintV749, Đọc bản diễn giải bên dưới. Ctrl+A / Ctrl+C để copy phần bạn muốn gửi.
    Gui, ManualLogVN:Add, Edit, x12 y36 w876 h470 vManualLogVNTextV749 ReadOnly +HScroll -Wrap, %text%
    Gui, ManualLogVN:Add, Button, x630 y516 w140 h30 vManualLogVNCopyButtonV749 gManualLogVNCopyV749, Copy tất cả
    Gui, ManualLogVN:Add, Button, x782 y516 w106 h30 vManualLogVNCloseButtonV749 gManualLogVNCloseV749, Đóng
    Gui, ManualLogVN:Show, w900 h558
    return true
}

ManualLogVNCopyV749:
Clipboard := manualLogVNDisplayV749
GuiControl, ManualLogVN:, ManualLogVNHintV749, Đã copy toàn bộ bản diễn giải. Bạn có thể dán để gửi.
return

ManualLogVNCloseV749:
ManualLogVNGuiClose:
ManualLogVNGuiEscape:
Gui, ManualLogVN:Destroy
manualLogVNDisplayV749 := "",ManualLogVNHwndV749 := 0
return

ManualLogVNGuiSize:
if (A_EventInfo=1)
    return
vnWidthV749 := A_GuiWidth-24,vnHeightV749 := A_GuiHeight-88,vnButtonsYV749 := A_GuiHeight-42
vnCopyXV749 := A_GuiWidth-270,vnCloseXV749 := A_GuiWidth-118
GuiControl, ManualLogVN:Move, ManualLogVNHintV749, % "w" . vnWidthV749
GuiControl, ManualLogVN:Move, ManualLogVNTextV749, % "w" . vnWidthV749 . " h" . vnHeightV749
GuiControl, ManualLogVN:Move, ManualLogVNCopyButtonV749, % "x" . vnCopyXV749 . " y" . vnButtonsYV749
GuiControl, ManualLogVN:Move, ManualLogVNCloseButtonV749, % "x" . vnCloseXV749 . " y" . vnButtonsYV749
return


MonsterSkipDistanceChangedV752:
GuiControlGet, skipInputV752, 1:, MonsterSkipDistanceInputV752
if (RegExMatch(skipInputV752,"^\d+$") && skipInputV752<=200)
    monsterSkipDistanceV752 := skipInputV752+0
return

MonsterSkipDistanceGetV752(radius)
{
    global monsterSkipDistanceV752
    return monsterSkipDistanceV752>0 ? monsterSkipDistanceV752 : Max(1,radius)/2
}

; V1801: independent shortcut for Form 4 Cast, configured beneath Form 3.
CastToggleKeyChangedV1801:
GuiControlGet, castKeyEditV1801, 1:, CastToggleKeyInputV1801
newCastKeyV1801 := NormalizeOptionalKey(castKeyEditV1801)
if (newCastKeyV1801!="" && !GetKeyVK(newCastKeyV1801) && !GetKeySC(newCastKeyV1801))
    return
if (castToggleKeyV1801!="")
    BackgroundHotkeyV63("~$" . castToggleKeyV1801,"CastToggleHandlerV1801","Off UseErrorLevel")
castToggleKeyV1801 := newCastKeyV1801
try IniWrite, % castToggleKeyV1801="" ? "None" : castToggleKeyV1801, %ConfigFile%, CastShortcut, Key
if (castToggleKeyV1801!="")
    BackgroundHotkeyV63("~$" . castToggleKeyV1801,"CastToggleHandlerV1801","On UseErrorLevel")
return

CastToggleHandlerV1801:
if (!IsGameForegroundV63())
    return
castManualToggleV1801 := !castManualToggleV1801
QCastOn := castManualToggleV1801
if (QCastOn)
    qCastLast1 := A_TickCount, qCastLast2 := A_TickCount, qCastLast3 := A_TickCount
; Always show shortcut state, even if optional View Tooltip / F-ON INFO is disabled.
GuiControl, 1:, CastToggleStatusV1801, % (castManualToggleV1801 ? "ON" : "OFF")
ToolTip, % "CAST: " . (castManualToggleV1801 ? "ON" : "OFF")
SetTimer, RemoveToolTip, -3000
return

; V816 - Gom .txt nam canh file AHK vao thu muc txt ngay khi mo tool.
; Khong thay doi file .log, tep .txt trong Logs/LoTrinh, hay tep tam A_Temp.
TxtRootInitV816()
{
    folder := A_ScriptDir . "\txt"
    try FileCreateDir, %folder%
    if (!InStr(FileExist(folder), "D"))
        return false
    ; Chuyen config.ini vao txt, khong ghi de du lieu neu da co ban trong txt.
    legacyIniV816 := A_ScriptDir . "\config.ini"
    targetIniV816 := folder . "\config.ini"
    if (FileExist(legacyIniV816))
    {
        if (FileExist(targetIniV816))
        {
            backupIndexV816 := 1
            Loop
            {
                targetIniV816 := folder . "\config-ban-cu-" . backupIndexV816 . ".ini"
                if (!FileExist(targetIniV816))
                    break
                backupIndexV816++
            }
        }
        try FileMove, %legacyIniV816%, %targetIniV816%
    }
    Loop, Files, % A_ScriptDir . "\*.txt", F
    {
        src := A_LoopFileFullPath
        dst := folder . "\" . A_LoopFileName
        if (FileExist(dst))
        {
            SplitPath, src,,, extension, baseName
            index := 1
            Loop
            {
                dst := folder . "\" . baseName . "-ban-cu-" . index . "." . extension
                if (!FileExist(dst))
                    break
                index++
            }
        }
        try FileMove, %src%, %dst%
    }
    return true
}

; Duong dan thong nhat cho file TXT trong thu muc goc.
; Neu khong tao duoc thu muc hay khong di chuyen duoc file cu, van doc file cu.
TxtRootPathV816(fileName)
{
    folder := A_ScriptDir . "\txt"
    if (!InStr(FileExist(folder), "D"))
    {
        try FileCreateDir, %folder%
        if (!InStr(FileExist(folder), "D"))
            return A_ScriptDir . "\" . fileName
    }
    path := folder . "\" . fileName
    legacy := A_ScriptDir . "\" . fileName
    if (!FileExist(path) && FileExist(legacy))
    {
        try FileMove, %legacy%, %path%
        if (ErrorLevel)
            return legacy
    }
    return path
}

