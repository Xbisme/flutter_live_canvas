# Research — MO-003 Wallpaper Browse, Collections & Detail

**Date**: 2026-07-24 · Contract: v0.3.2 · Nền tảng: MO-002 merged.

Mọi version tra trực tiếp pub.dev tại plan time (Principle XVI). Tất cả NEEDS CLARIFICATION của Technical Context được giải ở đây.

---

## R1 — State models: Native Dart 3 sealed classes (KHÔNG freezed) ⚠️ REVISED khi implement

**Quyết định cuối** (2026-07-24, đã chốt với project lead): dùng **sealed class Dart 3 thủ công** cho state Cubit (immutable, `initial/loading/loaded/error`). **KHÔNG dùng `freezed`, KHÔNG `build_runner`.** Codegen duy nhất của app vẫn là `dart run lean_builder build` cho DI (injectable) — như MO-001/MO-002.

**Vì sao đảo quyết định ban đầu (freezed)**: khi thử cài freezed đã lộ **xung đột analyzer bất khả giải** với DI codegen hiện tại:
- `lean_builder 0.1.10` (do `injectable_generator 3.0.2` pin) **chỉ chạy được với `analyzer 12.x`** (dùng API `LibraryIdentifier.name.tokens`; vỡ AOT trên analyzer 10.x/13.x).
- `freezed 3.2.5` **stable** yêu cầu `analyzer >=9 <11` → ép analyzer xuống 10.x → **vỡ lean_builder** → không sinh được `injection.config.dart` → app không build.
- Bản freezed DUY NHẤT khớp `analyzer ^12` là **`3.2.6-dev.1` (pre-release)** — lệch Principle XVI ("prefer stable").
- Nâng `injectable_generator 3.1.1` (→ `lean_builder 1.2.0`, analyzer 13) thì freezed lại không có bản nào khớp analyzer 13. → **không tổ hợp stable nào cho freezed + DI codegen**.

**Kết luận**: freezed ở đây buộc phải pre-release; project lead chọn **native sealed classes** (ổn định hơn pre-release, bỏ hẳn build_runner → hết xung đột analyzer vĩnh viễn, all-stable). Giữ đúng **tinh thần Principle III** (state immutable + sealed 4-trạng-thái) — chỉ khác **cơ chế** (không `@freezed`).

**Deviation Principle III** (đã được project lead duyệt — Governance): Constitution III ghi "state MUST be `@freezed` sealed classes". MO-003 dùng sealed class Dart 3 thủ công thay `@freezed` vì lý do tương thích toolchain ở trên. Đề xuất PATCH constitution: nới "`@freezed` **hoặc** native sealed class immutable". Ghi ở `plan.md` §Complexity Tracking.

**Chi tiết triển khai sealed state**: mỗi state là `sealed class XState extends Equatable` + các subclass (`XInitial`, `XLoading`, `XLoaded`, `XError`); `XLoaded` immutable (`final` fields) + `copyWith` tay cho pagination (`isLoadingMore`...). **Value equality qua `equatable 2.1.0`** (`props` liệt kê field) để `BlocBuilder` không rebuild thừa — cặp đôi chuẩn của bloc, gói thuần Dart (không đụng analyzer, không codegen), thay cho override `==`/`hashCode` tay (ít boilerplate, tránh bug). Đây là dependency duy nhất thêm cho state (justify Principle XIV: chuẩn hệ sinh thái bloc, thay codegen freezed).

**Alternatives rejected**:
- *freezed 3.2.6-dev.1 (pre-release)*: giữ `@freezed` đúng nguyên văn nhưng dùng pre-release (XVI); project lead từ chối.
- *freezed 3.2.5 stable*: **bất khả thi** — phá lean_builder (đã chứng minh).
- *Nâng DI stack lên analyzer 13*: freezed không có bản khớp; bỏ.

---

## R2 — Vòng đời `VideoPlayerController` trong grid (Principle II — NON-NEGOTIABLE)

**Quyết định**: `video_player 2.13.0`. Mỗi tile bọc bởi widget `VideoPreview` dùng **`visibility_detector 0.4.0+2`**: khi `visibleFraction >= 0.6` → khởi tạo + `play()` (muted, loop); khi rời viewport (`visibleFraction == 0`) → `pause()` + `dispose()` controller, chuyển về hiển thị `thumbnail_url` tĩnh. Controller **chỉ tồn tại cho tile đang/gần hiện** → số controller đồng thời bị chặn tự nhiên bởi số tile visible (SC-002).

**Rationale**: `visibility_detector` là cách tiêu chuẩn, chính xác hơn tính toán scroll offset thủ công, và bao được cả trường hợp tab switch / route push che grid. `video_player 2.13.0` yêu cầu Flutter ≥3.44 — khớp SDK dự án.

