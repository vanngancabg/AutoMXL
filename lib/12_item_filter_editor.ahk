; ==============================================================================
; FILE: 12_item_filter_editor.ahk (Dòng 37048 -> 42191 trong Gốc.ahk)
; CHỨC NĂNG: Hướng dẫn, Soạn thảo lọc đồ Tab 4, Lịch sử phòng & Map 130-139
; ==============================================================================
GuideTextV64()
{
    text := ""
    text .= "HƯỚNG DẪN AUTO-GSF`r`n"
    text .= "Bản đi kèm: Form 5 có 6 dòng; SIG lấy cả đồ trong rương; SCOS buff tại tọa độ 2.`r`n"
    text .= "`r`n"
    text .= "1. BẮT ĐẦU VÀ LƯU CẤU HÌNH`r`n"
    text .= "- Mở game và chọn đúng nhân vật/cửa sổ cần điều khiển, sau đó mở tool.`r`n"
    text .= "- Profile: chọn bộ cấu hình muốn dùng. Ô Tên và LƯU PROFILE dùng để lưu profile; XÓA PROFILE xóa profile đang chọn.`r`n"
    text .= "- Lưu ở cuối cửa sổ: lưu các ô phím, delay, lựa chọn và danh sách đã chỉnh. Một số ô tự lưu ngay khi thay đổi; vẫn nên bấm Lưu sau khi thiết lập xong.`r`n"
    text .= "- Phím: nhập tên phím như F1, F2, Q, E... None hoặc để trống nghĩa là không dùng ở ô hỗ trợ phím tùy chọn. M3 là chuột giữa ở ô có hỗ trợ.`r`n"
    text .= "- Delay thông thường tính bằng mili giây: 1000 = 1 giây. Các ô ghi (s), giây hoặc phút dùng đúng đơn vị trên giao diện.`r`n"
    text .= "`r`n"
    text .= "2. TAB BUFF — FORM 1: BUFF SET PHỤ`r`n"
    text .= "- Chuyển set: phím đổi bộ vũ khí. Delay bên cạnh là thời gian chờ sau khi đổi set.`r`n"
    text .= "- Kill 1 / Kill 2: phím của hai skill cần dùng khi ở set phụ; mỗi dòng có delay riêng.`r`n"
    text .= "- Phím chạy set: phím gọi lượt buff set phụ. Tool đổi set, dùng các skill đã nhập rồi đổi về set chính.`r`n"
    text .= "- Kill trái: thông tin skill trái mà tool đã đọc được để hỗ trợ giữ đúng thiết lập của set.`r`n"
    text .= "`r`n"
    text .= "3. TAB BUFF — FORM 2: BUFF NHANH`r`n"
    text .= "- Phím buff: phím gọi một lượt buff nhanh theo các dòng đã cấu hình.`r`n"
    text .= "- Delay: khoảng chờ dùng trong lượt buff nhanh, tính bằng mili giây.`r`n"
    text .= "- Dòng 4 -> 5 -> 6 mô tả thứ tự dùng nhóm phím cast, nhóm cast + click và chọn skill đánh sau buff. Đây là một lượt, không phải lệnh tự chạy farm.`r`n"
    text .= "`r`n"
    text .= "4. TAB BUFF — FORM 3: KIỂM TRA BUFF`r`n"
    text .= "- Deathlord, Pinnacle, Anathema: mỗi dòng gồm ID trạng thái và phím skill tương ứng. Dấu / ngăn hai ô ID và phím.`r`n"
    text .= "- ID là ID trạng thái buff, không phải Class ID của quái hoặc vật phẩm.`r`n"
    text .= "- GET ID SKILL: hỗ trợ đọc thông tin skill trong game; kết quả hiện ở ô bên cạnh.`r`n"
    text .= "- Tool đọc trạng thái hiện tại để dùng skill còn thiếu, tránh bấm lại skill dạng bật/tắt khi trạng thái đã có.`r`n"
    text .= "- Auto Buff Delay: bấm để bật/tắt chạy buff theo khoảng thời gian của ô bên cạnh. Ô này tính bằng mili giây.`r`n"
    text .= "`r`n"
    text .= "5. TAB BUFF — FORM 4: PHÍM CAST`r`n"
    text .= "- Có 3 dòng Phím / Delay. Nhập các phím cần bấm trong nhóm cast.`r`n"
    text .= "- Nhóm này chỉ bấm phím; phần dùng skill cần click phải được đặt ở Form 5.`r`n"
    text .= "- Dòng bỏ trống hoặc None không được thực hiện. Bấm Lưu sau khi chỉnh.`r`n"
    text .= "`r`n"
    text .= "6. TAB BUFF — FORM 5: BẤM + CLICK PHẢI`r`n"
    text .= "- Có 6 dòng, mỗi dòng gồm Phím và Delay.`r`n"
    text .= "- Dùng cho skill cần chọn bằng phím rồi click phải để thi triển trong lượt buff.`r`n"
    text .= "- Hai dòng 5 và 6 được lưu/nạp cùng cơ chế với bốn dòng đầu.`r`n"
    text .= "- Khi chạy buff nhanh, các dòng hợp lệ được xử lý theo thứ tự. Việc chọn lại skill cuối lượt do luồng buff hiện có thực hiện.`r`n"
    text .= "`r`n"
    text .= "7. TAB BUFF — FORM 6: CHỌN SKILL ĐÁNH`r`n"
    text .= "- Ô trên cùng: phím chọn skill đánh.`r`n"
    text .= "- Kill đánh phải: chọn skill rồi đánh mục tiêu bằng click phải.`r`n"
    text .= "- Kill đè phải: giữ chuột phải và hướng lần lượt qua nhóm mục tiêu của lượt quét.`r`n"
    text .= "- Ô số bên cạnh Kill đè phải: số mục tiêu tối đa trong một nhóm. Chỉ chọn một trong hai chế độ.`r`n"
    text .= "- Khi hết nhóm hoặc cần nhả chuột, tool kết thúc lượt giữ rồi dùng lượt quét tiếp theo để chọn nhóm mới.`r`n"
    text .= "- Nếu bỏ trống phím skill, tool dùng lựa chọn skill cuối theo cấu hình F hiện có.`r`n"
    text .= "- Bước đánh trước buff có luồng riêng: dùng phím skill đánh rồi click phải, không chạy nguyên nhóm giữ chuột của Form 6.`r`n"
    text .= "`r`n"
    text .= "8. TAB NHẶT ĐỒ — HP VÀ MANA`r`n"
    text .= "- Buff HP Belt / Buff MP Belt: bật dùng bình trên belt theo cấu hình.`r`n"
    text .= "- Pot: chọn ô belt hoặc chế độ Auto(1-4) nếu có trong danh sách.`r`n"
    text .= "- Ngưỡng: mức HP/MP kích hoạt dùng bình. Nhóm HP có Ngưỡng 1/2 để cấu hình hai ngưỡng.`r`n"
    text .= "- Cooldown: thời gian chờ giữa các lượt dùng (mili giây). HP phải lớn hơn 0; đổi profile vẫn giữ lượt chờ HP đang còn.`r`n"
    text .= "- Buff HP Rương / HP Cube / MP Rương / MP Cube: bật các nguồn bình tương ứng.`r`n"
    text .= "- Phím 16HP Rương -> Belt: chuyển nhóm bình HP từ rương nhân vật lên belt.`r`n"
    text .= "- Phím 8HP + 8MP -> Belt: nạp hỗn hợp bình theo nhóm đã ghi trên giao diện.`r`n"
    text .= "- Phím Rương -> Cube và hai ô Delay: cấu hình chuyển vật phẩm từ rương nhân vật sang Cube và thời gian chờ nhặt/chuyển.`r`n"
    text .= "- Sắp Rương: chạy chức năng sắp đồ trong rương nhân vật.`r`n"
    text .= "- Chuyển Khố: chuyển theo chức năng kho khi đọc được kho gần nhân vật; không yêu cầu đứng riêng ở thành 109.`r`n"
    text .= "`r`n"
    text .= "9. TAB NHẶT ĐỒ — BẬT NHẶT VÀ CÁC NHÓM`r`n"
    text .= "- Nhặt: công tắc nhặt tự động. Ô phím bên cạnh dùng để bật/tắt nhặt.`r`n"
    text .= "- Bán kính: phạm vi xét đồ để nhặt quanh vùng đang được luồng nhặt sử dụng.`r`n"
    text .= "- BK teleport khi nhặt lỗi: khoảng cách dùng khi teleport tới hoặc qua vật phẩm sau khi nhặt thất bại; mặc định 4 ô, chỉnh từ 1 đến 100.`r`n"
    text .= "- Nhặt thẳng vào Cube: bật cách xử lý đưa đồ vào Cube theo cơ chế nhặt của tool.`r`n"
    text .= "- Ẩn/hiện DS nhặt: điều khiển hiển thị danh sách/cảnh báo nhặt.`r`n"
    text .= "- Nhặt vào rương / Nhặt Set Cube / Nhặt Unique Cube: mỗi nhóm có ô phím riêng và nút Nhặt để gọi trực tiếp.`r`n"
    text .= "- GET item: phím gọi chức năng đọc/thêm vật phẩm theo cơ chế GET. Danh sách cụ thể được quản lý ở tab ITEM NHẶT.`r`n"
    text .= "`r`n"
    text .= "10. SIG — ĐỒ DƯỚI ĐẤT VÀ TRONG RƯƠNG`r`n"
    text .= "- Bấm Sig hoặc phím Sig để xử lý Set và các loại Unique đã chọn.`r`n"
    text .= "- TU / SU / SSU / SSSU: chỉ loại được tích chọn mới được dùng cho công thức Unique tương ứng. Set có lượt xử lý riêng.`r`n"
    text .= "- Bản này lấy nguyên liệu hợp lệ từ cả dưới đất và rương nhân vật. Rương nhân vật là túi mang theo, không phải đồ đang nằm trong khố.`r`n"
    text .= "- Mỗi lượt ghép đều quét lại cả hai nguồn; không chỉ kiểm tra rương ở lần đầu.`r`n"
    text .= "- Đồ trong danh sách không SIG, đồ được đánh dấu giữ và đồ đang chờ cất kho được kiểm tra trước khi đưa vào công thức.`r`n"
    text .= "- Chuẩn bị Cube và các tem/nguyên liệu đúng loại trong rương. Tool kiểm tra vị trí đồ, đưa nguyên liệu vào Cube, ghép, xử lý mảnh và trả vật phẩm dùng lại.`r`n"
    text .= "- Set hoặc SU còn ít món vẫn đi qua nhánh công thức tương ứng; không mặc định chờ đủ 5 mới xử lý.`r`n"
    text .= "- Ghép xong, SIG đóng Cube rồi gọi nhặt thật và kiểm tra hoàn tất.`r`n"
    text .= "- Khi SIG đang chạy, nút đổi thành Hủy; bấm Hủy để yêu cầu dừng lượt đang làm.`r`n"
    text .= "- Khi có lỗi item trên chuột/Cube, giữ nguyên hiện trạng để đọc thông báo hoặc xuất log kiểm tra.`r`n"
    text .= "`r`n"
    text .= "11. TAB FARM — CÁC Ô TỰ ĐÁNH`r`n"
    text .= "- BK đánh: bán kính tìm quái của luồng farm chính.`r`n"
    text .= "- Mở Cổng: phím mở cổng; ô sau dấu / là số tọa độ giữa các lần mở cổng theo lộ trình.`r`n"
    text .= "- Cast(tele): phím teleport; ô sau dấu / là khoảng thời gian tính bằng giây.`r`n"
    text .= "- Bước di chuyển: độ dài bước dùng khi tính điểm di chuyển.`r`n"
    text .= "- Cho phép xa đích: khoảng cho phép lệch/đi xa điểm đích trong xử lý đường đi.`r`n"
    text .= "- Thời gian xét kẹt(s): thời gian quan sát không tiến triển trước khi chuyển sang xử lý kẹt.`r`n"
    text .= "- Đi tối thiểu: ngưỡng di chuyển tối thiểu trong xử lý có dùng tùy chọn này.`r`n"
    text .= "- PET Loại Trừ: danh sách Class ID cần bỏ qua khi chọn mục tiêu. Bỏ Qua và Khóa(s) đặt thời gian xét bỏ qua/khóa quái hoặc vùng kẹt theo luồng hiện có.`r`n"
    text .= "- BK Lock: bán kính dùng chung khi xét kẹt quái và xác định đã đến gần vật phẩm để nhặt; 0 tự lấy BK đánh / 2.`r`n"
    text .= "- Boss Ưu Tiên: danh sách boss để luồng farm chính xét ưu tiên. Bước đánh trước buff không có ưu tiên boss riêng.`r`n"
    text .= "`r`n"
    text .= "12. VIEW ID, VIEW POS VÀ TIP`r`n"
    text .= "- View ID: bật bảng thông tin farm, trạng thái đánh/nhặt, danh sách mục tiêu và thông tin vật phẩm.`r`n"
    text .= "- Item quét: số item hợp lệ tìm thấy trong lượt quét nhặt của luồng farm; không phải tổng số item trong rương hay tổng số đã nhặt cả buổi.`r`n"
    text .= "- Khóa BK nhặt: bán kính của vùng nhặt đang khóa; 0 khi chưa có vùng khóa.`r`n"
    text .= "- View Pos: xem map, tọa độ, phòng và thông tin vị trí đọc được từ game.`r`n"
    text .= "- Tip: bật/tắt thông báo ngắn. Một số phần hiển thị nhường thao tác khi bạn giữ chuột hoặc đang thao tác trên tool.`r`n"
    text .= "`r`n"
    text .= "13. ĐÁNH TRƯỚC KHI BUFF`r`n"
    text .= "- Lấy vị trí vừa lên làm tâm cố định; phạm vi chọn quái là BK đánh / 2.`r`n"
    text .= "- Chọn quái hợp lệ trong vùng này; không có ngưỡng 5 đơn vị để phân biệt đứng đánh/đuổi như bản cũ.`r`n"
    text .= "- Quái chạy ra ngoài vùng sẽ không được đuổi tiếp. Tâm vùng không chạy theo nhân vật.`r`n"
    text .= "- Khi không còn quái hợp lệ trong vùng, nhân vật quay về điểm buff rồi mới bắt đầu buff.`r`n"
    text .= "- Riêng SCOS map 270: điểm buff là tọa độ 2 trong lộ trình. Tool đánh và đi vào tọa độ 2 trước; không quay về tọa độ 1 sát ranh map 241/270 để buff.`r`n"
    text .= "- SCOS thiếu tọa độ 2 hợp lệ thì chờ, không tự buff ở ranh giới.`r`n"
    text .= "`r`n"
    text .= "14. MAP, LỘ TRÌNH VÀ GHI TỌA ĐỘ`r`n"
    text .= "- MAP SCOS là tên khung chọn map/lộ trình. Danh sách dùng để chọn map cần thao tác.`r`n"
    text .= "- THÊM MAP / XÓA MAP: thêm hoặc xóa map được chọn trong danh sách.`r`n"
    text .= "- Tạo / Sửa: gọi chức năng tạo hoặc ghi sửa lộ trình/phòng theo chế độ ghi hiện có.`r`n"
    text .= "- KC: khoảng cách dùng khi ghi tọa độ.`r`n"
    text .= "- Danh sách tọa độ: chọn dòng muốn thao tác; dòng vàng biểu thị điểm đang được theo dõi/chọn theo trạng thái tool.`r`n"
    text .= "- GO: đi tới tọa độ chọn. Prev / Next: đi tới điểm trước/sau.`r`n"
    text .= "- STOP cạnh GO: dừng luồng điều khiển đang chạy. GO/Prev/Next là thao tác đi thủ công và đưa farm về trạng thái dừng để nhận lệnh mới.`r`n"
    text .= "- F-ON: bật/tắt theo dõi vị trí/map theo cơ chế hiện có.`r`n"
    text .= "- ADD: thêm tọa độ sau dòng vàng. UPDATE: gọi chế độ cập nhật/chèn theo nút hiện tại. Hai mũi tên: đổi thứ tự dòng. XÓA: xóa dòng. Load: nạp map thủ công.`r`n"
    text .= "- Ghi Tọa Độ ở cuối cửa sổ: bật/tắt chức năng ghi tuyến; bấm lại khi ghi xong.`r`n"
    text .= "- Run test: chạy thử giai đoạn 2 với tuyến đã chuẩn bị; đây là chế độ test, không phải nút khởi động vòng farm đầy đủ.`r`n"
    text .= "- Mode trong cụm nút farm: đổi vùng map thường/test; chế độ test dùng thư mục Map\Test.`r`n"
    text .= "`r`n"
    text .= "15. CÁC NÚT FARM VÀ TÙY CHỌN ĐI KÈM`r`n"
    text .= "- SCOS, FAUT, CYC, UBU, CAIN, TRAN, VIZ, BO: chọn quy trình farm mang tên tương ứng. Các map cần có tuyến và điều kiện vào map phù hợp.`r`n"
    text .= "- 130 / 133 / 136 / 139: gọi nhóm farm theo cấp cuộn tương ứng. 3000: gọi quy trình 3000.`r`n"
    text .= "- VeLab6 đến VeLab10: gọi quy trình về LAB tương ứng theo chức năng hiện có.`r`n"
    text .= "- WEA: hiện chưa được gán chức năng; bấm sẽ hiện thông báo.`r`n"
    text .= "- Nút farm đang chạy hiện Stop; bấm lại để dừng. Bấm Start sau đó để bắt đầu lượt mới.`r`n"
    text .= "- SIG: bật bước SIG trong quy trình vào map khi quy trình đó sử dụng tùy chọn này.`r`n"
    text .= "- Cất Item: bật bước cất tiền/vật phẩm phù hợp trong quy trình có hỗ trợ.`r`n"
    text .= "- HOP: đứng trong thành có thủ khố đã tải, nhập số thành phẩm 1-9999; tự quăng/nhặt Cube trống, đến gần thủ khố ghép theo Rune.txt, về điểm thả nhặt nhanh đúng đồ đã rơi. Không cần danh sách tọa độ. Bấm lại để hủy.`r`n"
    text .= "`r`n"
    text .= "16. KHU VỰC FARM VÀ PHỤC HỒI GAME`r`n"
    text .= "- Trong thành / Ngoài thành: ID map dùng cho kiểm tra khu vực. GET đọc ID map tại vị trí hiện tại vào ô tương ứng.`r`n"
    text .= "- Chạy Map liên tục: điều khiển việc nối lượt farm tiếp sau khi tạo phòng mới. Bấm Lưu sau khi cấu hình nếu cần lưu các ô khác cùng lúc.`r`n"
    text .= "- Đứng ... phút Farm: khoảng thời gian không thấy di chuyển/đánh trước khi gọi phục hồi trong lúc farm đang chạy.`r`n"
    text .= "- Chỉ di chuyển/đánh được xác nhận mới làm mới thời gian hoạt động; không đọc được nhân vật vẫn được tính là chưa thấy hoạt động.`r`n"
    text .= "- Game / nút ... ở tab ITEM NHẶT: chọn đường dẫn Game.exe dùng để mở lại.`r`n"
    text .= "- ID / Pass: thông tin đăng nhập dùng trong phục hồi. Ô Pass được che trên giao diện; mật khẩu lưu được bảo vệ theo tài khoản Windows.`r`n"
    text .= "- Vào GĐ4: tích chọn là chạy ngay luồng mở lại/đăng nhập phục hồi, không cần bấm Start.`r`n"
    text .= "- Khi phục hồi, tool ngắt tác vụ của phiên game cũ và giữ yêu cầu farm để tiếp tục. Quá 3 phút sẽ thử phục hồi lại thay vì tự hủy vì hết thời gian.`r`n"
    text .= "`r`n"
    text .= "17. TAB ITEM NHẶT — CÁC DANH SÁCH`r`n"
    text .= "- Cột trái: danh mục có sẵn, gồm tên từng Charm và Relic; mở tool là có. Danh mục được dùng cho nhặt mặc định, mục Không Nhặt chặn trước.`r`n"
    text .= "- Ô phải là văn bản luật nhặt. Giữ các tiêu đề để phân biệt từng mục; bấm Lưu sau khi sửa.`r`n"
    text .= "- Nhặt Thêm: những loại/tên vật phẩm cần nhặt thêm.`r`n"
    text .= "- Chuyển Charm Vào Cube: danh sách vật phẩm dùng luồng chuyển Cube; có thể nhập tên như Charm hoặc Relic, không cần thêm [cube] trong mục này.`r`n"
    text .= "- Chuyển Vào Kho (Cất Tiền): đồ phù hợp trong Cube hoặc dưới đất được xử lý qua túi trung gian để cất kho khi chạy bước cất tiền; luật này bỏ qua đồ đã có sẵn trong túi.`r`n"
    text .= "- Không Nhặt: mỗi loại trên một dòng, ví dụ Gem, Rune thường, Charm. Đây là danh sách loại trừ nhặt.`r`n"
    text .= "- Vật phẩm không SIG ở ô trái phía dưới: danh sách giữ khỏi công thức SIG, khác với Không Nhặt.`r`n"
    text .= "- Không Nhặt chỉ cần một khối. Bản hiện tại gộp các khối/dòng loại trừ trùng khi đọc/lưu.`r`n"
    text .= "`r`n"
    text .= "18. CÁCH VIẾT TÊN, OPTION VÀ MÀU`r`n"
    text .= "- Light Plated Boots: nhặt loại đó, không thêm điều kiện option.`r`n"
    text .= "- Light Plate [2-5]: lọc từ +2 đến +5 All Skills. Full Helm [3]: lọc +3 All Skills.`r`n"
    text .= "- Angelic [2-5] {doc}: kết hợp All Skills và option có Poison; doc/độc đều dùng được.`r`n"
    text .= "- ""Leather Gloves"" {Fire dance}: lọc loại đồ và chữ option tương ứng.`r`n"
    text .= "- [] và {} dùng như nhau. Các nhóm riêng cần cùng thỏa điều kiện; dấu | trong cùng một nhóm cho phép chọn một trong các điều kiện.`r`n"
    text .= "- Rune [red]: luật Rune có màu cảnh báo đỏ. Các màu hỗ trợ gồm red, green, blue, yellow, gold, white, orange, purple, grey, pink, tan, darkgreen, black.`r`n"
    text .= "- Set xanh [Zakarum]: luật nhặt Set, đồng thời giữ các bộ được chỉ rõ khỏi SIG theo cú pháp Set của tool.`r`n"
    text .= "- # ở đầu dòng dùng để tắt dòng/ghi chú. Tên không phân biệt hoa thường nhưng cần đúng loại tên mà game cung cấp.`r`n"
    text .= "- Luật nhặt rộng có thể vẫn nhận một món không đạt luật option hẹp. Muốn chỉ nhặt theo option thì kiểm tra và bỏ các luật nhặt rộng trùng loại.`r`n"
    text .= "`r`n"
    text .= "19. XUẤT LOG VÀ HƯỚNG DẪN`r`n"
    text .= "- Xuất Log: bấm để bắt đầu ghi chẩn đoán; bấm lần nữa để dừng và lấy gói log theo thông báo của tool.`r`n"
    text .= "- Muốn kiểm tra lỗi chui cổng, đánh, buff, nhặt hoặc SIG: bật log trước khi thực hiện lại thao tác gây lỗi rồi dừng log sau khi lỗi xảy ra.`r`n"
    text .= "- Hướng dẫn: mở cửa sổ có thanh cuộn và tạo/cập nhật Huong-dan-Auto-GSF.txt trong thư mục txt nếu thư mục cho phép ghi.`r`n"
    text .= "- Cửa sổ hướng dẫn có thể kéo rộng/cao; dùng cuộn chuột hoặc thanh cuộn để đọc tiếp.`r`n"
    text .= "`r`n"
    text .= "GHI CHÚ`r`n"
    text .= "Tài liệu mô tả cấu hình và luồng trong bản AHK đi kèm. Các thay đổi được kiểm tra trên mã nguồn; chưa được chạy xác nhận trực tiếp trong Diablo II/AutoHotkey trên Windows.`r`n"
    return text
}

UniqueKnownTierV4(tier)
{
    return tier="TU" || tier="SU" || tier="SSU" || tier="SSSU"
}


SetPickupVerifiedV4(h,cls,itemData)
{
    if (!h || !itemData || cls<0 || D2ReadU32(h,itemData)!=5)
        return false
    idx := D2ReadU32(h,itemData+0x28)
    pid := DllCall("GetProcessId","Ptr",h,"UInt")
    commonBase := pid ? D2GetModuleBaseV35(pid,"D2Common.dll") : 0
    if (!commonBase)
        return false
    sgpt := D2ReadU32(h,commonBase+0x99E1C)
    if (!sgpt)
        return false
    setTable := D2ReadU32(h,sgpt+0xC18),setCount := D2ReadU32(h,sgpt+0xC1C)
    itemTable := D2ReadU32(h,commonBase+0x9FB98),itemCount := D2ReadU32(h,commonBase+0x9FB94)
    if (!setTable || !itemTable || setCount<1 || setCount>32767 || itemCount<1 || itemCount>65535 || idx>=setCount || cls>=itemCount)
        return false
    record := setTable+idx*0x1B8
    if (D2ReadU16(h,record)!=idx)
        return false
    setCode := D2ReadU32(h,record+0x28)
    itemCode := D2ReadU32(h,itemTable+cls*0x1A8+0x80)
    return setCode!=0 && setCode=itemCode
}

UniqueLowNormalCodeV6(code)
{
    padding := (code >> 24) & 0xFF
    if (padding!=0 && padding!=0x20)
        return false
    code := code & 0xFFFFFF
    return code=0x6E6972 || code=0x756D61 || code=0x77656A
        || code=0x767161 || code=0x767163
}


PickupIsCharmV571(h,cls)
{
    static verified := {}
    if (!h || cls<0)
        return false
    pid := DllCall("GetProcessId","Ptr",h,"UInt")
    common := pid ? D2GetModuleBaseV35(pid,"D2Common.dll") : 0
    if (!common)
        return false
    moduleKey := pid . "|" . common
    if (!verified.HasKey(moduleKey))
    {
        if (!RecoveryMenuModuleV528(h,common,0x4B95C439,0xA9000))
            return false
        verified[moduleKey] := true
    }
    items := D2ReadU32(h,common+0x9FB98),count := D2ReadU32(h,common+0x9FB94)
    types := D2ReadU32(h,common+0xA0AD0),typeCount := D2ReadU32(h,common+0xA0AD4)
    if (!items || !types || count<1 || count>65535 || cls>=count || typeCount<1 || typeCount>32767)
        return false
    if (!MonsterBossProbeReadV1(h,items+cls*0x1A8+0x11E,4,itemTypes))
        return false
    pending := [NumGet(itemTypes,0,"UShort"),NumGet(itemTypes,2,"UShort")],seen := {},index := 1
    Loop, 128
    {
        if (index>pending.Length())
            break
        type := pending[index],index++
        if (type<=0 || type>=typeCount || seen.HasKey(type))
            continue
        seen[type] := true
        if (!MonsterBossProbeReadV1(h,types+type*0xE4,0x18,record))
            continue
        if (NumGet(record,0x17,"UChar"))
            return true
        pending.Push(NumGet(record,4,"UShort")),pending.Push(NumGet(record,6,"UShort"))
    }
    return false
}

ConsumablePickupGroupV7(h,cls)
{
    global consumableClassRAMV7,consumableNameJobsV7,consumableLastPidV7
    if (!IsObject(consumableClassRAMV7))
        consumableClassRAMV7 := {},consumableNameJobsV7 := {}
    ConsumableNamePollV7()
    pid := h ? DllCall("GetProcessId","Ptr",h,"UInt") : consumableLastPidV7
    if (!pid || cls<0)
        return ""
    key := pid . "|" . cls
    if (consumableClassRAMV7.HasKey(key))
        return PickupNameMatchV8(consumableClassRAMV7[key])
    if (!h || consumableNameJobsV7.HasKey(key) || consumableNameJobsV7.Count()>=4)
        return ""
    common := D2GetModuleBaseV35(pid,"D2Common.dll")
    if (!common)
        return ""
    table := D2ReadU32(h,common+0x9FB98),count := D2ReadU32(h,common+0x9FB94)
    if (!table || count<1 || count>65535 || cls>=count)
        return ""
    record := table+cls*0x1A8
    VarSetCapacity(itemHeaderV7,0xF6,0),gotV7 := 0
    if (!DllCall("ReadProcessMemory","Ptr",h,"Ptr",record,"Ptr",&itemHeaderV7,"UPtr",0xF6,"UPtr*",gotV7) || gotV7!=0xF6)
        return ""
    nameId := NumGet(itemHeaderV7,0xF4,"UShort")
    lang := D2GetModuleBaseV35(pid,"D2Lang.dll")
    if (!lang)
        return ""
    job := ConsumableNameStartV7(pid,lang+0x9450,nameId)
    if (IsObject(job))
    {
        job.key := key,job.pid := pid
        consumableNameJobsV7[key] := job,consumableLastPidV7 := pid
    }
    return ""
}

ConsumableNameStartV7(pid,fn,nameId)
{
    hp := DllCall("OpenProcess","UInt",0x043A,"Int",0,"UInt",pid,"Ptr")
    if (!hp)
        return false
    remote := DllCall("VirtualAllocEx","Ptr",hp,"Ptr",0,"UPtr",32,"UInt",0x3000,"UInt",0x40,"Ptr")
    if (!remote)
    {
        DllCall("CloseHandle","Ptr",hp)
        return false
    }
    VarSetCapacity(code,18,0)
    NumPut(0x53,code,0,"UChar")
    NumPut(0x08244C8B,code,1,"UInt")
    NumPut(0xC033,code,5,"UShort")
    NumPut(0xBB,code,7,"UChar"),NumPut(fn,code,8,"UInt")
    NumPut(0xD3FF,code,12,"UShort"),NumPut(0x5B,code,14,"UChar")
    NumPut(0xC2,code,15,"UChar"),NumPut(4,code,16,"UShort")
    wrote := 0
    if (!DllCall("WriteProcessMemory","Ptr",hp,"Ptr",remote,"Ptr",&code,"UPtr",18,"UPtr*",wrote) || wrote!=18)
    {
        DllCall("VirtualFreeEx","Ptr",hp,"Ptr",remote,"UPtr",0,"UInt",0x8000)
        DllCall("CloseHandle","Ptr",hp)
        return false
    }
    DllCall("FlushInstructionCache","Ptr",hp,"Ptr",remote,"UPtr",18)
    th := DllCall("CreateRemoteThread","Ptr",hp,"Ptr",0,"UPtr",0,"Ptr",remote,"Ptr",nameId,"UInt",0,"Ptr",0,"Ptr")
    if (!th)
    {
        DllCall("VirtualFreeEx","Ptr",hp,"Ptr",remote,"UPtr",0,"UInt",0x8000)
        DllCall("CloseHandle","Ptr",hp)
        return false
    }
    return {hp:hp,remote:remote,th:th}
}

