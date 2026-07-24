---
description: "Task list — MO-002 Foundation, Navigation & Design System"
---

# Tasks: Foundation, Navigation & Design System (MO-002)

**Input**: Design documents from `specs/MO-002-foundation-navigation/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/ui-contracts.md](contracts/ui-contracts.md)

**Tests**: Bao gồm test (không phải TDD tuỳ chọn thuần) — Constitution Principle XIII + FR-016 + SC-008 yêu cầu CI test gate xanh & `bloc_lint` 0 vi phạm.

**Foundation-only**: KHÔNG logic list/pagination/API thật (→ MO-003). Thân tab = placeholder; tab "Bạn" = shell rỗng.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: chạy song song được (khác file, không phụ thuộc task chưa xong)
- **[Story]**: US1/US2/US3/US4 (Setup/Foundational/Polish không gắn nhãn story)

## Path Conventions

Mobile Flutter single-codebase (theo [plan.md](plan.md) §Project Structure): `lib/core/`, `lib/features/`, `assets/fonts/`, `scripts/`, `test/`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Đổi dependency icon, tải font, dựng khung thư mục.

- [X] T001 Đổi dependency icon trong `pubspec.yaml`: gỡ `phosphor_flutter`, thêm `phosphoricons_flutter: ^1.0.0` (version R1 [research.md](research.md)); chạy `flutter pub get`, xác nhận solver sạch, commit `pubspec.lock`.
- [X] T002 [P] Tạo `scripts/fetch_fonts.sh` tải TTF về `assets/fonts/` (Clash Display 400/500/600/700 · Satoshi 400/500/700/900 · Space Mono 400/700 — nguồn Fontshare + Google Fonts theo R5) + `assets/fonts/README.md` ghi nguồn/license (ITF Free + OFL); chạy script, commit TTF.
- [X] T003 [P] Dựng khung thư mục theo [plan.md](plan.md): `lib/core/{theme,widgets/{controls,navigation,wallpaper,feedback,sheet},router,responsive}` và `lib/features/{browse,search,collections,favorites,profile,wallpaper_detail,collection_detail,dev_gallery}/presentation/pages`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Substrate mọi user story cần — token màu, theme dark nền, router skeleton, icon Phosphor, responsive, i18n. Đây là hạ tầng dùng chung (Principle VI/X/XI); các nhóm typography/spacing/elevation đầy đủ nằm ở US2.

**⚠️ CRITICAL**: Không user story nào bắt đầu trước khi phase này xong.

- [X] T004 Implement `lib/core/theme/app_colors.dart` — toàn bộ token màu "Void" + alias ngữ nghĩa + `aurora`/`auroraSoft` gradient (từ `colors.css` §data-model 1.1). Không hardcode nơi khác (FR-002).
- [X] T005 [P] Khai báo 3 font family trong `pubspec.yaml` `flutter: fonts:` trỏ TTF ở `assets/fonts/` (đủ weight R5).
- [X] T006 [P] Implement `lib/core/theme/app_theme.dart` nền — `ThemeData` dark-only (scaffoldBackground = bgApp, `colorScheme.dark` từ `AppColors`); TextTheme/typography hoàn thiện ở US2.
- [X] T007 [P] Implement `lib/core/responsive/breakpoints.dart` — helper phone/tablet (ngưỡng ~600dp) qua `MediaQuery`/`LayoutBuilder` (FR-011b).
- [X] T008 [P] Implement `lib/core/theme/app_icons.dart` — nguồn đơn ánh xạ tên icon prototype → `PhosphorIcons*` (regular/bold/fill) dùng toàn app (FR-005; cấm `Icons.*`/`CupertinoIcons`).
- [X] T009 Implement `lib/core/router/app_routes.dart` (route constants §data-model 3.1) + `lib/core/router/app_router.dart` — `StatefulShellRoute.indexedStack` 5 branch skeleton, wire vào `MaterialApp.router`, đăng ký DI (get_it/injectable).
- [X] T010 Mở rộng ARB (`lib/l10n/arb/app_vi.arb` + `app_en.arb`) — nhãn 5 tab (Khám phá/Tìm/Bộ sưu tập/Yêu thích/Bạn) + chuỗi placeholder (FR-015, không hardcode).

**Checkpoint**: Substrate sẵn sàng — user story có thể bắt đầu.

---

## Phase 3: User Story 1 - Điều hướng khung 5 tab giữ trạng thái (Priority: P1) 🎯 MVP

**Goal**: App điều hướng 5 tab, mỗi tab giữ state riêng; Detail/Collection push phủ tab, back về đúng tab.

**Independent Test**: Chạm 5 tab đổi body; cuộn tab A → sang B → về A giữ vị trí; mở route Detail placeholder phủ full-screen, back về đúng tab nguồn; tab "Bạn" là shell rỗng.

- [X] T011 [P] [US1] Implement `lib/core/widgets/navigation/app_tab_bar.dart` — `AppTabBar(items, currentIndex, onTap)`, cao `tabbarH 64`, icon active weight `fill` (dùng `AppColors`/`AppIcons`; contract §A).
- [X] T012 [P] [US1] Implement `lib/core/widgets/navigation/top_bar.dart` — `TopBar(title? | wordmark, trailing?)`, glass blur `blurBar` (contract §A).
- [X] T013 [US1] Nối 5 `StatefulShellBranch` với placeholder page (browse/search/collections/favorites) + `profile` shell rỗng `TopBar(title:"Bạn")`, dùng `AppTabBar` trong shell scaffold (phụ thuộc T009, T011, T012).
- [X] T014 [P] [US1] Thêm route top-level `wallpaperDetail /wallpaper/:id` + `collectionDetail /collection/:id` (push phủ shell, placeholder page) trong `app_router.dart` (FR-008).
- [X] T015 [US1] Implement placeholder tab body pages `lib/features/{browse,search,collections,favorites}/presentation/pages/*_placeholder_page.dart` — skeleton hợp theme (FR-011).
- [X] T016 [US1] Test điều hướng `test/core/router/app_router_test.dart` — 5-tab switch, giữ state per-tab (indexedStack), Detail push/pop trả về đúng tab nguồn (SC-001).

**Checkpoint**: US1 chạy độc lập — MVP khung điều hướng.

---

## Phase 4: User Story 2 - Hệ thống thiết kế trung thực (Priority: P2)

**Goal**: Toàn app áp đúng token (màu/spacing/typography/elevation), 3 font bundle, icon Phosphor; 0 hardcode.

**Independent Test**: So sánh thị giác với prototype; chữ đúng 3 font theo type scale (tắt mạng vẫn đúng); mọi icon Phosphor; grep 0 hardcode màu/px ngoài `lib/core/theme/`.

- [X] T017 [P] [US2] Implement `lib/core/theme/app_spacing.dart` — spacing grid 4px + gutter/gridGap + radii + control sizing + `wallRatio 9/16` (§data-model 1.2).
- [X] T018 [P] [US2] Implement `lib/core/theme/app_typography.dart` — 3 family + type scale (40/28/22/18/15/13/11/10) + line-height + weights + letter-spacing → `TextTheme` + styles đặt tên (§data-model 1.3).
- [X] T019 [P] [US2] Implement `lib/core/theme/app_elevation.dart` — `shadow1/2/3`, `shadowSheet`, Aura (`auraBlur/Spread`, màu tham số), blur backdrop (§data-model 1.4).
- [X] T020 [US2] Hoàn thiện `app_theme.dart` — gắn `TextTheme` (fontFamily Satoshi mặc định) + component theme dùng `AppSpacing`; dark-only; xác nhận wire `MaterialApp.router` (phụ thuộc T006, T017, T018, T019).
- [X] T021 [US2] Áp typography/theme lên nav shell — `TopBar` wordmark = Clash Display + aurora gradient; nhãn tab dùng typography token (thay style tạm từ US1).
- [X] T022 [US2] Audit 0-hardcode + guard hiến pháp: `grep -rnE "Color\(0x|EdgeInsets\.(all|symmetric)\([0-9]" lib/` chỉ khớp trong `lib/core/theme/`; loại mọi `Icons.*`/`CupertinoIcons` icon nội dung (SC-002, SC-004); `grep -rn "Navigator.of(" lib/` = 0 (Principle X / FR-009); `grep -rn "package:.*/features/" lib/core/` = 0 (core không import features — Principle XI / FR-013).
- [X] T023 [US2] Test `test/core/theme/app_theme_test.dart` — token/typography đúng; xác nhận 3 font resolve từ asset (không mạng) (SC-003).

