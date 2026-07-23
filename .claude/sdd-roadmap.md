# LiveCanvas Mobile v1.0 — Spec Roadmap

> Repo: `livecanvas-mobile`. Track song song bên repo `livecanvas-backend` (spec `BE-NNN`) — không sống trong repo này, chỉ tham chiếu tại các điểm đồng bộ contract.
>
> **Vai trò file này**: pure planning cho track mobile. Trạng thái hiện tại → [`project-context.md`](project-context.md). Ship history → [`changelog.md`](changelog.md).
>
> Last updated: 2026-07-23 (Chưa có spec nào merge · contract v0.3.0 — thêm resource Collection · thêm MO-001 bootstrap 2 flavor)
> Full requirements: `docs/PRD.md` · Nguyên tắc: [`../.specify/memory/constitution.md`](../.specify/memory/constitution.md)

---

## SDD Workflow For Each Spec

```
/speckit.specify → /speckit.clarify → /speckit.plan → /speckit.tasks → /speckit.implement
```

Branch: `MO-NNN-feature-name`, folder `specs/MO-NNN-feature-name/`

---

## Dependency Graph

```
Spec #000: API Contract Freeze                    ← SHARED — phối hợp với repo backend
           (contracts/openapi.yaml +
            .claude/api-context.md v0.3.0)
    │
    ▼
MO-001: Project Bootstrap & Flavors               ← NỀN TẢNG — tạo project trước tiên
(very_good_cli create, CHỈ 2 flavor
 development + production — gỡ staging,
 gen Dart client từ openapi.yaml, CI)
    │
    ▼
MO-002: Foundation & Navigation & Design System
(theme tokens từ handoff, tab shell go_router,
 mock server Prism để không chờ backend)
    │
    ▼
MO-003: Wallpaper Browse, Collections & Detail    ⇄ Điểm đồng bộ: cần repo backend đã
(List/grid cursor pagination, category filter,        merge BE-002 (API thật) trước khi merge
 search, tab Bộ sưu tập + Collection Detail,
 detail + preview video)
    │
    ├───────────────┐
    ▼                ▼
MO-004              MO-005
Favorites &          Set Wallpaper Native Integration
Local Data           (Android WallpaperService, iOS
(local-only,          preview + hướng dẫn Shortcuts)
 không cần backend)
    │                │
    └───────┬────────┘
            ▼
MO-006: IAP & Paywall                             ⇄ Điểm đồng bộ: cần repo backend đã
(in_app_purchase, paywall UI,                          merge BE-004 (verify-receipt thật)
 gọi /iap/verify-receipt, gate                         trước khi merge
 nội dung premium theo entitlement)
    │
    ▼
MO-007: Polish & Store Submission                 ⇄ Điểm đồng bộ: cần repo backend đã
(App icon, store metadata, TestFlight +                deploy production (BE-006) trước khi
 Internal testing, submit store)                       submit
```

---

## Spec Details

### Spec #000: API Contract Freeze

- **Status**: 🟡 In progress (v0.3.0 — thêm resource `Collection`, chờ xác nhận cuối)
- **Không tạo branch riêng** — review trực tiếp `contracts/openapi.yaml` + `.claude/api-context.md`, phối hợp với repo `livecanvas-backend`.
- **Thứ tự bắt buộc**: `docs/screen-inventory.md` (màn hình cần gì) → mới tới contract.
- **Checklist**: xem bản đầy đủ trong `api-context.md` §Quy ước chung; xác nhận schema `Wallpaper` đủ field cho UI list/detail/preview (kèm `collections` cho link Detail→bộ sưu tập); xác nhận UI list dùng cursor pagination đúng cách (lazy build + dispose video controller ngoài viewport); xác nhận UI filter tag dùng `GET /tags` (curated); xác nhận tab "Bộ sưu tập" dùng `GET /collections` + Collection Detail dùng `GET /collections/{id}` (items nhúng sẵn, không phân trang).
- **v0.3.0 — Collection**: tab "Bộ sưu tập" (list cover card) + màn Collection Detail (cover hero + grid wallpaper) qua `GET /collections`, `GET /collections/{id}`; `Wallpaper.collections` cho link "Từ bộ sưu tập". Entitlement bộ premium vẫn theo `download-url` từng file.

### MO-001: Project Bootstrap & Flavors

- **Status**: ⬜ Not started
- **Branch**: `MO-001-project-bootstrap`
- **Depends on**: #000
- **Scope**:
  - Tạo project bằng **`very_good_cli`** (`very_good create flutter_app livecanvas ...`) — KHÔNG dựng skeleton tay.
  - **CHỈ 2 flavor: `development` + `production`.** `very_good_cli` sinh mặc định 3 flavor (development/staging/production) → **gỡ bỏ hoàn toàn `staging`**: xoá `lib/main_staging.dart`, build config staging, và mọi scheme/build-type `Staging` phía iOS (Xcode schemes + xcconfig) lẫn Android (`buildTypes`/`productFlavors`). Kết quả cuối chỉ còn `development` và `production` (xác minh bằng `flutter run --flavor development` và `--flavor production`, không còn `staging`).
  - Mỗi flavor 1 entrypoint (`lib/main_development.dart`, `lib/main_production.dart`) + config môi trường riêng, quan trọng nhất là **backend base URL** (development → staging-api, production → production API) — không hardcode URL trong feature code, lấy từ config của flavor.
  - Sinh **Dart API client** từ `contracts/openapi.yaml` (`openapi-generator-cli -g dart-dio`) vào `lib/core/api` (generated, không sửa tay); interceptor `X-App-Key`.
  - Cài nền: `flutter_bloc`, `get_it`+`injectable`, `go_router`, `very_good_analysis`+`bloc_lint`, i18n ARB (vi mặc định), Phosphor icons — version lấy mới nhất trên pub.dev tại thời điểm plan (Principle XVI, KHÔNG đoán version).
  - CI tối thiểu: `dart format --set-exit-if-changed`, `flutter analyze` (0 warning), `very_good test`, `bloc lint`.