**Chi tiết triển khai**:
- Tile mặc định hiển thị `thumbnail_url` (poster); video fade-in khi controller `initialized`.
- Lỗi tải 1 video → giữ poster (fallback), không sập grid (edge case spec).
- Detail dùng cùng `VideoPreview` nhưng luôn-visible, kích thước lớn.
- Nhớ `dispose()` trong `State.dispose()` và khi widget bị recycle bởi `GridView.builder`.

**Alternatives rejected**: `chewie` (thừa UI controls, không cần cho preview muted-loop); tự viết `VisibilityDetector` bằng `Scrollable` metrics (dễ sai ở edge, tái phát minh).

---

## R3 — Skeleton shimmer điều khiển-bởi-state (FR-026..030, FR-029)

**Quyết định**: `shimmer 3.0.0`. Dựng shared widget trong `lib/core/widgets/feedback/skeleton/`: `ShimmerBox` (khối bo góc theo token, bọc `Shimmer.fromColors` với 2 tông từ `AppColors`), và các layout skeleton khớp nội dung: `WallpaperGridSkeleton` (đúng `Breakpoints.gridColumns`, tỉ lệ `AppSpacing.wallRatio`), `CollectionListSkeleton`, `WallpaperDetailSkeleton`. Render **có điều kiện theo state Cubit**: `state.isLoading → skeleton`, `loaded → nội dung thật`. KHÔNG `Future.delayed`, KHÔNG thời lượng tối thiểu — chuyển ngay khi state đổi (FR-029).

**Rationale**: `shimmer 3.0.0` tuy phát hành 2023 nhưng ổn định, phụ thuộc tối thiểu (`>=1.9.1 flutter`), API `Shimmer.fromColors` đủ. Màu shimmer lấy từ token → khớp dark aurora (Principle VI, FR-028). Vì shimmer bind vào `BlocBuilder` state, tính "dừng theo kết quả" là hệ quả tự nhiên của kiến trúc 4-state.

**Alternatives rejected**: `skeletonizer` (tự động skeleton hoá — mạnh nhưng thêm phụ thuộc lớn, khó ép "khớp bố cục chính xác" theo token, YAGNI); tự vẽ gradient `AnimatedBuilder` (nhiều mã hơn, không lợi rõ so với shimmer).

**Guard test**: widget test khẳng định khi Cubit ở `loading` có `ShimmerBox`, và ngay khi phát `loaded` (không bơm delay) skeleton biến mất — chống hồi quy timer giả tạo.

---

## R4 — Aura hue từ ảnh thật (`palette_generator`, defer từ MO-002)

**Quyết định**: `palette_generator 0.3.3+7`. Trích màu chủ đạo từ `thumbnail_url` qua `PaletteGenerator.fromImageProvider(NetworkImage(thumbnailUrl))`, lấy `dominantColor`/`vibrantColor` làm `auraColor` truyền vào `WallpaperCard` (đã có tham số `auraColor`). Cache theo wallpaper id trong Cubit/tile-state để không tính lại mỗi rebuild. Fallback: nếu trích lỗi/timeout → accent mặc định từ token (`AppColors` accent) — spec assumption.

**Rationale**: `WallpaperCard` MO-002 đã nhận `auraColor` như tham số → chỉ cần nguồn màu. `palette_generator` (Flutter team) là chuẩn; `fromImageProvider` chạy async, gọi khi tile xuất hiện. Không chặn render (dùng accent mặc định tới khi có màu).

**Alternatives rejected**: trích màu server-side (`accent_color` chỉ có ở `Collection`, không có ở `Wallpaper` — contract không đổi được trong MO-003, xem note dưới); hardcode accent (mất hiệu ứng aura theo ảnh — kém trung thực prototype).

**Note contract**: `Wallpaper` KHÔNG có `accent_color` (chỉ `Collection` có). MO-003 tự trích client-side — KHÔNG thêm field client-only (Principle I). `Collection.accent_color` dùng thẳng cho hero Collection Detail.

---

## R5 — `Result<T>` + `AppFailure` (Principle IV — dựng lần đầu)

**Quyết định**: `lib/core/domain/result.dart`: `sealed class Result<T>` với `Ok<T>(value)` và `Err<T>(failure)` + `fold(onOk, onErr)`. `lib/core/domain/app_failure.dart`: `sealed class AppFailure` liệt kê biến thể theo Constitution IV (subset dùng ở MO-003: `network`, `timeout`, `serverUnavailable`, `notFound`, `validation`, `unknown`; các biến thể IAP/native khai báo sẵn cho spec sau). `lib/core/error/dio_error_mapper.dart` map `DioException` (theo `type` + HTTP status + `error.code` JSON trong body) → `AppFailure`. `lib/core/error/failure_l10n.dart`: `AppFailure → context.l10n` message.

