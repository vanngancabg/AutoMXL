; ==============================================================================
; FILE: 05_heal_pot_cube.ahk (Dòng 5040 -> 5817 trong Gốc.ahk)
; CHỨC NĂNG: Tự động bơm HP/Mana (Belt, Rương, Cube) & Đọc máu/mana
; ==============================================================================
AutoPotTimer:
if (packetWatchArmedV1)
    return
if (xRunning)
{
    HealTrace("TIMER_SKIP reason=QUICK_BUFF_RUNNING", "timer")
    return
}
if (!autoPotOn && !manaOn && !invHealOn && !invManaOn && !cubeHealOn && !cubeManaOn)
{
    HealTrace("TIMER_SKIP reason=ALL_SOURCES_OFF", "timer")
    return
}
if (!IsGameActive())
{
    HealTrace("TIMER_SKIP reason=GAME_NOT_ACTIVE", "timer")
    return
}

pid := D2GetActiveGamePidV95()
if (pid)
{
    level := RoomRecordLevelV259(pid)
    if (level && FarmReviveTownLevelV295(level))
    {
        return
    }
}

if (!GameItemActionBeginV4("Heal", "heal", true))
    return
try
{
healVitals := D2ReadHealVitalsV3()
healHPEnabled := autoPotOn || invHealOn || cubeHealOn
healMPEnabled := manaOn || invManaOn || cubeManaOn
healHPWait := Max(0, potCooldown - (A_TickCount-potLastDrink), potNextDrinkAtV730-A_TickCount)
healMPWait := Max(0, manaCooldown - (A_TickCount-manaLastDrink))
healHPNeed := (healVitals.hp>=0 && healVitals.hp<=potHPThreshold)
healMPNeed := (healVitals.mana>=0 && healVitals.mana<=manaThreshold)
HealTrace("HP_GATE pid=" . healVitals.pid . " value=" . healVitals.hp
    . " threshold=" . potHPThreshold . " enabled=" . healHPEnabled
    . " need=" . healHPNeed . " cooldown_left_ms=" . healHPWait . " read=" . healVitals.reason, "hp_gate")
HealTrace("MANA_GATE pid=" . healVitals.pid . " value=" . healVitals.mana
    . " threshold=" . manaThreshold . " enabled=" . healMPEnabled
    . " need=" . healMPNeed . " cooldown_left_ms=" . healMPWait . " read=" . healVitals.reason, "mp_gate")
if (healHPEnabled && !healHPWait && healHPNeed)
{
    okHP := TryHealSources(1229, "HP")
    if (okHP)
    {
        potLastDrink := A_TickCount
        potNextDrinkAtV730 := potLastDrink+Max(1,potCooldown)
        HealTrace("HEAL_SENT kind=HP before=" . healVitals.hp . " next_try_ms=" . potCooldown)
    }
}
if (healMPEnabled && !healMPWait && healMPNeed)
{
    okMana := TryHealSources(1234, "Mana")
    if (okMana)
    {
        manaLastDrink := A_TickCount
        HealTrace("HEAL_SENT kind=Mana before=" . healVitals.mana . " next_try_ms=" . manaCooldown)
    }
}
}
finally
{
    GameItemActionEndV4("Heal")
}
return

