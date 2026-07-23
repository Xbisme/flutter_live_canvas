# Phase 0 Research: Project Bootstrap & Flavors (MO-001)

**Date**: 2026-07-23 · Mọi version dưới đây tra trực tiếp từ nguồn chính thức tại ngày này (Principle XVI — không đoán).

## R1. Toolchain versions (nguồn: pub.dev API, storage.googleapis.com/flutter_infra_release, registry.npmjs.org, search.maven.org)

| Công cụ / Package | Version stable mới nhất (2026-07-23) | Ghi chú |
|---|---|---|
| Flutter SDK | **3.44.7** (Dart 3.12.2) | Máy dev hiện có 3.44.4 tại `~/Documents/develop/flutter` — upgrade khi implement |
| very_good_cli | **1.3.0** | `dart pub global activate very_good_cli` |
| openapi-generator-cli (npm wrapper) | **2.40.0** | pin core generator trong `openapitools.json` |
| openapi-generator core | **7.14.0** | cần Java runtime ≥ 11 (máy dev CHƯA có — prerequisite) |
| flutter_bloc | **9.1.1** | |
| bloc_test | **10.0.0** | dev dep |
| bloc_lint | **0.4.2** | dev dep + `include: package:bloc_lint/recommended.yaml` trong analysis_options |
| bloc_tools (global CLI) | 0.1.0-dev.24 (chỉ có prerelease) | `dart pub global activate bloc_tools` → chạy `bloc lint .` |
| get_it | **9.2.1** | |
| injectable | **3.0.0** | |
| injectable_generator | **3.1.1** | dev dep |
| build_runner | **2.15.2** | dev dep |
| go_router | **17.3.0** | |
| very_good_analysis | **10.3.0** | dev dep |
| phosphor_flutter | **2.1.0** | icon Phosphor |
| intl | **0.20.3** | phải khớp pin của `flutter_localizations` (SDK) — nếu pub solve kêu, hạ theo SDK |
| mocktail | **1.0.5** | dev dep |
| dio | **5.10.0** | transitive của client dart-dio, khai báo tường minh để viết interceptor |
| json_serializable / json_annotation | **6.14.0** / **4.12.0** | cho client dart-dio (xem R3) |

KHÔNG cài ở MO-001 (Principle XIV — cài đúng spec cần): `video_player`, `in_app_purchase`, secure storage, `freezed` (chưa có state class nào ngoài template; thêm ở MO-002).

## R2. Scaffold bằng very_good_cli

- **Decision**: `very_good create flutter_app livecanvas --desc "LiveCanvas — live wallpaper app" --org "com.livecanvas"`, scaffold vào thư mục tạm rồi move nội dung vào repo root (giữ nguyên `.git/`, `.claude/`, `.specify/`, `specs/`, `LICENSE`, merge `README.md`).
- **Rationale**: `very_good create` không scaffold vào thư mục non-empty; repo đã có docs/planning. Template flutter_app sẵn: 3 flavor (development/staging/production), flutter_bloc + bloc_test + mocktail + very_good_analysis, l10n ARB, feature Counter mẫu — khớp phần lớn stack của constitution.
- **Gỡ staging** (Principle XII): xoá `lib/main_staging.dart`; Android — gỡ flavor `staging` trong `android/app/build.gradle`; iOS — xoá scheme `staging` + config `Debug-staging`/`Release-staging`/`Profile-staging` trong `project.pbxproj` và `ios/Flutter/staging.xcconfig` (nếu có). Verify: `grep -ri staging` sạch + chạy được cả 2 flavor còn lại.
- **Alternatives considered**: scaffold tay (`flutter create` + tự dựng flavor) — bị constitution cấm; giữ 3 flavor — vi phạm Principle XII.

## R3. Sinh Dart client từ openapi.yaml

- **Decision**: npm wrapper `@openapitools/openapi-generator-cli@2.40.0` (pin core `7.14.0` trong `openapitools.json`), generator `dart-dio`, `serializationLibrary=json_serializable`, output `lib/core/api/` (thư mục generated-only, có README cảnh báo không sửa tay). Script lặp lại được: `scripts/generate_api.sh` (xoá output cũ → generate → chạy `build_runner` trong package sinh ra nếu cần → `dart format`).
- **Rationale**: dart-dio là generator Dart trưởng thành nhất (constitution chỉ định); `json_serializable` cho code sinh gọn, cùng hệ sinh thái với freezed/json_annotation dùng sau này, tránh kéo built_value/built_collection.
- **Prerequisite**: Java ≥ 11 (openapi-generator chạy trên JVM). Máy dev cá nhân hiện chưa có Java → `brew install temurin` (ghi vào quickstart/README).
- **Contract Sync**: copy `.claude/openapi.yaml` (v0.3.2) → `contracts/openapi.yaml` byte-identical (FR-006) — generate đọc từ `contracts/`.
- **Alternatives considered**: built_value (default) — nặng hơn, style verbose; chạy jar trực tiếp — npm wrapper quản lý version dễ pin hơn cho team.

