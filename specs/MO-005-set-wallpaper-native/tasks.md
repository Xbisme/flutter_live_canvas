# Tasks: Set Wallpaper Native Integration (MO-005)

**Input**: Design documents from `specs/MO-005-set-wallpaper-native/`
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/)

**Tests**: INCLUDED — Principle XIII (hiến pháp) bắt buộc unit test cho business logic, `bloc_test` cho mọi Cubit, và widget test cho luồng quan trọng, trong đó nêu đích danh **"Set-Wallpaper flow (mocked channel)"**.

**Organization**: Theo user story (US1–US4) để implement & test độc lập. Nhãn `[P]` = chạy song song được (khác file, không phụ thuộc task chưa xong).

## Path Conventions

Flutter feature-first: `lib/core/…`, `lib/features/…`, test ở `test/…` (gương cấu trúc `lib`). Native: `android/app/src/main/kotlin/com/livecanvas/livecanvas/`, `ios/Runner/`. State = native sealed class + Equatable (deviation đã duyệt, xem [plan.md](plan.md) §Complexity Tracking).

**Đây là spec đầu tiên của dự án viết code native ngoài scaffold** — mọi thứ trong `android/`/`ios/` đều là mới.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Thêm dependency + khung hằng số channel.

- [X] T001 Xác nhận `path_provider` latest stable trên pub.dev (Principle XVI — bản chốt lúc plan: **2.1.6**, flutter.dev verified), thêm `path_provider: ^2.1.6` vào [pubspec.yaml](../../pubspec.yaml) kèm comment giải thích như các dep khác; chạy `flutter pub get`; commit `pubspec.lock` + `ios/Podfile.lock`.
- [X] T002 Tạo thư mục mới `lib/core/constants/` và file [lib/core/constants/channel_methods.dart](../../lib/core/constants/channel_methods.dart): `abstract final class WallpaperChannel` với `name = 'com.livecanvas/wallpaper'` + 3 hằng method (`setLiveWallpaper`, `saveVideoToPhotos`, `isLiveWallpaperSupported`) — theo [contracts/method-channel.md](contracts/method-channel.md). Principle VIII cấm hardcode tên channel/method ở call site.

**Checkpoint**: dep + hằng số channel sẵn sàng.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Tầng core dùng chung mà MỌI user story cần — model, kho tải, cầu nối native, use case, chuỗi lỗi. ⚠️ Phải xong trước US1–US4.

> **Lưu ý phạm vi**: `SetWallpaperUseCase` ở phase này **CHƯA** ghi lịch sử tải — phần đó là nội dung riêng của US3 (T031) để US3 vẫn là một increment độc lập có giá trị.