TryHealSources(targetClass, kind)
{
    global healExhausted, cubeHealOn, cubeManaOn, invHealOn, invManaOn, autoPotOn, manaOn
    global potHPThreshold,potCooldown,potLastDrink,potNextDrinkAtV730
    static retryAt := {}, lastPid := 0
    pid := D2GetActiveGamePidV95()
    if (!pid)
        return false
    if (pid!=lastPid)
    {
        healExhausted := {HP:{Belt:false,Ruong:false,Cube:false}, Mana:{Belt:false,Ruong:false,Cube:false}}
        retryAt := {}, lastPid := pid
    }
    if (kind="HP")
    {
        if (!RegExMatch(potCooldown,"^\d+$") || potCooldown<1
            || A_TickCount-potLastDrink<potCooldown || A_TickCount<potNextDrinkAtV730)
            return false
        currentHPV730 := D2ReadHealVitalsV3()
        if (currentHPV730.pid!=pid || currentHPV730.hp<0 || currentHPV730.hp>potHPThreshold)
            return false
    }
    beltOn := (kind="HP") ? autoPotOn : manaOn
    ruongOn := (kind="HP") ? invHealOn : invManaOn
    cubeOn := (kind="HP") ? cubeHealOn : cubeManaOn
    for _, source in ["Belt", "Ruong", "Cube"]
    {
        enabled := (source="Belt") ? beltOn : ((source="Ruong") ? ruongOn : cubeOn)
        cacheKey := kind . "_" . source
        if (!enabled)
        {
            HealTrace("SOURCE_SKIP kind=" . kind . " source=" . source . " reason=OFF", cacheKey)
            continue
        }
        if (healExhausted[kind][source] && retryAt.HasKey(cacheKey) && A_TickCount<retryAt[cacheKey])
        {
            HealTrace("SOURCE_SKIP kind=" . kind . " source=" . source . " reason=EMPTY_BACKOFF"
                . " retry_in_ms=" . (retryAt[cacheKey]-A_TickCount), cacheKey)
            continue
        }
        healExhausted[kind][source] := false
        if (source="Belt")
            result := V25UseBeltClassKey(targetClass)
        else if (source="Ruong")
            result := D2TryInventoryPotionClassV17(targetClass)
        else
            result := D2TryCubePotionClassV17(targetClass)
        HealTrace("SOURCE_RESULT kind=" . kind . " source=" . source . " result=" . result
            . " meaning=" . (result=1 ? "SENT" : (result=0 ? "EMPTY" : "READ_OR_SEND_ERROR")), cacheKey . "_result")
        if (result=1)
            return true
        if (result=0)
        {
            healExhausted[kind][source] := true
            retryAt[cacheKey] := A_TickCount+2000
        }
    }
    HealTrace("HEAL_NOT_SENT kind=" . kind . " reason=NO_AVAILABLE_SOURCE", kind . "_none")
    return false
}

