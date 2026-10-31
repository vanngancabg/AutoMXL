; ==============================================================================
; FILE: 07_config_belt_log_quickbuff.ahk (Dòng 9201 -> 13082 trong Gốc.ahk)
; CHỨC NĂNG: Auto Buff Delay, Load/Save INI, Nạp Belt/Cube, Ghi tọa độ & QuickBuff
; ==============================================================================
Cycle6GuiSyncV525()
{
    BuffSequenceGuiSyncV555()
}

BuffSequenceToggleV555:
BuffSequenceSetV555(!buffSequenceOnV555)
return

BuffSequenceDelayChangedV555:
buffSequenceDelayV555 := BuffSequenceDelayGetV555()
buffSequenceNextV555 := A_TickCount+buffSequenceDelayV555
sectionV555 := ProfileSection(currentProfile)
try IniWrite, %buffSequenceDelayV555%, % ProfileConfigPathV364(sectionV555), %sectionV555%, BuffSequenceDelayMs
return

BuffSequenceTimerV555:
BuffSequenceTickV555()
return

BuffSequenceDelayGetV555()
{
    global buffSequenceDelayV555
    if (ProfileControlExistsV365("BuffSequenceDelayInputV555"))
        GuiControlGet, value, 1:, BuffSequenceDelayInputV555
    else
        value := buffSequenceDelayV555
    if (!RegExMatch(value,"^\d+$") || value<1)
        return 30000
    return Min(86400000,value+0)
}

BuffSequenceGuiSyncV555()
{
    global buffSequenceOnV555
    if (ProfileControlExistsV365("BuffSequenceButtonV555"))
        GuiControl, 1:, BuffSequenceButtonV555, % buffSequenceOnV555 ? "Auto Buff Delay *" : "Auto Buff Delay"
}

BuffSequenceSetV555(on)
{
    global buffSequenceOnV555,buffSequenceEpochV555,buffSequenceNextV555,buffSequenceDelayV555
    global QCastOn,cycleOn,master456Paused,master456Saved
    if (on && (!SigBackgroundBindV179() || !BackgroundValidV63()))
    {
        ToolTipInfoV386("Chưa nhận được cửa sổ game để chạy Auto Buff Delay.")
        SetTimer, RemoveToolTip, -2500
        return false
    }
    buffSequenceEpochV555++,buffSequenceOnV555 := on ? true : false
    buffSequenceNextV555 := 0
    if (on)
    {
        buffSequenceDelayV555 := BuffSequenceDelayGetV555()
        SetTimer, BuffSequenceTimerV555, 100
    }
    else
    {
        SetTimer, BuffSequenceTimerV555, Off
        FarmAttackHoldReleaseV15()
    }
    BuffSequenceGuiSyncV555()
    return true
}

BuffSequenceContinueV555()
{
    global buffSequenceOnV555,buffSequenceRunningV555,buffSequenceEpochV555,buffSequenceRunEpochV555
    return !buffSequenceRunningV555 || (buffSequenceOnV555 && buffSequenceEpochV555=buffSequenceRunEpochV555)
}

BuffSequenceTickV555()
{
    global buffSequenceOnV555,buffSequenceRunningV555,buffSequenceEpochV555,buffSequenceRunEpochV555,buffSequenceNextV555
    global xRunning,zRunning,gameItemActionOwner,sigBusyV147,sigTownV148,packetWatchArmedV1,stageTwoV166,QCastOn
    if (!buffSequenceOnV555 || buffSequenceRunningV555 || A_TickCount<buffSequenceNextV555
        || xRunning || zRunning || gameItemActionOwner!="" || sigBusyV147 || IsObject(sigTownV148)
        || packetWatchArmedV1 || IsObject(stageTwoV166) || !IsGameActive())
        return
    FarmAttackHoldReleaseV15()
    if (!AutoMonsterPacketCleanupV1())
        return
    pid := D2GetActiveGamePidV95(),base := pid ? D2GetModuleBaseV35(pid,"D2Client.dll") : 0
    h := base ? D2OpenProcess(pid) : 0
    if (!h)
        return
    buffSequenceRunningV555 := true,buffSequenceRunEpochV555 := buffSequenceEpochV555
    runEpoch := buffSequenceEpochV555,ok := false
    try
    {
        player := D2ReadU32(h,base+0x11BBFC),mode := player ? D2ReadU32(h,player+0x10) : 0
        if (!player || mode=0 || mode=17)
            return
        ok := AutoBuffOnlySequenceV555(h,player,pid)
    }
    finally
    {
        DllCall("CloseHandle","Ptr",h)
        buffSequenceRunningV555 := false
        if (buffSequenceOnV555 && runEpoch=buffSequenceEpochV555)
            buffSequenceNextV555 := A_TickCount+(ok ? BuffSequenceDelayGetV555() : 1000)
    }
}


; AUTO BUFF DELAY ONLY: shared buff form actions but NO farm pre-buff
; combat scan, attack, returning to original XY, or SCOS point 2 movement.
; Do not call RouteBuffSequenceV20 here: that routine deliberately invokes
; FarmPreBuffCombatCheckV710 and can dispatch NativeMovePointV14.
AutoBuffOnlySequenceV555(h,player,pid)
{
    global buffSequenceOnV555,buffSequenceRunEpochV555,buffSequenceEpochV555
    global xRunning,zRunning,gameItemActionOwner
    if (!buffSequenceOnV555 || buffSequenceRunEpochV555!=buffSequenceEpochV555
        || xRunning || zRunning || gameItemActionOwner!=""
        || !IsGameActive() || D2GetActiveGamePidV95()!=pid)
        return false
    if (!FarmBuffForm1V906(pid) || !BuffSequenceContinueV555())
        return false
    if (!FarmBuffThreeRowsV519(h,player,pid) || !BuffSequenceContinueV555())
        return false
    if (!FarmBuffForm5V906() || !BuffSequenceContinueV555())
        return false
    if (!FarmBuffForm6SelectV906() || !BuffSequenceContinueV555())
        return false
    return true
}

ToggleCycle:
if (master456Paused)
    return

cycleOn := !cycleOn
Cycle6GuiSyncV525()

if (cycleOn)
{
    cycleStep := 1
    nextStepTime := 0
    ToolTipInfoV386("Auto Bấm Dãy F: ON")
}
else
{
    ToolTipInfoV386("Auto Bấm Dãy F: OFF")
}

SetTimer, RemoveToolTip, -3000

return

SaveAllConfig()
{
    global selectedTabV6, ConfigFile
    GuiControlGet, selectedTabV6,, AutoGSFMainTabs
    if (selectedTabV6>=1 && selectedTabV6<=4)
        try IniWrite, %selectedTabV6%, %ConfigFile%, General, SelectedTab
    SaveMaster456Key()
    SaveClickCastConfig("ClickCast")
    global ConfigFile

    global zKey
    global xKey

    global doubleKey
    global doubleTapMs

    global formDoubleKey
    global formDoubleTapMs
    global qCastDoubleKey
    global qCastDoubleTapMs

    global zSetKey, zSetDelay, xDelay
    global zSetKey, zSetDelay, xDelay
    global zFKey
    global zFKey2
    global zDelay1
    global zDelay2
    global zDelay3
    global QCastKey1, QCastKey2, QCastKey3, QCastDelay1, QCastDelay2, QCastDelay3
    global QCastKey1, QCastKey2, QCastKey3, QCastDelay1, QCastDelay2, QCastDelay3

    global FKey1, FKey2, FKey3, FKey4
    global FKey5, FKey6, FKey7, FKey8
    global FKey9, FKey10

    global FDelay1, FDelay2, FDelay3, FDelay4
    global FDelay5, FDelay6, FDelay7, FDelay8
    global FDelay9, FDelay10
    global autoPotOn, invHealOn, invManaOn, cubeHealOn, cubeManaOn, potMode, potCaptureKey1, potHPThreshold, potHPThreshold2V299, potCooldown
    global manaOn, manaMode, manaThreshold, manaCooldown
    global sigKeyV147,sigSuKeyV181,farmNaoKeyV181,pickupBackgroundV181
    global pickupToggleKeyV79, pickupImageOn, getIdKey, deleteIdKey, pickupRadius, pickupFailTeleRadiusV1253
	global petLearnEnabledV12
    try IniWrite, 1, %ConfigFile%, General, Version

    global profileList, currentProfile
    try IniWrite, %profileList%, %ConfigFile%, Profiles, Names
    try IniWrite, %currentProfile%, %ConfigFile%, Profiles, Current
    try IniWrite, %currentProfile%, %ConfigFile%, Settings, LastProfile

    try IniWrite, %zKey%, %ConfigFile%, Keys, Z
    try IniWrite, %xKey%, %ConfigFile%, Keys, X

    try IniWrite, %doubleKey%, %ConfigFile%, Double, Key
    try IniWrite, %doubleTapMs%, %ConfigFile%, Double, Interval

    try IniWrite, %formDoubleKey%, %ConfigFile%, FormDouble, Key
    try IniWrite, %formDoubleTapMs%, %ConfigFile%, FormDouble, Interval

    try IniWrite, %qCastDoubleKey%, %ConfigFile%, QCastDouble, Key
    try IniWrite, %qCastDoubleTapMs%, %ConfigFile%, QCastDouble, Interval

    try IniWrite, %zFKey%, %ConfigFile%, Z, FKey
    kill2GeneralSave := (zFKey2 = "" ? "None" : zFKey2)
try IniWrite, %kill2GeneralSave%, %ConfigFile%, Z, FKey2
    try IniWrite, %zDelay1%, %ConfigFile%, Z, Delay1
    try IniWrite, %zDelay2%, %ConfigFile%, Z, Delay2
    try IniWrite, %zDelay3%, %ConfigFile%, Z, Delay3

    try IniWrite, %zSetKey%, %ConfigFile%, Z, SetKey
    try IniWrite, %zSetDelay%, %ConfigFile%, Z, SetDelay
    try IniWrite, %xDelay%, %ConfigFile%, X, Delay
    Loop, 3
    {
        qIndex := A_Index
        qKey := QCastKey%qIndex%
        qDelay := QCastDelay%qIndex%
        try IniWrite, %qKey%, %ConfigFile%, QCast, Key%qIndex%
        try IniWrite, %qDelay%, %ConfigFile%, QCast, Delay%qIndex%
    }

    IniRead, zSetKey, %ConfigFile%, Z, SetKey, %zSetKey%
    IniRead, zSetDelay, %ConfigFile%, Z, SetDelay, %zSetDelay%
    IniRead, xDelay, %ConfigFile%, X, Delay, %xDelay%
    Loop, 3
    {
        qIndex := A_Index
        defaultQKey := QCastKey%qIndex%
        defaultQDelay := QCastDelay%qIndex%
        IniRead, tempQKey, %ConfigFile%, QCast, Key%qIndex%, %defaultQKey%
        IniRead, tempQDelay, %ConfigFile%, QCast, Delay%qIndex%, %defaultQDelay%
        QCastKey%qIndex% := tempQKey
        QCastDelay%qIndex% := tempQDelay
    }

    try IniWrite, %autoPotOn%, %ConfigFile%, AutoPot, Enabled
    try IniWrite, %invHealOn%, %ConfigFile%, AutoPot, InventoryHealEnabled
    try IniWrite, %invManaOn%, %ConfigFile%, AutoPot, InventoryManaEnabled
    try IniWrite, %cubeHealOn%, %ConfigFile%, AutoPot, CubeHealEnabled
    try IniWrite, %cubeManaOn%, %ConfigFile%, AutoPot, CubeManaEnabled
    try IniWrite, %potMode%, %ConfigFile%, AutoPot, Mode
    try IniWrite, %potCaptureKey1%, %ConfigFile%, AutoPot, CaptureKey1
    try IniWrite, %potHPThreshold%, %ConfigFile%, AutoPot, PotHPThreshold
    try IniWrite, %potHPThreshold2V299%, %ConfigFile%, AutoPot, PotHPThreshold2
    try IniWrite, %potCaptureKey2%, %ConfigFile%, AutoPot, CaptureKey2
    try IniWrite, %potCooldown%, %ConfigFile%, AutoPot, Cooldown
    try IniWrite, %manaOn%, %ConfigFile%, AutoMana, Enabled
    try IniWrite, %manaMode%, %ConfigFile%, AutoMana, Mode
    try IniWrite, %manaThreshold%, %ConfigFile%, AutoMana, Threshold
    try IniWrite, %manaCooldown%, %ConfigFile%, AutoMana, Cooldown
    try IniWrite, 1, %ConfigFile%, PickupImage, Enabled
    try IniWrite, %getIdKey%, %ConfigFile%, PickupImage, GetIdKey
    try IniWrite, %deleteIdKey%, %ConfigFile%, PickupImage, DeleteIdKey
    try IniWrite, %pickupRadius%, %ConfigFile%, PickupImage, Radius
    pickupFailTeleRadiusV1253 := PickupFailTeleRadiusGetV1253()
    try IniWrite, %pickupFailTeleRadiusV1253%, %ConfigFile%, PickupImage, PickupFailTeleRadius
	    try IniWrite, % petLearnEnabledV12 ? 1 : 0, %ConfigFile%, PickupImage, PetLearnEnabled

    Loop, 10
    {
        index := A_Index

        key := FKey%index%
        delay := FDelay%index%

        try IniWrite, %key%, %ConfigFile%, Cycle, FKey%index%
        try IniWrite, %delay%, %ConfigFile%, Cycle, FDelay%index%
    }
}

LoadConfig()
{
    global selectedTabV6, ConfigFile, continuousMapV168, autoLoadMapV340
    global zSetKey, zSetDelay, xDelay
    IniRead, selectedTabV6, %ConfigFile%, General, SelectedTab, 1
    if (selectedTabV6<1 || selectedTabV6>4)
        selectedTabV6 := 1
    LoadClickCastConfig("ClickCast")
    global ConfigFile

    global zKey
    global xKey

    global doubleKey
    global doubleTapMs

    global formDoubleKey
    global formDoubleTapMs
    global qCastDoubleKey
    global qCastDoubleTapMs

    global zFKey
    global zFKey2
    global zDelay1
    global zDelay2
    global zDelay3

    global FKey1, FKey2, FKey3, FKey4
    global FKey5, FKey6, FKey7, FKey8
    global FKey9, FKey10

    global FDelay1, FDelay2, FDelay3, FDelay4
    global FDelay5, FDelay6, FDelay7, FDelay8
    global FDelay9, FDelay10
    global autoPotOn, invHealOn, invManaOn, cubeHealOn, cubeManaOn, potMode, potCaptureKey1, potHPThreshold, potHPThreshold2V299, potCooldown
    global manaOn, manaMode, manaThreshold, manaCooldown
    global sigKeyV147,sigSuKeyV181,farmNaoKeyV181,pickupBackgroundV181
    
	    global petLearnEnabledV12
	global pickupToggleKeyV79, pickupImageOn, getIdKey, deleteIdKey, pickupRadius, pickupLastClick, pickupFailTeleRadiusV1253
	global farmResetWatchEnabledV217, farmResetWatchMinutesV217

    IniRead, temp, %ConfigFile%, Keys, Z,%A_Space%

    if (temp != "ERROR" && StrLen(temp) = 1)
        zKey := temp

    IniRead, temp, %ConfigFile%, Keys, X, x

    if (temp != "ERROR" && StrLen(temp) = 1)
        xKey := temp

    IniRead, temp, %ConfigFile%, Double, Key, Left

    if (temp != "ERROR")
    {
        if (temp = "None"
         || temp = "Left"
         || temp = "Right"
         || temp = "Up"
         || temp = "Down"
         || temp = "Home"
         || temp = "End"
         || temp = "PgUp"
         || temp = "PgDn")
        {
            doubleKey := temp
        }
        else
        {
            doubleKey := "Left"
        }
    }

    IniRead, temp, %ConfigFile%, Double, Interval, 1000

    if (temp != "ERROR")
        doubleTapMs := temp

    IniRead, temp, %ConfigFile%, FormDouble, Key, Right

    if (temp != "ERROR")
    {
        if (temp = "None"
         || temp = "Left"
         || temp = "Right"
         || temp = "Up"
         || temp = "Down"
         || temp = "Home"
         || temp = "End"
         || temp = "PgUp"
         || temp = "PgDn")
        {
            formDoubleKey := temp
        }
        else
        {
            formDoubleKey := "Right"
        }
    }

    IniRead, temp, %ConfigFile%, FormDouble, Interval, 1000

    if (temp != "ERROR")
        formDoubleTapMs := temp

    IniRead, temp, %ConfigFile%, QCastDouble, Key, Up

    if (temp = "None"
         || temp = "Left"
     || temp = "Right"
     || temp = "Up"
     || temp = "Down"
     || temp = "Home"
     || temp = "End"
     || temp = "PgUp"
     || temp = "PgDn")
        qCastDoubleKey := "None"
    else
        qCastDoubleKey := "None"

    IniRead, temp, %ConfigFile%, QCastDouble, Interval, 1000
    if (temp != "ERROR")
        qCastDoubleTapMs := temp

    IniRead, temp, %ConfigFile%, Z, FKey,%A_Space%

    if (temp != "ERROR")
        zFKey := temp

    IniRead, temp, %ConfigFile%, Z, FKey2,%A_Space%

    if (temp != "ERROR")
        zFKey2 := temp

    IniRead, temp, %ConfigFile%, Z, Delay1, 150

    if (temp != "ERROR")
        zDelay1 := temp

    IniRead, temp, %ConfigFile%, Z, Delay2, 150

    if (temp != "ERROR")
        zDelay2 := temp

    IniRead, temp, %ConfigFile%, Z, Delay3, 500

    if (temp != "ERROR")
        zDelay3 := temp

    IniRead, autoPotOn, %ConfigFile%, AutoPot, Enabled, 0
    IniRead, invHealOn, %ConfigFile%, AutoPot, InventoryHealEnabled, 0
    IniRead, invManaOn, %ConfigFile%, AutoPot, InventoryManaEnabled, %invHealOn%
    IniRead, cubeHealOn, %ConfigFile%, AutoPot, CubeHealEnabled, 0
    IniRead, cubeManaOn, %ConfigFile%, AutoPot, CubeManaEnabled, %cubeHealOn%
    IniRead, potMode, %ConfigFile%, AutoPot, Mode, Auto(1-4)
    IniRead, potCaptureKey1, %ConfigFile%, AutoPot, CaptureKey1, n
    IniRead, potHPThreshold, %ConfigFile%, AutoPot, PotHPThreshold, 7000
    hp2DefaultV299 := Max(1,Floor(potHPThreshold/2))
    IniRead, potHPThreshold2V299, %ConfigFile%, AutoPot, PotHPThreshold2, %hp2DefaultV299%
    IniRead, potCooldown, %ConfigFile%, AutoPot, Cooldown, 3000
    if (!RegExMatch(potCooldown,"^\d+$") || potCooldown<1)
        potCooldown := 3000
    IniRead, manaOn, %ConfigFile%, AutoMana, Enabled, 0
    IniRead, manaMode, %ConfigFile%, AutoMana, Mode, Auto(1-4)
    IniRead, manaThreshold, %ConfigFile%, AutoMana, Threshold, 1000
    IniRead, manaCooldown, %ConfigFile%, AutoMana, Cooldown, 3000
    pickupImageOn := true
    getIdKey := ""
    deleteIdKey := ""
    IniRead, pickupRadius, %ConfigFile%, PickupImage, Radius, 4
    IniRead, pickupFailTeleRadiusV1253, %ConfigFile%, PickupImage, PickupFailTeleRadius, 4
    if (!RegExMatch(pickupFailTeleRadiusV1253,"^\d+$") || pickupFailTeleRadiusV1253<1 || pickupFailTeleRadiusV1253>100)
        pickupFailTeleRadiusV1253 := 4
    pickupFailTeleRadiusV1253 += 0
	    IniRead, petLearnEnabledV12, %ConfigFile%, PickupImage, PetLearnEnabled, 0
    petLearnEnabledV12 := petLearnEnabledV12=1
    pickupRadius += 0
    if (pickupRadius < 1)
        pickupRadius := 4
    pickupLastClick := 0

    Loop, 10
    {
        index := A_Index

        defaultKey := FKey%index%
        defaultDelay := FDelay%index%

        IniRead, tempKey, %ConfigFile%, Cycle, FKey%index%, %defaultKey%
        IniRead, tempDelay, %ConfigFile%, Cycle, FDelay%index%, %defaultDelay%

        FKey%index% := tempKey
        FDelay%index% := tempDelay
    }

    global profileList, currentProfile
    IniRead, tempProfiles, %ConfigFile%, Profiles, Names, Default
    if (tempProfiles = "ERROR" || tempProfiles = "")
        tempProfiles := "Default"
    if (!InStr("|" . tempProfiles . "|", "|Default|"))
        tempProfiles := "Default|" . tempProfiles
    profileList := tempProfiles
    ProfileMigrateV364()
    ProfileDiscoverFilesV366()

    IniRead, tempCurrent, %ConfigFile%, Profiles, Current, __MISSING_V366__
    if (tempCurrent="__MISSING_V366__" || tempCurrent="ERROR" || tempCurrent="" || !ProfileExists(tempCurrent))
        IniRead, tempCurrent, %ConfigFile%, Settings, LastProfile, Default
    if (!ProfileExists(tempCurrent))
        tempCurrent := "Default"
    currentProfile := tempCurrent

    if (!FileExist(ProfileFile("Default")))
        SaveProfile("Default")

    LoadProfile(currentProfile)
    global profileReadyV364
    profileReadyV364 := true

    GuiControl,, ZRunKey, % MouseKeyDisplayV616((zKey    = "" ? "None" : zKey))
    GuiControl,, ZSetKey, % MouseKeyDisplayV616((zSetKey = "" ? "None" : zSetKey))
    GuiControl,, ZSetDelay, %zSetDelay%
    GuiControl,, ZKeyF1, % MouseKeyDisplayV616((zFKey   = "" ? "None" : zFKey))
    GuiControl,, ZKeyF2, % MouseKeyDisplayV616((zFKey2  = "" ? "None" : zFKey2))
    GuiControl,, ZDelay1,   %zDelay1%
    GuiControl,, ZDelay2,   %zDelay2%

    GuiControl,, ProfileSelect, |%profileList%
    GuiControl, ChooseString, ProfileSelect, %currentProfile%
    GuiControl,, NewProfileName, %currentProfile%

    Loop, 5
    {
        index := A_Index
        currentKey := FKey%index%
        currentDelay := FDelay%index%
        if (currentKey = "")
            currentKey := "None"
        GuiControl,, FKey%index%, % MouseKeyDisplayV616(currentKey)
        GuiControl,, FDelay%index%, %currentDelay%
    }
    Loop, 3
    {
        qIndex := A_Index
        qCurrentKey := QCastKey%qIndex%
        qCurrentDelay := QCastDelay%qIndex%
        if (qCurrentKey = "")
            qCurrentKey := "None"
        GuiControl,, QCastKey%qIndex%, % MouseKeyDisplayV616(qCurrentKey)
        GuiControl,, QCastDelay%qIndex%, %qCurrentDelay%
    }
    GuiControl,, XKey, % MouseKeyDisplayV616(xKey)
    GuiControl,, XDelay, %xDelay%
    GuiControl,, ZRunKey, % MouseKeyDisplayV616((zKey = "" ? "None" : zKey))
    GuiControl,, ZSetKey, % MouseKeyDisplayV616(zSetKey)
    GuiControl,, ZSetDelay, %zSetDelay%
    GuiControl,, ZKeyF1, % MouseKeyDisplayV616(zFKey)
    GuiControl,, ZKeyF2, % MouseKeyDisplayV616((zFKey2 = "" ? "None" : zFKey2))
    GuiControl,, ZDelay1, %zDelay1%
    GuiControl,, ZDelay2, %zDelay2%
    GuiControl, ChooseString, DoubleKey, %doubleKey%
    GuiControl,, DoubleTapMs, %doubleTapMs%
    GuiControl, ChooseString, FormDoubleKey, %formDoubleKey%
    GuiControl,, FormDoubleTapMs, %formDoubleTapMs%
    GuiControl, Choose, AutoGSFMainTabs, %selectedTabV6%
}


