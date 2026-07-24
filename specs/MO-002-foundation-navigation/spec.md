# Feature Specification: Foundation, Navigation & Design System

**Feature Branch**: `MO-002-foundation-navigation`

**Created**: 2026-07-24

**Status**: Draft

**Input**: User description: "MO-002 Foundation, Navigation & Design System — Xây nền tảng UI cho app (foundation-only, KHÔNG có logic list/API/pagination — để MO-003)."

## Context & Scope Boundary

MO-002 là spec **nền tảng UI (foundation-only)**. Nó dựng bộ khung mà mọi màn hình nghiệp vụ về sau đứng lên: hệ thống thiết kế (theme tokens, font, icon), thư viện widget dùng chung, khung điều hướng 5 tab, và một mock server để phát triển UI không phụ thuộc backend.

**Ngoài phạm vi (thuộc spec sau):**

- Logic list/grid wallpaper thật, cursor pagination, gọi API thật, quản lý vòng đời video controller → **MO-003**.
- Nội dung thật của Favorites (local storage) → **MO-004**.
- Nội dung thật của tab "Bạn" (trạng thái Premium, Restore purchase, settings) + luồng IAP/paywall → **MO-006**.
- Tích hợp native set wallpaper (Android WallpaperService / iOS Shortcuts) → **MO-005**.

Trong MO-002, thân mỗi tab chỉ là **placeholder skeleton**; giá trị bàn giao là *khung + hệ thống thiết kế* chạy được và trung thực với prototype, sẵn sàng cho MO-003 gắn nội dung thật.

## Clarifications

### Session 2026-07-24

- Q: Phạm vi responsive iPad/tablet trong MO-002 tới đâu? → A: Responsive-ready — shell + shared widgets viết responsive-aware (breakpoint/LayoutBuilder), chạy đúng không vỡ trên iPad; grid đa cột theo `ipad.html` để MO-003 khi có nội dung thật.
- Q: Shared widgets được trưng bày/kiểm chứng thị giác bằng cách nào trong MO-002? → A: Một màn **gallery demo nội bộ (dev-only)** trưng bày mọi shared widget với dữ liệu mẫu để đối chiếu prototype; thân tab thật là skeleton tối giản.
- Q: App hỗ trợ light + dark mode hay chỉ dark? → A: **Dark-only** — token `_ds/colors.css` chỉ định nghĩa một bảng màu dark "Void" (không có light mode / `prefers-color-scheme`), khớp constitution "dark aurora surface".

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Điều hướng khung 5 tab giữ trạng thái (Priority: P1)

Người dùng mở app và di chuyển giữa 5 tab chính — **Khám phá / Tìm / Bộ sưu tập / Yêu thích / Bạn** — bằng thanh tab dưới. Mỗi tab giữ nguyên trạng thái cuộn/điều hướng riêng khi chuyển qua lại. Từ trong tab có thể mở màn toàn màn hình (Wallpaper Detail, Collection Detail) phủ lên thanh tab, và quay lại đúng chỗ cũ.

**Why this priority**: Khung điều hướng là bộ xương của toàn app — không có nó thì không màn hình nghiệp vụ nào (MO-003+) có chỗ để gắn vào. Đây là lát cắt tối thiểu chạy được, chứng minh mô hình tab-shell + full-screen push của prototype hoạt động.

**Independent Test**: Chạy app, chạm lần lượt 5 tab thấy đổi nội dung placeholder tương ứng; cuộn trong 1 tab rồi sang tab khác và quay lại thấy vị trí cũ được giữ; mở 1 route Detail giả lập thấy nó phủ full-screen và nút back trả về đúng tab nguồn.

**Acceptance Scenarios**:

1. **Given** app vừa mở, **When** người dùng chạm từng tab trong 5 tab, **Then** thanh tab đánh dấu tab đang chọn và vùng nội dung đổi sang placeholder của tab đó.
2. **Given** đang ở tab "Khám phá" đã cuộn xuống, **When** chuyển sang tab "Yêu thích" rồi quay lại "Khám phá", **Then** vị trí cuộn và trạng thái của "Khám phá" được giữ nguyên (không reset).
3. **Given** đang ở một tab bất kỳ, **When** kích hoạt điều hướng tới Wallpaper Detail hoặc Collection Detail (route placeholder), **Then** màn đó phủ toàn màn hình che thanh tab, và thao tác back đưa về đúng tab nguồn.
4. **Given** đang ở tab "Bạn", **When** xem nội dung, **Then** thấy placeholder shell rỗng có tiêu đề "Bạn" (nội dung thật để MO-006).

