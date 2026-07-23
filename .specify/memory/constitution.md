<!--
================================================================================
SYNC IMPACT REPORT
================================================================================
Version Change: (placeholder template) → 1.0.0 (initial ratification)

This is the first real constitution for the LiveCanvas Mobile app, replacing
the unfilled speckit placeholder. All principles are newly authored and
tailored to a Flutter live-wallpaper client (NOT carried over verbatim from
another project).

Newly Added Principles:
- I.    Contract-Driven & Backend-Synced
- II.   Video Playback & Memory Discipline
- III.  BLoC-Driven State Management
- IV.   Result<T> Error Handling
- V.    Server-Authoritative Entitlement (No Local Premium Decisions)
- VI.   Design System & Theming (from the handoff tokens)
- VII.  Platform Integration (Android live wallpaper / iOS Shortcuts)
- VIII. Method Channel Architecture
- IX.   Local-First, Account-Free Data
- X.    go_router Navigation Standards
- XI.   Feature-First Modularity
- XII.  Build Flavors & Environment Config (EXACTLY development + production)
- XIII. Testing Discipline
- XIV.  Simplicity & YAGNI
- XV.   Internationalization by Default
- XVI.  Dependency Hygiene

Templates Requiring Updates:
- .specify/templates/plan-template.md ✅ (generic Constitution Check section
  remains accurate; no inline principle references to amend)
- .specify/templates/spec-template.md ✅ (no principle-specific sections)
- .claude/sdd-roadmap.md ✅ (MO-001 bootstrap spec added to satisfy
  Principle XII — two-flavor project via very_good_cli)

Follow-up TODOs:
- Confirm production bundle ID (iOS) / applicationId (Android) — Method Channel
  names and URL scheme below use the provisional `com.livecanvas` prefix.
================================================================================
-->

# LiveCanvas Mobile Constitution

> App Name: "LiveCanvas" — Flutter live (video) wallpaper app.
> Browse and download looping animated wallpapers; set them as live wallpaper
> on Android (`WallpaperService`) and via a guided Shortcuts flow on iOS.
> No user accounts — favorites/history are local; Premium is an IAP
> subscription verified server-side by transaction_id (self-written
> verify-receipt, no RevenueCat).

## Core Principles

### I. Contract-Driven & Backend-Synced

The backend contract is the single source of truth for every API interaction.
The app MUST NOT hand-write request/response models for endpoints that the
contract already describes.

- The Dart API client MUST be generated from `contracts/openapi.yaml`
  (`openapi-generator-cli -g dart-dio`) — generated code MUST NOT be edited by
  hand; regenerate instead.
- `contracts/openapi.yaml`, `.claude/api-context.md`, and
  `docs/screen-inventory.md` live in BOTH the mobile and backend repos and are
  kept byte-identical by hand ("Contract Sync"). When the app needs a shape
  the contract lacks, update `docs/screen-inventory.md` FIRST, then the
  contract, then copy to the other repo — NEVER add a client-only field.
- The current contract version is authoritative: **`v0.3.0`**. A feature MUST
  NOT depend on an endpoint or field not present in the pinned contract.
- Until a backend spec (`BE-NNN`) is confirmed merged, the corresponding
  mobile feature runs against a mock server (Prism) generated from the same
  `openapi.yaml` — never against invented fixtures that drift from the schema.

**Rationale**: Two independently developed repos only stay compatible if one
machine-readable contract drives both. Hand-written models and client-only
fields are how mobile and backend silently diverge.

### II. Video Playback & Memory Discipline

Every wallpaper is a looping video. Uncontrolled `VideoPlayerController`
instances are the single biggest crash/ANR risk in this app. Memory
discipline is NON-NEGOTIABLE.

- All wallpaper lists MUST use lazy builders (`GridView.builder` /
  `ListView.builder`) — a flat, unbounded list of loaded items is FORBIDDEN.