OpenGuide:
Gosub, PickupGuideShowV8
return


SaveFormPosition:
Gui, +LastFound
formHwnd := WinExist()
if (formHwnd)
{
    WinGet, formMinMax, MinMax, ahk_id %formHwnd%
    if (formMinMax != -1)
    {
        WinGetPos, tempFormX, tempFormY,,, ahk_id %formHwnd%
        if (tempFormX != "" && tempFormY != "" && tempFormX > -2000 && tempFormY > -2000)
        {
            formX := tempFormX
            formY := tempFormY
            try IniWrite, %formX%, %ConfigFile%, Window, X
            try IniWrite, %formY%, %ConfigFile%, Window, Y
        }
    }
}
return
GuiClose:
Gosub, SaveFormPosition
ExitApp
return

GuiEscape:
return

WM_SYSCOMMAND_SavePos(wParam, lParam, msg, hwnd)
{
    global formX, formY, ConfigFile
    if ((wParam & 0xFFF0) = 0xF020)
    {
        Gui, +LastFound
        guiHwnd := WinExist()
        if (hwnd = guiHwnd)
        {
            WinGetPos, formX, formY,,, ahk_id %hwnd%
            if (formX != "" && formY != "")
            {
                try IniWrite, %formX%, %ConfigFile%, Window, X
                try IniWrite, %formY%, %ConfigFile%, Window, Y
            }
        }
    }
}

SavePositionOnExit:
if (profileReadyV364)
{
    SaveProfile(currentProfile)
    try IniWrite, %currentProfile%, %ConfigFile%, Profiles, Current
    try IniWrite, %currentProfile%, %ConfigFile%, Settings, LastProfile
}
FonInfoCloseV385()
PickupOptCloseV12()
if (manualLogOnV81)
    Gosub, ManualLogStopV81
	if (IsObject(routeRecordV358))
    RouteRecordStopV358("EXIT")
if (IsObject(routePlanV375))
    RoutePlanSaveV375()
ConsumableNameCleanupV7()
MovementCtrlSetV78(false,0,"SavePositionOnExit")
AutoMonsterPacketCleanupV1(true)
PacketWatchStopV1()
IfWinExist, Auto-GSF
{
    WinGet, exitMinMax, MinMax, Auto-GSF
    if (exitMinMax != -1)
    {
        WinGetPos, exitFormX, exitFormY,,, Auto-GSF
        if (exitFormX != "" && exitFormY != "" && exitFormX > -2000 && exitFormY > -2000)
        {
            try IniWrite, %exitFormX%, %ConfigFile%, Window, X
            try IniWrite, %exitFormY%, %ConfigFile%, Window, Y
        }
    }
}
ExitApp
return


V92HPProbeTimer_DISABLED:
V92WriteHPProbe()
return

V92WriteHPProbe()
{
    if (!ManualLogActiveV81())
        return
    global V92Sample
    if (V92Sample = "")
        V92Sample := 0
    V92Sample++

    log := TxtRootPathV816("HPProbe-v92.txt")
    tmp := A_Temp . "\d2_hp_v92.txt"
    try FileDelete, %tmp%
    cmd := "tasklist /FI " . Chr(34) . "IMAGENAME eq Game.exe" . Chr(34) . " /FO CSV /NH > " . Chr(34) . tmp . Chr(34) . " 2>&1"
    RunWait, %ComSpec% /c %cmd%,, Hide
    FileRead, raw, %tmp%
    try FileDelete, %tmp%

    pidBest := 0, player := 0, baseBest := 0
    Loop, Parse, raw, `n, `r
    {
        line := A_LoopField
        if RegExMatch(line, "i)^""Game\.exe"",""([0-9]+)""", m)
        {
            pid := m1 + 0
            base := D2GetModuleBaseV35(pid, "D2Client.dll")
            if (!base)
                continue
            h0 := D2OpenProcess(pid)
            if (!h0)
                continue
            pp := D2ReadU32(h0, base + 0x11BBFC)
            DllCall("CloseHandle", "Ptr", h0)
            if (pp)
            {
                pidBest := pid, player := pp, baseBest := base
                break
            }
        }
    }
    if (!pidBest || !player)
        return

    h := D2OpenProcess(pidBest)
    if (!h)
        return

    pStats := D2ReadU32(h, player + 0x5C)
    pInv := D2ReadU32(h, player + 0x60)
    FormatTime, ts,, yyyyMMdd-HHmmss

    out := "=== V92 SAMPLE " . V92Sample . " " . ts . " tick=" . A_TickCount . " ===`r`n"
    out .= "PID=" . pidBest . " Player=" . V92Hex(player) . " Stats=" . V92Hex(pStats) . " Inventory=" . V92Hex(pInv) . "`r`n"

    if (pStats)
    {
        out .= "STAT_A0_E0"
        Loop, 17
        {
            off := 0xA0 + (A_Index-1)*4
            v := D2ReadU32(h, pStats + off)
            out .= " +" . V92HexOff(off) . "=" . v
        }
        out .= "`r`n"

        Loop, 2
        {
            rootOff := (A_Index=1) ? 0x24 : 0x48
            root := D2ReadU32(h, pStats + rootOff)
            out .= "ROOT stats+" . V92HexOff(rootOff) . "=" . V92Hex(root)
            if (root > 0x10000)
            {
                Loop, 20
                {
                    qoff := (A_Index-1)*4
                    qv := D2ReadU32(h, root + qoff)
                    out .= " +" . V92HexOff(qoff) . "=" . qv
                }
            }
            out .= "`r`n"
        }

        a4 := D2ReadU32(h, pStats + 0xA4)
        out .= "A4_VALUE=" . V92Hex(a4) . "`r`n"
        if (a4 > 0x10000)
        {
            out .= "A4_PTR_BLOCK"
            Loop, 32
            {
                qoff := (A_Index-1)*4
                qv := D2ReadU32(h, a4 + qoff)
                out .= " +" . V92HexOff(qoff) . "=" . qv
            }
            out .= "`r`n"
        }
    }

    if (pInv)
    {
        cnt := D2ReadU32(h, pInv + 0x28)
        u := D2ReadU32(h, pInv + 0x10)
        typ := u ? D2ReadU32(h, u+0x00) : 0
        cls := u ? D2ReadU32(h, u+0x04) : 0
        uid := u ? D2ReadU32(h, u+0x0C) : 0
        out .= "INV countField=" . cnt . " firstUnit=" . V92Hex(u) . " type=" . typ . " class=" . cls . " id=" . uid . "`r`n"
    }

    out .= "`r`n"
    DllCall("CloseHandle", "Ptr", h)
    ManualLogAppendV81(out, log)
}

V92Hex(v)
{
    return Format("0x{:08X}", v & 0xFFFFFFFF)
}

V92HexOff(v)
{
    return Format("{:02X}", v)
}

Belt4HPHandler:
if (!IsGameForegroundV63())
    return
if (sigBusyV147)
    return
if (packetWatchArmedV1)
    return
TransferHotkeyTrace("16HP_TO_BELT")
if (xRunning)
{
    DebugTraceWrite("belt", "TRANSFER_BLOCKED reason=BUFF_RUNNING")
    return
}
if (!IsGameActive())
{
    HealTrace("TIMER_SKIP reason=GAME_NOT_ACTIVE", "timer")
    return
}
pid := D2GetActiveGamePidV95()
if (pid && FarmReviveTownLevelV295(RoomRecordLevelV259(pid)))
    return
if (!GameItemActionBeginV4("Heal", "heal", true))
    return
if (!GameItemActionBeginV4("Belt", "belt", true))
    return
try
{
beltOneShotLogActive := beltOneShotLogArmed
if (beltOneShotLogActive)
    BeltSendLogV101("=== ONE-SHOT 4HP START " . A_Now . " ===")
beltTraceSendOK := V50ConfigureBelt([1229,1229,1229,1229])
DebugTraceWrite("belt", "BELT_HANDLER_END packets_sent_ok=" . beltTraceSendOK)
if (beltOneShotLogActive)
    BeltSendLogV101("=== ONE-SHOT END - LOG AUTO OFF ===")
beltOneShotLogActive := false
beltOneShotLogArmed := false
}
finally
{
    GameItemActionEndV4("Belt")
}
return

Belt2HP2ManaHandler:
if (!IsGameForegroundV63())
    return
if (sigBusyV147)
    return
if (packetWatchArmedV1)
    return
TransferHotkeyTrace("8HP_8MP_TO_BELT")
if (xRunning)
{
    DebugTraceWrite("belt", "TRANSFER_BLOCKED reason=BUFF_RUNNING")
    return
}
if (!IsGameActive())
{
    DebugTraceWrite("belt", "TRANSFER_BLOCKED reason=GAME_NOT_ACTIVE")
    return
}
if (!GameItemActionBeginV4("Belt", "belt", true))
    return
try
{
beltOneShotLogActive := beltOneShotLogArmed
if (beltOneShotLogActive)
    BeltSendLogV101("=== ONE-SHOT 2HP2MANA START " . A_Now . " ===")
beltTraceSendOK := V50ConfigureBelt([1229,1229,1234,1234])
DebugTraceWrite("belt", "BELT_HANDLER_END packets_sent_ok=" . beltTraceSendOK)
if (beltOneShotLogActive)
    BeltSendLogV101("=== ONE-SHOT END - LOG AUTO OFF ===")
beltOneShotLogActive := false
beltOneShotLogArmed := false
}
finally
{
    GameItemActionEndV4("Belt")
}
return

BeltSendLogV101(msg)
{
    DebugTraceWrite("belt", msg)
}

GameItemActionBeginV4(owner, channel, requireEmpty:=false)
{
    global buffSequenceRunningV555
    if (RemoteThreadBusyV740(D2GetActiveGamePidV95()))
        return false
    if (buffSequenceRunningV555)
        return false
    if (!FarmAttackReleaseWaitV15())
        return false
    global gameItemActionOwner, gameItemTimersPausedOwner, portalExitPendingV69, autoMonsterAttackOn, reviveBuffPendingV34
    if (autoMonsterAttackOn && (IsObject(portalExitPendingV69) || reviveBuffPendingV34))
        return false
    static lastSkip := {}, lastSkipTick := {}
    previousCritical := A_IsCritical
    Critical, On
    if (gameItemActionOwner!="")
    {
        busyOwner := gameItemActionOwner
        if (previousCritical)
            Critical, %previousCritical%
        else
            Critical, Off
        reason := "BUSY_" . busyOwner
        if (!lastSkip.HasKey(owner) || lastSkip[owner]!=reason || A_TickCount-lastSkipTick[owner]>=500)
        {
            DebugTraceWrite(channel,"ITEM_ACTION_SKIP requested=" . owner . " busy=" . busyOwner)
            lastSkip[owner] := reason, lastSkipTick[owner] := A_TickCount
        }
        return false
    }
    gameItemActionOwner := owner
    if (owner="Belt" || owner="Cube")
    {
        SetTimer, PickupImageTimer, Off
        SetTimer, AutoPotTimer, Off
        gameItemTimersPausedOwner := owner
        DebugTraceWrite(channel,"BACKGROUND_PAUSE owner=" . owner . " pickup_timer=OFF heal_timer=OFF")
    }
    if (previousCritical)
        Critical, %previousCritical%
    else
        Critical, Off
    if (requireEmpty)
    {
        ctx := D2OpenHealContextV3()
        cursor := ctx.reason="OK" ? PickupCursorV4(ctx.h,ctx.inv) : -1
        if (ctx.reason="OK")
            DllCall("CloseHandle","Ptr",ctx.h)
        if (!IsObject(cursor) || cursor.unit)
        {
            reason := "CURSOR_NOT_EMPTY_OR_UNREADABLE"
            if (!lastSkip.HasKey(owner) || lastSkip[owner]!=reason || A_TickCount-lastSkipTick[owner]>=500)
            {
                DebugTraceWrite(channel,"ITEM_ACTION_SKIP requested=" . owner . " reason=" . reason)
                lastSkip[owner] := reason, lastSkipTick[owner] := A_TickCount
            }
            GameItemActionEndV4(owner)
            return false
        }
    }
    if (lastSkip.HasKey(owner))
    {
        DebugTraceWrite(channel,"ITEM_ACTION_RESUME owner=" . owner)
        lastSkip.Delete(owner), lastSkipTick.Delete(owner)
    }
    if (owner="Belt" || owner="Cube")
        DebugTraceWrite(channel,"ITEM_ACTION_BEGIN owner=" . owner)
    return true
}

GameItemActionEndV4(owner)
{
    global gameItemActionOwner, gameItemTimersPausedOwner
    if (gameItemActionOwner!=owner)
        return
    if (gameItemTimersPausedOwner=owner)
    {
        gameItemTimersPausedOwner := ""
        gameItemActionOwner := ""
        SetTimer, AutoPotTimer, 50
        SetTimer, PickupImageTimer, 20
        DebugTraceWrite(owner="Belt" ? "belt" : "cube"
            ,"BACKGROUND_RESTORE owner=" . owner . " pickup_timer=20ms heal_timer=50ms")
        return
    }
    gameItemActionOwner := ""
}

V50MoveConfirmedV4(pid, uid, cls, slot)
{
    global cubeTransferDelayMs
    Loop, 3
    {
        attempt := A_Index
        ctx := D2OpenHealContextV3()
        if (ctx.reason!="OK" || ctx.pid!=pid)
        {
            if (ctx.reason="OK")
                DllCall("CloseHandle","Ptr",ctx.h)
            return false
        }
        cursor := PickupCursorV4(ctx.h,ctx.inv)
        snapshot := V9SnapshotAllItems(ctx)
        sent := false
        if (IsObject(cursor))
        {
            if (cursor.unit && cursor.uid=uid && cursor.cls=cls)
                sent := V50SendCursorToBeltV4({pid:pid},uid,slot)
            else if (!cursor.unit && snapshot.HasKey(uid))
            {
                item := snapshot[uid]
                if (item.cls=cls && item.loc=0 && item.owner=ctx.inv
                    && D2ReadU32(ctx.h,item.unit+0x0C)=uid)
                {
                    sent := V50RemotePacket26({pid:pid},uid,slot)
                }
            }
        }
        BeltSendLogV101("FILL_ATTEMPT uid=" . uid . " slot=" . slot
            . " attempt=" . attempt . " sent=" . sent)
        confirmStart := A_TickCount
        while (A_TickCount-confirmStart<600 && PickupGameActiveV2(pid))
        {
            Sleep, %cubeTransferDelayMs%
            cursor := PickupCursorV4(ctx.h,ctx.inv)
            snapshot := V9SnapshotAllItems(ctx)
            if (!IsObject(cursor) || (cursor.unit && cursor.uid=uid) || !snapshot.HasKey(uid))
                continue
            item := snapshot[uid]
            if (item.cls=cls && item.x=slot
                && D2ReadU32(ctx.h,item.unit+0x0C)=uid
                && D2ReadU32(ctx.h,item.unit+0x10)=2)
            {
                DllCall("CloseHandle","Ptr",ctx.h)
                BeltSendLogV101("FILL_CONFIRMED uid=" . uid . " class=" . cls . " slot=" . slot)
                return true
            }
        }
        cursor := PickupCursorV4(ctx.h,ctx.inv)
        live := snapshot.HasKey(uid) ? snapshot[uid] : 0
        BeltSendLogV101("FILL_STATE uid=" . uid . " target_slot=" . slot
            . " attempt=" . attempt . " cursor_read=" . IsObject(cursor)
            . " cursor_uid=" . (IsObject(cursor) ? cursor.uid : -1)
            . " found=" . IsObject(live) . " loc=" . (IsObject(live) ? live.loc : -1)
            . " xy=" . (IsObject(live) ? live.x . "," . live.y : "UNKNOWN"))
        for beltUid, beltItem in snapshot
        {
            if (D2ReadU32(ctx.h,beltItem.unit+0x10)=2
                && (!IsObject(cursor) || beltItem.unit!=cursor.unit))
                BeltSendLogV101("BELT_ACTUAL uid=" . beltUid . " class=" . beltItem.cls
                    . " xy=" . beltItem.x . "," . beltItem.y
                    . " mode=" . D2ReadU32(ctx.h,beltItem.unit+0x10))
        }
        if (attempt=3 && PickupGameActiveV2(pid) && IsObject(cursor)
            && cursor.unit && cursor.uid=uid && cursor.cls=cls)
        {
            dropped := false
            Loop, 3
            {
                cursor := PickupCursorV4(ctx.h,ctx.inv)
                if (!IsObject(cursor))
                    break
                if (!cursor.unit)
                {
                    dropped := true
                    break
                }
                if (cursor.uid!=uid || cursor.cls!=cls)
                    break
                sentDrop := PickupDropCursorV4(ctx.h,pid,ctx.inv,{uid:uid,cls:cls},"belt")
                BeltSendLogV101("BELT_DROP uid=" . uid . " try=" . A_Index . " sent=" . sentDrop)
                startDrop := A_TickCount
                while (A_TickCount-startDrop<600 && PickupGameActiveV2(pid))
                {
                    Sleep, %cubeTransferDelayMs%
                    cursor := PickupCursorV4(ctx.h,ctx.inv)
                    if (IsObject(cursor) && !cursor.unit)
                    {
                        dropped := true
                        break
                    }
                }
                if (dropped)
                    break
            }
            BeltSendLogV101("BELT_DROP_RESULT uid=" . uid . " confirmed=" . dropped
                . " cursor_empty=" . (IsObject(cursor) && !cursor.unit))
        }
        DllCall("CloseHandle","Ptr",ctx.h)
        BeltSendLogV101("FILL_NOT_CONFIRMED uid=" . uid . " slot=" . slot
            . " attempt=" . attempt . " retry=" . (attempt<3))
    }
    return false
}

