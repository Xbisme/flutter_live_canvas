# Feature Specification: Favorites & Local Data

**Feature Branch**: `MO-004-favorites-local-data`

**Created**: 2026-07-26

**Status**: Draft

**Input**: User description: "MO-004 Favorites & Local Data — Người dùng lưu wallpaper yêu thích ở local (chỉ lưu mảng ID, không cache full data — Principle IX). Mỗi lần mở màn Favorites gọi POST /wallpapers/batch để lấy data mới nhất theo danh sách ID. Toggle favorite ở màn Detail và Collection Detail. Reconcile khi ID không còn tồn tại (wallpaper bị admin xóa/unpublish → tự bỏ khỏi favorites, không báo lỗi). Lưu lịch sử tải local. Phụ thuộc MO-003 (đã merge). Không cần backend mới — dùng POST /wallpapers/batch đã có trong contract v0.4.0."

## Clarifications

### Session 2026-07-26

- Q: Phạm vi US4 (Lịch sử tải cục bộ) trong MO-004 làm tới đâu, khi cơ chế tải/đặt hình nền native thuộc MO-005? → A: MO-004 dựng **kho lưu trữ lịch sử tải cục bộ + màn xem lại** (kiểm thử bằng seed); **MO-005 nối điểm ghi** khi một lượt tải native thật hoàn tất. MO-004 KHÔNG thêm nút/điểm kích hoạt tải mới.
- Q: Nút yêu thích được toggle trực tiếp từ đâu? → A: **Từ grid tile ở mọi lưới (Browse, Favorites, Collection Detail) qua nút tim overlay trên WallpaperCard, và từ màn Wallpaper Detail.**

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Đánh dấu & bỏ đánh dấu yêu thích (Priority: P1)

Người dùng đang xem một wallpaper (ở màn Wallpaper Detail hoặc trong lưới của một Bộ sưu tập) và muốn lưu lại để xem sau. Họ chạm nút yêu thích để thêm; chạm lần nữa để bỏ. Trạng thái yêu thích được ghi nhớ vĩnh viễn trên thiết bị, không cần đăng nhập, và phản ánh nhất quán ở mọi nơi wallpaper đó xuất hiện.

**Why this priority**: Đây là giá trị cốt lõi của tính năng — nếu chỉ làm được việc này, người dùng đã có một bộ sưu tập cá nhân bền vững. Mọi thứ khác (xem lại danh sách, lịch sử tải) đều phụ thuộc vào việc trạng thái yêu thích được lưu đúng.

**Independent Test**: Mở một wallpaper bất kỳ, chạm yêu thích, đóng app hoàn toàn và mở lại → wallpaper vẫn hiển thị trạng thái đã-yêu-thích; chạm lần nữa để bỏ → trạng thái được gỡ và vẫn bền vững sau khi mở lại app.

**Acceptance Scenarios**:

1. **Given** một wallpaper chưa được yêu thích (ở màn Detail hoặc trên tile trong bất kỳ lưới nào), **When** người dùng chạm nút tim, **Then** nút chuyển sang trạng thái đã-yêu-thích ngay lập tức và ID được lưu vào bộ nhớ cục bộ.
2. **Given** một wallpaper đã yêu thích, **When** người dùng chạm nút yêu thích lần nữa, **Then** trạng thái được gỡ và ID bị xóa khỏi bộ nhớ cục bộ.
3. **Given** một wallpaper đã yêu thích từ màn Detail, **When** người dùng thấy cùng wallpaper đó trong lưới một Bộ sưu tập, **Then** nó cũng hiển thị trạng thái đã-yêu-thích (nhất quán xuyên màn hình).
4. **Given** người dùng đã yêu thích vài wallpaper, **When** họ tắt hẳn app rồi mở lại, **Then** tất cả trạng thái yêu thích được giữ nguyên.

---

### User Story 2 - Xem lại danh sách yêu thích với dữ liệu mới nhất (Priority: P2)

Người dùng mở tab "Yêu thích" để xem lại toàn bộ wallpaper đã lưu. Danh sách hiển thị thông tin **mới nhất** của từng wallpaper (tiêu đề, ảnh, trạng thái premium…) chứ không phải bản chụp cũ lúc bấm yêu thích — vì admin có thể đã cập nhật hoặc gỡ wallpaper trong thời gian đó.