- [X] T003 [P] Tạo model `WallpaperFile` (Equatable, `{wallpaperId, path, sizeBytes}`) trong [lib/core/wallpaper/wallpaper_file.dart](../../lib/core/wallpaper/wallpaper_file.dart) — theo [data-model.md](data-model.md) §1.
- [X] T004 [P] Tạo model `DownloadProgress` (Equatable, `{receivedBytes, totalBytes, fraction}`; `fraction` null khi `totalBytes` null) trong [lib/core/wallpaper/download_progress.dart](../../lib/core/wallpaper/download_progress.dart).
- [X] T005 Tạo `WallpaperDownloadRepository` interface + impl (`@LazySingleton(as:)`) trong [lib/core/wallpaper/wallpaper_download_repository.dart](../../lib/core/wallpaper/wallpaper_download_repository.dart) — theo [contracts/repositories.md](contracts/repositories.md). Bắt buộc: (a) mỗi lần gọi `download` phải xin **liên kết mới** qua `PublicApi.wallpapersIdDownloadUrlGet` rồi mới tải, KHÔNG lưu/dùng lại liên kết (INV-2); (b) tải bằng **instance `Dio` riêng, KHÔNG đăng ký interceptor nào** — không gửi `X-App-Key` sang host S3/R2 ([research.md](research.md) R2); (c) không đọc/so sánh/hardcode tên miền (FR-006); (d) lưu vào `getApplicationSupportDirectory()/wallpapers/<id>.<ext>` qua `path_provider`, **KHÔNG dùng cache dir** (R4); `<ext>` **suy từ `content-type` của response hoặc phần path của URL đã strip query**, mặc định `mp4` — KHÔNG cứng `.mp4`: liên kết là presigned và container thật có thể là `.mov`, mà file gắn sai đuôi làm `PHAsset` trên iOS lỗi khó truy nguyên; (e) ghi ra file `.part` rồi rename khi xong, để lần tải hỏng không để lại file cụt trông như hợp lệ; (f) `onReceiveProgress` → `DownloadProgress`, `CancelToken` để huỷ; (g) map `402`→`EntitlementRequiredFailure`, `404`→`NotFoundFailure`, còn lại qua `mapDioError` sẵn có; (h) `pruneExcept`, `discardPartial`. Phụ thuộc T003, T004.
- [X] T006 Tạo `WallpaperPlatformService` interface + impl (`@LazySingleton(as:)`) trong [lib/core/wallpaper/wallpaper_platform_service.dart](../../lib/core/wallpaper/wallpaper_platform_service.dart): bọc `MethodChannel(WallpaperChannel.name)`; **đây là nơi DUY NHẤT** mã lỗi native biến thành `AppFailure` theo bảng ở [data-model.md](data-model.md) §2 (`UNSUPPORTED`→`PlatformUnsupportedFailure`, `FILE_MISSING`/`PERMISSION_DENIED`→`FileWriteFailedFailure`, `SET_FAILED`/`SAVE_FAILED`→`WallpaperSetFailedFailure`); `setLiveWallpaper` trả `Result<bool>` với `false` = người dùng huỷ ở màn xem trước (**KHÔNG phải lỗi** — INV-7). Phụ thuộc T002, T003.
- [X] T007 Tạo `SetWallpaperUseCase` interface + impl (`@LazySingleton(as:)`) trong [lib/core/wallpaper/set_wallpaper_use_case.dart](../../lib/core/wallpaper/set_wallpaper_use_case.dart): `prepare` (gọi download), `apply` (gọi `setLiveWallpaper`, và **chỉ khi `applied == true`** mới gọi `pruneExcept` — huỷ ở màn xem trước thì file phải còn nguyên để thử lại, FR-016), `saveToPhotos` (gọi `saveVideoToPhotos` rồi xoá file trung gian). Phụ thuộc T005, T006.
- [X] T008 Thêm khoá i18n vào [lib/l10n/arb/app_vi.arb](../../lib/l10n/arb/app_vi.arb) + [app_en.arb](../../lib/l10n/arb/app_en.arb) kèm `@description`: tiêu đề sheet, 2 câu giải thích theo nền tảng, 2 nhãn nút chính, tiêu đề + 2 câu "Đã tải xuống", nhãn "Đặt làm hình nền"/"Mở Shortcuts", 3 bước hướng dẫn Shortcuts, nhãn huỷ/thử lại, và **4 thông điệp lỗi mới** (tải thất bại, ghi file thất bại, đặt hình nền thất bại, thiết bị không hỗ trợ) + thông điệp cần Premium; regen `lib/l10n/gen`. Chuỗi bám nguyên văn tiếng Việt của [SetWallpaper.jsx](../../.claude/livecanvas-detail-screens/project/livecanvas/SetWallpaper.jsx).
- [X] T009 Sửa [lib/core/error/failure_l10n.dart](../../lib/core/error/failure_l10n.dart): thêm 4 nhánh `DownloadFailedFailure`/`FileWriteFailedFailure`/`WallpaperSetFailedFailure`/`PlatformUnsupportedFailure` trước nhánh `_` (hiện đang gộp hết vào `failureUnknown` — comment ở dòng 17-18 nói rõ "MO-005 localize"). Phụ thuộc T008.
- [X] T010 Regen DI: `dart run lean_builder build`; xác minh `lib/core/di/injection.config.dart` có `WallpaperDownloadRepository`, `WallpaperPlatformService`, `SetWallpaperUseCase`. Phụ thuộc T005, T006, T007.
- [X] T011 [P] Unit test `WallpaperDownloadRepository` trong [test/core/wallpaper/wallpaper_download_repository_test.dart](../../test/core/wallpaper/wallpaper_download_repository_test.dart): xin liên kết mới **mỗi lần** gọi (INV-2 — assert số lần gọi API); `402`→`EntitlementRequiredFailure`; `404`→`NotFoundFailure`; lỗi mạng→`NetworkFailure`; huỷ qua `CancelToken` → không để lại file (INV-4); `pruneExcept` giữ đúng 1 file (INV-5); **assert Dio dùng để tải KHÔNG mang header `X-App-Key`**.
- [X] T012 [P] Unit test `WallpaperPlatformService` trong [test/core/wallpaper/wallpaper_platform_service_test.dart](../../test/core/wallpaper/wallpaper_platform_service_test.dart): mock channel qua `TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler`; đủ 5 mã lỗi → đúng `AppFailure`; `applied=false` → `Ok(false)` **không phải** `Err` (INV-7).
- [X] T013 [P] Unit test `SetWallpaperUseCase` trong [test/core/wallpaper/set_wallpaper_use_case_test.dart](../../test/core/wallpaper/set_wallpaper_use_case_test.dart): `apply` gọi `pruneExcept` khi `applied=true`; **không** gọi khi `applied=false`; `saveToPhotos` xoá file trung gian sau khi lưu xong.

