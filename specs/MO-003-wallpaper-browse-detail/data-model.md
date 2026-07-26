# Data Model — MO-003

**Nguồn sự thật**: model dữ liệu là **generated** từ `contracts/openapi.yaml` v0.3.2 trong package `livecanvas_api` — KHÔNG hand-write (Principle I). Phần dưới liệt kê (a) model contract dùng lại, (b) model bao/nội bộ mới, (c) state models `freezed` mỗi Cubit, (d) tầng `Result`/`AppFailure`.

---

## A. Model contract dùng lại (từ `package:livecanvas_api`)

| Model | Field dùng ở MO-003 | Ghi chú |
|---|---|---|
| `Wallpaper` | `id, title, thumbnailUrl, previewVideoUrl, isPremium, orientation, tags[], category, collections[], durationSeconds, resolution, fileSizeBytes` | Field nullable (generated). `collections` **chỉ đảm bảo populate ở `GET /wallpapers/{id}`**; ở list có thể rỗng. |
| `Tag` | `id, slug, name, wallpaperCount` | Phần tử `[0]` là thẻ ảo "Tất cả" (`id:0, slug:"all"`) do API sinh. |
| `Category` | `slug, name` | Không dùng làm bộ lọc ở MO-003 (Clarify Q2 — chỉ tags). |
| `Collection` | `id, slug, title, author, description, coverUrl, accentColor, isPremium, wallpaperCount` | List tab Bộ sưu tập. `accentColor` dùng cho hero. |
| `CollectionDetail` | `Collection` + `items: List<Wallpaper>` | `GET /collections/{id}` — items nhúng sẵn đúng thứ tự, không phân trang. |
| `WallpaperCursorPage` | `items[], nextCursor, hasMore` | Trả từ `GET /wallpapers`. |
| `CollectionRef` | `id, slug, title, coverUrl, isPremium` | Trong `Wallpaper.collections` — dựng link "Từ bộ sưu tập ·…" ở Detail. |

**Không tạo model DTO trùng lặp** cho các resource này (Principle XIV). UI đọc trực tiếp; xử lý nullable tại điểm dùng.

---

## B. Model bao/nội bộ (mới, `lib/core/catalog/models/`)

### `WallpaperPage`
Bao mỏng quanh `WallpaperCursorPage` để tầng domain không lệ thuộc kiểu generated ở API bề mặt Cubit (tuỳ chọn; nếu YAGNI có thể dùng thẳng `WallpaperCursorPage`).
- `items: List<Wallpaper>`
- `nextCursor: String?`
- `hasMore: bool`

> Quyết định: dùng thẳng `WallpaperCursorPage` nếu không phát sinh nhu cầu biến đổi → `WallpaperPage` chỉ tạo khi cần gộp/normalize. Mặc định tối giản: **dùng `WallpaperCursorPage` trực tiếp**, bỏ `WallpaperPage` trừ khi cần.

---

## C. `Result<T>` + `AppFailure` (`lib/core/domain/`, Principle IV)

### `Result<T>` (sealed, thủ công — không codegen)
```
sealed class Result<T>
  Ok<T>(T value)
  Err<T>(AppFailure failure)
  R fold<R>(R Function(T) onOk, R Function(AppFailure) onErr)
```

### `AppFailure` (sealed, thủ công)
Biến thể **dùng ở MO-003**: `network`, `timeout`, `serverUnavailable`, `notFound`, `validation`, `unknown({String? message, Object? error})`.
Khai báo sẵn (cho spec sau, không dùng runtime ở MO-003): `entitlementRequired`, `receiptInvalid`, `receiptConflict`, `storeUnavailable`, `downloadFailed`, `fileWriteFailed`, `wallpaperSetFailed`, `platformUnsupported`.

**Mapping** (`dio_error_mapper.dart`): xem bảng R5 trong [research.md](research.md).
**Localize** (`failure_l10n.dart`): mỗi biến thể → key ARB (vd `failureNetwork`, `failureTimeout`, `failureNotFound`, `failureServer`, `failureUnknown`).

---

## D. State models mỗi Cubit (native **sealed class + Equatable**, Principle III — xem R1 deviation)