**Rationale**: Constitution bắt buộc. Repository `try/catch` `DioException` → trả `Result.err(mapper(e))`; Cubit `.fold()`. Không dùng `dartz`/`fpdart` (Principle XIV — sealed class Dart 3 đủ, tránh thêm dep). `AppFailure` có thể là `@freezed` union hoặc sealed class thủ công — chọn **sealed class thủ công** cho `Result`/`AppFailure` (foundation, ít thay đổi, tránh phụ thuộc codegen ở tầng lõi); state Cubit mới dùng freezed.

**Alternatives rejected**: `dartz.Either` (thêm dep, cú pháp lạ — YAGNI); ném exception + try/catch ở Cubit (vi phạm Principle IV).

**Mapping bảng** (dùng ở `dio_error_mapper`): `connectionTimeout/receiveTimeout/sendTimeout → timeout`; `connectionError/unknown(SocketException) → network`; HTTP 404 / `NOT_FOUND`/`WALLPAPER_NOT_FOUND` → `notFound`; 400 `VALIDATION_ERROR` (cursor hỏng) → `validation`; 401 `INVALID_APP_KEY` → `unknown` (lỗi cấu hình, không nên xảy ra runtime); 500 `SERVER_ERROR`/503 → `serverUnavailable`; còn lại → `unknown`.

---

## R6 — Debounce + huỷ request cũ cho Search (FR-019/020/021, Clarify Q1)

**Quyết định**: Debounce trong `SearchCubit` bằng `Timer` (dart:async) ~350ms; bỏ qua từ khoá <2 ký tự (giữ `initial`). Chống race bằng **token tăng dần** (`int _requestSeq`): mỗi query tăng seq, khi kết quả về chỉ áp dụng nếu seq còn mới nhất (kết quả cũ bị loại). Không cần `rxdart`.

**Rationale**: `Timer` + seq-guard là mẫu tối giản, không thêm dependency (Principle XIV), test được bằng `bloc_test` + `fakeAsync`. Cùng cơ chế seq-guard tái dùng cho việc đổi tag nhanh ở Browse (edge case spec).

**Alternatives rejected**: `rxdart` `debounceTime/switchMap` (mạnh nhưng thêm dep cho 1 use case); `EventTransformer` của Bloc (dự án ưu tiên Cubit — Principle III).

---

## R7 — Cursor pagination + `loadingMore` + pull-to-refresh (FR-003/008/031, Clarify Q3)

**Quyết định**: `GridView.builder` + `ScrollController`; khi `pixels >= maxScrollExtent - threshold(≈600px)` và `hasMore` và không đang tải → dispatch `loadMore()`. State `loaded` mang `{items, nextCursor, hasMore, isLoadingMore}`; trang kế nối vào `items`, giữ shimmer/placeholder ở cuối grid (`isLoadingMore`). Lỗi trang kế → giữ items, đặt cờ lỗi cục bộ + nút thử lại (không xoá grid). Pull-to-refresh: bọc `RefreshIndicator`, gọi `refresh()` → reset cursor, tải lại trang đầu theo tag/query hiện tại. Đổi tag/query → reset về `loading` (skeleton toàn màn), phân trang lại từ đầu (dùng seq-guard R6).

**Rationale**: Đúng hợp đồng cursor (`next_cursor`/`has_more`) và Principle II (lazy builder). `RefreshIndicator` là chuẩn Material, khớp cả 3 list. Ngưỡng ~600px để prefetch mượt trước khi chạm đáy (SC-002 không giật).

**Alternatives rejected**: `infinite_scroll_pagination` (thêm dep, che mất kiểm soát controller lifecycle cần cho Principle II); offset pagination (vi phạm Principle II/contract).

---

## Tổng hợp dependency thêm (pubspec)

| Package | Version (pub.dev 2026-07-24) | SDK/Flutter | Dùng cho |
|---|---|---|---|
| `video_player` | ^2.13.0 | Dart ^3.12 / Flutter ≥3.44 | Preview video tile + Detail (R2) |
| `visibility_detector` | ^0.4.0+2 | Flutter ≥3.1 | Init/dispose controller theo viewport (R2) |
| `shimmer` | ^3.0.0 | Flutter ≥1.9.1 | Skeleton shimmer (R3) |
| `palette_generator` | ^0.3.3+7 | Dart ^3.4 / Flutter ≥3.22 | Aura hue từ thumbnail (R4) |
| ~~`freezed`/`freezed_annotation`/`build_runner`~~ | — | — | **BỎ** — xung đột analyzer với lean_builder (R1). State dùng native sealed class Dart 3, không codegen. |

Tất cả caret-pinned latest stable; `pubspec.lock` + `ios/Podfile.lock` commit lại sau `flutter pub get` (Principle XVI). `video_player` kéo pod iOS + native Android — chạy `pod install` và verify build 2 nền tảng ở khâu verify.
