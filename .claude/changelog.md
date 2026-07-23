# Changelog — LiveCanvas Mobile

> Append-only. Mỗi entry = 1 spec đã ship (merge vào `main`).

## [Unreleased]

- **MO-001 — Project Bootstrap & Flavors** (implemented 2026-07-23, branch `MO-001-project-bootstrap`, chờ merge):
  very_good_cli scaffold (org `com.livecanvas`), đúng 2 flavor development/production (gỡ staging + scheme Runner mặc định trên cả iOS/Android), `AppConfig` per-flavor (dev → backend local, prod → `--dart-define=APP_KEY`), client dart-dio sinh từ contract v0.3.2 vào `packages/livecanvas_api` (`scripts/generate_api.sh`), DI get_it + injectable 3 (lean_builder) + Dio `X-App-Key` interceptor, i18n ARB vi-first, CI 4 gate GitHub Actions. Verify: build 4/4 tổ hợp + app boot iOS simulator, staging fail cả 2 platform, backend local 401/200 đúng contract.
