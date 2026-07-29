# Phase 0 Research — Favorites & Local Data (MO-004)

Mọi "NEEDS CLARIFICATION" từ Technical Context được giải ở đây.

## R1 — Cơ chế persistence cục bộ

- **Decision**: Dùng **`shared_preferences` ^2.5.5** (flutter.dev, verified publisher; iOS 13+/Android SDK 24+), qua API hiện đại **`SharedPreferencesAsync`**. Lưu:
  - Favorites: 1 key `List<String>` (id dạng chuỗi) giữ **thứ tự thêm** (mới thêm → cuối; hiển thị đảo mới-trước).
  - Download history: 1 key `List<String>` mỗi phần tử là JSON `{"id":123,"at":"<ISO8601>"}`.
- **Rationale**: Principle IX chỉ yêu cầu lưu **ID/timestamp không nhạy cảm**; Principle XIV (YAGNI) ưu tiên thư viện chuẩn khi đủ dùng. Số lượng favorites/history do người dùng bound (hàng trăm) → key-value quá đủ, không cần truy vấn quan hệ. `shared_preferences` là first-party, ổn định, không kéo native pod phức tạp.
- **Alternatives**:
  - `Hive`/`Isar`: mạnh hơn nhưng thừa cho tập ID nhỏ; thêm codegen/native surface (nghịch XIV, XVI).
  - `flutter_secure_storage`: chỉ cần cho `transaction_id` (MO-006); favorites/history không nhạy cảm nên không dùng (Principle IX nói rõ chỉ transaction_id mới cần secure store).
- **Ghi chú XVI**: version 2.5.5 tra tại pub.dev thời điểm plan (2026-07-26); xác nhận lại latest stable ngay trước khi thêm vào `pubspec.yaml`, commit `pubspec.lock` + `ios/Podfile.lock`.

## R2 — Đồng bộ trạng thái tim xuyên nhiều màn (FR-004)

- **Decision**: `FavoritesRepository` (lazySingleton, core) giữ nguồn sự thật `Set<int>` trong bộ nhớ (nạp 1 lần từ store) và phát **`Stream<Set<int>> watchIds()`** (broadcast, phát giá trị hiện tại ngay khi lắng nghe). Mọi màn có nút tim (Browse grid, Collection Detail grid, Favorites grid, Wallpaper Detail) đọc trạng thái từ stream này và gọi `toggle(id)` để đổi. Ghi xuống `shared_preferences` là hệ quả của `toggle`.
- **Rationale**: Principle III cấm cubit-to-cubit; giao tiếp chia sẻ phải qua repository/stream. Một nguồn sự thật + stream cho phép cập nhật **optimistic tức thời (<100 ms, SC-002)**: `toggle` cập nhật set in-memory + phát stream ngay, I/O đĩa chạy bất đồng bộ nền.
- **Alternatives**:
  - Truyền favorite set xuống qua tham số từ mỗi cubit màn: rò rỉ trạng thái chéo, khó nhất quán khi toggle ở màn A phải phản chiếu màn B đang mở (nghịch FR-004).
  - `ValueNotifier` toàn cục: tương đương stream nhưng khó test/inject bằng getIt gọn như repository.
- **Wiring gọn**: cân nhắc widget core `FavoritableWallpaperTile` bọc `WallpaperTile`, tự `StreamBuilder` theo 1 id → tránh lặp wiring ở 3 lưới. `WallpaperCard` đã sẵn `isFav`/`onFav`; chỉ cần `WallpaperTile` forward.

## R3 — Reconcile + chunk batch (FR-009, FR-010, FR-011)

