; ==============================================================================
; FILE: 03_buff_cast_info.ahk (Dòng 464 -> 2143 trong Gốc.ahk)
; CHỨC NĂNG: Cửa sổ ngầm, QCast, Dãy F, Buff Z/X & Bảng Info xanh
; ==============================================================================
IsGameForegroundV63(hotkeyName := "")
{
    static lastCheck := 0, lastHwnd := 0, lastResult := false
    hwnd := DllCall("GetForegroundWindow","Ptr")
    if (!hwnd)
        return lastResult := false
    if (hwnd = lastHwnd && A_TickCount - lastCheck < 250)
        return lastResult
    lastCheck := A_TickCount, lastHwnd := hwnd
    WinGet, activePid, PID, ahk_id %hwnd%
    WinGet, activeProcess, ProcessName, ahk_id %hwnd%
    if (!(activeProcess="Game.exe" || activeProcess="Diablo II.exe" || activeProcess="D2.exe"))
        return lastResult := false
    return lastResult := activePid && D2GetModuleBaseV35(activePid,"D2Client.dll")!=0
}
IsGameActive()
{
    return GameTargetHwndV63()!=0
}

BackgroundBirthV63(pid)
{
    h := DllCall("OpenProcess","UInt",0x1000,"Int",0,"UInt",pid,"Ptr")
    if (!h)
        return ""
    VarSetCapacity(created,8,0), VarSetCapacity(exited,8,0)
    VarSetCapacity(kernel,8,0), VarSetCapacity(user,8,0)
    ok := DllCall("GetProcessTimes","Ptr",h,"Ptr",&created,"Ptr",&exited,"Ptr",&kernel,"Ptr",&user)
    DllCall("CloseHandle","Ptr",h)
    return ok ? Format("{:08X}{:08X}",NumGet(created,4,"UInt"),NumGet(created,0,"UInt")) : ""
}

BackgroundBindV63(hwnd := 0)
{
    global backgroundHwndV63, backgroundPidV63, backgroundBirthV63
    if (!hwnd)
    {
        if (!IsGameForegroundV63())
            return false
        hwnd := WinExist("A")
    }
    WinGet, pid, PID, ahk_id %hwnd%
    WinGet, process, ProcessName, ahk_id %hwnd%
    WinGetTitle, title, ahk_id %hwnd%
    if (!pid || !(process="Game.exe" || process="Diablo II.exe" || process="D2.exe" || InStr(title,"Diablo II"))
        || !D2GetModuleBaseV35(pid,"D2Client.dll"))
        return false
    birth := BackgroundBirthV63(pid)
    if (birth="")
        return false
    backgroundHwndV63 := hwnd, backgroundPidV63 := pid, backgroundBirthV63 := birth
    return true
}

BackgroundValidV63()
{
    global backgroundHwndV63, backgroundPidV63, backgroundBirthV63
    if (!backgroundHwndV63 || !DllCall("IsWindow","Ptr",backgroundHwndV63))
        return false
    WinGet, pid, PID, ahk_id %backgroundHwndV63%
    WinGet, minmax, MinMax, ahk_id %backgroundHwndV63%
    return pid=backgroundPidV63 && minmax!=-1 && BackgroundBirthV63(pid)=backgroundBirthV63
}

BackgroundInputWatchV553()
{
    return
}

BackgroundRefreshV690(w)
{
    global backgroundBlockReasonV553
    hwnd := w.hwnd,pid := w.pid
    if (!hwnd || !pid || w.birth="" || !DllCall("IsWindow","Ptr",hwnd))
        return false
    WinGet, actualPid, PID, ahk_id %hwnd%
    if (actualPid!=pid || BackgroundBirthV63(pid)!=w.birth)
        return false
    appQueued := DllCall("PostMessage","Ptr",hwnd,"UInt",0x1C,"UPtr",1,"Ptr",0)
    windowQueued := DllCall("PostMessage","Ptr",hwnd,"UInt",0x6,"UPtr",1,"Ptr",0)
    focusQueued := DllCall("PostMessage","Ptr",hwnd,"UInt",0x7,"UPtr",0,"Ptr",0)
    queued := appQueued && windowQueued && focusQueued
    backgroundBlockReasonV553 := queued ? "" : "Chưa gửi được kích hoạt nền; sẽ thử lại nhịp sau."
    PortalLogWriteV66("BACKGROUND_INPUT_REFRESH pid=" . pid . " app_queued=" . appQueued
        . " window_queued=" . windowQueued . " focus_queued=" . focusQueued
        . " cadence_ms=1000 foreground_forced=0 actual_activation=UNCONFIRMED"
        ,"BACKGROUND_INPUT_REFRESH",1000)
    return queued
}

BackgroundActivityViewV693(hwnd)
{
    v := BackgroundViewReadV692(hwnd)
    result := BackgroundActivityTextV692(v.activity)
    return result
}

BackgroundActivityV692(previous,live,attacking)
{
    if (!IsObject(live))
        return "NO_PLAYER"
    if (live.HasKey("mode") && (live.mode=0 || live.mode=17))
        return "DEAD"
    if (attacking)
        return "ATTACK"
    if (!IsObject(previous) || previous.pid!=live.pid || previous.birth!=live.birth)
        return "SAMPLING"
    if ((live.x-previous.x)**2+(live.y-previous.y)**2>=1)
        return "MOVE"
    if (FarmReviveTownLevelV295(live.level))
        return "TOWN"
    return "IDLE"
}

BackgroundActivityTextV692(activity)
{
    if (activity="NO_WINDOW")
        return "mất"
    if (activity="NO_PLAYER")
        return "mất NV"
    if (activity="DEAD")
        return "chết"
    if (activity="SAMPLING")
        return "đo"
    if (activity="ATTACK")
        return "đánh"
    if (activity="MOVE")
        return "đi"
    if (activity="TOWN")
        return "thành"
    return "đứng"
}

BackgroundViewReadV692(hwnd)
{
    global currentAttackPidV550,currentAttackUidV520,currentAttackAtV520
    static previous := false
    v := {activity:"NO_WINDOW", level:0}
    if (!hwnd || !DllCall("IsWindow","Ptr",hwnd))
    {
        previous := false
        return v
    }
    WinGet, pid, PID, ahk_id %hwnd%
    contact := {pid:pid,hwnd:hwnd,birth:pid ? BackgroundBirthV63(pid) : ""}
    live := false
    try
        live := FarmStandSampleV650(contact)
    attacking := FarmWatchAttackingV688(live,currentAttackPidV550,currentAttackUidV520
        ,currentAttackAtV520,A_TickCount)
    v.activity := BackgroundActivityV692(previous,live,attacking)
    v.level := IsObject(live) ? live.level : 0
    previous := live
    return v
}


FarmBackgroundContextV704()
{
    global mapControlGuiStartV180,mapStage1BuffDoneV248,stage2StartPendingV381
    global farmDeadStartV695,coordTrackingEnabledV409
    return FarmControlRunningV186() || mapControlGuiStartV180 || IsObject(mapStage1BuffDoneV248)
        || stage2StartPendingV381 || IsObject(farmDeadStartV695) || coordTrackingEnabledV409
}


GameTargetHwndV63()
{
    global autoMonsterAttackOn, coordGoV59, backgroundHwndV63,sigTownV148,scosEntryV162,stageTwoV166,sigBackgroundV179,pickupBackgroundV181,pickupImageOn,sigBusyV147,pickupGroupActiveV26
    global mainToolHwndV67,buffSequenceOnV555
    static resolvingToolTargetV67 := false
    if (mainToolHwndV67 && WinActive("ahk_id " . mainToolHwndV67))
    {
        if (BackgroundValidV63())
            return backgroundHwndV63
        if (resolvingToolTargetV67)
            return 0
        resolvingToolTargetV67 := true
        try
            boundToolTargetV67 := SigBackgroundBindV179()
        finally
            resolvingToolTargetV67 := false
        return boundToolTargetV67 && BackgroundValidV63() ? backgroundHwndV63 : 0
    }
    if (FarmBackgroundContextV704() || (pickupBackgroundV181 && (pickupImageOn || pickupGroupActiveV26)) || sigBackgroundV179 || sigBusyV147 || buffSequenceOnV555 || autoMonsterAttackOn || IsObject(coordGoV59) || IsObject(scosEntryV162) || IsObject(stageTwoV166) || (IsObject(sigTownV148) && sigTownV148.auto))
        return BackgroundBoundTargetV705()
    return IsGameForegroundV63() ? WinExist("A") : 0
}

BackgroundBoundTargetV705()
{
    global backgroundPidV63,backgroundHwndV63,backgroundBirthV63
    static resolving := false,lastTry := 0
    if (BackgroundValidV63())
        return backgroundHwndV63
    if (resolving || (lastTry && A_TickCount-lastTry<500))
        return 0
    pid := backgroundPidV63,birth := backgroundBirthV63
    if (!pid || birth="" || BackgroundBirthV63(pid)!=birth)
        return 0
    resolving := true,lastTry := A_TickCount
    try
    {
        if (!SigBackgroundBindV179(pid) || !BackgroundValidV63())
            return 0
        PortalLogWriteV66("AUTO_BACKGROUND_TARGET_REBOUND pid=" . backgroundPidV63
            . " hwnd=" . backgroundHwndV63 . " tool_focus_required=0")
        return backgroundHwndV63
    }
    finally
        resolving := false
}


