# Data Model: Foundation, Navigation & Design System (MO-002)

> MO-002 là nền tảng UI — **không có entity dữ liệu nghiệp vụ mới**. "Model" ở đây là cấu trúc **token thiết kế** và **inventory widget dùng chung** (cấu phần kỹ thuật). Dữ liệu nghiệp vụ (Wallpaper/Collection/Tag) do contract v0.3.2 định nghĩa và mock server cấp; các spec sau tiêu thụ.

## 1. Design Token Model (`lib/core/theme/`)

Nguồn: `_ds/.../tokens/*.css`. Mọi giá trị dưới đây là hằng, tiêu thụ mọi nơi (Principle VI, FR-001/002/003).

### 1.1 `AppColors` (từ `colors.css` — dark "Void")

| Nhóm | Token → giá trị |
|---|---|
| Neutrals | `void #0D0A13` (bg app) · `ink #12101A` · `onyx #1A1626` (surface) · `onyx2 #241E33` (raised) · `onyx3 #302943` (hover) |
| Lines/scrim | `line rgba(255,255,255,.08)` · `lineStrong …16` · `scrim rgba(9,7,14,.72)` |
| Text | `textHi #F6F3FB` · `textMid #ADA4BE` · `textLo #6E6683` |
| Brand triad | `iris400 #9B82FF` · `iris500 #7C5CFF` (accent chính) · `iris600 #6344E6` · `blush500 #FF6F9C` (favorite) · `blush400 #FF8FB2` · `aqua500 #46D5E6` |
| Semantic | `success #3FE0A6` · `warn #FFC24C` · `danger #FF5D6C` |
| Aliases | `bgApp=void` · `bgSurface=onyx` · `bgRaised=onyx2` · `bgRaisedHover=onyx3` · `borderSubtle=line` · `borderStrong=lineStrong` · `textPrimary=textHi` · `textSecondary=textMid` · `textTertiary=textLo` · `accent=iris500` · `accentHover=iris400` · `accentPress=iris600` · `onAccent #FFFFFF` · `favorite=blush500` |
| Gradient | `aurora` = `LinearGradient(105°, [blush500 0%, iris500 52%, aqua500 100%])` · `auroraSoft` (α .22) |

### 1.2 `AppSpacing` (từ `spacing.css` — grid 4px)

- Scale: `sp1 4 · sp2 8 · sp3 12 · sp4 16 · sp5 20 · sp6 24 · sp8 32 · sp10 40 · sp12 48 · sp16 64`.
- Layout: `gutter 16` (padding mép màn) · `gridGap 12` (khe giữa tile).
- Radii: `rXs 6 · rSm 10 · rMd 14 · rLg 20` (tile) · `rXl 28` (hero/sheet) · `rPill 999`.
- Sizing: `hit 44` (touch tối thiểu) · `btnH 52` · `chipH 36` · `iconBtn 44` · `tabbarH 64`.
- `wallRatio = 9/16` (tỉ lệ wallpaper tile).

### 1.3 `AppTypography` (từ `typography.css` — 3 font)

- Families: `display = Clash Display` (fallback Satoshi) · `body = Satoshi` (mặc định app) · `mono = Space Mono`.
- Scale (px): `display 40 · h1 28 · h2 22 · h3 18 · body 15 · sm 13 · xs 11 · 2xs 10`.
- Line-height: `tight 1.05 · snug 1.2 · body 1.45`. Weights: `regular 400 · medium 500 · bold 700 · black 900`.
- Letter-spacing: `display -0.02em · wide 0.08em` (mono/eyebrow).
- Xuất ra: `TextTheme` (map displayLarge/headline/title/body/label…) + `TextStyle` đặt tên dùng chung: `displayStyle, h1, h2, h3, bodyText, small, monoMeta, eyebrow`.

### 1.4 `AppElevation` (từ `elevation.css`)

- Shadows: `shadow1 (0 2 8 /.30) · shadow2 (0 8 24 /.42) · shadow3 (0 16 48 /.50) · shadowSheet (0 -10 44 /.55)`.
- **Aura** (glow theo nội dung): `auraBlur 36 · auraSpread -6`; **màu = tham số runtime** (`auraColor`), mặc định `iris500 α.55`. MO-002 nhận từ mock; MO-003 sinh từ ảnh (`palette_generator`).
- Blur backdrop (glass): `blurBar 18 · blurSheet 28` (dùng `BackdropFilter(ImageFilter.blur)`).

### 1.5 `AppTheme`

- `ThemeData` **dark-only**: `brightness.dark`, `scaffoldBackgroundColor = bgApp`, `colorScheme` từ brand triad, `textTheme = AppTypography`, `fontFamily = Satoshi`.

## 2. Shared Widget Inventory (`lib/core/widgets/`)

