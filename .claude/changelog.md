# Changelog — LiveCanvas Mobile

> Append-only. Mỗi entry = 1 spec đã ship (merge vào `main`).

## [Unreleased]

- **MO-002 — Foundation, Navigation & Design System** (implemented 2026-07-24, branch `MO-002-foundation-navigation`, chờ merge):
  Tầng theme tập trung dark-only từ token `_ds` (`lib/core/theme/`: colors/spacing/typography/elevation/theme/icons) + 3 font bundle cục bộ (Clash Display/Satoshi/Space Mono qua `scripts/fetch_fonts.sh`); icon đổi `phosphor_flutter`→`phosphoricons_flutter 1.0.0` (né IconData-final Flutter 3.44); 11 shared widget `lib/core/widgets/` (WallpaperCard+Aura glow, TabBar, TopBar wordmark aurora, PremiumBadge PRO không-khoá, Button/IconButton/FilterChip/MetaChip/EmptyState/AppSheet/Toast) trung thực prototype; nav `go_router StatefulShellRoute.indexedStack` 5 tab giữ state + route top-level Detail/Collection placeholder + màn `/dev/gallery` dev-only; mock server Prism (`scripts/mock_server.sh`, dev flavor opt-in `--dart-define=USE_MOCK=true`, port 4010). **Deviation**: router composition-root tách sang `lib/app/router/` (không phải `lib/core/router/`) để giữ Principle XI (core không import features) — `AppRoutes` constants vẫn ở core. Verify: 4 CI gate xanh (format · analyze 0 · 17 test · bloc lint 0); Prism trả schema-valid `/wallpapers`,`/tags`(có thẻ ảo "All"),`/collections` với `X-App-Key`.

## Shipped

- **MO-001 — Project Bootstrap & Flavors** (merged 2026-07-23 vào `main` qua PR #3, branch `MO-001-project-bootstrap`):
  very_good_cli scaffold (org `com.livecanvas`), đúng 2 flavor development/production (gỡ staging + scheme Runner mặc định trên cả iOS/Android), `AppConfig` per-flavor (dev → backend local, prod → `--dart-define=APP_KEY`), client dart-dio sinh từ contract v0.3.2 vào `packages/livecanvas_api` (`scripts/generate_api.sh`), DI get_it + injectable 3 (lean_builder) + Dio `X-App-Key` interceptor, i18n ARB vi-first, CI 4 gate GitHub Actions. Verify: build 4/4 tổ hợp + app boot iOS simulator, staging fail cả 2 platform, backend local 401/200 đúng contract.