GameTargetMessageV63(hwnd,msg,wParam,lParam)
{
    if (!hwnd || GameTargetHwndV63()!=hwnd)
        return false
    return DllCall("PostMessage","Ptr",hwnd,"UInt",msg,"UPtr",wParam,"Ptr",lParam)
}

GameTargetKeyV63(spec)
{
    global sigBusyV147,sigSendingKeyV147,sigTownV148,sigTownSendingV148
    if (IsObject(sigTownV148) && !sigBusyV147 && !sigTownSendingV148 && !InStr(spec," up}"))
    {
        MapKeyTraceV174(spec,"BLOCK_SIG_TOWN")
        return false
    }
    if (sigBusyV147 && !sigSendingKeyV147 && !InStr(spec," up}"))
    {
        MapKeyTraceV174(spec,"BLOCK_SIG_BUSY")
        return false
    }
    if (!RegExMatch(spec,"i)^\{?(?:Ctrl|LControl)(?:\s+(?:down|up))?\}?$"))
        MovementCtrlSetV78(false,0,"KEY " . spec)
    static held := {}
    key := Trim(spec), action := ""
    if (RegExMatch(key,"^\{(.+?)(?:\s+(down|up))?\}$",m))
        key := m1, action := m2
    if (action!="up" && !DeathlordPressGateV87(key))
    {
        MapKeyTraceV174(spec,"BLOCK_DEATHLORD_GATE")
        return false
    }
    if (key="LButton" || key="RButton" || key="MButton" || key="XButton1" || key="XButton2"
        || key="WheelUp" || key="WheelDown")
        return GameTargetMouseKeyV64(key,action)
    vk := GetKeyVK(key), sc := GetKeySC(key)
    if (!vk)
    {
        MapKeyTraceV174(spec,"BLOCK_INVALID_KEY")
        return false
    }
    lp := 1 | ((sc & 255)<<16) | ((sc & 256) ? 0x1000000 : 0)
    if (action="up" && held.HasKey(key))
    {
        target := held[key], held.Delete(key)
        WinGet, pid, PID, % "ahk_id " . target.hwnd
        if (!DllCall("IsWindow","Ptr",target.hwnd) || pid!=target.pid || BackgroundBirthV63(pid)!=target.birth)
            return false
        return DllCall("PostMessage","Ptr",target.hwnd,"UInt",0x101,"UPtr",vk,"Ptr",lp|0xC0000000)
    }
    hwnd := GameTargetHwndV63()
    if (!hwnd)
    {
        MapKeyTraceV174(spec,"BLOCK_NO_TARGET")
        return false
    }
    WinGet, pid, PID, ahk_id %hwnd%
    birth := BackgroundBirthV63(pid)
    if (action="up")
        return GameTargetMessageV63(hwnd,0x101,vk,lp|0xC0000000)
    if (!GameTargetMessageV63(hwnd,0x100,vk,lp))
    {
        MapKeyTraceV174(spec,"KEYDOWN_FAILED")
        return false
    }
    MapKeyTraceV174(spec,"KEYDOWN_QUEUED")
    if (action="down")
    {
        held[key] := {hwnd:hwnd,pid:pid,birth:birth}
        return true
    }
    Sleep, 30
    WinGet, nowPid, PID, ahk_id %hwnd%
    if (!DllCall("IsWindow","Ptr",hwnd) || nowPid!=pid || BackgroundBirthV63(pid)!=birth)
        return false
    keyUpQueuedV174 := DllCall("PostMessage","Ptr",hwnd,"UInt",0x101,"UPtr",vk,"Ptr",lp|0xC0000000)
    MapKeyTraceV174(spec,"KEYUP_QUEUED=" . keyUpQueuedV174)
    return keyUpQueuedV174
}

GameTargetMouseKeyV64(key,action := "")
{
    MovementCtrlSetV78(false,0,"MOUSE_KEY " . key)
    global backgroundAimV64
    static held := {}
    hwnd := GameTargetHwndV63()
    if (action="up" && held.HasKey(key))
    {
        target := held[key], held.Delete(key)
        WinGet, pid, PID, % "ahk_id " . target.hwnd
        if (!DllCall("IsWindow","Ptr",target.hwnd) || pid!=target.pid || BackgroundBirthV63(pid)!=target.birth)
            return false
        return DllCall("PostMessage","Ptr",target.hwnd,"UInt",target.msg+1,"UPtr",target.upFlag,"Ptr",target.lp)
    }
    if (!hwnd)
        return false
    if (IsObject(backgroundAimV64) && backgroundAimV64.hwnd=hwnd)
        x := backgroundAimV64.x, y := backgroundAimV64.y
    else
    {
        VarSetCapacity(rect,16,0)
        if (!DllCall("GetClientRect","Ptr",hwnd,"Ptr",&rect))
            return false
        x := NumGet(rect,8,"Int")//2, y := NumGet(rect,12,"Int")//2
    }
    PortalLogWriteV66("MOUSE_KEY key=" . key . " action=" . action . " client_xy=" . x . "," . y . " hwnd=" . hwnd)
    lp := ((Round(y)&65535)<<16)|(Round(x)&65535)
    if (key="WheelUp" || key="WheelDown")
    {
        VarSetCapacity(pt,8,0), NumPut(x,pt,0,"Int"), NumPut(y,pt,4,"Int")
        if (!DllCall("ClientToScreen","Ptr",hwnd,"Ptr",&pt))
            return false
        lp := ((NumGet(pt,4,"Int")&65535)<<16)|(NumGet(pt,0,"Int")&65535)
        return GameTargetMessageV63(hwnd,0x20A,((key="WheelUp" ? 120 : -120)&65535)<<16,lp)
    }
    msg := key="LButton" ? 0x201 : key="RButton" ? 0x204 : key="MButton" ? 0x207 : 0x20B
    upFlag := key="XButton1" ? 0x10000 : key="XButton2" ? 0x20000 : 0
    flag := upFlag | (key="LButton" ? 1 : key="RButton" ? 2 : key="MButton" ? 16 : key="XButton1" ? 32 : 64)
    if (action="up")
        return GameTargetMessageV63(hwnd,msg+1,upFlag,lp)
    if (!GameTargetMessageV63(hwnd,0x200,0,lp) || !GameTargetMessageV63(hwnd,msg,flag,lp))
        return false
    if (action="down")
    {
        WinGet, pid, PID, ahk_id %hwnd%
        held[key] := {hwnd:hwnd,pid:pid,birth:BackgroundBirthV63(pid),msg:msg,upFlag:upFlag,lp:lp}
        return true
    }
    return GameTargetMessageV63(hwnd,msg+1,upFlag,lp)
}

GameTargetAimV63(x,y)
{
    global backgroundAimV64
    hwnd := GameTargetHwndV63()
    if (!GameTargetMessageV63(hwnd,0x200,0,((Round(y)&65535)<<16)|(Round(x)&65535)))
        return false
    backgroundAimV64 := {hwnd:hwnd,x:x,y:y}
    return true
}

GameTargetClickV63(button := "Right",x := -1,y := -1)
{
    MovementCtrlSetV78(false,0,"CLICK " . button)
    global autoMonsterAttackOn,scosEntryV162
    if (autoMonsterAttackOn && button="Left")
        PortalLogWriteV66("FARM_LEFT_CLICK requested_xy=" . x . "," . y . " source=WINDOW_CLICK helper=GameTargetClickV63")
    hwnd := GameTargetHwndV63()
    if (!hwnd)
        return false
    if ((x<0 || y<0) && button="Right" && IsObject(scosEntryV162)
        && scosEntryV162.map="BO" && scosEntryV162.phase="LOAD")
    {
        pointV454 := BOBuffPointV454(hwnd)
        if (!IsObject(pointV454))
            return false
        x := pointV454.x,y := pointV454.y
        PortalLogWriteV66("BO_FINAL_BUFF_AT_PLAYER client_xy=" . x . "," . y)
    }
    if (x<0 || y<0)
    {
        VarSetCapacity(rect,16,0)
        if (!DllCall("GetClientRect","Ptr",hwnd,"Ptr",&rect))
            return false
        x := NumGet(rect,8,"Int")//2, y := NumGet(rect,12,"Int")//2
    }
    lp := ((Round(y)&65535)<<16)|(Round(x)&65535)
    right := button="Right", msg := right ? 0x204 : 0x201, flag := right ? 2 : 1
    PortalLogWriteV66("WINDOW_CLICK button=" . button . " client_xy=" . x . "," . y . " hwnd=" . hwnd)
    if (!GameTargetMessageV63(hwnd,0x200,0,lp) || !GameTargetMessageV63(hwnd,msg,flag,lp))
        return false
    return GameTargetMessageV63(hwnd,msg+1,0,lp)
}

; V454: buff chinh minh tai vi tri nhan vat thuc tren man hinh.
; Neu khong doc duoc vi tri thi KHONG click giua man hinh (co the cham NPC).
GameTargetBuffSelfClickV454()
{
    hwndV454 := GameTargetHwndV63()
    if (!hwndV454)
        return false
    pointV454 := BOBuffPointV454(hwndV454)
    if (!IsObject(pointV454))
    {
        PortalLogWriteV66("BUFF_SELF_SKIP reason=PLAYER_SCREEN_POINT_UNAVAILABLE hwnd=" . hwndV454)
        return false
    }
    if (GameTargetHwndV63()!=hwndV454)
        return false
    PortalLogWriteV66("BUFF_SELF_CLICK client_xy=" . pointV454.x . "," . pointV454.y . " hwnd=" . hwndV454)
    return GameTargetClickV63("Right",pointV454.x,pointV454.y)
}