V50SendCursorToBeltV4(ctx, itemUid, beltSlot)
{
    if (RemoteThreadBusyV740(D2GetActiveGamePidV95()))
        return false
    pid := ctx.pid
    if (!PickupGameActiveV2(pid) || beltSlot<0 || beltSlot>15)
        return false
    netBase := D2GetModuleBaseV35(pid,"D2Net.dll")
    if (!netBase)
        return false
    sendFn := netBase + 0x7650
    hSend := DllCall("OpenProcess","UInt",0x043A,"Int",0,"UInt",pid,"Ptr")
    if (!hSend)
        return false
    remote := DllCall("VirtualAllocEx","Ptr",hSend,"Ptr",0,"UPtr",128,"UInt",0x3000,"UInt",0x40,"Ptr")
    if (!remote)
    {
        DllCall("CloseHandle","Ptr",hSend)
        return false
    }
    VarSetCapacity(pkt,9,0)
    NumPut(0x23,pkt,0,"UChar")
    NumPut(itemUid,pkt,1,"UInt")
    NumPut(beltSlot,pkt,5,"UInt")
    wrotePkt := 0
    okPkt := DllCall("WriteProcessMemory","Ptr",hSend,"Ptr",remote+64,"Ptr",&pkt,"UPtr",9,"UPtrP",wrotePkt)
    VarSetCapacity(code,32,0)
    o:=0
    NumPut(0x68,code,o,"UChar"),o+=1
    NumPut(remote+64,code,o,"UInt"),o+=4
    NumPut(0x6A,code,o,"UChar"),o+=1
    NumPut(0x01,code,o,"UChar"),o+=1
    NumPut(0x6A,code,o,"UChar"),o+=1
    NumPut(0x09,code,o,"UChar"),o+=1
    NumPut(0xB8,code,o,"UChar"),o+=1
    NumPut(sendFn,code,o,"UInt"),o+=4
    NumPut(0xFF,code,o,"UChar"),o+=1
    NumPut(0xD0,code,o,"UChar"),o+=1
    NumPut(0xC3,code,o,"UChar"),o+=1
    wroteCode:=0
    okCode := DllCall("WriteProcessMemory","Ptr",hSend,"Ptr",remote,"Ptr",&code,"UPtr",o,"UPtrP",wroteCode)
    if (!okPkt || !okCode)
    {
        DllCall("VirtualFreeEx","Ptr",hSend,"Ptr",remote,"UPtr",0,"UInt",0x8000)
        DllCall("CloseHandle","Ptr",hSend)
        return false
    }
    th := DllCall("CreateRemoteThread","Ptr",hSend,"Ptr",0,"UPtr",0,"Ptr",remote,"Ptr",0,"UInt",0,"UIntP",tid,"Ptr")
    if (!th)
    {
        DllCall("VirtualFreeEx","Ptr",hSend,"Ptr",remote,"UPtr",0,"UInt",0x8000)
        DllCall("CloseHandle","Ptr",hSend)
        return false
    }
    wait := DllCall("WaitForSingleObject","Ptr",th,"UInt",1000)
    waitLimit := 5
    while (wait == 258 && IsGameActive() && waitLimit > 0)
    {
        wait := DllCall("WaitForSingleObject", "Ptr", th, "UInt", 1000)
        waitLimit--
    }
    exitCode:=0
    DllCall("GetExitCodeThread","Ptr",th,"UIntP",exitCode)
    RemoteThreadFinishV740(hSend,th,remote,wait)
    return (wait=0)
}

V50ConfigureBelt(want)
{
    global cubePickupDelayMs, cubeTransferDelayMs
    BeltSendLogV101("=== START V3 BELT + PICKUP STACK DIAG ===")
    BeltSendLogV101("MODE=" . want[1] . "," . want[2] . "," . want[3] . "," . want[4])
    BeltSendLogV101("TIMING pickup_ms=" . cubePickupDelayMs . " confirm_ms=" . cubeTransferDelayMs)

    retry := 0

V85_Restart:
    retry++
    BeltSendLogV101("PASS=" . retry)

    if (retry > 20)
    {
        BeltSendLogV101("RETRY_LIMIT -> STOP")
        return false
    }

    if (!IsGameActive())
        return false

    belt := V76ScanBeltSlots()
    if (!IsObject(belt))
    {
        Sleep, 80
        Goto, V85_Restart
    }

    wrongColumns := []
    Loop, 4
    {
        col := A_Index - 1
        target := want[A_Index]
        wrongColumn := false
        Loop, 4
        {
            row := A_Index - 1
            slot := col + row*4
            if (belt.HasKey(slot))
            {
                info := belt[slot]
                if (IsObject(info) && info.cls != target)
                {
                    wrongColumn := true
                    break
                }
            }
        }
        if (wrongColumn)
            wrongColumns.Push(col)
    }
    for _, col in wrongColumns
    {
        beltKey := col + 1
        previousCount := 5, noProgress := 0, emptyColumn := false
        Loop, 8
        {
            batch := A_Index
            BeltSendLogV101("CLEAR_WRONG_COLUMN col=" . col . " key=" . beltKey . " batch=" . batch)
            if (!IsGameActive())
                return false
            SetKeyDelay, %cubeTransferDelayMs%, %cubeTransferDelayMs%
            Loop, 4
            {
                BuffCheckedSendV29(beltKey)
            }
            SetKeyDelay, 30, 30
            belt := V76ScanBeltSlots()
            if (!IsObject(belt))
                return false
            remaining := 0
            Loop, 4
                if (belt.HasKey(col + (A_Index - 1)*4))
                    remaining++
            BeltSendLogV101("CLEAR_CHECK col=" . col . " remaining=" . remaining)
            if (!remaining)
            {
                emptyColumn := true
                break
            }
            if (remaining >= previousCount)
                noProgress++
            else
                noProgress := 0
            if (noProgress >= 3)
                break
            previousCount := remaining
        }
        if (!emptyColumn)
        {
            BeltSendLogV101("CLEAR_NOT_EMPTY col=" . col . " -> STOP")
            return false
        }
    }

    needHP := 0, needMP := 0
    Loop, 4
    {
        target := want[A_Index]
        if (target = 1229)
            needHP += 4
        else if (target = 1234)
            needMP += 4
    }
    pool := V78ScanInventoryPotions(needHP, needMP)

    if (!IsObject(belt) || !IsObject(pool))
    {
        Sleep, 80
        Goto, V85_Restart
    }

    BeltSendLogV101("POOL HP=" . pool[1229].Length() . " MP=" . pool[1234].Length())

    Loop, 4
    {
        col := A_Index - 1
        target := want[A_Index]

        Loop, 4
        {
            row := A_Index - 1
            slot := col + row*4

            if (belt.HasKey(slot))
            {
                info := belt[slot]
                if (IsObject(info) && info.cls = target)
                {
                    BeltSendLogV101("OK slot=" . slot . " cls=" . info.cls . " uid=" . info.uid)
                    continue
                }

                BeltSendLogV101("UNEXPECTED_SLOT slot=" . slot . " -> RESET")
                Sleep, 80
                Goto, V85_Restart
            }

            if (!pool.HasKey(target) || pool[target].Length() < 1)
            {
                BeltSendLogV101("POOL_EMPTY class=" . target . " -> STOP")
                return false
            }

            it := pool[target].RemoveAt(1)
            BeltSendLogV101("FAST_FILL slot=" . slot . " class=" . target . " uid=" . it.uid)

            if (!V50MoveConfirmedV4(pool.pid, it.uid, target, slot))
            {
                BeltSendLogV101("FAST_FILL_FAIL slot=" . slot . " uid=" . it.uid . " -> STOP")
                return false
            }

            belt[slot] := {cls:target, uid:it.uid, slot:slot}
            BeltSendLogV101("FILL_DONE slot=" . slot . " uid=" . it.uid . " confirmed=1")

            Sleep, %cubeTransferDelayMs%
        }
    }

    BeltSendLogV101("=== END BELT FILLS CONFIRMED ===")
    return true
}

V78ScanInventoryPotions(needHP := 16, needMP := 16)
{
    ctx := V44OpenGameContext()
    if (!IsObject(ctx))
        return ""

    h := ctx.h, inv := ctx.inv
    pool := {}
    pool[1229] := []
    pool[1234] := []

    scan := HealScanRootsV4(h,ctx.inv)
    if (scan.errors)
    {
        DllCall("CloseHandle","Ptr",h)
        BeltSendLogV101("BELT_SCAN_ROOT_ERROR function=V78ScanInventoryPotions")
        return ""
    }
    queue := scan.roots, seen := {}, qi := 1
    while (qi <= queue.Length() && qi <= 8192)
    {
        if (pool[1229].Length() >= needHP && pool[1234].Length() >= needMP)
            break
        u := queue[qi], qi++
        if (!u || seen.HasKey(u))
            continue
        seen[u] := 1

        typ := D2ReadU32(h,u+0x00)
        cls := D2ReadU32(h,u+0x04)
        itemData := (typ=4) ? D2ReadU32(h,u+0x14) : 0

        if (typ=4 && itemData && (cls=1229 || cls=1234)
            && D2ReadU8V18(h,itemData+0x45)=0
            && D2ReadU32(h,itemData+0x5C)=inv)
        {
            uid := D2ReadU32(h,u+0x0C)
            if (uid && ((cls=1229 && pool[1229].Length() < needHP)
                || (cls=1234 && pool[1234].Length() < needMP)))
                pool[cls].Push({uid:uid, cls:cls, itemData:itemData})
        }

        e4:=D2ReadU32(h,u+0xE4), e8:=D2ReadU32(h,u+0xE8)
        if (e4 && !seen.HasKey(e4))
            queue.Push(e4)
        if (e8 && !seen.HasKey(e8))
            queue.Push(e8)

        if (typ=4 && itemData)
        {
            ptrOffsets := [0x60,0x64,0x6C,0x70,0x84,0xAC,0xB0,0xB4,0xC8,0xD8]
            for _,po in ptrOffsets
            {
                pu:=D2ReadU32(h,itemData+po)
                if (pu && !seen.HasKey(pu) && D2ReadU32(h,pu)=4)
                    queue.Push(pu)
            }
        }
    }

    pool.pid := ctx.pid
    DllCall("CloseHandle","Ptr",h)
    return pool
}


V76ScanBeltSlots()
{
    if (!IsGameActive())
        return ""

    ctx := V44OpenGameContext()
    if (!IsObject(ctx))
        return ""

    h := ctx.h
    cursor := PickupCursorV4(h,ctx.inv)
    if (!IsObject(cursor))
    {
        DllCall("CloseHandle","Ptr",h)
        return ""
    }
    scan := HealScanRootsV4(h,ctx.inv)
    if (scan.errors)
    {
        DllCall("CloseHandle","Ptr",h)
        BeltSendLogV101("BELT_SCAN_ROOT_ERROR function=V76ScanBeltSlots")
        return ""
    }
    queue := scan.roots, seen := {}, qi := 1
    slots := {}

    while (qi <= queue.Length() && qi <= 8192)
    {
        u := queue[qi], qi++
        if (!u || seen.HasKey(u))
            continue
        seen[u] := 1

        typ := D2ReadU32(h,u+0x00)
        cls := D2ReadU32(h,u+0x04)
        uid := D2ReadU32(h,u+0x0C)
        itemData := (typ=4) ? D2ReadU32(h,u+0x14) : 0

        if (typ=4 && itemData && uid)
        {
            loc45 := D2ReadU8V18(h,itemData+0x45)
            mode := D2ReadU32(h,u+0x10)
            if (mode=2 && u!=cursor.unit)
            {
                path := D2ReadU32(h,u+0x2C)
                if (path)
                {
                    slot := D2ReadU32(h,path+0x0C)
                    if (slot >= 0 && slot <= 15 && uid!=0xFFFFFFFF
                        && D2ReadU32(h,u+0x0C)=uid && D2ReadU32(h,u+0x10)=2)
                    {
                        slots[slot] := {cls:cls,uid:uid,slot:slot,unit:u}
                        BeltSendLogV101("BELT_SLOT_READ slot=" . slot . " uid=" . uid
                            . " class=" . cls . " mode=" . mode . " loc=" . loc45)
                    }
                }
            }
        }

        e4:=D2ReadU32(h,u+0xE4), e8:=D2ReadU32(h,u+0xE8)
        if (e4 && !seen.HasKey(e4))
            queue.Push(e4)
        if (e8 && !seen.HasKey(e8))
            queue.Push(e8)

        if (typ=4 && itemData)
        {
            ptrOffsets := [0x60,0x64,0x6C,0x70,0x84,0xAC,0xB0,0xB4,0xC8,0xD8]
            for _,po in ptrOffsets
            {
                pu:=D2ReadU32(h,itemData+po)
                if (pu && !seen.HasKey(pu) && D2ReadU32(h,pu)=4)
                    queue.Push(pu)
            }
        }
    }

    DllCall("CloseHandle","Ptr",h)
    return slots
}

V50RemotePacket26(ctx, unitId, beltSlot)
{
    if (RemoteThreadBusyV740(D2GetActiveGamePidV95()))
        return false
    global cubePickupDelayMs
    pid := ctx.pid
    if (!pid)
        return false

    if (beltSlot < 0 || beltSlot > 15)
    {
        BeltSendLogV101("DIRECT19_23_BLOCK invalid_slot=" . beltSlot)
        return false
    }

    netBase := D2GetModuleBaseV35(pid, "D2Net.dll")
    if (!netBase)
    {
        BeltSendLogV101("DIRECT19_23_BLOCK D2Net=0")
        return false
    }

    sendFn := netBase + 0x7650
    BeltSendLogV101("DIRECT19_23 D2Net=" . V92Hex(netBase) . " Send=" . V92Hex(sendFn)
        . " uid=" . unitId . " slot=" . beltSlot)

    hSend := DllCall("OpenProcess", "UInt", 0x043A, "Int", 0, "UInt", pid, "Ptr")
    if (!hSend)
    {
        BeltSendLogV101("DIRECT19_23 OpenProcess_FAIL err=" . A_LastError)
        return false
    }

    remote := DllCall("VirtualAllocEx", "Ptr", hSend, "Ptr", 0, "UPtr", 256
        , "UInt", 0x3000, "UInt", 0x40, "Ptr")
    if (!remote)
    {
        err := A_LastError
        DllCall("CloseHandle", "Ptr", hSend)
        BeltSendLogV101("DIRECT19_23 Alloc_FAIL err=" . err)
        return false
    }

    VarSetCapacity(pkt19, 5, 0)
    NumPut(0x19, pkt19, 0, "UChar")
    NumPut(unitId, pkt19, 1, "UInt")

    VarSetCapacity(pkt23, 9, 0)
    NumPut(0x23, pkt23, 0, "UChar")
    NumPut(unitId, pkt23, 1, "UInt")
    NumPut(beltSlot, pkt23, 5, "UInt")

    wrote19 := 0, wrote23 := 0
    ok19 := DllCall("WriteProcessMemory", "Ptr", hSend, "Ptr", remote+128
        , "Ptr", &pkt19, "UPtr", 5, "UPtrP", wrote19)
    ok23 := DllCall("WriteProcessMemory", "Ptr", hSend, "Ptr", remote+160
        , "Ptr", &pkt23, "UPtr", 9, "UPtrP", wrote23)

    VarSetCapacity(code19, 32, 0)
    o := 0
    NumPut(0x68, code19, o, "UChar"), o += 1
    NumPut(remote+128, code19, o, "UInt"), o += 4
    NumPut(0x6A, code19, o, "UChar"), o += 1
    NumPut(0x01, code19, o, "UChar"), o += 1
    NumPut(0x6A, code19, o, "UChar"), o += 1
    NumPut(0x05, code19, o, "UChar"), o += 1
    NumPut(0xB8, code19, o, "UChar"), o += 1
    NumPut(sendFn, code19, o, "UInt"), o += 4
    NumPut(0xFF, code19, o, "UChar"), o += 1
    NumPut(0xD0, code19, o, "UChar"), o += 1
    NumPut(0xC3, code19, o, "UChar"), o += 1
    wroteCode19 := 0
    okCode19 := DllCall("WriteProcessMemory", "Ptr", hSend, "Ptr", remote
        , "Ptr", &code19, "UPtr", o, "UPtrP", wroteCode19)

    VarSetCapacity(code23, 32, 0)
    p := 0
    NumPut(0x68, code23, p, "UChar"), p += 1
    NumPut(remote+160, code23, p, "UInt"), p += 4
    NumPut(0x6A, code23, p, "UChar"), p += 1
    NumPut(0x01, code23, p, "UChar"), p += 1
    NumPut(0x6A, code23, p, "UChar"), p += 1
    NumPut(0x09, code23, p, "UChar"), p += 1
    NumPut(0xB8, code23, p, "UChar"), p += 1
    NumPut(sendFn, code23, p, "UInt"), p += 4
    NumPut(0xFF, code23, p, "UChar"), p += 1
    NumPut(0xD0, code23, p, "UChar"), p += 1
    NumPut(0xC3, code23, p, "UChar"), p += 1
    wroteCode23 := 0
    okCode23 := DllCall("WriteProcessMemory", "Ptr", hSend, "Ptr", remote+64
        , "Ptr", &code23, "UPtr", p, "UPtrP", wroteCode23)

    if (!ok19 || !ok23 || !okCode19 || !okCode23)
    {
        err := A_LastError
        DllCall("VirtualFreeEx", "Ptr", hSend, "Ptr", remote, "UPtr", 0, "UInt", 0x8000)
        DllCall("CloseHandle", "Ptr", hSend)
        BeltSendLogV101("DIRECT19_23 Write_FAIL err=" . err)
        return false
    }

    BeltSendLogV101("PACKET19 uid=" . unitId)
    th1 := DllCall("CreateRemoteThread", "Ptr", hSend, "Ptr", 0, "UPtr", 0
        , "Ptr", remote, "Ptr", 0, "UInt", 0, "UIntP", tid1, "Ptr")
    if (!th1)
    {
        err := A_LastError
        DllCall("VirtualFreeEx", "Ptr", hSend, "Ptr", remote, "UPtr", 0, "UInt", 0x8000)
        DllCall("CloseHandle", "Ptr", hSend)
        BeltSendLogV101("DIRECT19_23 Thread19_FAIL err=" . err)
        return false
    }
    wait1 := DllCall("WaitForSingleObject", "Ptr", th1, "UInt", 1000)
    exit1 := 0
    DllCall("GetExitCodeThread", "Ptr", th1, "UIntP", exit1)
    BeltSendLogV101("PACKET19_RESULT wait=" . wait1 . " exit=" . V92Hex(exit1)
        . " pkt=" . wrote19 . " code=" . wroteCode19)
    if (wait1 != 0)
    {
        RemoteThreadFinishV740(hSend,th1,remote,wait1)
        return false
    }
    DllCall("CloseHandle", "Ptr", th1)

    Sleep, %cubePickupDelayMs%

    BeltSendLogV101("PACKET23 uid=" . unitId . " slot=" . beltSlot)
    th2 := DllCall("CreateRemoteThread", "Ptr", hSend, "Ptr", 0, "UPtr", 0
        , "Ptr", remote+64, "Ptr", 0, "UInt", 0, "UIntP", tid2, "Ptr")
    if (!th2)
    {
        err := A_LastError
        DllCall("VirtualFreeEx", "Ptr", hSend, "Ptr", remote, "UPtr", 0, "UInt", 0x8000)
        DllCall("CloseHandle", "Ptr", hSend)
        BeltSendLogV101("DIRECT19_23 Thread23_FAIL err=" . err)
        return false
    }
    wait2 := DllCall("WaitForSingleObject", "Ptr", th2, "UInt", 1000)
    exit2 := 0
    DllCall("GetExitCodeThread", "Ptr", th2, "UIntP", exit2)

    RemoteThreadFinishV740(hSend,th2,remote,wait2)

    ok := (wait1 = 0 && wait2 = 0)
    BeltSendLogV101("PACKET23_RESULT wait=" . wait2 . " exit=" . V92Hex(exit2)
        . " pkt=" . wrote23 . " code=" . wroteCode23 . " ok=" . ok)
    return ok
}