**Checkpoint**: tầng core + chuỗi lỗi sẵn sàng — bắt đầu US song song được.

---

## Phase 3: User Story 1 — Đặt hình nền động trên Android (Priority: P1) 🎯 MVP

**Goal**: Từ Wallpaper Detail, tải file gốc rồi đặt làm hình nền động qua màn xem trước của hệ thống; hình nền sống qua thoát app và reboot.

**Independent Test**: Máy Android thật → wallpaper miễn phí → Detail → "Đặt làm hình nền" → hoàn tất luồng → thoát app + khởi động lại máy, hình nền vẫn chuyển động. Không cần iOS, không cần backend IAP.

- [X] T014 [P] [US1] Tạo `LiveCanvasWallpaperService` (Kotlin) trong [android/app/src/main/kotlin/com/livecanvas/livecanvas/LiveCanvasWallpaperService.kt](../../android/app/src/main/kotlin/com/livecanvas/livecanvas/LiveCanvasWallpaperService.kt): kế thừa `WallpaperService`; Engine tạo `MediaPlayer` ở `onSurfaceCreated` (đọc `active_video_path` từ `SharedPreferences` riêng của native tên `livecanvas_wallpaper_prefs` — R6), `isLooping = true`, `setVolume(0f, 0f)` (FR-012); `release()` ở `onSurfaceDestroyed`; **pause/resume ở `onVisibilityChanged`** để không đốt pin khi hình nền bị che; xử lý an toàn khi đường dẫn thiếu/hỏng (không crash, chỉ để màn đen).
- [X] T015 [P] [US1] Tạo resource meta-data [android/app/src/main/res/xml/livecanvas_wallpaper.xml](../../android/app/src/main/res/xml/livecanvas_wallpaper.xml) (`<wallpaper>` với `android:description`) + chuỗi label trong `android/app/src/main/res/values/strings.xml`.
- [X] T016 [US1] Khai `<service>` trong [android/app/src/main/AndroidManifest.xml](../../android/app/src/main/AndroidManifest.xml) đúng mẫu ở [contracts/method-channel.md](contracts/method-channel.md): `android:permission="android.permission.BIND_WALLPAPER"`, `<intent-filter>` action `android.service.wallpaper.WallpaperService`, `<meta-data android:name="android.service.wallpaper">`. **KHÔNG thêm `WRITE_EXTERNAL_STORAGE` hay bất kỳ quyền lưu trữ nào** (FR-014, INV-8). Phụ thuộc T014, T015.
- [X] T017 [US1] Tạo `WallpaperChannelHandler` (Kotlin) trong [android/app/src/main/kotlin/com/livecanvas/livecanvas/WallpaperChannelHandler.kt](../../android/app/src/main/kotlin/com/livecanvas/livecanvas/WallpaperChannelHandler.kt): xử lý `setLiveWallpaper` (kiểm tra file tồn tại → `FILE_MISSING`; **ghi `active_video_path` vào prefs TRƯỚC khi bắn intent**; `startActivityForResult` với `ACTION_CHANGE_LIVE_WALLPAPER` + `EXTRA_LIVE_WALLPAPER_COMPONENT` = `ComponentName(context, LiveCanvasWallpaperService::class.java)` **dựng từ context, KHÔNG hardcode chuỗi package** — flavor dev có hậu tố `.dev`, xem R5; trả `applied` theo `resultCode`), `isLiveWallpaperSupported` (`resolveActivity` cho intent trên), và ném `SAVE_FAILED`/`UNSUPPORTED` đúng mã. Phụ thuộc T014.
- [X] T018 [US1] Sửa [android/app/src/main/kotlin/com/livecanvas/livecanvas/MainActivity.kt](../../android/app/src/main/kotlin/com/livecanvas/livecanvas/MainActivity.kt): override `configureFlutterEngine` để đăng ký `WallpaperChannelHandler` lên `MethodChannel` tên `com.livecanvas/wallpaper`; nối `onActivityResult` về handler. Phụ thuộc T017.
- [X] T019 [P] [US1] Tạo `SetWallpaperState` (sealed native + Equatable) trong [lib/features/set_wallpaper/presentation/cubit/set_wallpaper_state.dart](../../lib/features/set_wallpaper/presentation/cubit/set_wallpaper_state.dart): `SetWallpaperInitial`, `SetWallpaperLoadingDownload(DownloadProgress)`, `SetWallpaperLoadedReady(WallpaperFile)`, `SetWallpaperLoadedApplied`, `SetWallpaperError(AppFailure)` — tên biến thể **mang tiền tố tên gốc** theo Principle III ([research.md](research.md) R7).
- [X] T020 [US1] Tạo `SetWallpaperCubit` (`@injectable`) trong [lib/features/set_wallpaper/presentation/cubit/set_wallpaper_cubit.dart](../../lib/features/set_wallpaper/presentation/cubit/set_wallpaper_cubit.dart): `startDownload()` (giữ `CancelToken`, phát `LoadingDownload` theo tiến trình, **chặn gọi chồng khi đang tải** — INV-3), `cancel()` (huỷ token + `discardPartial` → về `Initial`, INV-4), `applyWallpaper()` (gọi `apply`; `applied=true`→`LoadedApplied`; `applied=false`→**giữ nguyên** `LoadedReady`), `retry()` (về `Initial` để lần sau **xin liên kết mới** — INV-2). ⚠️ **`close()` phải làm ĐỦ hai việc**: huỷ `CancelToken` **và** gọi `discardPartial` — FR-008 đòi đóng sheet lúc đang tải phải huỷ *và* dọn dữ liệu dở dang, mà đường vuốt đóng sheet không đi qua `cancel()` (chỉ nút huỷ mới đi qua), nên nếu `close()` chỉ huỷ token thì file `.part` sẽ tích tụ (vỡ INV-4). Phụ thuộc T007, T019.
- [X] T021 [US1] Tạo `SetWallpaperSheet` trong [lib/features/set_wallpaper/presentation/widgets/set_wallpaper_sheet.dart](../../lib/features/set_wallpaper/presentation/widgets/set_wallpaper_sheet.dart) bám [SetWallpaper.jsx](../../.claude/livecanvas-detail-screens/project/livecanvas/SetWallpaper.jsx): grab handle, tiêu đề Clash 22 + nút đóng `GlassIconButton`, câu giải thích, nút chính `AppButton` full-width; trạng thái "Đã tải xuống" với icon check-circle 56 màu `success` + tiêu đề Clash 24 + câu mô tả + CTA. **Bỏ segmented control Android/iPhone** (FR-002 — đó chỉ là công cụ trình diễn của prototype web). ⚠️ **Hai tín hiệu tách bạch, không được gộp**: (a) chọn nhánh giao diện Android/iOS bằng **`defaultTargetPlatform`** — KHÔNG đọc `Platform.isAndroid` (test override được qua `debugDefaultTargetPlatformOverride`, giữ nguyên mục tiêu testability của R8); (b) `WallpaperPlatformService.isLiveWallpaperSupported()` **chỉ** dùng để bắn `PlatformUnsupportedFailure` khi máy Android không có màn chọn hình nền động (FR-017). Gộp hai thứ này lại sẽ khiến máy Android không hỗ trợ render nhầm nhánh iOS và FR-017 **không bao giờ hiển thị được**. Thanh tiến trình + nút huỷ khi đang tải. Haptic ở 2 mốc bắt đầu tải và thành công, đặt trong `BlocListener` (Principle III). Token-only, không hex ở call site. Phụ thuộc T008, T020.
- [X] T022 [US1] Sửa [lib/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart](../../lib/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart): thay handler `soon` của **cả hai** nút "Tải xuống" và "Đặt làm hình nền" bằng việc mở `SetWallpaperSheet` qua `showModalBottomSheet` (FR-001 — prototype nối cả 2 nút vào cùng một sheet); gỡ comment "MO-003: visual placeholders". Trên tablet hiển thị dạng hộp thoại giữa màn hình theo [ipad.html](../../.claude/livecanvas-detail-screens/project/livecanvas/ipad.html) (FR-031). Phụ thuộc T021.
- [X] T023 [P] [US1] `bloc_test` `SetWallpaperCubit` trong [test/features/set_wallpaper/set_wallpaper_cubit_test.dart](../../test/features/set_wallpaper/set_wallpaper_cubit_test.dart): Initial→LoadingDownload(progress)→LoadedReady; huỷ→Initial + `discardPartial` được gọi; lỗi tải→Error; gọi `startDownload` khi đang tải → **không** sinh lần tải thứ hai (INV-3); `applied=false` → **vẫn** `LoadedReady` (INV-7); `applied=true`→LoadedApplied; **`close()` khi đang tải → `discardPartial` được gọi** (FR-008, INV-4 — đường vuốt đóng sheet).
- [X] T024 [P] [US1] Widget test `SetWallpaperSheet` nhánh Android trong [test/features/set_wallpaper/set_wallpaper_sheet_android_test.dart](../../test/features/set_wallpaper/set_wallpaper_sheet_android_test.dart): với `debugDefaultTargetPlatformOverride = TargetPlatform.android` → hiện câu giải thích Android + nút "Tải & đặt hình nền"; **không** có segmented control; sau khi tải xong hiện "Đã tải xuống" + nút "Đặt làm hình nền"; trạng thái lỗi hiện **chuỗi tiếng Việt**, không có mã lỗi kỹ thuật nào (INV-6). **Case bắt buộc**: Android nhưng `isLiveWallpaperSupported()` trả `false` → vẫn render **nhánh Android** và hiện thông báo "thiết bị không hỗ trợ" (FR-017), **không** rơi sang hướng dẫn Shortcuts của iOS.
- [ ] T025 [US1] Nghiệm thu tay US1 trên **máy Android thật** theo [quickstart.md](quickstart.md) §US1 (10 bước, gồm **M1 reboot** và **M5 chỉ còn một file**); **bấm giờ SC-002** (file mẫu ~5 MB xong dưới 10 giây trên Wi-Fi) và **SC-001** (≤4 chạm, <60 giây). Ghi số đo vào PR.