---

### User Story 2 - Hệ thống thiết kế trung thực với prototype (Priority: P2)

Toàn app hiển thị với đúng bảng màu, khoảng cách, bo góc, đổ bóng, kiểu chữ và bộ icon của handoff design. Chữ dùng đúng 3 font (Clash Display cho tiêu đề/hiển thị, Satoshi cho body/UI, Space Mono cho metadata), icon dùng đúng bộ Phosphor. Không có màu/khoảng cách/kiểu chữ nào bị hardcode rải rác — tất cả đến từ một nguồn token tập trung.

**Why this priority**: Prototype là "hợp đồng thị giác" của sản phẩm. Nếu token và font không chuẩn ngay từ nền, mọi widget và màn hình về sau sẽ lệch, và việc sửa lại lan rộng rất tốn kém. Ưu tiên P2 vì phụ thuộc khung điều hướng (P1) để có nơi quan sát, nhưng là điều kiện cho mọi UI thật.

**Independent Test**: Mở app, so sánh màu nền, màu nhấn, bo góc, đổ bóng, cỡ/kiểu chữ và icon trên các phần tử placeholder với prototype — khớp thị giác; kiểm tra không có giá trị màu/pixel hardcode tại call site (đều tham chiếu token).

**Acceptance Scenarios**:

1. **Given** app đang chạy, **When** quan sát bất kỳ bề mặt nào, **Then** màu nền/nhấn, khoảng cách, bo góc, đổ bóng khớp giá trị token của handoff.
2. **Given** app đang chạy, **When** quan sát chữ ở các cấp (tiêu đề màn, tiêu đề thẻ, body, nhãn meta), **Then** đúng font family và cỡ theo type scale của handoff (display 40 / h1 28 / h2 22 / h3 18 / body 15 / sm 13 / xs 11 / 2xs 10).
3. **Given** app đang chạy, **When** quan sát bất kỳ icon nội dung nào, **Then** icon thuộc bộ Phosphor (không lẫn icon Material/Cupertino cho icon nội dung).
4. **Given** app chạy trên thiết bị không có sẵn 3 font này, **When** hiển thị chữ, **Then** vẫn đúng font (font được đóng gói cùng app, không phụ thuộc font hệ thống hay mạng).

---

### User Story 3 - Thư viện widget dùng chung theo prototype (Priority: P2)

Nhóm phát triển có sẵn bộ widget tái sử dụng — WallpaperCard, TabBar, TopBar, PremiumBadge, Sheet, Toast — dựng trung thực theo prototype, để mọi màn hình về sau ráp lại thay vì tự vẽ lại từng chỗ. Các widget này quan sát được qua nội dung placeholder/demo.

**Why this priority**: Widget dùng chung là đơn vị lắp ghép của mọi màn nghiệp vụ. Dựng chuẩn một lần ở nền giúp MO-003+ nhất quán và nhanh. P2 vì phụ thuộc token (US2) để render đúng.

**Independent Test**: Mở **màn gallery demo nội bộ (dev-only)**, render từng widget dùng chung với dữ liệu mẫu và đối chiếu thị giác với prototype tương ứng; xác nhận chúng nằm ở tầng widget dùng chung, không bị lặp lại trong từng màn.

**Acceptance Scenarios**:

1. **Given** thư viện widget đã dựng, **When** render WallpaperCard với dữ liệu mẫu, **Then** bố cục (thumbnail, tiêu đề, badge premium, nhãn meta) khớp prototype.
2. **Given** thư viện widget đã dựng, **When** hiển thị Sheet và Toast, **Then** kiểu dáng/animation khớp prototype và tuân quy tắc điều hướng (không mở 2 sheet trong cùng một frame).
3. **Given** một widget dùng chung, **When** kiểm tra nơi khai báo, **Then** nó nằm ở tầng widget dùng chung tập trung, không phải bản sao trong từng màn hình.

