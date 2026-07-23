# LiveCanvas Mobile v1.0 — Spec Roadmap

> Repo: `livecanvas-mobile`. Track song song bên repo `livecanvas-backend` (spec `BE-NNN`) — không sống trong repo này, chỉ tham chiếu tại các điểm đồng bộ contract.
>
> **Vai trò file này**: pure planning cho track mobile. Trạng thái hiện tại → [`project-context.md`](project-context.md). Ship history → [`changelog.md`](changelog.md).
>
> Last updated: 2026-07-23 (Chưa có spec nào merge · contract v0.3.0 — thêm resource Collection)
> Full requirements: `docs/PRD.md`

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
            .claude/api-context.md v1.0)
    │
    ▼
MO-001: Mobile Foundation & Navigation
(Flutter project, theme, navigation,
 API client generated từ openapi.yaml,
 mock server Prism để không chờ backend)
    │
    ▼
MO-002: Wallpaper Browse & Detail                 ⇄ Điểm đồng bộ: cần repo backend đã
(List/grid, category filter, search,                  merge BE-002 (API thật) trước khi merge
 detail + preview video)
    │
    ├───────────────┐
    ▼                ▼
MO-003              MO-004
Favorites &          Set Wallpaper Native Integration
Local Data           (Android WallpaperService, iOS
(local-only,          preview + hướng dẫn Shortcuts)
 không cần backend)
    │                │
    └───────┬────────┘
            ▼
MO-005: IAP & Paywall                             ⇄ Điểm đồng bộ: cần repo backend đã
(in_app_purchase, paywall UI,                          merge BE-004 (verify-receipt thật)
 gọi /iap/verify-receipt, gate                         trước khi merge
 nội dung premium theo entitlement)
    │
    ▼
MO-006: Polish & Store Submission                 ⇄ Điểm đồng bộ: cần repo backend đã
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

### MO-001: Mobile Foundation & Navigation

- **Status**: ⬜ Not started
- **Branch**: `MO-001-mobile-foundation`
- **Depends on**: #000
- **Scope**: Flutter skeleton, theme/design system, navigation (Browse, Favorites, Settings); generate Dart client từ `openapi.yaml`; mock server Prism local.

### MO-002: Wallpaper Browse & Detail

- **Status**: ⬜ Not started
- **Branch**: `MO-002-wallpaper-browse-detail`
- **Depends on**: MO-001
- **Scope**: List/grid wallpaper với cursor pagination (`ListView.builder`/`GridView.builder` lazy load, load thêm khi gần cuối scroll, dispose `VideoPlayerController` ngoài viewport), filter category + tag chips (`GET /tags`), search, màn detail + preview video full-screen (đọc `wallpaper.collections` để link sang bộ sưu tập); **tab "Bộ sưu tập"**: list cover card (`GET /collections`) + màn Collection Detail (`GET /collections/{id}` — items nhúng sẵn, grid, nút "Tải tất cả"/"Mở khoá" theo `is_premium`).
- **⚠️ Điểm đồng bộ**: chỉ merge sau khi repo backend xác nhận `BE-002` đã merge — chuyển từ mock sang API thật.

### MO-003: Favorites & Local Data

- **Status**: ⬜ Not started
- **Branch**: `MO-003-favorites-local-data`
- **Depends on**: MO-002
- **Scope**: Favorite lưu local (chỉ mảng ID), mỗi lần mở màn gọi `POST /wallpapers/batch` để lấy data mới nhất (không cache full data); lịch sử tải local.

### MO-004: Set Wallpaper Native Integration

- **Status**: ⬜ Not started
- **Branch**: `MO-004-set-wallpaper-native`
- **Depends on**: MO-002
- **Scope**: Android Platform Channel gọi `WallpaperManager`/`WallpaperService` (Kotlin); iOS màn preview + hướng dẫn Shortcuts (convert Live Photo `.heic`+`.mov`).

### MO-005: IAP & Paywall

- **Status**: ⬜ Not started
- **Branch**: `MO-005-iap-paywall`
- **Depends on**: MO-003, MO-004
- **Scope**: `in_app_purchase` integration, paywall UI, gọi `/iap/verify-receipt`, gate nội dung premium theo response entitlement từ backend (không tự quyết định ở client).
- **⚠️ Điểm đồng bộ**: chỉ merge sau khi repo backend xác nhận `BE-004` đã merge và hoạt động thật (không mock).

### MO-006: Polish & Store Submission

- **Status**: ⬜ Not started
- **Branch**: `MO-006-polish-store-submission`
- **Depends on**: MO-005
- **Scope**: App icon, store metadata (giải thích rõ flow iOS Shortcuts trong App Review Notes), TestFlight + Internal testing, submit App Store/Play Store.
- **⚠️ Điểm đồng bộ**: chỉ submit sau khi repo backend xác nhận `BE-006` — production đã sẵn sàng.