**Checkpoint**: US1 độc lập chạy được — Android đặt được hình nền động thật.

---

## Phase 4: User Story 2 — Lưu video + hướng dẫn Shortcuts trên iOS (Priority: P2)

**Goal**: Trên iPhone/iPad, lưu video gốc vào thư viện Ảnh rồi hướng dẫn 3 bước đặt qua Shortcuts, nói thẳng giới hạn của iOS.

**Independent Test**: iPhone thật → wallpaper miễn phí → "Đặt làm hình nền" → "Lưu video vào Ảnh" → video xuất hiện trong app Ảnh, nút "Mở Shortcuts" mở đúng app Phím tắt. Độc lập hoàn toàn với Android.

- [X] T026 [P] [US2] Tạo `WallpaperChannelHandler` (Swift) trong [ios/Runner/WallpaperChannelHandler.swift](../../ios/Runner/WallpaperChannelHandler.swift): `saveVideoToPhotos` → `PHPhotoLibrary.requestAuthorization(for: .addOnly)` (quyền **add-only**, không xin quyền đọc thư viện) → `PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL:)`; lưu **video gốc nguyên trạng, KHÔNG chuyển Live Photo** (FR-019, quyết định Q1/A); trả mã lỗi `PERMISSION_DENIED`/`FILE_MISSING`/`SAVE_FAILED`; `setLiveWallpaper` và `isLiveWallpaperSupported` trả `UNSUPPORTED`/`false`.
- [X] T027 [US2] Sửa [ios/Runner/AppDelegate.swift](../../ios/Runner/AppDelegate.swift): đăng ký `FlutterMethodChannel` tên `com.livecanvas/wallpaper` với handler ở T026 (dùng `engineBridge` trong `didInitializeImplicitFlutterEngine` cho khớp cấu trúc hiện có). Phụ thuộc T026.
- [X] T028 [P] [US2] Thêm `NSPhotoLibraryAddUsageDescription` vào [ios/Runner/Info.plist](../../ios/Runner/Info.plist) với mô tả **tiếng Việt** nói đúng mục đích (App Review đọc chính chuỗi này). **KHÔNG** thêm `NSPhotoLibraryUsageDescription` — app không đọc thư viện.
- [X] T029 [US2] Bổ sung nhánh iOS vào `SetWallpaperCubit` ([lib/features/set_wallpaper/presentation/cubit/set_wallpaper_cubit.dart](../../lib/features/set_wallpaper/presentation/cubit/set_wallpaper_cubit.dart)): `saveToPhotos()` gọi use case → `LoadedApplied`; lỗi quyền → `Error(FileWriteFailedFailure)` để UI hiện lối tắt mở Cài đặt. Phụ thuộc T020.
- [X] T030 [US2] Bổ sung nhánh iOS vào `SetWallpaperSheet` ([lib/features/set_wallpaper/presentation/widgets/set_wallpaper_sheet.dart](../../lib/features/set_wallpaper/presentation/widgets/set_wallpaper_sheet.dart)): câu giải thích nói rõ **iOS không cho app tự đặt** video làm hình nền (FR-018 — tuyệt đối không câu chữ nào ngụ ý ngược lại); nút chính "Lưu video vào Ảnh"; trạng thái xong hiện **3 bước** dạng `Step` (số trong pill `aurora-soft` + chữ) đúng nguyên văn prototype + nút thứ cấp "Mở Shortcuts" mở `shortcuts://` với **thông báo thân thiện khi không mở được** (FR-022); trường hợp từ chối quyền hiện thông báo + lối tắt mở Cài đặt (FR-020). Phụ thuộc T021, T029.
- [X] T031 [US2] Widget test `SetWallpaperSheet` nhánh iOS trong [test/features/set_wallpaper/set_wallpaper_sheet_ios_test.dart](../../test/features/set_wallpaper/set_wallpaper_sheet_ios_test.dart): với cổng nền tảng trả `false` → hiện câu giải thích iOS + nút "Lưu video vào Ảnh"; sau khi lưu xong hiện đúng **3 bước** + nút "Mở Shortcuts"; **assert không có chuỗi nào hứa app tự đặt hình nền** (FR-018).
- [ ] T032 [US2] Nghiệm thu tay US2 trên **iPhone thật** theo [quickstart.md](quickstart.md) §US2 (6 bước, gồm **M3** từ chối rồi cấp lại quyền, **M4** video nằm trong app Ảnh). Ghi kết quả vào PR.