- **Decision**:
  - **Chunk**: `FavoritesCubit` chia danh sách id thành lô ≤100, gọi `WallpaperRepository.batch(ids)` cho từng lô (tuần tự hoặc song song có bound), gộp giữ **đúng thứ tự id local**.
  - **Reconcile**: sau khi **mọi lô trả về thành công**, tính `missing = localIds - returnedIds`; gọi `FavoritesRepository.prune(missing)` để xóa vĩnh viễn khỏi store; hiển thị chỉ id còn lại.
  - **Không drop khi lỗi**: nếu bất kỳ lô nào trả `Err` (mạng/timeout/server) → cubit vào `error` (giữ nguyên id local, không prune) — Favorites screen hiện `FailureView` retry.
- **Rationale**: Batch bỏ qua âm thầm id không tồn tại (api-context: "id không tìm thấy bị bỏ qua âm thầm"); client suy ra "đã xóa" bằng phép trừ tập — chỉ hợp lệ khi request **thành công** (FR-011). Chunk vì server giới hạn 100 id/lần (VALIDATION_ERROR nếu >100).
- **Alternatives**: reconcile theo từng lô ngay khi lô về — phức tạp và có thể prune nhầm nếu 1 lô sau đó fail; chọn reconcile sau khi tất cả lô thành công cho an toàn.
- **Edge**: double-tap tim → `toggle` idempotent theo trạng thái cuối (set add/remove), phát stream trạng thái cuối; ghi đĩa debounce/last-write-wins.

## R4 — Vị trí kho favorites/history: core hay feature?

- **Decision**: Đặt `FavoritesRepository`, `DownloadHistoryRepository` (+ store, model) trong **`lib/core/favorites/`** (song song `lib/core/catalog/`). Feature `favorites` và `download_history` chỉ chứa `presentation/` (cubit + page).
- **Rationale**: Principle XI: `core/` không import `features/`; feature A không import feature B. Nút tim xuất hiện ở Browse, Collection Detail, Wallpaper Detail (các feature khác nhau) → nguồn favorite phải nằm ở `core/` để mọi feature dùng chung mà không tạo phụ thuộc chéo. Đây đúng khuôn mẫu MO-003 đã lập với `core/catalog/`.
- **Alternatives**: để trong `features/favorites/domain` rồi cho Browse/Collection import → vi phạm cấm feature→feature. Loại.

## R5 — Phạm vi & vị trí màn Download History (US4)

- **Decision** (theo Clarifications 2026-07-26): MO-004 dựng **`DownloadHistoryRepository` + store đầy đủ** và **màn xem tối giản** `DownloadHistoryPage` tái dùng `TopBar` + grid `WallpaperTile` + `EmptyState` + `FailureView` (không thiết kế riêng vì design handoff thiếu màn này). **Điểm ghi** (`record(id)`) do **MO-005** gọi khi tải/đặt native hoàn tất; MO-004 không thêm nút tải. Kho test bằng seed.
- **Vị trí**: pushed page từ tab **"Bạn"** (`profile_placeholder_page` thêm mục "Lịch sử tải") qua `AppRoutes.downloadHistory` + `context.push` (Principle X).
- **Rationale**: Giữ roadmap (MO-004 sở hữu "lịch sử tải local") nhưng không phát minh UI ngoài design; màn tối giản đủ nghiệm thu US4 và dễ thay khi có thiết kế.
- **Cần user xác nhận**: chấp nhận màn tối giản tạm thời, hay chỉ build **kho** ở MO-004 và dời **màn** sang MO-005 (nơi có thiết kế luồng tải/set). Mặc định plan: build cả kho + màn tối giản.

## Ràng buộc kế thừa (không nghiên cứu lại — đã có từ MO-003)

- `Result<T>` / `AppFailure` sealed + `dio_error_mapper` + `failure_l10n` (Principle IV) — tái dùng.
- `WallpaperTile` / `VideoPreview` (bounded controller, hover/hold) / `ShimmerBox` skeleton / `FailureView` / `EmptyState` / `WallpaperCard` (đã có nút tim) — tái dùng.
- Client generated `PublicApi.wallpapersBatchPost` + `WallpaperBatchRequest` — có sẵn (v0.3.2), không cần regenerate cho MO-004.
- State: native sealed class + Equatable (deviation đã duyệt).
