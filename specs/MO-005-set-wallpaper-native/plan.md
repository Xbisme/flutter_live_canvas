# Implementation Plan: Set Wallpaper Native Integration (MO-005)

**Branch**: `MO-005-set-wallpaper-native` | **Date**: 2026-08-09 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/MO-005-set-wallpaper-native/spec.md`

## Summary

Biến LiveCanvas từ trình duyệt video thành app hình nền thật: từ màn Wallpaper Detail, người dùng mở **sheet "Đặt làm hình nền"** (đã có bản dựng thiết kế `SetWallpaper.jsx`), tải file gốc qua `GET /wallpapers/{id}/download-url`, rồi — trên **Android** — đặt làm hình nền động qua màn xem trước của hệ thống; trên **iOS** — lưu video vào thư viện Ảnh kèm hướng dẫn Shortcuts. Đồng thời **nối điểm ghi lịch sử tải thật** mà MO-004 để treo.

**Cách tiếp cận kỹ thuật**:

- **Native là bắt buộc, không có đường vòng**: đặt video làm hình nền động Android chỉ làm được bằng một `WallpaperService` tự viết (Kotlin, `MediaPlayer` trên `SurfaceHolder`) + intent `ACTION_CHANGE_LIVE_WALLPAPER`. Không package pub.dev nào làm thay được ([research.md](research.md) R1).
- **Đã phải viết native rồi thì viết nốt phần iOS**: lưu vào thư viện Ảnh bằng ~30 dòng Swift `PHPhotoLibrary` trên **cùng một channel**, thay vì kéo thêm dependency (R3). Chỉ thêm **đúng một package**: `path_provider ^2.1.6`.
- **Tầng Dart**: kho dùng chung ở `lib/core/wallpaper/` (`WallpaperDownloadRepository` + `WallpaperPlatformService` + `SetWallpaperUseCase`), feature `lib/features/set_wallpaper/` chứa sheet + cubit. UseCase tồn tại vì Principle XI cấm repository gọi repository — mà việc ghi lịch sử tải bắt buộc phải bắc cầu giữa hai kho ngang hàng ở core (R9).
- **Hai chi tiết dễ hỏng đã chốt trước**: (a) tải bằng **instance Dio riêng không interceptor**, vì presigned URL trỏ host S3/R2 khác và không được gửi `X-App-Key` sang đó (R2); (b) `ComponentName` dựng từ context lúc chạy, vì flavor `development` có hậu tố package `.dev` — hardcode sẽ chạy đúng ở production và **hỏng im lặng ở dev** (R5).

## Technical Context

**Language/Version**: Dart 3.x / Flutter stable (theo bootstrap MO-001; analyzer 12 + lean_builder). Native: **Kotlin** (Android) + **Swift** (iOS) — lần đầu dự án viết code native ngoài scaffold.

**Primary Dependencies**: `flutter_bloc`, `get_it` + `injectable` (lean_builder codegen), `go_router`, `equatable`, `dio ^5.10.0` (đã có — tái dùng cho tải file), `shared_preferences` (đã có, MO-004), **`path_provider ^2.1.6` (MỚI — flutter.dev verified, Flutter Favorite, Android SDK 24+/iOS 13+)**.

**Storage**: File gốc trong `getApplicationSupportDirectory()/wallpapers/` (KHÔNG phải cache dir — hệ điều hành được phép dọn cache, sẽ giết hình nền đang chạy). Phía native: file `SharedPreferences` **riêng của Kotlin** (`livecanvas_wallpaper_prefs`) giữ đường dẫn video đang dùng — bắt buộc, vì sau reboot service chạy khi Flutter engine chưa tồn tại (R6).

**Testing**: `bloc_test`, `mocktail`, `very_good test`; method channel mock qua `TestDefaultBinaryMessengerBinding`. Phần native thật nghiệm thu tay theo [quickstart.md](quickstart.md).

**Target Platform**: Android (đặt trực tiếp) + iOS/iPadOS (lưu Ảnh + hướng dẫn Shortcuts) + tablet responsive.

**Project Type**: mobile-app (Flutter, feature-first Clean Architecture).

**Performance Goals**: File mẫu ~5 MB tải xong <10s trên Wi-Fi (SC-002), có tiến trình suốt quá trình. Hình nền động phát lặp mượt, `MediaPlayer` **pause khi `onVisibilityChanged(false)`** để không đốt pin lúc hình nền bị che.

**Constraints**: Chỉ nghiệm thu end-to-end trên wallpaper **free** (BE-005 chưa merge → premium luôn `402`). Không xin quyền lưu trữ trên Android (FR-014). Không tự chuyển Live Photo trên iOS (FR-019). Tối đa **một** lần tải chạy đồng thời (FR-009). Sau khi đặt xong giữ **tối đa một** file gốc (SC-007).

**Scale/Scope**: 1 sheet mới, 1 cubit, 3 lớp core, 2 file native mới (Kotlin service + Swift handler), 1 file XML resource, sửa `Info.plist` + `AndroidManifest.xml`, mở rộng `failure_l10n` + ARB. Không đổi contract, **không regenerate client**.

## Constitution Check

*GATE: pass trước Phase 0; re-check sau Phase 1 design.*

| Principle | Đánh giá | Trạng thái |
|---|---|---|
| I. Contract-Driven | Dùng `GET /wallpapers/{id}/download-url` đã có sẵn trong client generated (v0.4.0+). Không field client-only, **không cần regenerate** (contract v0.7.1 chỉ đụng `/admin/*`). | ✅ Pass |
| II. Video/Memory | Không thêm `VideoPlayerController` nào — sheet chỉ có tiến trình tải, không phát preview. Video hình nền do `MediaPlayer` **phía native** phát, và release ở `onSurfaceDestroyed` + pause ở `onVisibilityChanged`. | ✅ Pass |
| III. BLoC | `SetWallpaperCubit` sealed 4-state, biến thể **mang tiền tố tên gốc** (`loadingDownload`/`loadedReady`/`loadedApplied` — R7). Haptic/toast/điều hướng ở `BlocListener`. Không cubit-to-cubit. | ✅ Pass (xem Complexity: native sealed) |
| IV. Result<T> | Cả 3 lớp core trả `Result<T>`; không `try/catch` trong cubit. **MO-005 là spec đầu tiên thực sự sinh ra** `DownloadFailedFailure`/`FileWriteFailedFailure`/`WallpaperSetFailedFailure`/`PlatformUnsupportedFailure` — chúng đã được khai báo ở MO-003 nhưng `failure_l10n` còn gộp vào `failureUnknown`, MO-005 phải thêm nhánh + chuỗi ARB riêng. | ✅ Pass |
| V. Entitlement | Client **không** tự quyết định premium — cứ gọi `download-url`, `402` từ máy chủ mới là câu trả lời (FR-026). Không cache trạng thái quyền. | ✅ Pass |
| VI. Design System | Sheet bám `SetWallpaper.jsx` (2 trạng thái, grab handle, segmented → **bỏ**, 3 bước Shortcuts). Token-only, tái dùng `AppButton`/`AppSheet`/`GlassIconButton` sẵn có. Màn Lịch sử tải **giữ nguyên bản tối giản** — bàn giao thiết kế xác nhận không có bản dựng nào cho nó (R10). | ⚠️ Pass w/ note |
| VII. Platform | **Trọng tâm của spec**: Android đặt trực tiếp qua `WallpaperService`; iOS nói thẳng giới hạn + hướng dẫn Shortcuts, không giả vờ đặt được (FR-018). Haptic ở 2 mốc. Sheet dạng hộp thoại giữa màn hình trên iPad (FR-031). | ✅ Pass |
| VIII. Method Channel | Một channel theo miền `com.livecanvas/wallpaper`; tên channel/method tập trung ở **`lib/core/constants/channel_methods.dart` (thư mục `constants/` chưa tồn tại — tạo mới)**; DTO qua biên giới chỉ kiểu nguyên thuỷ; lỗi native map về `AppFailure` tại **đúng một chỗ**. | ✅ Pass |
| IX. Local-First | Chỉ lưu ID + timestamp (lịch sử tải, đã có từ MO-004) và đường dẫn file. Không `transaction_id` ở spec này. | ✅ Pass |
| X. Navigation | Sheet mở bằng `showModalBottomSheet` từ Detail (không phải route); điều hướng Paywall qua hằng `AppRoutes` + `context.push`. ⚠️ Principle X nêu **đích danh "Paywall, Set Wallpaper"**: khi bị chặn `402` phải **đóng sheet TRƯỚC** rồi mở Paywall trong `addPostFrameCallback` — không push khi sheet còn mở trong cùng frame (siết sau `/speckit-analyze`, phát hiện C1; ràng buộc nằm ở tasks T037 + assert ở T038). | ✅ Pass |
| XI. Modularity | Kho tải + service native ở `lib/core/wallpaper/`; `core/` không import `features/`. **Repository không gọi repository** — `SetWallpaperUseCase` bắc cầu sang `DownloadHistoryRepository` (R9). | ✅ Pass |
| XII. Flavors | Không thêm flavor. Ngược lại, spec **xử lý đúng** hậu tố `.dev` của flavor development ở `ComponentName` (R5). | ✅ Pass |
| XIII. Testing | Unit (download repo, map lỗi native, prune, use case ghi lịch sử đúng-một-lần), bloc_test (`SetWallpaperCubit` đủ nhánh), widget (sheet cả 2 nhánh nền tảng qua cổng tiêm được). Phần native thật → nghiệm thu tay M1–M7. | ✅ Pass |
| XIV. YAGNI | Thêm **đúng một** package (`path_provider`); tái dùng `dio` sẵn có thay vì `flutter_downloader`; viết ~30 dòng Swift thay vì thêm `gal`. Không dựng hàng đợi tải nền, không hẹn giờ đổi hình nền. | ✅ Pass |
| XV. i18n | Toàn bộ chuỗi sheet + 4 thông điệp lỗi mới vào ARB `vi` (+ `en`). Chuỗi `NSPhotoLibraryAddUsageDescription` cũng viết tiếng Việt (App Review đọc chính chuỗi đó). | ✅ Pass |
| XVI. Deps | `path_provider ^2.1.6` tra pub.dev tại plan-time (flutter.dev verified). `gal 2.3.3` đã tra và **loại có lý do** (R3). API nền tảng đối chiếu developer.android.com, không suy từ trí nhớ. | ✅ Pass |

**Kết luận gate**: **PASS**. Một deviation đã-được-duyệt kế thừa (native sealed class thay `@freezed` — xem Complexity Tracking). Một note thiết kế kế thừa từ MO-004 (màn Lịch sử tải chưa có bản dựng — không chặn).

**Re-check sau Phase 1**: các artifact Phase 1 không phát sinh vi phạm mới. Hai điểm được **siết chặt hơn** sau khi thiết kế: (a) `SetWallpaperUseCase` ra đời chính là để **không** vi phạm Principle XI; (b) chọn nhánh giao diện bằng `defaultTargetPlatform` thay cho `Platform.isAndroid` đọc thẳng trong widget, để Principle XIII có thể phủ cả hai nhánh nền tảng bằng test tự động.

**Re-check sau `/speckit-analyze`** (2026-08-09) — 3 vấn đề đã sửa vào tasks/contracts, không vấn đề nào tồn đọng:

| ID | Mức | Nội dung | Đã sửa ở |
|---|---|---|---|
| C1 | CRITICAL | Điều hướng Paywall từ trong sheet chưa nêu trình tự dismiss-then-`addPostFrameCallback` mà Principle X bắt buộc | tasks T037, T038; hàng Principle X ở trên |
| F1 | HIGH | Gộp nhầm "nền tảng nào" với "có hỗ trợ không" — máy Android không hỗ trợ sẽ render nhánh iOS và FR-017 không bao giờ hiện | tasks T021, T024; [contracts/method-channel.md](contracts/method-channel.md); [research.md](research.md) R8 |
| G1 | HIGH | `close()` của cubit chỉ huỷ token, không dọn file `.part` → vuốt đóng sheet lúc đang tải để lại rác (vỡ FR-008/INV-4) | tasks T020, T023 |

## Project Structure

### Documentation (this feature)

```text
specs/MO-005-set-wallpaper-native/
├── plan.md              # (file này)
├── research.md          # Phase 0 — R1..R10
├── data-model.md        # Phase 1 — entity, DTO channel, state machine, bất biến
├── quickstart.md        # Phase 1 — kịch bản nghiệm thu US1–US4 + phần buộc làm tay
├── contracts/           # Phase 1
│   ├── method-channel.md    # channel/method, DTO, mã lỗi, khai báo manifest/plist
│   └── repositories.md      # chữ ký repository + use case
├── checklists/
│   └── requirements.md  # (đã có từ /speckit-specify)
└── tasks.md             # (/speckit-tasks — CHƯA tạo ở bước này)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── constants/                          # MỚI (thư mục chưa tồn tại)
│   │   └── channel_methods.dart                # tên channel + method (Principle VIII)
│   ├── wallpaper/                          # MỚI — kho dùng chung (giống core/catalog, core/favorites)
│   │   ├── wallpaper_file.dart                 # model {wallpaperId, path, sizeBytes}
│   │   ├── download_progress.dart              # model {received, total, fraction}
│   │   ├── wallpaper_download_repository.dart  # interface + impl (Dio riêng, không interceptor)
│   │   ├── wallpaper_platform_service.dart     # interface + impl (bọc MethodChannel, map lỗi)
│   │   └── set_wallpaper_use_case.dart         # điều phối tải → ghi lịch sử → đặt/lưu
│   └── error/
│       └── failure_l10n.dart               # SỬA — thêm 4 nhánh lỗi native/tải
└── features/
    ├── set_wallpaper/presentation/         # MỚI
    │   ├── cubit/set_wallpaper_cubit.dart
    │   ├── cubit/set_wallpaper_state.dart      # sealed 4-state + biến thể có tiền tố
    │   └── widgets/set_wallpaper_sheet.dart    # bám SetWallpaper.jsx
    ├── paywall/presentation/pages/         # MỚI — bản TẠM cho US4
    │   └── paywall_placeholder_page.dart       # điểm đến khi bị chặn 402; thiết kế thật ở MO-006
    └── wallpaper_detail/presentation/pages/
        └── wallpaper_detail_page.dart      # SỬA — 2 nút "Tải xuống"/"Đặt làm hình nền" mở sheet (bỏ `soon`)

lib/core/router/app_routes.dart              # SỬA — thêm AppRoutes.paywall
lib/app/router/app_router.dart               # SỬA — entry go_router cho Paywall (pushed, phủ shell)

android/app/src/main/
├── kotlin/com/livecanvas/livecanvas/
│   ├── MainActivity.kt                     # SỬA — đăng ký MethodChannel handler
│   ├── WallpaperChannelHandler.kt          # MỚI — setLiveWallpaper / isLiveWallpaperSupported
│   └── LiveCanvasWallpaperService.kt       # MỚI — WallpaperService + MediaPlayer
├── res/xml/livecanvas_wallpaper.xml        # MỚI — meta-data của wallpaper service
└── AndroidManifest.xml                     # SỬA — khai <service> + BIND_WALLPAPER

ios/Runner/
├── AppDelegate.swift                       # SỬA — đăng ký MethodChannel handler
├── WallpaperChannelHandler.swift           # MỚI — saveVideoToPhotos (PHPhotoLibrary)
└── Info.plist                              # SỬA — NSPhotoLibraryAddUsageDescription

lib/l10n/arb/{app_vi,app_en}.arb             # SỬA — chuỗi sheet + 4 thông điệp lỗi
pubspec.yaml                                 # SỬA — path_provider ^2.1.6
```

**Structure Decision**: giữ nguyên khuôn feature-first đã dùng từ MO-003/MO-004 — thứ gì nhiều feature dùng chung thì nằm ở `lib/core/<miền>/`, thứ gì thuộc về một màn thì nằm ở `lib/features/<feature>/presentation/`. MO-005 đặt tải + cầu nối native ở `core/wallpaper/` vì Collection Detail ("Tải tất cả", MO-006) sẽ dùng lại đúng những lớp này; chỉ sheet và cubit của nó là thuần trình bày nên ở `features/set_wallpaper/`.

## Complexity Tracking

| Deviation | Vì sao cần | Đã duyệt |
|---|---|---|
| **State dùng native sealed class + Equatable thay `@freezed`** (Principle III yêu cầu `@freezed`) | `freezed` stable ép `analyzer <11` → phá `lean_builder` (DI, cần analyzer 12). Kế thừa nguyên quyết định MO-003 (research R1). | ✅ Duyệt ở MO-003 bởi project lead; đề xuất PATCH constitution III ("`@freezed` hoặc native sealed class") vẫn treo. |
| **Màn Lịch sử tải vẫn là bản tối giản, chưa có thiết kế** (Principle VI) | Đã rà lại toàn bộ bàn giao thiết kế ở bước plan này: **không có** bản dựng nào cho màn đó (R10). Không có nguồn thiết kế thì "thiết kế lại" chỉ là bịa. | Kế thừa deviation đã ghi nhận của MO-004; vẫn treo cho tới khi có bàn giao thật. |

Không có complexity nào khác vượt hiến pháp. Đáng chú ý theo hướng ngược lại: `SetWallpaperUseCase` **tăng** một lớp trừu tượng nhưng là để **tuân thủ** Principle XI (cấm repository gọi repository), không phải để lách.

## Phase 0 — Research

Xem [research.md](research.md): (R1) cơ chế đặt live wallpaper Android, (R2) tải file có tiến trình/huỷ bằng Dio instance riêng, (R3) lưu Photos iOS bằng Swift thuần thay vì package `gal`, (R4) vị trí + vòng đời file gốc (`path_provider`), (R5) `ComponentName` theo flavor, (R6) ai lưu đường dẫn để sống qua reboot, (R7) hình dạng state của sheet, (R8) chiến lược test phần native, (R9) đặt điểm ghi lịch sử tải ở đâu, (R10) có thay màn Lịch sử tải không.

## Phase 1 — Design & Contracts

- [data-model.md](data-model.md): entity `WallpaperFile`/`DownloadProgress`, DTO qua channel, bảng map mã lỗi native → `AppFailure`, dữ liệu phía Kotlin, state machine của sheet, 8 bất biến cần test bảo vệ (INV-1..INV-8).
- [contracts/method-channel.md](contracts/method-channel.md): 3 method của `com.livecanvas/wallpaper`, tham số/trả về, mã lỗi, và khai báo bắt buộc trong `AndroidManifest.xml` + `Info.plist`.
- [contracts/repositories.md](contracts/repositories.md): chữ ký `WallpaperDownloadRepository`, `WallpaperPlatformService`, `SetWallpaperUseCase` + ràng buộc thực thi; bảng tái dùng từ MO-003/MO-004.
- [quickstart.md](quickstart.md): kịch bản nghiệm thu US1–US4, bảng kịch bản lỗi, cổng CI, và **7 hạng mục buộc nghiệm thu tay** (M1–M7).
