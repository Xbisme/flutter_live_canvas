# Phase 0 Research: Foundation, Navigation & Design System (MO-002)

**Date**: 2026-07-24 · Mọi version tra trực tiếp pub.dev / npm registry tại ngày này (Principle XVI — không đoán). Không còn NEEDS CLARIFICATION.

## R1. Version pins (nguồn: pub.dev API, registry.npmjs.org — 2026-07-24)

| Package / Tool | Version | Ghi chú |
|---|---|---|
| `phosphoricons_flutter` | **1.0.0** | Dart SDK `>=3.0.0 <4.0.0`, Flutter `>=3.0.0` — tương thích Flutter 3.44. Thay `phosphor_flutter`. |
| `@stoplight/prism-cli` (npm) | **5.16.0** | Chạy qua `npx`; node/npm đã có trên máy dev. |
| go_router | 17.3.0 | (đã có MO-001) |
| flutter_bloc / bloc_lint | 9.1.1 / 0.4.2 | (đã có MO-001) |
| Flutter SDK | 3.44.7 (Dart 3.12.2) | máy dev 3.44.4 → upgrade khi implement |

**KHÔNG cài ở MO-002** (Principle XIV — cài đúng khi cần):
- `freezed` / `freezed_annotation` (3.2.5 / 3.1.0) — chưa có business Cubit nào ở MO-002 (nav dùng StatefulShellRoute native, theme dùng ThemeData/InheritedWidget). Thêm ở MO-003 khi có state list/pagination cần `@freezed` 4-state (Principle III).
- `palette_generator` — Aura hue lấy từ ảnh wallpaper thật là việc của MO-003; MO-002 dựng WallpaperCard nhận `auraColor` làm tham số, demo dùng hue tĩnh có sẵn trong mock data.
- `google_fonts` — bundle TTF cục bộ, không fetch runtime (FR-004 yêu cầu không phụ thuộc mạng).

## R2. Icon: phosphor_flutter → phosphoricons_flutter (blocker MO-001, chốt 2026-07-24)

