# Feature Specification: Wallpaper Browse, Collections & Detail

**Feature Branch**: `MO-003-wallpaper-browse-detail`

**Created**: 2026-07-24

**Status**: Draft

**Input**: User description: "MO-003 Wallpaper Browse, Collections & Detail — List/grid wallpaper với cursor pagination, filter tag chips (thẻ ảo 'All'), search, tab Bộ sưu tập + Collection Detail, Wallpaper Detail + preview video full-screen. Chuyển từ mock Prism sang API thật (backend BE-002/BE-003 đã merge)."

## Context & Scope Boundary

MO-003 là spec **nội dung nghiệp vụ đầu tiên** đứng lên khung MO-002 đã bàn giao (theme dark-only, 11 shared widget, nav shell 5 tab, route Detail/Collection placeholder). Nó biến các tab placeholder **Khám phá / Tìm / Bộ sưu tập** và các route Detail rỗng thành màn hình thật, chạy trên **API backend thật** (BE-002/BE-003 đã merge, có seed data) thay cho mock Prism.

Giá trị bàn giao: người dùng duyệt được thư viện wallpaper thật, lọc theo tag, tìm kiếm, xem chi tiết + preview video toàn màn hình, và duyệt các bộ sưu tập được tuyển chọn.

**Ngoài phạm vi (thuộc spec sau):**

- Lưu/hiển thị Favorites local (`POST /wallpapers/batch`, reconcile) → **MO-004** (tab "Yêu thích" giữ nguyên placeholder MO-002).
- Set wallpaper native (Android `WallpaperService` / iOS Shortcuts) → **MO-005**. Trong MO-003, nút "Đặt làm hình nền" ở Wallpaper Detail chỉ là điểm neo điều hướng chưa gắn hành vi native.
- Luồng IAP/paywall thật + mở khoá entitlement → **MO-006**. Trong MO-003, nội dung premium chỉ **hiển thị trạng thái khoá** (badge PRO, nút "Mở khoá"/"Tải tất cả"); chạm vào chỉ mở placeholder paywall, chưa verify receipt, chưa cấp quyền tải.
- Tải file wallpaper thật xuống thiết bị (`GET /wallpapers/{id}/download-url`) → gắn cùng MO-005/MO-006. MO-003 không thực hiện tải file gốc.

**Ranh giới quan trọng**: MO-003 tập trung **duyệt + xem + preview** (đọc dữ liệu). Mọi hành vi ghi (favorite, tải, đặt, mua) thuộc spec sau.

## Clarifications

### Session 2026-07-24

- Q: Wallpaper Detail có nút "Đặt làm hình nền" và "Tải xuống" — trong MO-003 các nút này làm gì? → A: Chỉ là **điểm neo điều hướng/placeholder**; hành vi native + tải file thật để MO-005/MO-006. MO-003 render nút đúng thị giác nhưng chạm vào mở placeholder tương ứng, không thực thi.
- Q: Search tìm theo gì và trả kết quả thế nào? → A: Tìm full-text theo từ khoá người dùng nhập, gọi `GET /wallpapers` với tham số tìm kiếm (cùng cursor pagination như Browse), kết quả hiển thị dạng grid giống Khám phá; có trạng thái rỗng khi không khớp.
- Q: Nội dung premium trong MO-003 xử lý ra sao (chưa có IAP)? → A: **Chỉ hiển thị trạng thái khoá** — badge PRO trên tile, nút "Mở khoá"/"Tải tất cả" ở Collection premium; chạm mở placeholder paywall (route đã có từ MO-002), KHÔNG verify, KHÔNG cấp quyền. Entitlement thật để MO-006.
- Q: Trạng thái đang tải hiển thị thế nào? → A: **Skeleton shimmer** cho mọi màn có tải dữ liệu (lưới Khám phá/Tìm, danh sách + chi tiết Bộ sưu tập, Wallpaper Detail). Placeholder phải **khớp bố cục nội dung thật** (đúng hình dạng/tỉ lệ ô, số cột, vị trí) và **khớp design system dark aurora** (Principle VI). Shimmer **KHÔNG chạy theo thời gian cố định** — nó gắn với trạng thái `loading` và **dừng đúng khoảnh khắc** state chuyển sang `loaded`/`error` (dữ liệu về hoặc lỗi), không sớm-không muộn, không delay giả tạo.
- Q: Tab Tìm kích hoạt tìm kiếm khi nào? → A: **Live gõ + debounce ~350ms, bắt đầu từ ≥2 ký tự.** Gõ dưới 2 ký tự không gọi API (giữ trạng thái ban đầu/gợi ý); mỗi lần từ khoá đổi (sau debounce) huỷ request cũ, chỉ hiển thị kết quả từ khoá mới nhất (FR-021).
- Q: Màn Khám phá lọc theo chiều nào (contract có cả `category` và `tags`)? → A: **Chỉ một hàng tag chips single-select** lấy từ `GET /tags`, map vào param `tags`. Tại một thời điểm chỉ 1 chip được chọn (mặc định "Tất cả"). KHÔNG dùng `category` và KHÔNG multi-select tag trong MO-003 (để spec sau nếu cần).
- Q: Các list (Khám phá / Bộ sưu tập) có pull-to-refresh không? → A: **Có.** Kéo xuống ở đầu list làm mới từ đầu (reset cursor, tải lại trang đầu); áp dụng cho lưới Khám phá, kết quả Tìm, và danh sách Bộ sưu tập.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Duyệt thư viện wallpaper với lọc tag (Priority: P1)