**Why this priority**: Biến các ID đã lưu thành một màn hình xem được là điều khiến tính năng "thật sự dùng được". Ưu tiên sau P1 vì cần P1 (lưu ID) hoạt động trước.

**Independent Test**: Yêu thích 3 wallpaper, mở tab Yêu thích → thấy đúng 3 mục với dữ liệu hiện hành; từ tab này chạm một mục → mở màn Detail của nó; bỏ yêu thích một mục → nó biến mất khỏi danh sách.

**Acceptance Scenarios**:

1. **Given** người dùng đã yêu thích một số wallpaper, **When** họ mở tab Yêu thích, **Then** hệ thống lấy dữ liệu mới nhất theo danh sách ID đã lưu và hiển thị lưới các wallpaper đó.
2. **Given** tab Yêu thích đang mở, **When** người dùng chạm một wallpaper, **Then** mở màn Wallpaper Detail của wallpaper đó.
3. **Given** người dùng đang ở tab Yêu thích, **When** họ bỏ yêu thích một mục, **Then** mục đó được gỡ khỏi lưới ngay mà không cần rời màn hình.
4. **Given** người dùng chưa yêu thích wallpaper nào, **When** họ mở tab Yêu thích, **Then** hiển thị trạng thái rỗng thân thiện gợi ý đi khám phá.
5. **Given** việc lấy dữ liệu thất bại (mất mạng), **When** người dùng mở tab Yêu thích, **Then** hiển thị trạng thái lỗi có thể thử lại, không mất danh sách ID đã lưu.

---

### User Story 3 - Tự dọn wallpaper không còn tồn tại (Priority: P2)

Một wallpaper đã yêu thích có thể bị admin gỡ hoặc chuyển sang trạng thái không công khai. Khi người dùng mở tab Yêu thích, những mục không còn tồn tại phải tự biến mất một cách êm — không báo lỗi, không để lại ô trống hay ảnh vỡ.

**Why this priority**: Đi kèm P2 để danh sách luôn sạch và đáng tin. Nếu thiếu, người dùng gặp ô hỏng và mất niềm tin. Cùng mức ưu tiên P2 vì gắn liền với luồng xem danh sách.

**Independent Test**: Yêu thích 3 wallpaper, giả lập một trong số đó không còn được trả về khi lấy dữ liệu → mở tab Yêu thích chỉ thấy 2 mục còn hợp lệ, và ID của mục đã mất được loại khỏi bộ nhớ cục bộ (không xuất hiện lại ở lần mở sau).

**Acceptance Scenarios**:

1. **Given** danh sách yêu thích chứa một ID mà nguồn dữ liệu không còn trả về, **When** người dùng mở tab Yêu thích, **Then** mục đó không được hiển thị và ID bị loại bỏ khỏi bộ nhớ cục bộ (đối chiếu âm thầm).
2. **Given** tất cả wallpaper đã yêu thích đều không còn tồn tại, **When** người dùng mở tab Yêu thích, **Then** hiển thị trạng thái rỗng như khi chưa yêu thích gì, không có thông báo lỗi.
3. **Given** một mục vừa bị đối chiếu loại bỏ, **When** người dùng mở lại tab Yêu thích lần sau, **Then** hệ thống không cố lấy lại ID đã loại đó nữa.

---

### User Story 4 - Lịch sử tải cục bộ (Priority: P3)

Người dùng muốn biết mình đã tải/lưu về những wallpaper nào. Ứng dụng giữ một lịch sử tải cục bộ, ghi lại các wallpaper người dùng đã tải thành công cùng thời điểm, để họ xem lại và mở nhanh.

**Why this priority**: Tiện ích phụ, có giá trị nhưng không thiết yếu cho MVP. **Ranh giới MO-004/MO-005 (đã chốt ở Clarifications)**: MO-004 dựng **kho lưu trữ lịch sử tải cục bộ (API ghi/đọc) + màn xem lại**; **MO-005 nối điểm ghi** khi một lượt tải/đặt hình nền native thật hoàn tất. MO-004 KHÔNG thêm nút/điểm kích hoạt tải mới — nên trong phạm vi MO-004, kho lịch sử được kiểm thử bằng **seed** trực tiếp.

**Independent Test**: Seed một vài mục lịch sử tải vào kho → mở màn Lịch sử tải thấy các mục theo thứ tự mới nhất trước, kèm thời điểm; chạm một mục → mở Detail; lịch sử bền vững sau khi mở lại app.