- **Decision**: dùng `phosphoricons_flutter ^1.0.0`.
- **Rationale**: `phosphor_flutter` 2.1.0 (bản mới nhất, stale 2 năm) khai báo `class PhosphorIconData extends IconData`. Từ Flutter 3.44, `IconData` bị đánh dấu `final` + `@mustBeConst` ([breaking change](https://docs.flutter.dev/release/breaking-changes/icondata-class-marked-final)) → package vỡ khi compile. `phosphoricons_flutter` né bằng `typedef PhosphorIconData = IconData;` (const, không kế thừa), 1530+ icon bám `phosphor-icons/core` v2.0.8 — **cùng bộ Phosphor** như design handoff, chỉ đổi cách gọi.
- **Mapping cách gọi**: prototype dùng kebab-case (`ph-user`, `ph-magnifying-glass`, `ph-caret-right`, `ph-check-circle`, `ph-x-circle`, `ph-heart`, `ph-flag`, `ph-user-minus`) → Flutter camelCase theo weight: `PhosphorIconsRegular.user`, `PhosphorIconsBold.magnifyingGlass`, `PhosphorIconsFill.heart`… (6 weight: thin/light/regular/bold/fill/duotone). Prototype ưu tiên `ph-fill` cho state active/nhấn.
- **Alternatives rejected**: chờ `phosphor_flutter` vá (vô định, stale 2 năm) · fork+patch (tự gánh maintenance) · git-dep vào fork lẻ (ngoài pub, không ổn định) · đổi hẳn sang Material Icons (lệch design đã duyệt — handoff vẽ bằng Phosphor). Chi tiết đánh giá đã thống nhất với product owner 2026-07-24.

## R3. Design tokens → tầng theme Flutter (từ `_ds/.../tokens/*.css`)

- **Decision**: port thành 5 file trong `lib/core/theme/` (Principle VI — một nguồn, tiêu thụ mọi nơi):
  - `app_colors.dart` — hằng `Color` từ `colors.css`: neutrals (`void #0D0A13`, `ink`, `onyx`, `onyx-2/3`), text (`hi/mid/lo`), brand triad (`iris-400/500/600`, `blush-500/400`, `aqua-500`), semantic (`success/warn/danger`), alias ngữ nghĩa (`bgApp/bgSurface/bgRaised/accent/favorite/...`). Aurora gradient (`aurora`, `aurora-soft`) là `LinearGradient` helper (105°, 3 stop).
  - `app_spacing.dart` — grid 4px (`sp1..sp16`), gutter 16, gridGap 12, radii (`rXs 6 … rXl 28`, `rPill 999`), control sizing (`hit 44`, `btnH 52`, `chipH 36`, `iconBtn 44`, `tabbarH 64`), `wallRatio 9/16`.
  - `app_typography.dart` — 3 family + type scale (display 40 / h1 28 / h2 22 / h3 18 / body 15 / sm 13 / xs 11 / 2xs 10), line-height (tight 1.05 / snug 1.2 / body 1.45), weights (400/500/700/900), letter-spacing (display -0.02em, wide 0.08em) → `TextTheme` + các `TextStyle` đặt tên (displayStyle/h1/…/monoMeta).
  - `app_elevation.dart` — `shadow1/2/3`, `shadowSheet`, và **Aura** (`auraBlur 36`, `auraSpread -6`; màu truyền runtime qua `auraColor`), blur backdrop (`blurBar 18`, `blurSheet 28`) cho glass chrome (`BackdropFilter`).
  - `app_theme.dart` — `ThemeData` dark-only lắp từ 4 nhóm token trên (colorScheme.dark, scaffoldBackground = void, textTheme = AppTypography, fontFamily mặc định Satoshi).
- **Rationale**: token CSS đã "flat hex / rgba → map thẳng sang Flutter Color/ThemeData" (ghi chú trong `colors.css`). Tách theo nhóm giữ đúng biên (Principle VI: màu/spacing/typography/elevation riêng biệt).
- **Aura signature**: glow màu-theo-nội-dung — MO-002 để `auraColor` là tham số widget (mock cấp hue tĩnh); MO-003 nối `palette_generator` sinh hue từ ảnh thật.
- **Alternatives rejected**: hardcode ở call site (cấm bởi Principle VI/FR-002) · một file token khổng lồ (khó bảo trì).

## R4. Theme mode: dark-only

- **Decision**: chỉ dark theme.
- **Rationale**: `colors.css` chỉ định nghĩa một `:root` bảng màu dark "Void" (violet-tinted), không có `@media prefers-color-scheme` / `data-theme` / token light. Constitution mô tả "dark aurora surface". Dựng light mode không có nguồn token → sẽ là bịa (vi phạm Principle VI).
- **Alternatives rejected**: light+dark ThemeData (không có token light) · theo system brightness (không có biến thể light để theo).

## R5. Fonts — bundle TTF cục bộ

- **Decision**: tải TTF về `assets/fonts/`, khai `pubspec.yaml` `fonts:`; KHÔNG dùng `google_fonts` (fetch runtime). Script `scripts/fetch_fonts.sh` ghi rõ nguồn để tái lập, commit TTF vào repo (là asset).
  - **Clash Display** (Fontshare) — 400/500/600/700 (theo `fonts.css`, dùng cho display/wordmark/paywall number).
  - **Satoshi** (Fontshare) — 400/500/700/900 (body/UI mặc định).
  - **Space Mono** (Google Fonts) — 400/700 (metadata/tag/count).
- **License**: Fontshare (ITF Free Font License) + Google Fonts (OFL) — đều cho dùng thương mại + đóng gói kèm app. Ghi nguồn license vào `assets/fonts/README.md`.
- **Rationale**: FR-004 yêu cầu không phụ thuộc font hệ thống/mạng lúc chạy. Bundle cục bộ = xác định, offline, không thêm dependency.
- **Alternatives rejected**: `google_fonts` (thêm dep + fetch/cache runtime, rủi ro offline — YAGNI) · dựa font hệ thống (không có 3 font này trên iOS/Android).

## R6. Navigation — go_router StatefulShellRoute.indexedStack (Principle X)

- **Decision**: `go_router` (đã có 17.3.0) với `StatefulShellRoute.indexedStack` cho 5 branch (Khám phá / Tìm / Bộ sưu tập / Yêu thích / Bạn) — mỗi branch giữ `Navigator` + state riêng (giải quyết SC-001 giữ trạng thái). Route constants trong `AppRoutes` (abstract final class). Detail/Collection là route **top-level** (ngoài shell) push phủ tab. TabBar (widget `_ds`) render từ `navigationShell.currentIndex`, đổi tab qua `navigationShell.goBranch(i)`.
- **Rationale**: đúng mô hình prototype `App` component (tab-shell + full-screen push) và mandate Principle X.
- **Sheet rule (FR-010)**: sheet "đóng-rồi-mở" → `Navigator.pop` rồi mở cái mới trong `WidgetsBinding.addPostFrameCallback` (không 2 sheet/frame).
- **Alternatives rejected**: `Navigator 1.0`/`Navigator.of` trực tiếp (cấm bởi Principle X) · `TabBarView` (mất deep-link + route constants) · package nav khác (đã chuẩn hoá go_router từ MO-001).

## R7. Responsive-aware (clarify 2026-07-24)

- **Decision**: helper breakpoint trong `lib/core/responsive/` dùng `MediaQuery`/`LayoutBuilder` — ngưỡng phone/tablet (vd ≥600dp là tablet). Shell + shared widgets thích ứng để không vỡ; số cột grid cụ thể theo `ipad.html` để MO-003 khi có grid thật.
- **Rationale**: tab body là placeholder — chưa có grid thật để tinh chỉnh; nhưng widget/khung phải responsive-ready để MO-003 không phải viết lại.
- **Alternatives rejected**: phone-only (shared widgets phải sửa lại khi thêm iPad) · dựng full grid iPad ngay (tinh chỉnh layout cho nội dung chưa tồn tại — lãng phí).

## R8. Mock server — Prism từ contract

- **Decision**: `scripts/mock_server.sh` chạy `npx @stoplight/prism-cli@5.16.0 mock contracts/openapi.yaml -p 4010` (dynamic examples theo schema). App flavor `development` có thể trỏ `apiBaseUrl` sang `http://localhost:4010` (hoặc `10.0.2.2:4010` trên Android emulator) để render dữ liệu mẫu.
- **Rationale**: roadmap chỉ định Prism; sinh trực tiếp từ `openapi.yaml` v0.3.2 nên response luôn khớp schema (SC-007) không cần viết fixture tay. `npx` tránh cài global.
- **Lưu ý**: mock là công cụ dev-time, không đóng vào app người dùng cuối. Contract nguồn: `contracts/openapi.yaml` (đồng bộ tay với backend, v0.3.2).
- **Alternatives rejected**: viết mock server Dart tay (tốn công, dễ lệch schema) · dùng backend local thật (MO-002 không nên phụ thuộc backend — điểm đồng bộ thật ở MO-003).

## R9. Widget inventory — bộ `_ds` canonical (từ `_ds_manifest.json`)

- **Decision**: port đủ 9 component `_ds` + 2 widget cấp màn của prototype:
  - **Composite (spec FR-006 nêu tên)**: `WallpaperCard`, `TabBar`, `TopBar`, `PremiumBadge`.
  - **Atoms (phụ thuộc của composite, phải có để dựng trung thực)**: `Button`, `IconButton`, `FilterChip`, `MetaChip`, `EmptyState`.
  - **Cấp màn (từ `Sheets.jsx`, không trong `_ds` bundle)**: `AppSheet` (bottom sheet nền), `Toast`.
- **Rationale**: `WallpaperCard`/`TopBar` trong prototype tiêu thụ `IconButton`/`FilterChip`/`MetaChip`/`PremiumBadge` — không thể dựng composite trung thực nếu thiếu atoms. Đưa cả bộ vào để MO-003+ ráp màn không phải bổ sung lắt nhắt.
- **Props tham chiếu** (từ usage prototype + `data.js`): `WallpaperCard(preview, auraColor, title, author, premium, meta{duration,res,size})`; `PremiumBadge` = xử lý "PRO" bằng aurora gradient, **không icon khoá** (guideline `premium-treatment`); `TopBar(title | wordmark, trailing)`; `TabBar(items[icon,label], currentIndex, onTap)`; `MetaChip` = nhãn mono (Space Mono). Chi tiết → [data-model.md](data-model.md) + [contracts/ui-contracts.md](contracts/ui-contracts.md).

## Resolved Clarifications (từ spec §Clarifications 2026-07-24)

Toàn bộ NEEDS CLARIFICATION = 0. Ba quyết định clarify: iPad **responsive-ready** (tinh chỉnh grid → MO-003) · widget qua **gallery demo dev-only** · theme **dark-only**.
