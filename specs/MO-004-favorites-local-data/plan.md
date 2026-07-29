# Implementation Plan: Favorites & Local Data (MO-004)

**Branch**: `MO-004-favorites-local-data` | **Date**: 2026-07-26 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/MO-004-favorites-local-data/spec.md`

## Summary

Cho phép người dùng lưu wallpaper yêu thích **cục bộ chỉ bằng mảng ID** (Principle IX), toggle nút tim ở mọi lưới + màn Detail, xem lại ở tab "Yêu thích" với **dữ liệu tươi lấy qua `POST /wallpapers/batch`**, tự **đối chiếu** (drop) ID bị admin xóa/unpublish, và giữ **kho lịch sử tải cục bộ** + màn xem (điểm ghi do MO-005 nối).

**Cách tiếp cận kỹ thuật**: Dựng 2 kho persistence cục bộ trong `lib/core/` (giống `core/catalog/` của MO-003, vì nhiều feature cùng dùng → phải ở core theo Principle XI):
- `FavoritesRepository` — lưu `Set<int>` id + thứ tự thêm qua `shared_preferences`; phát **stream phản ứng** `Stream<Set<int>>` để Browse/Collection Detail/Detail/Favorites đồng bộ trạng thái tim tức thời (Principle III: giao tiếp qua repository/stream dùng chung, KHÔNG cubit-to-cubit).
- `DownloadHistoryRepository` — lưu danh sách `{id, downloadedAt}` (mỗi id 1 mục, cập nhật đưa lên đầu) qua `shared_preferences`; API ghi/đọc để MO-005 gọi.

Thêm `batch(List<int>)` vào `WallpaperRepository` (catalog có sẵn `wallpapersBatchPost` trong client generated). Feature layer: `FavoritesCubit` (chunk ≤100, batch, reconcile, empty/error) + `FavoritesPage` (thay placeholder); `DownloadHistoryCubit` + màn tối giản dưới tab "Bạn". `WallpaperCard` **đã có** nút tim (`isFav`/`onFav`) — chỉ cần forward qua `WallpaperTile` và wiring nguồn state.

## Technical Context

**Language/Version**: Dart 3.x / Flutter stable (theo bootstrap MO-001; giữ analyzer 12 + lean_builder).

**Primary Dependencies**: `flutter_bloc`, `get_it` + `injectable` (lean_builder codegen), `go_router`, `equatable`, `video_player` (tái dùng cho tile), **`shared_preferences` ^2.5.5 (MỚI — flutter.dev, verified; iOS 13+/Android SDK 24+; dùng API `SharedPreferencesAsync`)**.

**Storage**: `shared_preferences` — key-value cục bộ, **chỉ ID + timestamp (không nhạy cảm)**. Không dùng `flutter_secure_storage` ở MO-004 (chỉ cần cho `transaction_id` ở MO-006). Không Hive/Isar/sqflite (YAGNI, Principle XIV).

**Testing**: `bloc_test`, `mocktail`, `very_good test` (deterministic).

**Target Platform**: Android (live wallpaper) + iOS/iPadOS + tablet responsive.

**Project Type**: mobile-app (Flutter, feature-first Clean Architecture).

**Performance Goals**: Toggle tim cập nhật UI < 100 ms (SC-002, optimistic qua stream); lưới Favorites dùng `GridView.builder` + `VideoPreview` bounded controllers (Principle II); batch chunk 100 id/lần (SC-005 ~250+ mục vẫn đủ).

**Constraints**: Reconcile **chỉ khi batch trả về thành công** (không drop khi mất mạng — FR-011); không cache full wallpaper (Principle IX); không quyết định premium ở client (Principle V).

**Scale/Scope**: Favorites do người dùng bound (test tới ~250); lịch sử tải bound tương tự. 2 màn mới (Favorites thật + Download History), 2 core repo, wiring 3 nơi (Browse/Collection/Detail).

## Constitution Check

*GATE: pass trước Phase 0; re-check sau Phase 1 design.*

| Principle | Đánh giá | Trạng thái |
|---|---|---|
| I. Contract-Driven | Dùng `POST /wallpapers/batch` có sẵn trong client generated (v0.3.2+); không field client-only; không cần regenerate cho MO-004. | ✅ Pass |
| II. Video/Memory | Lưới Favorites tái dùng `WallpaperTile`/`VideoPreview` (lazy `GridView.builder`, controller bounded, hover/hold play). Batch trả set bounded → không cursor, chấp nhận vì số lượng do user bound. | ✅ Pass |
| III. BLoC | `FavoritesCubit`/`DownloadHistoryCubit` sealed 4-state; đồng bộ xuyên màn qua **stream của `FavoritesRepository`** (không cubit-to-cubit). Side-effect (haptic/toast) ở `BlocListener`. | ✅ Pass (xem Complexity: native sealed) |
| IV. Result<T> | `WallpaperRepository.batch`, `DownloadHistoryRepository.record` trả `Result<T>`; map lỗi qua `dio_error_mapper` + `failure_l10n`. | ✅ Pass |
| V. Entitlement | Favorites độc lập premium; badge PRO display-only; không unlock cục bộ. | ✅ Pass |
| VI. Design System | Favorites bám `Favorites.jsx` (TopBar+count, EmptyState heart, grid 2 cột), token-only. **Màn Download History chưa có design** → dựng tối giản tái dùng widget hiện có (ghi rõ, chờ design). | ⚠️ Pass w/ note |
| VII. Platform/Haptic | Haptic feedback khi toggle favorite (Principle VII). Không native channel ở MO-004. | ✅ Pass |
| VIII. Method Channel | N/A (không native ở MO-004). | ✅ N/A |
| IX. Local-First | **Trọng tâm**: chỉ lưu ID; batch refetch mỗi lần mở; reconcile drop ID mất; local store chỉ ID/timestamp không nhạy cảm. | ✅ Pass |
| X. Navigation | Favorites = tab shell có sẵn; Download History = pushed page qua hằng `AppRoutes` + `context.push`. | ✅ Pass |
| XI. Modularity | Kho favorites/history dùng chung đặt ở `lib/core/favorites/` (nhiều feature dùng); `core/` không import `features/`. Feature chỉ presentation. | ✅ Pass |
| XII. Flavors | Không đổi flavor. | ✅ Pass |
| XIII. Testing | Unit (store/repo/reconcile/chunk/mapping), bloc_test (2 cubit), widget (Favorites empty/loaded/error/toggle). | ✅ Pass |
| XIV. YAGNI | `shared_preferences` thay vì DB nặng; màn history tối giản. | ✅ Pass |
| XV. i18n | Chuỗi mới vào ARB `vi` (+ `en`), qua `context.l10n`; `intl` cho định dạng thời gian lịch sử. | ✅ Pass |
| XVI. Deps | `shared_preferences` ^2.5.5 tra pub.dev tại plan-time. | ✅ Pass |

**Kết luận gate**: PASS. Một deviation đã-được-duyệt kế thừa (native sealed class, xem Complexity Tracking). Một note thiết kế (màn Download History chưa có design — dựng tối giản, không chặn).

## Project Structure

### Documentation (this feature)

```text
specs/MO-004-favorites-local-data/
├── plan.md              # (file này)
├── research.md          # Phase 0 — quyết định kỹ thuật
├── data-model.md        # Phase 1 — entity + storage schema + state shape
├── quickstart.md        # Phase 1 — kịch bản nghiệm thu chạy được
├── contracts/           # Phase 1 — interface repo + local-storage schema + batch reuse
│   ├── repositories.md
│   └── local-storage.md
├── checklists/
│   └── requirements.md  # (đã có từ /speckit.specify)
└── tasks.md             # (/speckit.tasks — CHƯA tạo ở bước này)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── favorites/                         # MỚI — kho dùng chung (giống core/catalog)
│   │   ├── favorites_repository.dart          # interface + impl (Stream<Set<int>>, toggle, isFav, prune)
│   │   ├── favorites_store.dart               # shared_preferences I/O (ID list + thứ tự)
│   │   ├── download_history_repository.dart   # interface + impl (record/read, Result)
│   │   ├── download_history_store.dart        # shared_preferences I/O (entries JSON)
│   │   ├── download_history_entry.dart        # model {id, downloadedAt} (Equatable)
│   │   └── local_data_module.dart             # @module cung cấp SharedPreferencesAsync
│   ├── catalog/
│   │   └── wallpaper_repository.dart       # SỬA — thêm batch(List<int>)
│   └── widgets/wallpaper/
│       ├── wallpaper_tile.dart             # SỬA — forward isFav/onFav
│       └── favoritable_wallpaper_tile.dart # MỚI (tùy) — wrapper bám stream favorite theo id
└── features/
    ├── favorites/presentation/
    │   ├── cubit/favorites_cubit.dart      # MỚI
    │   ├── cubit/favorites_state.dart      # MỚI (sealed 4-state)
    │   └── pages/favorites_page.dart       # MỚI — thay favorites_placeholder_page.dart
    └── download_history/presentation/      # MỚI feature (màn tối giản)
        ├── cubit/download_history_cubit.dart
        ├── cubit/download_history_state.dart
        └── pages/download_history_page.dart
