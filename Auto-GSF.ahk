; ==============================================================================
; AUTO-GSF V38 - BẢN CHIA NHÓM CHỨC NĂNG (ĐÃ TỐI ƯU & CHỐNG XUNG ĐỘT TOÀN DIỆN)
; ==============================================================================

; 1. Biến cờ đầu file & cấu hình file Log
#Include %A_ScriptDir%\lib\01_globals.ahk

; 2. Khởi tạo Admin, biến toàn cục, Timer & Auto-Execute
#Include %A_ScriptDir%\lib\02_startup.ahk

; 3. Cửa sổ ngầm, QCast, Dãy F, Buff Z/X & Bảng Info xanh
#Include %A_ScriptDir%\lib\03_buff_cast_info.ahk

; 4. Giao diện 4 Tab (ShowConfig), Lưu cấu hình & Quản lý Profile
#Include %A_ScriptDir%\lib\04_gui_profile.ahk

; 5. Tự động bơm HP/Mana (Belt, Rương, Cube) & Đọc máu/mana
#Include %A_ScriptDir%\lib\05_heal_pot_cube.ahk

; 6. Nhặt đồ, Cảnh báo đồ hiếm, Chuyển Cube & Đọc RAM cơ bản
#Include %A_ScriptDir%\lib\06_pickup_core_memory.ahk

; 7. Auto Buff Delay, Load/Save INI, Nạp Belt/Cube, Ghi tọa độ & QuickBuff
#Include %A_ScriptDir%\lib\07_config_belt_log_quickbuff.ahk

; 8. Tự đánh quái, Quét Boss, Bán kính đánh & PET loại trừ
#Include %A_ScriptDir%\lib\08_combat_attack_monster.ahk

; 9. Di chuyển lộ trình, F-ON nạp map, Thoát kẹt & Buff trạng thái
#Include %A_ScriptDir%\lib\09_route_move_stuck.ahk

; 10. Map SCOS, Tạo phòng mới, Đăng nhập lại GĐ4 & Tạo/Sửa map
#Include %A_ScriptDir%\lib\10_map_scos_recovery_room.ahk

; 11. GET Item, Quy trình SIG, Về thành & Các map VeLab/FAUT/CYC/UBU/TRAN/VIZ
#Include %A_ScriptDir%\lib\11_sig_town_farmlab.ahk

; 12. Hướng dẫn, Soạn thảo lọc đồ Tab 4, Lịch sử phòng & Map 130-139
#Include %A_ScriptDir%\lib\12_item_filter_editor.ahk

; 13. Logic chuyên biệt cho map CAIN, HOP, BO & Tìm Boss
#Include %A_ScriptDir%\lib\13_cain_hop_bo_boss.ahk

; 14. Watchdog chống đứng, Form 6, Sắp Rương/Kho, Chu kỳ Tâm & Log tiếng Việt
#Include %A_ScriptDir%\lib\14_watchdog_flow_vnlog.ahk