TransferHotkeyTrace(action)
{
    global pickupCubeTraceUntil, xRunning, v103CubeMoveRunning, debugPrivilegeOK, debugPrivilegeError
    if (!pickupCubeTraceUntil || A_TickCount >= pickupCubeTraceUntil)
        return
    traceChannel := (action="RUONG_TO_CUBE") ? "cube" : "belt"
    pid := D2GetActiveGamePidV95()
    WinGet, processName, ProcessName, A
    WinGetTitle, title, A
    active := IsGameActive()
    DebugTraceWrite(traceChannel, "TRANSFER_KEY action=" . action . " hotkey=" . A_ThisHotkey
        . " pid=" . pid . " process=" . processName . " title=" . title
        . " active=" . active . " ahk_bits=" . (A_PtrSize*8) . " admin=" . A_IsAdmin
        . " debug_privilege=" . debugPrivilegeOK . " debug_error=" . debugPrivilegeError
        . " xRunning=" . xRunning . " cubeRunning=" . v103CubeMoveRunning)
    if (!active || !pid)
        return
    snap := DllCall("CreateToolhelp32Snapshot", "UInt", 0x8|0x10, "UInt", pid, "Ptr")
    snapError := (snap && snap!=-1) ? 0 : A_LastError
    base := 0, firstError := 0, nextError := 0, moduleCount := 0
    if (snap && snap != -1)
    {
        sz := (A_PtrSize=8) ? 1080 : 1064
        nameOffset := (A_PtrSize=8) ? 48 : 32
        baseOffset := (A_PtrSize=8) ? 24 : 20
        VarSetCapacity(me, sz, 0)
        NumPut(sz, me, 0, "UInt")
        ok := DllCall("Module32FirstW", "Ptr", snap, "Ptr", &me)
        firstError := ok ? 0 : A_LastError
        while (ok)
        {
            moduleCount++
            moduleName := StrGet(&me+nameOffset, 256, "UTF-16")
            if (moduleName="D2Client.dll")
                base := NumGet(me, baseOffset, "Ptr")
            ok := DllCall("Module32NextW", "Ptr", snap, "Ptr", &me)
            nextError := A_LastError
        }
        DllCall("CloseHandle", "Ptr", snap)
    }
    h := D2OpenProcess(pid)
    openError := h ? 0 : A_LastError
    player := (h && base) ? D2ReadU32(h, base+0x11BBFC) : 0
    inv := player ? D2ReadU32(h, player+0x60) : 0
    first := inv ? D2ReadU32(h, inv+0x10) : 0
    DebugTraceWrite(traceChannel, "TRANSFER_OPEN snapshot=" . snap . " snapshot_error=" . snapError
        . " module_first_error=" . firstError . " module_next_error=" . nextError
        . " module_count=" . moduleCount . " D2Client=" . base
        . " process_handle=" . h . " open_error=" . openError
        . " player=" . player . " inventory=" . inv . " first_item=" . first)
    if (h)
        DllCall("CloseHandle", "Ptr", h)
}

DebugTraceFile(channel)
{
    if (channel="pickup")
        return TxtRootPathV816("Auto-GSF-Nhat-Ruong.txt")
    if (channel="belt")
        return TxtRootPathV816("Auto-GSF-Ruong-Belt.txt")
    if (channel="cube")
        return TxtRootPathV816("Auto-GSF-Ruong-Cube.txt")
    if (channel="heal")
        return TxtRootPathV816("Auto-GSF-Buff-HP-Mana.txt")
    if (channel="monster")
        return TxtRootPathV816("Auto-GSF-Quai-Boss.txt")
    if (channel="character")
        return TxtRootPathV816("Auto-GSF-Nhan-Vat-DLL.txt")
    if (channel="packet")
        return TxtRootPathV816("Auto-GSF-Click-Phai-Packet.txt")
    return ""
}

DebugTraceWrite(channel, message)
{
    if (!ManualLogActiveV81())
        return
    global pickupCubeTraceUntil
    if (!pickupCubeTraceUntil || A_TickCount >= pickupCubeTraceUntil)
        return
    log := DebugTraceFile(channel)
    if (log="")
        return
    ManualLogAppendV81(A_Now . " tick=" . A_TickCount . " | " . message . "`r`n", log, "UTF-8")
}

V104CubeLog(message)
{
    isCube := InStr(message, "PICKUP_CUBE_")=1
        || InStr(message, "PICKUP_CURSOR_")=1
        || InStr(message, "PICKUP_RELEASE_")=1
        || InStr(message, "PICKUP_")!=1
    DebugTraceWrite(isCube ? "cube" : "pickup", message)
}

V104RemotePacket19_2A(ctx, unitId, cubeUid, itemUnit, itemData, cubeUnit, cubeData, inv, potionClass)
{
    if (RemoteThreadBusyV740(D2GetActiveGamePidV95()))
        return false
    global cubePickupDelayMs
    if (unitId=cubeUid || potionClass=1204)
    {
        V104CubeLog("DIRECT19_2A_BLOCK reason=CUBE_SELF_INSERT uid=" . unitId . " cube_uid=" . cubeUid)
        return false
    }
    pid := ctx.pid
    if (!pid)
        return false
    if (!ctx.allowAny && potionClass != 1229 && potionClass != 1234)
    {
        V104CubeLog("DIRECT19_2A_BLOCK invalid_potion_class=" . potionClass)
        return false
    }
    if (cubeUid <= 0)
    {
        V104CubeLog("DIRECT19_2A_BLOCK invalid_cube_uid=" . cubeUid)
        return false
    }
    netBase := D2GetModuleBaseV35(pid, "D2Net.dll")
    if (!netBase)
    {
        V104CubeLog("DIRECT19_2A_BLOCK D2Net=0")
        return false
    }
    sendFn := netBase + 0x7650
    V104CubeLog("DIRECT19_2A D2Net=" . V92Hex(netBase) . " Send=" . V92Hex(sendFn)
        . " uid=" . unitId . " cube_uid=" . cubeUid)
    hSend := DllCall("OpenProcess", "UInt", 0x043A, "Int", 0, "UInt", pid, "Ptr")
    if (!hSend)
    {
        V104CubeLog("DIRECT19_2A OpenProcess_FAIL err=" . A_LastError)
        return false
    }
    remote := DllCall("VirtualAllocEx", "Ptr", hSend, "Ptr", 0, "UPtr", 256
        , "UInt", 0x3000, "UInt", 0x40, "Ptr")
    if (!remote)
    {
        err := A_LastError
        DllCall("CloseHandle", "Ptr", hSend)
        V104CubeLog("DIRECT19_2A Alloc_FAIL err=" . err)
        return false
    }
    VarSetCapacity(pkt19, 5, 0)
    NumPut(0x19, pkt19, 0, "UChar")
    NumPut(unitId, pkt19, 1, "UInt")
    VarSetCapacity(pkt2A, 9, 0)
    NumPut(0x2A, pkt2A, 0, "UChar")
    NumPut(unitId, pkt2A, 1, "UInt")
    NumPut(cubeUid, pkt2A, 5, "UInt")
    wrote19 := 0, wrote2A := 0
    ok19 := DllCall("WriteProcessMemory", "Ptr", hSend, "Ptr", remote+128
        , "Ptr", &pkt19, "UPtr", 5, "UPtrP", wrote19)
    ok2A := DllCall("WriteProcessMemory", "Ptr", hSend, "Ptr", remote+160
        , "Ptr", &pkt2A, "UPtr", 9, "UPtrP", wrote2A)
    VarSetCapacity(code19, 32, 0)
    o := 0
    NumPut(0x68, code19, o, "UChar"), o += 1
    NumPut(remote+128, code19, o, "UInt"), o += 4
    NumPut(0x6A, code19, o, "UChar"), o += 1
    NumPut(0x01, code19, o, "UChar"), o += 1
    NumPut(0x6A, code19, o, "UChar"), o += 1
    NumPut(0x05, code19, o, "UChar"), o += 1
    NumPut(0xB8, code19, o, "UChar"), o += 1
    NumPut(sendFn, code19, o, "UInt"), o += 4
    NumPut(0xFF, code19, o, "UChar"), o += 1
    NumPut(0xD0, code19, o, "UChar"), o += 1
    NumPut(0xC3, code19, o, "UChar"), o += 1
    wroteCode19 := 0
    okCode19 := DllCall("WriteProcessMemory", "Ptr", hSend, "Ptr", remote
        , "Ptr", &code19, "UPtr", o, "UPtrP", wroteCode19)
    VarSetCapacity(code2A, 32, 0)
    p := 0
    NumPut(0x68, code2A, p, "UChar"), p += 1
    NumPut(remote+160, code2A, p, "UInt"), p += 4
    NumPut(0x6A, code2A, p, "UChar"), p += 1
    NumPut(0x01, code2A, p, "UChar"), p += 1
    NumPut(0x6A, code2A, p, "UChar"), p += 1
    NumPut(0x09, code2A, p, "UChar"), p += 1
    NumPut(0xB8, code2A, p, "UChar"), p += 1
    NumPut(sendFn, code2A, p, "UInt"), p += 4
    NumPut(0xFF, code2A, p, "UChar"), p += 1
    NumPut(0xD0, code2A, p, "UChar"), p += 1
    NumPut(0xC3, code2A, p, "UChar"), p += 1
    wroteCode2A := 0
    okCode2A := DllCall("WriteProcessMemory", "Ptr", hSend, "Ptr", remote+64
        , "Ptr", &code2A, "UPtr", p, "UPtrP", wroteCode2A)
    if (!ok19 || !ok2A || !okCode19 || !okCode2A)
    {
        err := A_LastError
        DllCall("VirtualFreeEx", "Ptr", hSend, "Ptr", remote, "UPtr", 0, "UInt", 0x8000)
        DllCall("CloseHandle", "Ptr", hSend)
        V104CubeLog("DIRECT19_2A Write_FAIL err=" . err)
        return false
    }
    if (D2ReadU32(hSend,itemUnit+0x00) != 4
        || D2ReadU32(hSend,itemUnit+0x0C) != unitId
        || D2ReadU32(hSend,itemUnit+0x04) != potionClass
        || D2ReadU32(hSend,itemUnit+0x14) != itemData
        || D2ReadU8V18(hSend,itemData+0x45) != 0
        || D2ReadU32(hSend,itemData+0x5C) != inv
        || D2ReadU32(hSend,cubeUnit+0x00) != 4
        || D2ReadU32(hSend,cubeUnit+0x0C) != cubeUid
        || D2ReadU32(hSend,cubeUnit+0x04) != 1204
        || D2ReadU32(hSend,cubeUnit+0x14) != cubeData
        || D2ReadU8V18(hSend,cubeData+0x45) != 0
        || D2ReadU32(hSend,cubeData+0x5C) != inv)
    {
        V104CubeLog("SKIP_WRONG_POTION_OR_CUBE_CHANGED uid=" . unitId . " class=" . potionClass . " cube_uid=" . cubeUid)
        DllCall("VirtualFreeEx", "Ptr", hSend, "Ptr", remote, "UPtr", 0, "UInt", 0x8000)
        DllCall("CloseHandle", "Ptr", hSend)
        return false
    }
    V104CubeLog("PACKET19 uid=" . unitId)
    th1 := DllCall("CreateRemoteThread", "Ptr", hSend, "Ptr", 0, "UPtr", 0
        , "Ptr", remote, "Ptr", 0, "UInt", 0, "UIntP", tid1, "Ptr")
    if (!th1)
    {
        err := A_LastError
        DllCall("VirtualFreeEx", "Ptr", hSend, "Ptr", remote, "UPtr", 0, "UInt", 0x8000)
        DllCall("CloseHandle", "Ptr", hSend)
        V104CubeLog("DIRECT19_2A Thread19_FAIL err=" . err)
        return false
    }
    wait1 := DllCall("WaitForSingleObject", "Ptr", th1, "UInt", 1000)
    exit1 := 0
    DllCall("GetExitCodeThread", "Ptr", th1, "UIntP", exit1)
    V104CubeLog("PACKET19_RESULT wait=" . wait1 . " exit=" . V92Hex(exit1)
        . " pkt=" . wrote19 . " code=" . wroteCode19)
    if (wait1 != 0)
    {
        RemoteThreadFinishV740(hSend,th1,remote,wait1)
        return false
    }
    DllCall("CloseHandle", "Ptr", th1)
    Sleep, %cubePickupDelayMs%
    V104CubeLog("PACKET2A uid=" . unitId . " cube_uid=" . cubeUid)
    th2 := DllCall("CreateRemoteThread", "Ptr", hSend, "Ptr", 0, "UPtr", 0
        , "Ptr", remote+64, "Ptr", 0, "UInt", 0, "UIntP", tid2, "Ptr")
    if (!th2)
    {
        err := A_LastError
        DllCall("VirtualFreeEx", "Ptr", hSend, "Ptr", remote, "UPtr", 0, "UInt", 0x8000)
        DllCall("CloseHandle", "Ptr", hSend)
        V104CubeLog("DIRECT19_2A Thread2A_FAIL err=" . err)
        return false
    }
    wait2 := DllCall("WaitForSingleObject", "Ptr", th2, "UInt", 1000)
    exit2 := 0
    DllCall("GetExitCodeThread", "Ptr", th2, "UIntP", exit2)
    RemoteThreadFinishV740(hSend,th2,remote,wait2)
    ok := (wait1 = 0 && wait2 = 0)
    V104CubeLog("PACKET2A_RESULT wait=" . wait2 . " exit=" . V92Hex(exit2)
        . " pkt=" . wrote2A . " code=" . wroteCode2A . " ok=" . ok)
    return ok
}

V44OpenGameContext()
{
    ctx := D2OpenHealContextV3()
    if (ctx.reason!="OK")
        return false
    if (!ctx.inv || !ctx.first)
    {
        DllCall("CloseHandle","Ptr",ctx.h)
        return false
    }
    ctx.d2base := D2GetModuleBaseV35(ctx.pid,"D2Client.dll")
    return ctx
}

V2CubeWatchTimer:
if (!ManualLogActiveV81())
{
    SetTimer, V2CubeWatchTimer, Off
    return
}
if (xRunning)
    return
if (!cubeCtrlLogArmed)
{
    SetTimer, V2CubeWatchTimer, Off
    return
}
if (A_TickCount > cubeCtrlLogExpire)
{
    cubeCtrlLogArmed := false
    SetTimer, V2CubeWatchTimer, Off
    log := A_ScriptDir . "\Auto-GSF-Debug.log"
    ManualLogAppendV81("V2_WATCH_TIMEOUT - khong thay HP/MP loc45 0->3`r`n", log, "UTF-8")
    ToolTipInfoV386("CUBE LOG V2: hết 15 giây - chưa thấy chuyển")
    SetTimer, RemoveToolTip, -2200
    return
}
V2CheckCubeMove()
return

V2CheckCubeMove()
{
    if (!ManualLogActiveV81())
        return
    global cubeCtrlLogArmed, cubeWatchBefore
    after := V1SnapshotHPManaLoc()
    for uid, b in cubeWatchBefore
    {
        if (b.loc != 0 || !after.HasKey(uid))
            continue
        a := after[uid]
        if (a.loc = 3)
        {
            cubeCtrlLogArmed := false
            SetTimer, V2CubeWatchTimer, Off
            log := A_ScriptDir . "\Auto-GSF-Debug.log"
            ManualLogAppendV81("`r`n================ V2 MOVE CONFIRMED ================`r`n", log, "UTF-8")
            ManualLogAppendV81("DETECTED tick=" . A_TickCount . "`r`n", log, "UTF-8")
            ManualLogAppendV81("CHANGE id=" . uid . " class=" . b.cls . " loc45 " . b.loc . "->" . a.loc . " xy " . b.x . "," . b.y . "->" . a.x . "," . a.y . " unit=" . V92Hex(b.unit) . " data=" . V92Hex(b.data) . "`r`n", log, "UTF-8")
            ManualLogAppendV81("BEFORE loc45=" . b.loc . " x=" . b.x . " y=" . b.y . "`r`n", log, "UTF-8")
            ManualLogAppendV81("AFTER  loc45=" . a.loc . " x=" . a.x . " y=" . a.y . "`r`n", log, "UTF-8")
            ManualLogAppendV81("BELT_COMPARE=0x19 lifts item; 0x23 places to Belt; BYTE27 offsets were captured above for comparison.`r`n", log, "UTF-8")
            ManualLogAppendV81("RESULT=RUONG_TO_CUBE_CONFIRMED`r`n", log, "UTF-8")
            ToolTipInfoV386("CUBE LOG V2 OK - đã bắt Rương -> Cube")
            SetTimer, RemoveToolTip, -2200
            return
        }
    }
}

V1SnapshotHPManaLoc()
{
    r := {}
    tmp := A_Temp . "\d2_v2_cube_pid.txt"
    try FileDelete, %tmp%
    cmd := "tasklist /FI " . Chr(34) . "IMAGENAME eq Game.exe" . Chr(34) . " /FO CSV /NH > " . Chr(34) . tmp . Chr(34) . " 2>&1"
    RunWait, %ComSpec% /c %cmd%,, Hide
    FileRead, raw, %tmp%
    try FileDelete, %tmp%

    h := 0, first := 0
    Loop, Parse, raw, `n, `r
    {
        if !RegExMatch(A_LoopField, "i)^""Game\.exe"",""([0-9]+)""", m)
            continue
        pid := m1 + 0
        base := D2GetModuleBaseV35(pid, "D2Client.dll")
        if (!base)
            continue
        h0 := D2OpenProcess(pid)
        if (!h0)
            continue
        p := D2ReadU32(h0, base + 0x11BBFC)
        inv := p ? D2ReadU32(h0, p + 0x60) : 0
        f := inv ? D2ReadU32(h0, inv + 0x10) : 0
        if (p && inv && f)
        {
            h := h0, first := f
            break
        }
        DllCall("CloseHandle", "Ptr", h0)
    }
    if (!h || !first)
        return r

    q := [first], seen := {}, qi := 1
    Loop, 8192
    {
        if (qi > q.Length())
            break
        u := q[qi], qi++
        if (!u || seen.HasKey(u))
            continue
        seen[u] := 1
        typ := D2ReadU32(h,u+0x00), cls := D2ReadU32(h,u+0x04)
        uid := D2ReadU32(h,u+0x0C), data := D2ReadU32(h,u+0x14)
        path := D2ReadU32(h,u+0x2C)
        Loop, 64
        {
            off := (A_Index-1)*4
            pu := D2ReadU32(h,u+off)
            if (!pu || seen.HasKey(pu))
                continue
            pt := D2ReadU32(h,pu+0x00), pc := D2ReadU32(h,pu+0x04)
            if (pt=4 && pc>=1 && pc<=10000)
                q.Push(pu)
        }
        if (typ=4 && data)
        {
            Loop, 64
            {
                off := (A_Index-1)*4
                pu := D2ReadU32(h,data+off)
                if (!pu || seen.HasKey(pu))
                    continue
                pt := D2ReadU32(h,pu+0x00), pc := D2ReadU32(h,pu+0x04)
                if (pt=4 && pc>=1 && pc<=10000)
                    q.Push(pu)
            }
        }
        if (typ=4 && (cls=1229 || cls=1234) && data && uid)
        {
            loc := D2ReadU8V18(h,data+0x45)
            x := path ? D2ReadU32(h,path+0x0C) : 0
            y := path ? D2ReadU32(h,path+0x10) : 0
            r[uid] := {cls:cls, loc:loc, x:x, y:y, unit:u, data:data}
        }
    }
    DllCall("CloseHandle","Ptr",h)
    return r
}

InvToCubeHandler:
if (!IsGameForegroundV63())
    return
if (sigBusyV147)
    return
if (packetWatchArmedV1)
    return
TransferHotkeyTrace("RUONG_TO_CUBE")
if (xRunning)
{
    DebugTraceWrite("cube", "TRANSFER_BLOCKED reason=BUFF_RUNNING")
    return
}
if (!IsGameActive() || v103CubeMoveRunning)
{
    DebugTraceWrite("cube", "TRANSFER_BLOCKED active=" . IsGameActive() . " busy=" . v103CubeMoveRunning)
    return
}
if (!GameItemActionBeginV4("Cube", "cube", true))
    return
v103CubeMoveRunning := true
try
{
    V105SendAllPotionsToCube()
}
finally
{
    v103CubeMoveRunning := false
    GameItemActionEndV4("Cube")
}
return

V105SendAllPotionsToCube()
{
    global cubePickupDelayMs, cubeTransferDelayMs
    moved := 0, hpMoved := 0, mpMoved := 0, reason := ""
    batch := V105ScanStashPotions()
    DebugTraceWrite("cube", "CUBE_SCAN reason=" . batch.reason
        . " pid=" . batch.pid . " potions=" . (IsObject(batch.potions) ? batch.potions.Length() : 0))
    if (batch.reason != "")
        reason := batch.reason
    else
    {
        for _, p in batch.potions
        {
            if (!IsGameActive() || D2GetActiveGamePidV95() != batch.pid)
            {
                reason := "GAME_NOT_ACTIVE"
                break
            }
            DebugTraceWrite("cube", "CUBE_ITEM_BEGIN uid=" . p.uid . " class=" . p.cls
                . " cube_uid=" . batch.cube.uid)
            result := V103SendOnePotionToCube(batch, p)
            DebugTraceWrite("cube", "CUBE_ITEM_RESULT uid=" . p.uid . " class=" . p.cls
                . " confirmed=" . result.moved . " reason=" . result.reason)
            if (!result.moved)
            {
                reason := result.reason
                break
            }
            moved++
            if (result.cls = 1229)
                hpMoved++
            else if (result.cls = 1234)
                mpMoved++
        }
    }
    if (reason = "")
        reason := "STASH_EMPTY"
    movedText := "HP " . hpMoved . ", MP " . mpMoved
    if (reason = "STASH_EMPTY")
        message := "ĐÃ CHUYỂN " . movedText . " - RƯƠNG HẾT BÌNH"
    else if (reason = "CUBE_FULL" || reason = "CUBE_FULL_OR_REJECTED")
        message := "ĐÃ CHUYỂN " . movedText . " - CUBE KHÔNG NHẬN THÊM"
    else
        message := "ĐÃ CHUYỂN " . movedText . " - DỪNG: " . reason
    DebugTraceWrite("cube", "CUBE_TRANSFER_RESULT " . message)
    ToolTipInfoV386(message)
    SetTimer, RemoveToolTip, -3000
    return moved
}