V34WriteCubeProbeOnce()
{
    if (!ManualLogActiveV81())
        return
    log := A_ScriptDir . "\Cube-HP-Mana-Test.log"
    tmp := A_Temp . "\d2_cube_hpmana_v34.txt"
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
    ManualLogAppendV81("================ CUBE HP-MANA PROBE V34 " . A_Now . " ================`r`n", log, "UTF-8")
    ManualLogAppendV81("READ ONLY - CUBE DISCOVERY - NO SEND / NO CLICK / NO PACKET`r`n", log, "UTF-8")
    ManualLogAppendV81("KNOWN HP_CLASS=1229 MANA_CLASS=1234`r`n", log, "UTF-8")
    ManualLogAppendV81("PID=" . pidFound . " PLAYER=" . V92Hex(player) . " PLAYER_INV=" . V92Hex(inv) . " FIRST=" . V92Hex(first) . "`r`n", log, "UTF-8")
    ManualLogAppendV81("MUC TIEU: tim owner/inventory khac PLAYER_INV va loc/path cua HP-Mana trong Cube.`r`n`r`n", log, "UTF-8")

    queue := [first]
    seen := {}
    qi := 1
    itemN := 0, hpManaN := 0, foreignOwnerN := 0

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
            po := (A_Index - 1) * 4
            pu := D2ReadU32(h, u + po)
            if (!pu || seen.HasKey(pu))
                continue
            pt := D2ReadU32(h, pu + 0x00)
            pc := D2ReadU32(h, pu + 0x04)
            if (pt = 4 && pc >= 1 && pc <= 10000)
                queue.Push(pu)
        }

        if (typ = 4 && itemData)
        {
            Loop, 64
            {
                po := (A_Index - 1) * 4
                pu := D2ReadU32(h, itemData + po)
                if (!pu || seen.HasKey(pu))
                    continue
                pt := D2ReadU32(h, pu + 0x00)
                pc := D2ReadU32(h, pu + 0x04)
                if (pt = 4 && pc >= 1 && pc <= 10000)
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

        isHPMP := (cls = 1229 || cls = 1234)
        foreign := (owner && owner != inv)
        if (foreign)
            foreignOwnerN++

        if (isHPMP || foreign)
        {
            tag := ""
            if (cls = 1229)
                tag .= " HP_CLASS1229"
            else if (cls = 1234)
                tag .= " MANA_CLASS1234"
            if (foreign)
                tag .= " FOREIGN_OWNER_CANDIDATE"
            if (loc45 = 255)
                tag .= " BELT"

            if (isHPMP)
                hpManaN++

            ManualLogAppendV81("ITEM#" . itemN . " unit=" . V92Hex(u) . " class=" . cls . " id=" . uid . " q00=" . q00 . " loc44=" . loc44 . " loc45=" . loc45 . " owner=" . V92Hex(owner) . " playerInv=" . V92Hex(inv) . " path=" . V92Hex(path) . " xy=" . x . "," . y . tag . "`r`n", log, "UTF-8")

            if (isHPMP)
            {
                ud := ""
                Loop, 64
                {
                    off := (A_Index - 1) * 4
                    vv := D2ReadU32(h, u + off)
                    ud .= (A_Index=1 ? "" : " ") . Format("{:02X}:{:08X}", off, vv)
                }
                ManualLogAppendV81("  UNIT_DWORDS_00_FC " . ud . "`r`n", log, "UTF-8")

                bd := ""
                Loop, 256
                {
                    off := A_Index - 1
                    vv := D2ReadU8V18(h, itemData + off)
                    bd .= (A_Index=1 ? "" : " ") . Format("{:02X}:{:02X}", off, vv)
                }
                ManualLogAppendV81("  ITEMDATA_BYTES_00_FF " . bd . "`r`n", log, "UTF-8")
            }
        }
    }

    ManualLogAppendV81("`r`nSUMMARY CUBE_PROBE GRAPH_NODES=" . seen.Count() . " ITEMS=" . itemN . " HP_MANA=" . hpManaN . " FOREIGN_OWNER=" . foreignOwnerN . "`r`n", log, "UTF-8")
    ManualLogAppendV81("END CUBE HP-MANA PROBE V34`r`n", log, "UTF-8")
    DllCall("CloseHandle", "Ptr", h)
    return true
}


D2GetCurrentManaV17()
{
    vitals := D2ReadHealVitalsV3()
    return vitals.mana
}

D2DumpPlayerStatRootV21()
{
    tmp := A_Temp . "\\d2_stat_v21.txt"
    try FileDelete, %tmp%
    cmd := "tasklist /FI " . Chr(34) . "IMAGENAME eq Game.exe" . Chr(34) . " /FO CSV /NH > " . Chr(34) . tmp . Chr(34) . " 2>&1"
    RunWait, %ComSpec% /c %cmd%,, Hide
    FileRead, raw, %tmp%
    try FileDelete, %tmp%
    Loop, Parse, raw, `n, `r
    {
        line := A_LoopField
        if !RegExMatch(line, "i)^""Game\.exe"",""([0-9]+)""", m)
            continue
        pid := m1 + 0
        base := D2GetModuleBaseV35(pid, "D2Client.dll")
        if (!base)
            continue
        h := D2OpenProcess(pid)
        if (!h)
            continue
        player := D2ReadU32(h, base + 0x11BBFC)
        stats := player ? D2ReadU32(h, player + 0x5C) : 0
        root := stats ? D2ReadU32(h, stats + 0x24) : 0
        if (!root)
        {
            DllCall("CloseHandle", "Ptr", h)
            continue
        }
        txt := "STAT_ROOT_V21=" . V92Hex(root) . "`r`n"
        off := 0
        Loop, 65
        {
            v := D2ReadU32(h, root + off)
            val256 := Floor(v / 256)
            txt .= "OFF=0x" . Format("{:02X}", off) . " RAW=" . v . " DIV256=" . val256
            if (val256 = 14956)
                txt .= "  <== HP_MATCH"
            if (val256 = 7664)
                txt .= "  <== MANA_7664_MATCH"
            txt .= "`r`n"
            off += 4
        }
        DllCall("CloseHandle", "Ptr", h)
        return txt
    }
    return "STAT_ROOT_V21=FAIL`r`n"
}

