---
description: "Task list — MO-003 Wallpaper Browse, Collections & Detail"
---

# Tasks: Wallpaper Browse, Collections & Detail

**Input**: Design documents từ `specs/MO-003-wallpaper-browse-detail/`
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/consumed-endpoints.md](contracts/consumed-endpoints.md)

**Tests**: BẮT BUỘC (Constitution Principle XIII — unit cho repository/mapping/pagination, `bloc_test` cho mọi Cubit, widget test cho luồng critical). Task test nằm trong mỗi phase.

**Organization**: theo user story (US1→US4) để implement & test độc lập. MVP = US1.

## Format: `[ID] [P?] [Story?] Description`
- **[P]**: chạy song song được (khác file, không phụ thuộc task chưa xong).
- **[Story]**: US1..US4. Setup/Foundational/Polish KHÔNG có nhãn story.
- Đường dẫn file chính xác trong mô tả. Chỉ dùng token `lib/core/theme` + icon Phosphor; chuỗi qua ARB (Principle VI/XV).

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Thêm dependency runtime (KHÔNG freezed/build_runner — R1). State dùng native sealed class; DI vẫn `dart run lean_builder build`.

- [x] T001 Thêm dependency vào `pubspec.yaml` (caret, version đúng research.md): `video_player: ^2.13.0`, `visibility_detector: ^0.4.0+2`, `shimmer: ^3.0.0`, `palette_generator: ^0.3.3+7`. **KHÔNG** freezed/freezed_annotation/build_runner (xung đột analyzer với lean_builder — R1). Dart ≥3.12 xác nhận (3.12.2). `flutter pub get` OK, analyzer giữ 12.0.0. Commit `pubspec.lock`.
- [x] T002 KHÔNG cần codegen thứ hai (bỏ freezed). State là sealed class thủ công. DI codegen giữ nguyên `dart run lean_builder build` (MO-001). `build.yaml`/`generate_code.sh` không cần → đã gỡ.
- [x] T003 ✅ iOS simulator build (video_player link SPM, Xcode build done) + app boots & renders Browse grid real data qua Prism mock (wordmark, tag chips "Tất cả"/Neon, WallpaperCard+Aura+PRO, video→poster fallback). Android/pod chưa (no Android SDK). Commit Podfile.lock khi có.

**Checkpoint**: deps + codegen sẵn sàng.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Tầng `Result`/`AppFailure`, catalog repository dùng chung, shared widget (video + shimmer + tile) — mọi user story phụ thuộc.

**⚠️ CRITICAL**: Không story nào bắt đầu trước khi phase này xong.

### Domain: Result & AppFailure (Principle IV)

- [x] T004 [P] Tạo `lib/core/domain/result.dart`: `sealed class Result<T>` với `Ok<T>`/`Err<T>` + `fold<R>(onOk, onErr)` (data-model.md §C).
- [x] T005 [P] Tạo `lib/core/domain/app_failure.dart`: `sealed class AppFailure` — biến thể MO-003 (`network`, `timeout`, `serverUnavailable`, `notFound`, `validation`, `unknown`) + khai báo sẵn biến thể IAP/native (không dùng runtime).
- [x] T006 Tạo `lib/core/error/dio_error_mapper.dart`: `AppFailure mapDioError(Object)` theo bảng mapping research R5 (timeout/network/404/400 VALIDATION/500-503/401). Phụ thuộc T005.
- [x] T007 Thêm ARB keys lỗi vào `lib/l10n/arb/app_vi.arb` + `app_en.arb` (`failureNetwork`, `failureTimeout`, `failureNotFound`, `failureServer`, `failureValidation`, `failureUnknown`) + tạo `lib/core/error/failure_l10n.dart` (`AppFailure → localized message` qua `AppLocalizations`). Chạy gen l10n. Phụ thuộc T005.
- [x] T008 [P] Unit test `test/core/error/dio_error_mapper_test.dart`: mỗi nhánh DioException/HTTP status → đúng `AppFailure` (mocktail). Phụ thuộc T006.

### Catalog layer (shared, `lib/core/catalog/`)

