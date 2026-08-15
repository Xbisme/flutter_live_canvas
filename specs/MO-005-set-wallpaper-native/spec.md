# Feature Specification: Set Wallpaper Native Integration

**Feature Branch**: `MO-005-set-wallpaper-native`

**Created**: 2026-08-09

**Status**: Draft

**Input**: User description: "MO-005 Set Wallpaper Native Integration — Đặt hình nền động lên máy từ màn Wallpaper Detail. Android: tải file master qua GET /wallpapers/{id}/download-url (presigned ≤5 phút, domain S3/R2 khác CDN — không hardcode domain), lưu vào app storage, gọi Method Channel `com.livecanvas/wallpaper` sang Kotlin dùng WallpaperManager/WallpaperService để set live wallpaper (màn xác nhận trước khi áp dụng). iOS/iPadOS: không có API công khai để set video wallpaper → màn preview + hướng dẫn từng bước dùng Shortcuts (convert sang Live Photo .heic + .mov), lưu file vào Photos. Map mọi lỗi native về AppFailure (wallpaperSetFailed, platformUnsupported) theo Principle IV/VII/VIII, hiển thị qua failure_l10n tiếng Việt. Nối điểm ghi DownloadHistoryRepository.record(id) vào flow tải thật (MO-004 đã dựng kho nhưng chưa có điểm ghi thật, mới test qua seed). Wallpaper premium vẫn trả 402 ENTITLEMENT_REQUIRED cho tới MO-006 (backend BE-005 chưa merge) → phạm vi MO-005 chỉ nghiệm thu end-to-end trên wallpaper free, còn premium chỉ cần map 402 sang thông báo/điều hướng Paywall placeholder. Nếu có design handoff cho màn Lịch sử tải thì thay bản tối giản của MO-004."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Đặt hình nền động trên Android (Priority: P1)

Người dùng đang xem một hình nền miễn phí ở màn Wallpaper Detail và muốn dùng nó làm hình nền động cho máy Android của mình. Họ chạm "Đặt làm hình nền", một sheet trượt lên giải thích ngắn gọn rằng LiveCanvas đặt được trực tiếp trên Android, kèm nút "Tải & đặt hình nền". Họ chạm nút, thấy tiến trình tải, tải xong sheet chuyển sang trạng thái "Đã tải xuống" với nút "Đặt làm hình nền". Chạm nút đó mở màn xem trước của hệ thống Android; họ xác nhận và hình nền động bắt đầu chạy lặp trên màn hình chính/màn khoá.

**Why this priority**: Đây là lời hứa cốt lõi của sản phẩm — không có nó, app chỉ là trình duyệt video. Android là nền tảng duy nhất đặt được trực tiếp, nên đây là luồng mang lại giá trị đầy đủ nhất và là MVP thật sự của spec này.

**Independent Test**: Cài bản `development` trên máy Android thật, mở một wallpaper miễn phí bất kỳ từ Browse → Detail → "Đặt làm hình nền" → hoàn tất luồng. Kiểm chứng bằng cách thoát app, khoá/mở máy và khởi động lại máy: hình nền vẫn chuyển động. Không cần iOS, không cần backend IAP.

**Acceptance Scenarios**:

1. **Given** người dùng đang ở Wallpaper Detail của một hình nền miễn phí trên Android, **When** họ chạm "Đặt làm hình nền", **Then** sheet "Đặt làm hình nền" hiện lên với phần giải thích dành cho Android và nút chính "Tải & đặt hình nền".
2. **Given** sheet đang mở, **When** người dùng chạm "Tải & đặt hình nền", **Then** hệ thống xin liên kết tải mới, hiển thị tiến trình tải có thể huỷ, và khi xong thì chuyển sheet sang trạng thái "Đã tải xuống".
3. **Given** sheet đang ở trạng thái "Đã tải xuống" trên Android, **When** người dùng chạm "Đặt làm hình nền", **Then** màn xem trước hình nền động của hệ thống mở ra với đúng video vừa tải.
4. **Given** màn xem trước của hệ thống đang mở, **When** người dùng xác nhận áp dụng, **Then** hình nền động chạy lặp trên máy và app quay lại Wallpaper Detail với thông báo thành công.
5. **Given** màn xem trước của hệ thống đang mở, **When** người dùng bấm quay lại mà không áp dụng, **Then** app trở về bình thường, không báo lỗi, và file đã tải vẫn dùng lại được nếu người dùng thử lại.
6. **Given** người dùng đã đặt một hình nền LiveCanvas, **When** họ đặt một hình nền LiveCanvas khác, **Then** hình nền mới thay thế hình cũ và bộ nhớ máy không tích tụ thêm file thừa.
7. **Given** máy vừa khởi động lại, **When** người dùng mở màn hình chính, **Then** hình nền động vẫn chạy mà không cần mở lại app.