D2TryInventoryPotionClassV17(targetClass)
{
    return D2TryContainerPotionClassV17(targetClass, 0)
}

D2TryCubePotionClassV17(targetClass)
{
    return D2TryContainerPotionClassV17(targetClass, 3)
}

HealScanRootsV4(h, inv)
{
    roots := [], seen := {}, errors := 0
    for _, off in [0x0C,0x10]
    {
        if (!PickupReadU32V4(h,inv+off,u))
        {
            errors++
            continue
        }
        if (u && !seen.HasKey(u))
        {
            seen[u] := true
            roots.Push(u)
        }
    }
    return {roots:roots,errors:errors}
}

HealScanCandidateV4(h, u, cls, data, inv, targetClass, source)
{
    global pickupCubeTraceUntil
    if (!pickupCubeTraceUntil || A_TickCount>pickupCubeTraceUntil)
        return
    uid := D2ReadU32(h,u+0x0C)
    loc := D2ReadU8V18(h,data+0x45)
    owner := D2ReadU32(h,data+0x5C)
    HealTrace("SCAN_ITEM source=" . source . " target_class=" . targetClass
        . " uid=" . uid . " class=" . cls . " loc=" . loc
        . " owner=" . V92Hex(owner) . " inv=" . V92Hex(inv)
        . " class_match=" . (cls=targetClass) . " owner_match=" . (owner=inv)
        , "scan_" . targetClass . "_" . source . "_" . uid)
}

HealPotionMatchV304(h,cls,itemData,targetClass)
{
    if (!itemData)
        return false
    if (targetClass=1229)
        return (cls=1228 || cls=1229) && D2ReadU8V18(h,itemData)=2
    return cls=targetClass
}

D2TryContainerPotionClassV17(targetClass, wantedLoc45)
{
    ctx := D2OpenHealContextV3()
    if (ctx.reason!="OK")
    {
        HealTrace("CONTAINER_ERROR loc=" . wantedLoc45 . " reason=" . ctx.reason, "container_error")
        return -1
    }
    h := ctx.h, player := ctx.player, inv := ctx.inv, first := ctx.first
    if (!inv)
    {
        DllCall("CloseHandle", "Ptr", h)
        return -1
    }
    scan := HealScanRootsV4(h,inv)
    queue := scan.roots
    readErrors := scan.errors
    itemCount := 0, matchCount := 0
    source := wantedLoc45=0 ? "Ruong" : "Cube"
    HealTrace("SCAN_START source=" . source . " class=" . targetClass
        . " roots=" . queue.Length() . " root_errors=" . readErrors
        . " first=" . V92Hex(D2ReadU32(h,inv+0x0C))
        . " last=" . V92Hex(first), "scan_start_" . source . targetClass)
    seen := {}
    qi := 1
    Loop, 4096
    {
        if (qi > queue.Length())
            break
        u := queue[qi]
        qi++
        if (!u || seen.HasKey(u))
            continue
        seen[u] := 1
        if (!PickupReadU32V4(h,u,typ))
        {
            readErrors++
            continue
        }
        cls := D2ReadU32(h, u + 0x04)
        uid := D2ReadU32(h, u + 0x0C)
        itemData := D2ReadU32(h, u + 0x14)
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
        if (typ=4 && itemData)
        {
            itemCount++
            if (HealPotionMatchV304(h,cls,itemData,targetClass))
                matchCount++
            HealScanCandidateV4(h,u,cls,itemData,inv,targetClass,source)
        }
        if (typ != 4 || !uid || !HealPotionMatchV304(h,cls,itemData,targetClass))
            continue
        loc45 := D2ReadU8V18(h, itemData + 0x45)
        ownerInv := D2ReadU32(h, itemData + 0x5C)
        if (loc45 != wantedLoc45 || ownerInv != inv)
            continue
        playerPath := D2ReadU32(h, player + 0x2C)
        px := playerPath ? D2ReadU16(h, playerPath + 0x02) : 0
        py := playerPath ? D2ReadU16(h, playerPath + 0x06) : 0
        if (!PickupGameActiveV2(ctx.pid))
        {
            DllCall("CloseHandle", "Ptr", h)
            return -1
        }
        HealTrace("CONTAINER_USE uid=" . uid . " class=" . cls . " quality=" . D2ReadU8V18(h,itemData) . " loc=" . wantedLoc45)
        ok := D2RemoteUseInventoryV3(h, uid, px, py)
        HealTrace("CONTAINER_SEND uid=" . uid . " class=" . cls . " loc=" . wantedLoc45 . " sent=" . ok)
        DllCall("CloseHandle", "Ptr", h)
        return ok ? 1 : -1
    }
    DllCall("CloseHandle", "Ptr", h)
    complete := qi>queue.Length() && readErrors=0
    HealTrace("SCAN_END source=" . source . " class=" . targetClass
        . " items=" . itemCount . " class_matches=" . matchCount
        . " read_errors=" . readErrors . " complete=" . complete
        . " result=" . (complete ? "EMPTY" : "READ_ERROR"), "scan_end_" . source . targetClass)
    return complete ? 0 : -1
}