BackgroundHotkeyV63(key,label,options)
{
    if (label="Master456Handler" && !InStr(options,"Off"))
        return
    testKey := RegExReplace(key, "^[~*$<>!^+#]+")
    if (testKey = "" || testKey = "None" || testKey = "none" || testKey = "NONE" || testKey = "ERROR")
        return
    plainKey := RegExReplace(testKey, "^\^")
    if (!GetKeyVK(plainKey) && !GetKeySC(plainKey))
        return
    Hotkey, If, % Func("IsGameForegroundV63")
    Hotkey, %key%, %label%, %options%
    result := ErrorLevel
    Hotkey, If
    ErrorLevel := result
}

QCastTimer:
if (farmUserPausedV2026 && !castManualToggleV1801)
    return
if (buffSequenceRunningV555 || farmBuffExclusiveV621 || zRunning)
    return
FarmBuffTownSyncV509()
if (FarmTravelNoBuffV670() || CainCaveMoveActiveV502() || (autoMonsterAttackOn && !Stage2FightEnabledV9()))
    return
if (IsObject(sigTownV148))
    return
if (sigBusyV147)
    return
if (packetWatchArmedV1)
    return
if (master456Paused)
    return
if (xRunning)
    return
if (!QCastOn || (farmBuffModeV509!=1 && !castManualToggleV1801))
    return

if (!IsGameActive())
    return


Loop, 3
{
    if (!QCastOn || master456Paused || xRunning || zRunning || farmBuffExclusiveV621 || !IsGameActive())
        break
    qIndex := A_Index
    qKey := QCastKey%qIndex%
    qDelay := QCastDelay%qIndex%
    qLast := qCastLast%qIndex%

    if (qKey = "" || qKey = "None")
        continue

    if (qDelay < 0)
        qDelay := 0

    if (qLast = "" || qLast = 0 || A_TickCount - qLast >= qDelay)
    {
        if (QCastSendKey(qKey))
            qCastLast%qIndex% := A_TickCount
    }
}
return

FarmCastSyncV88(on)
{
    global QCastOn, master456Paused, master456Saved,farmBuffModeV509
    global qCastLast1, qCastLast2, qCastLast3, lastQCastDoubleKeyTime
    if (on && FarmTravelNoBuffV670())
        on := false
    if (on && master456Paused)
        master456Paused := false,master456Saved := false
    if (IsObject(master456Saved))
        master456Saved.cast := on ? true : false
    QCastOn := on && !master456Paused
    if (on)
        qCastLast1 := A_TickCount, qCastLast2 := A_TickCount, qCastLast3 := A_TickCount
    lastQCastDoubleKeyTime := 0
}

; Add only the manual CAST toggle/UI state to existing farm START and STOP.
; Do not replace any old start/stop action, pickup handoff, or pause behavior.
FarmCastToggleSetOnStartStopV2026(on,reason := "")
{
    global castManualToggleV1801,QCastOn
    castManualToggleV1801 := on ? true : false
    if (!on)
        QCastOn := false
    ; When START runs in town, existing FarmBuffTownSyncV509 still decides
    ; when the automatic CAST may actually fire after entering farm.
    GuiControl, 1:, CastToggleStatusV1801, % (castManualToggleV1801 ? "ON" : "OFF")
    PortalLogWriteV66("FARM_START_STOP_CAST reason=" . reason
        . " shortcut=" . (castManualToggleV1801 ? "ON" : "OFF") . " qcast=" . QCastOn)
}

FarmBuffStartV509()
{
    global farmBuffModeV509,QCastOn,master456Paused,master456Saved
    farmBuffModeV509 := 1,master456Paused := false,master456Saved := false
    QCastOn := false
    ResetAfterQuickBuff()
    FarmBuffTownSyncV509(true)
    PickupEnabledSetV71(true,true,false)
    FarmCastToggleSetOnStartStopV2026(true,"START")
    PortalLogWriteV66("BUFF_GROUPS_START cast4=TOWN_SYNC group5=BUFF_ONCE cycle6=MANUAL")
}

FarmBuffStopV509()
{
    global farmBuffModeV509,QCastOn,clickCastOn,cycleOn,master456Saved
    global sigBusyV147, sigCancelV147
    BuffSequenceSetV555(false)
    farmBuffModeV509 := 0,QCastOn := false,clickCastOn := false,cycleOn := false
    if (sigBusyV147) {
        sigCancelV147 := true
        sigBusyV147 := false
    }
    Cycle6GuiSyncV525()
    PickupCtrlEndV26()
    PickupEnabledSetV71(false,true,false)
    if (IsObject(master456Saved))
        master456Saved := {cast:false,click:false,cycle:false}
    FarmCastToggleSetOnStartStopV2026(false,"STOP")
    PortalLogWriteV66("BUFF_GROUPS_STOP cast4=OFF click5=OFF cycle6=OFF manual=AVAILABLE")
}

FarmBuffTownSyncV509(force := false)
{
    global farmBuffModeV509,QCastOn,master456Paused,qCastLast1,qCastLast2,qCastLast3,buffSequenceOnV555
    global farmControlOwnerV186
    static lastScosTravelV653 := false
    static lastRead := 0,lastPid := 0,lastLevel := 0
    if (farmBuffModeV509!=1 || (!force && A_TickCount-lastRead<400))
        return
    lastRead := A_TickCount
    pid := D2GetActiveGamePidV95()
    level := pid ? RoomRecordLevelV259(pid) : 0
    if (!level)
        return
    town := FarmReviveTownLevelV295(level)
    scosTravelV653 := FarmTravelNoBuffV670(pid,level)
    changed := force || pid!=lastPid || level!=lastLevel || town!=FarmReviveTownLevelV295(lastLevel)
        || scosTravelV653!=lastScosTravelV653
    lastPid := pid,lastLevel := level,lastScosTravelV653 := scosTravelV653
    if (!changed)
        return
    QCastOn := (buffSequenceOnV555 || (!town && !scosTravelV653)) && !master456Paused
    if (QCastOn)
        qCastLast1 := A_TickCount,qCastLast2 := A_TickCount,qCastLast3 := A_TickCount
    if (!town)
        FarmPickupSyncV57(0,0,-1,true)
    PortalLogWriteV66("CAST4_TOWN_TRANSITION level=" . level . " town=" . town
        . " cast4=" . QCastOn . " apply=ONCE manual=AVAILABLE")
}

FinalQuestItemV511(h,item)
{
    return IsObject(item) && (item.cls=1825 || item.cls=1839)
        && item.data && D2ReadU8V18(h,item.data)=7
}

QCastSendKey(key)
{
    global zRunning,farmBuffExclusiveV621
    global zKey, xKey, QCastOn, master456Paused, xRunning

    if (!QCastOn || master456Paused || xRunning || zRunning || farmBuffExclusiveV621 || !IsGameActive())
        return false
    key := Trim(key)
    if (key = "" || key = "None")
        return

    if (key = zKey)
    {
        Gosub, ZKeyHandler
        return true
    }

    if (key = xKey)
    {
        Gosub, XKeyHandler
        return true
    }

    if (!IsGameActive())
        return
    GameTargetKeyV63("{" . key . "}")
    Sleep, 200
    if (!IsGameActive() || !QCastOn || master456Paused || xRunning || zRunning || farmBuffExclusiveV621)
        return false
    GameTargetKeyV63("{" . key . " down}")
    try
    {
        Sleep, 200
    }
    finally
    {
        GameTargetKeyV63("{" . key . " up}")
    }
    return true
}

GetStepCount()
{
    global FKey1, FKey2, FKey3, FKey4
    global FKey5, FKey6, FKey7, FKey8
    global FKey9, FKey10

    Loop, 5
    {
        index := A_Index
        key := FKey%index%

        if (!QuickBuffHasKey(key))
            return index - 1
    }

    return 5
}

Cycle1Timer:
if (buffSequenceRunningV555 || farmBuffExclusiveV621)
    return
if (gameItemActionOwner!="" || IsObject(autoMonsterPacketPendingV1))
    return
if (FarmAttackHoldingV15())
    return
if (FarmTravelNoBuffV670() || CainCaveMoveActiveV502() || (autoMonsterAttackOn && !Stage2FightEnabledV9()))
    return
if (IsObject(sigTownV148))
    return
if (sigBusyV147)
    return
if (packetWatchArmedV1)
    return
if (master456Paused)
    return

if (!cycleOn)
    return

if (!cycle1On)
    return

if (zRunning)
    return

if (xRunning)
    return

if (!IsGameActive())
    return

if (nextStepTime != 0 && A_TickCount < nextStepTime)
    return

stepCount := GetStepCount()

if (stepCount <= 0)
    return

if (cycleStep > stepCount)
    cycleStep := 1

key := FKey%cycleStep%
delay := FDelay%cycleStep%

if (!QuickBuffHasKey(key))
{
    cycleStep := 1
    return
}

if (!IsGameActive())
    return
if (!GameTargetKeyV63("{" . key . "}"))
    return

nextStepTime := A_TickCount + delay

cycleStep++

if (cycleStep > stepCount)
    cycleStep := 1

return


