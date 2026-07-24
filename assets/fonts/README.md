# Bundled fonts (MO-002)

These `.ttf` files are fetched by [`scripts/fetch_fonts.sh`](../../scripts/fetch_fonts.sh)
and committed so the app ships them (no runtime/network font fetch — FR-004).

| Family | Weights | Source | License |
|---|---|---|---|
| Clash Display | 400 / 500 / 600 / 700 | [Fontshare](https://www.fontshare.com/fonts/clash-display) | ITF Free Font License (commercial use OK, bundling OK) |
| Satoshi | 400 / 500 / 700 / 900 | [Fontshare](https://www.fontshare.com/fonts/satoshi) | ITF Free Font License |
| Space Mono | 400 / 700 | [Google Fonts](https://fonts.google.com/specimen/Space+Mono) | SIL Open Font License 1.1 |

Usage — via `AppTypography` in `lib/core/theme/app_typography.dart` only:
Clash Display = display/headline/wordmark, Satoshi = body/UI (default), Space Mono = metadata/tags.
Re-run `scripts/fetch_fonts.sh` to refresh.