---

### User Story 4 - Phát triển UI độc lập backend qua mock server (Priority: P3)

Nhóm phát triển chạy được một mock server local sinh từ contract API, trả dữ liệu mẫu đúng hình dạng response đã thỏa thuận. Nhờ đó UI của MO-002/MO-003 phát triển và kiểm thử được mà không cần backend thật sẵn sàng.

**Why this priority**: Điểm đồng bộ backend thật là ở MO-003; mock cho phép làm UI song song, không bị chặn. P3 vì là công cụ hỗ trợ dev, không phải trải nghiệm người dùng cuối, nhưng gỡ được nút thắt tiến độ.

**Independent Test**: Chạy script khởi động mock server, gọi thử một endpoint list và một endpoint detail, nhận về payload mẫu khớp cấu trúc contract; app trỏ vào mock (qua config flavor development) hiển thị được dữ liệu mẫu.

**Acceptance Scenarios**:

1. **Given** contract API hiện có, **When** chạy script khởi động mock server, **Then** server phục vụ local và trả response mẫu đúng schema cho các endpoint chính.
2. **Given** mock server đang chạy, **When** app ở flavor development gọi tới, **Then** nhận dữ liệu mẫu để render, không cần backend thật.

---

### Edge Cases

- **Font chưa tải xong / thiếu file**: nếu một trong 3 font không đóng gói được, chữ phải có fallback hợp lý (không vỡ layout), và đây là lỗi build cần phát hiện ở CI, không âm thầm rơi về font hệ thống.
- **Thiết bị nhiều kích thước**: khung 5 tab và widget dùng chung phải hiển thị đúng, responsive-aware trên các cỡ iPhone (notch / Dynamic Island) và trên iPad không vỡ layout; tinh chỉnh grid đa cột đầy đủ theo handoff để MO-003 khi có nội dung thật.
- **Back tại gốc tab**: thao tác back khi đang ở gốc một tab (không có gì để pop) phải theo hành vi nền tảng chuẩn, không thoát app ngoài ý muốn giữa chừng.
- **Chuyển tab nhanh liên tục**: đổi tab dồn dập không được rò rỉ trạng thái hay mở chồng route ngoài ý muốn.
- **Điều hướng tới route Detail placeholder**: khi logic thật chưa có, route Detail/Collection vẫn phải mở/đóng sạch (đây là placeholder, không phải màn chết).

## Requirements *(mandatory)*

### Functional Requirements

**Hệ thống thiết kế (Design System)**

- **FR-001**: Hệ thống MUST port toàn bộ design token từ handoff `_ds` (colors, spacing, radii, typography, elevation) vào **một nguồn token tập trung** tại `lib/core/theme/`, và mọi bề mặt UI MUST tiêu thụ từ nguồn này.
- **FR-002**: Màu MUST đến từ tầng token/theme — **CẤM** giá trị màu thô (`Color(0xFF...)`/hex) tại call site. Khoảng cách và bo góc MUST dùng hằng token có tên — không dùng số pixel ma thuật.
- **FR-003**: Kiểu chữ MUST dùng text style token (display / body / mono) theo type scale của handoff (display 40 / h1 28 / h2 22 / h3 18 / body 15 / sm 13 / xs 11 / 2xs 10) — không `.copyWith` inline cho giá trị type dùng chung.
- **FR-004**: Hệ thống MUST đóng gói 3 font vào app (`assets/fonts/` + khai báo trong manifest asset): **Clash Display** (hiển thị/tiêu đề), **Satoshi** (body/UI), **Space Mono** (metadata/mono) — không phụ thuộc font hệ thống hay tải qua mạng lúc chạy.
- **FR-005**: Icon nội dung MUST dùng bộ **Phosphor** qua **một** dependency icon duy nhất; **CẤM** lẫn `Icons`/`CupertinoIcons` của Flutter cho icon nội dung. Dependency icon MUST là `phosphoricons_flutter` (thay `phosphor_flutter` vốn không tương thích Flutter 3.44), version chốt theo bản stable tra tại thời điểm plan (không đoán version).

**Widget dùng chung**