Người dùng mở tab **Khám phá** và thấy một lưới wallpaper động: mỗi ô tự phát bản preview video lặp, không tiếng. Cuộn xuống thì thư viện tải thêm mượt mà (không có nút "trang sau"), cuộn tiếp tới hết thì dừng. Một hàng chip tag ở đầu màn cho phép lọc; chip đầu tiên là **"Tất cả"** (mặc định chọn), chạm một tag khác thì lưới lọc lại chỉ còn wallpaper thuộc tag đó, chạm "Tất cả" thì trở về toàn bộ (mới → cũ).

**Why this priority**: Đây là màn hình cốt lõi của sản phẩm — lý do người dùng mở app. Không có Browse thì không có gì để xem, chọn, hay đặt. Lát cắt tối thiểu chạy được: một lưới wallpaper thật, phân trang đúng, lọc được — tự nó đã là MVP có giá trị.

**Independent Test**: Mở tab Khám phá với backend thật có seed data; xác nhận lưới hiển thị wallpaper thật (không phải mock), các ô tự phát preview; cuộn tới gần cuối thấy trang kế tự tải; cuộn tới hết thấy dừng đúng lúc; chạm một tag thấy lưới lọc lại, chạm "Tất cả" thấy trở về toàn bộ.

**Acceptance Scenarios**:

1. **Given** tab Khám phá vừa mở và dữ liệu chưa về, **When** đang tải trang đầu, **Then** hiển thị lưới **skeleton shimmer** đúng số cột và hình dạng ô như nội dung thật; khi dữ liệu về (state `loaded`), skeleton được thay ngay bằng lưới thật — không có độ trễ giả tạo.
2. **Given** tab Khám phá vừa mở, **When** dữ liệu tải xong, **Then** lưới hiển thị các wallpaper mới nhất (mới → cũ) với mỗi ô tự phát preview video lặp không tiếng, và chip "Tất cả" đang được chọn.
3. **Given** đang xem lưới và cuộn gần tới cuối danh sách hiện có, **When** vị trí cuộn chạm ngưỡng gần cuối, **Then** trang kế tiếp được tải và nối thêm vào lưới mà không làm gián đoạn thao tác cuộn (hiển thị chỉ báo/skeleton tải thêm ở cuối, dừng khi trang về).
4. **Given** đã cuộn tới wallpaper cuối cùng của thư viện, **When** không còn dữ liệu, **Then** không còn tải thêm và không hiện chỉ báo tải (kết thúc phân trang gọn).
5. **Given** đang xem "Tất cả", **When** chạm một chip tag cụ thể, **Then** lưới làm mới chỉ còn wallpaper thuộc tag đó (phân trang lại từ đầu theo tag), và chip đó được đánh dấu chọn.
6. **Given** đang lọc theo một tag, **When** chạm lại chip "Tất cả", **Then** lưới trở về toàn bộ wallpaper mới → cũ.
7. **Given** cuộn nhanh qua nhiều màn hình wallpaper, **When** các ô ra khỏi vùng nhìn, **Then** ứng dụng không phình bộ nhớ / không giật (video của ô ngoài vùng nhìn được giải phóng, chỉ ô đang/ sắp hiện mới phát).
8. **Given** backend lỗi hoặc mất mạng khi tải trang đầu, **When** người dùng ở tab Khám phá, **Then** hiện trạng thái lỗi thân thiện (không phải text kỹ thuật) kèm khả năng thử lại.
9. **Given** đang xem lưới đã tải, **When** kéo xuống ở đầu lưới (pull-to-refresh), **Then** danh sách tải lại từ đầu (reset cursor) và hiển thị dữ liệu mới nhất theo tag đang chọn.

