# Implementation Plan: Wallpaper Browse, Collections & Detail

**Branch**: `MO-003-wallpaper-browse-detail` | **Date**: 2026-07-24 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/MO-003-wallpaper-browse-detail/spec.md`

## Summary

Biến các tab placeholder MO-002 (Khám phá / Tìm / Bộ sưu tập) và các route Detail rỗng thành màn hình thật chạy trên **API backend thật** (contract v0.3.2, `PublicApi` của package `livecanvas_api`). Bốn user story: (US1) lưới wallpaper cursor-pagination + lọc tag single-select + pull-to-refresh; (US2) Wallpaper Detail full-screen video + link bộ sưu tập; (US3) tab Bộ sưu tập + Collection Detail; (US4) Search debounce live. Xuyên suốt: **skeleton shimmer điều khiển-bởi-state** (không timer), quản lý vòng đời `VideoPlayerController` chặt (Principle II), và lần đầu dựng tầng `Result<T>`/`AppFailure` (Principle IV) + state models `freezed` (Principle III).

Cách tiếp cận kỹ thuật: một **tầng catalog dùng chung ở `lib/core/catalog/`** (repository trả `Result<T>` bọc `PublicApi`) để Browse/Search/Collections/Collection Detail/Detail cùng dùng mà không vi phạm ranh giới feature↔feature (Principle XI); mỗi màn có Cubit `freezed` + trang riêng trong `lib/features/<screen>/presentation/`. Reuse tối đa shared widget MO-002 (WallpaperCard, FilterChip, TopBar, EmptyState, PremiumBadge, Breakpoints.gridColumns).

## Technical Context

**Language/Version**: Dart ^3.12 / Flutter ≥3.44. ⚠️ `video_player 2.13.0` yêu cầu **Dart ^3.12** — MO-001 đặt sàn `environment.sdk` ở `≥3.8`; T001 xác nhận Dart cài đặt ≥3.12 và bump floor nếu cần (không xung đột cứng, sàn là floor).

**Primary Dependencies** (mới thêm — version tra pub.dev 2026-07-24, Principle XVI, xem [research.md](research.md)):
- `video_player: ^2.13.0` — phát preview video (list tiles + Detail).
- `visibility_detector: ^0.4.0+2` — phát hiện tile vào/ra viewport để init/dispose controller (Principle II).
- `shimmer: ^3.0.0` — hiệu ứng shimmer cho skeleton.
- `palette_generator: ^0.3.3+7` — trích aura hue từ thumbnail thật (defer từ MO-002; **discontinued** trên pub.dev — giữ, low risk, review sau).
- **State models: native sealed class Dart 3 + `equatable: ^2.1.0`** (value equality qua `props`; KHÔNG `freezed`/`build_runner` — R1 chứng minh freezed xung đột analyzer với lean_builder DI codegen; project lead duyệt deviation Principle III).
- Sẵn có: `flutter_bloc 9.1.1`, `get_it 9.2.1` + `injectable 3.0.0` (codegen **lean_builder**, analyzer 12), `go_router 17.3.0`, `livecanvas_api` (path package, `PublicApi`).

**Storage**: N/A cho MO-003 (chỉ đọc từ backend; không persist — Favorites local để MO-004).

**Testing**: `flutter_test`, `bloc_test 10.0.0`, `mocktail 1.0.5` — unit (repository, cursor-pagination, `AppFailure` mapping), bloc_test (mọi Cubit), widget (Browse grid + controller dispose, Detail, Collection Detail, Search debounce).

**Target Platform**: iOS 15+/iPadOS + Android; responsive iPhone (notch/Dynamic Island) + iPad (grid đa cột).

**Project Type**: Mobile app (Flutter, feature-first Clean Architecture).

**Performance Goals**: Grid mở <2s (SC-001); cuộn ≥100 wallpaper không crash/giật, số `VideoPlayerController` đồng thời bị chặn trên (SC-002); lọc tag <1.5s (SC-003); Detail mở + video <1s (SC-004); search <2s (SC-006).

**Constraints**: Bộ nhớ phẳng khi cuộn (dispose controller ngoài viewport — Principle II NON-NEGOTIABLE); cursor-based pagination (không offset); shimmer dừng theo state không timer (FR-029); mọi lỗi → `AppFailure` → chuỗi l10n (không lộ text kỹ thuật, FR-007/SC-007).

**Scale/Scope**: 3 tab thật + 2 màn full-screen + tầng catalog dùng chung; ~5 Cubit; thư viện wallpaper cỡ trăm–nghìn item (cursor paginated, `limit` mặc định 20).

## Constitution Check

*GATE: Phải pass trước Phase 0. Re-check sau Phase 1.*

| Principle | Áp dụng MO-003 | Trạng thái |
|---|---|---|
| I. Contract-Driven | Chỉ dùng `PublicApi` sinh từ `openapi.yaml` v0.3.2 (`wallpapersGet/wallpapersIdGet/tagsGet/collectionsGet/collectionsIdGet`); dùng thẳng model generated (`Wallpaper/Tag/Collection/CollectionDetail`), KHÔNG hand-write. | ✅ PASS |
| II. Video & Memory | `GridView.builder` lazy + cursor; `VideoPlayerController` init khi tile visible, dispose khi rời viewport (`visibility_detector`), số controller đồng thời bị chặn; list phát `preview_video_url` muted-loop, file gốc KHÔNG tải khi duyệt. | ✅ PASS (thiết kế trung tâm) |
| III. BLoC 4-state | Mỗi màn 1 Cubit; state **sealed class Dart 3** `initial/loading/loaded/error`, biến thể prefix (`loadingMore`); side-effect qua `BlocListener`; DI `@injectable` cho screen Cubit. ⚠️ **Deviation cơ chế** (không `@freezed`) — xem Complexity Tracking. | ⚠️ DEVIATION (duyệt) |
| IV. Result\<T\> | Lần đầu dựng `lib/core/domain/result.dart` + `app_failure.dart`; repository trả `Result<T>`, map `DioException`/error-code → `AppFailure`; Cubit `.fold()`, không try/catch. | ✅ PASS (new foundation) |
| V. Server-Authoritative Entitlement | MO-003 chỉ **hiển thị** trạng thái khoá (`is_premium` badge/nút), KHÔNG gọi `download-url`, KHÔNG cấp quyền. | ✅ PASS |
| VI. Design System | Chỉ dùng token `lib/core/theme` + shared widget MO-002 + icon Phosphor; skeleton/video tile là widget mới trong `lib/core/widgets` theo token. | ✅ PASS |
| IX. Local-First | Không cache full data; đọc tươi từ API mỗi lần (Favorites để MO-004). | ✅ PASS |
| X. go_router | Route đã có (`AppRoutes.wallpaperDetail/collectionDetail`); điều hướng `context.push`; wire page thật vào `lib/app/router/app_router.dart`. | ✅ PASS |
| XI. Feature-First | Tầng catalog dùng chung đặt ở `lib/core/catalog/` (chỉ phụ thuộc package `livecanvas_api`, KHÔNG phụ thuộc features) → tránh feature↔feature import; mỗi màn là feature độc lập. | ✅ PASS (xem Structure Decision) |
| XIII. Testing | Unit + bloc_test + widget theo Performance/critical-path; profiling controller count. | ✅ PASS |
| XIV. Simplicity/YAGNI | Dùng model generated thẳng (không lớp map thừa); 1 repository/loại tài nguyên; không thêm cache/offline. | ✅ PASS |
| XV. i18n | Mọi chuỗi mới vào `app_vi.arb`/`app_en.arb`; số/thời lượng qua `intl`. | ✅ PASS |
| XVI. Dependency Hygiene | 4 dep runtime mới đã tra pub.dev (video_player/visibility_detector/shimmer/palette_generator); freezed/build_runner **loại bỏ** sau khi phát hiện xung đột analyzer (R1) → toàn bộ toolchain stable. | ✅ PASS |

**Điểm cần giám sát** (ghi ở [research.md](research.md)):
- **R1 — freezed ⊥ lean_builder (analyzer)**: đã giải quyết bằng cách bỏ freezed, dùng native sealed class → không còn build_runner, analyzer giữ 12, DI codegen chạy. Deviation Principle III (cơ chế) — xem Complexity Tracking.
- Tầng catalog ở `core/`: quyết định có chủ đích (chia sẻ đa màn, chỉ phụ thuộc external package) — hợp lệ Principle XI ("core chứa services").

→ **Gate PASS** (1 deviation cơ chế đã duyệt).

## Project Structure

### Documentation (this feature)

```text
specs/MO-003-wallpaper-browse-detail/
├── plan.md              # This file
├── research.md          # Phase 0 — 7 decision (R1..R7)
├── data-model.md        # Phase 1 — entities (generated) + state models + Result/AppFailure
├── quickstart.md        # Phase 1 — cách chạy & nghiệm thu (real API + Prism)
├── contracts/
│   └── consumed-endpoints.md   # Endpoint PublicApi mà MO-003 tiêu thụ + mapping màn hình
├── checklists/
│   └── requirements.md  # (đã có từ /specify)
└── tasks.md             # Phase 2 (/speckit-tasks — CHƯA tạo ở bước này)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── domain/                         # NEW (Principle IV)
│   │   ├── result.dart                 # sealed Result<T> = Ok<T> | Err<T>
│   │   └── app_failure.dart            # sealed AppFailure (network/timeout/notFound/validation/…)
│   ├── error/
│   │   ├── dio_error_mapper.dart       # DioException + error-code JSON → AppFailure
│   │   └── failure_l10n.dart           # AppFailure → localized message (dùng context.l10n)
│   ├── catalog/                        # NEW — shared, chỉ phụ thuộc livecanvas_api (KHÔNG features)
│   │   ├── catalog_module.dart         # @module: cung cấp PublicApi từ Dio sẵn có
│   │   ├── wallpaper_repository.dart    # interface + @LazySingleton impl → Result<WallpaperPage>/Result<Wallpaper>
│   │   ├── tag_repository.dart          # → Result<List<Tag>>
│   │   └── collection_repository.dart   # → Result<List<Collection>> / Result<CollectionDetail>
│   │   # (không có models/ riêng: dùng thẳng WallpaperCursorPage generated — data-model.md §B)
│   └── widgets/
│       ├── feedback/skeleton/          # NEW — shared shimmer (Principle VI)
│       │   ├── shimmer_box.dart         # ô shimmer nguyên thủy theo token
│       │   ├── wallpaper_grid_skeleton.dart
│       │   ├── collection_list_skeleton.dart
│       │   └── wallpaper_detail_skeleton.dart
│       └── wallpaper/
│           └── video_preview.dart       # NEW — VideoPlayerController + visibility lifecycle (Principle II)
└── features/
    ├── browse/{data?,presentation/{cubit,pages,widgets}}    # US1
    │   └── presentation/
    │       ├── cubit/browse_cubit.dart · browse_state.dart (freezed)
    │       ├── pages/browse_page.dart
    │       └── widgets/tag_filter_bar.dart · wallpaper_grid.dart
    ├── search/presentation/{cubit,pages}                    # US4 (debounce trong cubit)
    ├── collections/presentation/{cubit,pages}               # US3 list
    ├── collection_detail/presentation/{cubit,pages}         # US3 detail
    └── wallpaper_detail/presentation/{cubit,pages}          # US2