---

### User Story 2 - Lưu video và hướng dẫn Shortcuts trên iOS (Priority: P2)

Người dùng trên iPhone/iPad chạm "Đặt làm hình nền" ở Wallpaper Detail. Sheet giải thích thẳng thắn rằng iOS không cho phép app tự đặt video làm hình nền, và LiveCanvas sẽ lưu video vào thư viện Ảnh rồi hướng dẫn đặt qua Phím tắt (Shortcuts). Họ chạm "Lưu video vào Ảnh", cấp quyền nếu được hỏi, thấy tiến trình lưu, rồi nhận 3 bước hướng dẫn kèm nút "Mở Shortcuts".

**Why this priority**: iOS là nửa còn lại của tập người dùng và là điểm dễ bị App Review từ chối nhất nếu app hứa hẹn sai. Ưu tiên sau Android vì giá trị mang lại là hướng dẫn chứ không phải kết quả tự động, nhưng vẫn bắt buộc trước khi phát hành.

**Independent Test**: Cài bản `development` trên iPhone/iPad thật (hoặc simulator cho phần UI), mở một wallpaper miễn phí → "Đặt làm hình nền" → "Lưu video vào Ảnh". Kiểm chứng video xuất hiện trong app Ảnh và nút "Mở Shortcuts" mở đúng app Phím tắt. Hoàn toàn độc lập với Android.

**Acceptance Scenarios**:

1. **Given** người dùng ở Wallpaper Detail trên iOS, **When** họ chạm "Đặt làm hình nền", **Then** sheet hiện phần giải thích dành cho iOS và nút chính "Lưu video vào Ảnh" — **không** có bất kỳ câu chữ nào ngụ ý app tự đặt được hình nền.
2. **Given** app chưa từng xin quyền thư viện Ảnh, **When** người dùng chạm "Lưu video vào Ảnh", **Then** hệ thống hỏi quyền trước khi lưu.
3. **Given** người dùng từ chối quyền thư viện Ảnh, **When** app cố lưu, **Then** sheet hiển thị thông báo tiếng Việt giải thích cần cấp quyền kèm lối tắt mở Cài đặt, không sập app.
4. **Given** video đã lưu thành công, **When** sheet chuyển sang trạng thái "Đã tải xuống", **Then** hiển thị 3 bước hướng dẫn Shortcuts và nút "Mở Shortcuts".
5. **Given** sheet đang hiện hướng dẫn, **When** người dùng chạm "Mở Shortcuts", **Then** app Phím tắt của hệ thống mở lên; nếu máy không có app đó, hiển thị thông báo thân thiện thay vì lỗi kỹ thuật.

---

### User Story 3 - Lịch sử tải ghi nhận thật (Priority: P3)

Sau khi tải một hình nền (dù để đặt trên Android hay lưu vào Ảnh trên iOS), người dùng mở tab "Bạn" → "Lịch sử tải" và thấy hình nền vừa tải nằm ở đầu danh sách.

**Why this priority**: MO-004 đã dựng sẵn kho lưu lịch sử nhưng chưa có điểm ghi thật (mới test bằng dữ liệu seed). Đây là mảnh ghép nhỏ nhưng biến một màn hình đang rỗng vĩnh viễn thành có dữ liệu thật. Phụ thuộc vào việc tải chạy được nên xếp sau US1/US2.

**Independent Test**: Tải một hình nền bất kỳ, mở "Lịch sử tải", xác nhận mục mới ở đầu danh sách. Tải lại đúng hình đó, xác nhận danh sách vẫn chỉ có một mục cho hình đó và nó được đẩy lên đầu.

**Acceptance Scenarios**:

1. **Given** lịch sử tải đang rỗng, **When** người dùng tải thành công một hình nền, **Then** hình nền đó xuất hiện ở đầu màn "Lịch sử tải".
2. **Given** một hình nền đã có trong lịch sử, **When** người dùng tải lại chính nó, **Then** danh sách vẫn chỉ có một mục cho hình nền đó và mục ấy được đưa lên đầu.
3. **Given** một lần tải thất bại hoặc bị người dùng huỷ giữa chừng, **When** người dùng mở "Lịch sử tải", **Then** hình nền đó **không** được ghi vào lịch sử.
4. **Given** một hình nền trong lịch sử đã bị quản trị viên gỡ khỏi kho, **When** người dùng mở "Lịch sử tải", **Then** mục đó được loại khỏi danh sách mà không hiện lỗi.

---

### User Story 4 - Hình nền premium bị chặn đúng cách (Priority: P4)

Người dùng chưa mua gói Premium chạm "Đặt làm hình nền" trên một hình nền premium. Thay vì tải, app hiển thị thông báo rằng nội dung cần gói Premium kèm lối đi tới màn Paywall.

**Why this priority**: Bảo vệ nội dung trả phí, nhưng luồng mua thật thuộc MO-006 và backend IAP chưa merge — MO-005 chỉ cần chặn đúng và điều hướng đúng, không xử lý mua bán.

**Independent Test**: Mở một hình nền có nhãn PRO, chạm "Đặt làm hình nền", xác nhận không có file nào được tải và thông báo/điều hướng Paywall xuất hiện.

**Acceptance Scenarios**:

1. **Given** một hình nền premium và người dùng chưa có quyền, **When** họ chạm "Đặt làm hình nền", **Then** app không tải file nào và hiển thị thông báo cần gói Premium.
2. **Given** thông báo cần Premium đang hiện, **When** người dùng chạm nút hành động của thông báo, **Then** app điều hướng tới màn Paywall (bản tạm của MO-005, hoàn thiện ở MO-006).
3. **Given** một lần chặn vì premium, **When** người dùng mở "Lịch sử tải", **Then** hình nền đó không được ghi vào lịch sử.

---

### Edge Cases

- **Liên kết tải hết hạn**: liên kết chỉ sống ≤5 phút. Nếu người dùng để sheet mở lâu rồi mới bấm tải, hoặc lần tải trước thất bại, hệ thống phải xin liên kết mới thay vì dùng lại liên kết cũ.
- **Mất mạng giữa chừng**: tải dở phải dừng sạch, không để lại file rác, hiển thị lỗi mạng tiếng Việt và cho thử lại.
- **Hết dung lượng máy**: báo lỗi ghi file rõ ràng ("máy không đủ dung lượng"), không sập app, dọn phần đã tải dở.
- **Người dùng đóng sheet khi đang tải**: lần tải bị huỷ, không có tiến trình chạy ngầm vô thời hạn, không ghi lịch sử.
- **Hình nền bị gỡ khi đang xem**: liên kết tải trả về "không tìm thấy" → thông báo hình nền không còn khả dụng, không phải lỗi quyền.
- **Máy Android không hỗ trợ hình nền động** (một số ROM/thiết bị tối giản): báo "thiết bị không hỗ trợ" thay vì thất bại im lặng.
- **Người dùng huỷ ở màn xem trước của hệ thống**: coi là hành động bình thường, không phải lỗi.
- **Tải cùng lúc nhiều hình**: chỉ cho phép một lần tải hoạt động tại một thời điểm trong sheet.
- **Nút "Tải xuống" và "Đặt làm hình nền" ở Detail**: theo prototype cả hai cùng mở một sheet; sheet là nơi duy nhất quyết định hành động cuối.
- **iPad/tablet**: sheet hiển thị dạng hộp thoại giữa màn hình thay vì trượt từ đáy (theo `ipad.html`).
- **Hình nền đang được dùng làm hình nền máy bị xoá khỏi kho**: hình nền trên máy vẫn chạy (file đã nằm ở máy), app không được xoá file đang dùng khi dọn dẹp.

## Requirements *(mandatory)*

### Functional Requirements

**Luồng chung**

