# Contract — Repository Interfaces (MO-004)

Interface nội bộ của app (Dart). Tất cả trả `Result<T>` khi có thể lỗi (Principle IV). DI: `@LazySingleton(as: ...)`.

## FavoritesRepository (core/favorites)
Nguồn sự thật cho trạng thái yêu thích. In-memory `Set<int>` đồng bộ với `shared_preferences`, phát stream phản ứng.

```dart
abstract interface class FavoritesRepository {
  /// Tập id hiện tại (thứ tự thêm được giữ ở tầng store; getter này trả set).
  Set<int> get currentIds;

  /// Danh sách id theo thứ tự thêm (để hiển thị mới-trước = reversed).
  List<int> get orderedIds;

  /// Stream phát tập id hiện tại ngay khi lắng nghe, rồi mỗi lần đổi.
  Stream<Set<int>> watchIds();

  bool isFavorite(int id);

  /// Thêm/bỏ; cập nhật in-memory + phát stream tức thời, ghi đĩa nền.
  Future<void> toggle(int id);

  /// Xóa vĩnh viễn các id (dùng cho reconcile — FR-010). Không lỗi nếu id vắng.
  Future<void> prune(Set<int> ids);
}
```
- Không trả `Result` cho `toggle`/`prune` (I/O local, best-effort; lỗi ghi đĩa log nội bộ, không chặn UI — Principle XIV).
- `watchIds()` broadcast; Cubit/StreamBuilder đóng subscription khi dispose.

## DownloadHistoryRepository (core/favorites)
```dart
abstract interface class DownloadHistoryRepository {
  /// Ghi/cập nhật 1 mục (id + now), đưa lên đầu; unique theo id (FR-014).
  /// MO-005 gọi khi tải native hoàn tất.
  Future<Result<void>> record(int wallpaperId);

  /// Danh sách mục theo thứ tự mới-tải-trước.
  Future<Result<List<DownloadHistoryEntry>>> read();

  /// Reconcile: xóa các id không còn tồn tại (FR-015).
  Future<void> prune(Set<int> ids);
}
```

## WallpaperRepository.batch (SỬA — core/catalog)
Thêm vào interface `WallpaperRepository` có sẵn:
```dart
/// Lấy tươi nhiều wallpaper theo id qua POST /wallpapers/batch.
/// id không tồn tại bị server bỏ qua âm thầm → client tự đối chiếu.
/// Gọi phải đảm bảo 1..100 id (client chunk trước).
Future<Result<List<Wallpaper>>> batch(List<int> ids);
```
Impl bọc `PublicApi.wallpapersBatchPost(wallpaperBatchRequest: WallpaperBatchRequest(ids: ids))`, map lỗi qua `mapDioError` (giống `list`/`getById`).

## Backend endpoint tái dùng (không mới)
`POST /wallpapers/batch` — body `{ "ids": [<int>] }` (≤100), **200** `Wallpaper[]` (bỏ qua id không thấy), **400** `VALIDATION_ERROR` (rỗng/`>100`), **401** `INVALID_APP_KEY`. Đã có trong `contracts/openapi.yaml` v0.4.0 và client generated. **Không cần regenerate cho MO-004.**