**Checkpoint**: US1 + US2 độc lập — khung đã trung thực thiết kế.

---

## Phase 5: User Story 3 - Thư viện widget dùng chung + gallery (Priority: P2)

**Goal**: Bộ shared widget nội dung + màn gallery demo dev-only để đối chiếu prototype.

**Independent Test**: Mở `/dev/gallery` → từng widget render khớp prototype; PremiumBadge = PRO aurora không icon khoá; WallpaperCard có Aura glow theo `auraColor`.

- [X] T024 [P] [US3] Implement `AppButton` + `AppIconButton` trong `lib/core/widgets/controls/` (contract §A).
- [X] T025 [P] [US3] Implement `FilterChip` + `MetaChip` trong `lib/core/widgets/controls/` (MetaChip = Space Mono).
- [X] T026 [P] [US3] Implement `PremiumBadge` trong `lib/core/widgets/wallpaper/` — "PRO" aurora gradient text, KHÔNG icon khoá (guideline premium-treatment).
- [X] T027 [US3] Implement `WallpaperCard` trong `lib/core/widgets/wallpaper/` — preview placeholder gradient, Aura glow theo `auraColor`, title/author, `premium→PremiumBadge`, `meta→MetaChip`, fav (phụ thuộc T025, T026).
- [X] T028 [P] [US3] Implement `EmptyState` trong `lib/core/widgets/feedback/`.
- [X] T029 [P] [US3] Implement `AppSheet` (`lib/core/widgets/sheet/`, quy tắc đóng-rồi-mở `addPostFrameCallback` — FR-010) + `Toast` (`lib/core/widgets/feedback/`).
- [X] T030 [US3] Implement màn gallery demo `lib/features/dev_gallery/presentation/pages/dev_gallery_page.dart` + route `/dev/gallery` (dev-only, ẩn khỏi production — FR-006a) trưng bày mọi widget với dữ liệu mẫu (hình dạng theo `data.js`).
- [X] T031 [US3] Widget test `test/core/widgets/` — render + bề mặt public từng shared widget (SC-005).

