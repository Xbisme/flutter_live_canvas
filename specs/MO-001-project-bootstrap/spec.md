# Feature Specification: Project Bootstrap & Flavors

**Feature Branch**: `MO-001-project-bootstrap`

**Created**: 2026-07-23

**Status**: Draft

**Input**: User description: "MO-001 Project Bootstrap & Flavors — Tạo project Flutter bằng very_good_cli với đúng 2 flavor development + production (gỡ hoàn toàn staging mặc định trên cả iOS lẫn Android), gen Dart API client từ contracts/openapi.yaml bằng openapi-generator-cli -g dart-dio vào lib/core/api với interceptor X-App-Key, cài nền flutter_bloc, get_it+injectable, go_router, very_good_analysis+bloc_lint, i18n ARB (vi mặc định), Phosphor icons, CI tối thiểu (dart format --set-exit-if-changed, flutter analyze 0 warning, very_good test, bloc lint)"

## Clarifications

### Session 2026-07-23

- Q: Dùng org/bundle ID nào khi scaffold project (Android applicationId + iOS bundle ID + prefix Method Channel)? → A: `com.livecanvas` (provisional theo constitution; chốt tên thật trước MO-007).
- Q: Flavor `development` trỏ backend base URL nào tại bootstrap (staging chưa deploy)? → A: Local backend — `http://localhost:8000` (iOS simulator) / `http://10.0.2.2:8000` (Android emulator); đổi sang staging-api khi backend deploy thật (chỉ đụng file config flavor).
- Q: Giá trị `X-App-Key` cho từng flavor đến từ đâu? → A: Key development commit thẳng trong config flavor (backend local); key production inject qua `--dart-define` lúc build release, không nằm trong repo. (`X-App-Key` trong binary vốn extract được — đây là hygiene, không phải lớp bảo mật.)

## User Scenarios & Testing *(mandatory)*

> "User" trong spec này là **developer của LiveCanvas Mobile** — spec bootstrap tạo nền tảng repo, chưa có tính năng end-user nào.

### User Story 1 - Chạy app theo đúng 2 môi trường (Priority: P1)

Là developer, tôi clone repo, chạy được app trên cả iOS lẫn Android theo từng môi trường riêng biệt — bản `development` trỏ về hạ tầng staging, bản `production` trỏ về hạ tầng production — và **không tồn tại môi trường thứ ba nào** (không `staging`).

**Why this priority**: Đây là định nghĩa của bootstrap — mọi spec sau (MO-002+) đều chạy trên nền này. Cấu trúc flavor sai (thừa `staging`) sẽ lan ra scheme iOS, build type Android, CI, và store submission, càng để lâu càng khó gỡ (Principle XII).

**Independent Test**: Clone repo sạch, chạy app với từng môi trường trên simulator/emulator; xác nhận app khởi động, hiển thị đúng tên môi trường/base URL tương ứng; xác nhận mọi nỗ lực chạy môi trường `staging` thất bại vì không tồn tại.

**Acceptance Scenarios**:

1. **Given** repo vừa clone và cài dependencies, **When** developer chạy app flavor `development` trên Android emulator và iOS simulator, **Then** app khởi động thành công và dùng config môi trường development (base URL staging-api).
2. **Given** cùng trạng thái, **When** developer chạy app flavor `production` trên cả 2 nền tảng, **Then** app khởi động thành công và dùng config môi trường production.
3. **Given** repo hoàn chỉnh, **When** developer tìm kiếm mọi dấu vết `staging` (entrypoint Dart, Android buildTypes/productFlavors, iOS schemes/xcconfig), **Then** không còn bất kỳ tham chiếu `staging` nào và lệnh chạy flavor `staging` báo lỗi không tồn tại.
4. **Given** feature code bất kỳ, **When** cần backend base URL, **Then** URL chỉ đến từ config của flavor — không có URL hardcode trong feature code.

---

### User Story 2 - API client sinh từ contract, không viết tay (Priority: P2)

Là developer, tôi có sẵn Dart API client được sinh tự động từ `contracts/openapi.yaml` (v0.3.2), kèm cơ chế gắn app key vào mọi request public — để các spec sau (Browse, Favorites, IAP) gọi API mà không bao giờ viết tay model request/response.

**Why this priority**: Principle I — contract là nguồn sự thật duy nhất giữa 2 repo. Không có client sinh sẵn thì MO-003 trở đi sẽ tự chế model và trôi khỏi backend.

**Independent Test**: Xoá thư mục client đã sinh, chạy lại lệnh generate, client được tái tạo giống hệt; compile toàn project không lỗi; kiểm tra request tạo từ client có header app key.

**Acceptance Scenarios**:

1. **Given** `contracts/openapi.yaml` v0.3.2 trong repo, **When** developer chạy lệnh generate client, **Then** client Dart được sinh vào đúng vị trí quy định, project compile không lỗi, và mã sinh ra được đánh dấu "không sửa tay — regenerate".
2. **Given** client đã sinh, **When** app tạo một request tới endpoint public bất kỳ, **Then** request tự động mang header `X-App-Key` (giá trị lấy từ config flavor) mà feature code không phải tự gắn.
3. **Given** contract thay đổi version, **When** developer chạy lại lệnh generate, **Then** client cập nhật theo contract mới mà không cần sửa tay file sinh ra.