V25UseBeltClassKey(targetClass)
{
    ctx := D2OpenHealContextV3()
    if (ctx.reason!="OK")
    {
        HealTrace("BELT_ERROR class=" . targetClass . " reason=" . ctx.reason, "belt_error")
        return -1
    }
    h := ctx.h, inv := ctx.inv, first := ctx.first
    if (!inv)
    {
        DllCall("CloseHandle", "Ptr", h)
        return -1
    }
    found := false, foundKey := 0, foundX := -1, foundUID := 0
    scan := HealScanRootsV4(h,inv)
    queue := scan.roots
    seen := {}, readErrors := scan.errors, itemCount := 0, matchCount := 0
    HealTrace("SCAN_START source=Belt class=" . targetClass
        . " roots=" . queue.Length() . " root_errors=" . readErrors
        . " first=" . V92Hex(D2ReadU32(h,inv+0x0C))
        . " last=" . V92Hex(first), "scan_start_Belt" . targetClass)

    while (queue.Length() && seen.Count() < 4096)
    {
        u := queue.RemoveAt(1)
        if (!u || seen.HasKey(u))
            continue
        seen[u] := 1

        if (!PickupReadU32V4(h,u,typ))
        {
            readErrors++
            continue
        }
        cls := D2ReadU32(h, u + 0x04)
        itemData := D2ReadU32(h, u + 0x14)

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

        if (typ=4 && itemData)
        {
            itemCount++
            if (HealPotionMatchV304(h,cls,itemData,targetClass))
                matchCount++
            HealScanCandidateV4(h,u,cls,itemData,inv,targetClass,"Belt")
        }
        if (typ != 4 || !HealPotionMatchV304(h,cls,itemData,targetClass))
            continue

        path := D2ReadU32(h, u + 0x2C)
        if (!path)
            continue
        loc45 := D2ReadU8V18(h, itemData + 0x45)
        ownerInv := D2ReadU32(h, itemData + 0x5C)
        x := D2ReadU32(h, path + 0x0C)
        if (loc45 = 255 && ownerInv = inv && x >= 0 && x <= 15)
        {
            found := true
            foundX := x,foundClassV304 := cls
            foundKey := Mod(x, 4) + 1
            foundUID := D2ReadU32(h,u+0x0C)
            break
        }
    }
    incomplete := !found && (queue.Length()>0 || readErrors>0)
    DllCall("CloseHandle", "Ptr", h)
    if (!found)
    {
        HealTrace("BELT_NOT_FOUND class=" . targetClass . " graph_incomplete=" . incomplete
            . " items=" . itemCount . " class_matches=" . matchCount
            . " read_errors=" . readErrors, "belt_not_found_" . targetClass)
        return incomplete ? -1 : 0
    }
    if (!foundUID || !PickupGameActiveV2(ctx.pid))
        return -1
    if (!DeathlordKeyAllowedV29(foundKey) || !GameTargetKeyV63(foundKey))
        return -1
    HealTrace("BELT_PRESS class=" . foundClassV304 . " uid=" . foundUID
        . " slot=" . foundX . " key=" . foundKey . " result=SENT")
    return 1
}


