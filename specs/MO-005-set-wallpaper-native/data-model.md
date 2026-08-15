# Phase 1 — Data Model: Set Wallpaper Native Integration (MO-005)

**Ngày**: 2026-08-09 · **Spec**: [spec.md](spec.md) · **Research**: [research.md](research.md)

MO-005 **không thêm entity phía máy chủ nào** — contract v0.7.1 đã có đủ (`GET /wallpapers/{id}/download-url`). Toàn bộ mô hình dưới đây là dữ liệu cục bộ và dữ liệu đi qua biên giới Dart ↔ native.

**Ánh xạ tên nghiệp vụ (spec) ↔ tên kỹ thuật (ở đây)**:

| Tên trong [spec.md](spec.md) §Key Entities | Hiện thân kỹ thuật |
|---|---|
| File hình nền trên máy | `WallpaperFile` |
| Trạng thái tải | `DownloadProgress` + các state `SetWallpaper*` ở §4 |
| Yêu cầu đặt hình nền | **Không thành class** — tan vào tham số của method channel ở §2 (Principle VIII: dữ liệu qua biên giới là kiểu nguyên thuỷ, không phải model nghiệp vụ) |
| Mục lịch sử tải | `DownloadHistoryEntry` (đã có từ MO-004) |

---

## 1. Entity trong Dart

### `WallpaperFile` (mới — `lib/core/wallpaper/`)

File gốc đã tải về máy.

| Trường | Kiểu | Ghi chú |
|---|---|---|
| `wallpaperId` | `int` | Định danh wallpaper — cũng là tên file |
| `path` | `String` | Đường dẫn tuyệt đối trong thư mục riêng của app |
| `sizeBytes` | `int` | Dùng cho log/nghiệm thu SC-007 |

- Bất biến, `Equatable`.
- Vị trí thật: `<applicationSupportDirectory>/wallpapers/<wallpaperId>.<ext>` — `<ext>` suy từ `content-type` của response hoặc phần path của URL đã strip query, mặc định `mp4`. **Không cứng `.mp4`**: liên kết là presigned và container thật có thể là `.mov`; file gắn sai đuôi làm `PHAsset` trên iOS lỗi khó truy nguyên.
- **Bất biến vòng đời**: sau một lần đặt thành công, thư mục `wallpapers/` giữ **tối đa một** file — file của hình nền đang dùng (FR-015, SC-007).

### `DownloadProgress` (mới — `lib/core/wallpaper/`)

| Trường | Kiểu | Ghi chú |
|---|---|---|
| `receivedBytes` | `int` | |
| `totalBytes` | `int?` | `null` khi máy chủ không trả tổng dung lượng |
| `fraction` | `double?` | Suy ra; `null` khi `totalBytes == null` → UI hiển thị thanh chạy vô định |

### `DownloadHistoryEntry` (**đã có từ MO-004**, không đổi)

`{wallpaperId, downloadedAt}` — duy nhất theo id, mới nhất lên đầu. MO-005 chỉ **thêm điểm ghi thật**, không đổi hình dạng dữ liệu.

---

## 2. DTO qua biên giới Dart ↔ native (Principle VIII)

Chỉ truyền kiểu nguyên thuỷ; **không** đẩy model nghiệp vụ qua channel.

### `com.livecanvas/wallpaper` — `setLiveWallpaper` (Android)

**Gửi đi**:

```
{ "filePath": String, "wallpaperId": int }
```

**Nhận về**: `{ "applied": bool }` — `applied=false` nghĩa là người dùng quay lại từ màn xem trước của hệ thống mà không áp dụng (FR-016: **không phải lỗi**).

### `com.livecanvas/wallpaper` — `saveVideoToPhotos` (iOS)

**Gửi đi**:

```
{ "filePath": String }
```

**Nhận về**: `{ "saved": bool }`

### `com.livecanvas/wallpaper` — `isLiveWallpaperSupported`

Không tham số. Trả `bool` — `false` → `PlatformUnsupportedFailure` (FR-017).

### Mã lỗi native → `AppFailure` (Principle VIII)

Native ném `FlutterError`/`FlutterMethodNotImplemented` với `code` trong bảng dưới; tầng Dart map **duy nhất tại một chỗ**, không để lộ mã này lên UI (FR-029).