---

### User Story 3 - Nền tảng kiến trúc & chất lượng có sẵn (Priority: P3)

Là developer, khi bắt đầu MO-002 tôi đã có sẵn: state management, DI, router, i18n (tiếng Việt mặc định), bộ icon theo design, và bộ lint chuẩn — tất cả ở version stable mới nhất được tra cứu tại thời điểm plan, không đoán.

**Why this priority**: Tránh mỗi spec sau tự cài lẻ tẻ gây lệch version/lệch pattern; nhưng có thể demo được ngay cả khi story này chưa xong (app vẫn chạy từ Story 1).

**Independent Test**: Mở `pubspec.yaml` đối chiếu từng package với danh sách chốt; xác nhận mỗi version là bản stable mới nhất trên pub.dev tại ngày plan; app compile và test mẫu pass.

**Acceptance Scenarios**:

1. **Given** project bootstrap xong, **When** developer kiểm tra dependencies, **Then** các nền tảng state management (BLoC), DI, router, i18n ARB (vi mặc định + en), icon Phosphor, lint đều có mặt với version stable mới nhất tại thời điểm plan (có ghi nguồn tra cứu).
2. **Given** cấu trúc thư mục đã dựng, **When** đối chiếu với kiến trúc feature-first của hiến pháp (Principle XI), **Then** `lib/core/` và `lib/features/` đúng ranh giới quy định, core không import features.
3. **Given** một chuỗi UI mẫu bất kỳ, **When** hiển thị lên màn hình, **Then** chuỗi đến từ ARB (vi) qua cơ chế i18n — không hardcode.

---

### User Story 4 - CI chặn code kém chất lượng (Priority: P3)

Là developer, mỗi lần đẩy code lên, hệ thống CI tự động kiểm tra format, phân tích tĩnh (0 warning), toàn bộ test, và lint BLoC — PR đỏ thì không merge.

**Why this priority**: Gate chất lượng phải có từ commit đầu tiên để "0 warning" là trạng thái duy trì được, không phải mục tiêu trả nợ sau.

**Independent Test**: Đẩy một commit vi phạm format (hoặc chứa warning) lên PR → CI đỏ; sửa lại → CI xanh.

**Acceptance Scenarios**:

1. **Given** PR mới mở, **When** CI chạy, **Then** cả 4 bước đều thực thi: kiểm format, phân tích tĩnh (0 warning), test, lint BLoC — bước nào fail thì PR bị chặn.
2. **Given** code đúng chuẩn, **When** CI chạy, **Then** toàn bộ pipeline xanh trong thời gian chấp nhận được (xem SC-006).

---

### Edge Cases

- Chạy `flutter run --flavor staging` (hoặc chọn scheme Staging trong Xcode) → phải lỗi rõ ràng vì flavor không tồn tại, không âm thầm fallback về flavor khác.
- `contracts/openapi.yaml` không hợp lệ (sửa tay lỗi) → lệnh generate client phải fail rõ ràng, không sinh client rỗng/nửa vời.
- Developer sửa tay file trong thư mục client sinh ra → quy ước + CI/review phải phát hiện được (thư mục generated được đánh dấu, mọi thay đổi contract yêu cầu regenerate).
- Máy dev chưa cài công cụ generate (Java/openapi-generator) → tài liệu setup phải nêu prerequisite và lệnh cài.
- Base URL production chưa chốt (backend chưa deploy) → config production dùng giá trị placeholder có chú thích, app vẫn build được; việc thay URL thật chỉ đụng 1 file config.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Project MUST được scaffold bằng `very_good_cli` (`very_good create flutter_app`) — không dựng skeleton tay.
- **FR-002**: Project MUST có ĐÚNG 2 flavor `development` và `production`; mọi dấu vết `staging` do scaffold sinh ra (entrypoint Dart, Android buildTypes/flavors, iOS schemes/xcconfig) MUST bị gỡ hoàn toàn trên cả 2 nền tảng.
- **FR-003**: Mỗi flavor MUST có entrypoint riêng (`lib/main_development.dart`, `lib/main_production.dart`) và object config môi trường riêng chứa tối thiểu: backend base URL và app key; feature code MUST đọc từ config, KHÔNG hardcode.
- **FR-003a**: Config flavor `development` MUST trỏ backend local (`http://localhost:8000` iOS simulator / `http://10.0.2.2:8000` Android emulator — phân biệt theo platform) với key development commit thẳng; config flavor `production` MUST dùng placeholder base URL (domain chưa chốt) và nhận `X-App-Key` qua `--dart-define` lúc build — key production KHÔNG commit vào repo.
- **FR-004**: Dart API client MUST được sinh từ `contracts/openapi.yaml` (v0.3.2) bằng `openapi-generator-cli -g dart-dio` vào `lib/core/api`; thư mục này là generated-only (không sửa tay), có script/lệnh regenerate lặp lại được.
- **FR-005**: Mọi request qua client public MUST tự động mang header `X-App-Key` qua interceptor dùng chung — giá trị key lấy từ config flavor.
- **FR-006**: Repo MUST chứa `contracts/openapi.yaml` v0.3.2 byte-identical với bản trong `.claude/openapi.yaml` (Contract Sync).
- **FR-007**: Bộ dependency nền MUST được cài: `flutter_bloc`, `get_it` + `injectable`, `go_router`, `very_good_analysis` + `bloc_lint`, i18n ARB (`vi` mặc định, `en` phụ), bộ icon Phosphor — version là bản stable mới nhất tra trên pub.dev tại thời điểm plan (Principle XVI, KHÔNG đoán).
- **FR-008**: Cấu trúc thư mục MUST theo feature-first Clean Architecture của hiến pháp (Principle XI): `lib/core/` (config, constants, di, domain, router, theme, widgets, l10n, api) và `lib/features/` (rỗng hoặc placeholder) — core không import features.
- **FR-009**: CI MUST chạy trên mọi PR với đủ 4 gate: `dart format --set-exit-if-changed`, `flutter analyze` (0 warning), `very_good test`, `bloc lint` — fail bất kỳ gate nào thì PR bị chặn.
- **FR-010**: `pubspec.lock` (và `ios/Podfile.lock` khi phát sinh) MUST được commit.
- **FR-011**: README/tài liệu dev MUST ghi: lệnh chạy từng flavor, lệnh regenerate API client kèm prerequisite, và checklist pre-commit của hiến pháp.