```

- Wiring toggle: `WallpaperTile` nhận `isFav`/`onFav`; Browse `wallpaper_grid`, Collection Detail grid, Favorites grid lấy `Set<int>` favorite từ `FavoritesRepository` (inject qua getIt) và bọc lưới bằng `StreamBuilder`/`BlocBuilder`, hoặc dùng `FavoritableWallpaperTile` để wiring DRY một chỗ.
- Route: thêm `AppRoutes.downloadHistory` + entry go_router (pushed, phủ shell). Truy cập từ tab "Bạn" (`profile_placeholder_page` → thêm mục "Lịch sử tải").
- l10n: thêm khóa vào `lib/l10n/arb/app_vi.arb` (+ `app_en.arb`), regen `lib/l10n/gen`.

## Complexity Tracking

| Deviation | Vì sao cần | Đã duyệt |
|---|---|---|
| **State dùng native sealed class + Equatable thay `@freezed`** (Principle III yêu cầu `@freezed`) | `freezed` stable ép `analyzer <11` → phá `lean_builder` (DI, cần analyzer 12). Kế thừa nguyên quyết định MO-003 (research R1). | ✅ Duyệt ở MO-003 bởi project lead; đề xuất PATCH constitution III ("`@freezed` hoặc native sealed class") vẫn treo. |
| **Màn Download History dựng tối giản, chưa có design** (Principle VI) | Design handoff không có màn này. Dựng tối giản tái dùng grid/TopBar/EmptyState hiện có để không chặn US4; thay bằng thiết kế thật khi có (có thể ở MO-005). | Ghi nhận ở spec Clarifications + Assumptions; xác nhận với user. |

Không có complexity nào khác vượt hiến pháp.

## Phase 0 — Research

Xem [research.md](research.md): chốt (R1) cơ chế persistence (`shared_preferences` + `SharedPreferencesAsync`), (R2) cơ chế đồng bộ trạng thái tim xuyên màn (stream repository), (R3) chiến lược reconcile + chunk batch, (R4) vị trí kho favorites/history (core vs feature), (R5) phạm vi & vị trí màn Download History.

## Phase 1 — Design & Contracts

- [data-model.md](data-model.md): entity `Favorite`, `DownloadHistoryEntry`, storage schema (keys/format), state shape 4-state cho 2 cubit, luồng reconcile.
- [contracts/repositories.md](contracts/repositories.md): chữ ký `FavoritesRepository`, `DownloadHistoryRepository`, `WallpaperRepository.batch`.
- [contracts/local-storage.md](contracts/local-storage.md): key `shared_preferences`, định dạng giá trị, quy tắc thứ tự.
- [quickstart.md](quickstart.md): kịch bản nghiệm thu US1–US4 chạy được + lệnh test/gate.