---

### User Story 2 - Xem chi tiết wallpaper + preview video toàn màn hình (Priority: P2)

Từ bất kỳ ô nào trong lưới (Khám phá, Tìm, hay Collection Detail), người dùng chạm vào một wallpaper và mở màn **Wallpaper Detail** phủ toàn màn hình: video preview phát lặp lớn, tên/thông tin (tag, chỉ báo premium nếu có), và — nếu wallpaper thuộc bộ sưu tập — một liên kết "Từ bộ sưu tập · …" để nhảy sang Collection Detail. Các nút "Đặt làm hình nền" / "Tải xuống" hiển thị đúng thị giác (hành vi thật để spec sau).

**Why this priority**: Detail là cầu nối giữa "duyệt" và "hành động". Người dùng cần xem lớn, rõ trước khi quyết định. Nó cũng nối Browse với Collections qua liên kết ngược. Đứng độc lập được ngay khi có US1 làm nguồn.

**Independent Test**: Chạm một wallpaper trong lưới; xác nhận màn Detail phủ full-screen với video phát lặp lớn và metadata đúng; nếu wallpaper premium thấy chỉ báo/khoá; nếu wallpaper thuộc bộ sưu tập thấy liên kết dẫn sang đúng Collection Detail; back trả về đúng nguồn.

**Acceptance Scenarios**:

1. **Given** đang xem lưới, **When** chạm một wallpaper, **Then** màn Wallpaper Detail mở phủ toàn màn hình; trong lúc video/metadata chưa sẵn sàng, vùng preview và các khối thông tin hiển thị **skeleton shimmer** khớp bố cục, thay bằng nội dung thật ngay khi state `loaded`.
2. **Given** ở màn Wallpaper Detail đã tải xong, **When** xem, **Then** video preview phát lặp không tiếng ở kích thước lớn và thông tin wallpaper (tên, tag) hiển thị đầy đủ.
3. **Given** wallpaper đang xem là premium, **When** ở màn Detail, **Then** hiển thị chỉ báo premium (badge PRO) và các hành động gated thể hiện trạng thái khoá — KHÔNG cấp quyền tải/đặt trong MO-003.
4. **Given** wallpaper thuộc một hay nhiều bộ sưu tập, **When** ở màn Detail, **Then** hiển thị liên kết "Từ bộ sưu tập · <tên>"; chạm vào mở đúng Collection Detail tương ứng.
5. **Given** đang ở màn Detail, **When** chạm back, **Then** trở về đúng màn nguồn (Khám phá / Tìm / Collection Detail) tại vị trí cũ.
6. **Given** wallpaper đã bị admin gỡ (không còn tồn tại), **When** mở Detail, **Then** hiện trạng thái "không tìm thấy" thân thiện thay vì lỗi kỹ thuật.

---

### User Story 3 - Duyệt bộ sưu tập được tuyển chọn (Priority: P3)