ConsumableNamePollV7()
{
    global consumableClassRAMV7,consumableNameJobsV7
    if (!IsObject(consumableNameJobsV7) || !consumableNameJobsV7.Count())
        return
    done := []
    for key,job in consumableNameJobsV7
    {
        if (DllCall("WaitForSingleObject","Ptr",job.th,"UInt",0)!=0)
            continue
        ptr := 0,name := ""
        if (DllCall("GetExitCodeThread","Ptr",job.th,"UInt*",ptr) && ptr)
        {
            VarSetCapacity(wide,514,0),got := 0
            if (DllCall("ReadProcessMemory","Ptr",job.hp,"Ptr",ptr,"Ptr",&wide,"UPtr",512,"UPtr*",got) && got=512)
                name := StrGet(&wide,"UTF-16")
        }
        consumableClassRAMV7[key] := name
        DllCall("VirtualFreeEx","Ptr",job.hp,"Ptr",job.remote,"UPtr",0,"UInt",0x8000)
        DllCall("CloseHandle","Ptr",job.th),DllCall("CloseHandle","Ptr",job.hp)
        done.Push(key)
    }
    for _,key in done
        consumableNameJobsV7.Delete(key)
}

ConsumableNameCleanupV7()
{
    global consumableNameJobsV7
    if (!IsObject(consumableNameJobsV7))
        return
    for _,job in consumableNameJobsV7
    {
        if (DllCall("WaitForSingleObject","Ptr",job.th,"UInt",0)=0)
            DllCall("VirtualFreeEx","Ptr",job.hp,"Ptr",job.remote,"UPtr",0,"UInt",0x8000)
        DllCall("CloseHandle","Ptr",job.th),DllCall("CloseHandle","Ptr",job.hp)
    }
    consumableNameJobsV7 := {}
}

ConsumableKnownNameV7(name)
{
    name := RegExReplace(name,Chr(255) . "c.","")
    runes := "El|Eld|Tir|Nef|Eth|Ith|Tal|Ral|Ort|Thul|Amn|Sol|Shael|Dol|Hel|Io|Lum|Ko|Fal|Lem|Pul|Um|Mal|Ist|Gul|Vex|Ohm|Lo|Sur|Ber|Jah|Cham|Zod"
        . "|Ol|Elq|Tyr|Nif|Xeth|Xith|Thal|Rhal|Urt|Tuul|Ahmn|Zol|Shaen|Doj|Hem|Iu|Lux|Ka|Fel|Lew|Phul|Un|Mhal|Yst|Gur|Vez|Ohn|Loz|Zur|Bur|Iah|Yham|Xod"
        . "|Taha|Ghal|Qor|Fire|Stone|Arcane|Poison|Light|Ice"
    shrines := "Abandoned|Creepy|Eerie|Enchanted|Fascinating|Hidden|Intimidating|Magical|Ornate|Quiet|Sacred|Shimmering|Spiritual|Tainted|Trinity|Weird"
    gems := "Diamond|Amethyst|Ruby|Topaz|Bloodstone|Onyx|Amber|Turquoise|Sapphire|Emerald|Rainbow Stone|Skull"
    Loop, Parse, name, `n, `r
    {
        line := Trim(RegExReplace(A_LoopField,"\s+"," "))
        if (RegExMatch(line,"i)^(?:" . runes . ") Rune$") || RegExMatch(line,"i)^(?:Great|Enchanted|Elemental) Rune$"))
            return "RUNE"
        if (RegExMatch(line,"i)^(?:(?:Flawless|Perfect) )?(?:" . gems . ")$"))
            return "GEM"
        if (RegExMatch(line,"i)^(?:" . shrines . ") Shrine(?: \(\d+\))?$") || RegExMatch(line,"i)^Shrine(?: \(\d+\))?$"))
            return "SHRINE"
        if (RegExMatch(line,"i)^Oil of [A-Za-z ]+$"))
            return "OIL"
        if (RegExMatch(line,"i)^Arcane (?:Shard|Shards|Crystal|Cluster)$"))
            return "ARCANE"
        if (RegExMatch(line,"i)^Corrupted (?:Shard|Shards|Crystal|Cluster)$"))
            return "CORRUPTED"
        if (RegExMatch(line,"i)^(?:Sacred Essence|Heavenly Soul|Heavenly Souls|Mark of Infusion|Crate O' (?:Souls|Sacred Essence))$"))
            return "MATERIAL"
        if (RegExMatch(line,"i)\bSignet\b"))
		return "SIGNET"
    }
    return ""
}


PickupAutoGroupParseV7(line)
{
    line := PickupColorStripV14(Trim(line," `t`r`n" . Chr(0xFEFF)),ignoredColorV14)
    if (PickupShortParseV638(line,shortName,shortClass,shortQuality))
        return ""
    if (IsObject(SetNoSigParseV227(line)))
        return "SET_XANH"
    if (RegExMatch(line,"i)^ITEMDATA\s*=\s*07\s*\|\s*TIER\s*=\s*(TU|SU|SSU|SSSU)\s*$",m))
    {
        StringUpper, group, m1
        return group
    }
    if (RegExMatch(line,"i)^ITEMDATA\s*=\s*05\s*\|\s*TIER\s*=\s*(SET_XANH|SET)\s*$"))
        return "SET_XANH"
    if (RegExMatch(line,"i)^GROUP\s*=\s*(RUNE|GEM|SHRINE|OIL|ARCANE|CORRUPTED|MATERIAL|SIGNET|CHARM)\s*$",m))
    {
        StringUpper, group, m1
        return group
    }
    if (SubStr(line,1,1)="#" || line="" || InStr(line,"=") || PickupOptIsRuleV12(line))
        return ""
    StringUpper, plain, line
    if (plain="SET" || plain="SET XANH" || plain="SET_XANH")
        return "SET_XANH"
    if (RegExMatch(plain,"^(TU|SU|SSU|SSSU|UNIQUE|RUNE|GEM|SHRINE|OIL|ARCANE|CORRUPTED|MATERIAL|SIGNET|ANGELIC|CHARM)$"))
        return plain
    aliases := {"GEM THƯỜNG":"GEM_NORMAL","GEM NORMAL":"GEM_NORMAL","GEM FLAWLESS":"GEM_FLAWLESS","GEM PERFECT":"GEM_PERFECT","RUNE THƯỜNG":"RUNE_NORMAL","RUNE NORMAL":"RUNE_NORMAL","RUNE ENCHANTED":"RUNE_ENCHANTED","RUNE GREAT":"RUNE_GREAT","RUNE ELEMENTAL":"RUNE_ELEMENTAL"}
    if (aliases.HasKey(plain))
        return aliases[plain]
    patterns := PickupCatalogPatternsV9()
    normalized := PickupNameNormalizeV8(line)
    if (patterns.HasKey(normalized))
        return "FILTER:" . normalized
    return "NAME:" . normalized
}
PickupSetIsAngelicV13(h,cls,itemData,unit)
{
    global pickupAngelicSetIdsV13
    if (!IsObject(pickupAngelicSetIdsV13))
        pickupAngelicSetIdsV13 := {}
    if (!h || !itemData)
        return false
    setId := D2ReadU16(h,itemData+0x2C)
    if (setId && pickupAngelicSetIdsV13.HasKey(setId))
        return pickupAngelicSetIdsV13[setId]
    if (!unit)
        return false
    ctx := {pid:DllCall("GetProcessId","Ptr",h,"UInt"), h:h}
    name := SigSetNameV227(ctx,{unit:unit, uid:D2ReadU32(h,unit+0x0C), cls:cls, data:itemData})
    isAngelic := InStr(name,"Angelic",false) > 0
    if (setId)
        pickupAngelicSetIdsV13[setId] := isAngelic
    return isAngelic
}
PickupAutoGroupEnabledV7(group)
{
    global pickupAutoGroupsV7
    if (!IsObject(pickupAutoGroupsV7))
        UniquePickupReloadRAMV1()
    if (!IsObject(pickupAutoGroupsV7))
        return false
    if (pickupAutoGroupsV7.HasKey(group))
        return true
    for _,ancestor in PickupGroupParentChainV8(group)
        if (pickupAutoGroupsV7.HasKey(ancestor))
            return true
    return false
}

PickupGroupParentChainV8(group)
{
    if (UniqueKnownTierV4(group))
        return ["UNIQUE"]
    if (SubStr(group,1,4)="GEM_")
        return ["GEM"]
    if (SubStr(group,1,5)="RUNE_")
        return ["RUNE"]
    return []
}


PickupAutoGroupsRefreshV7()
{
    static lastStamp := ""
    file := UniquePickupFileV3()
    FileGetTime, stampTime, %file%, M
    FileGetSize, stampSize, %file%
    stamp := stampTime . "|" . stampSize
    if (stamp!=lastStamp)
    {
        UniquePickupReloadRAMV1()
        FileGetTime, stampTime, %file%, M
        FileGetSize, stampSize, %file%
        lastStamp := stampTime . "|" . stampSize
    }
}

ConsumableNamesPendingV7()
{
    global consumableNameJobsV7
    return (IsObject(consumableNameJobsV7) && consumableNameJobsV7.Count()>0) || PickupOptPendingV12()
}


PickupNameNormalizeV8(name)
{
    name := Trim(RegExReplace(RegExReplace(name,Chr(255) . "c.",""),"\s+"," "))
    StringLower, name, name
    return name
}

PickupNameMatchV8(name)
{
    global pickupAutoGroupsV7
    if (name="")
        return ""
    Loop, Parse, name, `n, `r
    {
        normalized := PickupNameNormalizeV8(A_LoopField)
        key := "NAME:" . normalized
        if (PickupAutoGroupEnabledV7(key))
            return key
    }
    patterns := PickupCatalogPatternsV9()
    plain := RegExReplace(name,Chr(255) . "c.","")
    for selector,_ in pickupAutoGroupsV7
    {
        if (SubStr(selector,1,7)!="FILTER:")
            continue
        filter := SubStr(selector,8)
        if (patterns.HasKey(filter) && RegExMatch(plain,"im)" . patterns[filter]))
            return selector
    }
    group := ConsumableKnownNameV7(name)
    if (group!="" && PickupAutoGroupEnabledV7(group))
        return group
    sub := PickupNamedSubtypeV8(name,group)
    return sub!="" && PickupAutoGroupEnabledV7(sub) ? sub : group
}

PickupNamedSubtypeV8(name,group)
{
    if (group="GEM")
    {
        Loop, Parse, name, `n, `r
        {
            line := PickupNameNormalizeV8(A_LoopField)
            if (ConsumableKnownNameV7(line)!="GEM")
                continue
            return RegExMatch(line,"^perfect ") ? "GEM_PERFECT" : (RegExMatch(line,"^flawless ") ? "GEM_FLAWLESS" : "GEM_NORMAL")
        }
    }
    if (group="RUNE")
    {
        enchanted := "Ol|Elq|Tyr|Nif|Xeth|Xith|Thal|Rhal|Urt|Tuul|Ahmn|Zol|Shaen|Doj|Hem|Iu|Lux|Ka|Fel|Lew|Phul|Un|Mhal|Yst|Gur|Vez|Ohn|Loz|Zur|Bur|Iah|Yham|Xod"
        Loop, Parse, name, `n, `r
        {
            line := PickupNameNormalizeV8(A_LoopField)
            if (ConsumableKnownNameV7(line)!="RUNE")
                continue
            if (RegExMatch(line,"i)^(?:Taha|Ghal|Qor|Great) Rune$"))
                return "RUNE_GREAT"
            if (RegExMatch(line,"i)^(?:Fire|Stone|Arcane|Poison|Light|Ice|Elemental) Rune$"))
                return "RUNE_ELEMENTAL"
            if (RegExMatch(line,"i)^(?:" . enchanted . "|Enchanted) Rune$"))
                return "RUNE_ENCHANTED"
            return "RUNE_NORMAL"
        }
    }
    return ""
}


PickupNoSigFileV490()
{
    return TxtRootPathV816("Item-Khong-Sig.txt")
}

PickupCanonicalDefaultsV491()
{
    return "Horadric Cube`r`nCharm`r`nUnique`r`nSet xanh`r`nMastercrafted`r`nRune`r`nGem`r`nShrine`r`nOil`r`nArcane`r`nCorrupted`r`nMaterial`r`nSignet`r`nCycle`r`nMystic Orb`r`nContainer`r`nRunestone`r`nEssence`r`nVessel`r`nEnchant Scroll`r`nEnchanting`r`nMystic Dye`r`nTreasure`r`nItem Design`r`nBelladonna Extract`r`nRiftstone`r`nScroll of Summoning`r`nRelic`r`nTrophy`r`nOccult Effigy`r`nEmblem`r`nQuest Item`r`nCube Reagent`r`n"
        . StrReplace(PickupCharmNamesV731(),"|","`r`n") . "`r`n"
}


PickupShortParseV638(line,ByRef name,ByRef cls,ByRef q)
{
    name := "",cls := 0,q := 0
    if (!RegExMatch(Trim(line),"i)^([^|]+)\|\s*(\d+)\s*\|\s*(0[1-9])\s*$",m))
        return false
    name := Trim(m1),cls := m2+0,q := ("0x" . m3)+0
    return name!="" && SubStr(name,1,1)!="#" && cls>0 && cls<65536 && q>=1 && q<=9
}

PickupLeftCategoryV638(line)
{
    if (PickupShortParseV638(line,label,cls,q))
        name := label
    else
        name := Trim(RegExReplace(line,"[\[{].*$","")," `t" . Chr(34))
    for _,parent in PickupCatalogParentChainV8(name)
    {
        ancestors := PickupCatalogParentChainV8(parent)
        return ancestors.Length() ? ancestors[ancestors.Length()] : parent
    }
    group := PickupAutoGroupParseV7(name)
    if (group="RUNE" || SubStr(group,1,5)="RUNE_")
        return "Rune"
    if (group="GEM" || SubStr(group,1,4)="GEM_")
        return "Gem"
    if (UniqueKnownTierV4(group) || group="UNIQUE")
        return "Unique"
    if (group="SET_XANH")
        return "Set xanh"
    for _,candidate in ["Horadric Cube","Charm","Mastercrafted","Rune","Gem","Shrine","Oil","Arcane","Corrupted","Material","Signet","Cycle","Mystic Orb","Container","Runestone","Essence","Vessel","Enchant Scroll","Enchanting","Mystic Dye","Treasure","Item Design","Belladonna Extract","Riftstone","Scroll of Summoning","Relic","Trophy","Occult Effigy","Emblem","Quest Item","Cube Reagent"]
    {
        if (PickupNameNormalizeV8(name)=PickupNameNormalizeV8(candidate))
            return candidate
        if (PickupAlertGroupMatchV14(PickupAutoGroupParseV7(candidate),0,"",false,name))
            return candidate
    }
    return "Angelic"
}


PickupNameIndexPutV638(index,name,cls,q)
{
    name := PickupNameNormalizeV8(name)
    if (name="" || cls<1 || q<1 || q>9)
        return
    identity := cls . "|" . Format("{:02X}",q)
    if (!index.HasKey(name))
        index[name] := identity
    else if (index[name]!=identity)
        index[name] := ""
}

PickupNameIndexV638()
{
    global pickupOptCacheV12,consumableClassRAMV7
    index := {},pid := D2GetActiveGamePidV95(),h := pid ? D2OpenProcess(pid) : 0
    if (!h)
        return index
    try
    {
        PickupOptPollV12()
        player := D2ReadU32(h,D2GetModuleBaseV35(pid,"D2Client.dll")+0x11BBFC)
        inv := player ? D2ReadU32(h,player+0x60) : 0
        if (inv)
        {
            ctx := {pid:pid,h:h,player:player,inv:inv,first:D2ReadU32(h,inv+0x10)}
            for uid,item in V9SnapshotAllItems(ctx)
            {
                q := D2ReadU8V18(h,item.data),key := pid . "|" . item.cls
                if (IsObject(consumableClassRAMV7) && consumableClassRAMV7.HasKey(key))
                    PickupNameIndexPutV638(index,consumableClassRAMV7[key],item.cls,q)
            }
        }
        for cacheKey,info in pickupOptCacheV12
        {
            if (!info.ok || info.pid!=pid)
                continue
            fields := StrSplit(cacheKey,"|"),unit := fields[2]+0,data := fields[4]+0
            if (D2ReadU32(h,unit)!=4 || D2ReadU32(h,unit+0x0C)!=info.uid
                || D2ReadU32(h,unit+0x14)!=data || D2ReadU32(h,data+0x14)!=fields[5]+0)
                continue
            cls := D2ReadU32(h,unit+4),q := D2ReadU8V18(h,data)
            PickupNameIndexPutV638(index,PickupGetNameV638(info.name),cls,q)
            key := pid . "|" . cls
            if (IsObject(consumableClassRAMV7) && consumableClassRAMV7.HasKey(key))
                PickupNameIndexPutV638(index,consumableClassRAMV7[key],cls,q)
        }
    }
    finally
        DllCall("CloseHandle","Ptr",h)
    return index
}

PickupUpgradeNamesV638(raw,index)
{
    result := ""
    Loop, Parse, raw, `n, `r
    {
        line := Trim(A_LoopField),group := PickupAutoGroupParseV7(line)
        key := PickupNameNormalizeV8(line)
        if (SubStr(group,1,5)="NAME:" && !PickupOptIsRuleV12(line)
            && !PickupShortParseV638(line,label,cls,q) && index.HasKey(key) && index[key]!="")
            line .= "|" . index[key]
        if (line!="")
            result .= line . "`r`n"
    }
    return PickupEditorDedupV10(result,removed)
}
PickupUniqueStringNameV766(h,pid,itemData)
{
    fileIndex := D2ReadU32(h,itemData+0x28)
    common := D2GetModuleBaseV35(pid,"D2Common.dll")
    if (!common)
        return ""
    sgpt := D2ReadU32(h,common+0x99E1C)
    if (!sgpt)
        return ""
    tablePtr := D2ReadU32(h,sgpt+0xC24)
    tableCount := D2ReadU32(h,sgpt+0xC28)
    if (!tablePtr || fileIndex>=tableCount)
        return ""
    record := tablePtr+fileIndex*0x14C
    if (D2ReadU16(h,record)!=fileIndex)
        return ""
    stringId := D2ReadU16(h,record+2)
    if (!stringId || stringId=65535)
        return ""
    lang := D2GetModuleBaseV35(pid,"D2Lang.dll")
    if (!lang)
        return ""
    job := ConsumableNameStartV7(pid,lang+0x9450,stringId)
    if (!IsObject(job))
        return ""
    started := A_TickCount
    while (DllCall("WaitForSingleObject","Ptr",job.th,"UInt",0)!=0)
    {
        if (A_TickCount-started>2000)
        {
            DllCall("CloseHandle","Ptr",job.th)
            DllCall("CloseHandle","Ptr",job.hp)
            return ""
        }
        Sleep, 20
    }
    ptr := 0,name := ""
    if (DllCall("GetExitCodeThread","Ptr",job.th,"UInt*",ptr) && ptr)
        name := PickupOptCleanTextV12(PickupOptReadWideV12(job.hp,ptr,512))
    DllCall("VirtualFreeEx","Ptr",job.hp,"Ptr",job.remote,"UPtr",0,"UInt",0x8000)
    DllCall("CloseHandle","Ptr",job.th)
    DllCall("CloseHandle","Ptr",job.hp)
    return Trim(name)
}
PickupGetNameV638(raw,statsRaw:="")
{
    raw := RegExReplace(raw,Chr(255) . "c.","")
    if (statsRaw!="")
    {
        statsRaw := RegExReplace(statsRaw,Chr(255) . "c.","")
        baseName := ""
        Loop, Parse, raw, `n, `r
            if (Trim(A_LoopField)!="")
            {
                baseName := Trim(A_LoopField)
                break
            }
        for _,line in StrSplit(statsRaw,"`n")
        {
            line := Trim(line)
            if (line="" || InStr(line,baseName) || RegExMatch(line,"^[+-]|^\d|^[A-Za-z ]+:\s"))
                continue
            if (!RegExMatch(line,"^(?:\+|-)") && !RegExMatch(line,"^\d"))
                return StrReplace(line,"|","/")
        }
    }
    Loop, Parse, raw, `n, `r
        if (Trim(A_LoopField)!="")
            return StrReplace(Trim(A_LoopField),"|","/")
    return ""
}

PickupEditorGetV638()
{
    global pickupGetTargetV638,sigBusyV147,xRunning,zRunning
    target := pickupGetTargetV638
    GuiControlGet, tab, 1:, AutoGSFMainTabs
    if (tab!=4 || (target!="PickupEditorInputV8" && target!="PickupNoSigEditorV490"))
        return false
    if (sigBusyV147 || xRunning || zRunning)
        return true
    pid := D2GetActiveGamePidV95(),base := pid ? D2GetModuleBaseV35(pid,"D2Client.dll") : 0
    h := base ? D2OpenProcess(pid) : 0
    if (!h)
        return true
    message := "GET: rê chuột lên đúng vật phẩm rồi bấm lại."
    try
    {
        MouseGetPos,,,hoverWindow
        WinGet, hoverPid, PID, ahk_id %hoverWindow%
        unit := hoverPid=pid ? D2ReadU32(h,base+0x11B834) : 0
        if (unit && D2ReadU32(h,unit)=4)
        {
            uid := D2ReadU32(h,unit+0x0C),cls := D2ReadU32(h,unit+4),data := D2ReadU32(h,unit+0x14)
            q := D2ReadU8V18(h,data),seed := D2ReadU32(h,data+0x14),started := A_TickCount
            if (uid && cls>0 && q>=1 && q<=9)
            {
                Loop
                {
                    if (D2GetActiveGamePidV95()!=pid || D2ReadU32(h,unit+0x0C)!=uid
                        || D2ReadU32(h,unit+0x14)!=data || D2ReadU32(h,data+0x14)!=seed)
                        break
                    PickupOptPollV12()
                    info := PickupOptReadV12(h,unit,cls,q,data,D2ReadU32(h,data+0x18))
                    if (IsObject(info) && info.ok)
                    {
                        name := PickupGetNameV638(info.name, info.stats)
                                    if (q=7)
            {
                un := PickupUniqueStringNameV766(h,pid,data)
                if (un!="")
                    name := un
            }
            else if (q=5)
            {
                tmpCtx := {h:h,pid:pid,setNoSigNamesV227:[],setNameCacheV227:{},setKeepLoggedV227:{}}
                sn := SigSetNameV227(tmpCtx,{unit:unit,uid:uid,cls:cls,data:data})
                if (sn!="")
                    name := sn
            }
						if (name!="")
                        {
                            row := name . "|" . cls . "|" . Format("{:02X}",q)
                            if (target="PickupEditorInputV8")
                                added := PickupEditorInsertV574(row)
                            else
                                added := PickupKeepInsertV638(row)
                            message := added ? "GET: " . row . " — bấm Lưu để áp dụng." : "GET: món này đã có trong mục đang chọn."
                            break
                        }
                    }
                    if (A_TickCount-started>=3000)
                    {
                        message := "GET: chưa đọc được tên món, chưa thêm; bấm lại."
                        break
                    }
                    Sleep, 30
                }
            }
        }
    }
    finally
        DllCall("CloseHandle","Ptr",h)
    ToolTipInfoV386(message)
    SetTimer, RemoveToolTip, -2500
    return true
}

PickupKeepInsertV638(row)
{
    GuiControlGet, raw, 1:, PickupNoSigEditorV490
    if (PickupEditorHasV10(raw,row))
        return false
    GuiControlGet, edit, 1:Hwnd, PickupNoSigEditorV490
    start := 0,finish := 0
    DllCall("SendMessage","Ptr",edit,"UInt",0xB0,"UIntP",start,"UIntP",finish,"Ptr")
    prefix := SubStr(raw,1,start)
    text := (start>0 && SubStr(prefix,0)!="`n" ? "`r`n" : "") . row . "`r`n"
    DllCall("SendMessage","Ptr",edit,"UInt",0xC2,"Ptr",1,"Str",text,"Ptr")
    return true
}

PickupCanonicalParseV491(raw)
{
    result := {add:"",input:"",left:"",exclude:"",cube:"",store:"",keep:"",canonical:false}
    section := "INPUT"
    Loop, Parse, raw, `n, `r
    {
        line := Trim(A_LoopField," `t`r`n" . Chr(0xFEFF))
        if (SubStr(line,1,1)="#" && InStr(line, "==="))
        {
            if (InStr(line,"Nhặt Thêm") || InStr(line,"Nhặt hết") || InStr(line,"Nhập Để Thêm"))
                section := "INPUT", result.canonical := true
            else if (InStr(line,"Chuyển Charm Vào Cube") || InStr(line,"Chuyển Cube"))
                section := "CUBE", result.canonical := true
            else if (InStr(line,"Chuyển Vào Kho"))
                section := "STORE", result.canonical := true
            else if (InStr(line,"Không Nhặt"))
                section := "EXCLUDE", result.canonical := true
            continue
        }
        line := Trim(RegExReplace(line,"\s*;.*$",""))
        if (line="")
            continue
            
        if (section="INPUT")
            result.input .= line . "`r`n"
        else if (section="STORE")
            result.store .= line . "`r`n"
        else if (section="EXCLUDE")
            result.exclude .= line . "`r`n"
        else if (section="CUBE")
            result.cube .= Trim(RegExReplace(line,"i)\[\s*cube\s*\]","")) . "`r`n"
    }
    
    result.left := result.input
    result.add := "" 
    result.input := PickupEditorDedupV10(result.input, removed)
    result.cube := PickupEditorDedupV10(result.cube, removed)
    result.store := PickupEditorDedupV10(result.store, removed)
    result.exclude := PickupExcludeNormalizeV717(result.exclude)
    return result
}

PickupCanonicalTextV491(add := "",excluded := "",cube := "",store := "",inputText := "")
{
    if (inputText="")
        inputText := add
        
    return "#=== Nhặt Thêm ===`r`n" . Rtrim(inputText,"`r`n") . (inputText!="" ? "`r`n" : "")
        . "`r`n#=== Chuyển Charm Vào Cube`r`n" . Rtrim(cube,"`r`n") . (cube!="" ? "`r`n" : "")
        . "`r`n#=== Chuyển Vào Kho (Cất Tiền)`r`n" . Rtrim(store,"`r`n") . (store!="" ? "`r`n" : "")
        . "`r`n#=== Không Nhặt`r`n" . Rtrim(excluded,"`r`n") . (excluded!="" ? "`r`n" : "")
}

PickupCubeRulesTextV574(raw)
{
    text := ""
    Loop, Parse, raw, `n, `r
    {
        line := Trim(A_LoopField)
        if (line!="" && SubStr(line,1,1)!="#")
            text .= line . " [cube]`r`n"
    }
    return text
}

PickupCanonicalAllowTextV491(raw)
{
    parts := PickupCanonicalParseV491(raw)
    return parts.canonical ? parts.left . parts.add . parts.store . PickupCubeRulesTextV574(parts.cube) : raw . "`r`nCharm`r`n"
}

PickupExcludeNormalizeV717(raw)
{
    seen := {},out := ""
    Loop, Parse, raw, `n, `r
    {
        line := Trim(A_LoopField," `t`r`n" . Chr(0xFEFF))
        if (line="" || (RegExMatch(line,"^#={3,}") && InStr(line,"Không Nhặt")))
            continue
        if (PickupExcludeLineClassV57(line,excludeClsV57))
        {
            key := "CLASS:" . excludeClsV57
            ; Dong cu chi luu KIND va ADDED, KHONG luu quality.
            ; Chuyen ve ten|class, khong tu dat mot quality gia.
            if (RegExMatch(line,"i)^CLASS\s*=\s*\d+",legacyV57)
                && RegExMatch(line,"i)(?:^|\|)\s*NAME\s*=\s*([^|]+)",nameV57))
                line := Trim(nameV571) . "|" . excludeClsV57
            else if (RegExMatch(line,"i)^CLASS\s*=\s*\d+",legacyV57))
                line := "CLASS=" . excludeClsV57
        }
        else
        {
            key := RegExReplace(line,"[ \t]+"," ")
            StringLower, key, key
            key := "LINE:" . key
        }
        if (seen.HasKey(key))
            continue
        seen[key] := true
        out .= line . "`r`n"
    }
    return out
}

PickupExcludeSectionTextV663(raw,excluded,fromExisting := false)
{
    if (fromExisting)
    {
        excluded := "",active := false,found := false
        Loop, Parse, raw, `n, `r
        {
            line := Trim(A_LoopField," `t`r`n" . Chr(0xFEFF))
            if (RegExMatch(line,"^#={3,}"))
            {
                active := InStr(line,"Không Nhặt") ? true : false
                found := found || active
                continue
            }
            if (active)
                excluded .= A_LoopField . "`r`n"
        }
        if (!found)
            return raw
    }
    body := PickupExcludeNormalizeV717(excluded)
    pattern := "m)(*ANYCRLF)^[ \t]*#={3,}[^\r\n]*(?:\r\n|\n|\r|$)"
    pos := 1,cursor := 1,out := "",inserted := false
    while (headerPos := RegExMatch(raw,pattern,header,pos))
    {
        bodyStart := headerPos+StrLen(header)
        nextPos := RegExMatch(raw,pattern,nextHeader,bodyStart)
        if (InStr(header,"Không Nhặt"))
        {
            out .= SubStr(raw,cursor,headerPos-cursor)
            if (!inserted)
            {
                out .= "#=== Không Nhặt`r`n" . body . (nextPos ? "`r`n" : "")
                inserted := true
            }
            cursor := nextPos ? nextPos : StrLen(raw)+1
        }
        if (!nextPos)
            break
        pos := nextPos
    }
    out .= SubStr(raw,cursor)
    if (!inserted && fromExisting)
        return raw
    if (!inserted)
        out .= (out!="" && SubStr(out,0)!="`n" ? "`r`n" : "")
            . "`r`n#=== Không Nhặt`r`n" . body
    return out
}

PickupCanonicalExcludeSyncV491()
{
    file := UniquePickupFileV3(),excludeFile := PickupExcludeFileV329()
    if (!FileExist(file) || !RareWarningReadTextV35(file,raw,false))
        return false
    if (!PickupCanonicalParseV491(raw).canonical || !RareWarningReadTextV35(excludeFile,excluded,false))
        return false
    normalized := PickupExcludeNormalizeV717(excluded)
    if (normalized!=excluded && !RareWarningWriteTextV35(excludeFile,normalized))
        return false
    changed := PickupExcludeSectionTextV663(raw,normalized)
    if (changed!=raw && !RareWarningWriteTextV35(file,changed))
        return false
    if (ProfileControlExistsV365("PickupEditorInputV8"))
    {
        GuiControlGet, editorRaw, 1:, PickupEditorInputV8
        editorChanged := PickupExcludeSectionTextV663(editorRaw,normalized)
        if (editorChanged!=editorRaw)
            GuiControl, 1:, PickupEditorInputV8, %editorChanged%
    }
    return true
}


PickupCatalogCustomV490()
{
    global pickupCatalogNamesV11
    if (!RareWarningReadTextV35(UniquePickupFileV3(),raw,true))
        return
    parts := PickupCanonicalParseV491(raw),rules := parts.left . parts.add
    roots := {},known := {},used := {},angelicRows := [],defaultRoots := {}
    for node,name in pickupCatalogNamesV11
    {
        known[PickupNameNormalizeV8(name)] := node
        if (!TV_GetParent(node))
        {
            roots[PickupNameNormalizeV8(name)] := node
            defaultRoots[PickupNameNormalizeV8(name)] := true
        }
    }
    Loop, Parse, rules, `n, `r
    {
        line := Trim(A_LoopField)
        if (line="" || SubStr(line,1,1)="#")
            continue
        groupName := PickupLeftCategoryV638(line),key := PickupNameNormalizeV8(groupName)
        if (key="angelic")
        {
            angelicRows.Push(line)
            continue
        }
        if (!roots.HasKey(key))
            roots[key] := PickupCatalogNodeV11(groupName,0,false)
        used[key] := true
        display := line
        if (PickupShortParseV638(line,label,cls,q))
            display := label
        if (!known.HasKey(PickupNameNormalizeV8(display)))
            PickupCatalogNodeV11(line,roots[key],false)
    }
    for key,node in roots
        if (!used.HasKey(key) && !defaultRoots.HasKey(key))
        {
            remove := []
            for child,_ in pickupCatalogNamesV11
            {
                p := child
                while (p && p!=node)
                    p := TV_GetParent(p)
                if (p=node)
                    remove.Push(child)
            }
            for _,child in remove
                pickupCatalogNamesV11.Delete(child)
            TV_Delete(node)
        }
        
    angelicKey := PickupNameNormalizeV8("Angelic")
    if (!roots.HasKey(angelicKey))
    {
        angelicRoot := PickupCatalogNodeV11("Angelic",0,false)
        roots[angelicKey] := angelicRoot
    }
    else
        angelicRoot := roots[angelicKey]
    for _,line in angelicRows
        if (PickupNameNormalizeV8(line)!="angelic")
            PickupCatalogNodeV11(line,angelicRoot,false)
}

