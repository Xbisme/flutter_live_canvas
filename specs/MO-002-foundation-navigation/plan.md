# Implementation Plan: Foundation, Navigation & Design System (MO-002)

**Branch**: `MO-002-foundation-navigation` | **Date**: 2026-07-24 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/MO-002-foundation-navigation/spec.md`

## Summary

Dựng nền tảng UI cho LiveCanvas trên scaffold MO-001: (1) port design token `_ds` (dark-only "Void") thành một tầng theme tập trung `lib/core/theme/` + đóng gói 3 font TTF cục bộ; (2) thay `phosphor_flutter` (vỡ Flutter 3.44) bằng `phosphoricons_flutter`; (3) dựng thư viện widget dùng chung `lib/core/widgets/` trung thực prototype (bộ `_ds`: WallpaperCard, TabBar, TopBar, PremiumBadge, + atoms Button/FilterChip/IconButton/MetaChip/EmptyState, + Sheet/Toast); (4) khung điều hướng `go_router` `StatefulShellRoute.indexedStack` 5 tab (thân tab = placeholder, tab "Bạn" = shell rỗng) + route placeholder full-screen cho Detail/Collection; (5) mock server Prism từ `contracts/openapi.yaml`; (6) màn gallery demo dev-only để đối chiếu widget với prototype. Foundation-only: KHÔNG logic list/pagination/API thật (→ MO-003).

## Technical Context

**Language/Version**: Dart 3.12.2 / Flutter **3.44.7** (máy dev đang 3.44.4 — upgrade khi implement, như MO-001).

**Primary Dependencies** (mới thêm ở MO-002, version tra pub.dev 2026-07-24 — xem [research.md](research.md)):
- `phosphoricons_flutter` **1.0.0** (thay `phosphor_flutter` — Dart 3.x compatible).
- (đã có từ MO-001, tái dùng) `go_router` 17.3.0, `flutter_bloc` 9.1.1, `get_it` 9.2.1 + `injectable` 3.0.0, `very_good_analysis` 10.3.0, `bloc_lint` 0.4.2.
- **KHÔNG thêm ở MO-002** (Principle XIV YAGNI): `freezed` (không có business Cubit — nav dùng StatefulShellRoute native; để MO-003), `palette_generator` (aura hue từ ảnh thật → MO-003; MO-002 nhận `auraColor` tham số, demo dùng hue tĩnh từ mock), `google_fonts` (bundle TTF cục bộ, không fetch runtime).

**Fonts** (bundle TTF cục bộ vào `assets/fonts/`, khai `pubspec.yaml`; không phụ thuộc mạng — FR-004):
- Clash Display (Fontshare, ITF Free) — weights 400/500/600/700.
- Satoshi (Fontshare, ITF Free) — weights 400/500/700/900.
- Space Mono (Google Fonts, OFL) — weights 400/700.

**Mock server**: Prism CLI `@stoplight/prism-cli` **5.16.0** qua `npx` (node/npm đã có trên máy), script `scripts/mock_server.sh mock contracts/openapi.yaml`. App flavor `development` trỏ được vào mock URL.

**Storage**: N/A (foundation-only; local storage của Favorites → MO-004).

**Testing**: `flutter_test` + `bloc_test` (đã có); widget test cho shared widgets + golden-lite (đối chiếu render); route test cho shell điều hướng.

**Target Platform**: iOS 15+ / Android; responsive-aware iPhone ↔ iPad (không vỡ layout); tinh chỉnh grid đa cột → MO-003.

**Project Type**: Mobile app (Flutter, single codebase).

**Performance Goals**: 60 fps điều hướng/scroll khung; CI ≤ 10 phút (kế thừa mục tiêu MO-001).

**Constraints**: Theme **dark-only** (token không có light mode); mọi giá trị thị giác từ token (0 hardcode); icon 100% Phosphor.

**Scale/Scope**: ~9 shared widget + 5 tab shell + gallery demo + mock server + theme layer. Không màn nghiệp vụ thật.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Áp dụng MO-002 | Trạng thái |
|---|---|---|
| I. Contract-Driven & Backend-Synced | Mock server sinh từ `contracts/openapi.yaml` (v0.3.2); không tạo/sửa API. | ✅ Pass |
| II. Video Playback & Memory Discipline | Không có video ở MO-002 (preview → MO-003). | ✅ N/A (deferred) |
| III. BLoC-Driven State Management | Foundation không có business logic state; nav dùng StatefulShellRoute native. Nếu phát sinh state UI → Cubit + 4-state; nhưng YAGNI: không tạo Cubit thừa. `bloc_lint` 0 vi phạm. | ✅ Pass |
| IV. Result\<T\> Error Handling | Không có async op nghiệp vụ ở MO-002. | ✅ N/A (deferred) |
| V. Server-Authoritative Entitlement | Không quyết định premium ở client; PremiumBadge chỉ hiển thị theo cờ mock. | ✅ Pass |
| VI. Design System & Theming | **Trọng tâm spec**: token tập trung, 0 hardcode màu/pixel, typography token, icon Phosphor đơn nhất, shared widgets ở `lib/core/widgets/`. | ✅ Pass (core) |
| VII. Platform Integration | Responsive-aware iPhone/iPad; native set-wallpaper → MO-005. | ✅ Pass (native deferred) |
| VIII. Method Channel Architecture | N/A ở MO-002. | ✅ N/A |
| IX. Local-First, Account-Free Data | N/A (Favorites local → MO-004). | ✅ N/A |
| X. go_router Navigation Standards | Route constants trong `AppRoutes`; chỉ `context.go/push/pop`; StatefulShellRoute.indexedStack 5 tab; sheet đóng-rồi-mở qua addPostFrameCallback. | ✅ Pass (core) |
| XI. Feature-First Modularity | Hạ tầng ở `lib/core/`; `lib/core/` không import `lib/features/*`. | ✅ Pass |
| XII. Build Flavors & Env Config | Tái dùng 2 flavor MO-001; dev flavor trỏ mock. | ✅ Pass |
| XIII. Testing Discipline | Widget/route test cho shell + widgets; CI 4 gate. | ✅ Pass |
| XIV. Simplicity & YAGNI | Defer freezed/palette_generator/google_fonts; không dựng nội dung tab thật. | ✅ Pass |
| XV. Internationalization by Default | Chuỗi qua ARB (vi mặc định), không hardcode. | ✅ Pass |
| XVI. Dependency Hygiene | Version tra pub.dev 2026-07-24 (không đoán); mỗi dep mới có lý do. | ✅ Pass |

**Kết luận**: 0 vi phạm cần biện minh → Complexity Tracking để trống.

## Project Structure

### Documentation (this feature)

```text
specs/MO-002-foundation-navigation/
├── plan.md              # This file
├── research.md          # Phase 0 — version pins + technical decisions
├── data-model.md        # Phase 1 — token model + widget inventory/contracts
├── quickstart.md        # Phase 1 — validation guide
├── contracts/
│   └── ui-contracts.md   # Phase 1 — widget API + route table (UI contract, no new HTTP API)
├── checklists/
│   └── requirements.md   # (từ /speckit.specify)
└── tasks.md             # Phase 2 — /speckit.tasks (KHÔNG tạo ở /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── theme/                    # ← MO-002 trọng tâm
│   │   ├── app_colors.dart         # token màu "Void" (dark) + aurora gradient
│   │   ├── app_spacing.dart        # spacing 4px grid + radii + control sizing
│   │   ├── app_typography.dart     # 3 font family + type scale → TextTheme + styles
│   │   ├── app_elevation.dart      # shadows + Aura glow token
│   │   └── app_theme.dart          # ThemeData dark-only lắp từ token trên
│   ├── widgets/                  # ← shared widget library (Principle VI)
│   │   ├── controls/               # Button, IconButton, FilterChip
│   │   ├── navigation/             # TabBar, TopBar
│   │   ├── wallpaper/              # WallpaperCard, PremiumBadge, MetaChip
│   │   ├── feedback/               # EmptyState, Toast
│   │   └── sheet/                  # AppSheet (bottom sheet nền)
│   ├── router/
│   │   ├── app_routes.dart         # route constants
│   │   └── app_router.dart         # go_router + StatefulShellRoute.indexedStack
│   ├── responsive/               # breakpoint helper (iPhone ↔ iPad)
│   ├── config/ · di/ · domain/ · l10n/   # (đã có từ MO-001)
│   └── api/                       # (generated client — MO-001; ở packages/livecanvas_api)
├── features/
│   ├── browse/ search/ collections/ favorites/ profile/   # placeholder tab bodies
│   │   └── presentation/pages/*_placeholder_page.dart
│   ├── wallpaper_detail/          # placeholder full-screen page
│   ├── collection_detail/         # placeholder full-screen page
│   └── dev_gallery/               # màn gallery demo dev-only (FR-006a)
└── main_development.dart / main_production.dart   # (MO-001)

assets/fonts/                      # 3 font TTF (bundle cục bộ)
scripts/
├── mock_server.sh                 # Prism mock từ contracts/openapi.yaml
└── fetch_fonts.sh                 # tải TTF Fontshare + Google Fonts (tái lập được)

test/
├── core/theme/                    # token/theme test
├── core/widgets/                  # widget test cho shared widgets
└── core/router/                   # route/shell navigation test
```

**Structure Decision**: Mobile app single-codebase, feature-first (Principle XI). MO-002 tập trung vào `lib/core/theme` + `lib/core/widgets` + `lib/core/router`; các `lib/features/<tab>/` chỉ chứa placeholder page. Widget dùng chung sống ở `lib/core/widgets/` (không nằm trong feature nào) vì mọi feature tiêu thụ chúng.

## Complexity Tracking

> Không có vi phạm hiến pháp cần biện minh — bảng để trống.
