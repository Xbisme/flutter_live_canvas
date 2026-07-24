# Consumed Endpoints — MO-003

MO-003 **chỉ tiêu thụ** các endpoint public đọc dữ liệu của contract v0.3.2 qua `PublicApi` (package `livecanvas_api`). Không thêm/sửa endpoint (Principle I — muốn đổi phải sửa `docs/screen-inventory.md` → `openapi.yaml` → sync 2 repo). Header `X-App-Key` do `AppKeyInterceptor` (MO-001) tự gắn.

| Màn / User Story | `PublicApi` method | Endpoint | Query/Path dùng | Trả về | FR |
|---|---|---|---|---|---|
| Browse — grid (US1) | `wallpapersGet(...)` | `GET /wallpapers` | `cursor?`, `limit`, `tags?` (bỏ khi "Tất cả") | `WallpaperCursorPage` | FR-001..006, 031 |
| Browse — tag chips (US1) | `tagsGet()` | `GET /tags` | — | `List<Tag>` (thẻ `[0]`="Tất cả") | FR-005 |
| Search — kết quả (US4) | `wallpapersGet(...)` | `GET /wallpapers` | `search` (≥2 ký tự), `cursor?`, `limit` | `WallpaperCursorPage` | FR-019..021 |
| Wallpaper Detail (US2) | `wallpapersIdGet(id)` | `GET /wallpapers/{id}` | path `id` | `Wallpaper` (`collections` đầy đủ) | FR-009..014 |
| Collections — list (US3) | `collectionsGet()` | `GET /collections` | — | `List<Collection>` | FR-015 |
| Collection Detail (US3) | `collectionsIdGet(id)` | `GET /collections/{id}` | path `id` | `CollectionDetail` (`items` nhúng) | FR-016..018 |

## KHÔNG dùng ở MO-003 (spec sau)

| Endpoint | Lý do hoãn | Spec |
|---|---|---|
| `GET /wallpapers/{id}/download-url` | Tải/đặt file gốc + gate entitlement | MO-005/MO-006 |
| `POST /wallpapers/batch` | Favorites local | MO-004 |
| `POST /iap/verify-receipt`, `GET /iap/subscription-status` | IAP thật | MO-006 |
| `GET /categories` | Không dùng bộ lọc category (Clarify Q2) | — |

## Lỗi → `AppFailure` (áp cho mọi call trên)

| HTTP / error.code | `AppFailure` | UI |
|---|---|---|
| timeout (connect/receive/send) | `timeout` | lỗi + thử lại |
| connectionError / SocketException | `network` | lỗi + thử lại |
| 404 `NOT_FOUND` / `WALLPAPER_NOT_FOUND` | `notFound` | "không tìm thấy" (Detail/Collection Detail) |
| 400 `VALIDATION_ERROR` (cursor hỏng) | `validation` | lỗi trang + thử lại |
| 500 `SERVER_ERROR` / 503 | `serverUnavailable` | lỗi + thử lại |
| 401 `INVALID_APP_KEY` | `unknown` | lỗi chung (lỗi cấu hình, không nên xảy ra) |

Chi tiết mapping: [research.md](../research.md) R5 · state: [data-model.md](../data-model.md).

## Ghi chú entitlement (Principle V)

`is_premium` ở `Wallpaper`/`Collection`/`CollectionDetail` chỉ dùng **hiển thị** badge PRO / nút "Mở khoá"/"Tải tất cả" ở trạng thái khoá. MO-003 KHÔNG gọi `download-url`, KHÔNG suy luận entitlement client-side.
