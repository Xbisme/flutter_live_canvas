# LiveCanvas — Mobile

> Ứng dụng **hình nền động (live video wallpaper)** viết bằng Flutter.
> Duyệt và tải các hình nền video lặp, đặt làm hình nền động trên Android
> (`WallpaperService`) và qua luồng hướng dẫn Shortcuts trên iOS.

LiveCanvas không có hệ thống tài khoản: **favorite/lịch sử lưu local**, gói
**Premium** là subscription IAP được xác thực phía server qua `transaction_id`
(tự viết verify-receipt, không dùng RevenueCat).

- **Nền tảng**: Android (đặt live wallpaper trực tiếp) · iOS/iPadOS (preview +
  hướng dẫn Shortcuts, do Apple không cho set video wallpaper qua API công
  khai) · Tablet responsive.
- **Repo backend đi kèm**: `livecanvas-backend` (Django) — độc lập, đồng bộ qua
  contract (xem [Contract Sync](#contract-sync)).

---

## Mục lục

- [Kiến trúc & nguyên tắc](#kiến-trúc--nguyên-tắc)
- [Yêu cầu môi trường](#yêu-cầu-môi-trường)
- [Khởi tạo project (bootstrap)](#khởi-tạo-project-bootstrap)
- [Chạy app theo flavor](#chạy-app-theo-flavor)
- [Sinh API client từ contract](#sinh-api-client-từ-contract)
- [Cấu trúc thư mục](#cấu-trúc-thư-mục)
- [Lệnh thường dùng](#lệnh-thường-dùng)
- [Contract Sync](#contract-sync)
- [Lộ trình spec](#lộ-trình-spec)

---

## Kiến trúc & nguyên tắc

Mọi quyết định kỹ thuật tuân theo bản hiến pháp dự án:
[`.specify/memory/constitution.md`](.specify/memory/constitution.md) (v1.0.0).
Tóm tắt những điều bắt buộc:

- **Contract-driven**: Dart API client được **generate** từ
  `contracts/openapi.yaml`, không viết tay model API.
- **Video & bộ nhớ**: list luôn dùng `GridView.builder` lazy, **dispose
  `VideoPlayerController` khi tile rời viewport**, cursor pagination.
- **State**: BLoC/Cubit (`flutter_bloc`), pattern 4 trạng thái
  `initial → loading → loaded → error`.
- **Lỗi**: repository trả `Result<T>` + `AppFailure` (không throw lên UI).
- **Entitlement**: client **không bao giờ tự quyết Premium** — gate thật ở
  `GET /wallpapers/{id}/download-url` phía backend.
- **Design system**: token màu/spacing/typography port từ bộ handoff
  (`.claude/livecanvas-detail-screens`), không hardcode màu/pixel.
- **Flavor**: **đúng 2 flavor `development` + `production`** (xem bên dưới).

## Yêu cầu môi trường

- **Flutter** (bản stable mới nhất) + **Dart** SDK đi kèm.
- **very_good_cli**: `dart pub global activate very_good_cli`
- **OpenAPI Generator** (để sinh Dart client):
  `dart pub global activate openapi_generator_cli`  hoặc bản CLI
  `@openapitools/openapi-generator-cli`.
- Xcode (iOS) + Android SDK/Android Studio.
- (Tuỳ chọn) **Prism** để mock backend từ `openapi.yaml`:
  `npm i -g @stoplight/prism-cli`.

## Khởi tạo project (bootstrap)

> Đây là spec **MO-001** trong lộ trình. Repo hiện mới có tài liệu contract +
> hiến pháp, **chưa có mã Flutter** — các bước dưới đây tạo skeleton.

1. **Tạo project bằng very_good_cli** (KHÔNG dựng skeleton tay):

   ```bash
   very_good create flutter_app livecanvas \
     --org com.livecanvas --desc "LiveCanvas — live video wallpapers"
   ```

2. **Chỉ giữ 2 flavor `development` + `production`.**
   `very_good_cli` sinh mặc định 3 flavor (development / **staging** /
   production). Phải **gỡ bỏ hoàn toàn `staging`**:
   - Xoá `lib/main_staging.dart`.
   - Xoá scheme/xcconfig `Staging` phía iOS (Xcode: Runner schemes +
     `ios/Flutter/*Staging*`).
   - Xoá `staging` trong Android `buildTypes`/`productFlavors`
     (`android/app/build.gradle`).
   - Kết quả: chỉ còn `development` và `production` (kiểm bằng
     `flutter run --flavor development` và `--flavor production`, không còn
     `staging`).

3. **Backend base URL theo flavor** (không hardcode trong feature code):
   - `development` → staging-api (`https://staging-api.example.com/v1`)
   - `production` → production API (`https://api.example.com/v1`)

4. **Sinh Dart API client** từ contract (xem
   [mục dưới](#sinh-api-client-từ-contract)).

5. **Cài nền**: `flutter_bloc`, `get_it` + `injectable`, `go_router`,
   `very_good_analysis` + `bloc_lint`, i18n ARB (vi mặc định), Phosphor icons.
   > Lấy version **mới nhất trên pub.dev** tại thời điểm cài — không đoán
   > version (hiến pháp Principle XVI).

## Chạy app theo flavor

```bash
# Development (trỏ staging-api)
flutter run --flavor development -t lib/main_development.dart

# Production (trỏ production API)
flutter run --flavor production  -t lib/main_production.dart
```

Build release production:

```bash
flutter build ipa --flavor production -t lib/main_production.dart      # iOS
flutter build appbundle --flavor production -t lib/main_production.dart # Android
```

## Sinh API client từ contract

Contract nguồn: [`contracts/openapi.yaml`](contracts/openapi.yaml) (**v0.3.0**).
Sinh client `dart-dio` vào `lib/core/api` (code generated — **không sửa tay**,
sinh lại khi contract đổi):

```bash
openapi-generator-cli generate \
  -i contracts/openapi.yaml \
  -g dart-dio \
  -o lib/core/api \
  --additional-properties=pubName=livecanvas_api
# sau đó:
dart run build_runner build --delete-conflicting-outputs
```

Mock backend khi backend thật chưa sẵn sàng:

```bash
prism mock contracts/openapi.yaml
```

## Cấu trúc thư mục

```
lib/
  core/
    api/           # Dart client generated từ openapi.yaml (không sửa tay)
    config/        # cấu hình theo flavor (base URL, app key)
    constants/     # routes, channel methods, token names
    di/            # get_it + injectable
    domain/        # Result<T>, AppFailure, base Cubit
    router/        # go_router (StatefulShellRoute — 5 tab)
    services/      # wallpaper setter, IAP, storage…
    theme/         # design tokens port từ handoff
    widgets/       # WallpaperCard, TabBar, TopBar, PremiumBadge, sheets…
    l10n/          # ARB (vi mặc định, en phụ)
  features/
    browse/        # grid + cursor pagination
    search/        # tìm + tag chips
    collections/   # tab Bộ sưu tập + Collection Detail
    favorites/     # local IDs + batch refetch
    wallpaper_detail/
    wallpaper_setter/  # Android native + iOS Shortcuts
    paywall/       # IAP + entitlement UI
  main_development.dart
  main_production.dart
contracts/
  openapi.yaml     # bản sao đồng bộ tay với repo backend
.claude/           # project-context, roadmap, api-context, screen-inventory, design handoff
.specify/          # constitution + speckit templates
```

## Lệnh thường dùng

```bash
dart format .                    # format
flutter analyze                  # 0 warning
very_good test --test-randomize-ordering-seed random
dart run bloc_tools:bloc lint .  # 0 vi phạm BLoC
```

## Contract Sync

3 file sau **tồn tại ở CẢ 2 repo** (`livecanvas-mobile`,
`livecanvas-backend`) và được **copy tay cho giống hệt** khi API đổi:

- `contracts/openapi.yaml`
- `.claude/api-context.md`
- `docs/screen-inventory.md` *(bản làm việc hiện đặt trong `.claude/`)*

Quy tắc: khi cần shape mới → sửa **`screen-inventory.md` trước** → rồi
`openapi.yaml` + `api-context.md` → rồi copy sang repo còn lại. **Không thêm
field chỉ-có-ở-client.** Contract hiện tại: **`v0.3.0`**.

## Lộ trình spec

Xem [`.claude/sdd-roadmap.md`](.claude/sdd-roadmap.md). Thứ tự:
`#000 Contract Freeze → MO-001 Bootstrap (2 flavor) → MO-002 Foundation/Design
→ MO-003 Browse/Collections/Detail → MO-004 Favorites → MO-005 Set Wallpaper →
MO-006 IAP/Paywall → MO-007 Store Submission`.

---

> Giao tiếp: tiếng Việt giữa dev ↔ Claude · tiếng Anh cho code/comment/commit.
