# Tasks: Favorites & Local Data (MO-004)

**Input**: Design documents from `specs/MO-004-favorites-local-data/`
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/)

**Tests**: INCLUDED — Principle XIII (hiến pháp) bắt buộc unit/bloc/widget test cho reconcile, mapping, Cubit, luồng chính.

**Organization**: Theo user story (US1–US4) để implement & test độc lập. Nhãn `[P]` = chạy song song được (khác file, không phụ thuộc task chưa xong).

## Path Conventions
Flutter feature-first: `lib/core/…`, `lib/features/…`, test ở `test/…` (gương cấu trúc lib). State = native sealed class + Equatable (deviation đã duyệt, xem plan §Complexity).

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Thêm dependency + khung thư mục kho cục bộ.

- [X] T001 Xác nhận `shared_preferences` latest stable trên pub.dev (Principle XVI), thêm `shared_preferences: ^2.5.5` vào [pubspec.yaml](../../pubspec.yaml); chạy `flutter pub get`; commit `pubspec.lock` + `ios/Podfile.lock`.
- [X] T002 Tạo thư mục `lib/core/favorites/` và `lib/core/favorites/local_data_module.dart` (`@module` cung cấp `SharedPreferencesAsync` cho DI); chạy `dart run lean_builder build` để regen DI.

**Checkpoint**: dep + DI module sẵn sàng.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Kho dùng chung + batch + wiring widget mà MỌI user story cần. ⚠️ Phải xong trước US1–US4.

- [X] T003 [P] Tạo `FavoritesStore` trong [lib/core/favorites/favorites_store.dart](../../lib/core/favorites/favorites_store.dart): đọc/ghi `List<String>` id (key `favorites.ids.v1`, giữ thứ tự thêm), `prune`, parse an toàn — theo [contracts/local-storage.md](contracts/local-storage.md).
- [X] T004 Tạo `FavoritesRepository` interface + `FavoritesRepositoryImpl` (`@LazySingleton(as:)`) trong [lib/core/favorites/favorites_repository.dart](../../lib/core/favorites/favorites_repository.dart): giữ `Set<int>` in-memory nạp từ store, `watchIds()` broadcast (phát giá trị hiện tại khi lắng nghe), `currentIds`/`orderedIds`, `isFavorite`, `toggle` (optimistic: cập nhật+phát stream ngay, ghi đĩa nền), `prune` — theo [contracts/repositories.md](contracts/repositories.md). Phụ thuộc T003.
- [X] T005 [P] Thêm `batch(List<int>)` vào interface + impl `WallpaperRepository` trong [lib/core/catalog/wallpaper_repository.dart](../../lib/core/catalog/wallpaper_repository.dart): bọc `PublicApi.wallpapersBatchPost(WallpaperBatchRequest(ids:...))`, trả `Result<List<Wallpaper>>`, map lỗi qua `mapDioError`.
- [X] T006 [P] Thêm khóa i18n vào [lib/l10n/arb/app_vi.arb](../../lib/l10n/arb/app_vi.arb) + `app_en.arb` (title "Yêu thích"/"Lịch sử tải", empty state heart + CTA "Khám phá hình nền", empty history, lỗi tải favorites) kèm `@description`; regen `lib/l10n/gen`.
- [X] T007 Sửa [lib/core/widgets/wallpaper/wallpaper_tile.dart](../../lib/core/widgets/wallpaper/wallpaper_tile.dart): thêm tham số `isFav`/`onFav` và forward xuống `WallpaperCard` (giữ tương thích: mặc định `isFav=false`, `onFav=null`).
- [X] T008 Regen DI (`dart run lean_builder build`) sau khi thêm `@LazySingleton` mới (T004, T005). Xác minh `injection.config.dart` có `FavoritesRepository`.
- [X] T009 [P] Unit test `FavoritesStore` trong [test/core/favorites/favorites_store_test.dart](../../test/core/favorites/favorites_store_test.dart): read/write/prune, giữ thứ tự, bỏ qua phần tử hỏng (mock `SharedPreferencesAsync`).
- [X] T010 [P] Unit test `FavoritesRepository` trong [test/core/favorites/favorites_repository_test.dart](../../test/core/favorites/favorites_repository_test.dart): `toggle` add/remove, `watchIds` phát tức thời + khi đổi, `isFavorite`, `prune`, double-toggle → trạng thái cuối đúng.
- [X] T011 [P] Unit test `WallpaperRepository.batch` trong [test/core/catalog/wallpaper_repository_batch_test.dart](../../test/core/catalog/wallpaper_repository_batch_test.dart): Ok mapping, Err (dio) → AppFailure, empty body.

