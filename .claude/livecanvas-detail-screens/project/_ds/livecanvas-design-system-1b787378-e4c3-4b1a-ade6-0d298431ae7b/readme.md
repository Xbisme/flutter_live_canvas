# LiveCanvas Design System

A design system for **LiveCanvas** — a mobile app (iOS / Android / tablet, one Flutter codebase) for browsing and downloading **live wallpapers**: short 5–15s portrait video loops (neon, nature, abstract, space). A Premium tier unlocks 4K content via in-app purchase.

The product's raw material is colorful moving imagery in 9:16. The central design problem is therefore *restraint*: the UI must be a quiet frame that lets that content glow, never competing with it. This system is built around that constraint.

> **Sources:** none — this system was created from scratch from a written brief (no codebase, Figma, or brand assets were provided). There is **no logo asset**; the brand mark is rendered as the "LiveCanvas" wordmark in Clash Display with the aurora gradient (see `guidelines/wordmark.html`). If a real logo exists, drop it in `assets/` and swap the `TopBar` wordmark.

---

## The signature element — "Aura"

Every 9:16 tile casts a large, soft, **content-derived glow**: a blurred clone of the wallpaper, tinted by its dominant color, bleeding out behind the rounded tile. On the detail screen the whole chrome adopts that hue. The grid looks *lit from within by the moving wallpapers themselves* — which is exactly what the product is.

Why it fits *this* app and not any other: a static-thumbnail wallpaper grid is a dead object; motion + color is the entire value proposition. The Aura makes the color spill into the UI, so even a still screenshot reads as "these move, these glow." It's also honest engineering, not a CSS trick — it maps directly to Flutter (`palette_generator` → `BoxShadow.color` / an `ImageFiltered` blur layer), so the design ships.

**Premium** reads in one glance without a boring 🔒: PRO tiles get an iridescent aurora hairline **ring** + a small gradient **PRO** tag (diamond glyph). Free tiles are unadorned.

## Why dark (with a reason, not a default)