- **FR-006**: Hệ thống MUST cung cấp các widget dùng chung tái sử dụng ở tầng widget tập trung (`lib/core/widgets/`): **WallpaperCard, TabBar, TopBar, PremiumBadge, Sheet, Toast**, dựng trung thực theo prototype — không tái hiện lại trong từng màn.
- **FR-006a**: Hệ thống MUST cung cấp một **màn gallery demo dev-only** trưng bày tất cả shared widget với dữ liệu mẫu, để đối chiếu thị giác với prototype và kiểm chứng SC-005. Màn này chỉ dùng lúc phát triển, KHÔNG lộ trong luồng điều hướng người dùng cuối (production).

**Điều hướng (Navigation)**

- **FR-007**: Hệ thống MUST triển khai khung **5 tab** (Khám phá / Tìm / Bộ sưu tập / Yêu thích / Bạn) với **giữ trạng thái riêng từng tab** khi chuyển qua lại (indexed-stack shell).
- **FR-008**: Các màn toàn màn hình (Wallpaper Detail, Collection Detail) MUST mở dạng **push phủ lên** thanh tab; back trả về đúng tab nguồn. Trong MO-002 đây là route **placeholder** (chưa nối logic nội dung), nhưng vòng đời mở/đóng phải hoàn chỉnh.
- **FR-009**: Mọi điều hướng MUST đi qua router tập trung với **hằng route** (không hardcode chuỗi path); **CẤM** dùng `Navigator.of(context)` trực tiếp.
- **FR-010**: Modal/sheet mà "đóng-rồi-mở" MUST đóng cái cũ trước rồi mở cái mới ở frame kế — **CẤM** đẩy 2 sheet trong cùng một frame.
- **FR-011**: Thân mỗi tab trong MO-002 MUST là **placeholder skeleton** hợp thị giác với theme; tab "Bạn" là **shell rỗng** có tiêu đề, nội dung thật để MO-006.

**Theme & responsive**

- **FR-011a**: Theme MUST là **dark-only** (bảng màu "Void" của handoff) — MO-002 không hiện thực light mode (token không định nghĩa light).
- **FR-011b**: Shell điều hướng và shared widgets MUST **responsive-aware** (thích ứng breakpoint iPhone ↔ iPad qua `LayoutBuilder`/`MediaQuery`) để chạy đúng, không vỡ layout trên iPad; việc tinh chỉnh grid đa cột theo `ipad.html` để MO-003 khi có nội dung thật.

**Trạng thái & kiến trúc**

- **FR-012**: Mọi trạng thái UI có logic MUST theo pattern BLoC (Cubit ưu tiên) với luồng một chiều và bộ 4 state chuẩn (`initial → loading → loaded → error`); widget chỉ phản ứng theo state, không chứa business logic. **Đây là ràng buộc áp dụng-khi-phát-sinh-state, KHÔNG phải deliverable riêng của MO-002**: foundation không có business state nên MO-002 KHÔNG tạo Cubit nào (YAGNI — nav dùng `StatefulShellRoute` native; state thật xuất hiện ở MO-003). Ràng buộc này được thực thi bằng `bloc lint` (0 vi phạm) ở CI gate; nếu implement phát sinh Cubit bất kỳ thì phải kèm `freezed` cho state (Principle III).
- **FR-013**: Mã nguồn MUST theo cấu trúc feature-first: hạ tầng dùng chung ở `lib/core/` (theme, widgets, router, di, l10n); `lib/core/` MUST NOT import từ `lib/features/*`.

**Mock server (công cụ dev)**

- **FR-014**: Hệ thống MUST cung cấp **mock server local sinh từ contract API** kèm script khởi động, trả response mẫu đúng schema cho các endpoint chính, để phát triển UI không phụ thuộc backend thật. App ở flavor development MUST trỏ được vào mock.

**Chất lượng & i18n**

- **FR-015**: Chuỗi hiển thị cho người dùng MUST đi qua hệ i18n (vi mặc định) — không hardcode chuỗi tiếng Việt trực tiếp trong widget.
- **FR-016**: 4 quality gate CI (format, analyze 0 warning, test, bloc lint) MUST xanh; `bloc_lint` MUST báo 0 vi phạm.

### Key Entities