PickupSplitInitV490()
{
    global pickupExcludeTextV490,pickupNoSigTextV490
    if (!UniquePickupCleanDuplicateV19())
        return false
    source := UniquePickupFileV3()
    if (!RareWarningReadTextV35(source,raw,false))
        return false
    parts := PickupCanonicalParseV491(raw)
    if (!FileExist(PickupNoSigFileV490()))
        if (!RareWarningWriteTextV35(PickupNoSigFileV490(),parts.keep))
            return false
    if (!RareWarningReadTextV35(PickupNoSigFileV490(),pickupNoSigTextV490,false))
        return false
    if (!FileExist(PickupExcludeFileV329()))
        if (!RareWarningWriteTextV35(PickupExcludeFileV329(),parts.exclude))
            return false
    pickupExcludeTextV490 := parts.exclude
    PickupExcludeLoadV329(),PickupNoSigLoadV490(),UniquePickupReloadRAMV1()
    PickupCatalogBuildV8()
    return true
}

PickupHeadersEnsureV684(raw)
{
    found := {}
    Loop, Parse, raw, `n, `r
    {
        line := Trim(A_LoopField," `t`r`n" . Chr(0xFEFF))
        if (SubStr(line,1,1)!="#" || !InStr(line,"==="))
            continue
        if (InStr(line,"Nhặt Thêm") || InStr(line,"Nhặt hết") || InStr(line,"Nhập Để Thêm"))
            found.input := true
        else if (InStr(line,"Chuyển Charm Vào Cube") || InStr(line,"Chuyển Cube"))
            found.cube := true
        else if (InStr(line,"Chuyển Vào Kho"))
            found.store := true
        else if (InStr(line,"Không Nhặt"))
            found.exclude := true
    }
    if (!found.input)
        raw := "#=== Nhặt Thêm ===`r`n`r`n" . raw
    for _,section in [{key:"cube",title:"Chuyển Charm Vào Cube"}
        ,{key:"store",title:"Chuyển Vào Kho (Cất Tiền)"},{key:"exclude",title:"Không Nhặt"}]
        if (!found[section.key])
            raw .= (raw!="" && SubStr(raw,0)!="`n" ? "`r`n" : "")
                . "`r`n#=== " . section.title . "`r`n`r`n"
    return raw
}

PickupSplitSaveV490()
{
    GuiControlGet, raw, 1:, PickupEditorInputV8
    raw := PickupHeadersEnsureV684(raw)
    GuiControlGet, keep, 1:, PickupNoSigEditorV490
    parts := PickupCanonicalParseV491(raw)
    if (parts.keep!="")
        keep := PickupEditorDedupV10(keep . "`r`n" . parts.keep,removed)
    
    inputList := PickupEditorDedupV10(parts.input, removed)
    
    index := PickupNameIndexV638()
    parts.cube := PickupUpgradeNamesV638(parts.cube,index)
    parts.store := PickupUpgradeNamesV638(parts.store,index)
    parts.exclude := PickupExcludeNormalizeV717(PickupUpgradeNamesV638(parts.exclude,index))
    raw := PickupExcludeSectionTextV663(raw,parts.exclude)
    keep := PickupUpgradeNamesV638(keep,index)
    inputList := PickupUpgradeNamesV638(inputList,index)
    
    if (!PickupOptValidateTextV12(inputList,error) || !PickupOptValidateTextV12(parts.store,error)
        || !PickupOptValidateTextV12(PickupCubeRulesTextV574(parts.cube),error)
        || !PickupSplitValidateV490(parts.exclude,error)
        || !PickupSplitValidateV490(keep,error,true))
    {
        GuiControl, 1:Show, PickupEditorStatusV8
        GuiControl, 1:, PickupEditorStatusV8, %error%
        return false
    }
    
    if (!RareWarningWriteTextV35(PickupExcludeFileV329(),parts.exclude)
        || !RareWarningWriteTextV35(PickupNoSigFileV490(),keep)
        || !RareWarningWriteTextV35(UniquePickupFileV3(),raw))
    {
        GuiControl, 1:Show, PickupEditorStatusV8
        GuiControl, 1:, PickupEditorStatusV8, Không lưu được danh sách; giữ bản nhập để thử lại.
        return false
    }
    
    PickupExcludeLoadV329(),PickupNoSigLoadV490(),UniquePickupReloadRAMV1()
    PickupCatalogBuildV8()
    GuiControl, 1:, PickupEditorInputV8, % PickupEditorReadV8()
    GuiControl, 1:, PickupNoSigEditorV490, %keep%
    GuiControl, 1:Hide, PickupEditorStatusV8
    return true
}

PickupSplitValidateV490(raw,ByRef error,noSig := false)
{
    error := ""
    Loop, Parse, raw, `n, `r
    {
        line := Trim(A_LoopField)
        if (line="" || SubStr(line,1,1)="#"
            || (!noSig && PickupExcludeLineClassV57(line,classV57))
            || RegExMatch(line,"i)^CLASS\s*=\s*\d+"))
            continue
        parsed := noSig ? SetNoSigParseV227(line) : false
        if (IsObject(parsed))
            continue
        if (!IsObject(PickupOptParseV12(line,why)))
        {
            error := (noSig ? "Không SIG" : "Không nhặt") . " dòng " . A_Index . ": " . why
            return false
        }
    }
    return true
}

PickupNoSigLoadV490()
{
    global pickupNoSigRulesV490,pickupNoSigClassesV490,pickupOptRevisionV12
    pickupNoSigRulesV490 := [],pickupNoSigClassesV490 := {}
    if (RareWarningReadTextV35(PickupNoSigFileV490(),raw,true))
        Loop, Parse, raw, `n, `r
        {
            line := Trim(A_LoopField)
            if (line="" || SubStr(line,1,1)="#" || IsObject(SetNoSigParseV227(line)))
                continue
            if (RegExMatch(line,"i)^CLASS\s*=\s*(\d+)",m))
                pickupNoSigClassesV490[m1+0] := true
            else if (IsObject(rule := PickupOptParseV12(line,error)))
                pickupNoSigRulesV490.Push(rule)
        }
    pickupOptRevisionV12++
}

PickupRuleListMatchV490(rules,h,unit,cls,q,data,ByRef ready)
{
    global consumableClassRAMV7
    ready := true
    if (!IsObject(rules) || !rules.Length())
        return false
    if (!unit || !h || !data)
    {
        ready := false
        return false
    }
    needsNameV638 := false
    for _,rule in rules
        if (rule.HasKey("exactClassV638"))
        {
            if (PickupOptRuleMatchV12(rule,q,0,"","","",h,cls))
                return true
        }
        else
            needsNameV638 := true
    if (!needsNameV638)
        return false
    PickupOptPollV12()
    flags := D2ReadU32(h,data+0x18)
    info := PickupOptReadV12(h,unit,cls,q,data,flags)
    if (!IsObject(info) || !info.ok)
    {
        ready := false
        return false
    }
    ConsumablePickupGroupV7(h,cls)
    classKeyV499 := info.pid . "|" . cls
    baseNameV499 := IsObject(consumableClassRAMV7) && consumableClassRAMV7.HasKey(classKeyV499) ? consumableClassRAMV7[classKeyV499] : ""
    for _,rule in rules
        if (PickupOptRuleMatchV12(rule,q,flags,info.name,info.stats,baseNameV499,h,cls))
            return true
    return false
}

PickupExcludeGroupMatchV491(h,cls,q,data)
{
    global pickupExcludeGroupsV491,consumableClassRAMV7
    groups := pickupExcludeGroupsV491
    if (!IsObject(groups) || !groups.Count())
        return false
    if (groups.HasKey("CHARM") && PickupIsCharmV571(h,cls))
        return true
    if (q+0=5 && groups.HasKey("SET_XANH"))
        return true
    if (q+0=7 && groups.HasKey("UNIQUE"))
        return true
    if (q+0=7 && data && h)
    {
        tier := UniqueItemsTierFromLiveTableV1(h,D2ReadU32(h,data+0x28),wlvl)
        if (groups.HasKey(tier))
            return true
    }
    group := ConsumablePickupGroupV7(h,cls)
    if (groups.HasKey(group))
        return true
    for _,parent in PickupGroupParentChainV8(group)
        if (groups.HasKey(parent))
            return true
    pid := h ? DllCall("GetProcessId","Ptr",h,"UInt") : 0
    keyV499 := pid . "|" . cls
    if (!pid || !IsObject(consumableClassRAMV7) || !consumableClassRAMV7.HasKey(keyV499))
        return true
    nameV499 := consumableClassRAMV7[keyV499]
    for excludedGroupV499,_ in groups
        if (PickupAlertGroupMatchV14(excludedGroupV499,q,"",q+0=5,nameV499))
            return true
    return false
}

PickupExcludedByNameV490(h,unit,cls,q,data)
{
    global pickupExcludeRulesV490
    if (PickupExcludeGroupMatchV491(h,cls,q,data))
        return true
    hit := PickupRuleListMatchV490(pickupExcludeRulesV490,h,unit,cls,q,data,ready)
    return hit || !ready
}

PickupNoSigMatchV490(ctx,item,q)
{
    global pickupNoSigRulesV490,pickupNoSigClassesV490,consumableClassRAMV7
    classKeepV981 := IsObject(pickupNoSigClassesV490) && pickupNoSigClassesV490.HasKey(item.cls)
    specificPresentV981 := false
    if (IsObject(pickupNoSigRulesV490))
        for _,ruleV981 in pickupNoSigRulesV490
            if (!ruleV981.HasKey("exactClassV638")
                && (ruleV981.stats.Length() || ruleV981.qualities.Count()
                    || ruleV981.tiers.Count() || ruleV981.eth))
                specificPresentV981 := true

    ; V981: ten + OPT trong ds KHONG SIG phai duoc xet TRUOC whitelist CLASS.
    ; Vi du: Angel of Death [2] [30%] [15%] - sai 1 opt thi SIG ngay,
    ; khong duoc giu lai boi CLASS chung hay rule theo ten khong co OPT.
    if (specificPresentV981)
    {
        startedV981 := A_TickCount
        Loop
        {
            PickupOptPollV12()
            flagsV981 := D2ReadU32(ctx.h,item.data+0x18)
            infoV981 := PickupOptReadV12(ctx.h,item.unit,item.cls,q,item.data,flagsV981)
            if (IsObject(infoV981) && infoV981.ok)
            {
                classKeyV981 := infoV981.pid . "|" . item.cls
                baseNameV981 := IsObject(consumableClassRAMV7) && consumableClassRAMV7.HasKey(classKeyV981)
                    ? consumableClassRAMV7[classKeyV981] : ""
                namedSpecificV981 := false,matchingSpecificV981 := false
                for _,ruleV981 in pickupNoSigRulesV490
                {
                    if (ruleV981.HasKey("exactClassV638")
                        || (!ruleV981.stats.Length() && !ruleV981.qualities.Count()
                            && !ruleV981.tiers.Count() && !ruleV981.eth))
                        continue
                    if (!RegExMatch(infoV981.name . "`n" . baseNameV981,"im)" . ruleV981.name))
                        continue
                    namedSpecificV981 := true
                    if (PickupOptRuleMatchV12(ruleV981,q,flagsV981,infoV981.name
                        ,infoV981.stats,baseNameV981,ctx.h,item.cls))
                        matchingSpecificV981 := true
                }
                if (namedSpecificV981)
                {
                    SigLogV147("SIG_NO_SIG_OPTS uid=" . item.uid . " class=" . item.cls
                        . " name=" . StrReplace(infoV981.name,"`n"," | ")
                        . " match=" . matchingSpecificV981
                        . " action=" . (matchingSpecificV981 ? "KEEP" : "SIG"))
                    return matchingSpecificV981
                }
                break
            }
            ; Khong SIG neu chua doc duoc ten/OPT - khong suy doan sai.
            if (A_TickCount-startedV981>3000)
                return true
            Sleep, 50
        }
    }
    if (classKeepV981)
    {
        SigLogV147("SIG_KEEP_CLASS uid=" . item.uid . " class=" . item.cls . " reason=NO_SIG_CLASS_RULE")
        return true
    }
    started := A_TickCount
    Loop
    {
        hit := PickupRuleListMatchV490(pickupNoSigRulesV490,ctx.h,item.unit,item.cls,q,item.data,ready)
        if (ready)
            return hit
        if (A_TickCount-started > 3000)
            return true
        PickupOptPollV12()
        Sleep, 50
    }
}
PickupEditorReadV8()
{
    if (!UniquePickupCleanDuplicateV19() || !RareWarningReadTextV35(UniquePickupFileV3(),raw,false))
        return ""
    return raw
}

PickupCharmNamesV731()
{
    return "The Butcher's Tooth|Riftwalker's Eye|Laser Focus Crystal|Optical Detector|Scroll of Kings|Horazon's Focus|Visions of Akarat"
        . "|Sacred Worldstone Key|Moon of the Spider|Fool's Gold|Spirit Trance Herb|The Black Road|Legacy of Blood|Idol of Vanity"
        . "|Azmodan's Heart|Crystalline Flame Medallion|Weather Control|Silver Seal of Ureh|Eternal Bone Pile|Soul of Kabraxis|Lylia's Curse"
        . "|Spirit of Creation|The Book of Lies|Dragon Claw|The Ancient Repositories|Xazax's Illusion|Astrogha's Venom Stinger|The Sleep"
        . "|Books of Kalan|Neutrality Pact|The Glorious Book of Median|Vial of Elder Blood|Essence of Time|Dulra Fruit|Paragon's Hammer"
        . "|Six Angel Bag|Zakarum's Ear|Sunstone of the Gods|Umbaru Treasure|Corrupted Wormhole|Demonsbane|Cold Fusion Schematics"
        . "|Dimensional Key|Sunstone of the Twin Seas|Sacred Sunstone|Shadow Vortex|Worldstone Orb|Caoi Dulra Fruit|Soulstone Shard"
        . "|Eye of Divinity|Nexus Crystal|Dúlra Aegis"
}

PickupCatalogBuildV8()
{
    global pickupCatalogNamesV11,pickupDefaultCatalogV490
    Gui, TreeView, PickupCatalogV8
    TV_Delete()
    pickupCatalogNamesV11 := {}
    PickupCatalogNodeV11("Horadric Cube")
    charmRootV573 := PickupCatalogNodeV11("Charm")
    PickupCatalogNodeV11("Relic",charmRootV573,false)
    for _,name in StrSplit(PickupCharmNamesV731(),"|")
        PickupCatalogNodeV11(name,charmRootV573,false)
    root := PickupCatalogNodeV11("Unique")
    for _,tier in ["TU","SU","SSU","SSSU"]
        PickupCatalogNodeV11(tier,root)
    PickupCatalogNodeV11("Set xanh")
    PickupCatalogNodeV11("Mastercrafted")
    root := PickupCatalogNodeV11("Rune")
    runeSets := [{name:"Rune thường",names:"El|Eld|Tir|Nef|Eth|Ith|Tal|Ral|Ort|Thul|Amn|Sol|Shael|Dol|Hel|Io|Lum|Ko|Fal|Lem|Pul|Um|Mal|Ist|Gul|Vex|Ohm|Lo|Sur|Ber|Jah|Cham|Zod"}
        ,{name:"Rune Enchanted",names:"Ol|Elq|Tyr|Nif|Xeth|Xith|Thal|Rhal|Urt|Tuul|Ahmn|Zol|Shaen|Doj|Hem|Iu|Lux|Ka|Fel|Lew|Phul|Un|Mhal|Yst|Gur|Vez|Ohn|Loz|Zur|Bur|Iah|Yham|Xod"}
        ,{name:"Rune Great",names:"Taha|Ghal|Qor"},{name:"Rune Elemental",names:"Fire|Stone|Arcane|Poison|Light|Ice"}]
    for _,set in runeSets
    {
        branch := PickupCatalogNodeV11(set.name,root,false)
        Loop, Parse, % set.names, |
            PickupCatalogNodeV11(A_LoopField . " Rune",branch,false)
    }
    root := PickupCatalogNodeV11("Gem")
    gems := "Diamond|Amethyst|Ruby|Topaz|Bloodstone|Onyx|Amber|Turquoise|Sapphire|Emerald|Rainbow Stone|Skull"
    for _,set in [{name:"Gem thường",prefix:""},{name:"Gem Flawless",prefix:"Flawless "},{name:"Gem Perfect",prefix:"Perfect "}]
    {
        branch := PickupCatalogNodeV11(set.name,root,false)
        Loop, Parse, gems, |
            PickupCatalogNodeV11(set.prefix . A_LoopField,branch,false)
    }
    root := PickupCatalogNodeV11("Shrine")
    PickupCatalogNodeV11("Shrine (10)",root,false)
    shrines := "Abandoned|Creepy|Eerie|Enchanted|Fascinating|Hidden|Intimidating|Magical|Ornate|Quiet|Sacred|Shimmering|Spiritual|Tainted|Trinity|Weird"
    Loop, Parse, shrines, |
        PickupCatalogNodeV11(A_LoopField . " Shrine",root,false)
    root := PickupCatalogNodeV11("Oil")
    for _,name in ["Oil of Augmentation","Oil of Conjuration","Oil of Greater Luck","Oil of Intensity"]
        PickupCatalogNodeV11(name,root,false)
    for _,group in ["Arcane","Corrupted"]
    {
        root := PickupCatalogNodeV11(group)
        for _,suffix in ["Shard","Crystal","Cluster"]
            PickupCatalogNodeV11(group . " " . suffix,root,false)
    }
    root := PickupCatalogNodeV11("Material")
    for _,name in ["Sacred Essence","Heavenly Soul","Mark of Infusion","Crate O' Souls","Crate O' Sacred Essence"]
        PickupCatalogNodeV11(name,root,false)
    root := PickupCatalogNodeV11("Signet")
    for _,name in ["Signet of Learning","Greater Signet of Learning","Large Signet of Learning","Custom Signet"]
        PickupCatalogNodeV11(name,root,false)
    root := PickupCatalogNodeV11("Cycle")
    for _,name in ["Small Cycle","Medium Cycle","Large Cycle","Golden Cycle"]
        PickupCatalogNodeV11(name,root,false)
    for _,name in ["Mystic Orb","Container","Essence","Vessel","Enchant Scroll","Enchanting","Mystic Dye","Treasure","Item Design","Belladonna Extract","Riftstone","Scroll of Summoning","Trophy","Occult Effigy","Emblem","Quest Item","Cube Reagent"]
        PickupCatalogNodeV11(name)
    pickupDefaultCatalogV490 := ""
    for node,name in pickupCatalogNamesV11
        if (!TV_GetParent(node))
            pickupDefaultCatalogV490 .= name . "`r`n"
    pickupDefaultCatalogV490 .= "Relic`r`nRunestone`r`n"
    PickupCatalogCustomV490()
    for node,_ in pickupCatalogNamesV11
        TV_Modify(node,"Sort -Expand")
    PickupCatalogArrangeV638()
}

PickupCatalogNodeV11(name,parent:=0,expand:=false)
{
    global pickupCatalogNamesV11
    node := TV_Add(name,parent,expand ? "Expand" : "")
    pickupCatalogNamesV11[node] := name
    return node
}


PickupCatalogPatternsV9()
{
    static patterns := ""
    if (!IsObject(patterns))
        patterns := {"mastercrafted":"\(Mastercrafted\)","mystic orb":"Mystic Orb","container":"Container","runestone":"Runestone","essence":"Essence","vessel":"Vessel","enchant scroll":"Enchant Scroll","enchanting":"Enchanting","mystic dye":"Mystic Dye","treasure":"Treasure","item design":"Item Design","belladonna extract":"Belladonna Extract","riftstone":"Riftstone","scroll of summoning":"Scroll of Summoning","relic":"Relic","trophy":"Trophy","occult effigy":"Occult Effigy","emblem":"Emblem of","cycle":"Cycle","small cycle":"Small Cycle","medium cycle":"Medium Cycle","large cycle":"Large Cycle","golden cycle":"Golden Cycle","quest item":"Quest Item","cube reagent":"Cube Reagent","shrine (10)":"Shrine \(10(?:\)|$)","signet":"Signet"}
    shrines := "Abandoned|Creepy|Eerie|Enchanted|Fascinating|Hidden|Intimidating|Magical|Ornate|Quiet|Sacred|Shimmering|Spiritual|Tainted|Trinity|Weird"
    Loop, Parse, shrines, |
        patterns[PickupNameNormalizeV8(A_LoopField . " Shrine")] := "^" . A_LoopField . " Shrine(?: \(\d+\))?$"
    return patterns
}


PickupEditorKeyV10(line)
{
    line := LTrim(Trim(line," `t`r`n" . Chr(0xFEFF)),"# `t")
    if (line="")
        return ""
    if (PickupShortParseV638(line,shortName,shortClass,shortQuality))
        return "ITEM:" . RareWarningRuleKeyV29(shortClass,shortQuality,-1)
    if (IsObject(SetNoSigParseV227(line)) && RegExMatch(line,"[\[{]"))
        return "SET_KEEP:" . PickupNameNormalizeV8(line)
    if (PickupOptIsRuleV12(line))
        return "OPT:" . PickupNameNormalizeV8(line)
    group := PickupAutoGroupParseV7(line)
    if (group!="")
        return "GROUP:" . group
    if (UniqueRuleParseV18(line,cls,q,idx,tier))
        return "ITEM:" . RareWarningRuleKeyV29(cls,q,idx)
    return "TEXT:" . PickupNameNormalizeV8(line)
}

PickupEditorHasV10(raw,name)
{
    wanted := PickupEditorKeyV10(name)
    Loop, Parse, raw, `n, `r
        if (PickupEditorKeyV10(A_LoopField)=wanted)
            return true
    return false
}

PickupEditorDedupV10(raw,ByRef removed)
{
    seen := {},removed := 0,result := ""
    Loop, Parse, raw, `n, `r
    {
        line := Trim(A_LoopField," `t`r`n" . Chr(0xFEFF))
        if (SubStr(line,1,1)="#")
        {
            result .= line . "`r`n"
            continue
        }
        key := PickupEditorKeyV10(line)
        if (key="")
            continue
        if (seen.HasKey(key))
        {
            removed++
            continue
        }
        seen[key] := true
        result .= line . "`r`n"
    }
    return result
}

PickupOptIsRuleV12(line)
{
    line := PickupColorStripV14(Trim(line," `t`r`n" . Chr(0xFEFF)),ignoredColorV14)
    if (PickupShortParseV638(RegExReplace(line,"i)\[\s*cube\s*\]",""),shortName,shortClass,shortQuality))
        return true
    if (SubStr(line,1,1)!="#" && RegExMatch(line,"i)\[\s*cube\s*\]"))
        return true
    if (IsObject(SetNoSigParseV227(line)))
        return false
    return SubStr(line,1,1)=Chr(34) || (SubStr(line,1,1)!="#" && RegExMatch(line,"^.+[\[{]"))
}

PickupOptRegexValidV12(pattern,ByRef error)
{
    error := ""
    try
    {
        RegExMatch("","im)" . pattern)
        if (ErrorLevel)
            error := "Regex không hợp lệ: " . pattern
    }
    catch e
        error := "Regex không hợp lệ: " . pattern
    return error=""
}

