# Data Model: Project Bootstrap & Flavors (MO-001)

MO-001 không có domain data (không persistence, không API model viết tay). Chỉ có 2 "entity" hạ tầng:

## AppConfig (lib/core/config/)

Nguồn duy nhất cho mọi giá trị phụ thuộc môi trường (FR-003/FR-003a). Immutable, khởi tạo 1 lần tại entrypoint.

| Field | Type | Rule |
|---|---|---|
| `environment` | enum `AppEnvironment { development, production }` | ĐÚNG 2 giá trị — thêm giá trị mới = amend constitution (Principle XII) |
| `apiBaseUrl` | `String` | development: chọn theo platform lúc runtime — Android `http://10.0.2.2:8000`, còn lại `http://localhost:8000`; production: placeholder `https://api.livecanvas.example` (chú thích TODO chốt domain) |
| `appKey` | `String` | development: dev key commit thẳng; production: `String.fromEnvironment('APP_KEY')` — build release phải truyền `--dart-define=APP_KEY=...`; giá trị rỗng → app vẫn build (backend sẽ trả 401 `INVALID_APP_KEY`) |

Quan hệ: `bootstrap(AppConfig)` nhận config → đăng ký vào DI (get_it) như singleton → Dio interceptor và mọi consumer sau này đọc từ DI, KHÔNG import trực tiếp file config flavor.

**State transitions**: không có — config bất biến suốt vòng đời process; đổi môi trường = chạy entrypoint khác.

## Generated API Client (lib/core/api/ — generated-only)

Artifact sinh từ `contracts/openapi.yaml` v0.3.2 ([research.md](research.md) R3). Không phải code viết tay — mọi model (Wallpaper, Tag, Collection, envelope cursor, error) do generator sở hữu.

| Thuộc tính | Giá trị |
|---|---|
| Generator | `dart-dio` (openapi-generator core 7.14.0, pin trong `openapitools.json`) |
| serializationLibrary | `json_serializable` |
| Nguồn | `contracts/openapi.yaml` — byte-identical với `.claude/openapi.yaml` (FR-006) |
| Vòng đời | contract đổi → chạy `scripts/generate_api.sh` → diff chỉ nằm trong `lib/core/api/` |
| Bất biến | Không sửa tay (Principle I); header `X-App-Key` gắn qua Dio interceptor bên ngoài client, không patch code sinh ra |