D2OpenHealContextV3()
{
    static cachedPid := 0, cachedBase := 0
        global backgroundPidV63
    pid := backgroundPidV63 ? backgroundPidV63 : D2GetActiveGamePidV95()
    if (!pid)
        return {reason:"GAME_NOT_ACTIVE",pid:0}
    if (pid!=cachedPid || !cachedBase)
    {
        cachedPid := pid
        cachedBase := D2GetModuleBaseV35(pid, "D2Client.dll")
    }
    if (!cachedBase)
        return {reason:"D2CLIENT_NOT_FOUND",pid:pid}
    h := D2OpenProcess(pid)
    if (!h)
        return {reason:"OPEN_GAME_FAILED",pid:pid,error:A_LastError}
    player := D2ReadU32(h,cachedBase+0x11BBFC)
    if (!player)
    {
        DllCall("CloseHandle", "Ptr", h)
        return {reason:"PLAYER_NOT_READY",pid:pid}
    }
    inv := D2ReadU32(h,player+0x60)
    first := inv ? D2ReadU32(h,inv+0x10) : 0
    return {reason:"OK",pid:pid,h:h,player:player,inv:inv,first:first}
}

D2ReadHealVitalsV3()
{
    ctx := D2OpenHealContextV3()
    if (ctx.reason != "OK")
        return {hp:-1,mana:-1,pid:ctx.pid,reason:ctx.reason}
    
    stats := D2ReadU32(ctx.h, ctx.player + 0x5C)
    hp := -1, mana := -1, reason := "STAT_ROOT_NOT_READY"
    
    if (stats)
    {
        hpInfo := MonsterBossProbeHPV2(ctx.h, stats)
        if (hpInfo.ok)
        {
            hp := hpInfo.hp
            reason := "OK"
        }
        
        for _, off in [0x48, 0x24]
        {
            root := D2ReadU32(ctx.h, stats + off)
            count := D2ReadU16(ctx.h, stats + off + 4)
            if (root && count > 0 && count < 512)
            {
                VarSetCapacity(ab, count * 8, 0)
                if (DllCall("ReadProcessMemory", "Ptr", ctx.h, "Ptr", root, "Ptr", &ab, "UPtr", count * 8, "UPtr*", got) && got == count * 8)
                {
                    Loop, %count%
                    {
                        at := (A_Index - 1) * 8
                        layer := NumGet(ab, at, "UShort")
                        statId := NumGet(ab, at + 2, "UShort")
                        value := NumGet(ab, at + 4, "UInt")
                        if (layer = 0 && statId = 8)
                        {
                            mana := Floor(value / 256)
                            break
                        }
                    }
                }
            }
            if (mana >= 0)
                break
        }
    }
    
    DllCall("CloseHandle", "Ptr", ctx.h)
    return {hp:hp,mana:mana,pid:ctx.pid,reason:reason}
}

HealTrace(message, throttleKey:="")
{
    global pickupCubeTraceUntil
    static lastLog := {}, session := 0
    if (!pickupCubeTraceUntil || A_TickCount>=pickupCubeTraceUntil)
        return
    if (session!=pickupCubeTraceUntil)
        lastLog := {}, session := pickupCubeTraceUntil
    if (throttleKey!="")
    {
        if (lastLog.HasKey(throttleKey) && A_TickCount-lastLog[throttleKey]<500)
            return
        lastLog[throttleKey] := A_TickCount
    }
    DebugTraceWrite("heal", message)
}