**Checkpoint**: US1 + US2 + US3 độc lập — thư viện widget sẵn cho MO-003.

---

## Phase 6: User Story 4 - Mock server độc lập backend (Priority: P3)

**Goal**: Prism mock từ contract; app dev render dữ liệu mẫu không cần backend.

**Independent Test**: `scripts/mock_server.sh` khởi động 1 lệnh; `curl` endpoint chính trả payload đúng schema; app development trỏ mock render được.

- [X] T032 [US4] Tạo `scripts/mock_server.sh` — `npx @stoplight/prism-cli@5.16.0 mock contracts/openapi.yaml -p 4010` (contract §C).
- [X] T033 [US4] Nối flavor `development`: `AppConfig.apiBaseUrl` → mock (`http://localhost:4010`, Android emulator `http://10.0.2.2:4010`) trong `lib/core/config/` (không hardcode nơi khác — Principle XII).
- [X] T034 [US4] Nghiệm thu mock: script chạy, `curl` `GET /wallpapers`,`/collections`,`/tags` trả schema hợp lệ; ghi bước vào [quickstart.md](quickstart.md) (SC-007).

**Checkpoint**: Cả 4 story độc lập hoàn chỉnh.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Đồng bộ docs, đảm bảo CI xanh, nghiệm thu tổng.