- [x] T009 Tạo `lib/core/catalog/catalog_module.dart` (`@module`): cung cấp `PublicApi` từ `LivecanvasApi(dio: getIt<Dio>()).getPublicApi()` (tái dùng Dio + AppKeyInterceptor của NetworkModule).
- [x] T010 [P] Tạo `WallpaperRepository` (interface + `@LazySingleton` impl) trong `lib/core/catalog/wallpaper_repository.dart`: `list({cursor,limit,tags,search}) → Future<Result<WallpaperCursorPage>>` (bỏ `tags` khi selectedTag "all"; set `search` khi ≥2 ký tự), `getById(id) → Future<Result<Wallpaper>>`; bọc try/catch DioException → `mapDioError`. Phụ thuộc T004, T006, T009.
- [x] T011 [P] Tạo `TagRepository` (interface + impl) `lib/core/catalog/tag_repository.dart`: `list() → Future<Result<List<Tag>>>` (`tagsGet`). Phụ thuộc T004, T006, T009.
- [x] T012 [P] Tạo `CollectionRepository` (interface + impl) `lib/core/catalog/collection_repository.dart`: `list() → Future<Result<List<Collection>>>`, `getById(id) → Future<Result<CollectionDetail>>`. Phụ thuộc T004, T006, T009.
- [x] T013 Chạy `dart run lean_builder build` để đăng ký DI mới (repositories + catalog_module vào injection.config.dart). Phụ thuộc T009–T012.
- [x] T014 [P] Unit test `test/core/catalog/wallpaper_repository_test.dart`: list() bỏ/không bỏ `tags` theo selectedTag, set `search`, thành công → `Ok`, DioException → `Err`; getById 404 → `Err(notFound)` (mocktail mock PublicApi). Phụ thuộc T010.

### Shared widgets (Principle VI)

- [x] T015 [P] Tạo `lib/core/widgets/wallpaper/video_preview.dart`: `VideoPreview` bọc `VideoPlayerController` + `visibility_detector` — init+play (muted,loop) khi visibleFraction ≥0.6, pause+dispose khi rời viewport, fallback poster `thumbnailUrl` khi chưa init/lỗi (research R2, Principle II). `dispose()` đúng trong State.
- [x] T016 [P] Tạo `lib/core/widgets/feedback/skeleton/shimmer_box.dart`: `ShimmerBox` (khối bo góc theo `AppSpacing`/`AppColors`, bọc `Shimmer.fromColors` 2 tông token) (research R3, FR-028).
- [x] T017 [P] Tạo `lib/core/widgets/wallpaper/wallpaper_tile.dart`: `WallpaperTile` = `VideoPreview` (preview) đưa vào `WallpaperCard` (đã có `auraColor`, `premium`, `onTap`); trích `auraColor` từ `thumbnailUrl` qua `palette_generator` (cache theo id, fallback accent token — research R4). Phụ thuộc T015.

**Checkpoint**: Foundation sẵn sàng — các user story có thể bắt đầu (song song nếu đủ người).

---

## Phase 3: User Story 1 — Duyệt thư viện + lọc tag (Priority: P1) 🎯 MVP

**Goal**: Lưới wallpaper thật, cursor pagination, tag chips single-select ("Tất cả" mặc định), pull-to-refresh, skeleton shimmer, video tile bounded.

**Independent Test**: Mở tab Khám phá (backend seed) → skeleton → lưới thật, tự phát preview; cuộn tải thêm rồi dừng; lọc tag & "Tất cả"; pull-to-refresh; cuộn ≥100 item số controller bị chặn; lỗi mạng → retry. (SC-001/002/003/007/009)

### Implementation