**Checkpoint**: US1 và US2 đều chạy độc lập trên nền tảng của mình.

---

## Phase 5: User Story 3 — Lịch sử tải ghi nhận thật (Priority: P3)

**Goal**: Nối **điểm ghi thật** cho `DownloadHistoryRepository` mà MO-004 để treo (mới test bằng dữ liệu seed).

**Independent Test**: Tải một wallpaper → mở tab "Bạn" → "Lịch sử tải" → thấy mục mới ở đầu danh sách; tải lại đúng nó → vẫn một mục, ở đầu.

- [X] T033 [US3] Bổ sung ghi lịch sử vào `SetWallpaperUseCase` ([lib/core/wallpaper/set_wallpaper_use_case.dart](../../lib/core/wallpaper/set_wallpaper_use_case.dart)): tiêm `DownloadHistoryRepository` (đã có từ MO-004 ở `lib/core/favorites/`) và gọi `record(wallpaperId)` **trong `prepare`, ngay sau khi `download` trả `Ok`, trước khi trả về** (INV-1) — nhờ đặt đúng chỗ này mà nhánh huỷ / lỗi mạng / `402` **tự động** không ghi, không cần rải điều kiện. `record` hỏng thì **chỉ log**, vẫn trả `Ok` của lượt tải (lịch sử là tiện ích phụ, không được làm hỏng việc đặt hình nền). Regen DI sau khi đổi constructor. Phụ thuộc T007.
- [X] T034 [US3] Unit test ghi lịch sử trong [test/core/wallpaper/set_wallpaper_history_test.dart](../../test/core/wallpaper/set_wallpaper_history_test.dart): tải thành công → `record` gọi **đúng một lần** với đúng id; huỷ → **không** gọi; lỗi mạng → **không** gọi; `402` → **không** gọi (FR-024); `record` trả `Err` → `prepare` vẫn trả `Ok`; **gọi `prepare` 3 lần cùng một id → `record` gọi 3 lần nhưng kho lịch sử còn đúng 1 mục và nằm ở đầu** (SC-005 — khẳng định lại hành vi dedupe của MO-004 qua đường ghi mới của MO-005).
- [X] T035 [US3] Kiểm chứng màn [lib/features/download_history/presentation/pages/download_history_page.dart](../../lib/features/download_history/presentation/pages/download_history_page.dart) hiển thị mục mới sau khi tải: màn này là **pushed page** (không sống trong `indexedStack`) nên `load()` chạy lại mỗi lần mở — xác nhận đúng như vậy, và nếu không thì sửa. Đây chính là lớp lỗi đã cắn ở MO-004 (bugfix 2: `FavoritesPage` trong `indexedStack` chỉ load một lần).