ResetCastDelayWhenManualKey(key)
{
    global QCastKey1, QCastKey2, QCastKey3
    global qCastLast1, qCastLast2, qCastLast3, clickCastRows
    if (!IsGameForegroundV63())
        return
    key := Trim(key)
    if (key = "" || key = "None")
        return
    now := A_TickCount
    Loop, 3
    {
        i := A_Index
        castKey := QCastKey%i%
        if (CastKeysMatch(castKey, key))
            qCastLast%i% := now
    }
    for _, row in clickCastRows
        if (CastKeysMatch(row.key, key))
            row.last := now
}

ManualCastKeyDown(ih, vk, sc)
{
    global xRunning
    if (xRunning)
        return
    key := GetKeyName(Format("vk{:02X}sc{:03X}", vk, sc))
    ResetCastDelayWhenManualKey(key)
}

CastKeysMatch(configKey, pressedKey)
{
    if (configKey = "" || configKey = "None")
        return false
    configSC := GetKeySC(configKey)
    pressedSC := GetKeySC(pressedKey)
    if (configSC && pressedSC)
        return configSC = pressedSC
    configVK := GetKeyVK(configKey)
    return configVK && configVK = GetKeyVK(pressedKey)
}

ZKeyHandler:
if (!IsGameForegroundV63())
    return
if (sigBusyV147)
    return
if (packetWatchArmedV1)
    return
if (A_ThisHotkey != "")
    ResetCastDelayWhenManualKey(zKey)


if (!IsGameActive())
    return

if (zRunning)
    return

if (xRunning)
    return

zRunning := true
zRunEpochV535 := farmRunEpochV535
DebugTraceWrite("character", "BUFF_START source=Z")

oldCycleOn := cycleOn
cycleOn := false

FarmSkillBaselineEnsureV621(D2GetActiveGamePidV95())
if (zSetKey != "" && zSetKey != "None")
{
    if (!IsGameActive())
        goto, ZKeyCleanup
    BuffCheckedSendV29(zSetKey)
    Sleep, %zSetDelay%
    if (!IsGameActive())
        goto, ZKeyCleanup
}

if (zFKey != "" && zFKey != "None")
{
    if (!IsGameActive())
        goto, ZKeyCleanup
    BuffCheckedSendV29(zFKey)
    Sleep, 30
    if (!IsGameActive())
        goto, ZKeyCleanup
    if (!IsGameActive())
        goto, ZKeyCleanup
    if (!GameTargetBuffSelfClickV454())
        goto, ZKeyCleanup
    Sleep, %zDelay1%
    if (!IsGameActive())
        goto, ZKeyCleanup
}

if (zFKey2 != "" && zFKey2 != "None")
{
    if (!IsGameActive())
        goto, ZKeyCleanup
    BuffCheckedSendV29(zFKey2)
    Sleep, 30
    if (!IsGameActive())
        goto, ZKeyCleanup
    if (!IsGameActive())
        goto, ZKeyCleanup
    if (!GameTargetBuffSelfClickV454())
        goto, ZKeyCleanup
    Sleep, %zDelay2%
    if (!IsGameActive())
        goto, ZKeyCleanup
}

if (zSetKey != "" && zSetKey != "None")
{
    if (!IsGameActive())
        goto, ZKeyCleanup
    BuffSetReturnV500(zSetKey,zSetDelay)
    BuffSetFixRightV500(zFKey2,zFKey)
}

ZKeyCleanup:
cycleStep := 1
nextStepTime := 0
if (zRunEpochV535=farmRunEpochV535)
    cycleOn := oldCycleOn
zRunning := false
return

XKeyHandler:
if (!IsGameForegroundV63())
    return
if (sigBusyV147)
    return
if (packetWatchArmedV1)
    return
if (!IsGameActive() || xRunning || zRunning)
    return
if (A_ThisHotkey != "")
    ResetCastDelayWhenManualKey(XKey)
xRunning := true
DebugTraceWrite("character", "BUFF_START source=X")
try
    QuickBuffRun()
finally
{
    ResetAfterQuickBuff()
    xRunning := false
    FarmSetVerifyTrigger()
}
return

DoubleKeyHandler:
if (!IsGameForegroundV63())
    return
if (master456Paused)
    return
if (xRunning)
    return

if (doubleKeyHeld)
    return
doubleKeyHeld := true
SetTimer, DoubleKeyReleaseWatch, 10

if (!IsGameActive())
    return

currentTime := A_TickCount

if (lastDoubleKeyTime != 0)
{
    elapsed := currentTime - lastDoubleKeyTime

    if (elapsed <= doubleTapMs)
    {
        cycleOn := !cycleOn
        Cycle6GuiSyncV525()

        cycleStep := 1
        nextStepTime := 0

        if (cycleOn)
            ToolTipInfoV386("Auto Bấm Dãy F: ON")
        else
            ToolTipInfoV386("Auto Bấm Dãy F: OFF")

        SetTimer, RemoveToolTip, -3000
        lastDoubleKeyTime := 0
        return
    }
}

lastDoubleKeyTime := currentTime

return

QCastDoubleKeyHandler:
return

FormDoubleKeyHandler:
if (!IsGameForegroundV63())
    return
if (xRunning)
    return

if (formDoubleKeyHeld)
    return
formDoubleKeyHeld := true
SetTimer, FormDoubleKeyReleaseWatch, 10

currentTime := A_TickCount

if (lastFormDoubleKeyTime != 0)
{
    elapsed := currentTime - lastFormDoubleKeyTime

    if (elapsed <= formDoubleTapMs)
    {
        if (configGuiVisible)
        {
            Gosub, SaveFormPosition
            Gui, Hide
            configGuiVisible := false
        }
        else
        {
            Gosub, ShowConfig
        }

        lastFormDoubleKeyTime := 0
        return
    }
}

lastFormDoubleKeyTime := currentTime

return

FarmInfoTranslateV4(message)
{
    if (RegExMatch(message,"i)(?:ghi log|xuất log|ghi tình trạng|\[INFO\]|đã xuất map)"))
        return ""
    if (RegExMatch(message,"i)[:：]\s*(?:ON|OFF|BẬT|TẮT)(?:\s*[—-]\s*ĐÃ HỦY DI CHUYỂN)?\s*$") )
        return ""
    if (RegExMatch(message,"i)(?:NO_SELECTED_ROUTE|NO_ROUTE_FILE|MAP_LOAD_WAIT|CAIN_LOAD_WAIT)"))
        return "Đang chờ file lộ trình khớp map hiện tại."
    if (RegExMatch(message,"i)(?:READ_FAILED|PLAYER_NOT_READABLE|LIVE_MAP_READ_FAILED)"))
        return "Chưa đọc được dữ liệu game; đang chờ lượt đọc tiếp theo."
    if (RegExMatch(message,"i)NO_LIVE_TARGET"))
        return "Chưa thấy quái sống hợp lệ để đánh trong lượt quét."
    if (RegExMatch(message,"i)(?:STUCK.*TELE|DELAY_TELEPORT|TELEPORT.*DISPATCH)"))
        return "Đang thử teleport để thoát chỗ kẹt."
    if (RegExMatch(message,"i)(?:ROUTE_MOVE|MAP_MOVE_DISPATCH)"))
        return "Đã gửi lệnh đi tới điểm tiếp theo; đang chờ vị trí thay đổi."
    if (RegExMatch(message,"i)MAP_MOVE_WAIT"))
        return "Nhân vật đang thực hiện thao tác khác; lệnh đi đang chờ."
    if (RegExMatch(message,"i)ROUTE_NO_PROGRESS"))
        return "Đã gửi lệnh đi nhưng nhân vật chưa tiến tới điểm đích."
    if (RegExMatch(message,"i)(?:ROUTE_WAIT|MAP_LOAD_WAIT|CAIN_LOAD_WAIT)"))
        return "Đang chờ dữ liệu lộ trình phù hợp với map hiện tại."
    if (RegExMatch(message,"i)(?:CAIN_EXIT|WAIT_MAP_CHANGE)"))
        return "Đã gửi lệnh vào cổng; đang chờ xác nhận chuyển map."
    if (RegExMatch(message,"i)MAP_STAGE2_DONE"))
        return "Đã đi hết lộ trình; đang chờ bước hoàn tất của map."
    if (RegExMatch(message,"i)(?:STAGE2_ROUTE_NEW|RUN_RESET_FROM_YELLOW|FARM_START_FROM_YELLOW)"))
        return "Đã nạp lộ trình mới từ dòng vàng."
    if (RegExMatch(message,"i)CAIN_ROOM_NEXT"))
        return "Đã chọn phòng tiếp giáp; đang tìm đường sang phòng đó."
    if (RegExMatch(message,"i)CAIN_WALL_BLOCKED"))
        return "Đường đang bị chặn; đang lần vách trái tìm lối đi."
    if (RegExMatch(message,"i)SCOS_241_STANDARD_BEGIN"))
        return "Scos map 241: đang đi lộ trình chuẩn, không đánh và không nhặt."
    if (RegExMatch(message,"i)SCOS_241_STANDARD_END"))
        return "Đã rời map 241; tiếp tục quy trình farm Scos."
    if (RegExMatch(message,"[À-ỹĐđ]") && !RegExMatch(message,"[A-Za-z_][A-Za-z_0-9]*=|V\d{2,}|_[A-Z]{2,}"))
        return message
    return ""
}

FarmInfoEventV4(message)
{
    global manualLogOnV81,farmInfoEventV4
    if (!manualLogOnV81)
        return
    readable := FarmInfoTranslateV4(message)
    if (readable!="")
        farmInfoEventV4 := {text:readable,at:A_TickCount}
}

