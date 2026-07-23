# LiveCanvas — Mobile

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

> Ứng dụng **hình nền động (live video wallpaper)** viết bằng Flutter.
> Duyệt và tải các hình nền video lặp, đặt làm hình nền động trên Android
> (`WallpaperService`) và qua luồng hướng dẫn Shortcuts trên iOS.

LiveCanvas không có hệ thống tài khoản: **favorite/lịch sử lưu local**, gói
**Premium** là subscription IAP được xác thực phía server qua `transaction_id`
(tự viết verify-receipt, không dùng RevenueCat).

- **Nền tảng**: Android (đặt live wallpaper trực tiếp) · iOS/iPadOS (preview +
  hướng dẫn Shortcuts) · Tablet responsive.
- **Repo backend đi kèm**: `livecanvas-backend` (Django) — độc lập, đồng bộ qua
  contract (xem [Contract Sync](#contract-sync)).
- Scaffold bởi [Very Good CLI][very_good_cli_link] (spec MO-001).

---

## Kiến trúc & nguyên tắc

Mọi quyết định kỹ thuật tuân theo hiến pháp dự án:
[`.specify/memory/constitution.md`](.specify/memory/constitution.md) (v1.0.0).
Tóm tắt bắt buộc:

- **Contract-driven**: Dart API client **generate** từ
  `contracts/openapi.yaml` (v0.3.2) — không viết tay model API.
- **Flavor**: **đúng 2 flavor `development` + `production`** — không có
  `staging` (Principle XII; thêm flavor = amend hiến pháp).
- **State**: BLoC/Cubit (`flutter_bloc`), 4 trạng thái
  `initial → loading → loaded → error`; **Lỗi**: `Result<T>` + `AppFailure`.
- **Entitlement**: client không bao giờ tự quyết Premium — gate thật ở
  `download-url` phía backend.
- **Video & bộ nhớ**: builder lazy + dispose `VideoPlayerController` ngoài
  viewport, cursor pagination (từ MO-003).

## Yêu cầu môi trường

| Công cụ | Ghi chú |
|---|---|
| Flutter ≥ 3.44.7 stable | `flutter upgrade` |
| very_good_cli | `dart pub global activate very_good_cli` |
| bloc_tools (CLI `bloc lint`) | `dart pub global activate bloc_tools` |
| Java ≥ 11 (chạy openapi-generator) | `brew install openjdk` |
| Node/npm (npx) | cho `@openapitools/openapi-generator-cli` |
| Xcode + Android SDK | build iOS/Android |
| Backend local (flavor development) | repo `livecanvas-backend`: `python manage.py runserver` |

## Chạy app theo flavor

```bash
# Development — trỏ backend local
#   iOS simulator:    http://localhost:8000
#   Android emulator: http://10.0.2.2:8000  (tự chọn theo platform)
flutter run --flavor development -t lib/main_development.dart

# Production — placeholder URL (domain thật chốt trước MO-007);
# X-App-Key bơm qua --dart-define, KHÔNG commit
flutter run --flavor production -t lib/main_production.dart \
  --dart-define=APP_KEY=<key>
```

Build release production:

```bash
flutter build ipa       --flavor production -t lib/main_production.dart --dart-define=APP_KEY=<key>
flutter build appbundle --flavor production -t lib/main_production.dart --dart-define=APP_KEY=<key>
```

Không tồn tại flavor thứ ba — `flutter run --flavor staging` phải báo lỗi.

## Sinh API client từ contract

Contract nguồn: [`contracts/openapi.yaml`](contracts/openapi.yaml)
(**v0.3.2**, sync tay với repo backend). Client `dart-dio` +
`json_serializable` được sinh vào **`packages/livecanvas_api/`** (package
path-dependency riêng, GENERATED-ONLY — không sửa tay):

```bash
scripts/generate_api.sh   # idempotent: xoá client cũ → generate → codegen → format
```

Generator pin version trong [`openapitools.json`](openapitools.json)
(core 7.14.0). Script tự bump SDK constraint của package sinh ra lên ≥3.8
(json_serializable dùng null-aware elements).

## Cấu trúc thư mục

```
lib/
  core/
    config/        # AppConfig theo flavor (base URL, X-App-Key)
    constants/     # (channel methods… từ MO-005)
    di/            # get_it + injectable 3 (codegen: dart run lean_builder build)
    network/       # AppKeyInterceptor (Dio)
    router/        # go_router — AppRoutes constants
  features/        # (trống — feature đầu tiên ở MO-002/003)
  l10n/arb/        # app_vi.arb (template, MẶC ĐỊNH) + app_en.arb
  app/             # App widget + HomePage placeholder
  bootstrap.dart   # bootstrap(builder, config) → DI
  main_development.dart / main_production.dart
packages/
  livecanvas_api/  # client generated (GENERATED.md — không sửa tay)
contracts/openapi.yaml
scripts/generate_api.sh
.claude/           # project-context, roadmap, api-context, design handoff
.specify/          # constitution + speckit
```

## Pre-commit checklist (bắt buộc — hiến pháp)

```bash
dart format .                    # format
flutter analyze                  # 0 warning
very_good test --test-randomize-ordering-seed random
bloc lint .                      # 0 vi phạm (bloc_tools)
```

CI ([.github/workflows/main.yaml](.github/workflows/main.yaml)) chạy đúng 4
gate này trên mọi PR — đỏ là không merge.

## Contract Sync

3 file sau **tồn tại ở CẢ 2 repo** (`livecanvas-mobile`, `livecanvas-backend`)
và được **copy tay cho giống hệt** khi API đổi:

- `contracts/openapi.yaml`
- `.claude/api-context.md`
- `docs/screen-inventory.md` *(bản làm việc hiện đặt trong `.claude/`)*

Quy tắc: cần shape mới → sửa **`screen-inventory.md` trước** → rồi
`openapi.yaml` + `api-context.md` → copy sang repo còn lại → chạy
`scripts/generate_api.sh`. **Không thêm field chỉ-có-ở-client.**
Contract hiện tại: **`v0.3.2`**.

## i18n

ARB tại `lib/l10n/arb/` — **`app_vi.arb` là template/mặc định**, `app_en.arb`
phụ. Thêm string mới vào `app_vi.arb` (kèm `@description`) → dịch sang
`app_en.arb` → `flutter gen-l10n` (tự chạy khi build). Dùng qua
`context.l10n`.

## Lộ trình spec

Xem [`.claude/sdd-roadmap.md`](.claude/sdd-roadmap.md):
`#000 Contract Freeze → MO-001 Bootstrap ✅ → MO-002 Foundation/Design →
MO-003 Browse/Collections/Detail → MO-004 Favorites → MO-005 Set Wallpaper →
MO-006 IAP/Paywall → MO-007 Store Submission`.

---

> Giao tiếp: tiếng Việt giữa dev ↔ Claude · tiếng Anh cho code/comment/commit.

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://github.com/VeryGoodOpenSource/very_good_cli