- Pagination MUST be cursor-based per the contract (`cursor` + `next_cursor`);
  offset/page pagination MUST NOT be introduced client-side.
- A `VideoPlayerController` MUST be disposed when its tile leaves the viewport
  and re-created when it returns. The number of simultaneously initialized
  controllers MUST be bounded (only visible/near-visible tiles).
- List/grid tiles MUST autoplay the low-res `preview_video_url` (muted,
  looping); the full-resolution file is fetched ONLY via `download-url` at
  set/download time, never for browsing.
- The next page MUST be requested when the scroll position nears the end, not
  all at once; `has_more: false` ends pagination.

**Rationale**: Server-side pagination solves only half the problem. Without
per-tile controller disposal, scrolling a video grid exhausts device memory
and decoder handles within seconds.

### III. BLoC-Driven State Management

All state MUST use the BLoC pattern via `flutter_bloc`, with unidirectional
flow (Events → BLoC → State → UI) and a consistent 4-state shape.

- Features manage state through Cubits (preferred) or Blocs; widgets react to
  state only and MUST NOT contain business logic.
- State classes MUST be immutable `@freezed` sealed classes.
- Mandatory 4-state pattern:
  `initial → loading → loaded({required T data}) → error({required AppFailure failure})`.
  Extended variants MUST prefix the base name (`loadingMore`,
  `loadedWithFilter`) — NOT `success`/`failed`/`empty`.
- Side effects (navigation, toasts, sheets, haptics) MUST be triggered from
  `BlocListener`, never `BlocBuilder`.
- Cubit-to-Cubit communication MUST go through shared repositories/streams —
  never direct Cubit references. All Cubits MUST be closed.
- `bloc_lint` MUST report zero violations.
- DI: domain/shared Cubits → `@lazySingleton`; screen-scoped Cubits →
  `@injectable`. `@singleton` (eager) is FORBIDDEN. `BlocProvider` is
  page-scoped unless app-wide lifetime is explicitly required.

**Rationale**: A predictable state machine keeps loading/error handling
uniform across Browse, Collections, Detail, Favorites, and Paywall — the
places where pagination and IAP state are easy to get wrong.

### IV. Result\<T\> Error Handling

All async operations that can fail MUST return `Result<T>` rather than
throwing. Exceptions are reserved for programmer error.

- Repository methods MUST return `Result<T>`.
- `AppFailure` MUST be a sealed class enumerating the app's known failures,
  at minimum:
  - `network`, `timeout`, `serverUnavailable`
  - `notFound` (wallpaper/collection removed by admin)
  - `validation` (bad request / invalid cursor)
  - `entitlementRequired` (premium content, no active subscription)
  - `receiptInvalid`, `receiptConflict`, `storeUnavailable`
  - `downloadFailed`, `fileWriteFailed`
  - `wallpaperSetFailed`, `platformUnsupported`
  - `unknown({String? message, Object? error})`
- Cubits MUST resolve `Result<T>` via `.fold()` — `loaded` on success,
  `error` on failure. try/catch inside Cubits is FORBIDDEN; repositories
  catch and wrap.
- User-facing messages MUST come from an `AppFailure` → localized-string
  mapping — NEVER raw exception text, HTTP bodies, or backend error codes.

**Rationale**: Network, IAP, and native-set failures are the norm on mobile,
not the exception. Explicit `Result<T>` forces each to be handled where it
occurs.

### V. Server-Authoritative Entitlement (No Local Premium Decisions)

The client MUST NEVER decide, cache, or infer that a user is Premium. The
backend is the sole authority.

- Premium is proven only by a `transaction_id` the backend verifies against
  the App Store / Play. Purchases go through `in_app_purchase`, then the
  receipt is sent to `POST /iap/verify-receipt`; entitlement UI reflects the
  backend response, not the store callback alone.