V105ScanStashPotions()
{
    pid := D2GetActiveGamePidV95()
    if (!pid)
        return {reason:"GAME_NOT_ACTIVE"}
    base := D2GetModuleBaseV35(pid, "D2Client.dll")
    h := D2OpenProcess(pid)
    if (!h || !base)
    {
        if (h)
            DllCall("CloseHandle", "Ptr", h)
        return {reason:"OPEN_GAME_FAILED"}
    }
    player := D2ReadU32(h, base + 0x11BBFC)
    inv := player ? D2ReadU32(h, player + 0x60) : 0
    first := inv ? D2ReadU32(h, inv + 0x10) : 0
    if (!first)
    {
        DllCall("CloseHandle", "Ptr", h)
        return {reason:"INVENTORY_UNAVAILABLE"}
    }
    snapshot := V9SnapshotAllItems({pid:pid,h:h,inv:inv,first:first})
    potions := [], cube := 0, hpSeen := 0, mpSeen := 0, cubeSeen := 0
    for itemUid, item in snapshot
    {
        if ((item.cls=1229 || item.cls=1234) && item.loc=0 && item.owner=inv)
        {
            if (D2ReadU32(h,item.unit)=4 && D2ReadU32(h,item.unit+0x0C)=itemUid
                && D2ReadU32(h,item.unit+0x04)=item.cls && D2ReadU32(h,item.unit+0x14)=item.data
                && D2ReadU8V18(h,item.data+0x45)=0 && D2ReadU32(h,item.data+0x5C)=inv)
            {
                potions.Push({uid:itemUid,unit:item.unit,data:item.data,cls:item.cls,loc:0,x:item.x,y:item.y})
                if (item.cls=1229)
                    hpSeen++
                else
                    mpSeen++
            }
        }
        if (item.cls=1204)
        {
            cubeSeen++
            if (!IsObject(cube) && item.loc=0 && item.owner=inv
                && D2ReadU8V18(h,item.data)=2 && D2ReadU32(h,item.unit)=4
                && D2ReadU32(h,item.unit+0x0C)=itemUid && D2ReadU32(h,item.unit+0x14)=item.data)
                cube := {uid:itemUid,unit:item.unit,data:item.data,cls:item.cls,loc:0,owner:item.owner}
        }
    }
    DllCall("CloseHandle", "Ptr", h)
    if (!potions.Length() || !IsObject(cube))
        return {reason:(!potions.Length() ? "STASH_EMPTY" : "CUBE_NOT_FOUND")}
    return {reason:"",pid:pid,base:base,inv:inv,cube:cube,potions:potions}
}

V103SendOnePotionToCube(batch, p)
{
    global cubeTransferDelayMs
    pid := batch.pid, base := batch.base, inv := batch.inv, c := batch.cube
    h := D2OpenProcess(pid)
    if (!h)
        return {moved:false,reason:"OPEN_GAME_FAILED"}
    ctx := {pid:pid,inv:inv}
    if (D2ReadU32(h,p.unit+0x0C) != p.uid || D2ReadU32(h,p.unit+0x04) != p.cls
        || D2ReadU32(h,p.unit+0x14) != p.data || D2ReadU8V18(h,p.data+0x45) != 0
        || D2ReadU32(h,p.data+0x5C) != inv
        || D2ReadU32(h,c.unit+0x0C) != c.uid || D2ReadU32(h,c.unit+0x04) != 1204
        || D2ReadU32(h,c.unit+0x14) != c.data || D2ReadU8V18(h,c.data+0x45) != 0
        || D2ReadU32(h,c.data+0x5C) != inv)
    {
        DllCall("CloseHandle", "Ptr", h)
        return {moved:false,reason:"ITEM_IDENTITY_CHANGED"}
    }
    DllCall("CloseHandle", "Ptr", h)
    if (!IsGameActive() || D2GetActiveGamePidV95() != pid)
    {
        return {moved:false,reason:"GAME_NOT_ACTIVE"}
    }
    sent := V104RemotePacket19_2A(ctx, p.uid, c.uid, p.unit, p.data, c.unit, c.data, inv, p.cls)
    if (!sent)
    {
        return {moved:false,reason:"SEND_FAILED"}
    }
    hCheck := D2OpenProcess(pid)
    confirmed := false, locAfter := -1, foundAfter := false
    if (hCheck)
    {
        Loop, 12
        {
            Sleep, %cubeTransferDelayMs%
            if (D2ReadU32(hCheck,p.unit) != 4 || D2ReadU32(hCheck,p.unit+0x0C) != p.uid
                || D2ReadU32(hCheck,p.unit+0x04) != p.cls
                || D2ReadU32(hCheck,p.unit+0x14) != p.data)
                break
            foundAfter := true
            locAfter := D2ReadU8V18(hCheck,p.data+0x45)
            if (locAfter = 3)
            {
                confirmed := true
                break
            }
        }
        DllCall("CloseHandle", "Ptr", hCheck)
    }
    if (!confirmed && IsGameActive() && D2GetActiveGamePidV95() = pid)
    {
        GameTargetClickV63("Left")
    }
    return {moved:confirmed,cls:p.cls,reason:(confirmed ? "MOVED" : "CUBE_FULL_OR_REJECTED")}
}


V6SendPacket2A(ctx, itemUid, cubeUid)
{
    if (RemoteThreadBusyV740(D2GetActiveGamePidV95()))
        return false
    if (itemUid=cubeUid)
    {
        V104CubeLog("PACKET2A_BLOCK reason=CUBE_SELF_INSERT uid=" . itemUid)
        return false
    }
    pid := ctx.pid
    netBase := D2GetModuleBaseV35(pid,"D2Net.dll")
    if (!netBase)
        return false
    sendFn := netBase + 0x7650
    hSend := DllCall("OpenProcess","UInt",0x043A,"Int",0,"UInt",pid,"Ptr")
    if (!hSend)
        return false
    remote := DllCall("VirtualAllocEx","Ptr",hSend,"Ptr",0,"UPtr",128,"UInt",0x3000,"UInt",0x40,"Ptr")
    if (!remote)
    {
        DllCall("CloseHandle","Ptr",hSend)
        return false
    }
    VarSetCapacity(pkt,9,0)
    NumPut(0x2A,pkt,0,"UChar")
    NumPut(itemUid,pkt,1,"UInt")
    NumPut(cubeUid,pkt,5,"UInt")
    wrotePkt := 0
    okPkt := DllCall("WriteProcessMemory","Ptr",hSend,"Ptr",remote+64,"Ptr",&pkt,"UPtr",9,"UPtrP",wrotePkt)
    VarSetCapacity(code,32,0)
    o:=0
    NumPut(0x68,code,o,"UChar"),o+=1
    NumPut(remote+64,code,o,"UInt"),o+=4
    NumPut(0x6A,code,o,"UChar"),o+=1
    NumPut(0x01,code,o,"UChar"),o+=1
    NumPut(0x6A,code,o,"UChar"),o+=1
    NumPut(0x09,code,o,"UChar"),o+=1
    NumPut(0xB8,code,o,"UChar"),o+=1
    NumPut(sendFn,code,o,"UInt"),o+=4
    NumPut(0xFF,code,o,"UChar"),o+=1
    NumPut(0xD0,code,o,"UChar"),o+=1
    NumPut(0xC3,code,o,"UChar"),o+=1
    wroteCode:=0
    okCode := DllCall("WriteProcessMemory","Ptr",hSend,"Ptr",remote,"Ptr",&code,"UPtr",o,"UPtrP",wroteCode)
    if (!okPkt || !okCode)
    {
        DllCall("VirtualFreeEx","Ptr",hSend,"Ptr",remote,"UPtr",0,"UInt",0x8000)
        DllCall("CloseHandle","Ptr",hSend)
        return false
    }
    th := DllCall("CreateRemoteThread","Ptr",hSend,"Ptr",0,"UPtr",0,"Ptr",remote,"Ptr",0,"UInt",0,"UIntP",tid,"Ptr")
    if (!th)
    {
        DllCall("VirtualFreeEx","Ptr",hSend,"Ptr",remote,"UPtr",0,"UInt",0x8000)
        DllCall("CloseHandle","Ptr",hSend)
        return false
    }
    wait := DllCall("WaitForSingleObject","Ptr",th,"UInt",1000)
    exitCode:=0
    DllCall("GetExitCodeThread","Ptr",th,"UIntP",exitCode)
    RemoteThreadFinishV740(hSend,th,remote,wait)
    return (wait=0)
}

V9SnapshotAllItems(ctx := 0)
{
    r := {}
    ownsHandle := !IsObject(ctx)
    if (ownsHandle)
        ctx := V44OpenGameContext()
    if (!IsObject(ctx))
        return r
    h:=ctx.h, first:=ctx.first, inv:=ctx.inv
    q := [first], seen := {}, qi := 1
    while (qi <= q.Length() && qi <= 8192)
    {
        u := q[qi], qi++
        if (!u || seen.HasKey(u))
            continue
        seen[u] := 1
        typ := D2ReadU32(h,u+0x00)
        cls := D2ReadU32(h,u+0x04)
        uid := D2ReadU32(h,u+0x0C)
        data := (typ=4) ? D2ReadU32(h,u+0x14) : 0
        if (typ=4 && data && uid)
        {
            loc := D2ReadU8V18(h,data+0x45)
            owner := D2ReadU32(h,data+0x5C)
            path := D2ReadU32(h,u+0x2C)
            x := path ? D2ReadU32(h,path+0x0C) : -1
            y := path ? D2ReadU32(h,path+0x10) : -1
            r[uid] := {cls:cls,loc:loc,owner:owner,x:x,y:y,unit:u,data:data,inv:inv}
        }
        e4 := D2ReadU32(h,u+0xE4), e8 := D2ReadU32(h,u+0xE8)
        if (e4 && !seen.HasKey(e4))
            q.Push(e4)
        if (e8 && !seen.HasKey(e8))
            q.Push(e8)
        if (typ=4 && data)
        {
            ptrOffsets := [0x60,0x64,0x6C,0x70,0x84,0xAC,0xB0,0xB4,0xC8,0xD8]
            for _,po in ptrOffsets
            {
                pu := D2ReadU32(h,data+po)
                if (pu && !seen.HasKey(pu) && D2ReadU32(h,pu)=4)
                    q.Push(pu)
            }
        }
    }
    if (ownsHandle)
        DllCall("CloseHandle","Ptr",h)
    return r
}


V9CubeIdentityTimer:
if (!ManualLogActiveV81())
{
    SetTimer, V9CubeIdentityTimer, Off
    return
}
if (xRunning)
    return
if (!v9CubeWatchArmed)
{
    SetTimer, V9CubeIdentityTimer, Off
    return
}
if (A_TickCount > v9CubeWatchExpire)
{
    v9CubeWatchArmed := false
    SetTimer, V9CubeIdentityTimer, Off
    log := A_ScriptDir . "\Auto-GSF-Cube.log"
    ManualLogAppendV81("V9_WATCH_TIMEOUT - khong thay item nao doi loc/xy/owner`r`n", log, "UTF-8")
    ToolTipInfoV386("V9: hết 15 giây - chưa bắt được Cube")
    SetTimer, RemoveToolTip, -2200
    return
}
V9CheckCubeIdentity()
return

V9CheckCubeIdentity()
{
    if (!ManualLogActiveV81())
        return
    global v9CubeWatchArmed, v9CubeBefore
    after := V9SnapshotAllItems()
    log := A_ScriptDir . "\Auto-GSF-Cube.log"
    for uid,b in v9CubeBefore
    {
        if (!after.HasKey(uid))
            continue
        a := after[uid]
        if (b.loc!=a.loc || b.x!=a.x || b.y!=a.y || b.owner!=a.owner)
        {
            v9CubeWatchArmed := false
            SetTimer, V9CubeIdentityTimer, Off
            ManualLogAppendV81("`r`n================ V9 ITEM CHANGE DETECTED ================`r`n", log, "UTF-8")
            ManualLogAppendV81("V9_CANDIDATE class=" . b.cls . " uid=" . uid . " loc45 " . b.loc . "->" . a.loc . " xy " . b.x . "," . b.y . "->" . a.x . "," . a.y . " owner " . V92Hex(b.owner) . "->" . V92Hex(a.owner) . " unit=" . V92Hex(b.unit) . " data=" . V92Hex(b.data) . "`r`n", log, "UTF-8")
            ManualLogAppendV81("V9_RESULT=CUBE_IDENTITY_CANDIDATE_CAPTURED | NO_SEND`r`n", log, "UTF-8")
            ToolTipInfoV386("V9 OK: đã bắt item thay đổi - gửi log")
            SetTimer, RemoveToolTip, -2500
            return true
        }
    }
    return false
}


V23StopCapture()
{
    global v23Armed, v23h
    v23Armed:=false
    SetTimer, V23CtrlLeftTimer, Off
    if (v23h)
        DllCall("CloseHandle","Ptr",v23h)
    v23h:=0
}

V23CtrlLeftTimer:
if (!ManualLogActiveV81())
{
    SetTimer, V23CtrlLeftTimer, Off
    return
}
if (xRunning)
    return
if (!v23Armed)
{
    SetTimer, V23CtrlLeftTimer, Off
    return
}
if (A_TickCount>v23Expire)
{
    log:=A_ScriptDir . "\\Auto-GSF-Debug.log"
    ManualLogAppendV81("V23_TIMEOUT | khong thay HP/MP loc45 0->3 | NO_SEND`r`n", log, "UTF-8")
    V23StopCapture()
    ToolTipInfoV386("V23: hết 15 giây - chưa bắt được")
    SetTimer, RemoveToolTip, -2200
    return
}
V23CheckCtrlLeft()
return

V23CheckCtrlLeft()
{
    if (!ManualLogActiveV81())
        return
    global v23Armed, v23Before, v23h, v23base, v23LastSel, v23SelChanges
    if (!v23Armed || !v23h)
        return false
    sel:=D2ReadU32(v23h,v23base+0x11B834)
    if (sel!=v23LastSel)
    {
        uid:=sel ? D2ReadU32(v23h,sel+0x0C) : 0
        cls:=sel ? D2ReadU32(v23h,sel+0x04) : 0
        v23SelChanges .= " sel=" . V92Hex(sel) . "/uid=" . uid . "/class=" . cls
        v23LastSel:=sel
    }
    after:=V1SnapshotHPManaLoc()
    for uid,b in v23Before
    {
        if (!after.HasKey(uid))
            continue
        a:=after[uid]
        if (b.loc=0 && a.loc=3)
        {
            s54:=D2ReadU32(v23h,v23base+0x11B854)
            s58:=D2ReadU32(v23h,v23base+0x11B858)
            s64:=D2ReadU32(v23h,v23base+0x11B864)
            log:=A_ScriptDir . "\\Auto-GSF-Debug.log"
            ManualLogAppendV81("V23_MOVE_CONFIRMED uid=" . uid . " class=" . b.cls . " loc45=0->3 xy=" . b.x . "," . b.y . "->" . a.x . "," . a.y . "`r`n", log, "UTF-8")
            ManualLogAppendV81("V23_SELECTED_CHANGES=" . v23SelChanges . "`r`n", log, "UTF-8")
            ManualLogAppendV81("V23_STATE_AT_CONFIRM selected=" . V92Hex(sel) . " s54=" . s54 . " s58=" . V92Hex(s58) . " s64=" . s64 . "`r`n", log, "UTF-8")
            ManualLogAppendV81("V23_RESULT=CTRL_LEFT_RUONG_TO_CUBE_CONFIRMED | NO_SEND`r`n", log, "UTF-8")
            V23StopCapture()
            ToolTipInfoV386("V23 OK: đã bắt Ctrl+LEFT - gửi log")
            SetTimer, RemoveToolTip, -2500
            return true
        }
    }
    return false
}

V102StopOneHPWatch()
{
    global v102OneHPArmed, v102OneHPHandle
    v102OneHPArmed := false
    SetTimer, V102OneHPWatchTimer, Off
    if (v102OneHPHandle)
        DllCall("CloseHandle", "Ptr", v102OneHPHandle)
    v102OneHPHandle := 0
}


V102OneHPWatchTimer:
if (!ManualLogActiveV81())
{
    SetTimer, V102OneHPWatchTimer, Off
    return
}
if (xRunning)
    return
if (!v102OneHPArmed)
{
    SetTimer, V102OneHPWatchTimer, Off
    return
}
if (A_TickCount >= v102OneHPExpire)
{
    log := A_ScriptDir . "\Auto-GSF-Cube.log"
    ManualLogAppendV81(A_Now . " | TIMEOUT: khong thay HP chuyen loc45=0->3.`r`n", log, "UTF-8")
    V102StopOneHPWatch()
    ToolTipInfoV386("HẾT 15 GIÂY - chưa thấy HP vào Cube")
    SetTimer, RemoveToolTip, -2500
    return
}
for uid, item in v102OneHPBefore
{
    if (D2ReadU32(v102OneHPHandle, item.unit + 0x0C) != uid)
        continue
    dataNow := D2ReadU32(v102OneHPHandle, item.unit + 0x14)
    if (!dataNow)
        continue
    locNow := D2ReadU8V18(v102OneHPHandle, dataNow + 0x45)
    if (locNow != 3)
        continue
    ownerNow := D2ReadU32(v102OneHPHandle, dataNow + 0x5C)
    pathNow := D2ReadU32(v102OneHPHandle, item.unit + 0x2C)
    xNow := pathNow ? D2ReadU32(v102OneHPHandle, pathNow + 0x0C) : 0
    yNow := pathNow ? D2ReadU32(v102OneHPHandle, pathNow + 0x10) : 0
    log := A_ScriptDir . "\Auto-GSF-Cube.log"
    ManualLogAppendV81(A_Now . " | CHUYEN_THANH_CONG uid=" . uid . " class=1229 loc45=" . item.loc . "->" . locNow . " owner=" . V92Hex(item.owner) . "->" . V92Hex(ownerNow) . " xy=" . item.x . "," . item.y . "->" . xNow . "," . yNow . " unit=" . V92Hex(item.unit) . " itemData=" . V92Hex(item.data) . "->" . V92Hex(dataNow) . "`r`n", log, "UTF-8")
    V102StopOneHPWatch()
    ToolTipInfoV386("ĐÃ BẮT 1 HP RƯƠNG -> CUBE - xem file log")
    SetTimer, RemoveToolTip, -2500
    return
}
return

ManualLogActiveV81()
{
    global manualLogOnV81, manualLogClosingV81
    return manualLogOnV81 || manualLogClosingV81
}

ManualLogAppendV81(message, originalPath, encoding := "UTF-8")
{
    global manualLogFolderV81, manualLogStartV81, manualLogSessionV95, manualLogFilesV98
    if (!ManualLogActiveV81() || manualLogFolderV81="" || originalPath="")
        return false
    SplitPath, originalPath, channelFile
    if (!manualLogFilesV98.HasKey(channelFile) || !manualLogFilesV98[channelFile])
        return false
    part := Floor((A_TickCount-manualLogStartV81)/10000)+1
    partPath := manualLogFolderV81 . "\" . manualLogSessionV95 . "-" . Format("{:04}",part) . "-" . channelFile
    FileAppend, %message%, %partPath%, UTF-8
    wroteV749 := !ErrorLevel
    if (wroteV749)
    {
        try
            ManualLogVNAppendV749(message,channelFile)
        catch errorV749
            ManualLogVNFailedV749()
    }
    return wroteV749
}

MapFullExportTimerV134:
MapFullExportV134()
return