PickupOptParseV12(line,ByRef error)
{
    rawLineV14 := line
    cubeRelicV567 := RegExMatch(line,"i)\[\s*cube\s*\]") ? true : false
    line := RegExReplace(line,"i)\[\s*cube\s*\]","")
    line := PickupColorStripV14(line,ruleColorV14)
    error := "",line := Trim(line," `t`r`n" . Chr(0xFEFF))
    if (PickupShortParseV638(line,shortName,shortClass,shortQuality))
        return {name:".*",stats:[],qualities:{},tiers:{},eth:false,raw:rawLineV14,color:ruleColorV14
            ,exactClassV638:shortClass,exactQualityV638:shortQuality
            ,cubeRelicV567:cubeRelicV567 && InStr(shortName,"Relic"),cubeCharmV571:cubeRelicV567 && !InStr(shortName,"Relic")}
    simpleMode := SubStr(line,1,1)!=Chr(34)
    if (simpleMode)
    {
        simple := Trim(RegExReplace(line,"\s+#.*$","")," `t:")
        splitAt := RegExMatch(simple,"[\[{]")
        m1 := splitAt ? Trim(SubStr(simple,1,splitAt-1)) : simple
        m2 := splitAt ? SubStr(simple,splitAt) : ""
        if (m1="" || InStr(m1,"=") || InStr(m1,Chr(34)))
        {
            error := "Nhập tên đồ trước [] hoặc {}."
            return false
        }
    }
    else if (!RegExMatch(line,"^" . Chr(34) . "([^" . Chr(34) . "]+)" . Chr(34) . "(.*)$",m))
    {
        error := "Tên phải nằm trong dấu nháy kép."
        return false
    }
    name := simpleMode ? "(?<![[:alnum:]_])\Q" . Trim(m1) . "\E(?![[:alnum:]_])" : RegExReplace(Trim(m1),"\s*\|\s*","|")
    if (!PickupOptRegexValidV12(name,error))
        return false
    rule := {name:name,stats:[],qualities:{},tiers:{},eth:false,raw:rawLineV14,color:ruleColorV14}
    category := Trim(m1)
    StringLower, category, category
    rule.cubeRelicV567 := cubeRelicV567 && category="relic"
    rule.namedCharmV740 := false
    if (simpleMode)
        for _,charmNameV740 in StrSplit(PickupCharmNamesV731(),"|")
            if (category=PickupNameNormalizeV8(charmNameV740))
                rule.namedCharmV740 := true
    rule.charmV571 := category="charm"
    rule.cubeCharmV571 := cubeRelicV567 && category!="relic"
    rule.setV574 := category="set" || category="set xanh" || category="set_xanh"
    if (rule.setV574)
        rule.qualities[5] := true,rule.name := ".*"
    if (simpleMode && (category="angelic" || category="sacred" || category="mastercrafted"))
    {
        rule.name := ".*"
        rule.tiers[category] := true
    }
    rest := m2,tokens := "",i := 1
    while (i<=StrLen(rest))
    {
        ch := SubStr(rest,i,1)
        if (ch="#")
            break
        if (ch!="{" && ch!="[")
        {
            tokens .= ch,i++
            continue
        }
        opener := ch,closer := ch="{" ? "}" : "]"
        depth := 1,pattern := "",escaped := false,i++
        while (i<=StrLen(rest) && depth>0)
        {
            ch := SubStr(rest,i,1),i++
            if (!escaped && ch=opener)
                depth++
            else if (!escaped && ch=closer)
                depth--
            if (depth>0)
                pattern .= ch
            escaped := (!escaped && ch="\")
        }
        if (depth)
        {
            error := "Thiếu dấu " . closer . " đóng option."
            return false
        }
        pattern := RegExReplace(Trim(pattern),"\s*\|\s*","|")
        pattern := RegExReplace(pattern,"i)(^|\|)(?:doc|độc)(?=\||$)","$1\bPoison\b")
        if (RegExMatch(pattern,"^(\d+)(?:-(\d+))?$",range))
        {
            minimum := range1+0,maximum := range2="" ? minimum : range2+0
            if (minimum>maximum || maximum>99)
            {
                error := "Khoảng All Skills phải tăng dần và trong 0–99."
                return false
            }
            values := ""
            Loop, % maximum-minimum+1
                values .= (A_Index=1 ? "" : "|") . (minimum+A_Index-1)
            pattern := "(?<![0-9])\+?(?:" . values . ")\s+to All Skills\b"
        }
        if (pattern="" || !PickupOptRegexValidV12(pattern,error))
        {
            if (error="")
                error := "Option trong [] hoặc {} không được để trống."
            return false
        }
        rule.stats.Push(pattern),tokens .= " "
    }
    qualities := {"low":1,"inferior":1,"normal":2,"superior":3,"magic":4,"set":5,"rare":6,"unique":7,"crafted":8,"honorific":9}
    tokens := RegExReplace(Trim(tokens),"\s+"," ")
    Loop, Parse, tokens, %A_Space%
    {
        token := A_LoopField
        StringLower, token, token
        if (token="")
            continue
        if (qualities.HasKey(token))
            rule.qualities[qualities[token]] := true
        else if (token="eth" || token="ethereal")
            rule.eth := true
        else if (RegExMatch(token,"^(sacred|angelic|mastercrafted|1|2|3|4)$"))
            rule.tiers[token] := true
        else if (RegExMatch(token,"^(red|green|blue|yellow|gold|white|black|orange|purple|grey|gray|tan|pink|darkgreen|sound\d+|notify|stat|map|show)$"))
            continue
        else
        {
            error := "Chưa hỗ trợ từ: " . token
            return false
        }
    }
    return rule
}

PickupOptValidateTextV12(raw,ByRef error)
{
    error := ""
    Loop, Parse, raw, `n, `r
    {
        if (!PickupOptIsRuleV12(A_LoopField))
            continue
        if (!IsObject(PickupOptParseV12(A_LoopField,why)))
        {
            error := "Dòng " . A_Index . ": " . why
            return false
        }
    }
    return true
}

PickupOptHelpV12()
{
    text := "NHẶT THEO TÊN VÀ OPTION`r`n`r`n"
    text .= "Set xanh [Zakarum]{Tên bộ khác}: nhặt mọi đồ Set; các bộ trong ngoặc không được SIG. [] và {} dùng như nhau; ngoặc trống bỏ qua. Tên bộ không phân biệt hoa/thường; có thể nhập phần tên (Zakarum).`r`n"
    text .= "Rune [red] hoặc Rune {red}: nhặt Rune và hiện chữ đỏ. Không ghi màu: xanh.`r`n"
    text .= "Angelic [2-5] {doc} [red]: điều kiện nhặt giữ nguyên, cảnh báo màu đỏ.`r`n"
    text .= "Màu: red, green, blue, yellow, gold, white, orange, purple, grey, pink, tan, darkgreen, black.`r`n"
    text .= "Light Plate [2-5] = nhặt Light Plate có +2 đến +5 All Skills.`r`n"
    text .= "Light Plated Boots = nhặt hết loại đó, không xét option.`r`n"
    text .= "Full Helm [3] = chỉ nhặt mũ có +3 All Skills.`r`n"
    text .= "Angelic [2-5] {doc} = mọi đồ Angelic có +2 đến +5 All Skills và option chứa Poison. doc/độc đều dùng được.`r`n"
    text .= "[] và {} dùng như nhau; có hoặc không có khoảng trắng trước ngoặc đều được.`r`n"
    text .= "Tên phải dùng đúng tên loại đồ trong game. Không phân biệt hoa/thường.`r`n`r`n"
    text .= "Option khác: " . Chr(34) . "Leather Gloves" . Chr(34) . " {Fire dance}`r`n"
    text .= "[] và {} dùng như nhau. Chỉ ghi số = All Skills; chữ = tên option. Hai nhóm cần cả hai; | trong một nhóm là chọn một.`r`n"
    text .= "Có thể thêm angelic, sacred, rare, eth... sau tên trong nháy kép để giới hạn loại đồ.`r`n"
    text .= "Mục Chuyển Charm Vào Cube: nhập tên đồ hoặc Tên|CLASS|ITEMDATA, ví dụ Relic hoặc Charm; không cần [cube].`r`n"
    text .= "Mục Chuyển Vào Kho (Cất Tiền): đồ trong Cube hoặc dưới đất → túi trung gian → kho khi Cất tiền; bỏ qua đồ có sẵn trong túi.`r`n"
    text .= "Charm: chỉ đổi tạm khi có đúng Charm cùng loại trong rương ngoài; chưa có đúng món đó thì chỉ nhặt, không chuyển Cube.`r`n"
    text .= "# tắt dòng. #Angelic: chỉ là tiêu đề ghi chú.`r`n`r`n"
    text .= "Món có luật tên/option riêng phải đạt điều kiện trước khi nhặt; luật nhặt mặc định và GET không bỏ qua điều kiện. Trong mục Chuyển Charm Vào Cube, Zakarum's Ear [rrr 15%] hoặc Zakarum's Ear {rrr 15%} chỉ nhận món có option khớp rrr 15%.`r`n"
    text .= "Tool đọc chữ trực tiếp từ game. Nếu chưa đọc được option thì chưa nhặt qua luật có option. XUẤT LOG ghi tên, option và lỗi đọc khi bạn bật log."
    return text
}

PickupOptExamplesV12()
{
    q := Chr(34)
    return "#Light Plate [2-5]`r`n#Light Plated Boots`r`n#Full Helm [3-4]`r`n#" . q . "Boots" . q . " angelic {All Skills} {All Attributes}`r`n"
}

PickupOptCleanTextV12(raw,reverseLines:=false)
{
    clean := RegExReplace(raw,Chr(255) . "c.","")
    clean := StrReplace(clean,"`r","")
    if (!reverseLines)
        return Trim(clean," `t`n")
    lines := StrSplit(clean,"`n"),result := ""
    Loop, % lines.Length()
    {
        line := Trim(lines[lines.Length()-A_Index+1])
        if (line!="")
            result .= (result="" ? "" : "`n") . line
    }
    return result
}

PickupOptRuleMatchV12(rule,q,flags,name,stats,baseName:="",h:=0,cls:=-1)
{
    if (rule.HasKey("exactClassV638"))
        return cls+0=rule.exactClassV638 && q+0=rule.exactQualityV638
    if (rule.qualities.Count() && !rule.qualities.HasKey(q+0))
        return false
    if (rule.eth && !(flags & 0x00400000))
        return false
    if (rule.tiers.Count())
    {
        hit := false
        for tier,_ in rule.tiers
            if (RegExMatch(name . "`n" . baseName,"im)\(" . tier . "\)"))
                hit := true
        if (!hit)
            return false
    }
    if (rule.charmV571 ? !PickupIsCharmV571(h,cls) : !RegExMatch(name . "`n" . baseName,"im)" . rule.name))
        return false
    for _,pattern in rule.stats
        if (stats="" || !RegExMatch(stats,"im)" . pattern))
            return false
    return true
}

PickupOptMatchV12(h,unit,cls,q,data)
{
    global pickupOptRulesV12,consumableClassRAMV7,pickupCubeTraceUntil
    PickupOptPollV12()
    if (!IsObject(pickupOptRulesV12))
        UniquePickupReloadRAMV1()
    if (!unit || !data || !h || !IsObject(pickupOptRulesV12) || !pickupOptRulesV12.Length())
        return false
    flags := D2ReadU32(h,data+0x18),possible := false
    for _,rule in pickupOptRulesV12
        if (!rule.actionOnlyV678 && (!rule.qualities.Count() || rule.qualities.HasKey(q+0)) && (!rule.eth || (flags & 0x00400000)))
            possible := true
    if (!possible)
        return false
    info := PickupOptReadV12(h,unit,cls,q,data,flags)
    if (!IsObject(info) || !info.ok)
        return false
    classKey := info.pid . "|" . cls
    baseName := IsObject(consumableClassRAMV7) && consumableClassRAMV7.HasKey(classKey) ? consumableClassRAMV7[classKey] : ""
    for _,rule in pickupOptRulesV12
    {
        if (rule.actionOnlyV678)
            continue
        if (PickupOptRuleMatchV12(rule,q,flags,info.name,info.stats,baseName,h,cls))
            return true
    }
    return false
}
PickupOptReadV12(h,unit,cls,q,data,flags,nameOnlyV740:=false,forceStatsV766:=false)
{
    global pickupOptCacheV12,pickupOptJobV12,pickupOptRulesV12,pickupOptRevisionV12,pickupExcludeRulesV490,pickupNoSigRulesV490,townStoreRulesV628
    static lastPrune := 0
    if (!IsObject(pickupOptCacheV12))
        pickupOptCacheV12 := {}
    pid := DllCall("GetProcessId","Ptr",h,"UInt")
    uid := D2ReadU32(h,unit+0x0C),seed := D2ReadU32(h,data+0x14)
    if (!pid || !uid || D2ReadU32(h,unit)!=4 || D2ReadU32(h,unit+0x04)!=cls || D2ReadU32(h,unit+0x14)!=data)
        return false
    key := pid . "|" . unit . "|" . uid . "|" . data . "|" . seed . "|" . q . "|" . flags . "|" . pickupOptRevisionV12
    if (nameOnlyV740 && pickupOptCacheV12.HasKey(key) && pickupOptCacheV12[key].ok && A_TickCount-pickupOptCacheV12[key].tick<60000)
        return pickupOptCacheV12[key]
    if (nameOnlyV740)
        key .= "|NAME"
    if (pickupOptCacheV12.HasKey(key))
    {
        info := pickupOptCacheV12[key]
        if (A_TickCount-info.tick < (info.ok ? 60000 : 10000))
            return info
        pickupOptCacheV12.Delete(key)
    }
    if (A_TickCount-lastPrune>5000)
    {
        expired := []
        for cacheKey,entry in pickupOptCacheV12
            if (A_TickCount-entry.tick>60000)
                expired.Push(cacheKey)
        for _,cacheKey in expired
            pickupOptCacheV12.Delete(cacheKey)
        lastPrune := A_TickCount
    }
    if (RemoteThreadBusyV740(pid) || PickupOptPidPendingV655(pid))
        return false
    if (IsObject(pickupOptJobV12))
        return false
    needsStats := false
    for _,ruleSet in [pickupOptRulesV12,pickupExcludeRulesV490,pickupNoSigRulesV490,townStoreRulesV628]
        for _,rule in ruleSet
            if (rule.stats.Length() && (!rule.qualities.Count() || rule.qualities.HasKey(q+0)) && (!rule.eth || (flags & 0x00400000)))
                needsStats := true
        if (forceStatsV766)
        needsStats := true
    else if (nameOnlyV740)
        needsStats := false
    job := PickupOptStartV12(pid,unit,cls,q,data,uid,seed,needsStats)
    if (!IsObject(job))
    {
        pickupOptCacheV12[key] := {ok:false,tick:A_TickCount,pid:pid,uid:uid}
        DebugTraceWrite("pickup","D2MX_READ_FAIL uid=" . uid . " class=" . cls . " reason=GAME_FUNCTION_OR_REMOTE_CALL_NOT_READY")
        return false
    }
    job.key := key,job.pid := pid,job.uid := uid,job.cls := cls,job.data := data,job.unit := unit,job.seed := seed
    job.tick := A_TickCount,job.timedOut := false
    pickupOptJobV12 := job
    return false
}

PickupOptPendingV12()
{
    global pickupOptJobV12
    PickupOptPollV12()
    return IsObject(pickupOptJobV12) && !pickupOptJobV12.timedOut
}

PickupOptRetiredPollV655()
{
    global pickupOptRetiredV655
    if (!IsObject(pickupOptRetiredV655))
        return
    for index,job in pickupOptRetiredV655.Clone()
    {
        if (DllCall("WaitForSingleObject","Ptr",job.th,"UInt",0)!=0)
            continue
        DllCall("VirtualFreeEx","Ptr",job.hp,"Ptr",job.remote,"UPtr",0,"UInt",0x8000)
        DllCall("CloseHandle","Ptr",job.th),DllCall("CloseHandle","Ptr",job.hp)
        pickupOptRetiredV655.Delete(index)
    }
    if (!pickupOptRetiredV655.Count())
        SetTimer, PickupOptRetiredTimerV655, Off
}

PickupOptRetiredTimerV655:
PickupOptRetiredPollV655()
return

PickupOptPidPendingV655(pid)
{
    global pickupOptRetiredV655
    PickupOptRetiredPollV655()
    for _,job in pickupOptRetiredV655
        if (job.pid=pid)
            return true
    return false
}

PickupOptPollV12()
{
    global pickupOptJobV12,pickupOptCacheV12,pickupOptRetiredV655
    static busy := false
    if (busy || !IsObject(pickupOptJobV12))
        return
    busy := true
    try
    {
        job := pickupOptJobV12
        if (DllCall("WaitForSingleObject","Ptr",job.th,"UInt",0)!=0)
        {
            if (!job.timedOut && A_TickCount-job.tick>2500)
            {
                job.timedOut := true
                if (!IsObject(pickupOptRetiredV655))
                    pickupOptRetiredV655 := {}
                pickupOptRetiredV655[job.pid . "|" . job.th] := job
                pickupOptCacheV12[job.key] := {ok:false,pid:job.pid,uid:job.uid,tick:A_TickCount}
                pickupOptJobV12 := false
                SetTimer, PickupOptRetiredTimerV655, 500
                FonInfoPushV385("Đọc tên item quá hạn; vẫn theo dõi lệnh cũ, không chặn cửa sổ game khác.")
                DebugTraceWrite("pickup","D2MX_READ_TIMEOUT uid=" . job.uid . " next=PER_PID_QUARANTINE_UNTIL_THREAD_END")
            }
            return
        }
        exitCode := 0,name := "",stats := ""
        success := DllCall("GetExitCodeThread","Ptr",job.th,"UInt*",exitCode) && exitCode=1
        identityOK := D2ReadU32(job.hp,job.unit)=4 && D2ReadU32(job.hp,job.unit+0x0C)=job.uid
            && D2ReadU32(job.hp,job.unit+0x14)=job.data && D2ReadU32(job.hp,job.data+0x14)=job.seed
        if (success && identityOK)
        {
            name := PickupOptReadWideV12(job.hp,job.name,512)
            if (job.needsStats)
                stats := PickupOptReadWideV12(job.hp,job.stats,4096)
            name := PickupOptCleanTextV12(name),stats := PickupOptCleanTextV12(stats,true)
        }
        info := {ok:success && identityOK && name!="",name:name,stats:stats,pid:job.pid,uid:job.uid,tick:A_TickCount,cls:job.cls}
        if (!IsObject(pickupOptCacheV12))
            pickupOptCacheV12 := {}
        if (pickupOptCacheV12.Count()>=512)
        {
            oldestKey := "",oldestTick := A_TickCount
            for cacheKey,entry in pickupOptCacheV12
                if (entry.tick<=oldestTick)
                    oldestKey := cacheKey,oldestTick := entry.tick
            if (oldestKey!="")
                pickupOptCacheV12.Delete(oldestKey)
        }
        pickupOptCacheV12[job.key] := info
        DebugTraceWrite("pickup","D2MX_ITEM uid=" . job.uid . " class=" . job.cls . " ok=" . info.ok . " name=" . StrReplace(name,"`n"," | ") . " options=" . StrReplace(stats,"`n"," | "))
        DllCall("VirtualFreeEx","Ptr",job.hp,"Ptr",job.remote,"UPtr",0,"UInt",0x8000)
        DllCall("CloseHandle","Ptr",job.th),DllCall("CloseHandle","Ptr",job.hp)
        pickupOptJobV12 := false
    }
    finally
        busy := false
}

PickupOptReadWideV12(h,addr,size)
{
    VarSetCapacity(buffer,size+2,0),got := 0
    if (!DllCall("ReadProcessMemory","Ptr",h,"Ptr",addr,"Ptr",&buffer,"UPtr",size,"UPtr*",got) || got!=size)
        return ""
    return StrGet(&buffer,"UTF-16")
}

PickupOptEmitV12(ByRef code,ByRef offset,hex)
{
    Loop, Parse, hex, %A_Space%
        if (A_LoopField!="")
            NumPut("0x" . A_LoopField,code,offset++,"UChar")
}

PickupOptStartV12(pid,unit,cls,q,data,uid,seed,needsStats)
{
    client := D2GetModuleBaseV35(pid,"D2Client.dll")
    hp := client ? D2OpenProcess(pid) : 0
    if (!hp)
        return false
    player := D2ReadU32(hp,client+0x11BBFC)
    valid := D2ReadU16(hp,client)=0x5A4D && player && D2ReadU32(hp,player)=0
        && D2ReadU32(hp,unit)=4 && D2ReadU32(hp,unit+0x04)=cls
        && D2ReadU32(hp,unit+0x14)=data && D2ReadU32(hp,data)=q
    if (!valid || !D2ReadU8V18(hp,client+0x914F0) || (needsStats && !D2ReadU8V18(hp,client+0x560B0)))
    {
        DllCall("CloseHandle","Ptr",hp)
        return false
    }
    remote := DllCall("VirtualAllocEx","Ptr",hp,"Ptr",0,"UPtr",0x2000,"UInt",0x3000,"UInt",0x40,"Ptr")
    if (!remote || remote>0xFFFFDFFF)
    {
        if (remote)
            DllCall("VirtualFreeEx","Ptr",hp,"Ptr",remote,"UPtr",0,"UInt",0x8000)
        DllCall("CloseHandle","Ptr",hp)
        return false
    }
    nameAddr := remote+0x200,statsAddr := remote+0x400
    VarSetCapacity(code,256,0),o := 0,jumps := []
    PickupOptEmitV12(code,o,"53 57 8B 5C 24 0C 31 C0 83 3B 04 0F 85")
    jumps.Push(o),o+=4
    PickupOptEmitV12(code,o,"81 7B 0C"),NumPut(uid,code,o,"UInt"),o+=4
    PickupOptEmitV12(code,o,"0F 85"),jumps.Push(o),o+=4
    PickupOptEmitV12(code,o,"81 7B 14"),NumPut(data,code,o,"UInt"),o+=4
    PickupOptEmitV12(code,o,"0F 85"),jumps.Push(o),o+=4
    PickupOptEmitV12(code,o,"8B 53 14 81 7A 14"),NumPut(seed,code,o,"UInt"),o+=4
    PickupOptEmitV12(code,o,"0F 85"),jumps.Push(o),o+=4
    PickupOptEmitV12(code,o,"68 00 01 00 00 68"),NumPut(nameAddr,code,o,"UInt"),o+=4
    PickupOptEmitV12(code,o,"53 B8"),NumPut(client+0x914F0,code,o,"UInt"),o+=4
    PickupOptEmitV12(code,o,"FF D0")
    if (needsStats)
    {
        PickupOptEmitV12(code,o,"31 C0 81 7B 0C"),NumPut(uid,code,o,"UInt"),o+=4
        PickupOptEmitV12(code,o,"0F 85"),jumps.Push(o),o+=4
        PickupOptEmitV12(code,o,"81 7B 14"),NumPut(data,code,o,"UInt"),o+=4
        PickupOptEmitV12(code,o,"0F 85"),jumps.Push(o),o+=4
        PickupOptEmitV12(code,o,"BF"),NumPut(statsAddr,code,o,"UInt"),o+=4
        PickupOptEmitV12(code,o,"6A 00 6A 01 53 B8"),NumPut(client+0x560B0,code,o,"UInt"),o+=4
        PickupOptEmitV12(code,o,"FF D0")
    }
    PickupOptEmitV12(code,o,"B8 01 00 00 00")
    endOffset := o
    PickupOptEmitV12(code,o,"5F 5B C2 04 00")
    for _,jump in jumps
        NumPut(endOffset-(jump+4),code,jump,"Int")
    written := 0
    if (!DllCall("WriteProcessMemory","Ptr",hp,"Ptr",remote,"Ptr",&code,"UPtr",o,"UPtr*",written) || written!=o)
    {
        DllCall("VirtualFreeEx","Ptr",hp,"Ptr",remote,"UPtr",0,"UInt",0x8000)
        DllCall("CloseHandle","Ptr",hp)
        return false
    }
    DllCall("FlushInstructionCache","Ptr",hp,"Ptr",remote,"UPtr",o)
    th := DllCall("CreateRemoteThread","Ptr",hp,"Ptr",0,"UPtr",0,"Ptr",remote,"Ptr",unit,"UInt",0,"Ptr",0,"Ptr")
    if (!th)
    {
        DllCall("VirtualFreeEx","Ptr",hp,"Ptr",remote,"UPtr",0,"UInt",0x8000)
        DllCall("CloseHandle","Ptr",hp)
        return false
    }
    return {hp:hp,remote:remote,th:th,name:nameAddr,stats:statsAddr,needsStats:needsStats}
}

PickupOptCloseV12()
{
    global pickupOptJobV12
    if (!IsObject(pickupOptJobV12))
        return
    job := pickupOptJobV12
    if (DllCall("WaitForSingleObject","Ptr",job.th,"UInt",0)=0)
        DllCall("VirtualFreeEx","Ptr",job.hp,"Ptr",job.remote,"UPtr",0,"UInt",0x8000)
    DllCall("CloseHandle","Ptr",job.th),DllCall("CloseHandle","Ptr",job.hp)
    pickupOptJobV12 := false
}

PickupColorHexV14(name)
{
    colors := {"red":"FF3030","green":"35D06F","blue":"5599FF","yellow":"FFFF00","gold":"FFD700","white":"FFFFFF","black":"000000","orange":"FFA500","purple":"BB77FF","grey":"AAAAAA","gray":"AAAAAA","tan":"D2B48C","pink":"FF88CC","darkgreen":"008000"}
    name := Trim(name)
    StringLower, name, name
    return colors.HasKey(name) ? colors[name] : ""
}

PickupColorStripV14(line,ByRef color)
{
    color := "",rest := line,out := ""
    while (pos := RegExMatch(rest,"i)(?:\[\s*(red|green|blue|yellow|gold|white|black|orange|purple|grey|gray|tan|pink|darkgreen)\s*\]|\{\s*(red|green|blue|yellow|gold|white|black|orange|purple|grey|gray|tan|pink|darkgreen)\s*\})",m))
    {
        out .= SubStr(rest,1,pos-1),color := PickupColorHexV14(m1!="" ? m1 : m2)
        rest := SubStr(rest,pos+StrLen(m))
    }
    return Trim(out . rest)
}


PickupAlertGroupMatchV14(group,q,tier,setOK,name)
{
    if (group="UNIQUE")
        return q=7 && UniqueKnownTierV4(tier)
    if (UniqueKnownTierV4(group))
        return q=7 && tier=group
    if (group="SET_XANH")
        return q=5 && setOK
    if (name="")
        return false
    
    if (SubStr(group,1,5)="NAME:")
    {
        Loop, Parse, name, `n, `r
            if (PickupNameNormalizeV8(A_LoopField)=SubStr(group,6))
                return true
        return false
    }
    if (SubStr(group,1,7)="FILTER:")
    {
        patterns := PickupCatalogPatternsV9(),filter := SubStr(group,8)
        return patterns.HasKey(filter) && RegExMatch(name,"im)" . patterns[filter])
    }
    baseGroup := ConsumableKnownNameV7(name)
    return group=baseGroup || group=PickupNamedSubtypeV8(name,baseGroup)
}

PickupAlertMatchV14(h,u,cls,q,data,tier,ByRef color,ByRef label)
{
    global pickupAllow,pickupListLoaded,pickupAutoGroupsV7,pickupColorsV14,pickupExactAlertsV14,pickupOptRulesV12,consumableClassRAMV7,pickupExcludeClassesV329
    if (IsObject(pickupExcludeClassesV329) && pickupExcludeClassesV329.HasKey(cls+0))
        return false
    color := "35D06F",label := "ITEM",matched := false,explicitColor := "",exactAlertV610 := false,customLabelV610 := ""
    rareTierV610 := q=7 && (tier="SSU" || tier="SSSU")
    if (!pickupListLoaded)
        PickupReloadRAMV97()
    if (!IsObject(pickupAutoGroupsV7))
        UniquePickupReloadRAMV1()
    key := (cls+0) . "|" . Format("{:02X}",q)
    if (pickupAllow.HasKey(key))
        matched := true
    idx := D2ReadU32(h,data+0x28)
    for _,exactKey in [RareWarningRuleKeyV29(cls,q,-1),RareWarningRuleKeyV29(cls,q,idx)]
    {
        if (!pickupExactAlertsV14.HasKey(exactKey))
            continue
        exact := pickupExactAlertsV14[exactKey],matched := true,exactAlertV610 := true
        if (exact.label!="")
            customLabelV610 := exact.label
        if (exact.color!="")
            explicitColor := exact.color
    }
    ConsumablePickupGroupV7(h,cls)
    pid := DllCall("GetProcessId","Ptr",h,"UInt"),classKey := pid . "|" . cls
    baseName := IsObject(consumableClassRAMV7) && consumableClassRAMV7.HasKey(classKey) ? consumableClassRAMV7[classKey] : ""
    flags := D2ReadU32(h,data+0x18),info := false
    PickupOptPollV12()
    if (pickupOptRulesV12.Length() || IsObject(pickupAutoGroupsV7) && pickupAutoGroupsV7.Count())
        info := PickupOptReadV12(h,u,cls,q,data,flags)
    name := IsObject(info) && info.ok ? info.name : baseName
    setOK := q=5 ? SetPickupVerifiedV4(h,cls,data) : false
    for group,_ in pickupAutoGroupsV7
    {
        if (!PickupAlertGroupMatchV14(group,q,tier,setOK,name . "`n" . baseName))
            continue
        matched := true
        if (pickupColorsV14.HasKey(group) && explicitColor="")
            color := pickupColorsV14[group]
    }
    if (IsObject(info) && info.ok)
    {
        for _,rule in pickupOptRulesV12
        {
            if (rule.actionOnlyV678)
                continue
            if (!PickupOptRuleMatchV12(rule,q,flags,info.name,info.stats,baseName,h,cls))
                continue
            matched := true
            if (rule.color!="")
                explicitColor := rule.color
        }
    }
    if (!matched)
        return false
    if (exactAlertV610)
        color := "FF3030"
    if (explicitColor!="")
        color := explicitColor
    if (rareTierV610)
        color := "FF3030"
    if (name!="")
    {
        displayLinesV14 := StrSplit(RegExReplace(name,Chr(255) . "c.",""),"`n")
        display := displayLinesV14[1]
        label := Trim(display," `t`r")
    }
    if (customLabelV610!="")
        label := customLabelV610
    if (q=7)
        label := "[" . (UniqueKnownTierV4(tier) ? tier : "UNIQUE ?") . "] " . (label="ITEM" ? "" : label)
    else if (exactAlertV610 && label="ITEM")
        label := "Vật phẩm hiếm"
    return true
}


BossPriorityTextV221()
{
    global bossPriorityClassesV221
    return StrReplace(bossPriorityClassesV221,",","`r`n")
}

MonsterLockEligibleV308(classId)
{
    return classId>=0 && BossPriorityHasV221(classId) && !MonsterClassExcludedV11(classId)
}

BossPriorityHasV221(classId)
{
    global bossPriorityIdsV221
    return IsObject(bossPriorityIdsV221) && bossPriorityIdsV221.HasKey(classId+0)
}

BossPriorityNormalizeV221(text,ByRef normalized,ByRef ids)
{
    normalized := "",ids := {}
    for _,token in StrSplit(RegExReplace(Trim(text),"[,;\s]+",","),",")
    {
        if (token="")
            continue
        if (!RegExMatch(token,"^\d+$") || StrLen(token)>10 || token+0>4294967295)
            return false
        id := token+0
        if (ids.HasKey(id))
            continue
        ids[id] := true,normalized .= (normalized="" ? "" : ",") . id
    }
    return true
}

BossPrioritySaveV221(profile:="")
{
    global ConfigFile,currentProfile,bossPriorityClassesV221
    profile := profile="" ? currentProfile : profile
    section := ProfileSection(profile)
    try IniWrite, %bossPriorityClassesV221%, % ProfileConfigPathV364(section), %section%, BossPriorityClasses
    return !ErrorLevel
}

BossPriorityLoadV221(profile)
{
    global ConfigFile,bossPriorityClassesV221,bossPriorityIdsV221
    section := ProfileSection(profile)
    IniRead, text, % ProfileConfigPathV364(section), %section%, BossPriorityClasses, %A_Space%
    if (!BossPriorityNormalizeV221(text,normalized,ids))
        normalized := "",ids := {}
    bossPriorityClassesV221 := normalized,bossPriorityIdsV221 := ids
    GuiControl,, BossPriorityListV221, % BossPriorityTextV221() . "`r`n"
}

BossPriorityCommitV221(text)
{
    global bossPriorityClassesV221,bossPriorityIdsV221
    if (!BossPriorityNormalizeV221(text,normalized,ids))
    {
        MsgBox, 48, Lỗi, Class ID boss chỉ nhập số, mỗi ID một dòng.
        return false
    }
    oldList := bossPriorityClassesV221,oldIds := bossPriorityIdsV221
    bossPriorityClassesV221 := normalized,bossPriorityIdsV221 := ids
    if (!BossPrioritySaveV221())
    {
        bossPriorityClassesV221 := oldList,bossPriorityIdsV221 := oldIds
        MsgBox, 48, Lỗi, Không lưu được danh sách Boss ưu tiên.
        return false
    }
    GuiControl,, BossPriorityListV221, % BossPriorityTextV221() . "`r`n"
    return true
}


BossPriorityGetNearestV221(fromGuiV222 := true)
{
    pid := fromGuiV222 ? CoordDisplayGamePidV1() : D2GetActiveGamePidV95(),base := pid ? D2GetModuleBaseV35(pid,"D2Client.dll") : 0
    h := base ? DllCall("OpenProcess","UInt",0x0410,"Int",false,"UInt",pid,"Ptr") : 0
    if (!h)
        return false
    try
    {
        player := D2ReadU32(h,base+0x11BBFC),path := player ? D2ReadU32(h,player+0x2C) : 0
        if (!MonsterBossProbeReadV1(h,path,0x20,pb))
            return false
        target := PetBossHoveredUnitV223(h,base,pid)
        if (!IsObject(target) || !MonsterBossProbeReadV1(h,target.unit,0x30,ub)
            || NumGet(ub,0,"UInt")!=1 || NumGet(ub,12,"UInt")!=target.uid
            || NumGet(ub,16,"UInt")=0 || NumGet(ub,16,"UInt")=12)
        {
            ToolTipInfoV386("GET BOSS: hãy đặt chuột lên boss sống rồi bấm phím GET.")
            SetTimer, RemoveToolTip, -2500
            return false
        }
        cls := NumGet(ub,4,"UInt")
        if (MonsterClassExcludedV11(cls))
        {
            ToolTipInfoV386("Class " . cls . " đang trong Pet loại trừ. Xóa khỏi loại trừ trước khi thêm Boss ưu tiên.")
            SetTimer, RemoveToolTip, -3000
            return false
        }
        GuiControlGet, edited, 1:, BossPriorityListV221
        if (!BossPriorityCommitV221(edited . "`r`n" . cls))
            return false
        ToolTipInfoV386("Đã thêm Boss ưu tiên: CLASS " . cls . " (con đang dưới chuột).")
        SetTimer, RemoveToolTip, -2500
        return true
    }
    finally
        DllCall("CloseHandle","Ptr",h)
}


PetBossFocusV222(wParam,lParam,msg,hwnd)
{
    global PetExcludeHwndV16,BossPriorityHwndV222,petBossGetTargetV222,pickupGetTargetV638
    if (((wParam >> 16) & 0xFFFF)!=0x100 || !lParam)
        return
    GuiControlGet, rightEditV638, 1:Hwnd, PickupEditorInputV8
    GuiControlGet, keepEditV638, 1:Hwnd, PickupNoSigEditorV490
    pickupGetTargetV638 := lParam=rightEditV638 ? "PickupEditorInputV8" : (lParam=keepEditV638 ? "PickupNoSigEditorV490" : "")
    if (lParam=PetExcludeHwndV16)
        petBossGetTargetV222 := "PET"
    else if (lParam=BossPriorityHwndV222)
        petBossGetTargetV222 := "BOSS"
}


PetBossHoveredUnitV223(h,base,pid)
{
    MouseGetPos,,,hoverWin
    WinGet, hoverPid, PID, ahk_id %hoverWin%
    if (!pid || hoverPid!=pid || D2GetActiveGamePidV95()!=pid)
        return false
    u := D2ReadU32(h,base+0x11B834)
    if (!u || !MonsterBossProbeReadV1(h,u,0x30,ub))
        return false
    uid := NumGet(ub,12,"UInt"),mode := NumGet(ub,16,"UInt")
    if (NumGet(ub,0,"UInt")!=1 || !uid || mode=0 || mode=12)
        return false
    return {unit:u,uid:uid}
}

SigReusableItemV225(item)
{
    return IsObject(item) && item.q=2 && (item.cls=1204 || item.cls=1734 || item.cls=1735)
}


SetNoSigParseV227(line)
{
    line := PickupColorStripV14(Trim(line," `t`r`n" . Chr(0xFEFF)),ignoredColor)
    if (SubStr(line,1,1)="#")
        return false
    line := Trim(RegExReplace(line,"\s+#.*$",""))
    if (!RegExMatch(line,"i)^(?:SET(?:[ _]+XANH)?|ITEMDATA\s*=\s*05\s*\|\s*TIER\s*=\s*(?:SET_XANH|SET))(?=\s|[\[{]|$)(.*)$",m))
        return false
    rest := Trim(m1),names := [],seen := {}
    while (rest!="")
    {
        if (!RegExMatch(rest,"^(?:\[([^\[\]{}]*)\]|\{([^\[\]{}]*)\})\s*",part))
            return false
        value := Trim(part1!="" ? part1 : part2)
        Loop, Parse, value, |
        {
            name := Trim(RegExReplace(A_LoopField,"\s+"," "))
            StringLower, key, name
            if (name!="" && !seen.HasKey(key))
                names.Push(name),seen[key] := true
        }
        rest := SubStr(rest,StrLen(part)+1)
    }
    return {names:names}
}

SetNoSigLoadV227(ctx)
{
    if (!RareWarningReadTextV35(UniquePickupFileV3(),raw))
        return false
    raw := PickupCanonicalAllowTextV491(raw)
    if (RareWarningReadTextV35(PickupNoSigFileV490(),keepText,true))
        raw .= "`r`n" . keepText
    names := [],seen := {}
    Loop, Parse, raw, `n, `r
    {
        line := Trim(A_LoopField," `t`r`n" . Chr(0xFEFF))
        if (line="" || SubStr(line,1,1)="#")
            continue
        parsed := SetNoSigParseV227(line)
        if (!IsObject(parsed))
        {
            if (RegExMatch(line,"i)^(?:SET(?:[ _]+XANH)?|ITEMDATA\s*=\s*05\s*\|\s*TIER\s*=\s*(?:SET_XANH|SET))(?=\s|[\[{]|$)"))
            {
                SigLogV147("SET_KEEP_RULE_ERROR line=" . line)
                return false
            }
            continue
        }
        for _,name in parsed.names
        {
            StringLower, key, name
            if (!seen.HasKey(key))
                names.Push(name),seen[key] := true
        }
    }
    ctx.setNoSigNamesV227 := names,ctx.setNameCacheV227 := {},ctx.setKeepLoggedV227 := {}
    for _,name in names
        SigLogV147("SET_KEEP_RULE set=" . name)
    return true
}

SigSetProtectedV227(ctx,item)
{
    if (!IsObject(ctx.setNoSigNamesV227) || !ctx.setNoSigNamesV227.Length())
        return false
    name := SigSetNameV227(ctx,item),keep := name="",matched := ""
    if (name!="")
        for _,wanted in ctx.setNoSigNamesV227
            if (InStr(name,wanted,false))
            {
                keep := true,matched := wanted
                break
            }
    if (ctx.setKeepLoggedV227.HasKey(item.uid))
        return ctx.setKeepLoggedV227[item.uid]
    SigLogV147("SET_MEMBERSHIP uid=" . item.uid . " class=" . item.cls . " set=" . name
        . " no_sig=" . keep . " rule=" . matched . " reason=" . (name="" ? "UNKNOWN_SET_KEEP_SAFE" : keep ? "PROTECTED_SET" : "OTHER_SET"))
    ctx.setKeepLoggedV227[item.uid] := keep
    return keep
}

SigSetNameV227(ctx,item)
{
    global sigSetNameJobV227
    if (!item.unit || D2ReadU32(ctx.h,item.unit)!=4 || D2ReadU32(ctx.h,item.unit+0x0C)!=item.uid
        || D2ReadU32(ctx.h,item.unit+0x14)!=item.data || !SetPickupVerifiedV4(ctx.h,item.cls,item.data))
        return ""
    common := D2GetModuleBaseV35(ctx.pid,"D2Common.dll"),sgpt := D2ReadU32(ctx.h,common+0x99E1C)
    itemTable := D2ReadU32(ctx.h,sgpt+0xC18),idx := D2ReadU32(ctx.h,item.data+0x28)
    record := itemTable+idx*0x1B8,setId := D2ReadU16(ctx.h,record+0x2C)
    sets := D2ReadU32(ctx.h,sgpt+0xC0C),count := D2ReadU32(ctx.h,sgpt+0xC10)
    if (!sets || count<1 || count>32767 || setId>=count)
        return ""
    setRecord := sets+setId*0x128
    members := D2ReadU32(ctx.h,setRecord+0x0C),linked := false
    if (D2ReadU16(ctx.h,setRecord)!=setId || members<1 || members>6)
        return ""
    Loop, %members%
        if (D2ReadU32(ctx.h,setRecord+0x110+(A_Index-1)*4)=record)
            linked := true
    stringId := D2ReadU16(ctx.h,setRecord+2)
    if (!linked || !stringId || stringId=65535)
        return ""
    key := setRecord . "|" . stringId
    if (ctx.setNameCacheV227.HasKey(key))
        return ctx.setNameCacheV227[key]
    if (IsObject(sigSetNameJobV227))
    {
        if (DllCall("WaitForSingleObject","Ptr",sigSetNameJobV227.th,"UInt",0)!=0)
            SigFailV147("Đang đọc tên bộ Set; giữ đồ, chờ rồi SIG lại")
        DllCall("VirtualFreeEx","Ptr",sigSetNameJobV227.hp,"Ptr",sigSetNameJobV227.remote,"UPtr",0,"UInt",0x8000)
        DllCall("CloseHandle","Ptr",sigSetNameJobV227.th),DllCall("CloseHandle","Ptr",sigSetNameJobV227.hp)
        sigSetNameJobV227 := false
    }
    lang := D2GetModuleBaseV35(ctx.pid,"D2Lang.dll")
    client := D2GetModuleBaseV35(ctx.pid,"D2Client.dll")
    if (!lang || !client || !NativeRightClickBuildV9(ctx.h,client))
        return ""
    job := ConsumableNameStartV7(ctx.pid,lang+0x9450,stringId)
    if (!IsObject(job))
        return ""
    sigSetNameJobV227 := job,start := A_TickCount
    while (DllCall("WaitForSingleObject","Ptr",job.th,"UInt",0)!=0)
    {
        SigCheckV147(ctx)
        if (A_TickCount-start>=4000)
            SigFailV147("Chưa đọc được tên bộ Set; giữ đồ, dừng SIG")
        Sleep, 25
    }
    name := "",ptr := 0
    if (DllCall("GetExitCodeThread","Ptr",job.th,"UInt*",ptr) && ptr)
        name := PickupOptCleanTextV12(PickupOptReadWideV12(job.hp,ptr,512))
    DllCall("VirtualFreeEx","Ptr",job.hp,"Ptr",job.remote,"UPtr",0,"UInt",0x8000)
    DllCall("CloseHandle","Ptr",job.th),DllCall("CloseHandle","Ptr",job.hp)
    sigSetNameJobV227 := false
    name := Trim(RegExReplace(name,"\s+"," "))
    ctx.setNameCacheV227[key] := name
    return name
}

ScosGoldReadV229(h,player)
{
    stats := D2ReadU32(h,player+0x5C)
    if (!stats || !MonsterBossProbeReadV1(h,stats,0x60,sb))
        return false
    for _,off in [0x24,0x48]
    {
        root := NumGet(sb,off,"UInt"),count := NumGet(sb,off+4,"UShort"),cap := NumGet(sb,off+6,"UShort")
        if (!root || count<1 || count>512 || cap<count || !MonsterBossProbeReadV1(h,root,count*8,ab))
            continue
        gold := 0,bank := 0,level := 0,seen := {},duplicate := false
        Loop, %count%
        {
            at := (A_Index-1)*8,layer := NumGet(ab,at,"UShort"),id := NumGet(ab,at+2,"UShort")
            if (layer || (id!=12 && id!=14 && id!=15))
                continue
            if (seen.HasKey(id))
                duplicate := true
            seen[id] := true,value := NumGet(ab,at+4,"UInt")
            if (id=12)
                level := value
            else if (id=14)
                gold := value
            else
                bank := value
        }
        if (!duplicate && level>=1 && level<=150 && gold<=2147483647 && bank<=2147483647)
            return {gold:gold,bank:bank,limit:2500000}
    }
    return false
}


ScosGoldBeforeWpV229(r,ctx,player,ByRef pb,px,py,independentStash := false)
{
    global xRunning,zRunning,gameItemActionOwner,packetWatchArmedV1,pickupTimerBusy
    if (r.goldDoneV229)
        return false
    if (!r.stashRouteDoneV230)
        return true
    if (r.phase!="WP")
        throw Exception("Chưa hoàn tất cất tiền trước WP")
    if (xRunning || zRunning || gameItemActionOwner!="" || pickupTimerBusy || packetWatchArmedV1
        || !AutoMonsterPacketCleanupV1())
        return true
    SigCheckV147(ctx)
    ctx.player := player,ctx.inv := D2ReadU32(ctx.h,player+0x60)
    TownStorePrepareV629(r,ctx,player)
    mode := D2ReadU32(ctx.h,player+0x10)
    if (mode=0 || mode=17)
        throw Exception("Nhân vật đã chết khi cất tiền")
    gold := ScosGoldReadV229(ctx.h,player)
    if (!IsObject(gold))
    {
        PortalLogWriteV66("SCOS_GOLD_ERROR reason=GOLD_STATS_UNREADABLE next=STOP_BEFORE_WP")
        throw Exception("Không đọc được tiền trong rương/người; chưa vào WP")
    }
    if (r.goldStepV229="CLOSE")
    {
        if (A_TickCount-r.goldAtV229<500)
            return true
        r.goldDoneV229 := true
        return false
    }
    if (r.goldStepV229="VERIFY")
    {
        received := gold.bank-r.goldBankV229,spent := r.goldWalletV229-gold.gold
        PortalLogWriteV66("SCOS_GOLD_VERIFY amount=" . r.goldAmountV229 . " wallet=" . gold.gold
            . " bank=" . gold.bank . " bank_delta=" . received . " wallet_delta=" . spent
            . " elapsed_ms=" . (A_TickCount-r.goldAtV229),"SCOS_GOLD_VERIFY",500)
        if (received=r.goldAmountV229 && spent=received)
        {
            PortalLogWriteV66("SCOS_GOLD_CONFIRMED amount=" . received . " wallet=" . gold.gold
                . " bank=" . gold.bank . " limit=" . gold.limit . " next=CLOSE_STASH_THEN_WP")
            ScosGoldCloseV229(r,ctx)
            return true
        }
        if (A_TickCount-r.goldAtV229>=4000)
        {
            PortalLogWriteV66("SCOS_GOLD_ERROR reason=DEPOSIT_UNCONFIRMED amount=" . r.goldAmountV229
                . " wallet=" . gold.gold . " bank=" . gold.bank . " bank_delta=" . received . " wallet_delta=" . spent)
            throw Exception("Chưa xác nhận cất tiền; dừng trước WP, không gửi lặp")
        }
        return true
    }
    if (!r.goldStepV229 && (gold.bank>=gold.limit || gold.gold=0) && TownStorePendingV628(ctx,player,r))
    {
        if (!TownStoreRunV628(r,ctx,player))
            return true
        r.goldDoneV229 := true
        return false
    }
    if ((gold.bank>=gold.limit || gold.gold=0)
        && (!TownStorePendingV628(ctx,player,r) || r.goldStepV229="OPEN_WAIT"))
    {
        PortalLogWriteV66("SCOS_GOLD_SKIP reason=" . (gold.bank>=gold.limit ? "STASH_FULL" : "NO_CARRIED_GOLD")
            . " wallet=" . gold.gold . " bank=" . gold.bank . " limit=" . gold.limit)
        if (r.goldStepV229="OPEN_WAIT")
        {
            ScosGoldCloseV229(r,ctx)
            return true
        }
        r.goldDoneV229 := true
        return false
    }
    stash := CycObjectV42(ctx.h,pb,267)
    if (!IsObject(stash))
        throw Exception("Không thấy rương cất tiền gần WP")
    if (!r.goldStartedV229)
    {
        r.goldStartedV229 := true
        PortalLogWriteV66("SCOS_GOLD_CHECK wallet=" . gold.gold . " bank=" . gold.bank . " limit=" . gold.limit
            . " stash_uid=" . stash.uid . " stash_xy=" . stash.x . "," . stash.y . " next=DEPOSIT_BEFORE_WP")
    }
    distance := Sqrt((px-stash.x)**2+(py-stash.y)**2)
    if (distance>20)
    {
        if (r.goldStepV229="OPEN_WAIT")
            throw Exception("Rời xa rương trong khi cất tiền; chưa vào WP")
        throw Exception("Chưa ở gần rương sau lộ trình; dừng để tránh đi tắt")
    }
    if (mode!=1 && mode!=5)
        return true
    inv := D2ReadU32(ctx.h,player+0x60),cursor := inv ? PickupCursorV4(ctx.h,inv) : false
    if (!IsObject(cursor) || cursor.unit)
        throw Exception("Có vật trên chuột; dừng bước cất tiền")
    if (r.goldStepV229="OPEN_WAIT")
    {
        if (stash.uid!=r.goldStashV229)
            throw Exception("Rương cất tiền đã thay đổi")
        if (A_TickCount-r.goldAtV229<750)
            return true
        amount := Min(gold.gold,gold.limit-gold.bank)
        bytes := ScosGoldPacketV231(amount)
        r.goldWalletV229 := gold.gold,r.goldBankV229 := gold.bank,r.goldAmountV229 := amount
        PortalLogWriteV66("SCOS_GOLD_SEND amount=" . amount . " wallet=" . gold.gold . " bank=" . gold.bank
            . " format=BUTTON_WORD_HIGH_WORD_LOW_WORD next=VERIFY_BALANCES")
        SigPacketV147(ctx,bytes)
        r.goldStepV229 := "VERIFY",r.goldAtV229 := A_TickCount
        return true
    }
    level := CoordLevelV14(ctx.h,NumGet(pb,0x1C,"UInt"))
    if (independentStash && (!BackgroundValidV63() || D2GetActiveGamePidV95()!=ctx.pid))
    {
        FarmGoldInfoV9(r,"Cất tiền: đang chờ nhận đúng cửa sổ game.")
        return true
    }
    opened := independentStash ? SigTownInteractStashV342(ctx.pid,level,stash)
        : SigTownPortalInteractV148(r.pid,level,stash,true)
    if (opened)
    {
        r.goldStashV229 := stash.uid,r.goldStepV229 := "OPEN_WAIT",r.goldAtV229 := A_TickCount
        PortalLogWriteV66("SCOS_GOLD_OPEN uid=" . stash.uid . " class=267 method=NATIVE_UNIT_INTERACT")
    }
    if (independentStash && !opened)
        FarmGoldInfoV9(r,"Cất tiền: chưa gửi được lệnh mở rương; giữ bước hiện tại.")
    return true
}

ScosGoldCloseV229(r,ctx)
{
    SigCheckV147(ctx)
    if (!TownStoreRunV628(r,ctx,ctx.player))
        return
    if (!r.storeUiClosedV633 && !GameTargetKeyV63("{Esc}"))
        throw Exception("Chưa đóng được rương sau cất tiền")
    r.goldStepV229 := "CLOSE",r.goldAtV229 := A_TickCount
    PortalLogWriteV66("SCOS_GOLD_CLOSE next=" . (r.map="NAO" ? "NAO_USE_ITEM_AT_5138_5060" : "EXISTING_WP_ROUTE"))
}


ScosGoldPacketV231(amount)
{
    if (amount<1 || amount>2147483647 || amount!=Floor(amount))
        throw Exception("Số tiền cất không hợp lệ")
    high := (amount >> 16) & 0xFFFF,low := amount & 0xFFFF
    return [0x4F,0x14,0x00,high & 0xFF,(high >> 8) & 0xFF,low & 0xFF,(low >> 8) & 0xFF]
}

GameRoomHistoryLoadV252()
{
    global gameRoomHistoryV252,ConfigFile
    gameRoomHistoryV252 := []
    IniRead, count, %ConfigFile%, GameRoomHistory, Count, 0
    count := Min(10,Max(0,count+0))
    Loop, %count%
    {
        key := "Name" . A_Index
        IniRead, name, %ConfigFile%, GameRoomHistory, %key%, %A_Space%
        key := "Time" . A_Index
        IniRead, stamp, %ConfigFile%, GameRoomHistory, %key%, %A_Space%
        if (name!="" && !InStr(name,"|") && !InStr(name,"`n"))
            gameRoomHistoryV252.Push({name:name,stamp:stamp})
    }
}

GameRoomHistoryLatestV252()
{
    global gameRoomHistoryV252
    return IsObject(gameRoomHistoryV252) && gameRoomHistoryV252.Length() ? gameRoomHistoryV252[1].name : ""
}


GameRoomHistoryPickV252:
GuiControlGet, selectedRoomV252, 1:, GameRoomHistoryV252
for _,historyRoomV252 in gameRoomHistoryV252
    if (selectedRoomV252=historyRoomV252.name . "  -  " . historyRoomV252.stamp)
    {
        GuiControl, 1:, GameRoomNameV252, % historyRoomV252.name
        break
    }
return

GameRoomLiveNameV252(pid)
{
    base := D2GetModuleBaseV35(pid,"D2Client.dll"),h := base ? D2OpenProcess(pid) : 0
    if (!h)
        return ""
    try
    {
        player := D2ReadU32(h,base+0x11BBFC)
        path := player ? D2ReadU32(h,player+0x2C) : 0
        if (!path || !CoordLevelV14(h,D2ReadU32(h,path+0x1C)))
            return ""
        info := D2ReadU32(h,base+0x11B980)
        if (!info || !MonsterBossProbeReadV1(h,info+0x1B,24,buf))
            return ""
        length := 0
        Loop, 24
        {
            value := NumGet(buf,A_Index-1,"UChar")
            if (!value)
                break
            if (value<32 || value>126 || value=124)
                return ""
            length++
        }
        if (!length || length>=24 || D2ReadU32(h,base+0x11B980)!=info)
            return ""
        name := StrGet(&buf,length,"CP0")
        if (!MonsterBossProbeReadV1(h,info+0x1B,24,verify)
            || StrGet(&verify,length,"CP0")!=name || NumGet(verify,length,"UChar")!=0)
            return ""
        return name
    }
    finally
        DllCall("CloseHandle","Ptr",h)
}

GameRoomHistoryCaptureV252(pid,verifiedNameV1181 := "",captureReasonV1181 := "LIVE_GAME")
{
    global gameRoomHistoryV252,ConfigFile
    name := (verifiedNameV1181!="" ? verifiedNameV1181 : GameRoomLiveNameV252(pid))
    if (name="")
    {
        PortalLogWriteV66("GAME_ROOM_HISTORY_READ_FAILED previous=KEPT")
        return false
    }
    if (!IsObject(gameRoomHistoryV252))
        GameRoomHistoryLoadV252()
    if (gameRoomHistoryV252.Length() && gameRoomHistoryV252[1].name=name)
        return true
    FormatTime, stamp,, yyyy-MM-dd HH:mm:ss
    next := [{name:name,stamp:stamp}]
    for _,item in gameRoomHistoryV252
        if (item.name!=name && next.Length()<10)
            next.Push(item)
    gameRoomHistoryV252 := next
    count := next.Length()
    try IniWrite, %count%, %ConfigFile%, GameRoomHistory, Count
    for i,item in next
    {
        key := "Name" . i,value := item.name
        try IniWrite, %value%, %ConfigFile%, GameRoomHistory, %key%
        key := "Time" . i,value := item.stamp
        try IniWrite, %value%, %ConfigFile%, GameRoomHistory, %key%
    }
    GuiControl, 1:, GameRoomNameV252, %name%
    PortalLogWriteV66("GAME_ROOM_HISTORY_SAVED name=" . name . " trigger=" . captureReasonV1181 . " count=" . count)
    return true
}

GameRoomHistoryWatchTimerV1181:
GameRoomHistoryAutoCaptureV1181()
return

GameRoomHistoryAutoCaptureV1181()
{
    static observedPidV1181 := 0,observedNameV1181 := "",lastSavedAtV1181 := 0
    pid := D2GetActiveGamePidV95()
    if (!pid)
        pid := CoordDisplayGamePidV1()
    if (!pid)
    {
        observedPidV1181 := 0, observedNameV1181 := ""
        return false
    }
    ; The live name function validates the player and stable game name in memory.
    ; It fails harmlessly on loading screens: never erase previously saved history.
    name := GameRoomLiveNameV252(pid)
    if (name="")
        return false
    ; Save on first observed entry or immediately upon change; also retry failed INI writes.
    if (observedPidV1181!=pid || observedNameV1181!=name || !lastSavedAtV1181
        || A_TickCount-lastSavedAtV1181>=10000)
    {
        if (!GameRoomHistoryCaptureV252(pid,name,"GAME_ENTER"))
            return false
        observedPidV1181 := pid, observedNameV1181 := name
        lastSavedAtV1181 := A_TickCount
    }
    return true
}

PickupFixedPriorityV254(cls,q)
{
    if (cls=1204)
        return 1
    if (cls=1734 || cls=1735)
        return 2
    return 3
}

FarmPauseReleaseV256(reason)
{
    global farmMapPauseV52,farmLoadedMapV56,farmControlOwnerV186,mapWorkflowV185
    global mapRunResumeV210,coordRunSelectedV210,coordRouteV16,coordCastPendingV50
    global farmStopMoveV124,farmCubeSortOnceV253,scosEntryV162
    if (IsObject(scosEntryV162) && scosEntryV162.map="BO"
        && reason="LEFT_PAUSED_MAP")
    {
        farmMapPauseV52 := false,farmLoadedMapV56 := false
        PortalLogWriteV66("BO_PAUSE_CONTEXT_RELEASE reason=" . reason . " owner=KEPT entry=KEPT")
        return
    }
    farmMapPauseV52 := false,farmLoadedMapV56 := false,farmControlOwnerV186 := ""
    mapWorkflowV185 := false,mapRunResumeV210 := false,coordRunSelectedV210 := false
    coordRouteV16 := false,coordCastPendingV50 := false,farmStopMoveV124 := false
    farmCubeSortOnceV253 := false
    SetTimer, FarmStopMoveTimerV124, Off
    PortalLogWriteV66("FARM_PAUSE_RELEASE reason=" . reason . " buttons=UNLOCKED")
}


Farm130ButtonV257:
libRequestedTierV728 := 130
Gosub, LibSelectedButtonV290
return

Farm133ButtonV290:
libRequestedTierV728 := 133
Gosub, LibSelectedButtonV290
return

Farm136ButtonV290:
libRequestedTierV728 := 136
Gosub, LibSelectedButtonV290
return

Farm139ButtonV290:
libRequestedTierV728 := 139
Gosub, LibSelectedButtonV290
return

LibSelectedButtonV290:
; V2026 fix: tat ca 4 nut 130/133/136/139 dung DUY NHAT START chung.
; Khong kiem tra thanh/map 103/263-266 o day: MapControlActionV168 se
; tu doc map hien tai bang F-ON, nap INI va chay tu dong vang.
libRunningV728 := FarmControlRunningV186() || IsObject(farmMapPauseV52) || cainPausedV10 || farmUserPausedV2026
if (libRunningV728 && farmControlOwnerV186="LIB" && libRequestedTierV728=libScrollTierV290)
{
    FarmUserPauseToggleV2026("LIB")
    return
}
; Doi tier trong khi dang Farm LIB: dung phien cu truoc khi Start tier moi.
if (libRunningV728 && farmControlOwnerV186="LIB")
    FarmButtonStopV1()
libScrollTierV290 := libRequestedTierV728
; Khong tao mot cach chon diem Start thu hai theo selection cua ListBox.
; Duy nhat FarmStartRowV394() quyet dinh dong vang tai START chung.
libRunChoiceV281 := false
farm130ButtonDispatchV257 := true
try
    Gosub, MapControlButtonV168
finally
    farm130ButtonDispatchV257 := false
return

LibFarmLevelV292(level)
{
    return level>0 && level!=1 && level!=40 && level!=75 && level!=103 && level!=109
}

MapScrollFarmV269(mapName)
{
    return mapName="LIB"
}

Map130EntryArmV257(hwnd,mapName:="LIB")
{
    global scosEntryV162,pickupImageOn,packetWatchArmedV1,backgroundPidV63,libScrollTierV290,libAutoTicketV293,farmEntryGoldV315
    global mapRunResumeV210,coordRunSelectedV210,coordManualRowV59,coordPinnedYellowV136
    if (packetWatchArmedV1 || !BackgroundBindV63(hwnd))
        return false
    level := FarmCurrentLevelV143()
    if (level!=103 && !LibFarmLevelV292(level))
        return false
    ; Quay lai qua CONG CU sau hoi sinh: GIU map da khoa.
    ; Chi mo ve moi trong Map130EntryTick moi duoc xoa khoa map.
    mapRunResumeV210 := false,coordRunSelectedV210 := false
    coordManualRowV59 := 0,coordPinnedYellowV136 := 0
    scosEntryV162 := {map:mapName,pid:backgroundPidV63,until:A_TickCount+180000,phase:level=103 ? "WP" : "MAP",row:1,last:0,pickup:pickupImageOn,shiftX:5050,shiftY:5036}
    FarmSharedEntryOptionsV781(scosEntryV162)
    scosEntryV162.autoTicketV293 := true
    scosEntryV162.scrollTierV290 := libScrollTierV290
    scosEntryV162.scrollClassV290 := libScrollTierV290=133 ? 2389 : libScrollTierV290=136 ? 2390 : libScrollTierV290=139 ? 2391 : 2348
    PickupEnabledSetV71(false,true,false)
    SetTimer, ScosEntryTimerV162, 250
    FarmPickupSyncV57(0,0,-1,true)
    PortalLogWriteV66("MAP_STAGE1_START map=LIB destination=LIVE_MAP town=103 scroll_at=5050,5036")
    return true
}


Map130ScrollV257(ctx,inv,scrollClass)
{
    items := V9SnapshotAllItems({h:ctx.h,inv:inv,first:D2ReadU32(ctx.h,inv+0x10)})
    for uid,item in items
        if (item.cls=scrollClass
            && D2ReadU8V18(ctx.h,item.data)=2 && item.loc=0 && item.owner=inv
            && D2ReadU32(ctx.h,item.unit+0x10)!=3 && D2ReadU32(ctx.h,item.unit+0x10)!=5)
        {
            PortalLogWriteV66("MAP_SCROLL_FOUND map=LIB uid=" . uid . " class=" . item.cls . " itemdata=02 next=USE_ONCE")
            return uid
        }
    PortalLogWriteV66("MAP_SCROLL_WAIT map=LIB class=" . scrollClass . " reason=NO_SELECTED_SCROLL_IN_INVENTORY","scroll_wait_LIB",2000)
    return 0
}

Map130EntryTickV257(r,ctx,player,ByRef pb,level,px,py)
{
    global coordSavedV15,mapFarmStartPendingV170,scosEntryV162
    global libFarmPinnedMapV2026,lib263EntryV841
    if (LibFarmLevelV292(level))
    {
        MapEntryFirstBuffFinishV248(r,ctx,player,level,px,py)
        return
    }
    if (level!=103)
        return
    if (r.phase="WP")
    {
        if (!r.libTownRouteDoneV11)
        {
            if (FarmNoFightFlowV8(r,ctx,pb,103,"LIB_TOWN")!="DONE")
                return
            r.libTownRouteV11 := FarmRoutePointsV724().Clone()
            last := r.libTownRouteV11[r.libTownRouteV11.Length()]
            r.shiftX := last.x,r.shiftY := last.y
            FarmCommonRouteEndV3(r)
            r.libTownRouteDoneV11 := true
            return
        }
        if (r.ticketErrorHoldV769)
            return
        if (r.autoTicketV293 && !r.ticketDoneV293)
        {
            r.ticketDoneV293 := true
            PortalLogWriteV66("LIB_AUTO_TICKET_START tier=" . r.scrollTierV290 . " count=1")
            if (!Ticket130RunV265(1,(r.scrollTierV290-130)//3,r))
            {
                r.ticketErrorHoldV769 := true
                FarmErrorKeepV769("AUTO_TICKET_FAILED")
                ToolTipInfoV386("Tạo vé chưa hoàn tất; giữ phiên farm và vật phẩm, chờ xử lý lỗi.")
                SetTimer, RemoveToolTip, -6000
                return
            }
            if (!IsObject(scosEntryV162) || scosEntryV162!=r)
                return
            r.until := A_TickCount+180000
            return
        }
        r.phase := "SHIFT",r.last := 0
        PortalLogWriteV66("MAP130_TOWN_GOLD_DONE next=USE_ITEM_AT_LAST_SAVED_POINT waypoint=SKIPPED")
        return
    }
    if (r.phase="SHIFT")
    {
        if ((px-r.shiftX)**2+(py-r.shiftY)**2>4)
        {
            point := {x:r.shiftX,y:r.shiftY}
            FarmNoFightFlowV8(r,ctx,pb,103,"LIB_SCROLL_POINT",[point],point)
            return
        }
        FarmCommonRouteEndV3(r)
        inv := D2ReadU32(ctx.h,player+0x60)
        cursor := inv ? PickupCursorV4(ctx.h,inv) : false
        if (!IsObject(cursor) || cursor.unit)
            throw Exception("Đang có vật phẩm trên chuột")
        chosen := Map130ScrollV257(ctx,inv,r.scrollClassV290)
        if (!chosen)
            return
        ; Day moi la bat dau MO MAP MOI (scroll moi), khong phai hoi sinh ve cong cu.
        libFarmPinnedMapV2026 := false,lib263EntryV841 := false
        PortalLogWriteV66("LIB_FON_UNPIN reason=NEW_SCROLL_PORTAL tier=" . r.scrollTierV290)
        r.oldPortals := NaoPortalsV188(ctx,pb)
        bytes := [0x20],SigDwordV147(bytes,chosen),SigDwordV147(bytes,px),SigDwordV147(bytes,py)
        r.phase := "PORTAL_WAIT",r.openAt := A_TickCount
        SigPacketV147(ctx,bytes)
        PortalLogWriteV66("MAP_SCROLL_OPEN_PORTAL tier=" . r.scrollTierV290 . " uid=" . chosen . " xy=" . px . "," . py . " use_once=1")
        return
    }
    if (A_TickCount-r.openAt>15000)
        throw Exception("Không xác nhận được cổng vào map LIB")
    if (A_TickCount-r.openAt<500)
        return
    portals := NaoPortalsV188(ctx,pb),target := false,count := 0
    for uid,portal in portals
        if (!r.oldPortals.HasKey(uid) && (portal.x-r.shiftX)**2+(portal.y-r.shiftY)**2<=144)
            target := portal,count++
    if (count>1)
        throw Exception("Có nhiều cổng mới gần nhau - dừng để tránh vào nhầm")
    if (!IsObject(target))
    {
        if (!r.scanLogAt || A_TickCount-r.scanLogAt>=1000)
        {
            r.scanLogAt := A_TickCount
            PortalLogWriteV66("MAP130_PORTAL_SCAN room=" . V92Hex(NumGet(pb,0x1C,"UInt")) . " portals=" . portals.Count() . " new_near=" . count)
        }
        return
    }
    if (!r.portalLogged)
    {
        r.portalLogged := true
        PortalLogWriteV66("MAP130_PORTAL_FOUND uid=" . target.uid . " xy=" . target.x . "," . target.y . " distance2=" . ((px-target.x)**2+(py-target.y)**2))
    }
    if ((px-target.x)**2+(py-target.y)**2>9)
    {
        point := {x:target.x,y:target.y}
        FarmNoFightFlowV8(r,ctx,pb,103,"LIB_PORTAL_" . target.uid,[point],point)
        return
    }
    FarmCommonRouteEndV3(r)
    if (r.enterAt && A_TickCount-r.enterAt<1500)
        return
    sent := MapStage9V373(ctx,103,target)
    r.enterAt := A_TickCount
    PortalLogWriteV66("MAP130_ENTER_PORTAL uid=" . target.uid . " xy=" . target.x . "," . target.y . " expected=LIVE_MAP method=NATIVE queued=" . sent)
}

RoomRecordPrepareV258()
{
    global
    roomRecordPidV259 := SigBackgroundBindV179() ? backgroundPidV63 : 0
    mapButtonStartV172 := false,mapFarmStartPendingV170 := false
    SetTimer, MapButtonStartTimerV172, Off
    SetTimer, MapFarmStartV170, Off
    if (FarmControlRunningV186() || IsObject(coordGoV59) || farmResumeArmedV70 || farmStartRetryV237)
        FarmStopV124("RECORD_ROUTE_BUTTON")
    FarmPauseReleaseV256("RECORD_ROUTE_BUTTON")
    farmStopMoveV124 := false,coordGoV59 := false
    SetTimer, FarmStopMoveTimerV124, Off
    SetTimer, CoordGoTimerV59, Off
    return true
}

RoomRecordLevelV259(pid)
{
    base := pid ? D2GetModuleBaseV35(pid,"D2Client.dll") : 0
    h := base ? D2OpenProcess(pid) : 0
    if (!h)
        return 0
    try
    {
        player := D2ReadU32(h,base+0x11BBFC)
        path := player ? D2ReadU32(h,player+0x2C) : 0
        if (!MonsterBossProbeReadV1(h,path,0x20,pb))
            return 0
        
        mode := player ? D2ReadU32(h,player+0x10) : 0
        if (mode = 0 || mode = 17)
            return 0
            
        level := CoordLevelV14(h,NumGet(pb,0x1C,"UInt"))
        return level
    }
    finally
        DllCall("CloseHandle","Ptr",h)
}

RoomMapButtonNameV22(level)
{
    global roomMapLastButtonV22,farmControlOwnerV186,libScrollTierV290
    liveGroupV412 := MapRouteGroupV412("",level)
    name := liveGroupV412!="MAP" ? liveGroupV412 : roomMapLastButtonV22
    if (name="")
    {
        if (level=270)
            name := "SCOS"
        else if (level=150)
            name := "CYC"
        else if (level=148)
            name := "UBU"
        else if (level=146)
            name := "TRAN"
        else if (level=168 || level=183 || level=184 || level=185)
            name := "CAIN"
        else if (level>=263 && level<=266)
            name := libScrollTierV290 ? libScrollTierV290 : "LIB"
        else
            name := farmControlOwnerV186
    }
    if (name="LIB")
        name := libScrollTierV290 ? libScrollTierV290 : "LIB"
    else if (name="M3000")
        name := "3000"
    else if (name="NAO")
        name := "FAUT"
    name := RegExReplace(name,"[\\/:*?""<>|\r\n]","-")
    name := RTrim(Trim(name)," .")
    return name!="" ? name : "MAP"
}

RoomMapNamedNumberV293(baseName)
{
    global routeMapsV21
    escaped := RegExReplace(baseName,"([\\.\*\+\?\[\]\{\}\(\)\^\$\|])","\$1")
    pattern := "i)^" . escaped . "(?:-Map\d+)?-(\d+)(?:-Map\d+)?$"
    highest := 0
    for _,map in routeMapsV21
        if (RegExMatch(map.name,pattern,m))
            highest := Max(highest,m1+0)
    nameOwnerV412 := "",nameLevelV412 := 0
    if (RegExMatch(baseName,"i)^([^-]+)(?:-Map(\d+))?",baseGroupV412))
        nameOwnerV412 := baseGroupV4121,nameLevelV412 := baseGroupV4122+0
    Loop, Files, % MapRouteDirectoryV408(nameOwnerV412,nameLevelV412) . "\*.ini"
    {
        SplitPath, A_LoopFileName,,,, stem
        if (RegExMatch(stem,pattern,m))
            highest := Max(highest,m1+0)
    }
    return baseName . "-" . (highest+1)
}


RoomMapUniqueNameV261(baseName,directory,ownFile := "")
{
    global routeMapsV21
    name := baseName,suffix := 1
    Loop
    {
        file := directory . "\" . name . ".ini"
        taken := FileExist(file) && file!=ownFile
        if (file!=ownFile)
            for _,map in routeMapsV21
                if (map.name=name)
                    taken := true
        if (!taken)
            return name
        suffix++,name := baseName . "-" . suffix
    }
}


FonEditBeginV414()
{
    global fonEditDepthV414,fonEditPreviousV414,coordTrackingEnabledV409,autoMapTrackingV10
    if (!fonEditDepthV414)
        fonEditPreviousV414 := coordTrackingEnabledV409
    fonEditDepthV414 := (fonEditDepthV414+0)+1
    coordTrackingEnabledV409 := false,autoMapTrackingV10 := false
    SetTimer, CoordCurrentTimerV15, Off
    SetTimer, RoomMapListTimerV110, Off
    GuiControl, 1:, CoordTrackingButtonV409, F-OFF
}

FonEditEndV414()
{
    global fonEditDepthV414,fonEditPreviousV414,coordTrackingEnabledV409,autoMapTrackingV10
    fonEditDepthV414 := Max(0,fonEditDepthV414-1)
    if (fonEditDepthV414)
        return
    SetTimer, RoomMapListTimerV110, 2000
    if (fonEditPreviousV414)
        FonTrackingEnableV410()
    else
    {
        coordTrackingEnabledV409 := false,autoMapTrackingV10 := false
        SetTimer, CoordCurrentTimerV15, Off
        GuiControl, 1:, CoordTrackingButtonV409, F-OFF
    }
}

BOCoordinateBlockedV471()
{
    global scosEntryV162,farmControlOwnerV186,mapWorkflowV185
    if (IsObject(scosEntryV162) && scosEntryV162.map="BO")
        return scosEntryV162.boStageV413!=4
    return farmControlOwnerV186="BO" && IsObject(mapWorkflowV185) && mapWorkflowV185.stage=3
}

BOCoordinateOffV471()
{
    return false
}

FonManualLoadV758()
{
    global coordCursorSnapshotV390,coordCurrentReadAtV132
    if (!FonTrackingEnableV410())
        return false
    coordCursorSnapshotV390 := false,coordCurrentReadAtV132 := 0
    PortalLogWriteV66("FON_MANUAL_REFRESH next=READ_LIVE_MAP tracking=ON")
    ok := FonLoadMapV382("MANUAL")
    if (ok)
    {
        CoordCurrentReadV15()
        CoordBoxRefreshV15(true)
    }
    return ok
}

FonTrackingEnableV410()
{
    global coordTrackingEnabledV409,autoMapTrackingV10,fonEditDepthV414
    if (fonEditDepthV414)
    {
        PortalLogWriteV66("FON_ENABLE_BLOCKED reason=ROUTE_EDIT depth=" . fonEditDepthV414,"FON_EDIT_BLOCKED",2000)
        return false
    }
    coordTrackingEnabledV409 := true,autoMapTrackingV10 := true
    GuiControl, 1:, CoordTrackingButtonV409, F-ON
    SetTimer, CoordCurrentTimerV15, 250
    return true
}

FonEnsureLiveV410(pid := 0)
{
    global farmControlOwnerV186,backgroundPidV63,scosEntryV162
    if (BOCoordinateBlockedV471())
        return BackgroundValidV63()
    if (!pid)
        pid := backgroundPidV63 ? backgroundPidV63 : CoordDisplayGamePidV1()
    level := pid ? RoomRecordLevelV259(pid) : 0
    if (BossSearchActiveV430(pid))
        return BackgroundValidV63() && BossSearchIdentityV430(pid,level)
    if (farmControlOwnerV186="BO")
    {
        if (!BackgroundValidV63() || pid!=backgroundPidV63)
            return false
        if (!IsObject(scosEntryV162) || scosEntryV162.phase!="FARM")
            return true
    }
    return pid && level ? Stage2MapWaitV381(pid,level) : false
}

Map263AutoLoadObserveV263(pid,level,x,y,levelPtrV395 := 0)
{
    static lastAttemptKeyV841 := "",nextAttemptAtV841 := 0
    global farmGD2TestV644
    if (LibFarmPinMatchesV2026(pid,level))
        return LibFarmPinRestoreV2026(pid,level,levelPtrV395)
    if (IsObject(farmGD2TestV644))
        return FarmGD2TestReadyV644(pid,level)

    if (CainCaveLiveModeV506(pid,level))
        return true
    global currentProfile,routeMapIdV21,coordSavedV15,coordTrackingEnabledV409
        global coordMapReadyV381,coordMapStateV381,mapLoadFailureV402,routePreviewV401,fonFirstLoadV763
    if (!coordTrackingEnabledV409 || !pid || !level || !x || !y || !levelPtrV395)
        return false
    if (BossSearchOwnsMapV430(pid,level))
        return true
    attemptKeyV841 := pid . "|" . currentProfile . "|" . level . "|" . levelPtrV395
    if (lastAttemptKeyV841!=attemptKeyV841)
        lastAttemptKeyV841 := attemptKeyV841,nextAttemptAtV841 := 0
if (!fonFirstLoadV763)
{
    fonFirstLoadV763 := true
    ; Re-enabling F-ON on the SAME map must keep the INI and yellow row.
    sameLoadedV845 := coordMapReadyV381 && IsObject(coordMapStateV381)
        && coordMapStateV381.loaded && coordMapStateV381.pid=pid
        && coordMapStateV381.level=level && coordMapStateV381.profile=currentProfile
        && coordMapStateV381.levelPtrV395=levelPtrV395
        && coordMapStateV381.mapId=routeMapIdV21
        && IsObject(coordSavedV15) && coordSavedV15.Length()
        && coordSavedV15[1].level=level
    if (sameLoadedV845)
        return true
    nextAttemptAtV841 := A_TickCount+1300
    return FonLoadMapV382("FON_FIRST",pid,level,x,y)
}
key := pid . "|" . currentProfile . "|" . level
    file := RoomProfileFileV108(currentProfile,routeMapIdV21)
    stampOK := MapFileStampReadV398(file,stamp)
    identityLive := IsObject(coordMapStateV381) && coordMapStateV381.loaded
        && coordMapStateV381.key=key && coordMapStateV381.levelPtrV395=levelPtrV395
        && coordMapStateV381.mapId=routeMapIdV21 && IsObject(coordSavedV15)
        && coordSavedV15.Length() && coordSavedV15[1].level=level
    ; Không giữ route cũ khi file bị sửa: phải đọc lại các điểm và bố cục.
    if (identityLive && (!stampOK || coordMapStateV381.fileV10!=file
        || coordMapStateV381.fileStampV10!=stamp))
    {
        coordMapReadyV381 := false
        if (A_TickCount<nextAttemptAtV841)
            return false
        nextAttemptAtV841 := A_TickCount+1300
        PortalLogWriteV66("FON_AUTO_RELOAD cause=ROUTE_FILE_CHANGED level=" . level)
        return FonLoadMapV382("AUTO_FILE_CHANGED",pid,level,x,y)
    }
    if (identityLive && !FarmReviveTownLevelV295(level)
        && !(level=39 || level=183 || level=184 || level=263 || level=241 || level=270)
        && coordMapStateV381.HasKey("layoutV841") && coordMapStateV381.layoutV841!=""
        && A_TickCount-coordMapStateV381.layoutCheckedAtV841>=2500)
    {
        ; V845: a partial Room2 read is NOT evidence of a different map.
        ; Keep the valid route/yellow watcher; reload only for a confirmed change.
        coordMapStateV381.layoutCheckedAtV841 := A_TickCount
        checkGeometryV841 := MapRoomLayoutReadV270(pid,level)
        if (!IsObject(checkGeometryV841) || checkGeometryV841.partial)
            PortalLogWriteV66("FON_LAYOUT_VERIFY_WAIT level=" . level . " loaded_map=KEPT", "FON_VERIFY_WAIT",5000)
        else if (checkGeometryV841.layout!=coordMapStateV381.layoutV841
            || checkGeometryV841.levelPtr!=levelPtrV395)
        {
            coordMapReadyV381 := false
            PortalLogWriteV66("FON_AUTO_RELOAD cause=ROOM_LAYOUT_CHANGED level=" . level)
            return FonLoadMapV382("AUTO_LAYOUT_CHANGE",pid,level,x,y)
        }
    }
    if (identityLive && coordMapReadyV381)
        return true
    coordMapReadyV381 := false
    if (A_TickCount<nextAttemptAtV841)
        return false
    nextAttemptAtV841 := A_TickCount+1300
    mapLoadFailureV402 := false,routePreviewV401 := false
    return FonLoadMapV382("AUTO_LEVEL_CHANGE",pid,level,x,y)
}

FonLoadErrorShowV385(text)
{
    global fonLoadErrorV385
    fonLoadErrorV385 := {text:text, shownAt:A_TickCount}
    SetTimer, FonLoadErrorFollowV385, 50
}

FonLoadErrorHideV385()
{
    global fonLoadErrorV385
    fonLoadErrorV385 := false
    SetTimer, FonLoadErrorFollowV385, Off
    ToolTip,,,, 5
}

FonLoadErrorFollowV385:
FonLoadErrorTickV385()
return

FonLoadErrorTickV385()
{
    global fonLoadErrorV385
    if (!IsObject(fonLoadErrorV385))
    {
        SetTimer, FonLoadErrorFollowV385, Off
        ToolTip,,,, 5
        return
    }
    if (A_TickCount-fonLoadErrorV385.shownAt>=800
        && (A_TimeIdlePhysical<300 || GetKeyState("LButton","P") || GetKeyState("RButton","P")))
    {
        FonLoadErrorHideV385()
        return
    }
    mouseMode := A_CoordModeMouse, tipMode := A_CoordModeToolTip
    CoordMode, Mouse, Screen
    CoordMode, ToolTip, Screen
    try
    {
        MouseGetPos, mx, my
        ToolTipInfoV386(fonLoadErrorV385.text, "mx+20", "my+20", 5)
    }
    finally
    {
        CoordMode, Mouse, %mouseMode%
        CoordMode, ToolTip, %tipMode%
    }
}
CoordMapUnavailableV381()
{
    global coordMapReadyV381,coordMapStateV381,coordMapAcceptedV381,coordCurrentLevelV400
    coordCurrentLevelV400 := 0
    coordMapReadyV381 := false,coordMapStateV381 := false,coordMapAcceptedV381 := false
}

FarmStartRowV394()
{
    global farmGD2TestV644
    if (IsObject(farmGD2TestV644) && farmGD2TestV644.starting)
        return farmGD2TestV644.row
    global scosEntryV162,coordRouteV16
    if (IsObject(scosEntryV162.commonRouteV3) && IsObject(scosEntryV162.commonRouteV3.pointsV724))
    {
        c := scosEntryV162.commonRouteV3
        return IsObject(coordRouteV16) && coordRouteV16.yellow>=1 ? coordRouteV16.yellow : c.startRowV724
    }
    global autoMapTrackingV10,coordYellowRowV350,coordSavedV15
    if (!IsObject(coordSavedV15) || !coordSavedV15.Length())
        return 0
    return coordYellowRowV350>=1 && coordYellowRowV350<=coordSavedV15.Length()
        ? coordYellowRowV350 : 1
}

Stage2RoomReplayReleaseV11()
{
    global roomExploreV89
    if (IsObject(roomExploreV89) && roomExploreV89.savedRouteOnly)
        RoomExploreEndV89("STANDARD_GD2_NEW_LOADED_ROUTE")
}

Stage2MapRequestV381(force := false)
{
    global farmControlOwnerV186
    pid := CoordDisplayGamePidV1()
    if (BossSearchActiveV430(pid))
        return BossSearchIdentityV430(pid,RoomRecordLevelV259(pid))
    level := pid ? RoomRecordLevelV259(pid) : 0
    if (!pid || !level)
        return false
    return Stage2MapWaitV381(pid,level,true)
}

Stage2StartWaitTimerV381:
if (farmUserPausedV2026)
    return
if (farmManualStoppedV2026)
{
    SetTimer, Stage2StartWaitTimerV381, Off
    return
}
if (!stage2StartPendingV381 || !autoMonsterAttackOn)
{
    stage2StartPendingV381 := false
    SetTimer, Stage2StartWaitTimerV381, Off
    return
}
if (!BackgroundValidV63() || !Stage2MapRequestV381())
    return
stage2StartPendingV381 := false
SetTimer, Stage2StartWaitTimerV381, Off
Gosub, AutoMonsterAttackToggle
if (farmControlOwnerV186="CAIN" && autoMonsterAttackOn && !IsObject(scosEntryV162))
    CainStage2AttachV379()
return

Stage2MapWaitV381(pid,level,force := false)
{
    global farmGD2TestV644
    if (IsObject(farmGD2TestV644))
        return FarmGD2TestReadyV644(pid,level)
    if (FarmCommonRouteActiveV3(pid,level))
        return FarmCommonRouteReadyV3(pid,level)

    if (CainCaveLiveModeV506(pid,level))
        return IsObject(MapLiveIdentityV399(pid,level))
    if (BOCoordinateBlockedV471())
        return BackgroundValidV63() && level>0
    global farmStartChoiceV2
    global currentProfile,routeMapIdV21,coordSavedV15,coordRouteV16,farmLoadedMapV56,coordMapSerialV381
    global coordMapStateV381,coordMapReadyV381,stage2MapFileV14
    global mapRunResumeV210,coordRunSelectedV210,farmStage2DoneV372,coordMoveDoneV14
    global farmControlOwnerV186
    if (BossSearchActiveV430(pid,level))
    {
        if (BossSearchIdentityV430(pid,level))
            return true
        return MapLoadFailedStopV397("BOSS_SEARCH_LIVE_MAP_READ_FAILED")
    }
    if (IsObject(farmStartChoiceV2) && farmStartChoiceV2.reloadPending)
        force := true
    baseV14 := pid ? D2GetModuleBaseV35(pid,"D2Client.dll") : 0
    hV14 := baseV14 ? D2OpenProcess(pid) : 0
    if (!hV14)
        return false
    priorCriticalV14 := A_IsCritical
    Critical, On
    try
    {
        playerV14 := D2ReadU32(hV14,baseV14+0x11BBFC)
        pathV14 := playerV14 ? D2ReadU32(hV14,playerV14+0x2C) : 0
        if (!pathV14 || !MonsterBossProbeReadV1(hV14,pathV14,0x20,pbV14))
            return false
        liveLevelV14 := CoordLevelV14(hV14,NumGet(pbV14,0x1C,"UInt"))
        room2V14 := D2ReadU32(hV14,NumGet(pbV14,0x1C,"UInt")+0x10)
        levelPtrV14 := room2V14 ? D2ReadU32(hV14,room2V14+0x58) : 0
        xV14 := NumGet(pbV14,2,"UShort"),yV14 := NumGet(pbV14,6,"UShort")
        if (!liveLevelV14 || liveLevelV14!=level || !levelPtrV14 || !xV14 || !yV14)
            return false
        if (LibFarmPinMatchesV2026(pid,level)
            && !LibFarmPinRestoreV2026(pid,level,levelPtrV14))
            return false
        if (LibFarmPinMatchesV2026(pid,level))
            force := false  ; Resume: dung cac diem da khoa, chi theo dong vang.
        if (!coordMapReadyV381 || !IsObject(coordMapStateV381) || !coordMapStateV381.loaded
            || coordMapStateV381.key!=pid . "|" . currentProfile . "|" . level
            || coordMapStateV381.mapId!=routeMapIdV21
            || coordMapStateV381.levelPtrV395!=levelPtrV14
            || !IsObject(coordSavedV15) || !coordSavedV15.Length()
            || coordSavedV15[1].level!=level)
            return false
        if (IsObject(farmStartChoiceV2))
        {
            FarmStartApplyYellowV2()
            farmStartChoiceV2.reloadPending := false
        }
        newMapV14 := !IsObject(stage2MapFileV14) || stage2MapFileV14.pid!=pid
            || stage2MapFileV14.profile!=currentProfile || stage2MapFileV14.level!=level
            || stage2MapFileV14.levelPtr!=levelPtrV14 || stage2MapFileV14.mapId!=routeMapIdV21
        newRouteV14 := force || newMapV14 || stage2MapFileV14.serial!=coordMapSerialV381
        if (newRouteV14)
        {
            rowV396 := FarmStartRowV394()
            Stage2RoomReplayReleaseV11()
            CoordRouteResetV16()
            mapRunResumeV210 := false,coordRunSelectedV210 := false
            farmStage2DoneV372 := false,coordMoveDoneV14 := false
            stage2MapFileV14 := {pid:pid,profile:currentProfile,level:level
                ,levelPtr:levelPtrV14,mapId:routeMapIdV21,serial:coordMapSerialV381}
            coordRouteV16.pid := pid,coordRouteV16.startLevel := level
            coordRouteV16.resumeRowV210 := rowV396,coordRouteV16.startAtYellowV367 := true
            coordRouteV16.yellow := rowV396
            PortalLogWriteV66("STAGE2_ROUTE_NEW level=" . level . " map=" . routeMapIdV21
                . " yellow=" . rowV396 . " source=FON_LIVE old_progress=DISCARDED")
        }
        if (!IsObject(coordSavedV15) || !coordSavedV15.Length() || coordSavedV15[1].level!=level)
            return false
        if (!IsObject(coordRouteV16) || coordRouteV16.pid!=pid || coordRouteV16.startLevel!=level
            || (coordRouteV16.HasKey("mapIdV396") && coordRouteV16.mapIdV396!=routeMapIdV21)
            || (coordRouteV16.HasKey("loadedSerialV11") && coordRouteV16.loadedSerialV11!=coordMapSerialV381))
        {
            rowV396 := FarmStartRowV394()
            CoordRouteResetV16()
            coordRouteV16.pid := pid,coordRouteV16.startLevel := level
            coordRouteV16.resumeRowV210 := rowV396,coordRouteV16.startAtYellowV367 := true
            coordRouteV16.yellow := rowV396
            PortalLogWriteV66("STAGE2_ROUTE_BEGIN level=" . level . " row=" . rowV396 . " source=FRESH_FILE")
        }
        coordRouteV16.mapIdV396 := routeMapIdV21
        coordRouteV16.loadedSerialV11 := coordMapSerialV381
        farmLoadedMapV56 := {pid:pid,profile:currentProfile,mapId:routeMapIdV21,level:level}
        return true
    }
    finally
    {
        DllCall("CloseHandle","Ptr",hV14)
        Critical, %priorCriticalV14%
    }
}

Ticket130ButtonV265:
if (ticket130BusyV265)
{
    sigCancelV147 := true
    return
}
InputBox, ticketCountV265, Tạo Vé130, Nhập số lượng vé cần tạo:, , 300, 140,,,,, 1
if (ErrorLevel)
    return
if (!RegExMatch(Trim(ticketCountV265),"^\d+$") || ticketCountV265<1 || ticketCountV265>999)
{
    ToolTipInfoV386("Nhập số lượng từ 1 đến 999.")
    SetTimer, RemoveToolTip, -2500
    return
}
Ticket130RunV265(ticketCountV265+0)
return

Ticket133ButtonV267:
if (ticket130BusyV265)
{
    sigCancelV147 := true
    return
}
InputBox, ticketCountV267, Tạo Vé133, Nhập số lượng vé cần tạo:, , 300, 140,,,,, 1
if (ErrorLevel)
    return
if (!RegExMatch(Trim(ticketCountV267),"^\d+$") || ticketCountV267<1 || ticketCountV267>999)
{
    ToolTipInfoV386("Nhập số lượng từ 1 đến 999.")
    SetTimer, RemoveToolTip, -2500
    return
}
Ticket130RunV265(ticketCountV267+0,true)
return

Ticket136ButtonV268:
if (ticket130BusyV265)
{
    sigCancelV147 := true
    return
}
InputBox, ticketCountV268, Tạo Vé136, Nhập số lượng vé cần tạo:, , 300, 140,,,,, 1
if (ErrorLevel)
    return
if (!RegExMatch(Trim(ticketCountV268),"^\d+$") || ticketCountV268<1 || ticketCountV268>999)
{
    ToolTipInfoV386("Nhập số lượng từ 1 đến 999.")
    SetTimer, RemoveToolTip, -2500
    return
}
Ticket130RunV265(ticketCountV268+0,2)
return

Ticket139ButtonV268:
if (ticket130BusyV265)
{
    sigCancelV147 := true
    return
}
InputBox, ticketCountV268, Tạo Vé139, Nhập số lượng vé cần tạo:, , 300, 140,,,,, 1
if (ErrorLevel)
    return
if (!RegExMatch(Trim(ticketCountV268),"^\d+$") || ticketCountV268<1 || ticketCountV268>999)
{
    ToolTipInfoV386("Nhập số lượng từ 1 đến 999.")
    SetTimer, RemoveToolTip, -2500
    return
}
Ticket130RunV265(ticketCountV268+0,3)
return

Ticket130MaterialMatchesV267(ctx,item)
{
    name := Ticket130NameV265(ctx,item)
    if (!ctx.soulModeV267)
        return ConsumableKnownNameV7(name)="GEM"
    Loop, Parse, name, `n, `r
        if (RegExMatch(Trim(A_LoopField),"i)^Heavenly Souls?$"))
            return true
    return false
}

Ticket130NameV265(ctx,item)
{
    global consumableClassRAMV7
    key := ctx.pid . "|" . item.cls,started := A_TickCount
    Loop
    {
        SigCheckV147(ctx)
        ConsumablePickupGroupV7(ctx.h,item.cls)
        ConsumableNamePollV7()
        if (consumableClassRAMV7.HasKey(key))
            return Trim(PickupOptCleanTextV12(consumableClassRAMV7[key]))
        if (A_TickCount-started>1500)
            SigFailV147("Chưa đọc được tên vật trong rương; dừng để tránh lấy nhầm")
        Sleep, 30
    }
}

Ticket130FindV265(ctx,wanted,skip := 0)
{
    for uid,a in SigSnapshotV147(ctx)
    {
        if (a.loc!=0 || a.owner!=ctx.inv || uid=skip || a.cls=1204
            || D2ReadU32(ctx.h,a.unit+0x10)=3 || D2ReadU32(ctx.h,a.unit+0x10)=5)
            continue
        if (wanted="ZAKARUM_EAR")
        {
            if (a.cls!=1804)
                continue
            SigLogV147("TICKET130_SEARCH wanted=" . wanted . " uid=" . uid . " class=" . a.cls . " name=Zakarum's Ear")
            return a
        }
        if (wanted="PARAGON_HAMMER")
        {
            if (a.cls!=1816)
                continue
            SigLogV147("TICKET133_SEARCH wanted=" . wanted . " uid=" . uid . " class=" . a.cls . " name=Paragon's Hammer")
            return a
        }
        if (wanted="SOUL_CRATE")
        {
            if (a.cls!=2346)
                continue
            SigLogV147("TICKET133_SEARCH wanted=" . wanted . " uid=" . uid . " class=" . a.cls . " name=Crate O' Souls")
            return a
        }
        name := Ticket130NameV265(ctx,a)
        SigLogV147("TICKET130_SEARCH wanted=" . wanted . " uid=" . uid . " class=" . a.cls . " name=" . name)
        if (wanted="GEM" && ConsumableKnownNameV7(name)="GEM")
            return a
        if (wanted="CLUSTER" && RegExMatch(name,"i)^(?:Diamond|Amethyst|Ruby|Topaz|Bloodstone|Onyx|Amber|Turquoise|Sapphire|Emerald|Rainbow Stone|Skull) Cluster(?: \(\d+\))?$"))
            return a
    }
    return false
}

Ticket130LooseGemsV266(ctx,limit)
{
    gems := []
    for uid,a in SigSnapshotV147(ctx)
    {
        if (a.loc!=0 || a.owner!=ctx.inv || a.cls=1204
            || D2ReadU32(ctx.h,a.unit+0x10)=3 || D2ReadU32(ctx.h,a.unit+0x10)=5)
            continue
        if (Ticket130MaterialMatchesV267(ctx,a))
        {
            gems.Push(a)
            if (gems.Length()>=limit)
                break
        }
    }
    return gems
}

Ticket130RetainedV266(ctx,item)
{
    retained := false
    for _,a in SigCubeItemsV147(ctx)
        if (a.cls=item.cls && a.q=item.q)
            retained := a
    if (!IsObject(retained))
        SigFailV147("Không xác nhận được vật dùng cube còn lại; ngưng")
    if (retained.uid!=item.uid)
    {
        home := ctx.returnHomesV265[item.uid]
        ctx.returnHomesV265.Delete(item.uid)
        home.uid := retained.uid,ctx.returnHomesV265[retained.uid] := home
    }
    return retained
}

Ticket130PrepareGemsV266(ctx,cube,target)
{
    gems := Ticket130LooseGemsV266(ctx,target)
    missing := target-gems.Length(),cluster := false
    SigLogV147("TICKET130_GEM_PLAN target=" . target . " loose=" . gems.Length() . " split=" . missing)
    Loop, %missing%
    {
        SigCheckV147(ctx)
        if (!IsObject(cluster))
        {
            cluster := Ticket130FindV265(ctx,ctx.soulModeV267 ? "SOUL_CRATE" : "CLUSTER")
            if (!IsObject(cluster))
                SigFailV147(ctx.soulModeV267 ? "Không đủ Heavenly Soul và không tìm thấy Crate O' Souls" : "Không đủ gem và không tìm thấy Gem Cluster")
            Ticket130ReserveV265(ctx,cluster)
            SigToCubeV147(ctx,cluster,cube,true)
            SigLogV147("TICKET130_CLUSTER_ENTER uid=" . cluster.uid . " split=" . missing)
        }
        output := SigTransmuteV147(ctx,[cluster],1,cluster)
        cluster := Ticket130RetainedV266(ctx,cluster)
        gem := output[1]
        if (!Ticket130MaterialMatchesV267(ctx,gem))
            SigFailV147("Tách chưa ra " . ctx.materialNameV267 . "; ngưng, giữ sản phẩm")
        if (A_Index=missing)
        {
            gems.InsertAt(1,gem)
            SigLogV147("TICKET130_GEM_KEEP_CUBE uid=" . gem.uid . " next=RETURN_CLUSTER_THEN_EAR")
        }
        else
        {
            SigReturnV147(ctx,gem)
            all := SigSnapshotV147(ctx)
            if (!all.HasKey(gem.uid) || all[gem.uid].loc!=0 || all[gem.uid].owner!=ctx.inv)
                SigFailV147(ctx.materialNameV267 . " đã tách chưa về rương; ngưng")
            gems.Push(all[gem.uid])
        }
        SigLogV147("TICKET130_GEM_PREPARED split_done=" . A_Index . " split_needed=" . missing . " ready=" . gems.Length())
    }
    if (IsObject(cluster))
    {
        SigReturnV147(ctx,cluster)
        ctx.returnHomesV265.Delete(cluster.uid)
        SigLogV147("TICKET130_CLUSTER_HOME next=MOVE_ZAKARUM_EAR")
    }
    return gems
}

TicketItemSizeV277(ctx,cls)
{
    if (!IsObject(ctx.itemSizesV277))
        ctx.itemSizesV277 := {}
    if (ctx.itemSizesV277.HasKey(cls))
        return ctx.itemSizesV277[cls]
    common := D2GetModuleBaseV35(ctx.pid,"D2Common.dll")
    table := common ? D2ReadU32(ctx.h,common+0x9FB98) : 0
    count := common ? D2ReadU32(ctx.h,common+0x9FB94) : 0
    if (!table || cls<0 || cls>=count || count>65535)
        SigFailV147("Không đọc được bảng kích thước vật phẩm")
    w := D2ReadU8V18(ctx.h,table+cls*0x1A8+0x10F)
    h := D2ReadU8V18(ctx.h,table+cls*0x1A8+0x110)
    if (w<1 || w>16 || h<1 || h>16)
        SigFailV147("Không đọc được kích thước vật phẩm class=" . cls)
    size := {w:w,h:h},ctx.itemSizesV277[cls] := size
    return size
}

TicketInventoryPlaceV277(ctx,item)
{
    all := SigSnapshotV147(ctx),occupied := {},extentX := 0,extentY := 0
    size := TicketItemSizeV277(ctx,item.cls)
    for uid,a in all
        if (a.loc=0 && a.owner=ctx.inv && uid!=item.uid && D2ReadU32(ctx.h,a.unit+0x10)!=3)
        {
            footprint := TicketItemSizeV277(ctx,a.cls)
            extentX := Max(extentX,a.x+footprint.w),extentY := Max(extentY,a.y+footprint.h)
            Loop, % footprint.h
            {
                yy := a.y+A_Index-1
                Loop, % footprint.w
                    occupied[(a.x+A_Index-1) . "," . yy] := true
            }
        }
    if (IsObject(ctx.returnHomesV265))
        for _,home in ctx.returnHomesV265
            extentX := Max(extentX,home.x+home.w),extentY := Max(extentY,home.y+home.h)
    if (!extentX || !extentY || extentX>32 || extentY>32)
        SigFailV147("Chưa xác định được vùng ô rương để đặt vật")
    cursor := PickupCursorV4(ctx.h,ctx.inv)
    rejected := 0
    Loop, % extentY
    {
        y := A_Index-1
        Loop, % extentX
        {
            x := A_Index-1
            if (x+size.w>extentX || y+size.h>extentY)
                continue
            free := true
            Loop, % size.h
            {
                yy := y+A_Index-1
                Loop, % size.w
                    if (occupied.HasKey((x+A_Index-1) . "," . yy) || SigReservedHomeCellV192(ctx,x+A_Index-1,yy))
                    {
                        free := false
                        break
                    }
                if (!free)
                    break
            }
            if (!free)
                continue
            cursor := PickupCursorV4(ctx.h,ctx.inv)
            if (!IsObject(cursor) || cursor.uid!=item.uid)
            {
                if (SigWaitLocV147(ctx,item.uid,0,100))
                    return true
                SigLiftV147(ctx,item)
            }
            SigLogV147("TICKET_EMPTY_SLOT uid=" . item.uid . " xy=" . x . "," . y . " size=" . size.w . "x" . size.h)
            bytes := [0x18],SigDwordV147(bytes,item.uid),SigDwordV147(bytes,x),SigDwordV147(bytes,y),SigDwordV147(bytes,0)
            SigPacketV147(ctx,bytes)
            if (SigWaitLocV147(ctx,item.uid,0,700))
            {
                SigLogV147("TICKET_PLACED uid=" . item.uid . " xy=" . x . "," . y . " cursor=EMPTY")
                return true
            }
            rejected++
            SigLogV147("TICKET_SLOT_REJECTED uid=" . item.uid . " xy=" . x . "," . y)
        }
    }
    SigFailV147("Không còn ô trống phù hợp để đặt vật; UID=" . item.uid . "; rejected=" . rejected)
}

TicketCubeClearV278(ctx,cube,items)
{
    if (!items.Length())
    {
        SigLogV147("TICKET_CUBE_EMPTY uid=" . cube.uid . " method=ALREADY_EMPTY")
        return true
    }
    SigCubeDropPickupV280(ctx,cube)
    ctx.cubeDroppedV278 := true
    if (SigCubeItemsV147(ctx).Length())
        SigFailV147("Cube nhặt lại chưa trống; dừng tạo vé")
    SigLogV147("TICKET_CUBE_EMPTY cube_uid=" . cube.uid . " method=DROP_PICK_NO_POSITION_LOCK")
    return true
}

Ticket130ReserveV265(ctx,item)
{
    all := SigSnapshotV147(ctx),live := all[item.uid]
    if (!IsObject(live) || live.loc!=0 || live.owner!=ctx.inv)
        SigFailV147("Vật cần lấy không còn trong rương")
    if (!IsObject(ctx.returnHomesV265))
        ctx.returnHomesV265 := {}
    sizeV277 := TicketItemSizeV277(ctx,item.cls)
    ctx.returnHomesV265[item.uid] := {uid:item.uid,x:live.x,y:live.y,w:sizeV277.w,h:sizeV277.h}
    SigLogV147("TICKET_HOME_RESERVED uid=" . item.uid . " class=" . item.cls . " xy=" . live.x . "," . live.y)
}

Ticket130HomeV265(ctx,item,home)
{
    all := SigSnapshotV147(ctx)
    live := all[item.uid]
    if (IsObject(live) && live.loc=0 && live.owner=ctx.inv && live.x=home.x && live.y=home.y)
        return true
    cursor := PickupCursorV4(ctx.h,ctx.inv)
    if (!IsObject(cursor) || cursor.uid!=item.uid)
        SigLiftV147(ctx,item)
    bytes := [0x18],SigDwordV147(bytes,item.uid),SigDwordV147(bytes,home.x),SigDwordV147(bytes,home.y),SigDwordV147(bytes,0)
    SigPacketV147(ctx,bytes)
    live := SigWaitLocV147(ctx,item.uid,0)
    if (!IsObject(live) || live.x!=home.x || live.y!=home.y)
        SigFailV147("Không trả được vật về đúng ô đã giữ; dừng, không quăng vật")
    SigLogV147("TICKET_HOME_RESTORED uid=" . item.uid . " xy=" . live.x . "," . live.y)
    return true
}

TicketPickupFinishV279(pid,level)
{
    global ticketPickupWaitV279,sigCancelV147,pickupImageOn,pickupTimerBusy
    global pickupBackgroundV181
    ticketPickupWaitV279 := {pid:pid,level:level,checks:0,emptyAt:0,done:false,scanAt:0,remaining:-1,active:true,resetProtectedV754:true}
    previousBackgroundV279 := pickupBackgroundV181
    pickupBackgroundV181 := true
    global cubeResetSerialV754
    pickupSerialV754 := cubeResetSerialV754
    FarmWatchSigGateV753(FarmWatchStateV688(),FarmWatchNowV688())
    started := A_TickCount
    try
    {
        PickupEnabledSetV71(true,true,false)
        SetTimer, PickupImageTimer, Off
        while (A_TickCount-started<120000)
        {
            if (sigCancelV147)
                throw Exception("Đã dừng chờ nhặt; chưa xác nhận hết đồ dưới đất")
            if (!pickupImageOn)
                throw Exception("Nhặt đã dừng / rương đầy; đồ dưới đất chưa được xác nhận hết")
            if (RoomRecordLevelV259(pid)!=level)
                throw Exception("Đã rời map; chưa xác nhận nhặt hết đồ")
            if (!pickupTimerBusy && GameItemActionBeginV4("Pickup", "cube"))
            {
                pickupTimerBusy := true
                try
                    PickupV61Tick()
                finally
                {
                    pickupTimerBusy := false
                    GameItemActionEndV4("Pickup")
                }
            }
            if (ticketPickupWaitV279.done && !pickupTimerBusy
                && A_TickCount-ticketPickupWaitV279.scanAt<1000)
            {
                if (!CubeResetVerifiedV754(pid,level,pickupSerialV754))
                {
                    Sleep, 100
                    continue
                }
                SigLogV147("TICKET_PICKUP_CONFIRMED checks=" . ticketPickupWaitV279.checks . " eligible_ground=0 cursor=EMPTY")
                return true
            }
            ToolTipInfoV386("Đã tạo vé - đang kiểm tra / nhặt đồ dưới đất. Còn " . (ticketPickupWaitV279.remaining<0 ? "chưa quét" : ticketPickupWaitV279.remaining) . " món trong danh sách.")
            Sleep, 100
        }
        throw Exception("Tạo vé chưa hoàn tất: chưa xác nhận nhặt hết sau 120 giây")
    }
    finally
    {
        ticketPickupWaitV279 := false
        if (pickupImageOn)
            SetTimer, PickupImageTimer, 20
        pickupBackgroundV181 := previousBackgroundV279
    }
}

Ticket130RunV265(count,soulMode:=false,entryV293:=false)
{
    global ticket130BusyV265,sigBusyV147,sigCancelV147,sigActiveModeV182,sigBackgroundV179
    global pickupImageOn,pickupTimerBusy,autoMonsterAttackOn,scosEntryV162,stageTwoV166,sigTownV148
    global sigCubeUiOpenV159,pickupRoundResetV1,ticketPickupWaitV279
    if (sigBusyV147 || autoMonsterAttackOn || (IsObject(scosEntryV162) && (!IsObject(entryV293) || scosEntryV162!=entryV293)) || IsObject(stageTwoV166) || IsObject(sigTownV148))
    {
        ToolTipInfoV386("Dừng Farm / SIG trước khi tạo vé.")
        SetTimer, RemoveToolTip, -3000
        return false
    }
    if (!SigBackgroundBindV179() || !PickupActivateGameV13())
        return false
    oldBackground := sigBackgroundV179,oldPickup := pickupImageOn
    sigBackgroundV179 := true
    PickupEnabledSetV71(false,true,false)
    start := A_TickCount
    while (pickupTimerBusy && A_TickCount-start<4000)
        Sleep, 50
    if (pickupTimerBusy || !GameItemActionBeginV4("Cube","cube",true))
    {
        sigBackgroundV179 := oldBackground
        ToolTipInfoV386("Đang xử lý đồ hoặc có vật trên chuột; chưa tạo vé.")
        SetTimer, RemoveToolTip, -3000
        return false
    }
    materialPerTicket := soulMode ? soulMode+0 : 1
    cost := soulMode=3 ? 200000 : soulMode=2 ? 100000 : 50000
    ticketLevel := soulMode=3 ? 139 : soulMode=2 ? 136 : soulMode ? 133 : 130
    ticketClassV289 := soulMode=3 ? 2391 : soulMode=2 ? 2390 : soulMode ? 2389 : 2348
    ticketCaption := "Vé" . ticketLevel
    reagentName := soulMode ? "Paragon's Hammer" : "Zakarum's Ear"
    ticket130BusyV265 := true,sigBusyV147 := true,sigCancelV147 := false,sigActiveModeV182 := "VE" . ticketLevel
    FarmWatchSigGateV753(FarmWatchStateV688(),FarmWatchNowV688())
    GuiControl, Disable, SigButtonV147
    GuiControl, Disable, SigSuButtonV181
    ctx := false,done := 0,message := "",cleanupOK := true,phase := "OPEN_CONTEXT",existingTicketReadyV738 := false
    SigLogV147("TICKET130_START requested=" . count)
    try
    {
        ctx := SigOpenContextV149()
        ctx.ticketEntryV293 := entryV293
        ctx.ticketPlacementV277 := true
        ctx.soulModeV267 := soulMode
        ctx.materialNameV267 := soulMode ? "Heavenly Soul" : "gem"
        SigLogV147("TICKET_RECIPE mode=" . ticketCaption . " reagent=" . reagentName . " material=" . ctx.materialNameV267 . " material_per_ticket=" . materialPerTicket . " gold_per_ticket=" . cost)
        phase := "CHECK_TOWN"
        level := RoomRecordLevelV259(ctx.pid)
        SigLogV147("TICKET130_LEVEL level=" . level)
        if (level!=1 && level!=40 && level!=75 && level!=103 && level!=109)
            SigFailV147("Tạo vé khi nhân vật ở thành")
        if (IsObject(entryV293))
        {
            phase := "CHECK_EXISTING_TICKET"
            existingV738 := false,cubeV738 := false
            for uidV738,itemV738 in SigSnapshotV147(ctx)
            {
                modeV738 := D2ReadU32(ctx.h,itemV738.unit+0x10)
                if (itemV738.cls=1204 && itemV738.q=2 && itemV738.loc=0 && itemV738.owner=ctx.inv)
                    cubeV738 := itemV738
                if (itemV738.cls!=ticketClassV289 || itemV738.q!=2 || modeV738=3 || modeV738=5)
                    continue
                if (itemV738.loc=0 && itemV738.owner=ctx.inv)
                    existingV738 := itemV738
                else if (itemV738.loc=3 && (!IsObject(existingV738) || existingV738.loc!=0))
                    existingV738 := itemV738
            }
            if (IsObject(existingV738))
            {
                if (existingV738.loc=3)
                {
                    if (!IsObject(cubeV738))
                        SigFailV147("Có vé trong Cube nhưng chưa thấy Cube trong túi; chưa tạo thêm vé")
                    ctx.cubeUid := cubeV738.uid
                    SigReturnV147(ctx,existingV738)
                }
                if (!SigWaitLocV147(ctx,existingV738.uid,0))
                    SigFailV147("Có vé sẵn nhưng chưa xác nhận lấy ra túi; chưa tạo thêm vé")
                existingTicketReadyV738 := true
                message := "Có sẵn " . ticketCaption . " - dùng vé này, bỏ qua tạo vé"
                PortalLogWriteV66("LIB_EXISTING_TICKET tier=" . ticketLevel . " uid=" . existingV738.uid
                    . " class=" . ticketClassV289 . " recipe=SKIPPED")
            }
        }
        if (!existingTicketReadyV738)
        {
            phase := "FIND_CUBE",cube := false,all := SigSnapshotV147(ctx)
            SigLogV147("TICKET130_INVENTORY count=" . all.Count() . " inv=" . V92Hex(ctx.inv))
            for uid,a in all
                if (a.cls=1204)
                {
                    SigLogV147("TICKET130_CUBE_CANDIDATE uid=" . uid . " quality=" . a.q
                        . " loc=" . a.loc . " owner=" . V92Hex(a.owner) . " xy=" . a.x . "," . a.y)
                    if (a.q=2 && a.loc=0 && a.owner=ctx.inv)
                        cube := a
                }
            if (!IsObject(cube))
                SigFailV147("Không tìm thấy Cube trong rương")
            ctx.cubeUid := cube.uid
            phase := "CHECK_CUBE_CONTENTS",inside := SigCubeItemsV147(ctx)
            SigLogV147("TICKET130_CUBE_CONTENTS " . SigItemsTextV150(inside))
            phase := "CHECK_GOLD"
            money := ScosGoldReadV229(ctx.h,ctx.player)
            SigLogV147("TICKET130_GOLD readable=" . IsObject(money) . " carried=" . money.gold . " bank=" . money.bank . " required=" . cost)
            if (!IsObject(money))
                SigFailV147("Chưa đọc được tiền trên người; chưa lấy vật ra")
            if (money.gold + money.bank < cost)
                SigFailV147("Tổng vàng không đủ: người " . money.gold . " + rương " . money.bank . " < " . cost)
            phase := soulMode ? "FIND_PARAGON_HAMMER" : "FIND_ZAKARUM_EAR"
            reagent := Ticket130FindV265(ctx,soulMode ? "PARAGON_HAMMER" : "ZAKARUM_EAR")
            if (!IsObject(reagent))
                SigFailV147("Không tìm thấy " . reagentName . " trong rương")
            target := Min(count,Floor((money.gold + money.bank)/cost))
            SigLogV147("TICKET130_PLAN requested=" . count . " affordable=" . Floor(money.gold/cost) . " target=" . target)
            phase := "CLEAR_CUBE_TO_GROUND"
            TicketCubeClearV278(ctx,cube,inside)
            if (SigCubeItemsV147(ctx).Length())
                SigFailV147("Cube chưa trống sau khi thả đồ")
            phase := "PREPARE_GEMS"
            gems := Ticket130PrepareGemsV266(ctx,cube,target*materialPerTicket)
            phase := soulMode ? "MOVE_PARAGON_HAMMER" : "MOVE_ZAKARUM_EAR"
            Ticket130ReserveV265(ctx,reagent)
            SigToCubeV147(ctx,reagent,cube,true)
            materialIndex := 0
            Loop, %target%
            {
                SigCheckV147(ctx)
                money := ScosGoldReadV229(ctx.h,ctx.player)
                if (!IsObject(money))
                    SigFailV147("Không đọc được tiền; ngưng tạo vé")
                if (money.gold + money.bank < cost)
                {
                    message := "Tổng vàng hết (người " . money.gold . " + rương " . money.bank . " < " . cost . ")"
                    break
                }
                phase := "GET_PREPARED_MATERIALS"
                inputs := [reagent],consumed := []
                Loop, %materialPerTicket%
                {
                    materialIndex++
                    all := SigSnapshotV147(ctx),prepared := gems[materialIndex]
                    if (!all.HasKey(prepared.uid))
                        SigFailV147("Không thấy " . ctx.materialNameV267 . " đã chuẩn bị; ngưng")
                    gem := all[prepared.uid]
                    if (gem.loc=3 && materialIndex=1 && prepared.loc=3)
                        SigLogV147("TICKET_USE_MATERIAL_IN_CUBE uid=" . gem.uid . " transfer=SKIP")
                    else
                    {
                        if (gem.loc!=0 || gem.owner!=ctx.inv)
                            SigFailV147(ctx.materialNameV267 . " đã chuẩn bị không còn trong rương; ngưng")
                        phase := "MOVE_MATERIAL"
                        Ticket130ReserveV265(ctx,gem)
                        SigToCubeV147(ctx,gem,cube,true)
                    }
                    inputs.Push(gem),consumed.Push(gem)
                }
                money := ScosGoldReadV229(ctx.h,ctx.player)
                if (!IsObject(money) || (money.gold + money.bank) < cost)
                {
                    message := "Tổng vàng không đủ; ngưng trước khi cube"
                    break
                }
                phase := "TRANSMUTE"
                output := SigTransmuteV147(ctx,inputs,1,reagent)
                reagent := Ticket130RetainedV266(ctx,reagent)
                if (output[1].cls!=ticketClassV289 || D2ReadU8V18(ctx.h,output[1].data)!=2)
                    SigFailV147("Cube không ra " . ticketCaption . " (class " . ticketClassV289 . "/02); ngưng, giữ sản phẩm")
                for _,usedMaterial in consumed
                    ctx.returnHomesV265.Delete(usedMaterial.uid)
                SigReturnV147(ctx,output[1])
                done++
                SigLogV147("TICKET130_CREATED done=" . done . " requested=" . count . " uid=" . output[1].uid . " gem_class=" . gem.cls)
                ToolTipInfoV386("Tạo " . ticketCaption . ": " . done . "/" . target)
                all := SigSnapshotV147(ctx)
                if (!all.HasKey(reagent.uid) || all[reagent.uid].loc!=3)
                    SigFailV147(reagentName . " không còn trong Cube; ngưng")
                reagent := all[reagent.uid]
            }
            if (message="")
                message := target<count ? "Đã làm đủ số vé theo tiền hiện có" : "Tạo vé xong"
        }
    }
    catch e
    {
        message := e.Message
        SigLogV147("TICKET130_STOP phase=" . phase . " done=" . done . " requested=" . count . " reason=" . e.Message)
        PortalLogWriteV66("TICKET130_STOP phase=" . phase . " reason=" . e.Message)
    }
    finally
    {
        sigCancelV147 := false
        if (IsObject(ctx))
        {
            try
            {
                cursor := PickupCursorV4(ctx.h,ctx.inv)
                if (IsObject(cursor) && cursor.uid)
                {
                    all := SigSnapshotV147(ctx)
                    held := all.HasKey(cursor.uid) ? all[cursor.uid] : cursor
                    SigReturnV147(ctx,held)
                }
                if (IsObject(reagent))
                    for _,a in SigCubeItemsV147(ctx)
                        SigReturnV147(ctx,a)
                SigCloseCubeV156()
            }
            catch restoreError
            {
                cleanupOK := false
                message .= " - Chưa trả được vật: " . restoreError.Message
                SigLogV147("TICKET_RESTORE_FAILED reason=" . restoreError.Message)
            }
            DllCall("CloseHandle","Ptr",ctx.h)
        }
        sigBusyV147 := false,sigActiveModeV182 := ""
        cancelledV575 := sigCancelV147
        sigCancelV147 := false,sigBackgroundV179 := oldBackground,pickupRoundResetV1 := true
        GameItemActionEndV4("Cube")
        if (cleanupOK && IsObject(ctx) && (done>0 || ctx.cubeDroppedV278))
        {
            try
            {
                TicketPickupFinishV279(ctx.pid,level)
                message .= " - Đã kiểm tra hết món trong danh sách nhặt dưới đất"
            }
            catch pickupErrorV279
            {
                cleanupOK := false
                message := "CHƯA HOÀN TẤT: " . pickupErrorV279.Message
                SigLogV147("TICKET_PICKUP_INCOMPLETE reason=" . pickupErrorV279.Message)
            }
        }
        if (cleanupOK && !cancelledV575)
            PickupEnabledSetV71(oldPickup,true,false)
        ticket130BusyV265 := false
        FarmWatchSigGateV753(FarmWatchStateV688(),FarmWatchNowV688())
        GuiControl, Enable, SigButtonV147
        GuiControl, Enable, SigSuButtonV181
    }
    SigLogV147("TICKET130_END done=" . done . " requested=" . count . " restore_ok=" . cleanupOK . " reason=" . message)
    ToolTipInfoV386(existingTicketReadyV738 ? message : message . " - Đã tạo " . done . "/" . count . " vé.")
    SetTimer, RemoveToolTip, -6000
    return (existingTicketReadyV738 || done=count) && cleanupOK
}

LibAutoTicketChangedV293:
if (!IsObject(libAutoTicketV293))
    libAutoTicketV293 := {}
for _,tierV293 in [130,133,136,139]
{
    GuiControlGet, enabledV293,, LibAutoTicket%tierV293%V293
    libAutoTicketV293[tierV293] := enabledV293=1
}
LibAutoTicketSaveV293(currentProfile)
return

LibAutoTicketSaveV293(name)
{
    global libAutoTicketV293,ConfigFile
    if (!IsObject(libAutoTicketV293))
        return
    section := ProfileSection(name)
    for _,tier in [130,133,136,139]
        try IniWrite, % libAutoTicketV293[tier] ? 1 : 0, % ProfileConfigPathV364(section), %section%, LibAutoTicket%tier%
}

ProfileConfigPathV364(section)
{
    global ConfigFile, currentProfile, profileList
    if (SubStr(section,1,8)!="Profile_")
        return ConfigFile
    best := ""
    names := profileList . "|" . currentProfile
    Loop, Parse, names, |
    {
        name := A_LoopField
        base := ProfileSection(name)
        if (name!="" && (section=base || InStr(section,base . "_RouteMap_")=1)
            && StrLen(name)>StrLen(best))
            best := name
    }
    return best!="" ? ProfileFile(best) : ConfigFile
}

ProfileNameValidV364(name)
{
    return name!="" && !RegExMatch(name,"[\\/:*?""<>|\[\]\x00-\x1F]")
        && name=RTrim(name," .")
        && !RegExMatch(name,"i)^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(\.|$)")
}

ProfileMigrateV364()
{
    global ConfigFile, profileList
    EnsureProfileFolder()
    Loop, Parse, profileList, |
    {
        name := A_LoopField
        if (name="")
            continue
        dest := ProfileFile(name)
        if (FileExist(dest))
            continue
        old := A_ScriptDir . "\Profiles\" . SubStr(dest,StrLen(ProfileFolder())+2)
        if (FileExist(old))
            try FileCopy, %old%, %dest%, 0
        base := ProfileSection(name)
        IniRead, sections, %ConfigFile%
        Loop, Parse, sections, `n, `r
        {
            section := A_LoopField
            if (section!=base && InStr(section,base . "_RouteMap_")!=1)
                continue
            IniRead, raw, %ConfigFile%, %section%
            Loop, Parse, raw, `n, `r
            {
                at := InStr(A_LoopField,"=")
                if (!at)
                    continue
                key := SubStr(A_LoopField,1,at-1), value := SubStr(A_LoopField,at+1)
                IniRead, exists, %dest%, %section%, %key%, __MISSING_V364__
                if (exists="__MISSING_V364__")
                    try IniWrite, %value%, %dest%, %section%, %key%
            }
        }
    }
}

ProfileCaptureControlsV364(name)
{
    global mainToolHwndV67
    if (!mainToolHwndV67 || !DllCall("IsWindow", "Ptr", mainToolHwndV67))
        return
    file := ProfileFile(name), section := ProfileSection(name)
    RecoveryLoginSettingsSaveV489(name)
    Form6SaveV716(section)
    pairs := ProfileControlPairsV364()
    Loop, Parse, pairs, |
    {
        parts := StrSplit(A_LoopField,":")
        control := parts[1], key := parts[2]
        try
        {
            GuiControlGet, hwnd, 1:Hwnd, %control%
            if (ErrorLevel || !hwnd)
                continue
            GuiControlGet, value, 1:, %hwnd%
            if (ErrorLevel)
                continue
        }
        catch controlErrorV364
            continue
        if (RegExMatch(key,"i)(Delay|Interval|Seconds|Radius|Threshold|Cooldown|TapMs|Minutes|Distance|RouteCastEvery|StateID|LevelID)$")
            && value!="" && !RegExMatch(value,"^\d+(\.\d+)?$"))
            continue
        if (value="None" && !InStr(key,"DoubleKey"))
            value := ""
        if (key="RouteCastKey" || key="StuckTeleportKey")
            value := PortalCastNormalizeV50(value)
        if (key="PickupImageOn")
            value := 1
        try IniWrite, %value%, %file%, %section%, %key%
    }
}

ProfileControlPairsV364()
{
    return "MapTestModeCheckV656:MapTestMode|RouteRecordDistanceInputV649:RouteRecordMinDistance|BuffSequenceDelayInputV555:BuffSequenceDelayMs|MonsterLockRoomSecInputV622:MonsterLockRoomSec|MonsterSkipDistanceInputV752:MonsterSkipDistance|ZRunKey:ZKey|ZSetKey:ZSetKey|ZSetDelay:ZSetDelay|ZKeyF1:ZFKey|ZKeyF2:ZFKey2|ZDelay1:ZDelay1|ZDelay2:ZDelay2|XKey:XKey|XDelay:XDelay|QCastDoubleKey:QCastDoubleKey|QCastDoubleTapMs:QCastDoubleTapMs|ClickCastKeyInput:ClickCastDoubleKey|ClickCastMsInput:ClickCastDoubleTapMs|DoubleKey:DoubleKey|DoubleTapMs:DoubleTapMs|FormDoubleKey:FormDoubleKey|FormDoubleTapMs:FormDoubleTapMs|Master456KeyInput:Master456Key|AutoPotOn:AutoPotOn|PotMode:PotMode|PotHPThreshold:PotHPThreshold|PotHPThreshold2InputV299:PotHPThreshold2|PotCooldown:PotCooldown|InvHealOn:InvHealOn|CubeHealOn:CubeHealOn|InvManaOn:InvManaOn|CubeManaOn:CubeManaOn|ManaOn:ManaOn|ManaMode:ManaMode|ManaThreshold:ManaThreshold|ManaCooldown:ManaCooldown|Belt4HPKey:Belt4HPKey|Belt2HP2ManaKey:Belt2HP2ManaKey|InvToCubeKey:InvToCubeKey|CubePickupDelayInput:CubePickupDelayMs|CubeTransferDelayInput:CubeTransferDelayMs|PickupEnabledInputV79:PickupImageOn|PickupToggleKeyInputV79:PickupToggleKey|PickupRadius:PickupRadius|PickupFailTeleRadiusInputV1253:PickupFailTeleRadius|PickupStashKeyInputV14:PickupStashKey|PickupSetKeyInputV14:PickupSetKey|PickupSUKeyInputV14:PickupSUKey|SigKeyInputV147:SigKey|SigSuKeyInputV181:SigSuKey|ItemInspectKeyInputV287:ItemInspectKey|SigTUInputV586:SigTU|SigSUInputV510:SigSU|SigSSUInputV13:SigSSU|RareWarningHideInputV19:RareWarningHidden|ExcludeModeV329:ExcludeMode|ExcludeDeleteModeV332:ExcludeDeleteMode|MonsterRadiusInputV48:MonsterAttackRadius|FarmScanLimitInputV771:FarmScanLimit|MonsterLockUntilDeadInputV145:MonsterLockUntilDead|PortalCastInputV50:RouteCastKey|PortalCastEveryInputV52:RouteCastEvery|TeleportKeyInputV55:StuckTeleportKey|TeleportIntervalInputV56:StuckTeleportIntervalSeconds|ChaseCheckInputV9:ChaseCheckSeconds|MapMoveDistanceInputV197:MapMoveDistance|BOMoveMinimumInputV456:BOMoveMinimum|MoveDelayInputV810:MoveDelayMs|GoalDetourInputV14:GoalDetourDistance|ViewIdInputV54:ViewID|ViewIdInputV54:ViewID|ViewPosInputV291:ViewPos|StateBuffKeyInputV17:StateBuffCastKey|PestilenceKeyInputV18:PinnacleCastKey|AnathemaKeyInputV518:AnathemaCastKey|DeathlordStateInputV19:DeathlordStateID|PestilenceStateInputV19:PinnacleStateID|AnathemaStateInputV518:AnathemaStateID|TownLevelInputV22:TownLevelID|OutsideLevelInputV22:OutsideLevelID|ContinuousMapInputV64:ContinuousMap|FarmResetWatchCheckV217:FarmBrainResetWatch|FarmResetWatchMinutesV217:FarmBrainResetMinutes|FarmEntrySigCheckV315:FarmEntrySig|FarmEntryGoldCheckV347:FarmEntryGold|AutoLoadMapCheckV348:AutoLoadMap|PetLearnKeyInputV13:PetLearnKey|PetLearnEnabledInputV12:PetLearnEnabled|PetExcludeDistanceInputV604:PetExcludeDistance|FKey1:FKey1|FKey2:FKey2|FKey3:FKey3|FKey4:FKey4|FKey5:FKey5|FDelay1:FDelay1|FDelay2:FDelay2|FDelay3:FDelay3|FDelay4:FDelay4|FDelay5:FDelay5|QCastKey1:QCastKey1|QCastKey2:QCastKey2|QCastKey3:QCastKey3|QCastDelay1:QCastDelay1|QCastDelay2:QCastDelay2|QCastDelay3:QCastDelay3|RClickKey1:ClickCastKey1|RClickKey2:ClickCastKey2|RClickKey3:ClickCastKey3|RClickKey4:ClickCastKey4|RClickKey5:ClickCastKey5|RClickKey6:ClickCastKey6|RClickDelay1:ClickCastDelay1|RClickDelay2:ClickCastDelay2|RClickDelay3:ClickCastDelay3|RClickDelay4:ClickCastDelay4|RClickDelay5:ClickCastDelay5|RClickDelay6:ClickCastDelay6|LibAutoTicket130V293:LibAutoTicket130|LibAutoTicket133V293:LibAutoTicket133|LibAutoTicket136V293:LibAutoTicket136|LibAutoTicket139V293:LibAutoTicket139"
}

ProfileRefreshControlsV364(name)
{
    global mainToolHwndV67
    if (!mainToolHwndV67 || !DllCall("IsWindow", "Ptr", mainToolHwndV67))
        return
    file := ProfileFile(name), section := ProfileSection(name)
    pairs := ProfileControlPairsV364()
    Loop, Parse, pairs, |
    {
        parts := StrSplit(A_LoopField,":"), control := parts[1], key := parts[2]
        try
        {
            GuiControlGet, hwnd, 1:Hwnd, %control%
            if (ErrorLevel || !hwnd)
                continue
        }
        catch controlErrorV364
            continue
        IniRead, value, %file%, %section%, %key%, __MISSING_V364__
        if (key="PickupImageOn")
            value := 1
        if (value="__MISSING_V364__")
            continue
        if (InStr("|DoubleKey|FormDoubleKey|QCastDoubleKey|ClickCastKeyInput|PotMode|ManaMode|", "|" . control . "|")
            || RegExMatch(control,"^FKey[1-5]$"))
        {
            if (value="")
                value := "None"
            GuiControl, 1:ChooseString, %control%, %value%
        }
        else
            GuiControl, 1:, %control%, %value%
    }
}

ProfileControlExistsV365(control)
{
    global mainToolHwndV67
    if (!mainToolHwndV67 || !DllCall("IsWindow", "Ptr", mainToolHwndV67))
        return false
    try
    {
        GuiControlGet, controlHwndV365, 1:Hwnd, %control%
        return !ErrorLevel && controlHwndV365
    }
    catch controlErrorV365
        return false
}

ProfileStoredV520(name)
{
    if (!ProfileNameValidV364(name) || !FileExist(ProfileFile(name)))
        return false
    file := ProfileFile(name),base := ProfileSection(name)
    IniRead, sections, %file%
    Loop, Parse, sections, `n, `r
        if (A_LoopField=base)
            return true
    return false
}

ProfileDiscoverFilesV366()
{
    global profileList,ConfigFile
    names := "Default",seen := {Default:true}
    Loop, Parse, profileList, |
    {
        name := Trim(A_LoopField)
        if (name="" || seen.HasKey(name) || !ProfileStoredV520(name))
            continue
        seen[name] := true,names .= "|" . name
    }
    pattern := ProfileFolder() . "\*.ini"
    Loop, Files, %pattern%, F
    {
        SplitPath, A_LoopFileName,,,, name
        if (seen.HasKey(name) || !ProfileStoredV520(name))
            continue
        seen[name] := true,names .= "|" . name
    }
    profileList := names
    try IniWrite, %profileList%, %ConfigFile%, Profiles, Names
}

FarmTravelNoBuffV670(pid := 0,level := 0)
{
    global scosEntryV162
    r := scosEntryV162
    if (!IsObject(r) || (pid && r.pid!=pid))
        return false
    if (!level)
        level := RoomRecordLevelV259(r.pid)
    if (!level)
        return false
    if (r.map="SCOS" && level=270 && IsObject(r.scosJoinV685)
        && !r.scosInwardV696.done)
        return true
    if (FarmReviveTownLevelV295(level))
        return true
    if ((r.map="SCOS" && level=241) || (r.map="CYC" && level=137)
        || (r.map="UBU" && level=147) || (r.map="CAIN" && (level=183 || level=184)))
        return true
    c := r.commonRouteV3
    return IsObject(c) && c.pid=r.pid && c.level=level && !c.fightOn
}

MapStage1BuffFirstV368(r,ctx,player)
{
    global scosEntryV162
    if (r.stage1BuffDoneV368)
        return true
    if (FarmTravelNoBuffV670(r.pid))
    {
        r.stage1BuffDoneV368 := true
        FarmCastSyncV88(false)
        return true
    }
    if (!r.HasKey("stage1PhaseV368"))
        r.stage1PhaseV368 := r.phase
    r.phase := "ENTRY_BUFF"
    if (!RouteBuffSequenceV20(ctx.h,player,r.pid,true) || scosEntryV162!=r)
        return false
    r.phase := r.stage1PhaseV368
    r.stage1BuffDoneV368 := true
    return true
}

CainQuestReturnV369(h,player,pid)
{
    return false
}

Stage2FlowConfigureV380(mode := "NORMAL",wantClass := 0,wantData := -1,combatOn := true)
{
    global stage2FlowV380,backgroundPidV63,farmControlOwnerV186,cainHuntRouteV403
    if (mode!="NORMAL" && mode!="ITEM")
        return false
    if (mode="ITEM" && (wantClass<=0 || wantData<0))
        return false
    stage2FlowV380 := {mode:mode,pid:backgroundPidV63,owner:farmControlOwnerV186
        ,combatOnV9: combatOn ? true : false
        ,itemClass:wantClass,itemData:wantData,done:false,pickupAtV380:0
        ,levelV427:mode="ITEM" ? FarmCurrentLevelV143() : 0,flowNameV427:mode="ITEM" ? "FARM_ITEM" : "NORMAL"
        ,baselineReadyV389:false,baselineCountV389:0,currentCountV389:0}
    if (mode="ITEM")
    {
        cainHuntRouteV403 := false
        Stage2ItemBaselineInitV389()
    }
    PortalLogWriteV66("STAGE2_FLOW mode=" . mode . " class=" . wantClass . " itemdata=" . wantData
        . " combat=" . (combatOn ? "ON_FIGHT_AND_PICKUP" : "OFF_NO_FIGHT_NO_PICKUP"))
    return true
}

Stage2FightEnabledV9()
{
    if (FarmCommonRouteActiveV3())
        return FarmCommonCombatV10()

    global stage2FlowV380,backgroundPidV63,farmControlOwnerV186
    r := stage2FlowV380
    return !IsObject(r) || r.pid!=backgroundPidV63 || r.owner!=farmControlOwnerV186
        || !r.HasKey("combatOnV9") || r.combatOnV9
}

Stage2PickupEnabledV9()
{
    global stage2FlowV380,backgroundPidV63,farmControlOwnerV186
    r := stage2FlowV380
    return !IsObject(r) || r.pid!=backgroundPidV63 || r.owner!=farmControlOwnerV186
        || !r.HasKey("combatOnV9") || r.combatOnV9
}

Stage2FlowModeV380()
{
    global stage2FlowV380,backgroundPidV63,farmControlOwnerV186
    r := stage2FlowV380
    return IsObject(r) && r.pid=backgroundPidV63 && r.owner=farmControlOwnerV186 ? r.mode : "NORMAL"
}

CainModeApplyV16(r,newSession := false,enablePickup := true)
{
    global stage2FlowV380,backgroundPidV63,cainNoFightV361,cainPauseFarmV361
    global farmPickupBlockedV57,farmPickupAllowedV57,mapWorkflowV185
    if (!IsObject(r))
        return false
    if (!IsObject(mapWorkflowV185) || mapWorkflowV185.map!="CAIN")
        mapWorkflowV185 := {map:"CAIN",stage:2,startLevel:40,testRows:0}
    MapStageSetV185(2)
    r.cainLevelV19 := FarmCurrentLevelV143()
    if (CainCaveMapV502(r.cainLevelV19))
    {
        Stage2FlowConfigureV380("NORMAL",0,-1,false)
        r.cainModeV383 := "CAVE_MOVE",r.cainPickupResumeV370 := false,r.cainPickupHeldV370 := true
        cainNoFightV361 := true,cainPauseFarmV361 := true
        FarmCastSyncV88(false)
        PickupEnabledSetV71(false,true,false)
        farmPickupBlockedV57 := true,farmPickupAllowedV57 := false
        return true
    }
    if (r.cainLevelV19=185)
    {
        if (newSession || !IsObject(stage2FlowV380) || stage2FlowV380.mode!="ITEM"
            || stage2FlowV380.pid!=r.pid || stage2FlowV380.owner!="CAIN")
            CainFinalFarmBeginV388(r,enablePickup)
        r.cainModeV383 := "ITEM"
        r.cainPickupResumeV370 := enablePickup
        FarmCastSyncV88(enablePickup)
        CainIntermediatePickupResumeV370(r)
    }
    else
    {
        Stage2FlowConfigureV380("NORMAL",0,-1,true)
        r.cainModeV383 := "NORMAL"
        cainNoFightV361 := false
        r.cainPickupResumeV370 := false,r.cainPickupHeldV370 := true
        FarmCastSyncV88(true)
        PickupEnabledSetV71(false,true,false)
        farmPickupBlockedV57 := true,farmPickupAllowedV57 := false
    }
    return true
}

Stage2FlowSelectCainV380()
{
    if (FarmCommonRouteActiveV3())
    {
        Stage2FlowConfigureV380("NORMAL",0,-1,FarmCommonCombatV10())
        return
    }

    global farmControlOwnerV186,scosEntryV162,stage2FlowV380,backgroundPidV63
    if (IsObject(stage2FlowV380) && stage2FlowV380.flowNameV427="FARM_ITEM"
        && stage2FlowV380.owner=farmControlOwnerV186 && stage2FlowV380.pid=backgroundPidV63
        && stage2FlowV380.levelV427=FarmCurrentLevelV143() && !stage2FlowV380.done)
        return
    if (farmControlOwnerV186="BO" && IsObject(scosEntryV162))
    {
        wantedV413 := scosEntryV162.boStageV413=4 ? 1825 : 668
        if (!IsObject(stage2FlowV380) || stage2FlowV380.owner!="BO"
            || stage2FlowV380.pid!=backgroundPidV63 || stage2FlowV380.itemClass!=wantedV413)
            FarmItemFlowBeginV427(wantedV413,7,false)
        return
    }
    if (farmControlOwnerV186="CAIN")
    {
        if (IsObject(scosEntryV162) && scosEntryV162.cainActiveV368)
            CainModeApplyV16(scosEntryV162,false,true)
        else
            Stage2FlowConfigureV380("NORMAL",0,-1,true)
        return
    }
    Stage2FlowConfigureV380()
}

Stage2ItemDoneV380()
{
    global stage2FlowV380
    return Stage2FlowModeV380()="ITEM" && stage2FlowV380.done
}

Stage2ItemCheckV380(h,player,pid)
{
    global stage2FlowV380,scosEntryV162
    if (Stage2FlowModeV380()!="ITEM" || stage2FlowV380.pid!=pid)
        return false
    if (BOFinalRouteActiveV451(pid) && !scosEntryV162.boBossKilledV454)
        return false
    r := stage2FlowV380
    if (!r.done)
    {
        count := Stage2ItemCountV380(h,player,r.itemClass,r.itemData)
        if (count<0)
            return false
        boFarmV31 := r.owner="BO" && r.itemData=7 && IsObject(scosEntryV162)
            && scosEntryV162.map="BO" && scosEntryV162.pid=pid && scosEntryV162.phase="FARM"
        boExistingV29 := boFarmV31 && scosEntryV162.boStageV413=2 && r.itemClass=668
        boFinalPickupV31 := boFarmV31 && scosEntryV162.boStageV413=4 && r.itemClass=1825
        if (boFinalPickupV31 && !r.baselineReadyV389)
        {
            Stage2ItemBaselineSetV389(r,count)
            if (!Stage2ItemCubeBaselineV420(h,player,r))
                r.baselineReadyV389 := false
            return false
        }
        if (!boExistingV29 && !boFinalPickupV31)
        {
            if (!r.baselineReadyV389)
            {
                Stage2ItemBaselineSetV389(r,count)
                if (!Stage2ItemCubeBaselineV420(h,player,r))
                    r.baselineReadyV389 := false
                return false
            }
            r.currentCountV389 := count
            if (count<=r.baselineCountV389)
                return false
        }
        r.currentCountV389 := count
        if (!Stage2ItemNewInCubeV420(h,player,r,boExistingV29 || boFinalPickupV31,boFinalPickupV31))
            return false
        if (!BossSearchCleanupReadyV431(h,player,r))
            return false
        r.done := true
        FarmCastSyncV88(false)
        MapStage2RouteFinishV185()
        PortalLogWriteV66("STAGE2_ITEM_DONE class=" . r.itemClass . " itemdata=" . r.itemData
            . " baseline=" . r.baselineCountV389 . " current=" . r.currentCountV389
            . " gained=" . (r.currentCountV389-r.baselineCountV389)
            . " confirmed=" . (boFinalPickupV31 ? "BO_FINAL_PICKED_NEW_UID_IN_INVENTORY_OR_CUBE" : boExistingV29 ? "BO_ITEM_IN_INVENTORY_OR_CUBE" : "NEW_ITEM_IN_CUBE")
            . " next=CALLER_DECIDES")
    }
    return true
}

CainStage2AttachV379()
{
    global scosEntryV162,backgroundPidV63,coordRouteV16,routeMapIdV21
    global cainNoFightV361,cainPauseFarmV361,pickupImageOn,farmStage2DoneV372
    level := FarmCurrentLevelV143()
    if (!level || FarmReviveTownLevelV295(level))
        return false
    if (!Stage2MapWaitV381(backgroundPidV63,level,true))
    {
        PortalLogWriteV66("CAIN_ATTACH_WAIT level=" . level . " reason=FRESH_FILE_NOT_READY"
            ,"CAIN_ATTACH_WAIT",2000)
        return false
    }
    r := {map:"CAIN",pid:backgroundPidV63,until:A_TickCount+600000,phase:"MAP",row:1,last:0
        ,pickup:pickupImageOn,startLevel:40,cainActiveV368:true,cainLastLevelV361:level
        ,cainPhaseV361:level=183 ? "RUN_GD2" : level=184 ? "RUN_GD3" : "RUN_GD4",cainRouteLoadedV361:true
        ,cainMapBuffDoneV368:true,stage1BuffDoneV368:true}
    r.cainPickupResumeV370 := true,r.cainPickupHeldV370 := true
    r.cainLevelV19 := level
    r.cainPhaseV383 := "WAIT"
    r.cainItemBaselineV361 := 0
    r.cainItemWaitLogV383 := 0
    r.cainExitWaitV383 := 0
    r.cainMoveAtV383 := 0
    r.cainInteractAtV383 := 0
    r.cainRunLogV383 := 0
    r.cainWaitLogV383 := 0
    r.cainNoRouteLoggedV383 := false
    scosEntryV162 := r,cainNoFightV361 := false,cainPauseFarmV361 := false
    farmStage2DoneV372 := false
    CainModeApplyV16(r,true,true)
    SetTimer, ScosEntryTimerV162, 250
    PortalLogWriteV66("CAIN_STAGE2_START level=" . level . " route_id=" . routeMapIdV21
        . " yellow=" . coordRouteV16.yellow . " flow=" . Stage2FlowModeV380())
    return true
}

CainIntermediateMapV370(pid := 0)
{
    global scosEntryV162
    r := scosEntryV162
    if (IsObject(r) && r.map="BO" && (!pid || r.pid=pid))
        return r.phase!="TOWN"
    if (!IsObject(r) || r.map!="CAIN" || !r.cainActiveV368 || (pid && r.pid!=pid))
        return false
    if (FarmCurrentLevelV143()=185)
        return false
    phase := r.cainPhaseV383
    return phase="WAIT" || phase="RUN"
}

CainIntermediatePickupHoldV370()
{
    global scosEntryV162,pickupImageOn,farmPickupBlockedV57
    if (!CainIntermediateMapV370())
        return false
    r := scosEntryV162
    if (!r.cainPickupHeldV370)
    {
        r.cainPickupResumeV370 := pickupImageOn
        r.cainPickupHeldV370 := true
        farmPickupBlockedV57 := true
        PickupEnabledSetV71(false,true,false)
        PortalLogWriteV66("CAIN_INTERMEDIATE_CUBE_FULL town=BLOCKED pickup=PAUSED next=CAVE")
    }
    return true
}

CainIntermediatePickupResumeV370(r)
{
    global farmPickupBlockedV57,farmPickupAllowedV57
    if (!Stage2PickupEnabledV9())
    {
        r.cainPickupHeldV370 := true
        PickupEnabledSetV71(false,true,false)
        farmPickupBlockedV57 := true,farmPickupAllowedV57 := false
        return
    }
    farmPickupBlockedV57 := false
    r.cainPickupHeldV370 := false
    PickupEnabledSetV71(r.cainPickupResumeV370,true,false)
    PortalLogWriteV66("CAIN_GD4_PICKUP_RESTORED town_sig=NORMAL")
}

FarmPickupFullHoldV371()
{
    global autoMonsterAttackOn,farmPickupBlockedV57,pickupFarmWorkV75
    if (BossSearchActiveV430())
    {
        farmPickupBlockedV57 := false,pickupFarmWorkV75 := false
        return
    }
    if (!autoMonsterAttackOn)
        return
    PickupEnabledSetV71(false,true,false)
    farmPickupBlockedV57 := true
    pickupFarmWorkV75 := false
    SigLogV147("FARM_CONTAINER_FULL pickup=OFF farm=CONTINUE town_sig=OFF")
}

FarmStage2DoneCurrentV372(pid)
{
    global farmStage2DoneV372,coordRouteV16
    return IsObject(farmStage2DoneV372) && farmStage2DoneV372.pid=pid
        && farmStage2DoneV372.route=coordRouteV16 && IsObject(coordRouteV16)
        && coordRouteV16.phase="DONE"
}


MapStage2FlowTimerV372:
if (farmUserPausedV2026)
    return
if (farmManualStoppedV2026)
{
    SetTimer, MapStage2FlowTimerV372, Off
    return
}
if (cainPausedV10)
    return
MapStage2FlowCompleteV372()
return

MapStage2FlowCompleteV372()
{
    if (FarmCommonRouteActiveV3())
        return

    global mapWorkflowV185,farmControlOwnerV186,farmStage2DoneV372
    global backgroundPidV63,autoMonsterAttackOn,xRunning,zRunning,gameItemActionOwner
    global sigTownV148,sigBusyV147
    if (!IsObject(mapWorkflowV185) || mapWorkflowV185.stage!=2 || (mapWorkflowV185.map="CAIN" || mapWorkflowV185.map="BO")
        || mapWorkflowV185.map!=farmControlOwnerV186 || !FarmStage2DoneCurrentV372(backgroundPidV63))
        return
    r := farmStage2DoneV372
    if (r.handled || r.owner!=mapWorkflowV185.map || !autoMonsterAttackOn
        || xRunning || zRunning || gameItemActionOwner!="" || sigBusyV147 || IsObject(sigTownV148))
        return
    if (!FarmNormalFinalMapV577(mapWorkflowV185.map,FarmCurrentLevelV143()))
        return
    if (Lab1SingleRunV310())
    {
        r.handled := true
        if (!FarmStage3RequestV313("COMPLETE"))
        {
            FarmErrorKeepV769("LAB_STAGE3_HANDOFF_FAILED")
        }
        return
    }
    r.handled := true
    if (FarmStage3RequestV313("COMPLETE"))
    {
        PortalLogWriteV66("MAP_FLOW_STAGE2_DONE next=STAGE3_DLL no_town=1")
        return
    }
    FarmErrorKeepV769("MAP_STAGE3_HANDOFF_FAILED")
    FarmCombatYieldV237()
    PickupEnabledSetV71(false,true,false)
    farmRestartReasonV238 := ""
    ToolTipInfoV386("Đã hết lộ trình — giữ phiên farm, chờ xử lý chuyển bước.")
    SetTimer, RemoveToolTip, -4000
    PortalLogWriteV66("MAP_FLOW_STAGE2_DONE next=ERROR_KEEP_FARM")
}

ScosEntryMoveV162(ctx,x,y)
{
    return MapStage1MoveV374(ctx,x,y)
}

MapStage9V373(ctx,level,target,kind:="AUTO",destination:=0)
{
    if (!IsObject(ctx) || !IsObject(target) || !target.uid)
        return false
    if (kind="WP" && destination>0)
    {
        bytes := [0x49]
        SigDwordV147(bytes,target.uid)
        SigDwordV147(bytes,destination)
        SigPacketV147(ctx,bytes)
        return true
    }
    if (kind="WP")
    {
        if (IsObject(ctx.entryStateV42) && ctx.entryStateV42.map="CAIN")
        {
            live := {unit:target.unit,uid:target.uid,cls:target.cls,typ:2,x:target.x,y:target.y}
            return EnterPortalInteractV363(ctx.pid,level,live)
        }
        return SigTownPortalInteractV148(ctx.pid,level,target,true)
    }
    typ := target.HasKey("typ") ? target.typ : D2ReadU32(ctx.h,target.unit)
    if (typ!=2 && typ!=5)
        typ := 2
    fullTarget := {unit:target.unit,uid:target.uid,cls:target.cls,typ:typ,x:target.x,y:target.y}
    return EnterPortalInteractV363(ctx.pid,level,fullTarget)
}


MapSigFlowV374(mode:="BOTH")
{
    global autoMonsterAttackOn
    ; MapStage1SigReadyV374 has already checked the option frozen at
    ; map-button press. Do not silently skip SIG if the GUI changes later.
    FarmAttackHoldReleaseV15()
    autoMonsterAttackOn := false
    SetTimer, AutoMonsterAttackTimer, Off
    FarmCastSyncV88(false)
    return SigStartBackgroundV183(mode)
}


RoutePlanNewV375:
RoutePlanChooseV375(true)
return
RoutePlanOpenV375:
RoutePlanChooseV375(false)
return

RoutePlanChooseV375(create)
{
    global routeRecordV358
    if (IsObject(routeRecordV358))
        return
    root := A_ScriptDir . "\LoTrinh"
    try FileCreateDir, %root%
    options := create ? "S16" : "3"
    FileSelectFile, chosen, %options%, % root . "\Farm-Flow.txt", Chọn file lộ trình, Lộ trình (*.txt)
    if (chosen="")
        return
    if (!RegExMatch(chosen,"i)\.txt$"))
        chosen .= ".txt"
    if (!FileExist(chosen))
    {
        f := FileOpen(chosen,"w","UTF-8")
        if (!IsObject(f))
            return RoutePlanErrorV375()
        f.Write("`; FARM FLOW - các bước chạy từ trên xuống`r`n`; MOVE = GĐ1 không đánh`; FARM = GĐ2 chung, hết map báo DONE`r`n`; WP / CAVE / PORTAL = GĐ9`; SIG / GOLD gọi theo checkbox`r`n`; BOSS class=... `; PICK class=1839 itemdata=07 `; TOWN `; NEWGAME`r`n")
        f.Close()
    }
    RoutePlanLoadV375(chosen)
}

RoutePlanLoadV375(file)
{
    global routePlanV375,ConfigFile
    f := FileOpen(file,"r","UTF-8")
    if (!IsObject(f))
        return RoutePlanErrorV375()
    raw := f.Read(),f.Close()
    routePlanV375.file := file
    GuiControl, RoutePlan:, PlanTextV375, %raw%
    GuiControl, RoutePlan:, PlanFileV375, %file%
    try IniWrite, %file%, %ConfigFile%, RoutePlan, LastFile
    return true
}

RoutePlanSaveLabelV375:
RoutePlanSaveV375()
return
RoutePlanSaveV375()
{
    global routePlanV375,routeRecordV358
    if (!IsObject(routePlanV375) || routePlanV375.file="" || IsObject(routeRecordV358))
        return false
    GuiControlGet, raw, RoutePlan:, PlanTextV375
    raw := StrReplace(StrReplace(raw,"`r`n","`n"),"`r","`n")
    raw := StrReplace(raw,"`n","`r`n")
    temp := routePlanV375.file . ".tmp"
    f := FileOpen(temp,"w","UTF-8")
    if (!IsObject(f))
        return RoutePlanErrorV375()
    f.Write(raw),f.Close()
    try FileMove, %temp%, % routePlanV375.file, 1
    if (ErrorLevel)
        return RoutePlanErrorV375()
    return true
}

RoutePlanRecordV375:
RoutePlanRecordStartV375()
return
RoutePlanRecordStartV375()
{
    global routePlanV375,routeRecordV358,roomRecordV108,backgroundPidV63,backgroundHwndV63
    if (IsObject(routeRecordV358))
        return
    if (IsObject(roomRecordV108))
    {
        ToolTipInfoV386("Dừng bộ ghi tọa độ cũ trước khi ghi lộ trình này.")
        SetTimer, RemoveToolTip, -3000
        return
    }
    if (!RoutePlanSaveV375())
    {
        ToolTipInfoV386("Chọn File mới hoặc Mở file trước khi Ghi tiếp.")
        SetTimer, RemoveToolTip, -3000
        return
    }
    if (!SigBackgroundBindV179() || !PickupActivateGameV13())
        return
    routeRecordV358 := {pid:backgroundPidV63,hwnd:backgroundHwndV63,startAt:A_TickCount,clicks:[],planV375:true}
    RoutePlanRecordingUiV375(true)
    Hotkey, ~*LButton, RouteRecordMouseDownV358, On
    ToolTipInfoV386("Đang ghi tiếp: chỉ click trái trong game; không ghi các tọa độ di chuyển trung gian.")
    SetTimer, RemoveToolTip, -4000
}

RoutePlanStopV375:
RouteRecordStopV358("PLAN_PAUSE")
return
RoutePlanGuiClose:
RoutePlanGuiEscape:
RouteRecordStopV358("PLAN_CLOSE")
RoutePlanSaveV375()
Gui, RoutePlan:Hide
return

RoutePlanRecordingUiV375(active)
{
    state := active ? "Disable" : "Enable"
    for _,control in ["PlanNewV375","PlanOpenV375","PlanSaveV375","PlanAddV375","PlanRecordV375"]
        GuiControl, RoutePlan:%state%, %control%
    option := active ? "+ReadOnly" : "-ReadOnly"
    GuiControl, RoutePlan:%option%, PlanTextV375
}

RoutePlanAddV375:
if (IsObject(routeRecordV358) || !RoutePlanSaveV375())
    return
GuiControlGet, kindV375, RoutePlan:, PlanActionV375
kindsV375 := {"WP":"WP","Chui hang":"CAVE","Vào cổng":"PORTAL","Đánh boss":"BOSS"
    ,"Nhặt item":"PICK","Farm GĐ2":"FARM","SIG":"SIG","Cất tiền":"GOLD"
    ,"Về thành":"TOWN","Tạo game mới":"NEWGAME","DONE":"DONE"}
kindV375 := kindsV375[kindV375]
GuiControlGet, paramsV375, RoutePlan:, PlanParamsV375
RoutePlanAppendV375(kindV375 . (Trim(paramsV375)!="" ? " " . Trim(paramsV375) : ""))
return

RoutePlanAppendV375(line)
{
    global routePlanV375
    if (!IsObject(routePlanV375) || routePlanV375.file="")
        return false
    f := FileOpen(routePlanV375.file,"r","UTF-8")
    if (!IsObject(f))
        return RoutePlanErrorV375()
    raw := f.Read(),f.Close()
    prefix := (raw!="" && SubStr(raw,0)!="`n") ? "`r`n" : ""
    f := FileOpen(routePlanV375.file,"a","UTF-8")
    if (!IsObject(f))
        return RoutePlanErrorV375()
    f.Write(prefix . line . "`r`n"),f.Close()
    GuiControl, RoutePlan:, PlanTextV375, % raw . prefix . line . "`r`n"
    return true
}

RoutePlanCopyV375:
GuiControlGet, copyV375, RoutePlan:, PlanTextV375
Clipboard := copyV375
return

RoutePlanErrorV375()
{
    ToolTipInfoV386("Không ghi/đọc được file lộ trình; các dòng cũ được giữ.")
    SetTimer, RemoveToolTip, -4000
    return false
}

SigResumePickupV655(state)
{
    global sigSessionActiveV1321,pickupSigListOnlyV1321
    global sigBusyV147,sigCancelV147,sigActiveModeV182,sigLastStopReasonV63,sigBackgroundV179
    global pickupImageOn,pickupTimerBusy,sigPostPickupV655,sigCompleteSerialV655,sigCompletePidV655,ticketPickupWaitV279,sigResetPendingV753
    if (!IsObject(state) || sigBusyV147 || IsObject(ticketPickupWaitV279) || pickupTimerBusy || !BackgroundValidV63()
        || D2GetActiveGamePidV95()!=state.pid || !GameItemActionBeginV4("Cube","cube",false))
        return false
    oldBackground := sigBackgroundV179
    sigBackgroundV179 := true
    sigBusyV147 := true,sigCancelV147 := false,sigActiveModeV182 := "SET_SU"
    sigSessionActiveV1321 := true
    GuiControl, 1:, SigButtonV147, Hủy
    try
    {
        if (!SigWaitPickupDoneV320(state.pid,state.level,state.scope))
            return false
        sigPostPickupV655 := false,sigCompleteSerialV655++,sigCompletePidV655 := state.pid
        sigResetPendingV753 := false
        sigLastStopReasonV63 := "COMPLETED_PICKUP_VERIFIED"
        pickupSigListOnlyV1321 := true
        PickupEnabledSetV71(true,true,false)
        SigLogV147("SIG_RESUME_DONE_NORMAL_PICKUP_ON filter=ITEM_NHAT_TXT_ONLY")
        return true
    }
    catch pickupErrorV655
    {
        sigLastStopReasonV63 := pickupErrorV655.Message
        FonInfoPushV385("[SIG] Chưa nhặt xong: " . pickupErrorV655.Message)
        return false
    }
    finally
    {
        sigBusyV147 := false,sigActiveModeV182 := "",sigBackgroundV179 := oldBackground
        sigSessionActiveV1321 := false
        FarmWatchSigGateV753(FarmWatchStateV688(),FarmWatchNowV688())
        GameItemActionEndV4("Cube")
        GuiControl, 1:, SigButtonV147, Sig
    }
}


MapStage1SigReadyV374(r)
{
    global scosEntryV162,sigCancelV147,sigLastStopReasonV63,sigPostPickupV655,sigCompleteSerialV655,sigCompletePidV655
    global sigBusyV147,sigActiveModeV182,pickupTimerBusy,ticketPickupWaitV279
    if (r.sigErrorHoldV769)
        return false
    if (r.stage1SigDoneV374 || r.preSigDoneV310)
        return true
    if (r.HasKey("entrySigV315"))
        enabledV374 := r.entrySigV315
    else
        GuiControlGet, enabledV374, 1:, FarmEntrySigCheckV315
    if (!enabledV374)
    {
        r.stage1SigDoneV374 := true
        return true
    }
    if (r.stage1SigBlockedV654)
    {
        if (sigCompletePidV655=r.pid && sigCompleteSerialV655>r.sigFailedSerialV655)
        {
            r.stage1SigBlockedV654 := false,r.stage1SigDoneV374 := true,r.preSigDoneV310 := true
            return true
        }
        if (SigProtectionEndedV761(r.pid))
        {
            r.stage1SigBlockedV654 := false
            return false
        }
        if (sigCancelV147)
            return SigEntryStopV762(r,"Đã hủy SIG")
        if (InStr(sigLastStopReasonV63,"Packet transmute"))
            return SigEntryStopV762(r,sigLastStopReasonV63)
        if (r.sigAttemptsV762>=3 || A_TickCount-r.sigFailedAtV762>=360000)
            return SigEntryStopV762(r,"SIG thất bại sau tối đa 3 lượt: " . sigLastStopReasonV63)
        if (A_TickCount<r.sigRetryAtV762)
            return false
        if (sigBusyV147 || sigActiveModeV182!="" || pickupTimerBusy
            || IsObject(ticketPickupWaitV279) || RemoteThreadBusyV740(r.pid))
        {
            if (A_TickCount-r.sigWaitAtV762>=15000)
                return SigEntryStopV762(r,"Lệnh trước chưa kết thúc sau 15 giây; giữ đồ và dừng")
            return false
        }
    }
    r.sigAttemptsV762 := r.sigAttemptsV762+1
    before := A_TickCount
    if (r.stage1SigBlockedV654 && IsObject(sigPostPickupV655) && sigPostPickupV655.pid=r.pid)
        ok := SigResumePickupV655(sigPostPickupV655)
    else
        ok := MapSigFlowV374()
    if (scosEntryV162!=r)
        return false
    r.until += A_TickCount-before
    if (ok)
    {
        r.stage1SigBlockedV654 := false,r.stage1SigDoneV374 := true,r.preSigDoneV310 := true
        return true
    }
    if (SigProtectionEndedV761(r.pid))
    {
        r.stage1SigBlockedV654 := false
        return false
    }
    r.stage1SigDoneV374 := false,r.preSigDoneV310 := false,r.stage1SigBlockedV654 := true
    r.sigFailedSerialV655 := sigCompleteSerialV655+0
    if (!r.sigFailedAtV762)
        r.sigFailedAtV762 := A_TickCount
    r.sigWaitAtV762 := A_TickCount,r.sigRetryAtV762 := A_TickCount+3000
    FonInfoPushV385("[SIG] Lượt " . r.sigAttemptsV762 . "/3 lỗi: " . sigLastStopReasonV63)
	if (InStr(sigLastStopReasonV63,"Packet transmute") && InStr(sigLastStopReasonV63,"đã thu hồi đồ"))
	{
    r.stage1SigBlockedV654 := false
    r.stage1SigDoneV374 := true
    r.preSigDoneV310 := true
    r.sigErrorHoldV769 := false
    SigLogV147("SIG_ENTRY_SKIP reason=TRANSMUTE_FAILED_RECOVERED_OK next=CONTINUE_FARM")
    return true
	}
if (sigCancelV147 || r.sigAttemptsV762>=3)
    return SigEntryStopV762(r,sigLastStopReasonV63)
    return false
}