FarmInfoLogStartV4()
{
    global fonInfoOnV385,fonInfoLogV385,farmInfoSessionV4,farmInfoPreviousV4
    global farmInfoEventV4,farmInfoLastV4,farmInfoLastAtV4,manualLogFilesV98
    global fonInfoAutoStuckV552
    fonInfoAutoStuckV552 := false
    farmInfoPreviousV4 := fonInfoOnV385,farmInfoSessionV4 := true
    farmInfoEventV4 := false,farmInfoLastV4 := "",farmInfoLastAtV4 := 0
    fonInfoLogV385 := []
    manualLogFilesV98["Auto-GSF-Tinh-Trang.txt"] := true
    FonInfoPushV385("Bắt đầu ghi tình trạng; Info chỉ quan sát hoạt động hiện tại.")
    ManualLogAppendV81(A_Now . " | Bắt đầu ghi tình trạng.`r`n",TxtRootPathV816("Auto-GSF-Tinh-Trang.txt"))
    SetTimer, FarmInfoLogTimerV589, 500
}

FarmInfoLogTimerV589:
if (farmInfoSessionV4)
    FarmInfoWriteStateV4(FarmInfoStateV4())
else
    SetTimer, FarmInfoLogTimerV589, Off
return

FarmInfoLogStopV4()
{
    global fonInfoOnV385,farmInfoSessionV4,farmInfoPreviousV4,farmInfoEventV4,FonInfoHwndV385
    if (!farmInfoSessionV4)
        return
    ManualLogAppendV81(A_Now . " | " . StrReplace(FarmInfoStateV4(),"`r`n"," ")
        . "`r`n" . A_Now . " | Đã dừng ghi tình trạng.`r`n",TxtRootPathV816("Auto-GSF-Tinh-Trang.txt"))
    SetTimer, FarmInfoLogTimerV589, Off
    farmInfoSessionV4 := false,farmInfoEventV4 := false
}

FarmInfoPhaseV4(phase)
{
    names := {"WP":"đi tới hoặc tìm WP","OPEN_WAIT":"chờ bảng WP mở"
        ,"SELECT_WAIT":"chờ chuyển map sau khi chọn WP","WALK":"di chuyển tới cửa map"
        ,"COMBAT":"đi qua map trung gian","FARM":"farm trong map","LOAD":"chờ nạp lộ trình"
        ,"CUBE":"xử lý vật phẩm trong cube để mở cổng","PORTAL":"tìm hoặc chờ vào cổng"
        ,"EXIT_PORTAL":"đi ra khỏi cổng vừa vào","WAIT_MAP":"chờ xác nhận chuyển map"
        ,"MAP":"chuẩn bị lộ trình trong map","ENTRY_BUFF":"buff trước khi di chuyển"
        ,"CAVE_MOVE":"lần vách và tìm đường sang phòng kế bên","EXIT":"tiếp cận cổng thoát"}
    return names.HasKey(phase) ? names[phase] : "chuẩn bị bước tiếp theo"
}

FarmInfoStateV4()
{
    global
    local text,prefix,row,point,phase,c,steps
    prefix := farmControlOwnerV186!="" ? farmControlOwnerV186 . ": " : ""
    if (sigTerminalErrorV762!="")
        return "SIG đã dừng: " . sigTerminalErrorV762
    if (backgroundBlockReasonV553!="")
        return backgroundBlockReasonV553
    if (!backgroundHwndV63 || !DllCall("IsWindow","Ptr",backgroundHwndV63))
        return "Chưa nhận được cửa sổ game để tiếp tục."
    if (sigBusyV147)
        return "Đang SIG " . (sigActiveModeV182="SET" ? "Set" : sigActiveModeV182="SU" ? "SU" : "vật phẩm") . "; chờ cube và thu hồi đồ xong."
    if (IsObject(ticketPickupWaitV279) && ticketPickupWaitV279.sigScopeV654)
        return prefix . "SIG đã xong; đang nhặt và chờ Done trước khi di chuyển."
    if (IsObject(scosEntryV162) && scosEntryV162.stage1SigBlockedV654
        && !scosEntryV162.stage1SigDoneV374 && !scosEntryV162.preSigDoneV310)
        return prefix . "SIG chưa hoàn tất: " . sigLastStopReasonV63
    if (IsObject(sigTownV148))
        return "Đang làm quy trình về thành, sắp đồ và SIG."
    if (IsObject(stageTwoV166))
    {
        if (stageTwoV166.loginRecoveryV489)
            return "Đang khôi phục đăng nhập game theo quy trình hiện có."
        steps := {"ESC":"mở menu thoát phòng","SAVE_EXIT":"lưu và thoát phòng cũ"
            ,"WAIT_LOBBY":"chờ màn hình tạo phòng","NAME_FIELD":"chọn ô tên phòng"
            ,"TYPE_NAME":"điền tên phòng mới","CREATE":"bấm tạo phòng","WAIT_GAME":"chờ vào phòng mới"
            ,"RECOVER":"kiểm tra lại màn hình game"}
        phase := stageTwoV166.phase
        return "Giai đoạn tạo phòng: " . (steps.HasKey(phase) ? steps[phase] : "chờ game xử lý bước hiện tại") . "."
    }
    if (xRunning || zRunning)
        return xRunning ? "Đang buff nhanh; farm chờ buff xong." : "Đang buff set phụ; chờ chuyển về set chính."
    if (IsObject(farmReviveV32) || reviveBuffPendingV34)
        return "Đang hồi sinh hoặc chuẩn bị buff để trở lại map."
    if (gameItemActionOwner!="")
        return gameItemActionOwner="Pickup" ? "Đang nhặt hoặc cất đồ; farm chờ thao tác này xong." : "Đang xử lý vật phẩm; farm đang chờ."
    if (petLearnOnV12)
        return "Đang lấy ID pet; farm chờ thao tác này xong."
    if (packetWatchArmedV1)
        return "Đang thu lệnh game để kiểm tra; farm chờ thao tác này xong."
    c := FarmInfoStuckStateV552()
    if (IsObject(c))
        return prefix . "Đang xử lý kẹt tại dòng " . (c.row+1) . "; thử đường đi hoặc teleport để thoát."
    if (currentAttackUidV520 && A_TickCount-currentAttackAtV520<1500)
        return prefix . "Vừa gửi lệnh đánh ID " . currentAttackClassV520 . ", UID " . currentAttackUidV520 . ", khoảng cách " . currentAttackDistV523 . "."
    if (IsObject(autoMonsterPacketPendingV1))
        return prefix . "Đang chờ game xử lý lệnh vừa gửi."
    if (monsterCombatUidV45)
        return prefix . "Đang giữ mục tiêu quái cá thể " . monsterCombatUidV45 . "; chưa chuyển sang đi tiếp."
    if (IsObject(scosEntryV162) && !IsObject(scosEntryV162.commonRouteV3))
    {
        phase := scosEntryV162.map="CAIN" && scosEntryV162.cainPhaseV383!="" ? scosEntryV162.cainPhaseV383 : scosEntryV162.phase
        text := prefix . "Đang " . FarmInfoPhaseV4(phase) . "."
    }
    else if (autoMonsterAttackOn || IsObject(coordGoV59))
    {
        row := IsObject(coordRouteV16) ? coordRouteV16.next : 0
        point := IsObject(coordGoV59) ? coordGoV59 : coordSavedV15[row]
        if (IsObject(coordRouteV16) && coordRouteV16.phase="DONE")
            text := prefix . "Đã hết lộ trình; đang chờ bước hoàn tất hoặc về thành."
        else if (IsObject(point))
            text := prefix . "Đi tới " . point.x . ", " . point.y . (row ? " (dòng " . row . ")" : "") . "."
        else
            text := prefix . "Chưa có điểm đến hợp lệ; đang chờ lộ trình."
        if (IsObject(scosEntryV162) && IsObject(scosEntryV162.commonRouteV3))
            text .= " Chế độ không đánh, không nhặt."
    }
    else
        text := prefix . (FarmControlRunningV186() ? "Đang chờ bước tiếp theo." : "Farm đã dừng.")
    c := coordCursorSnapshotV390
    if (IsObject(c) && A_TickCount-c.at<2000)
        text .= "`r`nVị trí vừa đọc: map " . c.level . ", tọa độ " . c.x . ", " . c.y . "."
    if (IsObject(farmInfoEventV4) && A_TickCount-farmInfoEventV4.at<4000)
        text .= "`r`n" . farmInfoEventV4.text
    return text
}

FarmInfoWriteStateV4(text)
{
    global manualLogOnV81,farmInfoLastV4,farmInfoLastAtV4
    if (!manualLogOnV81 || (text=farmInfoLastV4 && A_TickCount-farmInfoLastAtV4<3000))
        return
    farmInfoLastV4 := text,farmInfoLastAtV4 := A_TickCount
    ManualLogAppendV81(A_Now . " | " . StrReplace(text,"`r`n"," ") . "`r`n",TxtRootPathV816("Auto-GSF-Tinh-Trang.txt"))
}

FonInfoPushV385(text,displayRaw := false)
{
    global fonInfoOnV385, fonInfoLogV385
    if (!fonInfoOnV385)
        return
    if (!IsObject(fonInfoLogV385))
        fonInfoLogV385 := []
    if (!displayRaw && InStr(text,"Mục tiêu ID:")=1)
        return
    text := displayRaw ? RegExReplace(text,"[\r\n]+"," | ") : FarmInfoTranslateV4(text)
    if (text="")
        return
    FormatTime, tsV385,, HH:mm:ss
    fonInfoLogV385.Push(tsV385 . " " . text)
    while (fonInfoLogV385.Length()>8)
        fonInfoLogV385.RemoveAt(1)
}