**Checkpoint**: lịch sử tải có dữ liệu thật, không còn phụ thuộc seed.

---

## Phase 6: User Story 4 — Chặn premium đúng cách (Priority: P4)

**Goal**: Wallpaper premium bị chặn ở máy chủ, app hiện thông báo + lối đi tới Paywall, không tải gì và không ghi lịch sử.

**Independent Test**: Mở wallpaper có nhãn PRO → "Đặt làm hình nền" → không có tiến trình tải nào chạy, thông báo cần Premium + nút đi Paywall xuất hiện.

- [X] T036 [P] [US4] Thêm hằng `AppRoutes.paywall = '/paywall'` vào [lib/core/router/app_routes.dart](../../lib/core/router/app_routes.dart) + entry go_router (pushed, phủ shell) trong [lib/app/router/app_router.dart](../../lib/app/router/app_router.dart), trỏ tới một `PaywallPlaceholderPage` tối giản ở `lib/features/paywall/presentation/pages/paywall_placeholder_page.dart` (tái dùng `TopBar` + `EmptyState`). **Bản tạm có chủ đích** — thiết kế và luồng mua thật thuộc MO-006, đã ghi ở [spec.md](spec.md) §Assumptions.
- [X] T037 [US4] Xử lý `EntitlementRequiredFailure` trong `SetWallpaperSheet` ([lib/features/set_wallpaper/presentation/widgets/set_wallpaper_sheet.dart](../../lib/features/set_wallpaper/presentation/widgets/set_wallpaper_sheet.dart)): hiện thông báo cần gói Premium + nút hành động đi tới Paywall, đặt trong `BlocListener` (Principle III — điều hướng là side effect). ⚠️ **Principle X nêu đích danh "Paywall, Set Wallpaper"**: phải **đóng sheet TRƯỚC**, rồi mở Paywall trong `addPostFrameCallback` — tuyệt đối không `context.push(AppRoutes.paywall)` khi sheet còn đang mở trong cùng một frame. Phụ thuộc T036.
- [X] T038 [US4] Widget test chặn premium trong [test/features/set_wallpaper/set_wallpaper_premium_test.dart](../../test/features/set_wallpaper/set_wallpaper_premium_test.dart): use case trả `Err(EntitlementRequiredFailure())` → **không** có thanh tiến trình nào xuất hiện, thông báo Premium hiện, chạm CTA → điều hướng Paywall; **assert trình tự Principle X**: sheet đã biến mất khỏi cây widget **trước** khi route Paywall được push (pump qua frame để bắt được thứ tự); `record` lịch sử **không** được gọi.
- [ ] T039 [US4] Nghiệm thu tay US4 theo [quickstart.md](quickstart.md) §US4 trên wallpaper có nhãn PRO (backend BE-005 chưa merge → mọi premium đều `402`, đây là hành vi đúng của MO-005).