- A premium wallpaper's full file MUST be gated at
  `GET /wallpapers/{id}/download-url` (which returns `402
  ENTITLEMENT_REQUIRED` when unentitled). The app MUST NOT unlock a download
  based on any local flag.
- A premium Collection is unlocked at the SAME gate — "Tải tất cả" iterates
  `download-url` per item; the collection cover only shows "Mở khoá" based on
  `is_premium`, it does not grant access.
- `transaction_id` is treated as sensitive: it MUST NOT appear in logs,
  analytics, or crash reports, and MUST be stored via a secure store, not
  plain preferences.

**Rationale**: With no accounts, `transaction_id` verification is the only
thing standing between free and paid content. Any client-side entitlement
shortcut is a trivial bypass.

### VI. Design System & Theming

The app MUST reproduce the handoff design system (the
`livecanvas-detail-screens` bundle) through centralized theme tokens. Visual
values MUST come from tokens — never hardcoded at call sites.

- Design tokens (colors, spacing, radii, typography, elevation, fonts) MUST be
  ported from the handoff `_ds/.../tokens/*` into a single `lib/core/theme/`
  source and consumed everywhere.
- Colors MUST come from the theme/token layer — raw `Color(0xFF...)` / hex at
  call sites is FORBIDDEN. The app's dark "aurora" surface, glass chrome, and
  per-wallpaper accent glow (`aura`) are theme concerns, not inline styles.
- Spacing and radii MUST use named token constants — no magic pixel numbers.
- Typography MUST use the token text styles (display / body / mono) — no
  inline `.copyWith` for shared type values.
- Icons MUST use the Phosphor set (matching the design) via a single icon
  dependency — Flutter's built-in `Icons`/`CupertinoIcons` MUST NOT be mixed
  in for content icons.
- Shared UI (WallpaperCard, TabBar, TopBar, PremiumBadge, sheets, toasts) MUST
  be built as reusable widgets in `lib/core/widgets/`, faithful to the
  prototype, rather than re-implemented per screen.

**Rationale**: The prototype is the product's visual contract. Centralized
tokens make the aurora theme consistent and let the accent-glow system work
uniformly across tiles and detail chrome.

### VII. Platform Integration (Android Live Wallpaper / iOS Shortcuts)

The app MUST respect each platform's real capabilities for setting a video
wallpaper and adapt responsively across form factors.

- **Android**: setting a live wallpaper MUST go through a `WallpaperService`
  implementation invoked over a Method Channel; the confirm flow uses the
  system live-wallpaper chooser.
- **iOS/iPadOS**: Apple provides no public API to set a video wallpaper
  directly. The app MUST present a preview + guided Shortcuts flow (convert to
  Live Photo `.heic`+`.mov`) and MUST clearly explain this in-app and in App
  Review notes — it MUST NOT pretend to set the wallpaper programmatically.
- Layouts MUST support all iPhone sizes (notch / Dynamic Island) and adapt for
  iPad/tablet (responsive grid columns), matching the handoff `ipad.html`
  where provided.
- Haptic feedback MUST accompany key actions (favorite, download, set, tab
  switch) where the platform supports it.

**Rationale**: The Android/iOS capability gap is fundamental to this product.
Hiding it produces broken flows on iOS and rejected App Store submissions.

### VIII. Method Channel Architecture

Platform-specific features MUST use domain-separated Method Channels with a
single responsibility and structured error mapping.

- Channel naming: `com.livecanvas/{domain}` (e.g. `com.livecanvas/wallpaper`).
  Channel and method names MUST be centralized in
  `lib/core/constants/channel_methods.dart` — never hardcoded at call sites.
- Native errors MUST be mapped to `AppFailure` variants
  (`wallpaperSetFailed`, `platformUnsupported`, `fileWriteFailed`) — raw
  platform exceptions MUST NOT reach the UI.
- Cross-boundary data MUST use explicit DTOs, not domain models.