- **FR-001**: Ở màn Wallpaper Detail, cả nút "Tải xuống" lẫn nút "Đặt làm hình nền" MUST mở cùng một sheet "Đặt làm hình nền" (bám prototype `SetWallpaper.jsx`).
- **FR-002**: Sheet MUST chỉ hiển thị luồng của nền tảng đang chạy — không có bộ chuyển đổi Android/iPhone (đó chỉ là công cụ trình diễn của prototype web).
- **FR-003**: Sheet MUST có hai trạng thái theo prototype: (a) trước khi tải — tiêu đề, câu giải thích riêng theo nền tảng, nút chính; (b) sau khi tải xong — biểu tượng thành công, tiêu đề "Đã tải xuống", câu mô tả và hành động tiếp theo riêng theo nền tảng.
- **FR-004**: Nút chính MUST ghi "Tải & đặt hình nền" trên Android và "Lưu video vào Ảnh" trên iOS.
- **FR-005**: Mỗi lần bắt đầu tải, hệ thống MUST xin một liên kết tải mới; liên kết MUST NOT được lưu lại hay dùng lại giữa các lần (liên kết sống ≤5 phút).
- **FR-006**: Hệ thống MUST NOT giả định hay so sánh tên miền của liên kết tải — tên miền lưu trữ file gốc khác tên miền phân phối ảnh/preview.
- **FR-007**: Trong lúc tải, sheet MUST hiển thị tiến trình và cho phép người dùng huỷ.
- **FR-008**: Đóng sheet trong lúc tải MUST huỷ lần tải đó và dọn phần dữ liệu dở dang.
- **FR-009**: Tại một thời điểm MUST chỉ có tối đa một lần tải đang chạy.
- **FR-010**: Máy rung phản hồi (haptic) MUST đi kèm hai mốc: bắt đầu tải và đặt/lưu thành công.

**Android**

- **FR-011**: Sau khi tải xong, hành động "Đặt làm hình nền" MUST mở màn xem trước hình nền động của hệ thống để người dùng xác nhận trước khi áp dụng — app MUST NOT tự áp dụng mà không có bước xác nhận này.
- **FR-012**: Hình nền động MUST chạy lặp liên tục, không tiếng.
- **FR-013**: Hình nền động MUST tiếp tục chạy sau khi thoát app và sau khi khởi động lại máy.
- **FR-014**: File gốc trên Android MUST nằm trong vùng lưu trữ riêng của app và MUST NOT được ghi vào thư viện ảnh/video công khai của máy — việc tải ở đây là bước đệm để đặt hình nền, không phải hành động xuất file (quyết định Q2/A, xem §Assumptions). Kéo theo: app MUST NOT xin quyền ghi bộ nhớ ngoài trên Android.
- **FR-015**: Đặt một hình nền mới MUST thay thế hình nền cũ do app đặt và MUST dọn file gốc không còn dùng, nhưng MUST NOT xoá file đang được dùng làm hình nền hiện tại.
- **FR-016**: Người dùng huỷ ở màn xem trước của hệ thống MUST được xử lý như hành động bình thường (không báo lỗi) và file đã tải MUST dùng lại được cho lần thử tiếp theo.
- **FR-017**: Thiết bị không hỗ trợ hình nền động MUST nhận thông báo "thiết bị không hỗ trợ" rõ ràng.

**iOS/iPadOS**

- **FR-018**: Sheet MUST nói rõ iOS không cho phép app tự đặt video làm hình nền và MUST NOT dùng bất kỳ câu chữ nào ngụ ý điều ngược lại.
- **FR-019**: Hệ thống MUST lưu **video gốc nguyên trạng** vào thư viện Ảnh và MUST NOT tự chuyển đổi sang định dạng Live Photo — việc chuyển đổi do phím tắt của người dùng đảm nhiệm (quyết định Q1/A, xem §Assumptions).
- **FR-020**: Hệ thống MUST xin quyền ghi thư viện Ảnh trước khi lưu và MUST xử lý trường hợp bị từ chối bằng thông báo tiếng Việt kèm lối tắt mở Cài đặt.
- **FR-021**: Sau khi lưu thành công, sheet MUST hiển thị đúng 3 bước hướng dẫn Shortcuts theo prototype và nút "Mở Shortcuts".
- **FR-022**: Nút "Mở Shortcuts" MUST mở app Phím tắt của hệ thống; nếu không mở được, MUST hiển thị thông báo thân thiện thay vì lỗi kỹ thuật.

**Lịch sử tải**

- **FR-023**: Một lần tải **thành công** MUST ghi đúng một mục vào lịch sử tải.
- **FR-024**: Tải thất bại, bị huỷ, hoặc bị chặn vì premium MUST NOT ghi lịch sử.
- **FR-025**: Tải lại một hình nền đã có trong lịch sử MUST giữ nguyên một mục duy nhất cho hình nền đó và đưa nó lên đầu danh sách.