ToolTipInfoV386(text, x := "", y := "", which := 1)
{
    global fonInfoOnV385,viewIdV54,viewPosV291,viewTipV640
    static lastOverlayText := {}
    if (text = "")
        return
        
    if (viewTipV640)
    {
        if (x = "" || y = "")
            ToolTip, %text%
        else
            ToolTip, %text%, %x%, %y%
        SetTimer, RemoveToolTip, -2500
        
        if (fonInfoOnV385)
            FonInfoPushV385(text,true)
        return
    }
    
    if (!fonInfoOnV385)
    {
        lastOverlayText := {}
        return
    }
    if ((which=2 && !viewIdV54) || (which=20 && !viewIdV54 && !viewPosV291))
        return
    if (which!=1 && lastOverlayText.HasKey(which) && lastOverlayText[which]=text)
        return
    lastOverlayText[which] := text
    FonInfoPushV385(text,true)
}

FonInfoTimerV385:
FonInfoRenderV385()
return

FarmElapsedStartV1350()
{
    global farmElapsedStartedAtV1350,farmElapsedSavedSecV1350
    if (farmElapsedStartedAtV1350!="")
        return
    farmElapsedStartedAtV1350 := A_Now
    farmElapsedSavedSecV1350 := 0
}

FarmElapsedStopV1350()
{
    global farmElapsedStartedAtV1350,farmElapsedSavedSecV1350
    if (farmElapsedStartedAtV1350="")
        return
    secondsV1350 := A_Now
    EnvSub, secondsV1350, %farmElapsedStartedAtV1350%, Seconds
    farmElapsedSavedSecV1350 := Max(0,secondsV1350)
    farmElapsedStartedAtV1350 := ""
}

FarmElapsedTextV1350()
{
    global farmElapsedStartedAtV1350,farmElapsedSavedSecV1350
    secondsV1350 := farmElapsedSavedSecV1350
    if (farmElapsedStartedAtV1350!="")
    {
        secondsV1350 := A_Now
        EnvSub, secondsV1350, %farmElapsedStartedAtV1350%, Seconds
    }
    secondsV1350 := Max(0,Floor(secondsV1350))
    hoursV1350 := Floor(secondsV1350/3600)
    minutesV1350 := Mod(Floor(secondsV1350/60),60)
    secondsRemainderV1350 := Mod(secondsV1350,60)
    return "H: " . hoursV1350 . " giờ " . Format("{:02d}",minutesV1350)
        . " phút " . Format("{:02d}",secondsRemainderV1350)
}

FonInfoRenderV385()
{
    global fonInfoOnV385,FonInfoHwndV385,fonInfoLogV385,farmControlOwnerV186,mapWorkflowV185
    global coordCursorSnapshotV390,coordYellowRowV350,coordSavedV15,stageTwoV166
    global sigBusyV147,sigActiveModeV182,pickupImageOn,QCastOn,cycleOn,xRunning,zRunning
    global currentAttackUidV520,currentAttackClassV520,currentAttackAtV520,currentAttackDistV523
    global currentAttackPidV550,backgroundPidV63,FonInfoBodyV385,autoMonsterAttackOn,FonInfoStatusV622,cainNoFightV361,FonInfoGD4TimerV659
    global backgroundBlockReasonV553, farmScanListV682, farmScanSelectedV682
    global farmGroundItemCountV710, farmItemLockV625,farmStuckSkipInfoV1234,castManualToggleV1801

    if (!fonInfoOnV385)
    {
        SetTimer, FonInfoTimerV385, Off
        return
    }
	    if (!fonInfoOnV385)
    {
        SetTimer, FonInfoTimerV385, Off
        return
    }

    MouseGetPos,,,hoverWinV385
    gamePidV385 := backgroundPidV63 ? backgroundPidV63 : D2GetActiveGamePidV95()
    hoverPidV385 := 0
    if (hoverWinV385 && hoverWinV385 != FonInfoHwndV385)
        WinGet, hoverPidV385, PID, ahk_id %hoverWinV385%
    if (!hoverWinV385 || !gamePidV385
        || (hoverWinV385 != FonInfoHwndV385 && hoverPidV385 != gamePidV385))
    {
        if (DllCall("IsWindow","Ptr",FonInfoHwndV385))
            Gui, FonInfoV385:Hide
        return
    }

    state := FarmInfoStateV4()
    FarmInfoWriteStateV4(state)
    hwnd := GameTargetHwndV63()
    state := FarmInfoStateV4()
    FarmInfoWriteStateV4(state)
    hwnd := GameTargetHwndV63()
    if (!hwnd)
    {
        if (DllCall("IsWindow","Ptr",FonInfoHwndV385))
            Gui, FonInfoV385:Hide
        return
    }
    VarSetCapacity(rect,16,0),VarSetCapacity(origin,8,0)
    if (!DllCall("GetClientRect","Ptr",hwnd,"Ptr",&rect)
        || !DllCall("ClientToScreen","Ptr",hwnd,"Ptr",&origin))
        return
    gameW := NumGet(rect,8,"Int"),gameH := NumGet(rect,12,"Int")
    width := Max(170,Floor(gameW/8)),contentW := width-16,formH := 86
    left := NumGet(origin,0,"Int") + gameW - width - 5
    top := NumGet(origin,4,"Int") + 5
    if (!FonInfoHwndV385 || !DllCall("IsWindow","Ptr",FonInfoHwndV385))
    {
        Gui, FonInfoV385:Destroy
        Gui, FonInfoV385:New, +AlwaysOnTop -Caption +ToolWindow +E0x20 +HwndFonInfoHwndV385
        Gui, FonInfoV385:Color, 0F0F0F
        Gui, FonInfoV385:Font, s9 c00FF00, Consolas
        Gui, FonInfoV385:Font, s8 c00FF00, Arial
        Gui, FonInfoV385:Add, Text, x8 y5 w%contentW% h16 +0xC vFonInfoGD4TimerV659 BackgroundTrans
        Gui, FonInfoV385:Add, Text, x8 y23 w%contentW% h16 +0xC vFonInfoStatusV622 BackgroundTrans
        Gui, FonInfoV385:Font, s9 c00FF00, Consolas
        Gui, FonInfoV385:Add, Text, x8 y41 w%contentW% h56 vFonInfoBodyV385 BackgroundTrans
    }
        vitalsInfo := D2ReadHealVitalsV3()
    hpText := vitalsInfo.hp >= 0 ? vitalsInfo.hp : "Lỗi"
    pidText := vitalsInfo.pid ? vitalsInfo.pid : "N/A"
    
    gd4TimerTextV659 := FarmWatchTimerTextV659() . " | CAST: " . (castManualToggleV1801 ? "ON" : "OFF") . " | PID: " . pidText
    GuiControl, FonInfoV385:, FonInfoGD4TimerV659, %gd4TimerTextV659%
    
    vitalsDebug := D2ReadHealVitalsV3()
    hpText := vitalsDebug.hp >= 0 ? vitalsDebug.hp : "Lỗi"
    lvlDebug := RoomRecordLevelV259(backgroundPidV63)
    
    statusV615 := "HP: " . hpText . " | Map: " . lvlDebug
    GuiControl, FonInfoV385:, FonInfoStatusV622, %statusV615%

    scanTextV682 := ""
    if (IsObject(farmScanListV682) && farmScanListV682.Length() > 0)
    {
        selectedCV682 := false, othersV682 := []
        for _, cV682 in farmScanListV682
        {
            if (cV682.uid = farmScanSelectedV682)
                selectedCV682 := cV682
            else
                othersV682.Push(cV682)
        }
        orderedV682 := []
        if (IsObject(selectedCV682))
            orderedV682.Push(selectedCV682)
        for _, cV682 in othersV682
            orderedV682.Push(cV682)

        maxLinesV682 := 12, shownV682 := 0
        for _, cV682 in orderedV682
        {
            if (shownV682 >= maxLinesV682)
                break
            shownV682++
            markV682 := (cV682.uid = farmScanSelectedV682) ? "> " : "  "
            scanTextV682 .= "`r`n" . markV682 . cV682.cls . " | " . Round(Sqrt(cV682.dist), 1)
            if (cV682.priority)
                scanTextV682 .= " [BOSS]"
        }
        if (orderedV682.Length() > maxLinesV682)
            scanTextV682 .= "`r`n  ... +" . (orderedV682.Length() - maxLinesV682) . " nữa"
    }

    bgTextV682 := BackgroundActivityViewV693(hwnd)
        statusLineV682 := "FARM " . (autoMonsterAttackOn ? "ON" : "OFF")
        . " | BG " . bgTextV682 . "`r`n------------------"

    itemInfoV710 := "`r`nItem quét: " . (farmGroundItemCountV710+0)
    lockRadiusV710 := 0
    if (IsObject(farmItemLockV625))
        lockRadiusV710 := Round(Sqrt(farmItemLockV625.pickupRadiusSqV648))
    itemInfoV710 .= "`r`nKhóa BK nhặt: " . lockRadiusV710

    body := statusLineV682 . itemInfoV710
    body .= "`r`n--------------------`r`n" . ViewActivityStateV606()
    
    ; One compact line above DS QUET. New stuck target overwrites previous.
    body .= "`r`n----------------------"
    if (IsObject(farmStuckSkipInfoV1234))
    {
        lastClsV1234 := farmStuckSkipInfoV1234.cls >= 0 ? farmStuckSkipInfoV1234.cls : "?"
        lastDistV1234 := farmStuckSkipInfoV1234.dist >= 0 ? Round(farmStuckSkipInfoV1234.dist,1) : "?"
        body .= "`r`nID kẹt: " . lastClsV1234 . " | " . lastDistV1234
    }
    else
        body .= "`r`nID kẹt: -- | --"
    body .= "`r`n----------------------`r`n-- DS QUÉT (" . farmScanListV682.Length() . ") --"
    maxLinesV682 := 3
    linesAddedV682 := 0
    if (scanTextV682 != "")
    {
        body .= scanTextV682
        linesAddedV682 := StrLen(scanTextV682) ? StrSplit(scanTextV682, "`r`n").Length() - 1 : 0
    }
    Loop, % (maxLinesV682 - linesAddedV682)
        body .= "`r`n "
    body .= "`r`n----------------------`r`n" . FarmElapsedTextV1350()

    GuiControlGet, bodyHwndV605, FonInfoV385:Hwnd, FonInfoBodyV385
    dpiScaleV605 := A_ScreenDPI/96
    VarSetCapacity(textRectV605,16,0)
    NumPut(Round(contentW*dpiScaleV605),textRectV605,8,"Int")
    textDcV605 := DllCall("GetDC","Ptr",bodyHwndV605,"Ptr")
    if (textDcV605)
    {
        textFontV605 := DllCall("SendMessage","Ptr",bodyHwndV605,"UInt",0x31,"Ptr",0,"Ptr",0,"Ptr")
        oldFontV605 := textFontV605 ? DllCall("SelectObject","Ptr",textDcV605,"Ptr",textFontV605,"Ptr") : 0
        measuredV605 := DllCall("DrawTextW","Ptr",textDcV605,"WStr",body,"Int",-1,"Ptr",&textRectV605,"UInt",0xC10)
        if (oldFontV605)
            DllCall("SelectObject","Ptr",textDcV605,"Ptr",oldFontV605)
        DllCall("ReleaseDC","Ptr",bodyHwndV605,"Ptr",textDcV605)
        if (measuredV605>0)
            bodyHV605 := Ceil((NumGet(textRectV605,12,"Int")-NumGet(textRectV605,4,"Int"))/dpiScaleV605)+2
    }
    if (!bodyHV605)
        bodyHV605 := 90
    formH := bodyHV605+47
    GuiControl, FonInfoV385:Move, FonInfoBodyV385, w%contentW% h%bodyHV605%
    GuiControl, FonInfoV385:, FonInfoBodyV385, %body%
    Gui, FonInfoV385:Show, x%left% y%top% w%width% h%formH% NoActivate, Info
}