- [x] T018 [P] [US1] Tạo `lib/features/browse/presentation/cubit/browse_state.dart` (sealed class + Equatable): `initial/loading/loaded({items,tags,selectedTagId,nextCursor,hasMore,isLoadingMore,loadMoreFailed})/error(failure)` (data-model.md §D).
- [x] T019 [US1] Tạo `lib/features/browse/presentation/cubit/browse_cubit.dart` (`@injectable`): `load()` (song song `tagsGet`+`wallpapersGet` trang đầu), `loadMore()` (append theo `nextCursor`, cờ isLoadingMore/loadMoreFailed), `selectTag(id)` (reset→loading, seq-guard R6), `refresh()` (reset cursor); dùng `.fold()`, không try/catch. Phụ thuộc T010, T011, T018.
- [x] T020 [P] [US1] Tạo `lib/core/widgets/feedback/skeleton/wallpaper_grid_skeleton.dart`: lưới `ShimmerBox` đúng `Breakpoints.gridColumns` + `AppSpacing.wallRatio` (FR-027). Phụ thuộc T016.
- [x] T021 [P] [US1] Tạo `lib/features/browse/presentation/widgets/tag_filter_bar.dart`: hàng `FilterChip` (widget MO-002) single-select từ `tags`, chip "Tất cả" mặc định, `onSelected(id)` (FR-005).
- [x] T022 [US1] Tạo `lib/features/browse/presentation/widgets/wallpaper_grid.dart`: `GridView.builder` lazy (cols theo Breakpoints) render `WallpaperTile`, `ScrollController` prefetch khi gần đáy (~600px) gọi `loadMore`, footer skeleton khi isLoadingMore / lỗi cục bộ + retry (FR-003/030, research R7). Phụ thuộc T017.
- [x] T023 [US1] Tạo `lib/features/browse/presentation/pages/browse_page.dart`: `BlocProvider(BrowseCubit)`, `TopBar` wordmark + `TagFilterBar`; `BlocBuilder`: loading→`WallpaperGridSkeleton`, loaded→`WallpaperGrid` bọc `RefreshIndicator`(refresh), error→`EmptyState`+retry; tile `onTap`→`context.push('/wallpaper/{id}')`; `BlocListener` cho side-effect. Xoá `browse_placeholder_page.dart`. Phụ thuộc T019, T020, T021, T022.
- [x] T024 [US1] Wire router: trong `lib/app/router/app_router.dart` thay `BrowsePlaceholderPage` → `BrowsePage` (branch Khám phá). Phụ thuộc T023.
- [x] T025 [P] [US1] Thêm ARB keys màn Browse (tiêu đề rỗng/lỗi, "Thử lại", nhãn tag) vào `app_vi.arb`+`app_en.arb`, gen l10n.
- [x] T026 [P] [US1] `bloc_test` `test/features/browse/browse_cubit_test.dart`: load thành công/lỗi, loadMore append + hasMore=false dừng, selectTag reset+seq-guard bỏ kết quả cũ, refresh reset cursor (mocktail repos). Phụ thuộc T019.
- [x] T027 [US1] Widget test `test/features/browse/browse_page_test.dart`: loading hiển thị `ShimmerBox` và **biến mất ngay khi phát loaded (không delay)** (FR-029); cuộn kích loadMore; **tile rời viewport → controller dispose** (Principle II, SC-002); **video 1 ô lỗi tải → giữ poster tĩnh, không sập grid** (edge case); lỗi → EmptyState+retry. Phụ thuộc T023.

**Checkpoint**: US1 chạy độc lập — MVP có thể demo.

---

## Phase 4: User Story 2 — Wallpaper Detail + preview full-screen (Priority: P2)

**Goal**: Chạm tile → Detail full-screen (video lớn, meta, badge premium khoá, link bộ sưu tập), skeleton, "không tìm thấy".

**Independent Test**: Chạm 1 wallpaper → Detail full-screen video <1s; premium → badge/nút khoá; thuộc bộ → link mở đúng Collection Detail; id đã gỡ → "không tìm thấy"; back về nguồn. (SC-004/005, FR-009..014)

### Implementation

