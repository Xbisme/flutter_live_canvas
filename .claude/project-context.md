# LiveCanvas Mobile — Project Context

> Repo: `livecanvas-mobile` (Flutter — iOS/Android/tablet 1 codebase)
> Repo liên quan: `livecanvas-backend` (Django, độc lập hoàn toàn — đồng bộ qua `contracts/openapi.yaml` + `.claude/api-context.md`, copy tay giữa 2 repo)
>
> Last updated: 2026-07-23 (MO-001 đã implement trên branch `MO-001-project-bootstrap` — chờ PR/merge · contract v0.3.2)
> **Mục đích**: Snapshot tối thiểu để bắt đầu 1 session làm việc trên repo mobile.
>
> **Đọc file nào khi nào**:
> - Bắt đầu session mới → file này + `docs/PRD.md` + `CLAUDE.md` (khi có).
> - Chuẩn bị họp spec mới → file này + [`sdd-roadmap.md`](sdd-roadmap.md).
> - **Trước khi đổi/thêm bất kỳ API nào** → [`../docs/screen-inventory.md`](../docs/screen-inventory.md) TRƯỚC TIÊN (màn hình cần gì quyết định API, không phải ngược lại), rồi mới tới `api-context.md`.
> - Cần biết chi tiết từng endpoint (header/body/response) → [`api-context.md`](api-context.md) + [`openapi.yaml`](openapi.yaml) — **contract version hiện tại: `v0.3.2`**.
> - Cần hiểu vì sao spec X ra đời → [`decisions/`](decisions/).
> - Cần biết spec nào ship khi nào → [`changelog.md`](changelog.md).

## Snapshot

- **Vai trò repo này**: App Flutter hình nền động LiveCanvas — duyệt/tải wallpaper, set làm hình nền máy, gói Premium qua IAP.
- **Platforms**: Android (live wallpaper trực tiếp qua `WallpaperService`) · iOS/iPadOS (preview + hướng dẫn set qua Shortcuts, do Apple không cho set video wallpaper qua API công khai) · Tablet responsive.
- **Stack**: Flutter, API client Dart generate từ `contracts/openapi.yaml` (`openapi-generator-cli -g dart-dio`).
- **Không có hệ thống user/account** — favorite/lịch sử lưu local; entitlement premium xác định qua `transaction_id` gửi lên backend verify, không qua login.
- **IAP**: `in_app_purchase` (tự viết verify-receipt, gọi API backend `/iap/verify-receipt` — không dùng RevenueCat, quyết định chủ động để học full flow).
- **Communication**: Tiếng Việt giữa user + Claude · Tiếng Anh cho code/comment/commit.

## Current Focus

- **Trạng thái**: MO-001 (bootstrap) đã implement xong trên branch `MO-001-project-bootstrap`, 4 quality gate xanh local — chờ PR/merge. Backend đã merge BE-001→BE-003 (Core Content API thật, có seed data).
- **Kết quả MO-001 + deviation đáng nhớ** (chi tiết: `specs/MO-001-project-bootstrap/`):
  - Project very_good_cli, org `com.livecanvas`, ĐÚNG 2 flavor (staging + scheme Runner mặc định đã gỡ cả iOS/Android/VSCode launch).
  - `AppConfig` per-flavor: development → backend local (`localhost:8000` / Android emulator `10.0.2.2:8000`, dev key `dev-app-key` commit); production → placeholder URL + `--dart-define=APP_KEY`.
  - Client dart-dio + json_serializable sinh vào **`packages/livecanvas_api`** (path package, KHÔNG phải `lib/core/api` như spec gốc — dart-dio sinh package độc lập, không nhét được vào `lib/`); regenerate: `scripts/generate_api.sh` (cần Java; script tự bump sdk constraint ≥3.8 cho null-aware elements).
  - **Version pins do xung khắc solver** (KHÔNG tự ý nâng): `injectable 3.0.0` + `injectable_generator 3.0.2` (codegen bằng **lean_builder**, không phải build_runner; lệnh: `dart run lean_builder build`) + `bloc_lint 0.4.1` (0.4.2 xung khắc `_fe_analyzer_shared`); `bloc_tools` là CLI global, không để trong dev_deps (gây xung khắc).
  - ⚠️ **`phosphor_flutter` 2.1.0 vỡ với Flutter 3.44** (`IconData` thành final class) — đã gỡ khỏi MO-001; PHẢI chốt hướng xử lý (chờ bản vá / fork / thay icon set) trước khi làm UI thật ở MO-002.
  - i18n: `app_vi.arb` là template mặc định; CI 4 gate tự viết ở `.github/workflows/main.yaml`.
