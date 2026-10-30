; ==============================================================================
; MODULE: WEB SYNC (GSF COMMUNITY)
; ==============================================================================
global Sync_URL := "https://script.google.com/macros/s/AKfycbwFzJJvzwKe9W7FYnGKBajeqZeZXCcFP2qoB-pzhTf4bXjIKchQLGFyTLamhdSpjT0w/exec"

WebSync_PushData(amountTG, itemName) {
    try {
        http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        http.Open("POST", Sync_URL, true)
        http.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
        
        ; Sử dụng đơn vị tiền tệ TG chuẩn
        payload := "currency=TG&amount=" . amountTG . "&item=" . itemName
        http.Send(payload)
    } catch e {
        ; Silent fail chống treo tool
    }
}