## R4. Cấu hình môi trường & X-App-Key

- **Decision**: class `AppConfig` thuần Dart trong `lib/core/config/` (`environment`, `apiBaseUrl`, `appKey`); mỗi entrypoint (`main_development.dart` / `main_production.dart`) khởi tạo config của mình rồi gọi `bootstrap(config)`.
  - `development`: `apiBaseUrl` chọn theo platform lúc runtime — Android emulator `http://10.0.2.2:8000`, còn lại `http://localhost:8000`; `appKey` = dev key commit thẳng (đã chốt ở clarify).
  - `production`: `apiBaseUrl` placeholder có chú thích (domain chưa chốt); `appKey` = `String.fromEnvironment('APP_KEY')` — inject `--dart-define=APP_KEY=...` lúc build release, không commit.
- **Rationale**: config theo entrypoint là pattern chuẩn của very_good flavor; không cần flutter_dotenv (thêm dependency + asset bundling vô ích — Principle XIV).
- **Interceptor**: Dio `Interceptor` gắn `X-App-Key` từ `AppConfig` cho mọi request của client sinh ra — đăng ký khi khởi tạo Dio trong DI (`lib/core/di/`), feature code không tự gắn header (FR-005).
- **Alternatives considered**: flutter_dotenv (dep thừa), `--dart-define` cho cả dev (DX phiền — bị loại ở clarify).

## R5. bloc_lint — cách chạy chính thức (nguồn: pub.dev/packages/bloc_lint README)

- **Decision**: dev dep `bloc_lint ^0.4.2` + `include: package:bloc_lint/recommended.yaml` trong `analysis_options.yaml`; CLI: `dart pub global activate bloc_tools` rồi `bloc lint .` (local + CI).
- **Ghi chú**: constitution viết `dart run bloc_tools:bloc lint .` — cách chạy chính thức theo README hiện tại là global activate + `bloc lint .`; tinh thần "0 vi phạm" không đổi (đã dự phòng ở spec Assumptions).

## R6. i18n ARB

- **Decision**: dùng chuẩn Flutter `gen-l10n` (template very_good đã bật): `lib/l10n/arb/app_vi.arb` (template, mặc định) + `app_en.arb`; `l10n.yaml` đặt `template-arb-file: app_vi.arb`. `flutter_localizations` từ SDK + `intl ^0.20.3` (theo pin SDK).
- **Rationale**: Principle XV — vi là ngôn ngữ chính; template very_good mặc định en → đổi template sang vi ngay từ bootstrap.

## R7. CI (GitHub Actions)

- **Decision**: 1 workflow `.github/workflows/main.yaml` chạy trên PR + push main: checkout → `subosito/flutter-action` (channel stable, cache) → `flutter pub get` → `dart format --set-exit-if-changed .` → `flutter analyze` (fail on warning/info qua very_good_analysis) → `very_good test` (activate very_good_cli) → `bloc lint .` (activate bloc_tools). Target ≤ 10 phút (SC-006) — cache pub + Flutter SDK.
- **Không build native iOS/Android trong CI** (đã chốt ở spec Assumptions) — verify native bằng tay theo Definition of Done.
- **Alternatives considered**: reusable workflow `VeryGoodOpenSource/very_good_workflows` — tiện nhưng thêm 1 tầng gián tiếp; workflow tự viết 6 step dễ kiểm soát gate hơn (giữ đơn giản, có thể chuyển sau).

## R8. Cấu trúc feature-first (Principle XI)

- **Decision**: giữ skeleton very_good, bổ sung:
  ```
  lib/core/{config,constants,di,domain,api,router,theme,widgets}/  # api = generated-only
  lib/features/            # trống ở MO-001 (giữ feature counter template làm mẫu hoặc xoá — xoá, thay bằng placeholder HomePage tối giản hiển thị tên environment)
  lib/l10n/arb/
  ```
  Counter feature của template bị xoá (không phải sản phẩm); thay bằng 1 trang placeholder hiển thị `AppConfig.environment` — đủ chứng minh flavor hoạt động (US1 acceptance) và giữ 1 widget test mẫu cho CI gate.
- **Rationale**: repo sạch ngay từ đầu; trang placeholder là bằng chứng chạy được flavor, bị thay ở MO-002.

## Resolved Clarifications (từ spec)

Toàn bộ NEEDS CLARIFICATION = 0. Các quyết định clarify 2026-07-23: bundle ID `com.livecanvas` · dev URL local backend (`localhost:8000`/`10.0.2.2:8000`) · X-App-Key dev commit / prod `--dart-define`.