- [x] T028 [P] [US2] Tạo `lib/features/wallpaper_detail/presentation/cubit/wallpaper_detail_state.dart` (sealed class + Equatable): `initial/loading/loaded(wallpaper)/error(failure)`.
- [x] T029 [US2] Tạo `lib/features/wallpaper_detail/presentation/cubit/wallpaper_detail_cubit.dart` (`@injectable`): `load(id)` gọi `wallpapersIdGet` (để có `collections` đầy đủ), `.fold()`. Phụ thuộc T010, T028.
- [x] T030 [P] [US2] Tạo `lib/core/widgets/feedback/skeleton/wallpaper_detail_skeleton.dart`: skeleton hero video + khối meta (FR-027). Phụ thuộc T016.
- [x] T031 [US2] Tạo `lib/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart`: `VideoPreview` lớn (luôn visible), tên/tag (`MetaChip`), `PremiumBadge` khi premium + nút "Đặt/Tải" trạng thái khoá (placeholder, KHÔNG cấp quyền — Principle V), link "Từ bộ sưu tập ·<title>" từ `wallpaper.collections` → `context.push('/collection/{id}')`; state loading→skeleton, error(notFound)→"không tìm thấy". Xoá placeholder. Phụ thuộc T029, T030, T017.
- [x] T032 [US2] Wire router: thay `WallpaperDetailPlaceholderPage` → `WallpaperDetailPage` (truyền `id`) trong `app_router.dart`. Phụ thuộc T031.
- [x] T033 [P] [US2] Thêm ARB keys Detail ("Từ bộ sưu tập", "Đặt làm hình nền", "Tải xuống", "Không tìm thấy") + gen l10n.
- [x] T034 [P] [US2] `bloc_test` `test/features/wallpaper_detail/wallpaper_detail_cubit_test.dart`: load thành công, 404→`error(notFound)`. Phụ thuộc T029.
- [x] T035 [US2] Widget test `test/features/wallpaper_detail/wallpaper_detail_page_test.dart`: skeleton→loaded; premium hiện badge+nút khoá; có collections hiện link; notFound hiện "không tìm thấy". Phụ thuộc T031.

**Checkpoint**: US1 + US2 chạy độc lập.

---

## Phase 5: User Story 3 — Bộ sưu tập + Collection Detail (Priority: P3)

**Goal**: Tab Bộ sưu tập (cover card list, pull-refresh) + Collection Detail (hero + accent + grid items đúng thứ tự + nút bộ premium khoá).

**Independent Test**: Tab Bộ sưu tập → skeleton → list; chạm bộ → Detail hero+grid; bộ premium → nút "Mở khoá"/"Tải tất cả" khoá; chạm item → Wallpaper Detail. (FR-015..018)

### Implementation

- [x] T036 [P] [US3] Tạo `lib/features/collections/presentation/cubit/collections_state.dart` (sealed class + Equatable): `initial/loading/loaded(items)/empty/error`.
- [x] T037 [US3] Tạo `lib/features/collections/presentation/cubit/collections_cubit.dart` (`@injectable`): `load()`/`refresh()` gọi `collectionsGet`. Phụ thuộc T012, T036.
- [x] T038 [P] [US3] Tạo `lib/features/collection_detail/presentation/cubit/collection_detail_state.dart` (sealed class + Equatable): `initial/loading/loaded(collection)/error`.
- [x] T039 [US3] Tạo `lib/features/collection_detail/presentation/cubit/collection_detail_cubit.dart` (`@injectable`): `load(id)` gọi `collectionsIdGet`, 404→`error(notFound)`. Phụ thuộc T012, T038.
- [x] T040 [P] [US3] Tạo `lib/core/widgets/feedback/skeleton/collection_list_skeleton.dart`: skeleton cover card (FR-027). Phụ thuộc T016.
- [x] T041 [US3] Tạo `lib/features/collections/presentation/pages/collections_page.dart`: list cover card (`Collection.coverUrl/title/isPremium`) bọc `RefreshIndicator`; loading→skeleton, loaded→list, error→EmptyState; chạm→`context.push('/collection/{id}')`. Xoá placeholder. Phụ thuộc T037, T040.
- [x] T042 [US3] Tạo `lib/features/collection_detail/presentation/pages/collection_detail_page.dart`: hero cover + `accentColor` + mô tả + `GridView` (không phân trang) `WallpaperTile` đúng thứ tự `items`; nút "Mở khoá"/"Tải tất cả" khoá khi `isPremium` (placeholder paywall, Principle V); item `onTap`→`/wallpaper/{id}`; loading→skeleton khớp bố cục = 1 `ShimmerBox` hero + reuse `WallpaperGridSkeleton` (T020) cho phần grid (FR-027), notFound→"không tìm thấy". Xoá placeholder. Phụ thuộc T039, T017, T020.
- [x] T043 [US3] Wire router: thay `CollectionsPlaceholderPage`→`CollectionsPage` và `CollectionDetailPlaceholderPage`→`CollectionDetailPage` (truyền `id`) trong `app_router.dart`. Phụ thuộc T041, T042.
- [x] T044 [P] [US3] Thêm ARB keys Collections ("Mở khoá", "Tải tất cả", rỗng/lỗi) + gen l10n.
- [x] T045 [P] [US3] `bloc_test` collections + collection_detail (`test/features/collections/...`, `test/features/collection_detail/...`): load thành công/empty/lỗi, detail 404→notFound. Phụ thuộc T037, T039.
- [x] T046 [US3] Widget test `test/features/collection_detail/collection_detail_page_test.dart`: skeleton→loaded hero+grid; premium→nút khoá; chạm item điều hướng. Phụ thuộc T042.