Người dùng mở tab **Bộ sưu tập** và thấy danh sách các cover card bộ sưu tập được tuyển chọn. Chạm một bộ sưu tập mở màn **Collection Detail**: ảnh/hero cover lớn, mô tả, và lưới các wallpaper thuộc bộ (đúng thứ tự đã tuyển). Bộ premium hiển thị nút "Mở khoá" và "Tải tất cả" ở trạng thái khoá (hành vi thật để MO-006).

**Why this priority**: Collections là cách khám phá theo chủ đề, tăng chiều sâu nội dung, nhưng không phải đường vào cốt lõi — người dùng vẫn dùng được app đầy đủ chỉ với Browse + Detail. Vì vậy P3.

**Independent Test**: Mở tab Bộ sưu tập với seed data; xác nhận danh sách cover card thật; chạm một bộ mở Collection Detail với hero cover + lưới wallpaper đúng thứ tự; bộ premium hiện nút "Mở khoá"/"Tải tất cả" ở trạng thái khoá; chạm một wallpaper trong bộ mở Wallpaper Detail.

**Acceptance Scenarios**:

1. **Given** tab Bộ sưu tập vừa mở và dữ liệu chưa về, **When** đang tải, **Then** hiển thị **skeleton shimmer** dạng cover card khớp bố cục, thay bằng danh sách thật ngay khi state `loaded`.
2. **Given** tab Bộ sưu tập vừa mở, **When** dữ liệu tải xong, **Then** hiển thị danh sách cover card các bộ sưu tập được tuyển chọn (không phân trang).
3. **Given** đang xem danh sách bộ sưu tập, **When** chạm một cover card, **Then** mở Collection Detail phủ full-screen (hero + lưới hiển thị skeleton shimmer trong lúc tải) với hero cover, mô tả, và lưới wallpaper thuộc bộ theo đúng thứ tự tuyển chọn.
4. **Given** bộ sưu tập là premium, **When** ở Collection Detail, **Then** hiển thị nút "Mở khoá" và "Tải tất cả" ở trạng thái khoá; chạm mở placeholder paywall, KHÔNG cấp quyền tải trong MO-003.
5. **Given** đang ở Collection Detail, **When** chạm một wallpaper trong lưới, **Then** mở Wallpaper Detail của wallpaper đó; back trả về Collection Detail.
6. **Given** một bộ sưu tập trống hoặc lỗi tải, **When** mở Collection Detail, **Then** hiện trạng thái rỗng/lỗi thân thiện.

---

### User Story 4 - Tìm kiếm wallpaper (Priority: P4)

Người dùng mở tab **Tìm**, nhập từ khoá, và thấy lưới kết quả wallpaper khớp — cùng kiểu lưới, preview và phân trang như Khám phá. Không có kết quả thì hiện trạng thái rỗng gợi ý thử từ khác.

**Why this priority**: Search hữu ích khi thư viện lớn nhưng là đường tắt, không phải đường chính; Browse + tag đã đủ khám phá. P4 — làm sau khi ba luồng trên vững.

**Independent Test**: Mở tab Tìm, nhập một từ khoá khớp seed data; xác nhận lưới kết quả hiển thị với preview + phân trang; nhập từ khoá không khớp thấy trạng thái rỗng; chạm một kết quả mở Wallpaper Detail.

**Acceptance Scenarios**:

1. **Given** tab Tìm vừa mở (chưa nhập gì), **When** người dùng nhìn màn, **Then** hiển thị trạng thái ban đầu/gợi ý (chưa có kết quả), không tải toàn bộ thư viện một cách vô ích.
2. **Given** ô tìm đang trống, **When** người dùng gõ 1 ký tự, **Then** CHƯA gọi tìm kiếm; **When** đạt ≥2 ký tự và ngừng gõ ~350ms, **Then** tìm kiếm chạy một lần cho từ khoá hiện tại (không gọi mỗi phím).
3. **Given** người dùng nhập một từ khoá có kết quả, **When** tìm kiếm đang chạy, **Then** vùng kết quả hiển thị **skeleton shimmer** lưới, thay bằng lưới kết quả thật (preview tự phát, phân trang cursor như Khám phá) ngay khi kết quả về — shimmer dừng theo state, không theo timer.
4. **Given** người dùng nhập một từ khoá không khớp gì, **When** tìm kiếm thực thi, **Then** hiển thị trạng thái rỗng thân thiện gợi ý thử từ khác.
5. **Given** đang xem kết quả tìm, **When** chạm một wallpaper, **Then** mở Wallpaper Detail; back trả về kết quả tìm tại vị trí cũ.