**Acceptance Scenarios**:

1. **Given** một wallpaper vừa được tải thành công, **When** lượt tải hoàn tất, **Then** một mục lịch sử (ID + thời điểm) được ghi vào bộ nhớ cục bộ.
2. **Given** đã có mục trong lịch sử tải, **When** người dùng mở màn Lịch sử tải, **Then** danh sách hiển thị theo thứ tự mới-nhất-trước với dữ liệu wallpaper hiện hành.
3. **Given** cùng một wallpaper được tải nhiều lần, **When** xem lịch sử, **Then** không tạo mục trùng cũ; mục của wallpaper đó phản ánh lần tải gần nhất (đưa lên đầu).
4. **Given** một wallpaper trong lịch sử không còn tồn tại, **When** người dùng mở màn Lịch sử tải, **Then** mục đó tự được loại bỏ như cơ chế đối chiếu ở US3.

---

### Edge Cases

- **Danh sách yêu thích rất lớn (> 100 ID)**: nguồn dữ liệu lấy theo lô giới hạn 100 ID mỗi lần → hệ thống phải chia thành nhiều lô và gộp kết quả, giữ đúng thứ tự hiển thị.
- **Chạm yêu thích liên tục rất nhanh (double-tap)**: trạng thái cuối cùng phải phản ánh đúng số lần chạm (không kẹt ở trạng thái sai do đua lệnh ghi).
- **Mất mạng khi mở tab Yêu thích**: ID cục bộ không được xóa; hiển thị lỗi thử-lại được. Chỉ đối chiếu (loại ID) khi nguồn dữ liệu trả về **thành công** mà thiếu ID đó — không loại vì lỗi mạng.
- **Bỏ yêu thích ở tab Yêu thích rồi kéo xuống làm mới**: mục đã bỏ không được xuất hiện lại.
- **Wallpaper premium trong danh sách yêu thích**: vẫn hiển thị và đánh dấu premium như ở các màn khác; yêu thích không phụ thuộc quyền premium.
- **Thao tác yêu thích khi lưới đang tải phân trang ở màn khác**: trạng thái yêu thích phải nhất quán khi wallpaper đó cuộn vào tầm nhìn.

## Requirements *(mandatory)*

### Functional Requirements

#### Favorites — lưu trữ & đồng bộ trạng thái

- **FR-001**: Hệ thống MUST cho phép người dùng đánh dấu và bỏ đánh dấu một wallpaper là yêu thích **trực tiếp từ tile trong mọi lưới** (Khám phá/Browse, Yêu thích, Collection Detail) qua nút tim overlay trên WallpaperCard, **và** từ màn Wallpaper Detail.
- **FR-002**: Hệ thống MUST chỉ lưu **danh sách ID** wallpaper yêu thích trên thiết bị (không lưu bản sao đầy đủ dữ liệu wallpaper).
- **FR-003**: Hệ thống MUST giữ trạng thái yêu thích bền vững qua các lần tắt/mở lại ứng dụng và không phụ thuộc vào bất kỳ tài khoản/đăng nhập nào.
- **FR-004**: Hệ thống MUST phản ánh trạng thái yêu thích một cách nhất quán và tức thời ở mọi nơi cùng một wallpaper xuất hiện (Detail, Collection Detail, danh sách Yêu thích, và lưới khám phá nếu đang hiển thị).
- **FR-005**: Thao tác đánh dấu/bỏ đánh dấu MUST cập nhật giao diện ngay (không chờ vòng lấy dữ liệu), và xử lý an toàn khi người dùng chạm liên tiếp nhanh.

#### Favorites — màn hình xem lại

- **FR-006**: Hệ thống MUST cung cấp màn "Yêu thích" hiển thị lưới các wallpaper đã lưu, dùng **dữ liệu mới nhất** lấy theo danh sách ID (không dùng dữ liệu chụp lúc bấm yêu thích).
- **FR-007**: Màn Yêu thích MUST cho phép chạm một mục để mở Wallpaper Detail, và bỏ yêu thích ngay tại chỗ (mục biến mất khỏi lưới mà không cần rời màn).
- **FR-008**: Màn Yêu thích MUST hiển thị trạng thái rỗng thân thiện khi chưa có mục nào, và trạng thái lỗi có-thể-thử-lại khi việc lấy dữ liệu thất bại (không làm mất danh sách ID đã lưu).
- **FR-009**: Khi số ID vượt giới hạn một lần lấy dữ liệu (100), hệ thống MUST tự chia thành nhiều lô và gộp kết quả đúng thứ tự.

