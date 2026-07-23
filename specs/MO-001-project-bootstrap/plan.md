# Implementation Plan: Project Bootstrap & Flavors

**Branch**: `MO-001-project-bootstrap` | **Date**: 2026-07-23 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/MO-001-project-bootstrap/spec.md`

## Summary

Scaffold project Flutter `livecanvas` bằng `very_good_cli` (org `com.livecanvas`), gỡ hoàn toàn flavor `staging` để còn ĐÚNG 2 flavor `development` (→ backend local, dev key commit) + `production` (→ placeholder URL, key qua `--dart-define`); sync contract v0.3.2 vào `contracts/openapi.yaml` và sinh Dart client `dart-dio` + `json_serializable` vào `lib/core/api` (generated-only, script regenerate lặp lại được) với Dio interceptor `X-App-Key`; cài nền flutter_bloc / get_it+injectable / go_router / very_good_analysis+bloc_lint / i18n ARB (vi template) / Phosphor; CI GitHub Actions 4 gate (format, analyze 0 warning, very_good test, bloc lint). Toàn bộ version chốt theo [research.md](research.md) (tra pub.dev 2026-07-23).

## Technical Context

**Language/Version**: Dart 3.12.2 / Flutter 3.44.7 stable (máy dev đang 3.44.4 tại `~/Documents/develop/flutter` — upgrade trước khi implement)

**Primary Dependencies**: flutter_bloc 9.1.1, get_it 9.2.1 + injectable 3.0.0 (+ injectable_generator 3.1.1, build_runner 2.15.2), go_router 17.3.0, dio 5.10.0, json_serializable 6.14.0 / json_annotation 4.12.0, phosphor_flutter 2.1.0, intl 0.20.3 (theo pin flutter_localizations); dev: very_good_analysis 10.3.0, bloc_lint 0.4.2, bloc_test 10.0.0, mocktail 1.0.5. Tooling: very_good_cli 1.3.0, @openapitools/openapi-generator-cli 2.40.0 (core 7.14.0, cần Java ≥ 11)

**Storage**: N/A (MO-001 không có persistence; favorites local từ MO-004)

**Testing**: `very_good test` (flutter_test + bloc_test + mocktail); CI GitHub Actions

**Target Platform**: iOS/iPadOS + Android (tablet responsive); chạy được trên simulator/emulator cả 2 flavor

**Project Type**: mobile-app (Flutter single codebase)

**Performance Goals**: N/A cho bootstrap — gate là CI ≤ 10 phút (SC-006), clone-to-run ≤ 15 phút (SC-001)

**Constraints**: ĐÚNG 2 flavor (Principle XII); `lib/core/api` generated-only (Principle I); 0 warning analyze + 0 vi phạm bloc_lint; version không đoán (Principle XVI)

**Scale/Scope**: skeleton + 1 trang placeholder hiển thị environment; không feature end-user nào

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Áp dụng | Đánh giá |
|---|---|---|
| I. Contract-Driven | Client sinh từ `contracts/openapi.yaml` v0.3.2, không sửa tay, script regenerate | ✅ PASS (FR-004/006; lưu ý constitution ghi pin v0.3.0 — lỗi thời, contract hiện hành v0.3.2, cần amend PATCH sau) |
| II. Video/Memory | Không có video ở MO-001 | N/A |
| III. BLoC | Cài flutter_bloc + bloc_lint gate; chưa có Cubit nghiệp vụ | ✅ PASS |
| IV. Result\<T\> | Chưa có repository nào — Result/AppFailure dựng ở MO-002 khi có consumer đầu tiên (YAGNI, tránh code chết) | N/A — ghi nhận, không vi phạm |
| V. Entitlement | Không đụng IAP | N/A |
| VI. Design System | Chưa port token (MO-002); MO-001 không hardcode màu ngoài placeholder theme mặc định | ✅ PASS |
| VII/VIII. Platform/Channel | Không có Method Channel ở MO-001; org `com.livecanvas` khớp naming channel tương lai | ✅ PASS |
| IX. Local-First | N/A | N/A |
| X. go_router | Cài go_router; router tối giản 1 route placeholder trong `lib/core/router/` | ✅ PASS |
| XI. Feature-First | Cấu trúc `lib/core/*` + `lib/features/` đúng ranh giới; xoá counter template | ✅ PASS |
| XII. 2 Flavors | development + production, gỡ sạch staging cả 2 platform, verify bằng grep + chạy | ✅ PASS (mục tiêu chính của spec) |
| XIII. Testing | Giữ ≥ 1 widget test placeholder + CI chạy very_good test | ✅ PASS |
| XIV. YAGNI | Không cài video/IAP/secure-storage/freezed/dotenv trước lúc cần | ✅ PASS |
| XV. i18n | ARB vi làm template mặc định + en phụ ngay từ bootstrap | ✅ PASS |
| XVI. Dependency Hygiene | Mọi version tra pub.dev/npm/maven 2026-07-23, caret pin, commit lockfile | ✅ PASS ([research.md](research.md) R1) |

**Kết luận gate**: PASS — không vi phạm nào cần Complexity Tracking. 1 follow-up ngoài scope: amend constitution PATCH cập nhật contract version v0.3.0 → v0.3.2.

## Project Structure

### Documentation (this feature)

```text
specs/MO-001-project-bootstrap/
├── plan.md              # file này
├── research.md          # Phase 0 — versions + quyết định (đã xong)
├── data-model.md        # Phase 1 — AppConfig entity
├── quickstart.md        # Phase 1 — hướng dẫn verify end-to-end
├── contracts/           # Phase 1 — interface bootstrap (không phải API contract — cái đó ở /contracts repo root)
└── tasks.md             # Phase 2 (/speckit-tasks — chưa tạo)
```

### Source Code (repository root)

```text
contracts/
└── openapi.yaml               # copy byte-identical từ .claude/openapi.yaml (v0.3.2) — Contract Sync

lib/
├── core/
│   ├── api/                   # GENERATED-ONLY (openapi-generator dart-dio) — có README cảnh báo
│   ├── config/                # AppConfig + dev/prod config
│   ├── constants/             # (placeholder — channel_methods.dart từ MO-005)
│   ├── di/                    # get_it + injectable setup; đăng ký Dio + X-App-Key interceptor
│   └── router/                # go_router tối giản (1 route placeholder)
├── features/                  # trống (feature đầu tiên ở MO-002/003)
├── l10n/arb/                  # app_vi.arb (template) + app_en.arb
├── app/                       # App widget (theme mặc định, routerConfig)
├── bootstrap.dart             # bootstrap(config) chung
├── main_development.dart      # entry flavor development
└── main_production.dart       # entry flavor production

scripts/
└── generate_api.sh            # regenerate client (xoá cũ → generate → format)

android/                       # 2 flavor: development, production (KHÔNG staging)
ios/                           # 2 scheme/xcconfig: development, production (KHÔNG staging)
.github/workflows/main.yaml    # CI 4 gate
openapitools.json              # pin openapi-generator core 7.14.0
l10n.yaml / analysis_options.yaml / pubspec.yaml (+ pubspec.lock commit)
```

**Structure Decision**: Scaffold `very_good create flutter_app livecanvas --org com.livecanvas` vào thư mục tạm rồi move vào repo root (giữ `.git/`, `.claude/`, `.specify/`, `specs/`, `LICENSE`, merge README) — very_good không scaffold vào thư mục non-empty ([research.md](research.md) R2). Xoá feature counter template, thay bằng placeholder page hiển thị environment (bằng chứng flavor chạy — US1) + 1 widget test (giữ CI gate có test thật).

## Complexity Tracking

Không có vi phạm Constitution nào — bảng này bỏ trống.