**Checkpoint**: cả 4 user story chạy độc lập.

---

## Phase 7: Polish & Cross-Cutting Concerns

- [X] T040 [P] Rà toàn bộ chuỗi hiển thị mới nằm trong ARB (Principle XV) — không còn chuỗi cứng nào trong `lib/features/set_wallpaper/`; `app_vi.arb` và `app_en.arb` **cùng bộ khoá**.
- [ ] T041 [P] Rà bảng kịch bản lỗi ở [quickstart.md](quickstart.md) §Kịch bản lỗi: mất mạng giữa chừng, đóng sheet khi đang tải, liên kết hết hạn >5 phút, wallpaper bị gỡ, hết dung lượng, máy không hỗ trợ — **mọi trường hợp không lộ mã lỗi kỹ thuật** (INV-6, SC-004).
- [ ] T042 [P] Nghiệm thu bố cục tablet (FR-031, Principle VII): mở sheet trên iPad/máy tính bảng → hiển thị dạng **hộp thoại giữa màn hình** theo [ipad.html](../../.claude/livecanvas-detail-screens/project/livecanvas/ipad.html), không phải sheet trượt từ đáy (M8). Nếu không có thiết bị, ghi rõ **defer, không chặn merge** như MO-003 đã làm với T056.
- [ ] T043 Kiểm SC-007 trên máy thật: đặt 10 hình nền khác nhau rồi kiểm thư mục `wallpapers/` **chỉ còn một file** (M5).
- [X] T044 Chạy Pre-Commit Checklist hiến pháp: `dart format .` · `flutter analyze` (0 warning) · `very_good test --test-randomize-ordering-seed random` · `dart run bloc_tools:bloc lint .` (0 vi phạm).
- [ ] T045 Nghiệm thu SC-003 trên **máy Android thứ hai** (khác nhà sản xuất/ROM) theo [quickstart.md](quickstart.md) §US1 bước 7–9 — khác biệt ROM là điểm dễ vỡ nhất của live wallpaper (M7).
- [X] T046 Cập nhật [.claude/changelog.md](../../.claude/changelog.md) (mục MO-005 ở `[Unreleased]`) + [project-context.md](../../.claude/project-context.md) / [sdd-roadmap.md](../../.claude/sdd-roadmap.md) status khi chuẩn bị PR; ghi rõ deviation kế thừa (native sealed class; màn Lịch sử tải vẫn tối giản) và **Paywall là bản tạm chờ MO-006**.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: không phụ thuộc gì — bắt đầu ngay.
- **Foundational (Phase 2)**: phụ thuộc Phase 1 — **CHẶN toàn bộ user story**.
- **US1 (Phase 3)** / **US2 (Phase 4)** / **US3 (Phase 5)** / **US4 (Phase 6)**: đều chỉ phụ thuộc Phase 2; sau đó chạy song song được nếu đủ người, hoặc tuần tự theo ưu tiên P1→P4.
- **Polish (Phase 7)**: sau khi các user story mong muốn đã xong.