**Rationale**: A single monolithic bridge becomes unmaintainable; typed,
domain-scoped channels keep native failures debuggable and mapped.

### IX. Local-First, Account-Free Data

The app has no login. Favorites and download history are device-local; remote
data is always re-fetched fresh.

- Favorites MUST store ONLY wallpaper IDs locally. Full wallpaper data MUST be
  re-fetched via `POST /wallpapers/batch` each time the Favorites screen
  opens — the app MUST NOT cache and render stale wallpaper objects (a
  wallpaper may have been edited/removed by admin).
- IDs missing from a `batch` response mean the wallpaper was removed; the app
  MUST reconcile local state (drop the favorite) rather than error.
- Local persistence MUST hold only non-sensitive references (IDs, timestamps);
  `transaction_id` is the one exception and MUST use secure storage
  (Keychain / Keystore).

**Rationale**: Caching full content locally guarantees stale UI and larger
attack/PII surface for no benefit; IDs + refetch keeps the app correct and
light.

### X. go_router Navigation Standards

All navigation MUST use `go_router` with centralized route constants.

- Route paths MUST be constants in an `AppRoutes` abstract final class — no
  hardcoded path strings.
- Navigate ONLY via `context.go()` / `context.push()` / `context.pop()` —
  `Navigator.of(context)` direct use is FORBIDDEN.
- The 5-tab shell (Khám phá / Tìm / Bộ sưu tập / Yêu thích / Bạn) MUST use
  `StatefulShellRoute.indexedStack` for tab-state persistence; full-screen
  pushes (Wallpaper Detail, Collection Detail) cover the shell.
- Modals/sheets (Paywall, Set Wallpaper, Share) that dismiss-then-open MUST
  dismiss first and open in `addPostFrameCallback` — two sheets MUST NOT be
  pushed in the same frame.