D2GetCurrentHPV1()
{
    vitals := D2ReadHealVitalsV3()
    return vitals.hp
}

D2RemoteUseInventoryV3(hProcess, unitId, playerX := 0, playerY := 0)
{
    if (RemoteThreadBusyV740(D2GetActiveGamePidV95()))
        return false
    pid := D2GetProcessIdFromHandle(hProcess)
    netBase := pid ? D2GetModuleBaseV35(pid, "D2Net.dll") : 0
    if (!netBase)
        return false
    hUse := DllCall("OpenProcess", "UInt", 0x043A, "Int", 0, "UInt", pid, "Ptr")
    if (!hUse)
        return false
    sendFn := netBase + 0x7650
    remote := DllCall("VirtualAllocEx", "Ptr", hUse, "Ptr", 0, "UPtr", 128, "UInt", 0x3000, "UInt", 0x40, "Ptr")
    if (!remote)
    {
        DllCall("CloseHandle", "Ptr", hUse)
        return false
    }
    VarSetCapacity(pkt, 13, 0)
    NumPut(0x20, pkt, 0, "UChar")
    NumPut(unitId, pkt, 1, "UInt")
    NumPut(playerX, pkt, 5, "UInt")
    NumPut(playerY, pkt, 9, "UInt")
    wrote := 0
    ok1 := DllCall("WriteProcessMemory", "Ptr", hUse, "Ptr", remote+64, "Ptr", &pkt, "UPtr", 13, "UPtrP", wrote)
    VarSetCapacity(code, 32, 0)
    o := 0
    NumPut(0x68, code, o, "UChar"), o += 1
    NumPut(remote+64, code, o, "UInt"), o += 4
    NumPut(0x6A, code, o, "UChar"), o += 1
    NumPut(0x01, code, o, "UChar"), o += 1
    NumPut(0x6A, code, o, "UChar"), o += 1
    NumPut(0x0D, code, o, "UChar"), o += 1
    NumPut(0xB8, code, o, "UChar"), o += 1
    NumPut(sendFn, code, o, "UInt"), o += 4
    NumPut(0xFF, code, o, "UChar"), o += 1
    NumPut(0xD0, code, o, "UChar"), o += 1
    NumPut(0xC3, code, o, "UChar"), o += 1
    wrote2 := 0
    ok2 := DllCall("WriteProcessMemory", "Ptr", hUse, "Ptr", remote, "Ptr", &code, "UPtr", o, "UPtrP", wrote2)
    if (!ok1 || !ok2)
    {
        DllCall("VirtualFreeEx", "Ptr", hUse, "Ptr", remote, "UPtr", 0, "UInt", 0x8000)
        DllCall("CloseHandle", "Ptr", hUse)
        return false
    }
    th := DllCall("CreateRemoteThread", "Ptr", hUse, "Ptr", 0, "UPtr", 0, "Ptr", remote, "Ptr", 0, "UInt", 0, "UIntP", tid, "Ptr")
    if (!th)
    {
        DllCall("VirtualFreeEx", "Ptr", hUse, "Ptr", remote, "UPtr", 0, "UInt", 0x8000)
        DllCall("CloseHandle", "Ptr", hUse)
        return false
    }
    waitUse := DllCall("WaitForSingleObject", "Ptr", th, "UInt", 1000)
    waitLimit := 5
    while (waitUse == 258 && IsGameActive() && waitLimit > 0)
    {
        waitUse := DllCall("WaitForSingleObject", "Ptr", th, "UInt", 1000)
        waitLimit--
    }
    RemoteThreadFinishV740(hUse,th,remote,waitUse)
    return waitUse=0
}

D2GetActiveGamePidV95()
{
    hwnd := GameTargetHwndV63()
    if (!hwnd)
        return 0
    WinGet, pid, PID, ahk_id %hwnd%
    return pid+0
}