### Key Entities

- **Flavor Config**: object cấu hình theo môi trường — tên môi trường, backend base URL, `X-App-Key`; là nguồn duy nhất cho mọi giá trị phụ thuộc môi trường.
- **Generated API Client**: sản phẩm sinh tự động từ contract v0.3.2 — mọi model/endpoint public (wallpapers, tags, collections, batch, iap) đều từ đây, không viết tay.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Developer mới clone repo và chạy được app cả 2 flavor trên tối thiểu 1 nền tảng trong ≤ 15 phút theo README (không cần hỏi ai).
- **SC-002**: `flutter run --flavor development -t lib/main_development.dart` và `--flavor production -t lib/main_production.dart` đều chạy thành công trên iOS simulator VÀ Android emulator (4/4 tổ hợp).
- **SC-003**: Tìm kiếm toàn repo (case-insensitive) từ `staging` trong mã nguồn/cấu hình build trả về 0 kết quả (ngoại trừ chú thích base URL "staging-api" của flavor development).
- **SC-004**: Xoá `lib/core/api` rồi chạy lệnh regenerate → client tái sinh, `flutter analyze` 0 warning, project compile — chứng minh quy trình regenerate lặp lại được 100%.
- **SC-005**: 100% package trong `pubspec.yaml` có version đúng bản stable mới nhất trên pub.dev tại ngày plan (đối chiếu được trong plan.md).
- **SC-006**: CI pipeline chạy đủ 4 gate và hoàn thành ≤ 10 phút trên PR bootstrap.

## Assumptions

- **Tên project/app**: `livecanvas` (hiển thị "LiveCanvas") — theo constitution; tên sản phẩm thương mại thật sẽ chốt trước MO-007 (store submission), đổi display name khi đó là thay đổi nhỏ.
- **Bundle ID / applicationId**: `com.livecanvas` — ĐÃ CHỐT tại clarify 2026-07-23 (provisional theo constitution, follow-up chốt tên thật trước MO-007 store submission). Đổi applicationId trước khi phát hành là khả thi vì app chưa lên store.
- **Base URL**: ĐÃ CHỐT tại clarify 2026-07-23 — flavor `development` trỏ backend local đang chạy BE-003 (`http://localhost:8000` trên iOS simulator, `http://10.0.2.2:8000` trên Android emulator — config phân biệt theo platform); flavor `production` dùng placeholder URL có chú thích (production domain chưa chốt). Khi staging/production deploy thật, thay URL chỉ đụng file config flavor.
- **CI platform**: GitHub Actions (repo host trên GitHub, backend cũng đã dùng GitHub Actions ở BE-001).
- **CI scope**: chỉ chạy gate chất lượng Dart/Flutter (format/analyze/test/bloc lint) — KHÔNG build iOS/Android native trong CI ở spec này (build native verify tay theo Definition of Done; đưa vào CI sau nếu cần).
- **`bloc_lint`**: nếu tại thời điểm plan công cụ lint BLoC chính thức có tên/cách chạy khác (vd. nằm trong `bloc_tools`), plan sẽ chốt theo docs chính thức — tinh thần yêu cầu là "0 vi phạm lint BLoC trong CI".
- **Video/IAP/native packages** (video_player, in_app_purchase, secure storage…) KHÔNG cài ở spec này — cài đúng lúc ở spec cần chúng (Principle XIV/XVI).