### User Story Dependencies

- **US1 (P1)**: sau Phase 2. Không phụ thuộc story nào.
- **US2 (P2)**: sau Phase 2. Dùng lại `SetWallpaperSheet`/`SetWallpaperCubit` do US1 tạo (T021, T020) — nếu làm song song, cần thống nhất trước rằng US1 tạo khung sheet còn US2 chỉ thêm nhánh.
- **US3 (P3)**: sau Phase 2. Sửa `SetWallpaperUseCase` (T007) — độc lập với UI của US1/US2, test được bằng unit test không cần máy.
- **US4 (P4)**: sau Phase 2 + T021 (cần sheet để gắn `BlocListener`).

### Within Each User Story

- Native trước Dart (Kotlin/Swift handler xong thì tầng Dart mới chạy thật được trên máy).
- Model → service → cubit → widget → wiring.
- Test viết cùng hoặc ngay sau phần được test; nghiệm thu tay là task cuối của story.

### Parallel Opportunities

- **Phase 2**: T003 ∥ T004 (2 model khác file); sau khi T005–T007 xong thì T011 ∥ T012 ∥ T013.
- **Phase 3**: T014 ∥ T015 (Kotlin service và resource khác file); T019 làm song song với toàn bộ phần native; T023 ∥ T024.
- **Phase 4**: T026 ∥ T028 (Swift và plist khác file).
- **Xuyên story**: US3 (T033–T035) hoàn toàn có thể chạy song song với US1/US2 vì chỉ đụng `set_wallpaper_use_case.dart` + test.

---

## Parallel Example: Phase 2 Foundational

```bash
# Hai model, khác file, không phụ thuộc nhau:
Task: "Tạo model WallpaperFile trong lib/core/wallpaper/wallpaper_file.dart"
Task: "Tạo model DownloadProgress trong lib/core/wallpaper/download_progress.dart"

# Sau khi T005–T007 xong, ba bộ test chạy song song:
Task: "Unit test WallpaperDownloadRepository trong test/core/wallpaper/wallpaper_download_repository_test.dart"
Task: "Unit test WallpaperPlatformService trong test/core/wallpaper/wallpaper_platform_service_test.dart"
Task: "Unit test SetWallpaperUseCase trong test/core/wallpaper/set_wallpaper_use_case_test.dart"
```

---

## Implementation Strategy

### MVP First (chỉ User Story 1)

1. Phase 1 Setup (T001–T002).
2. Phase 2 Foundational (T003–T013) — **CHẶN mọi thứ**.
3. Phase 3 US1 (T014–T025).
4. **DỪNG và NGHIỆM THU**: Android đặt được hình nền động thật, sống qua reboot.
5. Đây đã là lời hứa cốt lõi của sản phẩm — demo được ngay.

### Incremental Delivery

1. Setup + Foundational → nền sẵn sàng.
2. + US1 → Android đặt được hình nền (**MVP**).
3. + US2 → iOS có đường đi hợp lệ, đủ điều kiện nộp store.
4. + US3 → Lịch sử tải hết rỗng.
5. + US4 → Nội dung premium được bảo vệ, sẵn sàng bàn giao cho MO-006.

### Rủi ro cần canh sớm

- **T014/T017 là phần rủi ro nhất của cả spec** — code native chưa từng có trong dự án, và hành vi live wallpaper khác nhau đáng kể giữa các ROM. Làm sớm, thử trên máy thật sớm, đừng để tới cuối.
- **Bẫy flavor** (T017): bản `development` có package `com.livecanvas.livecanvas.dev`. Nếu chỉ test bản dev mà hardcode `ComponentName`, lỗi sẽ chỉ lộ ra ở bản production — kiểm cả hai flavor.
- **T005 (Dio riêng)**: nếu lỡ dùng lại Dio của client generated, `X-App-Key` sẽ bị gửi sang host S3/R2. T011 có assert riêng cho việc này — đừng bỏ qua.

---

## Notes

- `[P]` = khác file, không phụ thuộc task chưa xong.
- Nhãn `[US#]` map task về user story để truy vết.
- Mỗi user story hoàn thành độc lập và nghiệm thu độc lập được.
- Commit theo từng task hoặc nhóm hợp lý.
- **Không** đụng contract, **không** regenerate `packages/livecanvas_api` — MO-005 chỉ dùng endpoint đã có.