**Checkpoint**: US1–US3 chạy độc lập.

---

## Phase 6: User Story 4 — Tìm kiếm (Priority: P4)

**Goal**: Tab Tìm, debounce live ≥2 ký tự, lưới kết quả (reuse WallpaperGrid), EmptyState khi không khớp.

**Independent Test**: Chưa nhập→gợi ý; 1 ký tự→không gọi; ≥2 ký tự+ngừng ~350ms→tìm 1 lần; khớp→grid; không khớp→EmptyState; chạm→Detail. (SC-006, FR-019..021)

### Implementation

- [x] T047 [P] [US4] Tạo `lib/features/search/presentation/cubit/search_state.dart` (sealed class + Equatable): `initial/loading/loaded({query,items,nextCursor,hasMore,isLoadingMore,loadMoreFailed})/empty(query)/error`.
- [x] T048 [US4] Tạo `lib/features/search/presentation/cubit/search_cubit.dart` (`@injectable`): `queryChanged(text)` debounce `Timer` ~350ms, bỏ qua <2 ký tự (→`initial`), seq-guard (R6); `loadMore()`; kết quả rỗng→`empty`. Phụ thuộc T010, T047.
- [x] T049 [US4] Tạo `lib/features/search/presentation/pages/search_page.dart`: `TextField` (`TopBar`/ô tìm) → `queryChanged`; loading→`WallpaperGridSkeleton`, loaded→`WallpaperGrid` (reuse T022), empty→`EmptyState`, initial→gợi ý; item→`/wallpaper/{id}`. Xoá placeholder. Phụ thuộc T048, T022, T020.
- [x] T050 [US4] Wire router: thay `SearchPlaceholderPage`→`SearchPage` trong `app_router.dart`. Phụ thuộc T049.
- [x] T051 [P] [US4] Thêm ARB keys Search (placeholder ô tìm, gợi ý, "Không tìm thấy kết quả") + gen l10n.
- [x] T052 [P] [US4] `bloc_test` `test/features/search/search_cubit_test.dart` với `fakeAsync`: <2 ký tự không gọi API; debounce chỉ gọi 1 lần; gõ nhanh→chỉ kết quả mới nhất (seq-guard); rỗng→`empty`. Phụ thuộc T048.
- [x] T053 [US4] Widget test `test/features/search/search_page_test.dart`: nhập ≥2 ký tự→skeleton→grid; không khớp→EmptyState. Phụ thuộc T049.

**Checkpoint**: US1–US4 chạy độc lập.

---

## Phase 7: Polish & Cross-Cutting

- [ ] T054 (OPTIONAL, chưa làm) [P] Cập nhật `lib/features/dev_gallery/presentation/pages/dev_gallery_page.dart` trưng thêm `WallpaperTile` (video), skeleton widgets với dữ liệu mẫu (đối chiếu prototype). (tuỳ chọn)
- [~] T055 Video controller lifecycle code + guard (VideoPreview visibility dispose) verified qua code + widget test; profiling ≥100 item với video THẬT ⏸️ cần backend+device thật.
- [~] T056 iPhone 16 Pro Max (Dynamic Island) verified không vỡ layout; iPad đa cột ⏸️ cần chạy device iPad.
- [x] T057 Chạy pre-commit gate (Constitution): `dart format .`, `flutter analyze` (0 warning), `very_good test --test-randomize-ordering-seed random`, `dart run bloc_tools:bloc lint .` (0 vi phạm).
- [~] T058 Nghiệm thu US1 qua Prism mock (grid/chips/card/aura render đúng); backend THẬT + 4 US đầy đủ ⏸️ cần backend chạy.

