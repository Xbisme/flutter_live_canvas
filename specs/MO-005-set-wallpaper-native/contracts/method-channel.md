# Contract — Method Channel `com.livecanvas/wallpaper` (MO-005)

Tuân thủ Principle VIII: một channel theo miền, tên channel + tên method **tập trung ở `lib/core/constants/channel_methods.dart`** (thư mục này hiện **chưa tồn tại** — MO-005 tạo mới), DTO qua biên giới chỉ dùng kiểu nguyên thuỷ, lỗi native map về `AppFailure` trước khi chạm UI.

```dart
// lib/core/constants/channel_methods.dart
abstract final class WallpaperChannel {
  static const name = 'com.livecanvas/wallpaper';

  static const setLiveWallpaper = 'setLiveWallpaper';
  static const saveVideoToPhotos = 'saveVideoToPhotos';
  static const isLiveWallpaperSupported = 'isLiveWallpaperSupported';
}
```

---

## `setLiveWallpaper` — chỉ Android

Ghi đường dẫn video vào kho prefs của native rồi mở màn xem trước hình nền động của hệ thống.

| | |
|---|---|
| **Tham số** | `{ "filePath": String, "wallpaperId": int }` |
| **Trả về** | `{ "applied": bool }` |
| **Trên iOS** | ném `UNSUPPORTED` |

- `applied = true` — người dùng đã xác nhận ở màn xem trước, hình nền đang chạy.
- `applied = false` — người dùng quay lại mà không áp dụng. **Không phải lỗi** (FR-016).
- Native **phải** ghi `active_video_path` **trước** khi bắn intent — nếu người dùng xác nhận rồi khởi động lại máy ngay, service vẫn có đường dẫn để đọc.
- `ComponentName` dựng từ context lúc chạy, **không hardcode** chuỗi package (flavor `development` có hậu tố `.dev` — xem [research.md](../research.md) R5).

**Lỗi**: `UNSUPPORTED`, `FILE_MISSING`, `SET_FAILED`.

---

## `saveVideoToPhotos` — chỉ iOS/iPadOS

Xin quyền **add-only** rồi ghi video vào thư viện Ảnh.

| | |
|---|---|
| **Tham số** | `{ "filePath": String }` |
| **Trả về** | `{ "saved": bool }` |
| **Trên Android** | ném `UNSUPPORTED` |

- Quyền: `PHPhotoLibrary.requestAuthorization(for: .addOnly)`. Cần khoá **`NSPhotoLibraryAddUsageDescription`** trong `ios/Runner/Info.plist` (chưa có — MO-005 thêm). **Không** xin `NSPhotoLibraryUsageDescription` (quyền đọc toàn bộ thư viện) vì app không đọc gì cả.
- Lưu **video gốc nguyên trạng**, không chuyển đổi sang Live Photo (Q1/A — FR-019).

**Lỗi**: `UNSUPPORTED`, `FILE_MISSING`, `PERMISSION_DENIED`, `SAVE_FAILED`.

---

## `openShortcuts` — chỉ iOS/iPadOS

Mở app Phím tắt của hệ thống.

| | |
|---|---|
| **Tham số** | không |
| **Trả về** | `{ "opened": bool }` |
| **Trên Android** | ném `UNSUPPORTED` |

- `opened = false` khi máy không có app Phím tắt — **không phải lỗi**, UI chỉ đổi câu chữ (FR-022).
- ⚠️ Cần khai **`LSApplicationQueriesSchemes` = ["shortcuts"]** trong `Info.plist`; thiếu nó thì `canOpenURL("shortcuts://")` **luôn trả false** và nút sẽ báo "không có app Phím tắt" trên mọi máy — đây là bản iOS của bẫy `<queries>` bên Android.
- Xử lý ở channel của chính app thay vì thêm `url_launcher` cho đúng một scheme (Principle XIV).

---

## `isLiveWallpaperSupported`

| | |
|---|---|
| **Tham số** | không |
| **Trả về** | `bool` |

- Android: kiểm tra có activity nào xử lý được `ACTION_CHANGE_LIVE_WALLPAPER` không.
- iOS: luôn `false`.

⚠️ **Đây là câu hỏi về NĂNG LỰC, không phải về nền tảng.** Tầng Dart **KHÔNG** được dùng kết quả này để chọn nhánh giao diện Android/iOS — máy Android thiếu màn chọn hình nền động cũng trả `false`, và nếu gộp hai thứ lại thì người dùng Android đó sẽ thấy hướng dẫn Shortcuts của iOS, còn thông báo "thiết bị không hỗ trợ" (FR-017) **không bao giờ hiển thị được**. Chọn nhánh giao diện bằng `defaultTargetPlatform` (test override được qua `debugDefaultTargetPlatformOverride` — vẫn đạt mục tiêu testability của [research.md](../research.md) R8); dùng `isLiveWallpaperSupported` **chỉ** để bắn `PlatformUnsupportedFailure`.

---

## Khai báo native bắt buộc

### Android — `android/app/src/main/AndroidManifest.xml`

```xml
<service
    android:name=".LiveCanvasWallpaperService"
    android:exported="true"
    android:permission="android.permission.BIND_WALLPAPER"
    android:label="@string/wallpaper_label">
  <intent-filter>
    <action android:name="android.service.wallpaper.WallpaperService" />
  </intent-filter>
  <meta-data
      android:name="android.service.wallpaper"
      android:resource="@xml/livecanvas_wallpaper" />
</service>
```

- Thêm `android/app/src/main/res/xml/livecanvas_wallpaper.xml` (`<wallpaper>` với `android:description`).
- **KHÔNG** thêm `WRITE_EXTERNAL_STORAGE` hay bất kỳ quyền lưu trữ nào (FR-014, INV-8).

### iOS — `ios/Runner/Info.plist`

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>LiveCanvas lưu video hình nền vào thư viện Ảnh để bạn đặt làm hình nền qua Phím tắt.</string>
```

Chuỗi mô tả quyền này hiển thị cho người dùng cuối nên phải là tiếng Việt và nói đúng mục đích — App Review đọc chính chuỗi này.