MapFullExportV134()
{
    global manualLogOnV81,manualLogFolderV81,manualLogSessionV95,manualLogFilesV98,mapFullCapturedV134
    static busy := false
    if (busy || !manualLogOnV81 || !manualLogFilesV98["Auto-GSF-Map-Full.log"])
        return
    busy := true,h := 0,session := manualLogSessionV95
    try
    {
        pid := CoordDisplayGamePidV1(),base := pid ? D2GetModuleBaseV35(pid,"D2Client.dll") : 0
        h := base ? DllCall("OpenProcess","UInt",0x0410,"Int",0,"UInt",pid,"Ptr") : 0
        if (!h)
            return
        player := D2ReadU32(h,base+0x11BBFC),path := player ? D2ReadU32(h,player+0x2C) : 0
        if (!MonsterBossProbeReadV1(h,path,0x20,pb))
            return
        room1 := NumGet(pb,0x1C,"UInt"),current := room1 ? D2ReadU32(h,room1+0x10) : 0
        if (!MonsterBossProbeReadV1(h,current,0x60,rb))
            return
        lp := NumGet(rb,0x58,"UInt"),level := lp ? D2ReadU32(h,lp+0x1D0) : 0
        if (!level || !MonsterBossProbeReadV1(h,lp,0x20,lb))
            return
        captureKey := pid . "|" . lp . "|" . level
        if (mapFullCapturedV134=captureKey)
            return
        first := NumGet(lb,0x10,"UInt"),nodes := {},queue := [current],chainSeen := {},chainStatus := "NO_VALID_HEAD",failed := 0
        chain := first
        if (chain>=0x10000)
        {
            chainStatus := "END_NULL"
            while (chain)
            {
                if (!manualLogOnV81 || manualLogSessionV95!=session)
                    return
                if (chainSeen.HasKey(chain) || chainSeen.Count()>=4096)
                {
                    chainStatus := "CYCLE_OR_LIMIT"
                    break
                }
                if (!MonsterBossProbeReadV1(h,chain,0x60,cb) || NumGet(cb,0x58,"UInt")!=lp)
                {
                    chainStatus := "READ_FAILED_OR_OTHER_LEVEL"
                    break
                }
                chainSeen[chain] := true,queue.Push(chain)
                chain := NumGet(cb,0x24,"UInt")
                if (Mod(chainSeen.Count(),32)=0)
                    Sleep, -1
            }
        }
        queued := {},qi := 1,limited := false
        while (qi<=queue.Length())
        {
            if (!manualLogOnV81 || manualLogSessionV95!=session)
                return
            address := queue[qi++]
            if (queued.HasKey(address))
                continue
            if (queued.Count()>=4096)
            {
                limited := true
                break
            }
            queued[address] := true
            node := RoomExploreReadV89(h,address,level)
            if (!IsObject(node) || D2ReadU32(h,address+0x58)!=lp)
            {
                failed++
                continue
            }
            nodes[address] := node
            for _,neighbor in node.links
                if (!queued.HasKey(neighbor))
                    queue.Push(neighbor)
            if (Mod(queued.Count(),32)=0)
                Sleep, -1
        }
        file := RoomProfileFileV108(),section := "Rooms-" . level,saved := {},savedCount := 0,maxSaved := -1
        IniRead, savedRaw, %file%, %section%
        Loop, Parse, savedRaw, `n, `r
        {
            if (RegExMatch(A_LoopField,"^(\d+_\d+_\d+_\d+)=(\d+)$",m))
                saved[m1] := m2+0,savedCount++,maxSaved := Max(maxSaved,m2+0)
        }
        IniRead, nextSaved, %file%, %section%, NextNumber, MISSING
        chainComplete := chainStatus="END_NULL" && chainSeen.HasKey(current) && !failed && !limited
        log := "FULL_MAP_BEGIN time=" . A_Now . " pid=" . pid . " map=" . level . " player=" . NumGet(pb,2,"UShort") . "," . NumGet(pb,6,"UShort")
            . " current_room2=" . V92Hex(current) . " level_pointer=" . V92Hex(lp) . " head=" . V92Hex(first)
            . " source=GAME_MEMORY read_only=1 file=" . file . "`r`n"
        log .= "FULL_MAP_METHOD level_head_offset=0x10 room2_next_offset=0x24 level_owner_offset=0x58"
            . " chain_status=" . chainStatus . " chain_rooms=" . chainSeen.Count() . " current_in_chain=" . chainSeen.HasKey(current)
            . " chain_complete=" . chainComplete . " failed_reads=" . failed . " limit_reached=" . limited
            . " links_kind=GEOGRAPHIC_NEIGHBORS_NOT_CONFIRMED_WALKABLE level_header_raw=" . MonsterBossProbeHexV1(lb,0x20) . "`r`n"
        geometry := {},foundSaved := {},loaded := 0,index := 0,missing := 0
        for address,node in nodes
        {
            key := node.x . "_" . node.y . "_" . node.w . "_" . node.h
            geometry[key] := true
            number := saved.HasKey(key) ? saved[key] : "UNSAVED"
            if (saved.HasKey(key))
                foundSaved[key] := true
            else
                missing++
            links := ""
            for _,neighbor in node.links
            {
                other := nodes[neighbor]
                otherKey := IsObject(other) ? other.x . "_" . other.y . "_" . other.w . "_" . other.h : ""
                otherNumber := otherKey!="" && saved.HasKey(otherKey) ? saved[otherKey] : "UNSAVED"
                links .= (links="" ? "" : ",") . V92Hex(neighbor) . ":" . otherNumber
            }
            loaded += node.r1 ? 1 : 0,index++
            log .= "ROOM index=" . index . " saved_number=" . number . " current=" . (address=current)
                . " room2=" . V92Hex(address) . " room1=" . V92Hex(node.r1) . " loaded=" . (node.r1!=0)
                . " rect=" . node.x . "," . node.y . "," . node.w . "," . node.h . " center=" . node.cx . "," . node.cy
                . " neighbors=" . links . " raw=" . node.raw . "`r`n"
        }
        absent := 0
        for key,number in saved
            if (!foundSaved.HasKey(key))
            {
                absent++
                log .= "SAVED_NOT_FOUND_IN_MEMORY saved_number=" . number . " rect=" . key . "`r`n"
            }
        log .= "FULL_MAP_END memory_room_addresses=" . nodes.Count() . " unique_room_rectangles=" . geometry.Count()
            . " loaded_room1=" . loaded . " saved_room_count=" . savedCount . " highest_saved_number=" . maxSaved
            . " next_saved_number=" . nextSaved . " memory_rooms_without_saved_number=" . missing . " saved_rooms_absent=" . absent
            . " complete_level_list=" . chainComplete . " numbering=FILE_ASSIGNED_NOT_GAME_ROOM_COUNT`r`n`r`n"
        if (!manualLogOnV81 || manualLogSessionV95!=session)
            return
        output := manualLogFolderV81 . "\" . session . "-Auto-GSF-Map-Full.log"
        FileAppend, %log%, %output%, UTF-8
        if (!ErrorLevel)
        {
            mapFullCapturedV134 := captureKey
            ToolTipInfoV386("Đã xuất map " . level . ": " . nodes.Count() . " phòng. Xem Auto-GSF-Map-Full.log trong Logs.")
            SetTimer, RemoveToolTip, -3000
        }
        else
        {
            ToolTipInfoV386("Không ghi được Auto-GSF-Map-Full.log trong thư mục Logs.")
            SetTimer, RemoveToolTip, -3000
        }
    }
    finally
    {
        if (h)
            DllCall("CloseHandle","Ptr",h)
        busy := false
    }
}

ManualLogStopV81:
showLogV749 := manualLogOnV81 && A_ExitReason=""
SetTimer, MapInputWatchV176, Off
SetTimer, StageTwoTestArmTimerV167, Off
stageTwoTestWaitV167 := 0
if (!IsObject(stageTwoV166) || (!stageTwoV166.continuous && !stageTwoV166.restartRunV17))
    StageTwoStopV166("LOG_STOP_BUTTON")
SetTimer, WpCaptureTimerV161, Off
PacketWatchStopV1()
wpCaptureV161 := false
SigCubeCaptureStopV151()
if (!IsObject(sigTownV148) || !sigTownV148.auto)
    SigTownCancelV148("LOG_STOP_BUTTON")
SetTimer, MapFullExportTimerV134, Off
SetTimer, EntryMouseLogTimerV160, Off
SetTimer, StageTwoKeyLogTimerV164, Off
if (IsObject(roomExploreV89) && !roomExploreV89.manualReplay)
    RoomExploreStopV89("LOG_STOP")
manualLogClosingV81 := true
FarmInfoLogStopV4()
ManualLogAppendV81(A_Now . " | SESSION_END reason=USER_STOP`r`n",A_ScriptDir . "\Auto-GSF-Cong-Len-Map.log")
V102StopOneHPWatch()
PacketWatchStopV1()
for _,stopLogTimerV81 in ["PortalLogTimerV66","NativeExportTimerV12","CharacterDLLProbeTimerV3","MonsterBossProbeTimerV1","StopPickupCubeTrace","V104CubeGroundTimer","V2CubeWatchTimer","V9CubeIdentityTimer","V23CtrlLeftTimer","V102OneHPWatchTimer"]
    SetTimer, %stopLogTimerV81%, Off
portalLogUntilV66 := 0
pickupCubeTraceUntil := 0
pickupCubeTracePacket := false
autoMonsterExportV2 := false
cubeCtrlLogArmed := false
v104CubeExpire := 0
manualLogOnV81 := false
manualLogClosingV81 := false
GuiControl,, ExportLogButtonV81, XUẤT LOG
try
    ManualLogVNStopV749(showLogV749)
catch errorV749
    ToolTipInfoV386("Đã dừng log. Không mở được bảng diễn giải; log gốc vẫn còn.")
return

ManualLogClearOldV157(folder)
{
    global manualLogFilesV98
    failed := 0
    Loop, Files, % folder . "\*", F
    {
        if (!RegExMatch(A_LoopFileName,"i)\.(txt|log)$") && !RegExMatch(A_LoopFileName,"i)-Stage2-.*\.bmp$"))
            continue
        try FileDelete, %A_LoopFileFullPath%
        if (ErrorLevel)
            failed++
    }
    for name,_ in manualLogFilesV98
    {
        oldPath := A_ScriptDir . "\" . name
        if (!FileExist(oldPath))
            continue
        try FileDelete, %oldPath%
        if (ErrorLevel)
            failed++
    }
    return failed=0
}
RouteRecordToggleV358:
RouteRecorderShowV657()
return

RouteRecorderShowV657()
{
    global routeRecorderHwndV657,routeRecordV358
    global RouteRecorderNameV657,RouteRecorderStatusV657,RouteRecorderFileV657,RouteRecorderPointsV657,RouteRecorderIdentityTextV658
    if (!routeRecorderHwndV657 || !DllCall("IsWindow","Ptr",routeRecorderHwndV657))
    {
        Gui, RouteRecorderV657:New, +AlwaysOnTop +HwndrouteRecorderHwndV657, Ghi Tọa Độ GD1
        Gui, RouteRecorderV657:Font, s9, Segoe UI
        Gui, RouteRecorderV657:Add, Text, x12 y15 w70 h22, Tên tuyến:
        Gui, RouteRecorderV657:Add, Edit, x84 y10 w300 h26 vRouteRecorderNameV657, GD1
        Gui, RouteRecorderV657:Add, Button, x396 y9 w112 h28 gRouteRecorderStartV657, Bắt đầu ghi
        Gui, RouteRecorderV657:Add, Button, x518 y9 w112 h28 gRouteRecorderStopV657, Dừng và lưu
        Gui, RouteRecorderV657:Add, Button, x518 y46 w112 h28 gGD1IdentifyButtonV643, Nhận Diện
        Gui, RouteRecorderV657:Add, Text, x12 y48 w494 h34 vRouteRecorderStatusV657, Chưa ghi. Nhập tên tuyến rồi bấm Bắt đầu ghi.
        Gui, RouteRecorderV657:Add, Edit, x12 y88 w618 h42 ReadOnly vRouteRecorderFileV657, File sẽ lưu trong LoTrinh\GD1 khi bấm Dừng và lưu.
        Gui, RouteRecorderV657:Add, ListView, x12 y140 w618 h292 Grid vRouteRecorderPointsV657, STT|Map|Nhân vật X`,Y|Điểm click X`,Y|Đối tượng / NPC
        LV_ModifyCol(1,42), LV_ModifyCol(2,48), LV_ModifyCol(3,100), LV_ModifyCol(4,100), LV_ModifyCol(5,300)
        Gui, RouteRecorderV657:Add, Edit, x12 y442 w618 h70 Multi ReadOnly vRouteRecorderIdentityTextV658, Nhận diện NPC / kho / cổng: bấm Nhận Diện rồi đưa chuột lên đối tượng trong game.
        Gui, RouteRecorderV657:Add, Text, x12 y522 w618 h34, Chỉ ghi click trái trong cửa sổ game đã chọn. Mỗi dòng hiện ngay sau khi ghi thành công.
        Gui, 1:Default
    }
    Gui, RouteRecorderV657:Show, w642 h564
    Gui, 1:Default
}

RouteRecorderBeginV657(r)
{
    global routeRecorderHwndV657
    if (!routeRecorderHwndV657)
        return
    Gui, RouteRecorderV657:Default
    Gui, ListView, RouteRecorderPointsV657
    LV_Delete()
    GuiControl,, RouteRecorderFileV657, Đang ghi; chưa xuất file.
    Gui, 1:Default
    Gui, RouteRecorderV657:Show, NA
}

RouteRecorderAppendV657(index,c)
{
    global routeRecorderHwndV657
    if (!routeRecorderHwndV657)
        return
    Gui, RouteRecorderV657:Default
    Gui, ListView, RouteRecorderPointsV657
    LV_Add("",index,c.level,c.px . "," . c.py,c.mx . "," . c.my,c.targetDesc)
    LV_Modify(index,"Vis")
    Gui, 1:Default
    RouteRecorderStatusV657("ĐANG GHI: " . index . " điểm. Map " . c.level . " | Nhân vật: " . c.px . "," . c.py . " | Click: " . c.mx . "," . c.my)
}

RouteRecorderStatusV657(message)
{
    global routeRecorderHwndV657
    if (routeRecorderHwndV657)
        GuiControl, RouteRecorderV657:, RouteRecorderStatusV657, %message%
}

RouteRecorderIdentityV658(message)
{
    global routeRecorderHwndV657
    if (routeRecorderHwndV657 && DllCall("IsWindow","Ptr",routeRecorderHwndV657))
    {
        GuiControl, RouteRecorderV657:, RouteRecorderIdentityTextV658, %message%
        return true
    }
    return false
}

RouteRecorderSavedV657(file)
{
    global routeRecorderHwndV657
    if (routeRecorderHwndV657)
        GuiControl, RouteRecorderV657:, RouteRecorderFileV657, %file%
    RouteRecorderStatusV657("Đã dừng và lưu xong. Danh sách điểm được giữ để xem lại.")
}

RouteRecorderStartV657:
if (IsObject(routeRecordV358))
{
    RouteRecorderStatusV657("Đang có phiên ghi. Dừng và lưu trước khi ghi tuyến mới.")
    return
}
RouteRecordStartV358()
return

RouteRecorderStopV657:
if (IsObject(routeRecordV358) && !routeRecordV358.planV375)
    RouteRecordStopV358("RECORDER_FORM_STOP")
return

RouteRecorderV657GuiClose:
RouteRecorderV657GuiEscape:
if (IsObject(routeRecordV358) && !routeRecordV358.planV375)
{
    if (!RouteRecordStopV358("RECORDER_FORM_CLOSE"))
        return
}
Gui, RouteRecorderV657:Hide
return

RouteRecordStartV358()
{
    global routeRecordV358, backgroundPidV63, backgroundHwndV63, roomRecordV108
    if (IsObject(roomRecordV108))
    {
        ToolTipInfoV386("Đang Tạo/Sửa Map — dừng lại trước khi Ghi Map.")
        SetTimer, RemoveToolTip, -3000
        return false
    }
    GuiControlGet, gd1NameV643, RouteRecorderV657:, RouteRecorderNameV657
    if (Trim(gd1NameV643)="")
    {
        RouteRecorderStatusV657("Nhập tên tuyến trước khi bắt đầu ghi.")
        return false
    }
    gd1NameV643 := RegExReplace(Trim(gd1NameV643),"[\\/:*?""<>|]","_")
    if (!SigBackgroundBindV179() || !PickupActivateGameV13())
    {
        RouteRecorderStatusV657("Không tìm thấy cửa sổ game; chọn game rồi bấm Bắt đầu ghi lại.")
        ToolTipInfoV386("Không tìm thấy cửa sổ game để ghi lộ trình.")
        SetTimer, RemoveToolTip, -3000
        return false
    }
    routeRecordV358 := {pid:backgroundPidV63, hwnd:backgroundHwndV63
        , startAt:A_TickCount, clicks:[],gd1NameV643:gd1NameV643}
    RouteRecorderBeginV657(routeRecordV358)
    GuiControl, 1:, RouteRecordButtonV358, Đang ghi (0)
    Hotkey, ~*LButton, RouteRecordMouseDownV358, On
    RouteRecorderStatusV657("ĐANG GHI: click chuột trái trong game. Bấm Dừng và lưu trên form khi xong.")
    SetTimer, RemoveToolTip, -6000
    return true
}

RouteRecordStopV358(reason)
{
    global routeRecordV358
    r := routeRecordV358
    if (!IsObject(r))
        return false
    Hotkey, ~*LButton, RouteRecordMouseDownV358, Off
    routeRecordV358 := false
    if (r.planV375)
    {
        RoutePlanRecordingUiV375(false)
        GuiControl, 1:, RouteRecordButtonV358, Ghi Tọa Độ
        return true
    }
    GuiControl, 1:, RouteRecordButtonV358, Ghi Tọa Độ
    logDir := A_ScriptDir . (r.gd1NameV643!="" ? "\LoTrinh\GD1" : "\Logs")
    try FileCreateDir, %logDir%
    outFile := logDir . "\" . (r.gd1NameV643!="" ? r.gd1NameV643 . "-" : "Route-Record-") . A_Now . "-" . A_TickCount . ".txt"
    content := "=== GHI LO TRINH " . A_Now . " ===`r`n"
    content .= "pid=" . r.pid . " hwnd=" . r.hwnd . " clicks=" . r.clicks.Length() . " reason=" . reason . "`r`n"
    content .= "Cot: CLICK#N | t_ms | client=cx,cy | screen=sx,sy | level | player=px,py | map=mx,my`r`n"
    content .= "player = toa do nhan vat trong map khi click`r`n"
    content .= "map    = toa do map ma con tro dang chi (quy doi tu client + camera)`r`n`r`n"
    for i, c in r.clicks
    {
        content .= "CLICK#" . i
            . " | t=" . (c.at - r.startAt)
            . " | client=" . c.cx . "," . c.cy
            . " | screen=" . c.sx . "," . c.sy
            . " | level=" . c.level
            . " | player=" . c.px . "," . c.py
            . " | map=" . c.mx . "," . c.my
            . "`r`n"
        if (c.targetDesc != "")
            content .= "  TARGET " . c.targetDesc . "`r`n"
    }
    content .= "`r`n; GD1: đúng tọa độ click theo thứ tự, không phụ thuộc file Map.`r`n"
    content .= "GD1Route := []`r`n"
    for i,c in r.clicks
        content .= "GD1Route.Push({level:" . c.level . ",x:" . c.mx . ",y:" . c.my . "})"
            . (c.targetDesc!="" ? " `; " . c.targetDesc : "") . "`r`n"
    content .= "`r`n=== END ===`r`n"
    f := FileOpen(outFile, "w", "UTF-8")
    if (IsObject(f))
    {
        writtenV657 := f.Write(content)
        f.Close()
        if (!writtenV657)
        {
            routeRecordV358 := r
            RouteRecorderStatusV657("Lỗi ghi file. Bấm Dừng và lưu để thử lại; dữ liệu vẫn được giữ.")
            return false
        }
        RouteRecorderSavedV657(outFile)
        ToolTipInfoV386("Đã ghi lộ trình: " . outFile)
    }
    else
    {
        routeRecordV358 := r
        RouteRecorderStatusV657("Không ghi được file. Kiểm tra quyền ghi rồi bấm Dừng và lưu lại.")
        ToolTipInfoV386("Không ghi được file lộ trình.")
        return false
    }
    SetTimer, RemoveToolTip, -5000
    return true
}

RouteRecordMouseDownV358:
if (!IsObject(routeRecordV358))
    return
if (!IsGameForegroundV63() || D2GetActiveGamePidV95() != routeRecordV358.pid)
    return
RouteRecordCaptureV358(routeRecordV358)
return