FarmWatchTimerTextV659()
{
    global farmWatchV5
    w := farmWatchV5
    if (!IsObject(w))
        return "Đứng: đang khởi tạo"
    if (!w.enabled)
        return "Đứng: tắt"
    ; The Info clock reports character inactivity, not SIG recovery locks.
    ; Live SIG work is character activity; stale pending SIG flags are not.
    ; Activity can override a stale wait even if its SIG flag is still set.
    elapsed := w.sigPausedV753 && !w.sigWaitBypassedV1080 ? 0
        : Floor(Max(0,FarmWatchNowV688()-w.idleAtV650)/1000)
    return "Đứng: " . elapsed . "/" . Round(w.period/1000) . "s"
}

ViewActivityStateV606()
{
    global farmCombatViewV624,backgroundPidV63,farmCenterCycleV741,farmRunEpochV535,farmScanListV682
    global backgroundBlockReasonV553,sigBusyV147,sigTownV148,stageTwoV166
    global ticketPickupWaitV279,sigLastStopReasonV63,sigTerminalErrorV762
    global xRunning,zRunning,farmReviveV32,reviveBuffPendingV34,gameItemActionOwner
    global petLearnOnV12,packetWatchArmedV1,autoMonsterAttackOn,coordGoV59,coordRouteV16
    global scosEntryV162,currentAttackUidV520,currentAttackAtV520,monsterCombatUidV45,currentAttackClassV520,currentAttackDistV523
    global monsterChaseV44,chaseCheckSecV9,teleportIntervalSecV56,farmItemLockV625
    global monsterLockNoDamageSecV621,monsterLockRoomSecV622
    activity := "đã dừng",stuck := "không"
    running := autoMonsterAttackOn || (IsObject(coordGoV59) && !coordGoV59.stop) || FarmControlRunningV186()
    r := IsObject(coordGoV59) && !coordGoV59.stop && IsObject(coordGoV59.routeV392)
        ? coordGoV59.routeV392 : coordRouteV16
    ; ITEM_MOVE su dung route rieng. Doc dung route nay de hien dong ho xet ket.
    itemGoalInfoV1801 := IsObject(farmItemLockV625) && IsObject(farmCenterCycleV741)
        && farmCenterCycleV741.pid=backgroundPidV63
        && farmCenterCycleV741.phase="ITEM_MOVE"
        && IsObject(farmItemLockV625.returnGoalV655)
        ? farmItemLockV625.returnGoalV655 : false
    if (IsObject(itemGoalInfoV1801) && IsObject(itemGoalInfoV1801.routeV392))
        r := itemGoalInfoV1801.routeV392
    e := IsObject(itemGoalInfoV1801) && IsObject(r.escapeV84)
        ? r.escapeV84 : FarmInfoStuckStateV552()
    if (IsObject(e))
    {
        stage := e.stageV589
        names := {"BACK":"đang lùi","LEFT":"đang né trái","RIGHT":"đang né phải","TELE":"đang teleport","RETURN":"về tọa độ trước"}
        stuck := names.HasKey(stage) ? names[stage] : "đang tìm lối thoát"
        if (stage="TELE" && !e.sentV589 && r.lastTeleport)
        {
            remaining := Max(0,Max(3,teleportIntervalSecV56)-(A_TickCount-r.lastTeleport)/1000)
            if (remaining>0)
                stuck := "chờ teleport " . Round(remaining,1) . "s"
        }
        if (e.stepAt)
            stuck .= " (" . Round(Max(0,A_TickCount-e.stepAt)/1000,1) . "s)"
    }
    else if (running && IsObject(r.obstacleV465))
    {
        e := r.obstacleV465
        names := {"BACK":"đang lùi","LEFT":"đang né trái","RIGHT":"đang né phải"}
        stuck := names.HasKey(e.stage) ? names[e.stage] : "đang tìm lối thoát"
        if (e.since)
            stuck .= " (" . Round(Max(0,A_TickCount-e.since)/1000,1) . "s)"
    }
    else if (running && !monsterCombatUidV45 && IsObject(r.stuckProbe) && r.stuckProbe.since && r.phase="NEXT")
        stuck := "di chuyển " . Round(Max(0,A_TickCount-r.stuckProbe.since)/1000,1) . "/" . Max(1,chaseCheckSecV9) . "s"
    if (running && IsObject(farmCenterCycleV741)
        && farmCenterCycleV741.pid=backgroundPidV63
        && farmCenterCycleV741.phase="ITEM_MOVE" && stuck="không")
        stuck := IsObject(itemGoalInfoV1801) ? "nhặt: đang đợi xét kẹt" : "nhặt: chưa khởi tạo xét kẹt"
    if (sigTerminalErrorV762!="")
        activity := "SIG đã dừng: " . sigTerminalErrorV762
    else if (backgroundBlockReasonV553!="")
        activity := "chờ: " . backgroundBlockReasonV553
    else if (sigBusyV147)
        activity := "SIG"
    else if (IsObject(ticketPickupWaitV279) && ticketPickupWaitV279.sigScopeV654)
        activity := "SIG: nhặt đồ, chờ Done"
    else if (IsObject(scosEntryV162) && scosEntryV162.stage1SigBlockedV654
        && !scosEntryV162.stage1SigDoneV374 && !scosEntryV162.preSigDoneV310)
        activity := "chờ SIG: " . sigLastStopReasonV63
    else if (IsObject(sigTownV148))
        activity := "về thành / sắp đồ / SIG"
    else if (IsObject(stageTwoV166))
        activity := "chờ thoát / tạo phòng"
    else if (xRunning || zRunning)
        activity := "buff"
    else if (IsObject(farmReviveV32) || reviveBuffPendingV34)
        activity := "hồi sinh / buff"
    else if (gameItemActionOwner!="")
        activity := gameItemActionOwner="Pickup" ? "Nhặt vật phẩm"
    else if (petLearnOnV12 || packetWatchArmedV1)
        activity := "chờ lấy dữ liệu game"
    else if (IsObject(e))
        activity := "xử lý kẹt"
    else if (IsObject(farmCenterCycleV741) && farmCenterCycleV741.pid=backgroundPidV63 && farmCenterCycleV741.epoch=farmRunEpochV535)
    {
        phaseV768 := farmCenterCycleV741.phase
        itemMoveStatusV914 := IsObject(itemGoalInfoV1801) && IsObject(r.escapeV84)
            ? "Đang thoát kẹt để quay lại nhặt vật phẩm"
            : "Đi tới vật phẩm; không tiến thì xét kẹt và thoát kẹt"
        activity := phaseV768="ATTACK_FIRST" ? "Quét+đánh quái quanh dòng " . farmCenterCycleV741.row
            : phaseV768="ATTACK_MORE" ? "Quét+đánh quái quanh dòng " . farmCenterCycleV741.row
            : phaseV768="ITEM_MOVE" ? itemMoveStatusV914
            : phaseV768="ITEM_ATTACK" ? "Đánh quái BK/2 quanh vật phẩm"
            : phaseV768="ATTACK" ? "Đang đánh quái"
            : phaseV768="PICKUP" ? "Kích nhặt (nếu có đồ)"
            : phaseV768="PICKUP_BUSY" ? "Đang nhặt vật phẩm"
            : phaseV768="CHECK" ? "Kiểm tra vị trí dòng " . farmCenterCycleV741.row
            : phaseV768="RETURN" ? "Đi/tele về dòng " . (IsObject(farmCenterCycleV741.forwardV756) ? farmCenterCycleV741.forwardV756.row : farmCenterCycleV741.row + 1)
            : phaseV768="MOVE" ? "Chuẩn bị đi tới dòng " . (IsObject(farmCenterCycleV741.forwardV756) ? farmCenterCycleV741.forwardV756.row : farmCenterCycleV741.row + 1)
            : "Quy trình " . farmCenterCycleV741.row . " → " . (IsObject(farmCenterCycleV741.forwardV756) ? farmCenterCycleV741.forwardV756.row : farmCenterCycleV741.row + 1) . ": " . phaseV768
    }
    else if (currentAttackUidV520 && A_TickCount-currentAttackAtV520<1500)
        activity := "đánh"
    else if (monsterCombatUidV45 && running)
        activity := "bám mục tiêu đánh"
    else if (IsObject(scosEntryV162) && !IsObject(scosEntryV162.commonRouteV3))
    {
        phase := scosEntryV162.map="CAIN" && scosEntryV162.cainPhaseV383!=""
            ? scosEntryV162.cainPhaseV383 : scosEntryV162.phase
        activity := FarmInfoPhaseV4(phase)
    }
    else if (running)
        activity := IsObject(r) && r.phase="NEXT" ? "di chuyển" : "chờ bước tiếp theo"
    cV624 := farmCombatViewV624
    if (running && IsObject(cV624) && cV624.pid=backgroundPidV63 && A_TickCount-cV624.at<1500
        && !xRunning && !zRunning && gameItemActionOwner="" && !sigBusyV147
        && !IsObject(stageTwoV166) && !IsObject(sigTownV148) && !IsObject(e) && !IsObject(farmCenterCycleV741))
    {
        if (cV624.uid)
            activity := cV624.text
        else if (activity="di chuyển")
            activity := IsObject(farmScanListV682) && farmScanListV682.Length() ? "có quái quanh nhân vật; chờ lượt đánh" : "di chuyển; chưa thấy quái quanh nhân vật"
    }
    ; Info only: show the ACTUALLY SENT attack, not just a scanned candidate.
    ; The fresh combat scan must belong to this PID and the same UID.
    if (running && IsObject(farmCenterCycleV741) && farmCenterCycleV741.pid=backgroundPidV63
        && (farmCenterCycleV741.phase="ATTACK" || farmCenterCycleV741.phase="ATTACK_FIRST"
            || farmCenterCycleV741.phase="ATTACK_MORE" || farmCenterCycleV741.phase="ROAD_ATTACK"
            || farmCenterCycleV741.phase="ITEM_ATTACK")
        && currentAttackUidV520 && currentAttackAtV520
        && A_TickCount-currentAttackAtV520<1500
        && IsObject(cV624) && cV624.pid=backgroundPidV63
        && cV624.uid=currentAttackUidV520 && A_TickCount-cV624.at<1500)
    {
        activity := "Đang đánh ID " . currentAttackClassV520 . " | " . Round(currentAttackDistV523,1)
        if (IsObject(farmScanListV682))
        {
            for _, infoMobV1240 in farmScanListV682
            {
                if (infoMobV1240.uid=currentAttackUidV520)
                {
                    if (infoMobV1240.priority)
                        activity .= " [BOSS]"
                    break
                }
            }
        }
    }
    if (IsObject(r.retryV611) && r.retryV611.hold)
    {
        stuck := "Cần thay tọa độ mới"
        if (activity="di chuyển" || activity="xử lý kẹt" || activity="chờ bước tiếp theo")
            activity := "đứng chờ; quái tới thì đánh"
    }
    activity := RegExReplace(activity, "[\r\n]+", " ")
    
    if (StrLen(activity) <= 10)
        activity .= "`r`n "

    ; Hien dong ho ket DI CHUYEN va QUAI tai cung dong "Ket"; khong them dong rieng.
    combatTimerV1210 := FarmCombatStuckInfoV1210(running)
    if (combatTimerV1210!="")
        stuck := stuck="không" ? combatTimerV1210 : stuck . " | " . combatTimerV1210
    return "Kẹt: " . stuck . "`r`nĐang làm: " . activity
}