- **Ràng buộc hiến pháp**: Principle XII (đúng 2 flavor), XVI (dependency hygiene), I (client generate từ contract).
- **Định nghĩa hoàn thành**: `flutter run --flavor development -t lib/main_development.dart` và `--flavor production -t lib/main_production.dart` đều chạy được trên iOS + Android; `staging` đã biến mất khỏi cả 2 nền tảng; CI xanh.

### MO-002: Foundation, Navigation & Design System

- **Status**: ⬜ Not started
- **Branch**: `MO-002-foundation-navigation`
- **Depends on**: MO-001
- **Scope**: Port **design tokens** từ handoff `_ds` (`colors/spacing/typography/elevation/fonts`) vào `lib/core/theme`; dựng widget dùng chung (WallpaperCard, TabBar, TopBar, PremiumBadge, Sheet, Toast) đúng prototype; navigation `go_router` với `StatefulShellRoute.indexedStack` cho 5 tab (Khám phá / Tìm / Bộ sưu tập / Yêu thích / Bạn) + push full-screen cho Detail/Collection; mock server **Prism** local từ `openapi.yaml` để phát triển không chờ backend.
- **Ràng buộc hiến pháp**: Principle VI (design system), X (navigation), III (BLoC).

### MO-003: Wallpaper Browse, Collections & Detail

- **Status**: ⬜ Not started
- **Branch**: `MO-003-wallpaper-browse-detail`
- **Depends on**: MO-002
- **Scope**: List/grid wallpaper với cursor pagination (`GridView.builder` lazy load, load thêm khi gần cuối scroll, **dispose `VideoPlayerController` ngoài viewport** — Principle II), filter category + tag chips (`GET /tags`), search; **tab "Bộ sưu tập"**: list cover card (`GET /collections`) + màn Collection Detail (`GET /collections/{id}` — items nhúng sẵn, grid, nút "Tải tất cả"/"Mở khoá" theo `is_premium`); màn Wallpaper Detail + preview video full-screen (đọc `wallpaper.collections` để link sang bộ sưu tập).
- **⚠️ Điểm đồng bộ**: chỉ merge sau khi repo backend xác nhận `BE-002` đã merge — chuyển từ mock sang API thật.

### MO-004: Favorites & Local Data

- **Status**: ⬜ Not started
- **Branch**: `MO-004-favorites-local-data`
- **Depends on**: MO-003
- **Scope**: Favorite lưu local (chỉ mảng ID — Principle IX), mỗi lần mở màn gọi `POST /wallpapers/batch` để lấy data mới nhất (không cache full data); reconcile khi ID bị xóa (bỏ favorite, không lỗi); lịch sử tải local.

### MO-005: Set Wallpaper Native Integration

- **Status**: ⬜ Not started
- **Branch**: `MO-005-set-wallpaper-native`
- **Depends on**: MO-003
- **Scope**: Android Method Channel `com.livecanvas/wallpaper` gọi `WallpaperManager`/`WallpaperService` (Kotlin); iOS màn preview + hướng dẫn Shortcuts (convert Live Photo `.heic`+`.mov`); map lỗi native → `AppFailure` (`wallpaperSetFailed`/`platformUnsupported`). Principle VII + VIII.

### MO-006: IAP & Paywall

- **Status**: ⬜ Not started
- **Branch**: `MO-006-iap-paywall`
- **Depends on**: MO-004, MO-005
- **Scope**: `in_app_purchase` integration, paywall UI, gọi `/iap/verify-receipt`, gate nội dung premium theo response entitlement từ backend (**không tự quyết định ở client** — Principle V; entitlement thật ở `download-url`, "Tải tất cả" của bộ premium = lặp gọi download-url); `transaction_id` lưu secure storage, không log.
- **⚠️ Điểm đồng bộ**: chỉ merge sau khi repo backend xác nhận `BE-004` đã merge và hoạt động thật (không mock).

### MO-007: Polish & Store Submission

- **Status**: ⬜ Not started
- **Branch**: `MO-007-polish-store-submission`
- **Depends on**: MO-006
- **Scope**: App icon, store metadata (giải thích rõ flow iOS Shortcuts trong App Review Notes), TestFlight + Internal testing, submit App Store/Play Store — build bằng flavor `production`.
- **⚠️ Điểm đồng bộ**: chỉ submit sau khi repo backend xác nhận `BE-006` — production đã sẵn sàng.