- **Đã có sẵn**:
  - `docs/screen-inventory.md` — danh sách màn hình + data cần, làm nền cho contract (đã review, 1 giả định còn treo: Onboarding không cần data riêng).
  - `.claude/openapi.yaml` v0.3.2 + `.claude/api-context.md` v0.3.2 (synced verbatim từ backend) — cursor-based pagination, resource `Tag` curated (+ **thẻ ảo "All"** `{id:0, slug:"all"}` ở đầu `GET /tags`, reserved slug), `POST /wallpapers/batch` cho Favorites, resource `Collection` curated (tab "Bộ sưu tập" + màn Collection Detail) qua `GET /collections`, `GET /collections/{id}`.
- **Spec tiếp theo**: `MO-001-project-bootstrap` — tạo project Flutter bằng `very_good_cli` với **đúng 2 flavor `development` + `production`** (gỡ `staging` mà very_good_cli sinh mặc định), gen Dart client từ `openapi.yaml`. Sau đó mới tới MO-002 (foundation/design system). Backend đã merge BE-002 và implement BE-003 (Core Content API thật) — điểm đồng bộ MO-003 sẽ có API thật để chuyển khỏi mock.
- **Quyết định kỹ thuật đã chốt** (ảnh hưởng UI/state management):
  - Bootstrap: dùng `very_good_cli` tạo project; **đúng 2 flavor `development` + `production`** — KHÔNG có `staging` hay flavor nào khác (gỡ `staging` mà very_good_cli sinh mặc định). Base URL backend lấy theo config từng flavor, không hardcode. Chi tiết + toàn bộ nguyên tắc: [`../.specify/memory/constitution.md`](../.specify/memory/constitution.md) (v1.0.0, Principle XII).
  - Pagination: cursor-based — dùng `ListView.builder`/`GridView.builder` lazy build, load trang tiếp khi gần cuối scroll, **dispose `VideoPlayerController` của item ngoài viewport** để tránh tràn RAM (đây là phần client phải tự làm, server chỉ giải quyết 1 nửa).
  - Favorites: chỉ lưu local mảng ID, mỗi lần mở màn gọi `POST /wallpapers/batch` lấy data mới nhất (không cache full data).
  - Tag: hiển thị dạng filter chips, danh sách lấy từ `GET /tags` (curated, không phân trang). Phần tử `[0]` là **thẻ ảo "All"** (`id:0, slug:"all"`) do API sinh → render làm chip mặc định; chọn "All" = gọi `GET /wallpapers` không truyền `tags` (toàn bộ, mới→cũ). Không gửi `tags=all` lên (hoặc nếu gửi, backend bỏ qua).
  - Collection (Bộ sưu tập): tab riêng list cover card từ `GET /collections` (không phân trang); màn Collection Detail gọi `GET /collections/{id}` (nhúng sẵn `items` đúng thứ tự, không cần batch). Wallpaper Detail đọc `wallpaper.collections` để hiện link "Từ bộ sưu tập ·…". Bộ premium: chỉ hiện nút "Mở khoá"; entitlement thật vẫn theo `download-url` từng file, "Tải tất cả" = lặp gọi download-url.
- **Chưa quyết định**:
  - Tên sản phẩm thật + bundle ID (iOS) / applicationId (Android).
  - Design system/theme cụ thể (chưa có branding.md).
  - Base URL backend cho từng environment (dev/staging/prod) — phụ thuộc `livecanvas-backend` BE-001.

## Repo Layout

```
.claude/
├── project-context.md      # ← you are here
├── sdd-roadmap.md           # spec planning (chỉ track MO-*)
├── dev-workflow.md          # quy trình speckit + Contract Sync với repo backend
├── api-context.md           # chi tiết header/body/response từng endpoint
├── changelog.md
└── decisions/

contracts/
└── openapi.yaml              # bản sao — đồng bộ tay với repo backend khi đổi API

lib/
├── core/                     # DI, Result<T>, AppFailure, API client (generated)
└── features/
    ├── browse/                 # List/detail/search wallpaper
    ├── favorites/               # Local favorites
    ├── wallpaper_setter/         # Android native + iOS Shortcuts flow
    └── paywall/                  # IAP + entitlement UI
ios/
android/
specs/                         # MO-NNN-*/ folders (speckit output)
docs/
├── PRD.md                     # product requirements (phần liên quan mobile)
└── screen-inventory.md        # màn hình + data cần — nền tảng của contract, đọc TRƯỚC api-context.md
pubspec.yaml
```

## Key Documents

| File | Vai trò |
|---|---|
| [`../docs/screen-inventory.md`](../docs/screen-inventory.md) | Màn hình cần gì → đọc TRƯỚC khi sửa API |
| [`api-context.md`](api-context.md) | Chi tiết endpoint: header, request body, response thành công/lỗi |
| [`../contracts/openapi.yaml`](../contracts/openapi.yaml) | API contract máy-đọc — dùng generate Dart client |
| [`sdd-roadmap.md`](sdd-roadmap.md) | Spec planning track mobile |
| [`dev-workflow.md`](dev-workflow.md) | Quy trình speckit + Contract Sync giữa 2 repo |
| [`changelog.md`](changelog.md) | Ship history (append-only) |
