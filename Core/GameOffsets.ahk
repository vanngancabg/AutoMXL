; ==============================================================================
; MODULE: GAME OFFSETS
; Mục đích: Lưu trữ toàn bộ địa chỉ tĩnh (Static Pointers) và độ lệch (Offsets)
; Tất cả module khác sẽ gọi thông qua Object "Offset" thay vì gõ cứng số Hex.
; ==============================================================================

global Offset := {}

; ------------------------------------------------------------------------------
; 1. Địa chỉ gốc của các thư viện (Base Pointers)
; ------------------------------------------------------------------------------
Offset.D2Client := {}
Offset.D2Client.PlayerUnit := 0x11BBFC ; Con trỏ gốc tới nhân vật chính

Offset.D2Net := {}
Offset.D2Net.SendPacket := 0x7650      ; Hàm gửi tín hiệu mạng (Packet Injection)[cite: 1]

; ------------------------------------------------------------------------------
; 2. Cấu trúc Unit (Dùng chung cho Player, Quái vật, Vật phẩm trên đất)
; ------------------------------------------------------------------------------
Offset.Unit := {}
Offset.Unit.Type       := 0x00 ; 0 = Player, 1 = Monster, 4 = Item[cite: 1]
Offset.Unit.ClassID    := 0x04 ; Mã ID của đối tượng (VD: 1229 là bình máu)[cite: 1]
Offset.Unit.UID        := 0x0C ; Mã định danh độc nhất (Unique ID)[cite: 1]
Offset.Unit.Mode       := 0x10 ; Trạng thái (VD: 0 hoặc 17 là chết)[cite: 1]
Offset.Unit.ItemData   := 0x14 ; Trỏ tới cấu trúc ItemData (nếu là vật phẩm)[cite: 1]
Offset.Unit.Path       := 0x2C ; Trỏ tới tọa độ / Room[cite: 1]
Offset.Unit.Stats      := 0x5C ; Trỏ tới cây chỉ số (Máu, Mana...)[cite: 1]
Offset.Unit.Inventory  := 0x60 ; Trỏ tới hòm đồ (nếu là Player)[cite: 1]
Offset.Unit.Next1      := 0xE4 ; Node liên kết tiếp theo (Inventory chain)[cite: 1]
Offset.Unit.Next2      := 0xE8 ; Node liên kết tiếp theo (Room chain)[cite: 1]

; ------------------------------------------------------------------------------
; 3. Cấu trúc ItemData (Chi tiết của một vật phẩm)
; ------------------------------------------------------------------------------
Offset.ItemData := {}
Offset.ItemData.Quality   := 0x00 ; 2 = Magic, 5 = Set, 7 = Unique[cite: 1]
Offset.ItemData.FileIndex := 0x28 ; Mã dòng Unique (để phân loại đồ xịn)[cite: 1]
Offset.ItemData.Loc45     := 0x45 ; Vị trí: 0 = Hòm, 255 = Belt, 3 = Cube[cite: 1]
Offset.ItemData.Owner     := 0x5C ; Trỏ về ID của người/rương sở hữu món đồ[cite: 1]

; ------------------------------------------------------------------------------
; 4. Cấu trúc Tọa độ & Không gian (Path & Room)
; ------------------------------------------------------------------------------
Offset.Path := {}
Offset.Path.DynamicX := 0x02 ; Tọa độ X đang di chuyển (của Player/Quái)[cite: 1]
Offset.Path.DynamicY := 0x06 ; Tọa độ Y đang di chuyển (của Player/Quái)[cite: 1]
Offset.Path.StaticX  := 0x0C ; Tọa độ X tĩnh (của đồ rơi dưới đất)[cite: 1]
Offset.Path.StaticY  := 0x10 ; Tọa độ Y tĩnh (của đồ rơi dưới đất)[cite: 1]
Offset.Path.Room     := 0x1C ; Trỏ tới thông tin phòng (Room) hiện tại[cite: 1]