**Checkpoint**: kho favorite + batch + tile forwarding sẵn sàng — bắt đầu US song song được.

---

## Phase 3: User Story 1 — Toggle & bền vững (Priority: P1) 🎯 MVP

**Goal**: Toggle tim ở mọi lưới + màn Detail, nhất quán xuyên màn (FR-004), bền vững qua restart (SC-001), phản hồi <100ms + haptic.

**Independent Test**: Chạm tim trên tile Khám phá và trên Detail → nhất quán xuyên màn; tắt/mở app → giữ nguyên.

- [X] T012 [P] [US1] Tạo `FavoritableWallpaperTile` trong [lib/core/widgets/wallpaper/favoritable_wallpaper_tile.dart](../../lib/core/widgets/wallpaper/favoritable_wallpaper_tile.dart): bọc `WallpaperTile`, bám `FavoritesRepository` theo 1 id với **rebuild hẹp** — `StreamBuilder` trên `watchIds().map((s) => s.contains(id)).distinct()` (chỉ rebuild khi trạng thái tim CỦA id ĐÓ đổi, tránh rebuild toàn lưới, addresses P1); `onFav` gọi `toggle(id)` + `HapticFeedback.selectionClick()` (Principle VII).
- [X] T013 [US1] Wiring lưới Browse [lib/features/browse/presentation/widgets/wallpaper_grid.dart](../../lib/features/browse/presentation/widgets/wallpaper_grid.dart) dùng `FavoritableWallpaperTile` (thay `WallpaperTile` trần).
- [X] T014 [US1] Wiring lưới Collection Detail [lib/features/collection_detail/presentation/pages/collection_detail_page.dart](../../lib/features/collection_detail/presentation/pages/collection_detail_page.dart) dùng `FavoritableWallpaperTile`.
- [X] T015 [US1] Thêm nút yêu thích ở [lib/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart](../../lib/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart): bind `FavoritesRepository` (StreamBuilder/isFavorite) + `toggle` + haptic.
- [X] T016 [P] [US1] Widget test toggle trong [test/features/favorites/favorite_toggle_test.dart](../../test/features/favorites/favorite_toggle_test.dart): chạm tim trên tile → `toggle` gọi, icon đổi; 2 tile cùng id phản chiếu nhau qua stream (nhất quán FR-004).

**Checkpoint**: US1 độc lập chạy được — favorite bền vững + đồng bộ.

---

## Phase 4: User Story 2 — Màn Favorites data tươi (Priority: P2)

**Goal**: Tab "Yêu thích" hiển thị lưới data mới nhất qua batch, empty state, error retry, chunk ≤100 (SC-005).

**Independent Test**: Favorite vài mục → mở tab Yêu thích thấy đúng data hiện hành; rỗng → empty; mất mạng → FailureView, id không mất.

- [X] T017 [P] [US2] Tạo `FavoritesState` (sealed 4-state, Equatable) trong [lib/features/favorites/presentation/cubit/favorites_state.dart](../../lib/features/favorites/presentation/cubit/favorites_state.dart): Initial/Loading/Loaded(items)/Error(failure) — theo [data-model.md](data-model.md).
- [X] T018 [US2] Tạo `FavoritesCubit` (`@injectable`) trong [lib/features/favorites/presentation/cubit/favorites_cubit.dart](../../lib/features/favorites/presentation/cubit/favorites_cubit.dart): `load()` chunk `orderedIds` thành lô ≤100 → gọi `WallpaperRepository.batch` **tuần tự từng lô** (đơn giản, xác định được cho test; đủ cho ≤ vài trăm id — chốt U1) → gộp giữ thứ tự (đảo mới-trước); id rỗng → Loaded([]); bất kỳ lô Err → Error; lắng nghe `watchIds()` để gỡ mục khi bỏ tim tại chỗ. Đóng subscription khi close.
- [X] T019 [US2] Tạo `FavoritesPage` trong [lib/features/favorites/presentation/pages/favorites_page.dart](../../lib/features/favorites/presentation/pages/favorites_page.dart) (BlocProvider `FavoritesCubit` từ getIt): `TopBar` "Yêu thích" + số đếm, lưới 2 cột `FavoritableWallpaperTile` tap→Detail, skeleton khi Loading, `EmptyState` heart + CTA, `FailureView` retry — bám [Favorites.jsx](../../.claude/livecanvas-detail-screens/project/livecanvas/Favorites.jsx).
- [X] T020 [US2] Nối `FavoritesPage` vào tab "Yêu thích": thay `FavoritesPlaceholderPage` trong composition-root router [lib/app/router/](../../lib/app/router/) (giữ `AppRoutes`), xóa [lib/features/favorites/presentation/pages/favorites_placeholder_page.dart](../../lib/features/favorites/presentation/pages/favorites_placeholder_page.dart).
- [X] T021 [P] [US2] bloc_test `FavoritesCubit` trong [test/features/favorites/favorites_cubit_test.dart](../../test/features/favorites/favorites_cubit_test.dart): Initial→Loading→Loaded; rỗng→Loaded([]); batch Err→Error; chunk 250 id → 3 lô; bỏ tim qua stream → item bị gỡ khỏi Loaded.
- [X] T022 [P] [US2] Widget test `FavoritesPage` trong [test/features/favorites/favorites_page_test.dart](../../test/features/favorites/favorites_page_test.dart): loaded grid, empty state (CTA), error FailureView.