RouteRecordCaptureV358(r)
{
    if (!IsObject(r))
        return
    VarSetCapacity(pt, 8, 0)
    if (!DllCall("GetCursorPos", "Ptr", &pt))
        return
    sx := NumGet(pt, 0, "Int"), sy := NumGet(pt, 4, "Int")
    hwnd := r.hwnd
    if (!DllCall("IsWindow", "Ptr", hwnd))
        return
    NumPut(sx, pt, 0, "Int"), NumPut(sy, pt, 4, "Int")
    if (!DllCall("ScreenToClient", "Ptr", hwnd, "Ptr", &pt))
        return
    cx := NumGet(pt, 0, "Int"), cy := NumGet(pt, 4, "Int")
    px := 0, py := 0, level := 0, mx := 0, my := 0, targetDesc := ""
    base := D2GetModuleBaseV35(r.pid, "D2Client.dll")
    h := base ? D2OpenProcess(r.pid) : 0
    if (h)
    {
        try
        {
            player := D2ReadU32(h, base + 0x11BBFC)
            path := player ? D2ReadU32(h, player + 0x2C) : 0
            if (player && MonsterBossProbeReadV1(h, path, 0x20, pb))
            {
                px := NumGet(pb, 2, "UShort"), py := NumGet(pb, 6, "UShort")
                level := CoordLevelV14(h, NumGet(pb, 0x1C, "UInt"))
                view := AutoMonsterAttackViewV1(h, base, hwnd, path)
                if (IsObject(view) && view.cw > 0 && view.ch > 0)
                {
                    gx := cx * view.gw / view.cw
                    gy := cy * view.gh / view.ch
                    pSX := NumGet(pb, 8, "Int") - view.ox
                    pSY := NumGet(pb, 12, "Int") - view.oy
                    a := (gx - pSX) / 16.0
                    b := (gy - pSY) / 8.0
                    mx := Round(px + (a + b) / 2.0)
                    my := Round(py + (b - a) / 2.0)
                }
                unit := D2ReadU32(h, base + 0x11B834)
                if (unit && MonsterBossProbeReadV1(h, unit, 0x18, ub))
                {
                    kind := NumGet(ub, 0, "UInt")
                    cls  := NumGet(ub, 4, "UInt")
                    uid  := NumGet(ub, 12, "UInt")
                    if (kind = 1)
                        targetDesc := "NPC/MONSTER type=1 class=" . cls . " uid=" . uid
                    else if (kind = 2)
                        targetDesc := "OBJECT class=" . cls . " uid=" . uid
                    else if (kind = 4)
                    {
                        itemData := NumGet(ub, 0x14, "UInt")
                        q := itemData ? D2ReadU8V18(h, itemData) : 0
                        targetDesc := "ITEM class=" . cls . " itemdata=" . Format("{:02X}", q) . " uid=" . uid
                    }
                    else if (kind != 0)
                        targetDesc := "UNIT type=" . kind . " class=" . cls . " uid=" . uid
                    targetPathV643 := D2ReadU32(h,unit+0x2C)
                    if (targetDesc!="" && MonsterBossProbeReadV1(h,targetPathV643,0x18,targetPbV643))
                    {
                        txV643 := kind=1 ? NumGet(targetPbV643,2,"UShort") : NumGet(targetPbV643,0x0C,"UInt")
                        tyV643 := kind=1 ? NumGet(targetPbV643,6,"UShort") : NumGet(targetPbV643,0x10,"UInt")
                        targetDesc .= " x=" . txV643 . " y=" . tyV643
                    }
                }
            }
        }
        finally
            DllCall("CloseHandle", "Ptr", h)
    }
    if (!level || !IsObject(view) || mx<=0 || my<=0)
    {
        if (!r.planV375)
            RouteRecorderStatusV657("Chưa đọc được tọa độ click; chưa thêm điểm. Kiểm tra nhân vật trong game.")
        return
    }
    if (r.planV375)
    {
        line := "MOVE level=" . level . " x=" . mx . " y=" . my
        if (targetDesc!="")
            line .= " `; " . targetDesc
        if (!RoutePlanAppendV375(line))
        {
            RouteRecordStopV358("WRITE_FAILED")
            return
        }
    }
    r.clicks.Push({at:A_TickCount, sx:sx, sy:sy, cx:cx, cy:cy
        , px:px, py:py, level:level, mx:mx, my:my, targetDesc:targetDesc})
    GuiControl, 1:, RouteRecordButtonV358, % "Đang ghi (" . r.clicks.Length() . ")"
    if (!r.planV375)
        RouteRecorderAppendV657(r.clicks.Length(),r.clicks[r.clicks.Length()])
}
ExportHPManaLog:
if (manualLogOnV81)
{
    Gosub, ManualLogStopV81
    ToolTipInfoV386("ĐÃ DỪNG LOG — FARM VẪN CHẠY.")
    SetTimer, RemoveToolTip, -2500
    return
}
manualLogFolderV81 := A_ScriptDir . "\Logs"
manualLogSessionV95 := A_Now . "-" . A_TickCount
try FileCreateDir, %manualLogFolderV81%
if (ErrorLevel)
{
    ToolTipInfoV386("KHÔNG TẠO ĐƯỢC THƯ MỤC LOG.")
    SetTimer, RemoveToolTip, -2500
    return
}
if (!ManualLogClearOldV157(manualLogFolderV81))
{
    ToolTipInfoV386("KHÔNG XÓA ĐƯỢC LOG CŨ — ĐÓNG FILE LOG ĐANG MỞ RỒI THỬ LẠI.")
    SetTimer, RemoveToolTip, -3000
    return
}
manualLogStartV81 := A_TickCount
manualLogOnV81 := true
ManualLogVNStartV749()
FarmInfoLogStartV4()
mapFullCapturedV134 := ""
SetTimer, MapFullExportTimerV134, 1000
GuiControl,, ExportLogButtonV81, DỪNG LOG
PortalLogStartV66()
mapInputLastV176 := ""
SetTimer, MapInputWatchV176, 50
MapKeyTraceV174("INPUT_WATCH","START before_manual_L")
entryMouseStateV160 := {LButton:GetKeyState("LButton","P"),RButton:GetKeyState("RButton","P"),MButton:GetKeyState("MButton","P")}
SetTimer, EntryMouseLogTimerV160, 50
stageTwoKeysV164 := {Esc:GetKeyState("Esc","P"),Enter:GetKeyState("Enter","P"),Tab:GetKeyState("Tab","P")}
SetTimer, StageTwoKeyLogTimerV164, 50
PacketWatchStopV1()
autoMonsterExportV2 := autoMonsterAttackOn
SetTimer, CharacterDLLProbeTimerV3, Off
characterDLLProbeV3 := {moduleIndex:1,lastSnapshot:"",busy:false}
SetTimer, MonsterBossProbeTimerV1, Off
monsterProbeSeenV1 := {}
monsterProbeBusyV1 := false
pickupCubeTraceUntil := 0
pickupCubeTracePacket := false
SetTimer, StopPickupCubeTrace, Off
wpCaptureV161 := false
traceCreateFailed := false
for traceNameV98, traceEnabledV98 in manualLogFilesV98
{
    if (!traceEnabledV98 || traceNameV98="Auto-GSF-Map-Full.log" || traceNameV98="Auto-GSF-Tinh-Trang.txt")
        continue
    traceFile := A_ScriptDir . "\" . traceNameV98
    traceWrittenV98 := ManualLogAppendV81(A_Now . " tick=" . A_TickCount . " | TRACE_START channel=" . traceNameV98
        . " duration=UNTIL_STOP segment_ms=10000 profile=" . currentProfile . "`r`n", traceFile, "UTF-8")
    if (!traceWrittenV98)
        traceCreateFailed := true
}

if (traceCreateFailed)
{
    Gosub, ManualLogStopV81
    ToolTipInfoV386("KHÔNG TẠO ĐƯỢC FILE LOG TXT TRONG THƯ MỤC TOOL")
    SetTimer, RemoveToolTip, -3000
    return
}
stageTwoTestWaitV167 := 0
SetTimer, StageTwoTestArmTimerV167, Off
pickupCubeTraceUntil := A_TickCount + 2147480000
SetTimer, NativeExportTimerV12, 250
SetTimer, CharacterDLLProbeTimerV3, 500
DebugTraceWrite("character", "TEST town_to_field_buff_return duration=UNTIL_STOP segment_ms=10000 poll_ms=500 state_interpretation=PROBE")
DebugTraceWrite("pickup", "CONFIG pickup_on=" . pickupImageOn . " radius=" . pickupRadius
    . " rules=" . pickupAllowCount . " get_key=" . getIdKey)
DebugTraceWrite("belt", "CONFIG key_16HP=" . belt4HPKey . " key_8HP8MP=" . belt2HP2ManaKey
    . " pickup_delay_ms=" . cubePickupDelayMs . " transfer_delay_ms=" . cubeTransferDelayMs)
DebugTraceWrite("cube", "CONFIG key=" . invToCubeKey . " pickup_delay_ms=" . cubePickupDelayMs
    . " transfer_delay_ms=" . cubeTransferDelayMs)
SigGroundDiagnosticV63()
HealTrace("CONFIG priority=Belt>Ruong>Cube HP_belt=" . autoPotOn . " mana_belt=" . manaOn
    . " HP_ruong=" . invHealOn . " MP_ruong=" . invManaOn
    . " HP_cube=" . cubeHealOn . " MP_cube=" . cubeManaOn
    . " hp_threshold=" . potHPThreshold . " mana_threshold=" . manaThreshold
    . " hp_cooldown_ms=" . potCooldown . " mana_cooldown_ms=" . manaCooldown)
DebugTraceWrite("monster", "READ_ONLY_SCAN duration=UNTIL_STOP segment_ms=10000 poll_ms=500 classification=UNCONFIRMED auto_attack=" . autoMonsterAttackOn)
SetTimer, MonsterBossProbeTimerV1, 500
if (autoMonsterExportV2)
{
    log := TxtRootPathV816("Auto-GSF-Tu-Danh.txt")
    AutoMonsterAttackLogV2("TRACE_START duration=UNTIL_STOP segment_ms=10000 auto_attack=ON checkbox_preserved=1")
    DebugTraceWrite("packet", "AUTO_DIAGNOSTIC auto_attack=ON checkbox_preserved=1 capture=TOOL_CLIENT_CALL_STATUS actual_packet_capture=0 tool_actions=RUNNING duration=UNTIL_STOP segment_ms=10000")
    ToolTipInfoV386("ĐANG GHI LOG 10 GIÂY/ĐOẠN — BẤM XUẤT LOG ĐỂ DỪNG")
}
else
{
    DebugTraceWrite("packet", "CHARACTER_TEST capture=OFF tool_actions=RUNNING duration=UNTIL_STOP segment_ms=10000")
    ToolTipInfoV386("ĐANG GHI LOG 10 GIÂY/ĐOẠN — BẤM XUẤT LOG ĐỂ DỪNG")
}
SetTimer, StopPickupCubeTrace, Off
SetTimer, RemoveToolTip, -2500
return

StopPickupCubeTrace:
SetTimer, NativeExportTimerV12, Off
SetTimer, CharacterDLLProbeTimerV3, Off
PacketWatchStopV1()
if (autoMonsterExportV2)
{
    AutoMonsterAttackLogV2("TRACE_END auto_attack=" . autoMonsterAttackOn . " checkbox_preserved=1")
    autoMonsterExportV2 := false
}
SetTimer, MonsterBossProbeTimerV1, Off
if (pickupCubeTraceUntil && A_TickCount >= pickupCubeTraceUntil)
{
    pickupCubeTraceUntil := 0
    pickupCubeTracePacket := false
    for _, traceChannel in ["pickup", "belt", "cube", "heal", "monster", "packet", "character"]
    {
        traceFile := DebugTraceFile(traceChannel)
        ManualLogAppendV81(A_Now . " tick=" . A_TickCount . " | TRACE_END channel=" . traceChannel . "`r`n", traceFile, "UTF-8")
    }
}
return

V105CaptureOpenedCube:
V105LogCubeState()
ToolTipInfoV386("Đã chụp Cube lần 2 - xem Auto-GSF-Cube.log")
SetTimer, RemoveToolTip, -2500
return

V105LogCubeState()
{
    if (!ManualLogActiveV81())
        return
    static captureNo := 0
    log := A_ScriptDir . "\Auto-GSF-Cube.log"
    pid := D2GetActiveGamePidV95()
    base := pid ? D2GetModuleBaseV35(pid, "D2Client.dll") : 0
    h := base ? D2OpenProcess(pid) : 0
    player := h ? D2ReadU32(h, base + 0x11BBFC) : 0
    inv := player ? D2ReadU32(h, player + 0x60) : 0
    first := inv ? D2ReadU32(h, inv + 0x10) : 0
    if (!first)
    {
        if (h)
            DllCall("CloseHandle", "Ptr", h)
        ManualLogAppendV81(A_Now . " | CUBE_STATE_ERROR active_pid=" . pid . "`r`n", log, "UTF-8")
        return false
    }
    captureNo++
    ctx := {pid:pid,h:h,inv:inv,first:first}
    snapshot := V9SnapshotAllItems(ctx)
    selected := D2ReadU32(h, base + 0x11B834)
    ManualLogAppendV81("`r`n" . A_Now . " | CUBE_STATE #" . captureNo . " pid=" . pid . " player=" . V92Hex(player) . " inv=" . V92Hex(inv) . " selected=" . V92Hex(selected) . "`r`n", log, "UTF-8")
    uiRaw := ""
    Loop, 256
        uiRaw .= Format("{:02X}",D2ReadU8V18(h,base+0x11B800+A_Index-1))
    ManualLogAppendV81("D2CLIENT_UI_11B800_11B8FF=" . uiRaw . "`r`n", log, "UTF-8")
    cubeCount := 0, insideCount := 0
    for uid,item in snapshot
    {
        if (item.cls=1204)
        {
            quality := D2ReadU8V18(h,item.data+0x00)
            cubeCount++
            ManualLogAppendV81("CUBE uid=" . uid . " quality=" . Format("{:02X}",quality) . " loc45=" . item.loc . " owner=" . V92Hex(item.owner) . " xy=" . item.x . "," . item.y . " unit=" . V92Hex(item.unit) . " itemData=" . V92Hex(item.data) . "`r`n", log, "UTF-8")
            raw := ""
            Loop, 128
                raw .= Format("{:02X}",D2ReadU8V18(h,item.data+A_Index-1))
            ManualLogAppendV81("CUBE_DATA_00_7F=" . raw . "`r`n", log, "UTF-8")
        }
        if (item.loc=3)
        {
            insideCount++
            ManualLogAppendV81("INSIDE uid=" . uid . " class=" . item.cls . " xy=" . item.x . "," . item.y . " itemData=" . V92Hex(item.data) . "`r`n", log, "UTF-8")
        }
    }
    ManualLogAppendV81("CUBE_STATE_END cube_count=" . cubeCount . " inside_count=" . insideCount . "`r`n", log, "UTF-8")
    DllCall("CloseHandle", "Ptr", h)
    return (cubeCount>0)
}
beltLogOK := V23WriteBelt16Log()
invLogOK := V2WriteManaProbeOnce()
cubeLogOK := V34WriteCubeProbeOnce()

trackLog := A_ScriptDir . "\TheoDoi-HP-Mana-Belt.log"
beltLog := A_ScriptDir . "\Belt-Wide-V24.log"
invLog := A_ScriptDir . "\HP-Mana-Test.log"
cubeLog := A_ScriptDir . "\Cube-HP-Mana-Test.log"

beltText := ""
invText := ""
cubeText := ""
if FileExist(beltLog)
    FileRead, beltText, %beltLog%
if FileExist(invLog)
    FileRead, invText, %invLog%
if FileExist(cubeLog)
    FileRead, cubeText, %cubeLog%

try FileDelete, %trackLog%
ManualLogAppendV81("================ THEO DOI HP-MANA-BELT V33 " . A_Now . " ================`r`n", trackLog, "UTF-8")
ManualLogAppendV81("READ ONLY - NO SEND / NO CLICK / NO PACKET`r`n", trackLog, "UTF-8")
ManualLogAppendV81("MUC DICH: SO SANH BELT + RUONG TRUOC/SAU SHIFT+CHUOT TRAI`r`n", trackLog, "UTF-8")
ManualLogAppendV81("PROFILE=" . currentProfile . " | BUFF_RUONG=" . InvHealOn . " | PHIM_4HP=" . Belt4HPKey . " | PHIM_2HP2MANA=" . Belt2HP2ManaKey . "`r`n", trackLog, "UTF-8")
ManualLogAppendV81("BAT_HP=" . AutoPotOn . " | BAT_MANA=" . ManaOn . " | HP_NGUONG=" . PotHPThreshold . " | MANA_NGUONG=" . ManaThreshold . "`r`n", trackLog, "UTF-8")
ManualLogAppendV81("BELT_SCAN_OK=" . beltLogOK . " | INVENTORY_SCAN_OK=" . invLogOK . " | CUBE_SCAN_OK=" . cubeLogOK . "`r`n", trackLog, "UTF-8")

ManualLogAppendV81("`r`n================ BELT ================`r`n", trackLog, "UTF-8")
if (beltText != "")
    ManualLogAppendV81(beltText, trackLog, "UTF-8")
else
    ManualLogAppendV81("KHONG CO DU LIEU BELT`r`n", trackLog, "UTF-8")

ManualLogAppendV81("`r`n================ RUONG / INVENTORY ================`r`n", trackLog, "UTF-8")
if (invText != "")
    ManualLogAppendV81(invText, trackLog, "UTF-8")
else
    ManualLogAppendV81("KHONG CO DU LIEU RUONG / INVENTORY`r`n", trackLog, "UTF-8")

ManualLogAppendV81("`r`n================ RUONG CUBE / CUBE INVENTORY PROBE ================`r`n", trackLog, "UTF-8")
if (cubeText != "")
    ManualLogAppendV81(cubeText, trackLog, "UTF-8")
else
    ManualLogAppendV81("KHONG CO DU LIEU CUBE`r`n", trackLog, "UTF-8")

ManualLogAppendV81("`r`n================ END V34 ================`r`n", trackLog, "UTF-8")

if (beltLogOK && invLogOK && cubeLogOK)
    ToolTipInfoV386("XUẤT LOG OK - TheoDoi-HP-Mana-Belt.log")
else
    ToolTipInfoV386("XUẤT LOG CHƯA ĐỦ - vào game rồi thử lại")
SetTimer, RemoveToolTip, -2500
return

ManaTestLogOnce:
return


V23WriteBelt16Log()
{
    if (!ManualLogActiveV81())
        return
    log := A_ScriptDir . "\\Belt-Wide-V24.log"
    tmp := A_Temp . "\\d2_belt_v24.txt"
    try FileDelete, %tmp%
    cmd := "tasklist /FI " . Chr(34) . "IMAGENAME eq Game.exe" . Chr(34) . " /FO CSV /NH > " . Chr(34) . tmp . Chr(34) . " 2>&1"
    RunWait, %ComSpec% /c %cmd%,, Hide
    FileRead, raw, %tmp%
    try FileDelete, %tmp%

    pidFound := 0, player := 0, h := 0
    Loop, Parse, raw, `n, `r
    {
        ln := A_LoopField
        if !RegExMatch(ln, "i)^""Game\.exe"",""([0-9]+)""", m)
            continue
        pid := m1 + 0
        base := D2GetModuleBaseV35(pid, "D2Client.dll")
        if (!base)
            continue
        h0 := D2OpenProcess(pid)
        if (!h0)
            continue
        pp := D2ReadU32(h0, base + 0x11BBFC)
        if (!pp)
        {
            DllCall("CloseHandle", "Ptr", h0)
            continue
        }
        pidFound := pid, player := pp, h := h0
        break
    }
    if (!pidFound || !player || !h)
        return false

    inv := D2ReadU32(h, player + 0x60)
    first := inv ? D2ReadU32(h, inv + 0x10) : 0
    if (!inv || !first)
    {
        DllCall("CloseHandle", "Ptr", h)
        return false
    }
    ManualLogAppendV81("================ BELT WIDE GRAPH V24 " . A_Now . " ================`r`n", log, "UTF-8")
    ManualLogAppendV81("READ ONLY - BELT DISCOVERY ONLY - RUONG V22 UNTOUCHED - NO SEND/CLICK/PACKET`r`n", log, "UTF-8")
    ManualLogAppendV81("EXPECTED PHYSICAL BELT: 12 HP + 4 MANA`r`n", log, "UTF-8")
    ManualLogAppendV81("KNOWN: HP_CLASS=1229 MANA_CLASS=1234`r`n", log, "UTF-8")
    ManualLogAppendV81("PID=" . pidFound . " PLAYER=" . V92Hex(player) . " INV=" . V92Hex(inv) . " FIRST=" . V92Hex(first) . "`r`n`r`n", log, "UTF-8")

    queue := [first]
    seen := {}
    qi := 1
    itemN := 0, beltN := 0, hpN := 0, manaN := 0
    Loop, 8192
    {
        if (qi > queue.Length())
            break
        u := queue[qi]
        qi++
        if (!u || seen.HasKey(u))
            continue
        seen[u] := 1

        typ := D2ReadU32(h, u + 0x00)
        cls := D2ReadU32(h, u + 0x04)
        uid := D2ReadU32(h, u + 0x0C)
        itemData := D2ReadU32(h, u + 0x14)
        path := D2ReadU32(h, u + 0x2C)

        Loop, 64
        {
            po := (A_Index-1)*4
            pu := D2ReadU32(h, u + po)
            if (!pu || seen.HasKey(pu))
                continue
            ptyp := D2ReadU32(h, pu + 0x00)
            pcls := D2ReadU32(h, pu + 0x04)
            if (ptyp = 4 && pcls >= 1 && pcls <= 10000)
                queue.Push(pu)
        }

        if (typ = 4 && itemData)
        {
            Loop, 64
            {
                po := (A_Index-1)*4
                pu := D2ReadU32(h, itemData + po)
                if (!pu || seen.HasKey(pu))
                    continue
                ptyp := D2ReadU32(h, pu + 0x00)
                pcls := D2ReadU32(h, pu + 0x04)
                if (ptyp = 4 && pcls >= 1 && pcls <= 10000)
                    queue.Push(pu)
            }
        }

        if (typ != 4 || cls < 1 || cls > 10000 || !itemData)
            continue

        itemN++
        q00 := D2ReadU8V18(h, itemData + 0x00)
        loc44 := D2ReadU8V18(h, itemData + 0x44)
        loc45 := D2ReadU8V18(h, itemData + 0x45)
        owner := D2ReadU32(h, itemData + 0x5C)
        x := path ? D2ReadU32(h, path + 0x0C) : 0
        y := path ? D2ReadU32(h, path + 0x10) : 0
        mark := ""
        if (loc45 = 255)
        {
            beltN++
            mark .= " BELT_CANDIDATE#" . beltN
        }
        if (cls = 1229)
        {
            hpN++
            mark .= " HP_CLASS1229"
        }
        if (cls = 1234)
        {
            manaN++
            mark .= " MANA_CLASS1234"
        }

        ManualLogAppendV81("ITEM#" . itemN . " unit=" . V92Hex(u) . " class=" . cls . " id=" . uid . " q00=" . q00 . " loc44=" . loc44 . " loc45=" . loc45 . " owner=" . V92Hex(owner) . " path=" . V92Hex(path) . " xy=" . x . "," . y . mark . "`r`n", log, "UTF-8")

        if (loc45 = 255 || cls = 1229 || cls = 1234)
        {
            d := ""
            Loop, 64
            {
                off := (A_Index-1)*4
                vv := D2ReadU32(h, u + off)
                d .= (A_Index=1 ? "" : " ") . Format("{:02X}:{:08X}", off, vv)
            }
            ManualLogAppendV81("  UNIT_DWORDS_00_FC " . d . "`r`n", log, "UTF-8")

            b := ""
            Loop, 256
            {
                off := A_Index-1
                vv := D2ReadU8V18(h, itemData + off)
                b .= (A_Index=1 ? "" : " ") . Format("{:02X}:{:02X}", off, vv)
            }
            ManualLogAppendV81("  ITEMDATA_BYTES_00_FF " . b . "`r`n", log, "UTF-8")
        }
    }

    ManualLogAppendV81("`r`nGRAPH_SEEN=" . seen.Count() . " ITEM_FOUND=" . itemN . " BELT_LOC255=" . beltN . " HP_CLASS1229=" . hpN . " MANA_CLASS1234=" . manaN . "`r`n", log, "UTF-8")
    ManualLogAppendV81("END BELT WIDE GRAPH V24`r`n", log, "UTF-8")
    DllCall("CloseHandle", "Ptr", h)
    return true
}