---

### Edge Cases

- **Cuộn cực nhanh qua nhiều trang**: số video controller đồng thời phải luôn bị chặn trên (chỉ ô hiện/gần hiện); ô ngoài vùng nhìn giải phóng video để không tràn RAM / cạn decoder (Principle II — NON-NEGOTIABLE).
- **Cursor không hợp lệ / hết hạn giữa chừng**: xử lý như lỗi tải trang, cho thử lại, không crash.
- **Tag "Tất cả" (thẻ ảo id:0, slug:"all")**: chọn "All" = gọi list KHÔNG truyền `tags`; không gửi `tags=all` lên server.
- **Wallpaper/Collection bị admin gỡ giữa phiên**: mở Detail của nó → trạng thái "không tìm thấy" thân thiện, không lỗi kỹ thuật.
- **Mất mạng khi đang cuộn tải thêm**: giữ nội dung đã tải, hiện lỗi ở phần tải thêm với khả năng thử lại, không xoá lưới hiện có.
- **Video preview lỗi tải (1 ô)**: ô đó hiển thị fallback (poster/ảnh tĩnh hoặc khung placeholder) thay vì làm sập cả lưới.
- **Chuyển tag/từ khoá liên tục nhanh**: request cũ bị huỷ/bỏ qua, chỉ kết quả của lựa chọn mới nhất được hiển thị (không nhấp nháy kết quả cũ).
- **Bộ sưu tập có wallpaper premium lẫn free**: mỗi tile phản ánh trạng thái premium của chính nó; nút cấp-bộ ("Tải tất cả") vẫn ở trạng thái khoá theo `is_premium` của bộ.
- **iPad/tablet**: lưới tăng số cột theo breakpoint (đã responsive-ready từ MO-002); Detail/Collection Detail không vỡ layout ở màn rộng. Skeleton shimmer cũng phải đúng số cột theo breakpoint (không phải layout skeleton của điện thoại phóng to).
- **Phản hồi cực nhanh (cache/mạng tốt)**: nếu `loaded` tới gần như tức thời, shimmer chỉ thoáng qua/không kịp hiện — KHÔNG được cố tình giữ shimmer thêm cho "đủ đẹp"; state quyết định, không timer.
- **Chuyển tag/từ khoá khi đang có nội dung cũ**: khi bắt đầu tải bộ mới, màn quay lại skeleton shimmer (thay vì giữ nội dung cũ mờ đi) để tín hiệu tải rõ ràng, rồi thay bằng kết quả mới khi về.

## Requirements *(mandatory)*

### Functional Requirements

**Browse / Lưới wallpaper (US1)**

- **FR-001**: Tab Khám phá MUST hiển thị wallpaper dạng lưới lười (lazy grid), tải từ backend thật, sắp xếp mới → cũ theo mặc định.
- **FR-002**: Mỗi ô lưới MUST tự phát bản preview video độ phân giải thấp, lặp, không tiếng; file gốc/full-res KHÔNG được tải khi đang duyệt.
- **FR-003**: Danh sách MUST dùng phân trang cursor-based theo contract (`cursor` / `next_cursor`); MUST tải trang kế khi vị trí cuộn tới gần cuối, và dừng khi hết dữ liệu (`has_more: false`). Phân trang offset/page phía client bị CẤM.
- **FR-004**: Ứng dụng MUST giới hạn số `VideoPlayerController` khởi tạo đồng thời (chỉ ô đang/gần hiện); ô rời vùng nhìn MUST được giải phóng controller và tạo lại khi quay lại vùng nhìn.
- **FR-005**: Màn Khám phá MUST hiển thị một hàng chip tag **single-select** lấy từ danh mục tag tuyển chọn của backend (`GET /tags`); phần tử đầu là thẻ ảo "Tất cả" và là chip được chọn mặc định. Tại một thời điểm chỉ một chip được chọn. MO-003 KHÔNG dùng bộ lọc `category` và KHÔNG cho multi-select tag (để spec sau nếu cần).
- **FR-006**: Chọn "Tất cả" MUST tải toàn bộ wallpaper (không truyền tham số `tags`); chọn một tag cụ thể MUST tải lại danh sách chỉ gồm wallpaper thuộc tag đó (truyền param `tags`, phân trang lại từ đầu).
- **FR-007**: Khi tải trang đầu thất bại (mạng/serverlỗi), màn MUST hiển thị trạng thái lỗi thân thiện (từ ánh xạ `AppFailure` → chuỗi địa phương hoá) kèm hành động thử lại; KHÔNG hiển thị text kỹ thuật/HTTP/mã lỗi backend.
- **FR-008**: Khi tải trang kế thất bại, ứng dụng MUST giữ nội dung đã tải và hiển thị lỗi cục bộ ở phần tải thêm với khả năng thử lại.