**Rationale**: Centralized routing keeps the tab stack and full-screen push
model (from the prototype's `App` component) predictable and testable.

### XI. Feature-First Modularity

The codebase MUST be organized by feature using Clean Architecture; each
feature is independently developable and testable.

- Structure:
  ```
  lib/
    core/          # config, constants, di, domain (Result/AppFailure),
                   # router, services, theme, widgets, l10n
    features/
      <feature>/
        data/          # repositories impl, data sources (generated client)
        domain/        # models, repo interfaces, use cases
        presentation/  # cubits, pages, widgets
  ```
- `lib/core/` MUST NOT import from `lib/features/*`.
- `lib/features/<A>/` MUST NOT import internal files of `lib/features/<B>`.
- Domain MUST NOT import data-layer implementations. Repository→Repository
  dependencies are FORBIDDEN — orchestrate via a UseCase or core Service.
- DI via get_it + injectable (`@lazySingleton` / `@injectable`; never
  `@singleton`).

**Rationale**: Clear feature boundaries let Browse, Collections, Favorites,
Wallpaper-Set, and Paywall evolve in parallel without cross-contamination.

### XII. Build Flavors & Environment Config

The project MUST ship with EXACTLY TWO build flavors: **`development`** and
**`production`**. No `staging` and no additional flavors may be introduced.

- The project MUST be scaffolded with **`very_good_cli`**
  (`very_good create flutter_app`). `very_good_cli` generates
  development/staging/production by default; the **`staging` flavor MUST be
  removed** during bootstrap (entrypoint `lib/main_staging.dart`, its build
  configs, and all iOS/Android `Staging` schemes/build types), leaving only
  `development` and `production`.
- Each flavor MUST have its own entrypoint (`lib/main_development.dart`,
  `lib/main_production.dart`) and its own environment config — most
  importantly the backend base URL (development → staging-api; production →
  production API). Base URLs MUST NOT be hardcoded in feature code; they come
  from the flavor's config object.
- Adding a third flavor, or hardcoding an environment switch outside the
  flavor config, requires a constitution amendment — it is not a routine
  change.
- Run/build commands are flavor-explicit, e.g.
  `flutter run --flavor development -t lib/main_development.dart`.

**Rationale**: Two flavors (a dev build pointed at staging infra, a release
build pointed at production) cover this app's needs. `staging` as a third
flavor adds signing, scheme, and config surface with no product value here,
and the user has explicitly scoped the app to dev + production only.

### XIII. Testing Discipline

Unit tests are REQUIRED for business logic; BLoC tests for all Cubits; widget
tests for critical flows.

- Unit tests MUST cover: repositories, cursor-pagination logic, favorites
  reconciliation (batch), entitlement/IAP mapping, `AppFailure` mapping.
- BLoC tests MUST cover every Cubit using `bloc_test`.
- Widget tests MUST cover: Browse grid pagination + controller disposal,
  Wallpaper Detail, Paywall/purchase flow, Set-Wallpaper flow (mocked
  channel).
- Tests MUST be deterministic (no flakiness) and use `mocktail` for mocks.
- Coverage is NOT gated by a hard CI threshold; reviewers judge adequacy by
  critical-path coverage. Standard command:
  `very_good test --test-randomize-ordering-seed random`.

**Rationale**: Pagination/controller lifecycle and IAP entitlement are the two
areas where silent bugs are worst (crashes and revenue leaks); they must be
verified.

### XIV. Simplicity & YAGNI

The app MUST stay focused on browsing, downloading, and setting wallpapers.
Complexity MUST be justified by a concrete, current need.

- Start with the simplest viable implementation per feature.
- Prefer the Flutter/Dart standard library over a package when capability is
  equivalent; each package MUST be justified.
- Do NOT add accounts, cloud sync, social/sharing backends, or feature-flag
  systems unless a spec explicitly scopes them.
- Three similar lines beat a premature abstraction.

**Rationale**: A content browser + IAP app has a small essential core;
over-engineering it only adds bugs and binary size.

### XV. Internationalization by Default

All user-facing strings MUST be internationalized via Flutter's ARB-based i18n
— no hardcoded UI strings.

- Strings live in ARB files under `lib/l10n/arb/`, accessed via
  `context.l10n`; new strings include `@description`.
- Dates/numbers/durations MUST use `intl` locale-aware formatters.
- Primary language: **Vietnamese** (the product's audience and the entire
  prototype copy); Secondary: English.

**Rationale**: The design ships in Vietnamese; treating strings as localizable
from day one avoids a costly retrofit and keeps copy reviewable.

### XVI. Dependency Hygiene

When adding or upgrading any third-party package, the version and docs MUST
come from the official source — never guessed or copied from another project.

- Before editing `pubspec.yaml`, the latest stable version MUST be looked up
  on `pub.dev` (and CocoaPods/SPM upstream for native pods). New deps use a
  caret constraint pinned to latest stable; `any`/open ranges are FORBIDDEN.
- Official docs MUST be consulted for API surface, breaking changes,
  transitive native deps, and minimum platform versions — inferring API shape
  from memory is FORBIDDEN.
- MAJOR-version upgrades MUST review the CHANGELOG/migration guide before the
  bump, with a one-line note of impact (or "no breaking changes affect
  LiveCanvas").
- `pubspec.lock` and `ios/Podfile.lock` MUST be committed; unexpected version
  churn in a PR MUST be reviewed.
- Every package MUST exist on pub.dev under the exact name written; if not
  found, STOP and ask — do not guess a similar name.

**Rationale**: Late-binding dependency conflicts (especially iOS pod
triangles) waste implementation time after Dart code is written; a 30-second
pub.dev check at plan time prevents rework and fictional packages.

## Technical Standards

### Platform & Stack

- **Framework**: Flutter (latest stable, verified at bootstrap) with Dart
  (matching stable SDK). Scaffolded via **`very_good_cli`**.
- **Target platforms**: Android (live wallpaper) + iOS/iPadOS (preview +
  Shortcuts) + tablet responsive.
- **Build flavors**: `development`, `production` — EXACTLY these two (see
  Principle XII).
- **Architecture**: Clean Architecture + feature-first.
- **State**: Cubit (preferred) / BLoC via `flutter_bloc`.
- **API client**: generated from `contracts/openapi.yaml`
  (`openapi-generator -g dart-dio`).
- **Networking**: Dio (via the generated dart-dio client) with an `X-App-Key`
  interceptor for public/IAP endpoints.
- **Video**: a maintained video playback package (e.g. `video_player`) with
  strict controller lifecycle per Principle II — exact version fetched at plan
  time (Principle XVI).
- **DI**: get_it + injectable.
- **Router**: go_router with `StatefulShellRoute`.
- **Theme**: design tokens ported from the handoff `_ds` bundle.
- **Icons**: Phosphor icon set (to match the design).
- **IAP**: `in_app_purchase` (self-written verify via backend; no RevenueCat).
- **Secure storage**: Keychain/Keystore for `transaction_id`; lightweight
  local store for favorite/history IDs.
- **Linting**: `very_good_analysis` + `bloc_lint` (zero warnings).
- **Testing**: `bloc_test`, `mocktail`, `very_good test`.
- **i18n**: Flutter ARB + `intl` (Vietnamese primary, English secondary).

### Screens (from `docs/screen-inventory.md`)

Browse · Search · Collections (list + detail) · Wallpaper Detail (video
preview) · Favorites · Paywall/Premium · Set-Wallpaper (Android confirm /
iOS Shortcuts). Admin screens are backend-side and out of scope for the app.

## Development Workflow

### Pre-Commit Checklist (MANDATORY)

```bash
dart format .                    # Format
flutter analyze                  # Zero warnings
very_good test                   # All tests pass
dart run bloc_tools:bloc lint .  # Zero BLoC violations
```

### Testing Gates

Every PR MUST pass: all unit/BLoC/widget tests; `flutter analyze` zero
warnings; `bloc_lint` zero violations; `dart format` verified. The generated
API client MUST be regenerated (not hand-edited) when the contract changes.

### Review Requirements

- All changes reviewed before merge.
- IAP/entitlement changes and Method Channel (native set) changes receive
  extra scrutiny.
- New packages MUST be justified and version-checked (Principle XVI).
- Any contract change MUST be mirrored to the backend repo (Contract Sync)
  in the same or a linked PR.

### Quality Checks

- Browse/Collection grids MUST be profiled while fast-scrolling to confirm
  `VideoPlayerController` count stays bounded and memory is flat.
- Purchase flow MUST be verified: buy, restore, verify-receipt success,
  `402 ENTITLEMENT_REQUIRED`, store-unavailable.
- Android set-wallpaper and the iOS Shortcuts guide MUST both be exercised on
  device.

## Governance

This constitution establishes non-negotiable principles for LiveCanvas Mobile
development. All implementation decisions MUST align with these principles.

### Amendment Process

1. Proposed amendments MUST be documented with rationale.
2. Amendments MUST be reviewed for impact on existing code.
3. Breaking changes require a migration plan before approval.
4. Version increments follow semantic versioning:
   - MAJOR: principle removal or incompatible redefinition (e.g. adding a
     third build flavor, or allowing client-side entitlement).
   - MINOR: a new principle or material expansion.
   - PATCH: clarification or wording refinement.

### Compliance

- All PRs MUST verify compliance with relevant principles.
- Complexity beyond these standards MUST be explicitly justified.
- Deviations MUST be documented with rationale and approved by the project
  lead.
- Use `CLAUDE.md` (when present) for runtime development guidance; planning
  status lives in `.claude/project-context.md` and `.claude/sdd-roadmap.md`.

**Version**: 1.0.0 | **Ratified**: 2026-07-23 | **Last Amended**: 2026-07-23