> Nguồn canonical: `_ds_manifest.json` (9 component) + `Sheets.jsx` (Sheet/Toast cấp màn). Trung thực prototype (FR-006). Props suy từ usage prototype + `data.js`.

| Widget | Nhóm | API (tham chiếu) | Ghi chú trung thực prototype |
|---|---|---|---|
| `AppButton` | controls | `label, onPressed, variant{primary/ghost}, gradient?` | primary CTA cao `btnH 52`; aurora gradient cho CTA thương hiệu |
| `AppIconButton` | controls | `icon(PhosphorIcon), onPressed, variant{solid/ghost}` | tròn `iconBtn 44`; icon Phosphor |
| `FilterChip` | controls | `label, selected, onTap` | cao `chipH 36`, bo `rPill`; chip "Tất cả" mặc định |
| `MetaChip` | controls | `text` | nhãn **Space Mono** (duration/res/size/count) — cùng nhóm atom với FilterChip (T025) |
| `PremiumBadge` | wallpaper | `—` (hiển thị "PRO") | **aurora gradient text, KHÔNG icon khoá** (guideline `premium-treatment`) |
| `WallpaperCard` | wallpaper | `preview, auraColor, title, author, premium, meta{duration,res,size}, onTap, onFav, isFav` | tile `wallRatio 9/16`, bo `rLg 20`, **Aura glow** dưới tile theo `auraColor`; preview = video 9:16 (MO-002 dùng placeholder gradient) |
| `TopBar` | navigation | `title? \| wordmark(bool), trailing?` | wordmark = Clash Display + aurora; glass blur `blurBar` |
| `AppTabBar` | navigation | `items[{icon,label}], currentIndex, onTap` | cao `tabbarH 64`; 5 tab; icon active dùng weight `fill` |
| `EmptyState` | feedback | `icon, title, message, action?` | trạng thái rỗng (dùng ở placeholder tab/Favorites sau) |
| `AppSheet` | sheet | `child, padding` | bottom sheet nền, bo `rXl 28`, `shadowSheet`, blur `blurSheet` |
| `Toast` | feedback | `text` | thông báo ngắn nổi (vd "Đã sao chép liên kết") |

**Ràng buộc**: mỗi widget tồn tại **đúng một** bản ở `lib/core/widgets/` (SC-005); màu/spacing/typography **chỉ** từ token (FR-002); icon **chỉ** Phosphor (FR-005). Widget không chứa business logic (Principle III).

## 3. Navigation Model (`lib/core/router/`)

### 3.1 `AppRoutes` (route constants — Principle X)

| Const | Path | Loại |
|---|---|---|
| `browse` | `/browse` | tab branch 0 (Khám phá) |
| `search` | `/search` | tab branch 1 (Tìm) |
| `collections` | `/collections` | tab branch 2 (Bộ sưu tập) |
| `favorites` | `/favorites` | tab branch 3 (Yêu thích) |
| `profile` | `/profile` | tab branch 4 (Bạn) |
| `wallpaperDetail` | `/wallpaper/:id` | top-level push (placeholder MO-002) |
| `collectionDetail` | `/collection/:id` | top-level push (placeholder MO-002) |
| `devGallery` | `/dev/gallery` | dev-only (FR-006a; ẩn khỏi production) |

### 3.2 Shell

- `StatefulShellRoute.indexedStack` với 5 `StatefulShellBranch` (mỗi branch giữ Navigator + state riêng → SC-001).
- `AppTabBar` render từ `navigationShell.currentIndex`; đổi tab = `navigationShell.goBranch(index)`.
- Detail/Collection: route top-level (ngoài shell) → push phủ TabBar (FR-008); back về đúng tab nguồn.

### 3.3 Tab body (MO-002 = placeholder)

| Tab | Nội dung MO-002 |
|---|---|
| Khám phá / Tìm / Bộ sưu tập / Yêu thích | Placeholder skeleton hợp theme (dùng `EmptyState`/skeleton) — nội dung thật MO-003/004 |
| Bạn | **Shell rỗng** có `TopBar(title:"Bạn")` — nội dung Premium/Restore/settings MO-006 |

## 4. Mock Data (dev-time, không phải entity app)

- Prism sinh response mẫu từ `contracts/openapi.yaml` v0.3.2 (Wallpaper/Collection/Tag…). MO-002 chỉ cần đủ để render placeholder/gallery — không mô hình hoá lại schema ở client (client generated đã có từ MO-001 tại `packages/livecanvas_api`).
- Gallery demo có thể dùng vài mẫu tĩnh (theo hình dạng `data.js`: `preview` gradient, `auraColor`, `title`, `author`, `premium`, `duration/res/size`) để trưng bày `WallpaperCard` mà không cần mock server chạy.