**Wallpaper Detail (US2)**

- **FR-009**: Chạm một wallpaper (từ bất kỳ lưới nào) MUST mở màn Wallpaper Detail phủ toàn màn hình (push che shell tab).
- **FR-010**: Wallpaper Detail MUST phát preview video lặp không tiếng ở kích thước lớn và hiển thị metadata (tên, tag, chỉ báo premium nếu có).
- **FR-011**: Nếu wallpaper thuộc một/nhiều bộ sưu tập, Detail MUST hiển thị liên kết "Từ bộ sưu tập · <tên>" dẫn sang đúng Collection Detail.
- **FR-012**: Nếu wallpaper là premium, Detail MUST hiển thị chỉ báo premium; các hành động gated (đặt/tải) MUST thể hiện trạng thái khoá và KHÔNG cấp quyền trong MO-003.
- **FR-013**: Nút "Đặt làm hình nền" và "Tải xuống" MUST hiển thị đúng thị giác nhưng chỉ neo điều hướng/placeholder trong MO-003 (hành vi native/tải thật để MO-005/MO-006).
- **FR-014**: Mở Detail của wallpaper đã bị gỡ MUST hiện trạng thái "không tìm thấy" thân thiện, không crash/không text kỹ thuật.

**Collections (US3)**

- **FR-015**: Tab Bộ sưu tập MUST hiển thị danh sách cover card các bộ sưu tập tuyển chọn của backend (không phân trang).
- **FR-016**: Chạm một cover card MUST mở Collection Detail phủ full-screen với hero cover, mô tả, và lưới wallpaper thuộc bộ theo đúng thứ tự tuyển chọn (items nhúng sẵn, không cần gọi thêm từng item).
- **FR-017**: Collection Detail của bộ premium MUST hiển thị nút "Mở khoá" và "Tải tất cả" ở trạng thái khoá; chạm mở placeholder paywall và KHÔNG cấp quyền tải trong MO-003.
- **FR-018**: Chạm một wallpaper trong Collection Detail MUST mở Wallpaper Detail của nó, và back trả về Collection Detail tại vị trí cũ.

**Search (US4)**

- **FR-019**: Tab Tìm MUST cho nhập từ khoá và trả lưới kết quả wallpaper khớp (param `search` của `GET /wallpapers`), dùng cùng kiểu lưới lười + preview + phân trang cursor như Khám phá. Tìm kiếm MUST kích hoạt **live theo từ khoá với debounce ~350ms**.
- **FR-020**: Từ khoá dưới **2 ký tự** MUST KHÔNG gọi API (giữ trạng thái ban đầu/gợi ý); trạng thái ban đầu (chưa nhập) MUST KHÔNG tải toàn bộ thư viện; khi không có kết quả MUST hiển thị trạng thái rỗng thân thiện gợi ý thử từ khác.
- **FR-021**: Khi người dùng đổi từ khoá/tag liên tục nhanh, ứng dụng MUST chỉ hiển thị kết quả của lựa chọn mới nhất (huỷ/bỏ qua request cũ), tránh nhấp nháy kết quả lỗi thời.

**Xuyên suốt (cross-cutting)**