#### Favorites — đối chiếu (reconcile)

- **FR-010**: Khi lấy dữ liệu **thành công**, nếu một ID đã lưu không có trong kết quả trả về, hệ thống MUST coi wallpaper đó là không-còn-tồn-tại: không hiển thị và **loại ID đó khỏi bộ nhớ cục bộ**, không hiện thông báo lỗi.
- **FR-011**: Hệ thống MUST KHÔNG loại bỏ ID nào khi việc lấy dữ liệu thất bại (ví dụ mất mạng) — chỉ đối chiếu dựa trên một phản hồi thành công.

#### Download history (P3)

- **FR-012**: Hệ thống MUST cung cấp **API kho lịch sử tải cục bộ** (ghi/cập nhật một mục = ID wallpaper + thời điểm; đọc danh sách) để lớp tải native ở MO-005 gọi khi một lượt tải hoàn tất thành công. MO-004 KHÔNG tự thêm điểm kích hoạt tải; kho được kiểm thử độc lập bằng seed.
- **FR-013**: Hệ thống MUST cung cấp màn xem Lịch sử tải hiển thị theo thứ tự mới-nhất-trước, dùng dữ liệu wallpaper hiện hành lấy theo ID, cho phép chạm để mở Detail.
- **FR-014**: Lịch sử tải MUST không tạo mục trùng cho cùng một wallpaper; lần tải mới cập nhật thời điểm và đưa mục lên đầu.
- **FR-015**: Màn Lịch sử tải MUST áp dụng cùng cơ chế đối chiếu như FR-010 để tự loại các wallpaper không còn tồn tại.

### Ràng buộc phi chức năng (kế thừa nền tảng)

- **FR-016**: Mọi lời gọi lấy dữ liệu MUST trả kết quả dạng thành-công/thất-bại có kiểu (không ném lỗi thô lên UI) và ánh xạ lỗi sang thông báo người dùng đọc được — nhất quán với nền tảng đã dựng ở MO-003.
- **FR-017**: Tính năng MUST hoạt động không cần bất kỳ endpoint backend mới nào (chỉ dùng khả năng lấy dữ liệu theo danh sách ID đã có trong hợp đồng API hiện hành).

### Key Entities *(include if feature involves data)*

- **Favorite (mục yêu thích)**: đại diện cho một wallpaper người dùng đã lưu. Thuộc tính bền vững duy nhất: **ID wallpaper**. Thứ tự lưu (để hiển thị) có thể suy ra từ trình tự thêm. Không lưu tiêu đề/ảnh/premium — những dữ liệu này luôn lấy tươi từ nguồn.
- **Download History Entry (mục lịch sử tải)**: đại diện cho một lần tải hoàn tất. Thuộc tính bền vững: **ID wallpaper** + **thời điểm tải gần nhất**. Mỗi wallpaper tối đa một mục (cập nhật thời điểm khi tải lại).
- **Wallpaper (tham chiếu)**: thực thể dữ liệu hiện hành lấy theo ID từ nguồn; không được lưu bản sao cục bộ. Dùng để hiển thị ở màn Yêu thích và Lịch sử tải.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Sau khi người dùng đánh dấu yêu thích và khởi động lại ứng dụng, 100% trạng thái yêu thích được giữ nguyên.
- **SC-002**: Trạng thái nút yêu thích cập nhật trên giao diện trong vòng 100 ms kể từ khi chạm (cảm giác tức thời).
- **SC-003**: Khi mở tab Yêu thích với danh sách hợp lệ, lưới hiển thị dữ liệu mới nhất; mọi ID không còn tồn tại được loại sạch trong cùng lần mở đó (0 ô hỏng/ảnh vỡ).
- **SC-004**: Cùng một wallpaper hiển thị trạng thái yêu thích **giống hệt** trên tất cả các màn nơi nó xuất hiện, không có sai lệch giữa các màn.
- **SC-005**: Danh sách yêu thích lớn (ví dụ 250 mục) vẫn hiển thị đầy đủ, đúng thứ tự, không mất mục do giới hạn lô 100/lần.
- **SC-006**: Mất mạng khi mở tab Yêu thích không làm mất mục yêu thích nào đã lưu; sau khi có mạng và thử lại, danh sách hiển thị bình thường.
- **SC-007**: Người dùng mở được màn Lịch sử tải và thấy các lượt tải đã hoàn tất theo thứ tự mới-nhất-trước, mỗi wallpaper chỉ một mục.

