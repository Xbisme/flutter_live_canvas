# Contract — Repository & Service (MO-005)

Mọi hàm có thể hỏng đều trả `Result<T>` (Principle IV). Không có `try/catch` trong Cubit — repository bắt và bọc.

Vị trí: `lib/core/wallpaper/` (giống `core/catalog/` của MO-003 và `core/favorites/` của MO-004 — dùng chung nhiều feature, và `core/` không được import `features/` theo Principle XI).

---

## `WallpaperDownloadRepository`

Tải file gốc về vùng riêng của app, có tiến trình và huỷ được.

```dart
abstract interface class WallpaperDownloadRepository {
  /// Xin liên kết tải MỚI rồi tải file về thư mục riêng của app.
  ///
  /// [onProgress] phát tiến trình cho UI (FR-007).
  /// [cancelToken] để huỷ khi người dùng bấm huỷ hoặc đóng sheet (FR-008).
  ///
  /// Liên kết KHÔNG được lưu lại hay dùng lại giữa các lần gọi (FR-005, INV-2).
  Future<Result<WallpaperFile>> download(
    int wallpaperId, {
    void Function(DownloadProgress) onProgress,
    CancelToken? cancelToken,
  });

  /// Xoá mọi file gốc trừ [keepWallpaperId] (FR-015, INV-5).
  Future<Result<void>> pruneExcept(int keepWallpaperId);

  /// Xoá file dở dang của một lần tải bị huỷ/lỗi (INV-4).
  Future<Result<void>> discardPartial(int wallpaperId);
}
```

**Ràng buộc thực thi**:

- Dùng **một instance `Dio` riêng, không interceptor** — không gửi `X-App-Key` sang host lưu trữ bên thứ ba ([research.md](../research.md) R2).
- Không đọc, không so sánh, không hardcode tên miền của liên kết trả về (FR-006).
- `402` từ `download-url` → `Err(EntitlementRequiredFailure())`; `404` → `Err(NotFoundFailure())`; còn lại đi qua `dio_error_mapper` sẵn có.
- Ghi ra file tạm rồi mới đổi tên thành file đích, để một lần tải hỏng không để lại file cụt trông như file hợp lệ.

---

## `WallpaperPlatformService`

Bọc method channel; **đây là nơi duy nhất** mã lỗi native biến thành `AppFailure` (Principle VIII).

```dart
abstract interface class WallpaperPlatformService {
  /// true nếu máy có thể đặt hình nền động (Android có màn chọn; iOS luôn false).
  Future<bool> isLiveWallpaperSupported();

  /// Android: mở màn xem trước của hệ thống.
  /// Ok(true)  = người dùng đã áp dụng.
  /// Ok(false) = người dùng quay lại, KHÔNG phải lỗi (FR-016, INV-7).
  Future<Result<bool>> setLiveWallpaper(WallpaperFile file);

  /// iOS: xin quyền add-only rồi lưu video gốc vào thư viện Ảnh.
  Future<Result<bool>> saveVideoToPhotos(WallpaperFile file);
}
```

---

## `SetWallpaperUseCase`

Điều phối tải → ghi lịch sử → đặt/lưu. Tồn tại vì **Principle XI cấm repository gọi repository**: `WallpaperDownloadRepository` và `DownloadHistoryRepository` (đã có từ MO-004) là hai kho ngang hàng ở `core/`, nên phải có một tầng đứng trên điều phối chứ không cho kho này gọi kho kia ([research.md](../research.md) R9).

```dart
abstract interface class SetWallpaperUseCase {
  /// Tải file gốc; ghi lịch sử tải ĐÚNG MỘT LẦN khi và chỉ khi ghi file
  /// thành công (FR-023, FR-024, INV-1).
  Future<Result<WallpaperFile>> prepare(
    int wallpaperId, {
    void Function(DownloadProgress) onProgress,
    CancelToken? cancelToken,
  });

  /// Đặt hình nền (Android) rồi dọn các file gốc không còn dùng (FR-015).
  Future<Result<bool>> apply(WallpaperFile file);

  /// Lưu vào thư viện Ảnh (iOS) rồi xoá file trung gian.
  Future<Result<bool>> saveToPhotos(WallpaperFile file);
}
```

**Ràng buộc thực thi**:

- Ghi lịch sử nằm trong `prepare`, **sau** khi `download` trả `Ok` — nhánh huỷ, lỗi mạng, và `402` do đó tự động không ghi, không cần rải điều kiện ở nhiều nơi.
- `DownloadHistoryRepository.record` hỏng **không** được làm hỏng cả lượt tải: lịch sử là tiện ích phụ, người dùng vẫn phải đặt được hình nền. Ghi log nội bộ và trả `Ok` của lượt tải.
- `apply` chỉ gọi `pruneExcept` khi native trả `applied = true` — người dùng huỷ ở màn xem trước thì file phải còn nguyên để thử lại (FR-016).

---

## Tái dùng từ spec trước (không sửa hình dạng)

| Thành phần | Nguồn | MO-005 dùng để |
|---|---|---|
| `DownloadHistoryRepository.record(int)` | MO-004, `lib/core/favorites/` | Nối **điểm ghi thật** — MO-004 mới test bằng dữ liệu seed |
| `WallpaperRepository` | MO-003, `lib/core/catalog/` | Không đụng tới; `download-url` là lời gọi mới của MO-005 |
| `AppFailure` (`DownloadFailedFailure`, `FileWriteFailedFailure`, `WallpaperSetFailedFailure`, `PlatformUnsupportedFailure`) | MO-003, `lib/core/domain/app_failure.dart` | **Đã khai báo sẵn, chưa từng dùng** — MO-005 là spec đầu tiên sinh ra chúng |
| `failure_l10n.dart` | MO-003, `lib/core/error/` | Hiện đang gộp 4 biến thể trên vào `failureUnknown` qua nhánh `_` — MO-005 **phải thêm nhánh riêng** + chuỗi ARB (FR-028, FR-030) |