- **FR-022**: Mọi tương tác dữ liệu MUST đi qua client Dart sinh từ `contracts/openapi.yaml` chạy trên backend thật (BE-002/BE-003); KHÔNG hand-write model, KHÔNG dùng fixture bịa. Dev flavor vẫn có thể trỏ mock Prism qua cờ opt-in.
- **FR-023**: Mọi chuỗi hiển thị MUST được địa phương hoá (ARB, tiếng Việt chính); mọi màu/spacing/typography/icon MUST lấy từ tầng theme `lib/core/theme` + icon Phosphor (không hardcode, không trộn `Icons`/`Cupertino`).
- **FR-024**: Trạng thái mỗi màn MUST theo mẫu 4-trạng-thái BLoC (`initial → loading → loaded → error`, biến thể prefix như `loadingMore`); side-effect (điều hướng, toast) MUST từ `BlocListener`.
- **FR-025**: Layout MUST responsive: lưới tăng số cột theo breakpoint iPad/tablet; Detail và Collection Detail không vỡ ở màn rộng.
- **FR-031**: Lưới Khám phá, kết quả Tìm, và danh sách Bộ sưu tập MUST hỗ trợ **pull-to-refresh**: kéo xuống ở đầu list làm mới từ đầu (reset cursor, tải lại trang đầu; với Tìm là chạy lại từ khoá hiện tại).

**Trạng thái tải (skeleton shimmer)**

- **FR-026**: Trong trạng thái `loading` (tải trang đầu / mở Detail / mở Collection Detail / chạy tìm kiếm), mọi màn MUST hiển thị **skeleton placeholder có hiệu ứng shimmer** thay cho nội dung — KHÔNG dùng spinner đơn thuần làm trạng thái tải chính của các màn này.
- **FR-027**: Hình dạng skeleton MUST khớp bố cục nội dung thật sẽ thay thế nó (đúng tỉ lệ/hình dạng ô wallpaper, số cột theo breakpoint, dạng cover card bộ sưu tập, khối hero + metadata ở Detail) — không phải một khối xám chung chung.
- **FR-028**: Skeleton shimmer MUST khớp design system dark aurora (màu/độ tương phản/bo góc từ tầng theme `lib/core/theme`, Principle VI) và cảm giác tinh tế — không chói, không lệch tông.
- **FR-029**: Shimmer MUST được điều khiển bởi **state kết quả**, không bởi thời gian: nó hiện đúng khi state `loading` và **dừng đúng khoảnh khắc** state chuyển sang `loaded`/`error`. CẤM đặt thời lượng shimmer cố định, delay tối thiểu giả tạo, hay giữ shimmer sau khi dữ liệu đã về.
- **FR-030**: Tải trang kế (`loadingMore`) MUST hiển thị skeleton/placeholder ở cuối lưới (không phải phủ toàn màn), và cũng dừng theo state khi trang về hoặc lỗi.

### Key Entities *(include if feature involves data)*