V2WriteManaProbeOnce()
{
    if (!ManualLogActiveV81())
        return
    log := A_ScriptDir . "\\HP-Mana-Test.log"
    tmp := A_Temp . "\\d2_inventory_hpmana_v16.txt"
    try FileDelete, %tmp%
    cmd := "tasklist /FI " . Chr(34) . "IMAGENAME eq Game.exe" . Chr(34) . " /FO CSV /NH > " . Chr(34) . tmp . Chr(34) . " 2>&1"
    RunWait, %ComSpec% /c %cmd%,, Hide
    FileRead, raw, %tmp%
    try FileDelete, %tmp%

    pidFound := 0, player := 0, h := 0
    Loop, Parse, raw, `n, `r
    {
        ln := A_LoopField
        if !RegExMatch(ln, "i)^""Game\.exe"",""([0-9]+)""", m)
            continue
        pid := m1 + 0
        base := D2GetModuleBaseV35(pid, "D2Client.dll")
        if (!base)
            continue
        h0 := D2OpenProcess(pid)
        if (!h0)
            continue
        pp := D2ReadU32(h0, base + 0x11BBFC)
        if (!pp)
        {
            DllCall("CloseHandle", "Ptr", h0)
            continue
        }
        pidFound := pid, player := pp, h := h0
        break
    }
    if (!pidFound || !player || !h)
        return false

    inv := D2ReadU32(h, player + 0x60)
    first := inv ? D2ReadU32(h, inv + 0x10) : 0
    if (!inv || !first)
    {
        DllCall("CloseHandle", "Ptr", h)
        return false
    }
    ManualLogAppendV81("================ INVENTORY HP-MANA WIDE GRAPH V16 " . A_Now . " ================`r`n", log, "UTF-8")
    ManualLogAppendV81("READ ONLY - INVENTORY/RUONG ONLY - NO BELT ACTION - NO GET - NO SEND/CLICK/PACKET`r`n", log, "UTF-8")
    ManualLogAppendV81("PID=" . pidFound . " PLAYER=" . V92Hex(player) . " INVENTORY=" . V92Hex(inv) . " FIRST=" . V92Hex(first) . "`r`n", log, "UTF-8")
    hpNow := D2GetCurrentHPV1()
    manaNow := D2GetCurrentManaV17()
    ManualLogAppendV81("CURRENT_HP=" . hpNow . " HP_KNOWN_CLASS=1229`r`n", log, "UTF-8")
    ManualLogAppendV81("CURRENT_MANA=" . manaNow . " MANA_KNOWN_CLASS=1234`r`n", log, "UTF-8")
    statDumpV21 := D2DumpPlayerStatRootV21()
    ManualLogAppendV81("---------------- STAT ROOT V21 0x00..0x100 ----------------`r`n" . statDumpV21, log, "UTF-8")

    queue := [first]
    seen := {}
    qi := 1
    foundCount := 0
    Loop, 4096
    {
        if (qi > queue.Length())
            break
        u := queue[qi]
        qi++
        if (!u || seen.HasKey(u))
            continue
        seen[u] := 1

        typ := D2ReadU32(h, u + 0x00)
        cls := D2ReadU32(h, u + 0x04)
        uid := D2ReadU32(h, u + 0x0C)
        itemData := D2ReadU32(h, u + 0x14)
        path := D2ReadU32(h, u + 0x2C)
        e4 := D2ReadU32(h, u + 0xE4)
        e8 := D2ReadU32(h, u + 0xE8)

        if (e4 && !seen.HasKey(e4))
            queue.Push(e4)
        if (e8 && !seen.HasKey(e8))
            queue.Push(e8)

        if (typ = 4 && itemData)
        {
            ptrOffsets := [0x60, 0x64, 0x6C, 0x70, 0x84, 0xAC, 0xB0, 0xB4, 0xC8, 0xD8]
            for _, po in ptrOffsets
            {
                pu := D2ReadU32(h, itemData + po)
                if (!pu || seen.HasKey(pu))
                    continue
                ptyp := D2ReadU32(h, pu + 0x00)
                pcls := D2ReadU32(h, pu + 0x04)
                if (ptyp = 4 && pcls >= 1 && pcls <= 10000)
                    queue.Push(pu)
            }
        }

        if (typ != 4 || cls < 1 || cls > 10000 || !itemData)
            continue

        foundCount++
        q00 := D2ReadU8V18(h, itemData + 0x00)
        loc44 := D2ReadU8V18(h, itemData + 0x44)
        loc45 := D2ReadU8V18(h, itemData + 0x45)
        x := path ? D2ReadU32(h, path + 0x0C) : 0
        y := path ? D2ReadU32(h, path + 0x10) : 0
        mark := (cls = 1229 ? " HP_KNOWN" : " MANA_CANDIDATE")

        ManualLogAppendV81("`r`nITEM n=" . foundCount . " unit=" . V92Hex(u) . " type=" . typ . " class=" . cls . " id=" . uid . " itemData=" . V92Hex(itemData) . " q00=" . q00 . " loc44=" . loc44 . " loc45=" . loc45 . " path=" . V92Hex(path) . " xy=" . x . "," . y . " E4=" . V92Hex(e4) . " E8=" . V92Hex(e8) . mark . "`r`n", log, "UTF-8")

        ManualLogAppendV81("UNIT_DWORDS_00_FC`r`n", log, "UTF-8")
        line := ""
        Loop, 64
        {
            ro := (A_Index - 1) * 4
            rv := D2ReadU32(h, u + ro)
            line .= Format("{:02X}", ro) . ":" . V92Hex(rv) . " "
            if (Mod(A_Index, 8) = 0)
            {
                ManualLogAppendV81(line . "`r`n", log, "UTF-8")
                line := ""
            }
        }

        ManualLogAppendV81("ITEMDATA_DWORDS_00_FC PTR=" . V92Hex(itemData) . "`r`n", log, "UTF-8")
        line := ""
        Loop, 64
        {
            ro := (A_Index - 1) * 4
            rv := D2ReadU32(h, itemData + ro)
            line .= Format("{:02X}", ro) . ":" . V92Hex(rv) . " "
            if (Mod(A_Index, 8) = 0)
            {
                ManualLogAppendV81(line . "`r`n", log, "UTF-8")
                line := ""
            }
        }

        ManualLogAppendV81("ITEMDATA_BYTES_00_7F`r`n", log, "UTF-8")
        line := ""
        Loop, 128
        {
            bo := A_Index - 1
            bv := D2ReadU8V18(h, itemData + bo)
            line .= Format("{:02X}", bo) . ":" . Format("{:02X}", bv) . " "
            if (Mod(A_Index, 16) = 0)
            {
                ManualLogAppendV81(line . "`r`n", log, "UTF-8")
                line := ""
            }
        }
    }

    ManualLogAppendV81("`r`nSUMMARY V16 INVENTORY_ITEMS=" . foundCount . " GRAPH_NODES=" . seen.Count() . "`r`n", log, "UTF-8")
    ManualLogAppendV81("END INVENTORY HP-MANA WIDE GRAPH V16`r`n", log, "UTF-8")
    DllCall("CloseHandle", "Ptr", h)
    return true
}

ClickCastTimer:
ClickCastDoubleHandler:
return

ClickCastReleaseWatch:
if (!GetKeyState(clickCastDoubleKey, "P"))
{
    clickCastHeld := false
    SetTimer, ClickCastReleaseWatch, Off
}
return

ClearExtraFRows()
{
    global FKey5, FKey6, FKey7, FKey8, FKey9, FKey10
    global FDelay5, FDelay6, FDelay7, FDelay8, FDelay9, FDelay10
    Loop, 5
    {
        i := A_Index + 5
        FKey%i% := ""
        FDelay%i% := 0
    }
}

SaveClickCastConfig(section)
{
    Form6SaveV716(section)
    global ConfigFile, clickCastRows, clickCastDoubleKey, clickCastDoubleTapMs
    try IniWrite, %clickCastDoubleKey%, % ProfileConfigPathV364(section), %section%, ClickCastDoubleKey
    try IniWrite, %clickCastDoubleTapMs%, % ProfileConfigPathV364(section), %section%, ClickCastDoubleTapMs
    for i, row in clickCastRows
    {
        key := row.key
        delay := row.delay
        try IniWrite, %key%, % ProfileConfigPathV364(section), %section%, ClickCastKey%i%
        try IniWrite, %delay%, % ProfileConfigPathV364(section), %section%, ClickCastDelay%i%
    }
}

LoadClickCastConfig(section)
{
    Form6LoadV716(section)
    global ConfigFile, clickCastRows, clickCastDoubleKey, clickCastDoubleTapMs
    global lastClickCastTap, clickCastHeld, doubleKey, formDoubleKey, qCastDoubleKey
    if (clickCastDoubleKey != "")
        ToolDoubleBindV18(clickCastDoubleKey,"ClickCastDoubleHandler","Off")
    IniRead, key, % ProfileConfigPathV364(section), %section%, ClickCastDoubleKey, Down
    if (!InStr("|None|Left|Right|Up|Down|Home|End|PgUp|PgDn|", "|" . key . "|"))
        key := "Down"
    IniRead, interval, % ProfileConfigPathV364(section), %section%, ClickCastDoubleTapMs, 1000
    if interval is not integer
        interval := 1000
    if (interval < 50)
        interval := 1000
    if (key!="None" && (key = doubleKey || key = formDoubleKey || key = qCastDoubleKey))
    {
        for _, candidate in ["Down", "Home", "End", "PgUp", "PgDn", "Left", "Right", "Up"]
        {
            if (candidate != doubleKey && candidate != formDoubleKey && candidate != qCastDoubleKey)
            {
                key := candidate
                break
            }
        }
    }
    clickCastDoubleKey := "None"
    clickCastDoubleTapMs := interval + 0
    lastClickCastTap := 0
    clickCastHeld := false
    SetTimer, ClickCastReleaseWatch, Off
    clickCastRows := []
    Loop, 6
    {
        i := A_Index
        IniRead, key, % ProfileConfigPathV364(section), %section%, ClickCastKey%i%, None
        IniRead, delay, % ProfileConfigPathV364(section), %section%, ClickCastDelay%i%, 0
        key := NormalizeOptionalKey(key)
        if (key != "" && !GetKeyVK(key) && !GetKeySC(key))
            key := ""
        if delay is not integer
            delay := 0
        if (delay < 0)
            delay := 0
        clickCastRows.Push({key: key, delay: delay + 0, last: A_TickCount})
    }
    ToolDoubleBindV18(clickCastDoubleKey,"ClickCastDoubleHandler","On")
}

RefreshClickCastControls()
{
    Form6RefreshV716()
    global clickCastRows, clickCastDoubleKey, clickCastDoubleTapMs, qCastDoubleKey, qCastDoubleTapMs
    for i, row in clickCastRows
    {
        key := (row.key = "" ? "None" : row.key)
        delay := row.delay
        GuiControl,, RClickKey%i%, % MouseKeyDisplayV616(key)
        GuiControl,, RClickDelay%i%, %delay%
    }
    GuiControl, ChooseString, QCastDoubleKey, %qCastDoubleKey%
    GuiControl,, QCastDoubleTapMs, %qCastDoubleTapMs%
    GuiControl, ChooseString, ClickCastKeyInput, %clickCastDoubleKey%
    GuiControl,, ClickCastMsInput, %clickCastDoubleTapMs%
}


QuickBuffRun(skipToggleKeyV27 := "",selectLastFOnlyV377 := false)
{
    global zSetKey, zSetDelay, zFKey, zFKey2, zDelay1, zDelay2, xDelay
    global QCastKey1, QCastKey2, QCastKey3, QCastDelay1, QCastDelay2, QCastDelay3
    global qCastLast1, qCastLast2, qCastLast3, clickCastRows
    global FKey1, FKey2, FKey3, FKey4, FKey5
    global FDelay1, FDelay2, FDelay3, FDelay4, FDelay5
    global cycleStep, nextStepTime
    global farmBuffExclusiveV621,xRunning,farmRunEpochV535,autoMonsterAttackOn
    if (farmBuffExclusiveV621)
        return false
    savedXRunningV621 := xRunning,epochV621 := farmRunEpochV535,attackWasOnV621 := autoMonsterAttackOn
    farmBuffExclusiveV621 := true,xRunning := true,completedV621 := false
    FarmAttackHoldReleaseV15()
    try
    {
    FarmSkillBaselineEnsureV621(D2GetActiveGamePidV95())
    castRows := []
    fRows := []
    clickRows := []
    Loop, 3
    {
        i := A_Index
        castRows.Push({key:QCastKey%i%, delay:QCastDelay%i%, index:i})
    }
    for _, row in clickCastRows
        clickRows.Push({key:row.key, delay:row.delay, source:row})
    Loop, 4
    {
        i := A_Index
        if (FKey%i% = "" || FKey%i% = "None")
            break
        fRows.Push({key:FKey%i%, delay:FDelay%i%, index:i})
    }
    if (QuickBuffAllowedV27(zSetKey,skipToggleKeyV27))
        if (!QuickBuffSend(zSetKey) || !QuickBuffWait(zSetDelay))
            return false
    if (QuickBuffAllowedV27(zFKey,skipToggleKeyV27))
        if (!QuickBuffCast(zFKey, zDelay1))
            return false
    if (QuickBuffAllowedV27(zFKey2,skipToggleKeyV27))
        if (!QuickBuffCast(zFKey2, zDelay2))
            return false
    if (QuickBuffAllowedV27(zSetKey,skipToggleKeyV27))
        if (!BuffSetReturnV500(zSetKey,zSetDelay))
            return false
    for _, row in castRows
    {
        if (!QuickBuffAllowedV27(row.key,skipToggleKeyV27))
            continue
        if (!QuickBuffSend(row.key))
            return false
        i := row.index
        qCastLast%i% := A_TickCount
        if (!QuickBuffWait(xDelay))
            return false
    }
    for _, row in clickRows
    {
        if (!QuickBuffAllowedV27(row.key,skipToggleKeyV27))
            continue
        if (!QuickBuffCast(row.key, xDelay))
            return false
        row.source.last := A_TickCount
    }
    lastFIndex := 0
    for _, row in fRows
    {
        if (!QuickBuffAllowedV27(row.key,skipToggleKeyV27))
            continue
        if (row.index=5 || (row.index=fRows.Length() && (selectLastFOnlyV377 || CastKeysMatch(row.key,"F10"))))
        {
            if (!QuickBuffSend(row.key) || !QuickBuffWait(xDelay))
                return false
        }
        else if (!QuickBuffCast(row.key, xDelay))
            return false
        lastFIndex := row.index
    }
    cycleStep := lastFIndex + 1
    if (cycleStep > fRows.Length())
        cycleStep := 1
    nextStepTime := 0
    if (!BuffSetFixRightV500())
        return false
    completedV621 := true
    return true
    }
    finally
    {
        farmBuffExclusiveV621 := false
        xRunning := epochV621=farmRunEpochV535 ? savedXRunningV621 : false
        if (completedV621 && attackWasOnV621 && epochV621=farmRunEpochV535)
            FarmBuffResumeVerifiedV621()
    }
}

QuickBuffHasKey(key)
{
    return key != "" && key != "None"
}

QuickBuffSend(key)
{
    global farmPortalBuffActiveDeadlineV1301
    if (farmPortalBuffActiveDeadlineV1301 && A_TickCount>=farmPortalBuffActiveDeadlineV1301)
        return false
    if (!BuffSequenceContinueV555() || !IsGameActive())
        return false
    if (!DeathlordKeyAllowedV29(key))
        return false
    return GameTargetKeyV63("{" . key . "}")
}

QuickBuffCast(key, delay)
{
    global scosEntryV162
    if (!DeathlordKeyAllowedV29(key))
        return true
    if (!QuickBuffSend(key) || !QuickBuffWait(30))
        return false
    if (!IsGameActive())
        return false
    if (!GameTargetBuffSelfClickV454())
        return false
    return QuickBuffWait(delay)
}

QuickBuffWait(ms)
{
    global farmPortalBuffActiveDeadlineV1301
    if ((farmPortalBuffActiveDeadlineV1301 && A_TickCount>=farmPortalBuffActiveDeadlineV1301)
        || !BuffSequenceContinueV555())
        return false
    started := A_TickCount
    while (A_TickCount - started < ms)
    {
        if (!BuffSequenceContinueV555() || !IsGameActive()
            || (farmPortalBuffActiveDeadlineV1301 && A_TickCount>=farmPortalBuffActiveDeadlineV1301))
            return false
        Sleep, 10
    }
    return BuffSequenceContinueV555() && IsGameActive()
        && (!farmPortalBuffActiveDeadlineV1301 || A_TickCount<farmPortalBuffActiveDeadlineV1301)
}

ResetAfterQuickBuff()
{
    global qCastLast1, qCastLast2, qCastLast3, clickCastRows
    global cycleStep, nextStepTime, FDelay1
    global pickupLastClick, v61LastPickupTick
    global lastDoubleKeyTime, lastQCastDoubleKeyTime, lastClickCastTap
    now := A_TickCount
    qCastLast1 := now
    qCastLast2 := now
    qCastLast3 := now
    for _, row in clickCastRows
        row.last := now
    cycleStep := 1
    nextStepTime := now + FDelay1
    pickupLastClick := now
    v61LastPickupTick := now
    lastDoubleKeyTime := 0
    lastQCastDoubleKeyTime := 0
    lastClickCastTap := 0
}

Master456Handler:
return

Master456StateSaveV121(profile)
{
    global ConfigFile,master456Paused,master456Saved,QCastOn,clickCastOn,cycleOn
    section := ProfileSection(profile)
    paused := master456Paused ? 1 : 0
    cast := paused && IsObject(master456Saved) ? master456Saved.cast : QCastOn
    click := paused && IsObject(master456Saved) ? master456Saved.click : clickCastOn
    cycle := paused && IsObject(master456Saved) ? master456Saved.cycle : cycleOn
    try IniWrite, %paused%, % ProfileConfigPathV364(section), %section%, Master456Paused
    try IniWrite, %cast%, % ProfileConfigPathV364(section), %section%, Master456ResumeCast
    try IniWrite, %click%, % ProfileConfigPathV364(section), %section%, Master456ResumeClick
    try IniWrite, %cycle%, % ProfileConfigPathV364(section), %section%, Master456ResumeCycle
}

Master456StateLoadV121(profile)
{
    global master456Paused,master456Saved
    master456Paused := false,master456Saved := false
    Cycle6GuiSyncV525()
}

SaveMaster456Key()
{
    global ConfigFile, master456Key
    key := (master456Key = "" ? "None" : master456Key)
    try IniWrite, %key%, %ConfigFile%, Master456, Key
}

