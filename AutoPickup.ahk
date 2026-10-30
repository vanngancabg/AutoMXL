; ======================================================================
========
; MODULE: AUTO PICKUP
; Mục đích: Quét bộ nhớ để tìm vật phẩm rơi dưới đất và tự động nhặt.
; ======================================================================
========
global AutoPickup_Active := false
global AutoPickup_Radius := 15 ; Bán kính quét đồ
global AutoPickup_Delay := 200 ; Độ trễ giữa các lần nhặt (tránh spam click)
global AutoPickup_LastTick := 0
; Danh sách ClassID muốn nhặt (Ví dụ: 1204 là Cube, 1734 là một loại ngọc...)
; Trong thực tế, bạn sẽ load danh sách này từ file Item-Nhat.txt
global Pickup_Filter := {1204: true, 1734: true, 1735: true}
; ------------------------------------------------------------------------------
; Điều khiển Module
; ------------------------------------------------------------------------------
AutoPickup_Start() {
AutoPickup_Active := true
SetTimer, AutoPickup_Loop, 100
}
AutoPickup_Stop() {
AutoPickup_Active := false
SetTimer, AutoPickup_Loop, Off
}
; ------------------------------------------------------------------------------
; Vòng lặp chính quét vật phẩm
; ------------------------------------------------------------------------------
AutoPickup_Loop:

if (!AutoPickup_Active || A_TickCount - AutoPickup_LastTick &lt; AutoPickup_Delay)
return
pid := Engine_GetGamePID()
if (!pid)
return
hProcess := Engine_OpenProcess(pid)
if (!hProcess)
return
baseAddress := Engine_GetModuleBase(pid, &quot;D2Client.dll&quot;)
playerBase := Engine_ReadU32(hProcess, baseAddress + Offset.D2Client.PlayerUnit)
if (!playerBase) {
Engine_CloseProcess(hProcess)
return
}
; Lấy tọa độ nhân vật để tính khoảng cách
playerPos := Player.GetPosition(hProcess, playerBase)
; Đọc thông tin Room của nhân vật để duyệt danh sách Unit
path := Engine_ReadU32(hProcess, playerBase + Offset.Unit.Path)
room := path ? Engine_ReadU32(hProcess, path + Offset.Path.Room) : 0
if (room) {
; Lấy Unit đầu tiên trong danh sách của Room
pUnit := Engine_ReadU32(hProcess, room + 0x74)
Loop, 1024 ; Giới hạn vòng lặp chống kẹt (Failsafe)
{
if (!pUnit)
break
type := Engine_ReadU32(hProcess, pUnit + Offset.Unit.Type)
; Nếu là vật phẩm (Type = 4)
if (type == 4) {
classID := Engine_ReadU32(hProcess, pUnit + Offset.Unit.ClassID)
unitID := Engine_ReadU32(hProcess, pUnit + Offset.Unit.UID)
; Kiểm tra xem đồ này có trong bộ lọc không

if (Pickup_Filter.HasKey(classID)) {
itemPath := Engine_ReadU32(hProcess, pUnit + Offset.Unit.Path)
itemX := Engine_ReadU32(hProcess, itemPath + Offset.Path.StaticX)
itemY := Engine_ReadU32(hProcess, itemPath + Offset.Path.StaticY)
; Tính khoảng cách Manhattan đơn giản
distX := Abs(itemX - playerPos.x)
distY := Abs(itemY - playerPos.y)
dist := distX + distY
if (dist &lt;= AutoPickup_Radius) {
; Phát lệnh click hoặc gửi packet nhặt đồ ở đây
; Để an toàn trên AHK thuần, ta có thể giả lập click chuột
; hoặc thiết kế một hàm tiêm packet an toàn hơn ở tầng Core.
; Ghi log test:
; FileAppend, Nhặt item ID: %classID% tại %itemX%, %itemY% `n,
log_pickup.txt
AutoPickup_LastTick := A_TickCount
break ; Nhặt xong 1 món thì thoát vòng lặp, chờ nhịp sau
}
}
}
; Chuyển sang Unit tiếp theo trong danh sách liên kết
pUnit := Engine_ReadU32(hProcess, pUnit + Offset.Unit.Next2)
}
}
Engine_CloseProcess(hProcess)
return