- [X] T035 [P] Cập nhật `.claude/`: `sdd-roadmap.md` (MO-002 status), `changelog.md`, `project-context.md` (Current Focus sang MO-002 done / MO-003 next).
- [X] T036 CI 4 gate xanh: `dart format --set-exit-if-changed .`, `flutter analyze` (0 warning), `very_good test`, `bloc lint .` (0 vi phạm) — sửa nếu đỏ (SC-008). Kèm guard grep từ T022 (`Navigator.of(` = 0, `lib/core` không import `lib/features`) như bước chặn trước merge (Principle X/XI).
- [X] T037 Chạy [quickstart.md](quickstart.md) end-to-end trên iOS + Android + iPad simulator; xác nhận đủ 8 SC; ghi evidence.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (P1)**: không phụ thuộc — bắt đầu ngay.
- **Foundational (P2)**: sau Setup — **BLOCKS mọi user story**.
- **User Stories (P3–P6)**: sau Foundational.
  - **US1 (P1)** là MVP — làm trước.
  - **US2 (P2)** và **US3 (P2)** độc lập nhau, có thể song song sau Foundational (khác file: theme/* vs widgets/*). US2 nên xong sớm để US1/US3 trung thực thị giác, nhưng US1 đã test được về chức năng trước US2.
  - **US4 (P3)** độc lập, có thể làm bất cứ lúc nào sau Setup (chỉ chạm scripts/ + config).
- **Polish (P7)**: sau các story mong muốn.

### User Story Dependencies

- **US1**: chỉ cần Foundational. Không phụ thuộc story khác (dùng AppColors/theme nền từ Foundational).
- **US2**: cần Foundational (mở rộng theme). Áp lên shell US1 nhưng US1 test chức năng độc lập trước.
- **US3**: cần Foundational + token US2 để render chuẩn (WallpaperCard dùng typography/elevation). Test độc lập qua gallery.
- **US4**: chỉ cần Setup + config; độc lập UI hoàn toàn.

### Within Each Story

- Widget atoms trước composite (T025/T026 trước T027).
- Theme token nhóm trước khi hoàn thiện `app_theme` (T017–T019 trước T020).
- Implementation trước test của story.

### Parallel Opportunities

- Setup: T002, T003 song song.
- Foundational: T005, T006, T007, T008 song song (sau/độc lập T004); T009/T010 sau khi có AppColors.
- US1: T011, T012 song song; T014 song song với T013.
- US2: T017, T018, T019 song song; T020 sau đó.
- US3: T024, T025, T026, T028, T029 song song; T027 sau T025/T026; T030/T031 sau widget.
- Cross-story: sau Foundational, US2 + US3 + US4 có thể do người khác nhau làm song song.

---

## Parallel Example: User Story 3

```bash
# Atoms song song:
Task: "AppButton + AppIconButton in lib/core/widgets/controls/"
Task: "FilterChip + MetaChip in lib/core/widgets/controls/"
Task: "PremiumBadge in lib/core/widgets/wallpaper/"
Task: "EmptyState in lib/core/widgets/feedback/"
Task: "AppSheet + Toast in lib/core/widgets/{sheet,feedback}/"
# → rồi mới WallpaperCard (T027) vì phụ thuộc MetaChip + PremiumBadge.
```

---

## Implementation Strategy

### MVP First (User Story 1)

1. Phase 1 Setup → 2. Phase 2 Foundational (BLOCKS) → 3. Phase 3 US1 → **STOP & VALIDATE** điều hướng 5 tab giữ state → demo khung.

### Incremental Delivery

1. Setup + Foundational → substrate.
2. + US1 → khung điều hướng (MVP).
3. + US2 → hệ thống thiết kế trung thực (áp lên khung).
4. + US3 → thư viện widget + gallery.
5. + US4 → mock server (phát triển độc lập backend).
6. Polish → docs + CI xanh + nghiệm thu 8 SC.

### Parallel Team Strategy

Sau Foundational: Dev A → US1; Dev B → US2; Dev C → US3; US4 ai rảnh cũng làm được (chỉ scripts/config).

---

## Notes

- [P] = khác file, không phụ thuộc. [Story] = truy vết tới user story.
- Mỗi story hoàn thành + test được độc lập (checkpoint).
- Foundation-only: KHÔNG list/pagination/API thật, KHÔNG video, KHÔNG freezed/palette_generator (→ MO-003).
- Commit sau mỗi task hoặc nhóm logic; dừng ở checkpoint để nghiệm thu.
- Icon: chỉ `PhosphorIcons*` (phosphoricons_flutter); màu/spacing/typography chỉ từ `lib/core/theme/`.