Dark is the right *functional* choice here — video previews need a dark neutral so in-content color pops, and endless scrolling is easier on the eyes. But the base is a **violet-tinted "Void" (#0D0A13), not clinical near-black**, so warm and cool content alike sits on it without an odd tint. And color does **not** come from one garish neon accent — it comes from the content via the Aura, backed by a considered triad (Iris / Blush / Aqua) that forms the brand's aurora gradient. This deliberately avoids the three default traps: cream + serif + earth-orange, near-black + one loud accent, and newspaper broadsheet.

---

## Content fundamentals (voice & tone)

Consumer app, Vietnamese UI. Copy is **short, active, and literal** — a button says exactly what tapping it does.

- **Action-first, imperative.** "Đặt làm hình nền", "Tải xuống", "Mở khoá Premium", "Khám phá hình nền". Never vague ("Tiếp tục" only where the action truly is *continue*).
- **Second person, warm but not chatty.** "Gợi ý cho bạn", "Chưa có gì ở đây", "Chạm vào ♥ để lưu lại đây."
- **Casing:** sentence case everywhere. No ALL-CAPS except tiny mono eyebrow labels (FREE / PRO) and metadata.
- **Numbers stay literal & mono:** "0:08", "4K", "12MB", "128 hình nền" — Space Mono makes specs feel precise.
- **No emoji in UI chrome.** The one exception is the ♥ glyph referenced *in copy* ("Chạm vào ♥…") because it names a visible control. Icons carry meaning, not decoration.
- **Premium never nags.** The paywall states value plainly ("Toàn bộ nội dung 4K, tải không giới hạn, không quảng cáo") and shows a plain free-vs-pro table; no dark patterns, no fake countdowns.

---

## Visual foundations

- **Backgrounds:** flat violet-tinted Void (#0D0A13). No page gradients, no textures, no illustrations. The only gradients are the brand **aurora** (a fixed 105° pink→violet→cyan) used sparingly, and the content-derived Aura glow. All backgrounds are solid colors → trivial Flutter `Color`.
- **Color vibe of imagery:** saturated, luminous, full-bleed. Content owns the color; chrome stays neutral. Tiles are full-bleed 9:16 with a bottom protection gradient (`rgba(9,7,14,.78)→transparent`) for title legibility.
- **Type:** Clash Display (display, −0.02em tracking), Satoshi (all UI/body), Space Mono (metadata & counts). Deliberately not Inter/Roboto.
- **Corner radii:** tiles `--r-lg` 20px, sheets/hero `--r-xl` 28px, chips/buttons/avatars pill, inputs/metadata `--r-sm`–`--r-md`. Consistent and generous — soft but not bubbly.
- **Cards / tiles:** no drop-shadow on the tile itself; the Aura *is* the elevation. A 1px `--line` hairline on free tiles; the aurora gradient ring on premium.
- **Elevation:** soft dark shadows (`--shadow-1..3`, `--shadow-sheet`) reserved for floating surfaces (sheets, dialogs, the primary button). Content relies on the Aura, not shadows.
- **Transparency & blur:** frosted glass on chrome that sits over content — the bottom `TabBar`, `IconButton variant="glass"`, and `MetaChip tone="glass"` use `backdrop-filter: blur(18px)` over a translucent Void. Blur is only for over-content chrome, never decoration → Flutter `BackdropFilter(ImageFilter.blur)`.
- **Borders:** hairlines only — `--line` (8% white) default, `--line-strong` (16%) for emphasis. No heavy or colored borders except the premium aurora ring.
- **Motion / animation:** quick and physical. Press = scale to 0.96–0.97 (`transform .12s ease`); color/opacity transitions .15s ease. Favorites pop to blush. No bounce, no long fades — snappy, content stays the star. The "live" dot (aqua) marks a moving wallpaper. Maps to Flutter implicit animations / `AnimatedScale`.
- **Hover/press states:** touch-first, so press dominates — scale-down + slight background shift. Chips/buttons darken or shift to the active fill. Favorite toggles fill color (blush) + soft glow.
- **Layout rules:** 16px screen gutter (`--gutter`), 12px grid gap (`--grid-gap`), 2-column 9:16 grid on phone. Fixed elements: top bar (56px), glass bottom tab bar (64px). Min touch target 44px.

---

## Iconography

**Phosphor Icons** (via CDN: `@phosphor-icons/web`), weights **regular** (default UI), **fill** (active tabs, favorites, badges), **duotone** (empty-state hero glyph). Chosen for a friendly, consumer, medium-stroke look that matches Satoshi — not the technical/thin feel of some sets.

- Usage in components: `<i className="ph ph-heart" />` (regular), `ph-fill`, `ph-duotone`. Every component prop that takes an `icon` expects a Phosphor name **without** the `ph-` prefix.
- **Flutter mapping:** the `phosphor_flutter` package exposes the same set 1:1.
- Common glyphs here: `magnifying-glass`, `heart`, `squares-four`, `user`, `download-simple`, `paint-brush-broad`, `sparkle`, `diamond` (premium), `share-network`, `arrow-left`, `x`, `android-logo`, `apple-logo`, `cell-signal-full`/`wifi-high`/`battery-full` (status bar).
- **No custom SVG icons, no emoji** in the UI. The premium marker is a Phosphor `diamond` on the aurora gradient — deliberately not a lock.
- **Substitution flag:** Phosphor is a substitution of convenience (no brand icon set was provided). If LiveCanvas adopts a bespoke set, replace the CDN links and re-document here.

---

## Components

Reusable primitives in `components/` (namespace `window.LiveCanvasDesignSystem_1b7873`):

- **Button** (`controls/`) — primary / aurora / secondary / ghost; sizes sm·md·lg; icon slots.
- **IconButton** (`controls/`) — circular; glass / solid / ghost; active (favorite) state.
- **FilterChip** (`controls/`) — category/tag pill with active fill, optional icon + count.
- **WallpaperCard** (`wallpaper/`) — the signature 9:16 tile with Aura, PRO ring, favorite, meta.
- **PremiumBadge** (`wallpaper/`) — aurora PRO tag / dot (no lock).
- **MetaChip** (`wallpaper/`) — mono metadata pill (duration, 4K, size) + "live" dot.
- **TopBar** (`navigation/`) — screen header; wordmark or title + leading/trailing slots.
- **TabBar** (`navigation/`) — glass bottom navigation.
- **EmptyState** (`feedback/`) — empty grids / no results, duotone glyph in aurora halo.

## UI kits

- **`ui_kits/livecanvas_app/`** — full interactive app recreation: Browse, Search, Favorites, Wallpaper Detail, Paywall, Set-Wallpaper (Android vs iOS), Profile. See its `README.md`.

## Foundations (Design System tab cards)

`guidelines/` holds specimen cards, grouped: **Colors** (brand triad, aurora, neutrals, text, semantic), **Type** (display, body, mono, scale), **Spacing** (scale, radius), **Elevation** (shadows, Aura), **Brand** (wordmark, free-vs-premium).

---

## Root manifest / index

- `styles.css` — entry point; `@import`s all tokens + fonts (link this one file).
- `tokens/` — `colors.css`, `typography.css`, `spacing.css`, `elevation.css`, `fonts.css`.
- `components/` — `controls/`, `wallpaper/`, `navigation/`, `feedback/` (each: `.jsx` + `.d.ts` + `.prompt.md` + one `@dsCard` html).
- `guidelines/` — foundation specimen cards.
- `ui_kits/livecanvas_app/` — the app kit.
- `thumbnail.html` — homepage tile. `SKILL.md` — Agent-Skill wrapper.

## Fonts — action needed
Clash Display and Satoshi load from the **Fontshare** CDN; Space Mono from **Google Fonts**. These are CDN links, not bundled files. For production Flutter, download the TTFs (Fontshare + Google Fonts both allow it) and register them; `google_fonts` covers Space Mono directly.