; V1210: Info cu van hien ID/Dist/[BOSS], chi them dong xet ket quai.
; Doc ca dong ho theo muc tieu va watchdog (khong can packet da gui).
FarmCombatStuckInfoV1210(running)
{
    global farmCenterCycleV741,backgroundPidV63,monsterChaseV44,farmWatchV5
    global chaseCheckSecV9
    if (!running)
        return ""
    cycle := farmCenterCycleV741
    ; Chi hien dong ho QUAI khi bot dang danh, khong hien khoi khoi luc MOVE/CHECK.
    if (IsObject(cycle) && cycle.pid=backgroundPidV63
        && cycle.phase!="ATTACK" && cycle.phase!="ATTACK_FIRST"
        && cycle.phase!="ATTACK_MORE" && cycle.phase!="ROAD_ATTACK"
        && cycle.phase!="ITEM_ATTACK")
        return ""
    now := A_TickCount,uid := 0,since := 0
    c := monsterChaseV44
    if (IsObject(c) && c.uid && c.pid=backgroundPidV63
        && c.seenAtV591 && now-c.seenAtV591<2000 && c.since)
        uid := c.uid,since := c.since
    w := farmWatchV5
    if (IsObject(w) && w.pid=backgroundPidV63 && IsObject(w.combatStallProbeV903))
    {
        p := w.combatStallProbeV903
        if (p.uid && p.pid=backgroundPidV63 && p.since && (!uid || uid=p.uid))
            uid := p.uid,since := p.since
    }
    if (uid && since)
        return "quái " . Round(Max(0,now-since)/1000,1) . "/" . Max(1,chaseCheckSecV9) . "s"
    return ""
}


FarmInfoStuckStateV552()
{
    global autoMonsterAttackOn,coordRouteV16,coordGoV59
    if (autoMonsterAttackOn && IsObject(coordRouteV16) && IsObject(coordRouteV16.escapeV84))
        return coordRouteV16.escapeV84
    if (IsObject(coordGoV59) && !coordGoV59.stop && IsObject(coordGoV59.routeV392)
        && IsObject(coordGoV59.routeV392.escapeV84))
        return coordGoV59.routeV392.escapeV84
    return false
}

InfoStuckWatchV552()
{
    return
}

AttackInfoRememberV550(pid,cls,uid,x,y,px,py)
{
    global currentAttackUidV520,currentAttackClassV520,currentAttackX_V520,currentAttackY_V520
    global currentAttackAtV520,currentAttackDistV523,currentAttackPidV550
    currentAttackPidV550 := pid,currentAttackUidV520 := uid,currentAttackClassV520 := cls
    currentAttackX_V520 := x,currentAttackY_V520 := y,currentAttackAtV520 := A_TickCount
    currentAttackDistV523 := Round(Sqrt((x-px)**2+(y-py)**2),1)
}


FonInfoCloseV385()
{
    global fonInfoOnV385,fonInfoAutoStuckV552,fonInfoStuckDismissedV552,backgroundBlockReasonV553
	FarmStuckInfoDisableV10(true)
    fonInfoAutoStuckV552 := false
    fonInfoStuckDismissedV552 := IsObject(FarmInfoStuckStateV552()) || backgroundBlockReasonV553!=""
    fonInfoOnV385 := false
    SetTimer, FonInfoTimerV385, Off
    Gui, FonInfoV385:Destroy
    global viewIdV54
    viewIdV54 := false
    if (ProfileControlExistsV365("ViewIdInputV54"))
        GuiControl, 1:, ViewIdInputV54, 0

}
farmStuckInfoAutoV10 := false

FarmStuckInfoEnableV10()
{
    return
}

FarmStuckInfoDisableV10(force := false)
{
    return
}
DoubleKeyReleaseWatch:
if (!GetKeyState(doubleKey, "P"))
{
    doubleKeyHeld := false
    SetTimer, DoubleKeyReleaseWatch, Off
}
return

QCastDoubleKeyReleaseWatch:
if (!GetKeyState(qCastDoubleKey, "P"))
{
    qCastDoubleKeyHeld := false
    SetTimer, QCastDoubleKeyReleaseWatch, Off
}
return

FormDoubleKeyReleaseWatch:
if (!GetKeyState(formDoubleKey, "P"))
{
    formDoubleKeyHeld := false
    SetTimer, FormDoubleKeyReleaseWatch, Off
}
return

RemoveToolTip:
ToolTip
return


NormalizeOptionalKey(key)
{
    key := Trim(key)
    if (key = "" || key = "None" || key = "none" || key = "NONE" || key = "ERROR")
        return ""
    return RegExReplace(key,"i)(^|[~*$<>!^+#])(?:M3|Mouse3)$","$1MButton")
}