**Checkpoint**: US2 độc lập — mở tab Yêu thích xem data tươi.

---

## Phase 5: User Story 3 — Tự dọn wallpaper không còn tồn tại (Priority: P2)

**Goal**: ID bị admin xóa/unpublish tự bị **prune vĩnh viễn** khi batch thành công (FR-010); KHÔNG prune khi lỗi (FR-011); 0 ô hỏng (SC-003).

**Depends on**: US2 (T018) — US3 bổ sung reconcile vào chính `FavoritesCubit` của US2. Không độc lập với US2; test độc lập của US3 giả định US2 đã xong (addresses I1).

**Independent Test**: (sau khi US2 xong) Favorite 3 mục, 1 mục không còn được batch trả → mở Yêu thích chỉ 2 mục, id mất bị xóa store (lần sau không thử lấy lại).

- [X] T023 [US3] Bổ sung reconcile vào `FavoritesCubit.load()` ([lib/features/favorites/presentation/cubit/favorites_cubit.dart](../../lib/features/favorites/presentation/cubit/favorites_cubit.dart)): sau khi MỌI lô batch thành công, `missing = requestedIds - returnedIds` → `FavoritesRepository.prune(missing)`; đảm bảo nhánh Err KHÔNG prune.
- [X] T024 [P] [US3] bloc_test/unit reconcile trong [test/features/favorites/favorites_reconcile_test.dart](../../test/features/favorites/favorites_reconcile_test.dart): id thiếu trong response → `prune` được gọi đúng tập; batch Err → `prune` KHÔNG gọi; tất cả mất → Loaded([]).

**Checkpoint**: US3 độc lập — danh sách favorite tự sạch.

---

## Phase 6: User Story 4 — Lịch sử tải cục bộ (Priority: P3)

**Goal**: Kho lịch sử tải (API ghi/đọc) + màn xem tối giản (mới-tải-trước, unique theo id — FR-014, reconcile — FR-015). Điểm ghi do MO-005 nối; MO-004 test bằng seed.

**Independent Test**: Seed vài `record(id)` → màn Lịch sử tải hiển thị mới-trước, mỗi wallpaper 1 mục, tap→Detail; `record` trùng id → đưa lên đầu.

- [X] T025 [P] [US4] Tạo model `DownloadHistoryEntry` (Equatable, `{wallpaperId, downloadedAt}`) trong [lib/core/favorites/download_history_entry.dart](../../lib/core/favorites/download_history_entry.dart).
- [X] T026 [P] [US4] Tạo `DownloadHistoryStore` trong [lib/core/favorites/download_history_store.dart](../../lib/core/favorites/download_history_store.dart): key `download_history.entries.v1`, mỗi phần tử JSON `{"id","at"}`, insert-front + dedup theo id, `prune`, parse an toàn — theo [contracts/local-storage.md](contracts/local-storage.md).
- [X] T027 [US4] Tạo `DownloadHistoryRepository` interface + impl (`@LazySingleton(as:)`) trong [lib/core/favorites/download_history_repository.dart](../../lib/core/favorites/download_history_repository.dart): `record(id)→Result<void>`, `read()→Result<List<DownloadHistoryEntry>>` (mới-trước), `prune(ids)`. Phụ thuộc T025, T026. Regen DI.
- [X] T028 [P] [US4] Tạo `DownloadHistoryState` (sealed 4-state) trong [lib/features/download_history/presentation/cubit/download_history_state.dart](../../lib/features/download_history/presentation/cubit/download_history_state.dart).
- [X] T029 [US4] Tạo `DownloadHistoryCubit` (`@injectable`) trong [lib/features/download_history/presentation/cubit/download_history_cubit.dart](../../lib/features/download_history/presentation/cubit/download_history_cubit.dart): `load()` đọc entries → id → chunk batch (tái dùng `WallpaperRepository.batch`) → reconcile prune (FR-015) → Loaded theo thứ tự entry.
- [X] T030 [US4] Tạo màn tối giản `DownloadHistoryPage` trong [lib/features/download_history/presentation/pages/download_history_page.dart](../../lib/features/download_history/presentation/pages/download_history_page.dart): tái dùng `TopBar` "Lịch sử tải" + lưới `WallpaperTile` (tap→Detail) + `EmptyState` + `FailureView` (chưa có design riêng — plan §Complexity).
- [X] T031 [US4] Thêm `AppRoutes.downloadHistory` trong [lib/core/router/app_routes.dart](../../lib/core/router/app_routes.dart) + entry go_router (pushed, phủ shell) ở [lib/app/router/](../../lib/app/router/); thêm mục "Lịch sử tải" vào tab "Bạn" [lib/features/profile/presentation/pages/profile_placeholder_page.dart](../../lib/features/profile/presentation/pages/profile_placeholder_page.dart) điều hướng `context.push` (Principle X).
- [X] T032 [P] [US4] Unit test `DownloadHistoryStore`/`Repository` trong [test/core/favorites/download_history_test.dart](../../test/core/favorites/download_history_test.dart): insert-front, dedup theo id (record trùng → 1 mục lên đầu), thứ tự mới-trước, prune.
- [X] T033 [P] [US4] bloc_test `DownloadHistoryCubit` trong [test/features/download_history/download_history_cubit_test.dart](../../test/features/download_history/download_history_cubit_test.dart): loaded theo thứ tự, empty, error, reconcile prune.