*(MO-002 là nền tảng UI, không có thực thể dữ liệu nghiệp vụ mới — dữ liệu nghiệp vụ do contract/mock cung cấp và được các spec sau tiêu thụ. Các "khối" nền tảng dưới đây là cấu phần kỹ thuật, không phải entity dữ liệu.)*

- **Design Token Set**: nguồn tập trung của màu / khoảng cách / bo góc / typography / elevation / font, dẫn xuất từ handoff `_ds`.
- **Shared Widget Library**: tập widget tái sử dụng (WallpaperCard, TabBar, TopBar, PremiumBadge, Sheet, Toast).
- **Navigation Shell**: khung 5 tab giữ trạng thái + tập route (gồm route placeholder cho Detail/Collection).
- **Mock Data Source**: mock server local sinh từ contract, cấp payload mẫu cho phát triển UI.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Người dùng điều hướng được cả 5 tab và mỗi tab **giữ đúng trạng thái riêng** khi chuyển qua lại (100% số tab giữ trạng thái, 0 lần reset ngoài ý muốn trong kiểm thử).
- **SC-002**: Toàn bộ giá trị thị giác (màu, khoảng cách, bo góc, typography, elevation) trên các phần tử của MO-002 **đến từ token tập trung** — **0** giá trị màu/pixel hardcode tại call site (xác minh bằng lint/review).
- **SC-003**: Chữ hiển thị đúng **cả 3 font** đóng gói trên thiết bị sạch (không cài sẵn font, không mạng) — 100% bề mặt chữ dùng đúng font token, không rơi về font hệ thống.
- **SC-004**: Icon nội dung 100% thuộc bộ Phosphor — **0** lần lẫn `Icons`/`CupertinoIcons` cho icon nội dung.
- **SC-005**: Mỗi widget dùng chung (WallpaperCard, TabBar, TopBar, PremiumBadge, Sheet, Toast) render **khớp thị giác với prototype** và tồn tại **đúng một** bản ở tầng widget dùng chung (0 bản sao trong màn).
- **SC-006**: App chạy được và điều hướng đúng trên **cả iOS và Android**; shell + shared widgets **không vỡ/không tràn/đè** layout trên các breakpoint iPhone và iPad kiểm thử (responsive-aware — tinh chỉnh grid đa cột theo handoff để MO-003).
- **SC-007**: Mock server khởi động bằng một lệnh và trả response mẫu **đúng schema** cho các endpoint chính; app development render được dữ liệu mẫu mà không cần backend thật.
- **SC-008**: 4 quality gate CI xanh (format, analyze 0 warning, test, bloc lint 0 vi phạm).

## Assumptions

- **Foundation-only**: thân các tab là placeholder; logic nghiệp vụ (list/pagination/API thật, favorites local, premium/IAP, native set wallpaper) thuộc các spec sau (MO-003..MO-006). MO-002 không hiện thực nội dung thật của chúng.
- **Handoff là chuẩn thị giác**: prototype `livecanvas-detail-screens` + token `_ds` là nguồn sự thật cho design; khớp thị giác được ưu tiên hơn sao chép cấu trúc HTML/CSS của prototype.
- **Font license**: Clash Display + Satoshi (Fontshare, ITF Free Font License) và Space Mono (Google Fonts, OFL) đều cho phép dùng thương mại và **đóng gói file `.ttf`** kèm app; MO-002 tải và nhúng các file này.
- **Icon**: quyết định thay `phosphor_flutter` → `phosphoricons_flutter` đã chốt (2026-07-24) do `phosphor_flutter` 2.1.0 không tương thích Flutter 3.44; giữ nguyên bộ Phosphor, chỉ đổi package + cách gọi.
- **Route Detail/Collection**: mở dưới dạng placeholder ở MO-002; nội dung thật gắn ở MO-003.
- **Tab "Bạn"**: shell rỗng ở MO-002; nội dung Premium/Restore/settings gắn ở MO-006.
- **Mock server**: dùng công cụ mock từ contract chạy local (dev-time), không phải thành phần chạy trên thiết bị người dùng cuối; phụ thuộc `contracts/openapi.yaml` hiện có (v0.3.2).
- **Nền tảng có sẵn từ MO-001**: flavor development/production, DI, router scaffold, i18n vi-first, client generate — MO-002 xây tiếp trên đó, không dựng lại.