## Assumptions

- **Vị trí truy cập**: Tab "Yêu thích" đã tồn tại trong khung điều hướng 5 tab (dựng ở MO-002); MO-004 lấp nội dung thật cho tab này. Màn Lịch sử tải truy cập từ khu vực hồ sơ/"Bạn" hoặc một liên kết phụ (vị trí chính xác chốt ở khâu thiết kế `/speckit.plan`).
- **Nguồn dữ liệu theo ID**: Dùng khả năng lấy nhiều wallpaper theo danh sách ID đã có trong hợp đồng API hiện hành (giới hạn 100 ID/lần, ID không tìm thấy bị bỏ qua âm thầm) — không thêm endpoint mới.
- **Thứ tự hiển thị mặc định**: Yêu thích hiển thị mới-thêm-trước; Lịch sử tải hiển thị mới-tải-trước. (Có thể tinh chỉnh ở khâu plan nếu cần.)
- **Điểm ghi lịch sử tải** *(chốt ở Clarifications)*: MO-004 chỉ cung cấp **kho lịch sử tải (API ghi/đọc) + màn xem**; **MO-005 nối điểm ghi** khi lượt tải/đặt hình nền native thật hoàn tất. MO-004 không thêm nút/điểm kích hoạt tải, nên kho được kiểm thử bằng seed; màn Lịch sử tải sẽ rỗng trên thực tế cho tới khi MO-005 nối vào — không chặn hoàn thành US1–US3.
- **Nút yêu thích trên tile** *(chốt ở Clarifications)*: WallpaperCard nhận thêm nút tim overlay dùng chung ở mọi lưới (Browse, Favorites, Collection Detail) + nút ở Detail. Đây là sửa đổi widget dùng chung `WallpaperCard` (MO-002/MO-003) — cần giữ tương thích các nơi đang dùng.
- **Không đăng nhập/không đồng bộ đám mây**: Toàn bộ dữ liệu yêu thích và lịch sử chỉ sống trên thiết bị; không đồng bộ giữa các thiết bị (nhất quán với thiết kế không-có-tài-khoản của sản phẩm).
- **Kế thừa nền tảng MO-003**: Tái dùng lớp Result/AppFailure, ánh xạ lỗi, widget lưới/tile/skeleton/FailureView và mô hình trạng thái sealed đã có — không dựng lại.
- **Design handoff (đối chiếu)**: `.claude/livecanvas-detail-screens/project/livecanvas/Favorites.jsx` cung cấp thiết kế màn Favorites (TopBar "Yêu thích" + đếm số mono, empty state icon heart với CTA "Khám phá hình nền", lưới 2 cột gap 12) và xác nhận `WallpaperCard` có nút tim (`favorite`/`onFavorite`) — nền tảng cho FR-001/FR-006/FR-008. **Lưu ý**: design bundle **KHÔNG có màn Lịch sử tải (US4)** — màn này chưa được thiết kế; cần chốt ở `/speckit.plan` (dựng tối giản theo pattern lưới hiện có, hoặc dời màn sang MO-005 nơi có thiết kế luồng tải/set).

## Dependencies

- **MO-003 (đã merge)**: cung cấp lớp catalog (lấy dữ liệu wallpaper theo ID), các widget lưới/tile/skeleton/lỗi, và khung điều hướng chứa tab Yêu thích.
- **Hợp đồng API v0.4.0**: khả năng lấy nhiều wallpaper theo danh sách ID (đã có). Không cần backend mới. Lưu ý vận hành: cần đảm bảo client API cục bộ đã đồng bộ với hợp đồng v0.4.0 trước khi hiện thực.
- **Không phụ thuộc MO-005/MO-006**: Favorites (US1–US3) độc lập hoàn toàn; phần ghi Lịch sử tải (US4) sẽ được MO-005 nối dữ liệu đầy đủ nhưng không chặn MO-004.