**Nội dung premium**

- **FR-026**: Khi máy chủ từ chối vì thiếu quyền Premium, hệ thống MUST không tải file nào và MUST hiển thị thông báo cần gói Premium kèm lối đi tới màn Paywall.
- **FR-027**: Hệ thống MUST NOT tự suy đoán quyền Premium ở phía máy — quyết định chặn hay cho tải luôn đến từ phản hồi của máy chủ.

**Lỗi & ngôn ngữ**

- **FR-028**: Mọi lỗi tải, ghi file, và lỗi phía hệ điều hành MUST được quy về tập lỗi chuẩn của app (tải thất bại, ghi file thất bại, đặt hình nền thất bại, nền tảng không hỗ trợ) và hiển thị bằng chuỗi tiếng Việt thân thiện.
- **FR-029**: Thông điệp lỗi MUST NOT chứa mã lỗi kỹ thuật, nội dung phản hồi máy chủ, hay tên ngoại lệ của hệ điều hành.
- **FR-030**: Toàn bộ chuỗi hiển thị mới MUST nằm trong hệ thống đa ngôn ngữ (tiếng Việt chính, tiếng Anh phụ) — không có chuỗi cứng trong giao diện.

**Bố cục**

- **FR-031**: Trên máy tính bảng, sheet MUST hiển thị dạng hộp thoại giữa màn hình theo bản dựng `ipad.html`.

### Key Entities

- **Yêu cầu đặt hình nền**: gói dữ liệu tối thiểu chuyển từ tầng Flutter sang tầng hệ điều hành — đường dẫn file gốc trên máy và định danh hình nền. Không mang theo mô hình dữ liệu nghiệp vụ.
- **Trạng thái tải**: tiến trình của một lần tải (chưa bắt đầu / đang tải kèm phần trăm / xong / lỗi / đã huỷ) — nguồn dữ liệu cho giao diện sheet.
- **File hình nền trên máy**: file gốc đã tải nằm trong vùng lưu trữ riêng của app, gắn với hình nền đang được dùng; có vòng đời riêng (giữ file đang dùng, dọn file cũ).
- **Mục lịch sử tải** *(đã có từ MO-004)*: định danh hình nền + thời điểm tải, duy nhất theo hình nền, mới nhất lên đầu.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Trên Android, người dùng đặt được hình nền động từ lúc mở Wallpaper Detail đến lúc hình nền chạy trên máy trong **không quá 4 lần chạm** và dưới **60 giây** với mạng Wi-Fi thông thường.
- **SC-002**: Một hình nền mẫu khoảng 5 MB tải xong trong **dưới 10 giây** trên Wi-Fi ổn định, có hiển thị tiến trình suốt quá trình.
- **SC-003**: Hình nền động vẫn chuyển động sau khi thoát app và sau khi khởi động lại máy — kiểm chứng trên ít nhất **2 thiết bị Android thật** khác nhau.
- **SC-004**: **100%** thông điệp lỗi hiển thị bằng tiếng Việt thân thiện; **0** trường hợp lộ mã lỗi kỹ thuật hoặc tên ngoại lệ ra giao diện.
- **SC-005**: Sau mỗi lần tải thành công, hình nền xuất hiện ở **đầu** màn "Lịch sử tải" ngay lần mở kế tiếp, **không** có mục trùng lặp sau khi tải lại cùng một hình nền 3 lần.
- **SC-006**: Trên iOS, người dùng lần đầu hoàn thành từ lúc chạm "Đặt làm hình nền" đến lúc video nằm trong thư viện Ảnh trong **dưới 30 giây**, và hướng dẫn Shortcuts đủ để đặt xong hình nền trong **dưới 2 phút** mà không cần tra cứu ngoài app.
- **SC-007**: Dung lượng app chiếm trên máy **không tăng tích luỹ**: sau 10 lần đặt hình nền khác nhau, app giữ tối đa **một** file gốc (file của hình nền đang dùng).
- **SC-008**: Mọi hình nền premium khi chưa có quyền đều bị chặn ở **100%** số lần thử, không có file nào được tải về máy.

## Assumptions

