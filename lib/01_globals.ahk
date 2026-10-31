; ==============================================================================
; FILE: 01_globals.ahk (Dòng 1 -> 50 trong Gốc.ahk)
; CHỨC NĂNG: Biến cờ đầu file & cấu hình file Log
; ==============================================================================
#InstallKeybdHook
#InstallMouseHook
mapTestModeV656 := false
pickupContextModeV765 := "FARM"
pickupSigListOnlyV1321 := false
sigSessionActiveV1321 := false
sigFailedItemsV765 := {}
 
manualLogFilesV98 := {}
manualLogFilesV98["Auto-GSF-Buff-HP-Mana.txt"] := false
manualLogFilesV98["Auto-GSF-Click-Phai-Packet.txt"] := false
manualLogFilesV98["Auto-GSF-Cong-Len-Map.log"] := true
manualLogFilesV98["Auto-GSF-Cube.log"] := false
manualLogFilesV98["Auto-GSF-Debug.log"] := false
manualLogFilesV98["Auto-GSF-Nhan-Vat-DLL.txt"] := false
manualLogFilesV98["Auto-GSF-Nhat-Ruong.txt"] := true
manualLogFilesV98["UniqueItems-GET.txt"] := true
manualLogFilesV98["Auto-GSF-Quai-Boss.txt"] := true
manualLogFilesV98["Auto-GSF-Ruong-Belt.txt"] := false
manualLogFilesV98["Auto-GSF-Ruong-Cube.txt"] := true
manualLogFilesV98["Auto-GSF-Test-Phong.log"] := true
manualLogFilesV98["Auto-GSF-Map-Full.log"] := true
manualLogFilesV98["Auto-GSF-Tu-Danh.txt"] := true
roomMapLastButtonV22 := ""
autoMapTrackingV10 := true
coordTrackingEnabledV409 := true
cainPausedV10 := false
farmUserPausedV2026 := false
farmPauseTickV2026 := 0
coordPinnedYellowV136 := 0
coordYellowRowV350 := 0
fonInfoOnV385 := false
farmElapsedStartedAtV1350 := ""
farmElapsedSavedSecV1350 := 0
coordMapReadyV381 := false
coordMapStateV381 := false
coordMapAcceptedV381 := false
coordMapReloadV381 := false
coordMapKeepYellowV381 := false
coordMapSerialV381 := 0
fonFirstLoadV763 := false
stage2StartPendingV381 := false
autoLoadMapV340 := true
autoLoadMapPendingV340 := false
autoLoadMapAttemptsV340 := 0
fonStartupLoadDoneV763 := false
roomSavedReplayEnabledV116 := false
roomRecordV108 := false
roomExploreV89 := false
portalBuffV85 := false