Mẫu 4-trạng-thái: `sealed class XState extends Equatable` với subclass `XInitial | XLoading | XLoaded(...) | XError(AppFailure)`; biến thể prefix cho pagination nằm **trong** `XLoaded` bằng cờ (`isLoadingMore`, `loadMoreFailed`) + `copyWith`. Value equality qua `props` (equatable 2.1.0). KHÔNG dùng `@freezed` (xung đột analyzer với lean_builder — research R1).

### `BrowseState` (feature: browse — US1)
- `initial`
- `loading` — tải trang đầu (skeleton toàn màn)
- `loaded({ List<Wallpaper> items, List<Tag> tags, int selectedTagId, String? nextCursor, bool hasMore, bool isLoadingMore, bool loadMoreFailed })`
- `error(AppFailure failure)` — lỗi trang đầu
> `tags` tải cùng lần đầu (`tagsGet`); `selectedTagId` mặc định `0` ("Tất cả"). Đổi tag → quay `loading`, phân trang lại.

### `SearchState` (feature: search — US4)
- `initial` — chưa nhập / <2 ký tự (hiện gợi ý)
- `loading` — đang tìm (skeleton)
- `loaded({ String query, List<Wallpaper> items, String? nextCursor, bool hasMore, bool isLoadingMore, bool loadMoreFailed })`
- `empty(String query)` — không kết quả (EmptyState)
- `error(AppFailure failure)`
> Cubit giữ `Timer? _debounce` + `int _seq` (R6). `empty` là biến thể hợp lệ (không dùng `success/failed`).

### `CollectionsState` (feature: collections — US3 list)
- `initial · loading · loaded(List<Collection> items) · empty · error(AppFailure)`
> Không phân trang (`collectionsGet`). Pull-to-refresh → `loading` lại.

### `CollectionDetailState` (feature: collection_detail — US3 detail)
- `initial · loading · loaded(CollectionDetail collection) · error(AppFailure)`
> `notFound` (404) → error với `AppFailure.notFound` → UI "không tìm thấy".

### `WallpaperDetailState` (feature: wallpaper_detail — US2)
- `initial · loading · loaded(Wallpaper wallpaper) · error(AppFailure)`
> Luôn gọi `wallpapersIdGet(id)` (để có `collections` đầy đủ). `notFound` → "không tìm thấy".

---

## E. Repository (interface + impl, `lib/core/catalog/`)

| Repository | Method | Trả về | Endpoint |
|---|---|---|---|
| `WallpaperRepository` | `list({cursor, limit, tags, search})` | `Future<Result<WallpaperCursorPage>>` | `GET /wallpapers` |
| | `getById(int id)` | `Future<Result<Wallpaper>>` | `GET /wallpapers/{id}` |
| `TagRepository` | `list()` | `Future<Result<List<Tag>>>` | `GET /tags` |
| `CollectionRepository` | `list()` | `Future<Result<List<Collection>>>` | `GET /collections` |
| | `getById(int id)` | `Future<Result<CollectionDetail>>` | `GET /collections/{id}` |

- `list()` của Wallpaper: chọn "Tất cả" (`selectedTagId==0`) → **không** truyền `tags`; tag khác → truyền `slug`. `search` chỉ set khi ≥2 ký tự.
- Impl bọc `try/catch DioException` → `Result.err(mapper(e))`; thành công → `Result.ok(resp.data!)`.
- DI: `@LazySingleton(as: WallpaperRepository)` v.v.; `PublicApi` cung cấp qua `catalog_module.dart` (`@module` tạo `LivecanvasApi(dio: getIt<Dio>()).getPublicApi()`), tái dùng `Dio` + `AppKeyInterceptor` sẵn có từ `NetworkModule`.

---

## Quan hệ & ràng buộc (từ requirements)

- `Wallpaper.collections` (chỉ ở detail) → mỗi `CollectionRef` render 1 link → `context.push('/collection/{id}')` (FR-011).
- `selectedTagId==0` ⇒ bỏ param `tags`; `slug=="all"` không bao giờ gửi (FR-006, contract reserved).
- `is_premium` (Wallpaper & Collection) ⇒ chỉ hiển thị khoá (badge/nút), KHÔNG mở quyền (FR-012/017, Principle V).
- Video: list phát `previewVideoUrl` (muted-loop), poster `thumbnailUrl`; file gốc KHÔNG tải (Principle II).
- Aura: `auraColor` trích từ `thumbnailUrl` qua `palette_generator`; fallback accent token (R4).