---

## Dependencies & Execution Order

### Phase Dependencies
- **Setup (P1)**: không phụ thuộc — bắt đầu ngay.
- **Foundational (P2)**: sau Setup — **BLOCKS mọi user story**.
- **User Stories (P3–P6)**: sau Foundational; sau đó chạy song song được (nếu đủ người) hoặc tuần tự P1→P2→P3→P4.
- **Polish (P7)**: sau các story mong muốn.

### User Story Dependencies
- **US1 (P1)**: chỉ cần Foundational. Dựng `WallpaperGrid`/`WallpaperTile`-usage mà US3/US4 reuse.
- **US2 (P2)**: chỉ cần Foundational (WallpaperRepository.getById + VideoPreview). Độc lập test được.
- **US3 (P3)**: cần Foundational (CollectionRepository + WallpaperTile). Reuse `WallpaperTile`; điều hướng tới Detail (US2) qua path constant — không import page US2.
- **US4 (P4)**: cần Foundational; **reuse `WallpaperGrid` (T022) + skeleton (T020) của US1**. Nếu làm US4 trước US1, kéo T020/T022 lên foundational.

### Within Each Story
- State (sealed class) → Cubit → widgets/skeleton → Page → wire router → tests. Model (generated) đã sẵn.

### Parallel Opportunities
- Setup: T003 [P].
- Foundational: T004/T005 [P]; T010/T011/T012 [P] (sau T009); widgets T015/T016 [P], T017 sau T015; test T008/T014 [P].
- Trong 1 story: state + skeleton + ARB + bloc_test đánh [P] (khác file); Page phụ thuộc widgets.
- Khác story: US1/US2/US3/US4 song song sau Foundational.

---

## Parallel Example: Foundational

```bash
# Domain + mapper (khác file):
Task: "T004 Result<T> in lib/core/domain/result.dart"
Task: "T005 AppFailure in lib/core/domain/app_failure.dart"
# Sau T009 (PublicApi module) — 3 repository song song:
Task: "T010 WallpaperRepository"
Task: "T011 TagRepository"
Task: "T012 CollectionRepository"
# Shared widgets song song:
Task: "T015 VideoPreview"
Task: "T016 ShimmerBox"
```

---

## Implementation Strategy

### MVP First (US1)
1. Phase 1 Setup → 2 Foundational (CRITICAL) → 3 US1.
2. **STOP & VALIDATE**: test US1 độc lập (quickstart §US1), profiling controller count.
3. Demo MVP.

### Incremental Delivery
Setup+Foundational → US1 (MVP) → US2 → US3 → US4, mỗi story test độc lập rồi demo. Commit sau mỗi task/nhóm; dừng ở checkpoint nghiệm thu.

### Parallel Team Strategy
Sau Foundational: Dev A→US1, Dev B→US2, Dev C→US3; US4 sau khi US1 có `WallpaperGrid`.

---

## Notes
- [P] = khác file, không phụ thuộc. [US#] = truy vết user story.
- Tests bắt buộc (Principle XIII): unit (repo/mapper), bloc_test (mọi Cubit), widget (grid dispose + shimmer-stops + Detail + Search debounce).
- Video controller lifecycle (Principle II) và shimmer-dừng-theo-state (FR-029) là 2 điểm dễ hồi quy nhất — có guard test riêng (T027, T052).
- Sau mỗi thay đổi DI (thêm @injectable/@LazySingleton): chạy `dart run lean_builder build`. State là sealed class thủ công — KHÔNG codegen.
- Chuỗi tiếng Việt qua `context.l10n`; màu/spacing/typography/icon chỉ từ `lib/core/theme` + Phosphor.