```
Các `*_placeholder_page.dart` MO-002 được thay bằng page thật; router cập nhật import tương ứng.

**Structure Decision**: Mobile feature-first (Principle XI). **Điểm khác biệt có chủ đích**: logic đọc catalog (wallpaper/tag/collection) dùng chung bởi ≥4 màn → đặt repository ở `lib/core/catalog/` (một "core service") thay vì nhân bản trong từng feature hay tạo phụ thuộc feature↔feature (bị cấm). `core/catalog` chỉ import package ngoài `livecanvas_api`, không import `lib/features/*` → không phá Principle XI. Cubit/pages/widgets đặc thù màn nằm trong `lib/features/<screen>/presentation/`. Các feature KHÔNG import lẫn nhau; điều hướng chéo (Detail→Collection Detail, tile→Detail) qua `context.push(AppRoutes…)` với path constant (Principle X), không import page của feature khác.

## Complexity Tracking

| Deviation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Principle III: dùng **native sealed class Dart 3** thay `@freezed` cho state | `freezed` (mọi bản stable) ép `analyzer <11` → phá `lean_builder 0.1.10` (DI codegen, cần analyzer 12); bản freezed khớp analyzer 12 chỉ có pre-release `3.2.6-dev.1` (lệch Principle XVI). Native sealed class giữ đúng tinh thần III (immutable sealed 4-state), bỏ hẳn build_runner → all-stable, hết xung đột. Đã được project lead duyệt (Governance). | *freezed pre-release*: lệch XVI "prefer stable". *freezed stable*: bất khả thi (phá lean_builder — R1 chứng minh). *Nâng DI lên analyzer 13*: freezed không có bản khớp. |

**Follow-up**: đề xuất PATCH `.specify/memory/constitution.md` Principle III → "`@freezed` **hoặc** native sealed class immutable" (ngoài phạm vi `/speckit-implement`).