**Checkpoint**: US4 độc lập (test qua seed) — kho + màn history.

---

## Phase 7: Polish & Cross-Cutting

- [X] T034 [P] Cập nhật [quickstart.md](quickstart.md) nếu path/route lệch thực tế khi implement.
- [X] T035 Chạy Pre-Commit Checklist hiến pháp: `dart format .` · `flutter analyze` (0 warning) · `very_good test --test-randomize-ordering-seed random` · `dart run bloc_tools:bloc lint .` (0 vi phạm).
- [ ] T036 Nghiệm thu iOS simulator + (nếu có) Android máy thật theo [quickstart.md](quickstart.md) US1–US4; **kiểm chứng thủ công SC-002 (toggle <100ms)** (không có test tự động cho ngưỡng này — chốt C1), không giật lưới, reconcile sạch.
- [X] T037 Cập nhật `.claude/changelog.md` (mục MO-004 ở `[Unreleased]`) + `project-context.md`/`sdd-roadmap.md` status khi chuẩn bị PR.

---

## Dependencies & Story Completion Order

```
Setup (T001–T002)
   ▼
Foundational (T003–T011)   ← BLOCKING mọi US
   ▼
US1 (T012–T016)  ── MVP, P1
   ▼ (FavoritesRepository sẵn)
US2 (T017–T022)  ── P2 (cần T004 batch/repo)
   ▼
US3 (T023–T024)  ── P2 (bổ sung reconcile vào FavoritesCubit của US2)
   
US4 (T025–T033)  ── P3, độc lập US1–US3 (chỉ cần Foundational: batch + DI)
   ▼
Polish (T034–T037)
```

- **US1 → US2 → US3**: US3 sửa cùng `FavoritesCubit` của US2 nên nối tiếp US2. US1 độc lập US2/US3 (chỉ dùng repository).
- **US4** chỉ phụ thuộc Foundational (batch + store pattern), chạy **song song** US1–US3 nếu muốn.

## Parallel Opportunities

- **Foundational**: T003, T005, T006 song song (khác file); T009/T010/T011 (test) song song sau khi impl xong.
- **US1**: T012 [P] rồi T013/T014/T015 (mỗi file khác nhau, có thể song song sau T012); T016 test song song.
- **US2**: T017 [P] song song với chuẩn bị; T021/T022 test song song.
- **US4**: T025/T026 [P] song song; T032/T033 test song song. Cả cụm US4 có thể chạy song song với US1–US3.

## Implementation Strategy

- **MVP = US1** (P1): favorite bền vững + đồng bộ xuyên màn — đã đủ giá trị cốt lõi, giao được ngay sau Foundational.
- **Increment 2 = US2 + US3** (P2): màn Yêu thích data tươi + tự dọn.
- **Increment 3 = US4** (P3): lịch sử tải (kho + màn tối giản; điểm ghi hoàn thiện ở MO-005).

## Notes
- State: native sealed class + Equatable (KHÔNG `@freezed`) — deviation đã duyệt (plan §Complexity).
- Không regenerate `packages/livecanvas_api` cho MO-004 (batch có sẵn). Regenerate v0.4.0 là việc riêng, không chặn.
- Màn Download History tối giản, chưa có design handoff — chờ xác nhận/thiết kế (có thể thay ở MO-005).
