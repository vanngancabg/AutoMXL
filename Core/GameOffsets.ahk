; ==============================================================================
; MODULE: GAME OFFSETS
; ==============================================================================
global Offset := {}
Offset.D2Client := {}
Offset.D2Client.PlayerUnit := 0x11BBFC
Offset.D2Net := {}
Offset.D2Net.SendPacket := 0x7650
Offset.Unit := {}
Offset.Unit.Type       := 0x00
Offset.Unit.ClassID    := 0x04
Offset.Unit.UID        := 0x0C
Offset.Unit.Mode       := 0x10
Offset.Unit.ItemData   := 0x14
Offset.Unit.Path       := 0x2C
Offset.Unit.Stats      := 0x5C
Offset.Unit.Inventory  := 0x60
Offset.Unit.Next1      := 0xE4
Offset.Unit.Next2      := 0xE8
Offset.ItemData := {}
Offset.ItemData.Quality   := 0x00
Offset.ItemData.FileIndex := 0x28
Offset.ItemData.Loc45     := 0x45
Offset.ItemData.Owner     := 0x5C
Offset.Path := {}
Offset.Path.DynamicX := 0x02
Offset.Path.DynamicY := 0x06
Offset.Path.StaticX  := 0x0C
Offset.Path.StaticY  := 0x10
Offset.Path.Room     := 0x1C