| `code` native | `AppFailure` | Sinh ra khi |
|---|---|---|
| `UNSUPPORTED` | `PlatformUnsupportedFailure` | Máy không có màn chọn hình nền động; gọi API Android trên iOS |
| `FILE_MISSING` | `FileWriteFailedFailure` | Đường dẫn truyền sang không tồn tại/không đọc được |
| `PERMISSION_DENIED` | `FileWriteFailedFailure` | Người dùng từ chối quyền thư viện Ảnh (iOS) — UI kèm lối tắt mở Cài đặt (FR-020) |
| `SET_FAILED` | `WallpaperSetFailedFailure` | Hệ thống từ chối/lỗi khi áp dụng hình nền |
| `SAVE_FAILED` | `WallpaperSetFailedFailure` | `PHPhotoLibrary` báo lỗi khi ghi asset |

> `PERMISSION_DENIED` cố ý map về `FileWriteFailedFailure` chứ không tạo biến thể mới: `AppFailure` là tập đóng do hiến pháp liệt kê (Principle IV) và "không ghi được vào nơi cần ghi" đúng là ý nghĩa của nó. Sự khác biệt về **hành động gợi ý** (mở Cài đặt) do UI quyết định theo ngữ cảnh iOS, không cần một loại lỗi riêng.

---

## 3. Dữ liệu phía native (Kotlin sở hữu)

`LiveCanvasWallpaperService` đọc file `SharedPreferences` **riêng của native** (R6) — không dùng chung kho của plugin `shared_preferences`:

- File: `livecanvas_wallpaper_prefs`
- Khoá `active_video_path` → `String` — đường dẫn video đang được dùng làm hình nền.
- Ghi tại thời điểm xử lý `setLiveWallpaper`, **trước** khi bắn intent màn xem trước.
- Đọc trong `onSurfaceCreated` của Engine — đây là đường duy nhất để hình nền sống sót qua reboot khi Flutter engine chưa chạy (FR-013).

---

## 4. State machine của sheet

`SetWallpaperState` — sealed native + Equatable (deviation đã duyệt từ MO-003), tên biến thể mang tiền tố tên gốc theo Principle III:

```
SetWallpaperInitial
  │  bấm nút chính
  ▼
SetWallpaperLoadingDownload(DownloadProgress)
  │                    │ huỷ / đóng sheet          │ lỗi
  │ tải xong           ▼                           ▼
  ▼                SetWallpaperInitial      SetWallpaperError(AppFailure)
SetWallpaperLoadedReady(WallpaperFile)
  │  Android: "Đặt làm hình nền" · iOS: đã lưu xong
  ▼
SetWallpaperLoadedApplied
```

Quy tắc chuyển trạng thái:

- `SetWallpaperError` → bấm thử lại → quay về `SetWallpaperInitial` (**xin liên kết tải mới**, không dùng lại liên kết cũ — FR-005).
- Người dùng huỷ ở màn xem trước Android (`applied=false`): **giữ nguyên** `SetWallpaperLoadedReady` — file đã tải vẫn dùng lại được (FR-016), không rơi vào `Error`.
- Chỉ nhánh đi vào `SetWallpaperLoadedReady` mới ghi lịch sử tải (FR-023, FR-024), và ghi **đúng một lần** ở tầng service (R9).
- Chặn vì premium: `SetWallpaperError(EntitlementRequiredFailure)` — UI hiện thông báo + lối đi Paywall, **không** ghi lịch sử (FR-025, FR-026).

---

## 5. Bất biến cần được test bảo vệ

| # | Bất biến | Nguồn |
|---|---|---|
| INV-1 | Chỉ ghi lịch sử tải khi file đã ghi xong thành công | FR-023, FR-024 |
| INV-2 | Mỗi lần tải xin liên kết mới; không lưu/dùng lại liên kết | FR-005 |
| INV-3 | Tối đa một lần tải chạy tại một thời điểm | FR-009 |
| INV-4 | Huỷ/đóng sheet → dọn file dở dang, không để lại rác | FR-008 |
| INV-5 | Sau khi đặt thành công, thư mục chỉ còn file đang dùng | FR-015, SC-007 |
| INV-6 | Không mã lỗi kỹ thuật nào rò lên UI | FR-029 |
| INV-7 | `applied=false` không phải trạng thái lỗi | FR-016 |
| INV-8 | Android không xin quyền ghi bộ nhớ ngoài | FR-014 |
