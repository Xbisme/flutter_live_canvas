# Phase 0 — Research: Set Wallpaper Native Integration (MO-005)

**Ngày**: 2026-08-09 · **Spec**: [spec.md](spec.md)

Mọi version package đều tra trực tiếp trên pub.dev tại thời điểm plan (Principle XVI). Mọi API nền tảng đều đối chiếu tài liệu chính thức của Android/Apple, không suy từ trí nhớ.

---

## R1 — Android đặt video làm hình nền động bằng cách nào?

**Quyết định**: Tự viết `LiveCanvasWallpaperService` (Kotlin, kế thừa `android.service.wallpaper.WallpaperService`) phát video bằng `MediaPlayer` lên `SurfaceHolder` của Engine; áp dụng bằng cách bắn intent `WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER` kèm extra `EXTRA_LIVE_WALLPAPER_COMPONENT` trỏ tới service của chính app.

**Căn cứ** (developer.android.com):
- `ACTION_CHANGE_LIVE_WALLPAPER` + `EXTRA_LIVE_WALLPAPER_COMPONENT` đều có từ **API 16**, thấp hơn `minSdk` của dự án rất nhiều → an toàn. Intent này mở màn **xem trước của hệ thống**, người dùng bấm "Đặt hình nền" mới thực sự áp dụng — khớp FR-011 (phải có bước xác nhận) và FR-016 (huỷ ở màn xem trước là hành động bình thường, không phải lỗi).
- Khai báo bắt buộc trong manifest: `<service>` với `android:permission="android.permission.BIND_WALLPAPER"`, `<intent-filter>` action `android.service.wallpaper.WallpaperService`, và `<meta-data android:name="android.service.wallpaper" android:resource="@xml/livecanvas_wallpaper"/>`.
- Vòng đời Engine dùng: `onSurfaceCreated` (tạo `MediaPlayer`), `onSurfaceDestroyed` (release), `onVisibilityChanged` (pause khi ẩn / resume khi hiện) — đây chính là thứ giữ FR-012 (chạy lặp, không tiếng: `isLooping = true`, `setVolume(0f, 0f)`) và tránh ngốn pin khi hình nền không hiển thị.

**Phương án đã cân nhắc và loại**:
- `WallpaperManager.setStream()` / `setBitmap()` — **chỉ đặt được ảnh tĩnh**, không phát video. Không đáp ứng được sản phẩm.
- Dùng package pub.dev có sẵn — không có package nào được bảo trì cung cấp một `WallpaperService` phát video; các package "wallpaper" phổ biến chỉ bọc `setBitmap`. Tự viết là con đường duy nhất, và cũng đúng tinh thần Principle VIII (channel theo miền, tự map lỗi).

---

## R2 — Tải file gốc có tiến trình và huỷ được: dùng gì?

**Quyết định**: Dùng **`Dio` (đã có, `^5.10.0`)** với một **instance riêng, không đăng ký interceptor nào**, gọi `download(url, savePath, onReceiveProgress:, cancelToken:)`. Không thêm package tải file mới.

**Căn cứ**:
- Dio đã là dependency (client generated dùng nó), có sẵn `onReceiveProgress` cho FR-007 và `CancelToken` cho FR-008. Thêm package chỉ để tải file là vi phạm Principle XIV.
- **Vì sao phải là instance riêng, không dùng lại Dio của client generated**: Dio đó có `baseUrl` trỏ backend và **interceptor gắn `X-App-Key` vào mọi request**. Liên kết tải là **presigned URL của S3/R2 — khác host hoàn toàn** (contract v0.4.0 cảnh báo rõ điều này). Gửi khoá app của mình sang một nhà cung cấp lưu trữ bên thứ ba là rò rỉ thông tin không cần thiết, và header lạ có nguy cơ va vào phần chữ ký của presigned URL. Instance sạch cũng tự nhiên thoả FR-006 (không giả định gì về tên miền).

**Phương án đã cân nhắc và loại**:
- `flutter_downloader` — chạy nền qua service riêng, thêm cấu hình native đáng kể cho một nhu cầu chỉ là tải một file trong lúc sheet đang mở. YAGNI.
- `http` package — không có tiến trình tải sẵn tiện như Dio, mà Dio thì đã có trong cây phụ thuộc.

---

## R3 — iOS lưu video vào thư viện Ảnh: package hay code native?

**Quyết định**: Viết **Swift thuần** trên chính channel `com.livecanvas/wallpaper` (`PHPhotoLibrary.requestAuthorization(for: .addOnly)` → `PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL:)`). **Không** thêm package.

**Căn cứ**:
- Đã bắt buộc phải viết code native cho Android (R1), nên đã có sẵn hạ tầng channel + quy ước map lỗi. Thêm ~30 dòng Swift rẻ hơn việc nuôi một dependency.
- Principle VIII yêu cầu **lỗi native phải map về `AppFailure`**. Tự viết cho phép phân biệt sạch "người dùng từ chối quyền" (FR-020, cần lối tắt mở Cài đặt) với "ghi file thất bại" — trong khi package thường gộp thành một loại lỗi chung.
- Chỉ cần thêm khoá `NSPhotoLibraryAddUsageDescription` vào `Info.plist` (quyền **add-only**, không xin quyền đọc toàn bộ thư viện).