- **[Q1/A — đã chốt 2026-08-09] iOS lưu video gốc, không tự chuyển Live Photo**: app chỉ lưu file video nguyên trạng vào thư viện Ảnh; việc chuyển sang Live Photo do phím tắt của người dùng đảm nhiệm. Căn cứ: bước 2 trong prototype viết "chọn **video** vừa lưu" — tức người dùng chọn một video thường. Cách đọc này cũng khớp Principle VII (mệnh đề "convert to Live Photo" mô tả *việc mà luồng Shortcuts làm*, không phải việc app làm), nên **không phải deviation hiến pháp**. Việc app tự ghép cặp `.heic`+`.mov` là nâng cấp trải nghiệm có thể cân nhắc ở MO-007 Polish.
- **[Q2/A — đã chốt 2026-08-09] "Tải xuống" trên Android là bước đệm, không phải xuất file**: file gốc nằm trong vùng riêng của app, người dùng không thấy trong thư viện máy; kết quả người dùng nhận được là hình nền đang chạy. Căn cứ: prototype nối cả hai nút vào cùng một sheet, và nhãn nút chính của sheet trên Android là "Tải & **đặt hình nền**" — bản thân thiết kế coi việc tải là một bước của việc đặt. Trên iOS thì ngược lại: lưu vào thư viện Ảnh là bắt buộc vì Shortcuts phải đọc từ đó. Hệ quả: Android không cần xin quyền ghi bộ nhớ ngoài (Principle XIV — không thêm quyền khi chưa có nhu cầu thật).
- **Bộ chuyển đổi OS trong prototype là công cụ trình diễn**: `SetWallpaper.jsx` có nút chuyển Android/iPhone để xem cả hai luồng trên web. App thật xác định nền tảng theo máy đang chạy và chỉ hiển thị một luồng — người dùng iPhone không có nhu cầu đọc hướng dẫn Android.
- **Chỉ nghiệm thu end-to-end trên hình nền miễn phí**: backend IAP (`BE-005`) chưa merge nên mọi hình nền premium đều bị từ chối. MO-005 chỉ cần chặn đúng và điều hướng đúng; luồng mua và quyền thật thuộc MO-006.
- **Màn Paywall là bản tạm**: MO-005 chỉ cần một điểm đến để điều hướng khi bị chặn. Thiết kế và luồng mua đầy đủ thuộc MO-006.
- **"Tải tất cả" của bộ sưu tập nằm ngoài phạm vi**: nút này ở Collection Detail sẽ được nối ở MO-006 cùng với quyền Premium, vì bộ sưu tập premium là trường hợp chính của nó.
- **Màn "Lịch sử tải" giữ nguyên bản tối giản của MO-004**: kiểm tra thư mục bàn giao thiết kế cho thấy **không có** bản dựng nào cho màn này (`Browse`, `Collection`, `Favorites`, `Paywall`, `Search`, `SetWallpaper`, `Sheets`, `WallpaperDetail`). MO-005 chỉ nối điểm ghi dữ liệu thật, không thiết kế lại màn.
- **Sheet là điểm vào duy nhất của việc tải**: prototype nối cả "Tải xuống" lẫn "Đặt làm hình nền" vào cùng một sheet, nên MO-005 không dựng thêm luồng tải riêng biệt.
- **Không có giới hạn số lần tải** phía máy chủ cần xử lý ở phiên bản này.
- **Người dùng có mạng khi bắt đầu tải**; app không hỗ trợ hàng đợi tải ngoại tuyến ở phiên bản này.

## Out of Scope

- Luồng mua hàng, khôi phục giao dịch, và quyền Premium thật (thuộc MO-006).
- "Tải tất cả" cho bộ sưu tập (thuộc MO-006).
- Thiết kế lại màn "Lịch sử tải" (chưa có bản bàn giao thiết kế).
- Hẹn giờ đổi hình nền, xoay vòng nhiều hình nền, hay hình nền theo bộ sưu tập.
- Cắt/xoay/chỉnh sửa video trước khi đặt.
- Đặt hình nền cho màn khoá riêng biệt với màn hình chính trên Android (dùng thiết lập mặc định của hệ thống).
- **Tự động chuyển video sang định dạng Live Photo bên trong app trên iOS** — chốt Q1/A: để phím tắt của người dùng làm; cân nhắc lại ở MO-007.
- **Xuất file vào thư viện ảnh/video công khai trên Android** — chốt Q2/A: file nằm trong vùng riêng của app.