- **Wallpaper**: một hình nền động. Thuộc tính người dùng thấy: định danh, tên, ảnh poster/preview tĩnh, URL preview video (thấp), cờ premium, danh sách tag, và danh sách bộ sưu tập nó thuộc về (cho liên kết ngược ở Detail). File full-res chỉ lấy khi tải/đặt (ngoài phạm vi MO-003).
- **Tag**: nhãn phân loại tuyển chọn để lọc. Danh sách không phân trang; phần tử đầu là **thẻ ảo "Tất cả"** (định danh 0, slug "all", reserved) do backend sinh, render làm chip mặc định.
- **Collection (Bộ sưu tập)**: nhóm wallpaper tuyển chọn theo chủ đề. Thuộc tính: định danh, tên, mô tả, ảnh cover/hero, cờ premium, và danh sách wallpaper thành viên (nhúng sẵn, đúng thứ tự) khi xem chi tiết.
- **Trang kết quả (paginated page)**: một lát danh sách wallpaper kèm con trỏ trang kế và cờ còn-dữ-liệu; là đơn vị của cả Browse và Search.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Người dùng mở tab Khám phá và thấy lưới wallpaper thật (có preview phát) trong vòng 2 giây trên mạng bình thường.
- **SC-002**: Người dùng cuộn liên tục qua ít nhất 100 wallpaper mà app không crash, không giật rõ rệt, và số video phát đồng thời luôn bị giới hạn ở phạm vi ô đang/gần hiện (xác minh khi profiling: số controller và bộ nhớ giữ phẳng, không tăng tuyến tính theo số ô đã cuộn qua).
- **SC-003**: Lọc theo tag làm mới lưới và hiển thị kết quả đúng tag trong vòng 1,5 giây; chuyển giữa "Tất cả" và một tag không để lại kết quả lỗi thời.
- **SC-004**: 95% lần chạm một wallpaper mở được màn Detail với video phát trong vòng 1 giây.
- **SC-005**: Từ Wallpaper Detail của một wallpaper thuộc bộ sưu tập, người dùng tới được đúng Collection Detail chỉ với một thao tác chạm.
- **SC-006**: Tìm kiếm một từ khoá có trong thư viện trả kết quả grid trong vòng 2 giây; từ khoá không khớp luôn hiện trạng thái rỗng thay vì màn trắng hoặc lỗi.
- **SC-007**: Mọi trạng thái lỗi (mất mạng, cursor hỏng, nội dung bị gỡ) hiển thị thông điệp thân thiện có thể thử lại — không lần nào lộ text kỹ thuật/HTTP/mã lỗi backend cho người dùng.
- **SC-008**: Toàn bộ màn hình MO-003 chạy đúng, không vỡ layout, trên cả iPhone (có notch/Dynamic Island) lẫn iPad/tablet (lưới đa cột).
- **SC-009**: Ở mọi màn tải dữ liệu, người dùng thấy skeleton shimmer khớp bố cục ngay lập tức (không có màn trắng/nhảy layout), và skeleton biến mất đúng khoảnh khắc dữ liệu về — xác minh: khi phản hồi tức thời (cache/mạng nhanh) shimmer không bị giữ lại bởi delay giả tạo; khi phản hồi chậm shimmer duy trì tới đúng lúc `loaded`/`error`, không sớm.

## Assumptions

- Backend BE-002/BE-003 (Core Content API) đã merge, có seed data thật cho `GET /wallpapers`, `GET /tags` (kèm thẻ ảo "All"), `GET /collections`, `GET /collections/{id}` theo contract v0.3.2. Nếu backend chưa sẵn ở môi trường dev, dev flavor có thể trỏ mock Prism qua cờ opt-in để phát triển UI (Principle I).
- Nền tảng MO-002 đã sẵn và tái sử dụng: theme dark-only `lib/core/theme`, 11 shared widget `lib/core/widgets` (WallpaperCard + Aura glow, TabBar, TopBar, PremiumBadge, FilterChip, MetaChip, EmptyState, AppSheet, Toast), nav `go_router StatefulShellRoute` 5 tab, và route top-level Detail/Collection (đang placeholder — MO-003 gắn nội dung thật).
- Aura glow của WallpaperCard/Detail lấy hue từ ảnh thật qua `palette_generator` (defer từ MO-002); nếu chưa lấy được thì fallback về một accent mặc định.
- State model dùng `freezed` (defer từ MO-002 — nay thêm vì MO-003 là feature Cubit đầu tiên).
- Favorites (tab "Yêu thích"), set wallpaper native, tải file gốc, và luồng IAP/entitlement thật đều NGOÀI phạm vi — MO-003 chỉ hiển thị trạng thái khoá cho nội dung premium.
- Preview video là bản độ phân giải thấp do backend cung cấp URL; app không transcode.
- Skeleton shimmer sẽ là một shared widget mới trong `lib/core/widgets` (khớp design system MO-002), dùng lại cho mọi màn tải; hiệu ứng shimmer có thể dùng package chuyên dụng hoặc tự vẽ bằng gradient animation — chốt cụ thể (và version nếu dùng package, Principle XVI) ở bước `/speckit-plan`. Ràng buộc bất biến: shimmer điều khiển bởi state, KHÔNG bởi timer (FR-029).