**Phương án đã cân nhắc và loại**:
- **`gal` 2.3.3** (midoridesign.studio, verified publisher, cập nhật 14 ngày trước, iOS 11+/Android SDK 21+) — package tốt và còn sống. Loại vì: (a) tài liệu của nó yêu cầu app khai `WRITE_EXTERNAL_STORAGE` + `requestLegacyExternalStorage` cho Android API ≤29, mà MO-005 **cố tình không xin quyền lưu trữ trên Android** (FR-014/Q2-A) — mang theo một package kéo kỳ vọng cấu hình ngược với quyết định đó là mời gọi nhầm lẫn về sau; (b) ta chỉ cần đúng một lời gọi trên đúng một nền tảng.
- `image_gallery_saver` — đã cũ, không còn được bảo trì tích cực. Loại theo Principle XVI.

---

## R4 — File gốc nằm ở đâu, sống bao lâu?

**Quyết định**: Thêm **`path_provider ^2.1.6`** (flutter.dev verified publisher, Android SDK 24+/iOS 13+ — khớp nền hiện tại). Lưu file vào thư mục **riêng của app** (`getApplicationSupportDirectory()`), một thư mục con `wallpapers/`, tên file theo id wallpaper + **đuôi suy từ `content-type`/path của URL** (mặc định `mp4`, KHÔNG cứng `.mp4` — liên kết là presigned, container thật có thể là `.mov`, và file gắn sai đuôi làm `PHAsset` trên iOS lỗi khó truy nguyên). Sau khi đặt thành công, **giữ đúng một file** — file của hình nền đang dùng — và xoá phần còn lại (FR-015, SC-007).

**Căn cứ**:
- `getApplicationSupportDirectory()` (không phải cache dir): iOS không tự dọn thư mục này, còn hình nền động Android **phải đọc được file lâu dài** kể cả sau khi khởi động lại máy (FR-013). Đặt vào cache là mời hệ điều hành xoá mất hình nền đang chạy.
- Trên iOS file này chỉ là bản trung gian trước khi copy vào thư viện Ảnh → có thể xoá ngay sau khi lưu xong.

**Phương án đã cân nhắc và loại**:
- `getTemporaryDirectory()` — hệ điều hành có quyền dọn bất kỳ lúc nào → hình nền động Android sẽ chết. Loại.
- Không dùng `path_provider`, tự hỏi native đường dẫn qua channel — làm được nhưng thừa, `path_provider` là Flutter Favorite của chính flutter.dev.

---

## R5 — `ComponentName` của WallpaperService theo flavor

**Quyết định**: **Không hardcode** chuỗi package. Phía Kotlin dựng `ComponentName(context, LiveCanvasWallpaperService::class.java)` từ context lúc chạy.

**Căn cứ**: `android/app/build.gradle.kts` đặt `applicationId = "com.livecanvas.livecanvas"` nhưng flavor `development` có **`applicationIdSuffix = ".dev"`** → package lúc chạy của bản dev là `com.livecanvas.livecanvas.dev`. Một chuỗi hardcode sẽ chạy đúng ở bản production và **hỏng im lặng ở bản development** — đúng kiểu lỗi chỉ lộ ra khi đã lên store. Dựng từ context là miễn nhiễm với chuyện này.

---

## R6 — Đường dẫn video sống sót qua reboot: ai lưu?

**Quyết định**: **Phía Kotlin tự sở hữu bản lưu của mình** — `LiveCanvasWallpaperService` đọc đường dẫn video từ một file `SharedPreferences` **riêng của native**, được ghi ngay tại thời điểm đặt hình nền, trong cùng lời gọi channel. Tầng Flutter **không** dựa vào việc native đọc được kho `shared_preferences` của Dart.

**Căn cứ**:
- Sau khi khởi động lại máy, hệ thống dựng lại `WallpaperService` **mà không hề khởi động Flutter engine** → lúc đó không có gì trong Dart để hỏi. Service buộc phải tự đọc được đường dẫn.
- Đọc ké kho của plugin `shared_preferences` là ràng buộc vào chi tiết nội bộ của plugin (nó đã đổi từ XML sang DataStore cho API `SharedPreferencesAsync`) — chính là kiểu phụ thuộc âm thầm vỡ khi nâng version. Một file prefs riêng do native sở hữu là ranh giới sạch, đúng tinh thần Principle VIII (dữ liệu qua biên giới là DTO tường minh).

---

## R7 — Hình dạng state của sheet (Principle III)

**Quyết định**: Sealed class native + Equatable (kế thừa deviation đã duyệt từ MO-003), theo mẫu 4 trạng thái với biến thể **mang tiền tố tên gốc** đúng như Principle III yêu cầu:

| State | Ý nghĩa |
|---|---|
| `SetWallpaperInitial` | Sheet vừa mở, chưa bấm gì |
| `SetWallpaperLoadingDownload(progress)` | Đang tải, `progress` ∈ [0,1] hoặc null khi chưa biết tổng dung lượng |
| `SetWallpaperLoadedReady(filePath)` | Tải xong — trạng thái "Đã tải xuống" của prototype |
| `SetWallpaperLoadedApplied` | Android: người dùng đã áp dụng xong / iOS: đã lưu vào Ảnh |
| `SetWallpaperError(failure)` | Mọi thất bại, mang theo `AppFailure` |

**Căn cứ**: Principle III cấm đặt tên `success`/`failed`/`empty` và bắt biến thể mở rộng phải nối vào tên gốc (`loadingMore`, `loadedWithFilter`). `loadingDownload` / `loadedReady` / `loadedApplied` tuân thủ đúng. Tiến trình tải là **state**, không phải stream side-channel, để widget test kiểm được từng mốc.

---

## R8 — Kiểm thử phần native mà không cần máy thật

**Quyết định**: Mock `MethodChannel` bằng `TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler` cho tầng service; `bloc_test` cho cubit; widget test cho sheet ở cả hai nhánh nền tảng bằng cách chọn nhánh theo **`defaultTargetPlatform`** (override trong test qua `debugDefaultTargetPlatformOverride`) thay vì đọc thẳng `Platform.isAndroid`.

> **Sửa sau `/speckit-analyze` (2026-08-09, phát hiện F1)**: bản đầu của R8 đề xuất dùng chính `WallpaperPlatformService.isLiveWallpaperSupported()` làm cổng chọn nhánh giao diện. **Sai** — đó là câu hỏi về *năng lực*, không phải về *nền tảng*: máy Android thiếu màn chọn hình nền động cũng trả `false`, nên sheet sẽ render nhánh iOS cho người dùng Android và FR-017 ("thiết bị không hỗ trợ") **không bao giờ hiển thị được**. Hai tín hiệu phải tách bạch: `defaultTargetPlatform` chọn nhánh, `isLiveWallpaperSupported()` chỉ để bắn `PlatformUnsupportedFailure`.

**Căn cứ**:
- `Platform.isAndroid` đọc trực tiếp trong widget khiến **không thể** viết widget test cho nhánh iOS trên máy CI Linux/macOS. `defaultTargetPlatform` override được trong test nên vẫn đạt mục tiêu đó, mà không phải bịa ra một cổng trừu tượng thừa.
- Phần thực sự chạy trên máy — hình nền sống qua reboot (FR-013), quyền thư viện Ảnh (FR-020) — **không thể tự động hoá**, đưa vào [quickstart.md](quickstart.md) làm kịch bản nghiệm thu tay, giống cách MO-003/MO-004 đã làm.

---

## R9 — Điểm ghi lịch sử tải đặt ở đâu?

**Quyết định**: Gọi `DownloadHistoryRepository.record(id)` **trong repository của MO-005, ngay sau khi file ghi xong thành công**, trước khi trả `Result.ok`. Không gọi từ Cubit, không gọi từ widget.

**Căn cứ**:
- FR-023/FR-024 đòi "chỉ ghi khi **thành công**". Đặt ở đúng chỗ biết được kết quả cuối của việc ghi file thì các nhánh huỷ/lỗi/402 tự động không ghi, không cần rải điều kiện ở nhiều nơi.
- Principle XI cấm repository gọi repository. `DownloadHistoryRepository` nằm ở `lib/core/favorites/` còn kho tải mới nằm ở `lib/core/wallpaper/` → **cả hai đều là core**, nên phải điều phối bằng một **UseCase/Service ở core** đứng trên cả hai, chứ không phải cho repository này gọi repository kia. Chi tiết chữ ký ở [contracts/repositories.md](contracts/repositories.md).

---

## R10 — Có thay màn "Lịch sử tải" của MO-004 không?

**Quyết định**: **Không.** Giữ nguyên bản tối giản.

**Căn cứ**: Đã rà toàn bộ thư mục bàn giao thiết kế `.claude/livecanvas-detail-screens/project/livecanvas/` — có `Browse`, `Collection`, `Favorites`, `Paywall`, `Search`, `SetWallpaper`, `Sheets`, `WallpaperDetail`, và **không có** bản dựng nào cho màn Lịch sử tải. Không có nguồn thiết kế thì việc "thiết kế lại" chỉ là bịa, đúng thứ Principle VI muốn tránh. Deviation của MO-004 vẫn treo cho tới khi có bàn giao thật.

---

## Tổng hợp dependency mới (Principle XVI)

| Package | Version chốt | Publisher | Vì sao cần |
|---|---|---|---|
| `path_provider` | `^2.1.6` | flutter.dev (verified, Flutter Favorite) | Lấy thư mục riêng của app để chứa file gốc (R4) |

Không thêm package nào khác. `dio` tái dùng bản đã có (`^5.10.0`); phần lưu ảnh iOS và đặt hình nền Android viết native (R1, R3).
