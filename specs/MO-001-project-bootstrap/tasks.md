# Tasks: Project Bootstrap & Flavors (MO-001)

**Input**: Design documents from `/specs/MO-001-project-bootstrap/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/bootstrap-interfaces.md](contracts/bootstrap-interfaces.md), [quickstart.md](quickstart.md)

**Tests**: Constitution XIII yêu cầu test cho critical path — MO-001 giữ mức tối thiểu có ý nghĩa: 1 widget test placeholder (giữ CI gate có test thật) + 1 unit test interceptor. Không TDD-first cho task scaffold/cấu hình.

**Organization**: Task nhóm theo user story của spec.md. Lưu ý bootstrap có tính tuần tự cao — [P] chỉ đánh ở task thật sự độc lập file.

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup (Tooling & Scaffold)

**Purpose**: Máy dev đủ toolchain + project very_good được scaffold vào repo root

- [ ] T001 Cài/upgrade toolchain trên máy dev: `flutter upgrade` tại `~/Documents/develop/flutter` lên 3.44.7 stable + thêm `bin` vào PATH; `dart pub global activate very_good_cli 1.3.0`; `dart pub global activate bloc_tools`; `brew install temurin` (Java cho openapi-generator — máy hiện CHƯA có); verify `flutter doctor`, `java -version`, `npx --version`
- [ ] T002 Scaffold `very_good create flutter_app livecanvas --desc "LiveCanvas — live wallpaper app" --org "com.livecanvas"` vào thư mục tạm, move toàn bộ nội dung vào repo root (GIỮ nguyên `.git/`, `.claude/`, `.specify/`, `specs/`, `LICENSE`; merge nội dung README template vào `README.md`); commit mốc scaffold nguyên bản
- [ ] T003 Baseline xanh: `flutter pub get` → `flutter test` pass trên template nguyên bản; commit `pubspec.lock`

**Checkpoint**: Repo có project Flutter chạy được (còn 3 flavor template — gỡ staging ở US1)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Dependency nền + khung thư mục + lint config mà MỌI story phía sau cần

**⚠️ CRITICAL**: Hoàn thành trước khi vào bất kỳ user story nào

- [ ] T004 Cập nhật `pubspec.yaml` theo bảng version [research.md](research.md) R1 (caret pin, KHÔNG đoán): deps `flutter_bloc ^9.1.1`, `get_it ^9.2.1`, `injectable ^3.0.0`, `go_router ^17.3.0`, `dio ^5.10.0`, `phosphor_flutter ^2.1.0`, `intl ^0.20.3` (hạ theo pin flutter_localizations nếu pub solve kêu), `json_annotation ^4.12.0`; dev_deps `very_good_analysis ^10.3.0`, `bloc_lint ^0.4.2`, `bloc_test ^10.0.0`, `mocktail ^1.0.5`, `injectable_generator ^3.1.1`, `build_runner ^2.15.2`, `json_serializable ^6.14.0`; `flutter pub get` sạch, commit `pubspec.lock`
- [ ] T005 Dựng khung thư mục Principle XI: `lib/core/{config,constants,di,router}/` (+ `.gitkeep` cho `lib/features/`); XOÁ feature counter của template (`lib/counter/`, test counter liên quan) — placeholder page thay thế làm ở T011
- [ ] T006 [P] `analysis_options.yaml`: include `package:very_good_analysis/analysis_options.yaml` + `package:bloc_lint/recommended.yaml`; `flutter analyze` 0 warning trên khung hiện tại

**Checkpoint**: Nền sẵn — US1 bắt đầu được

---

## Phase 3: User Story 1 — Chạy app theo đúng 2 môi trường (Priority: P1) 🎯 MVP

**Goal**: 2 flavor development/production chạy được iOS + Android, `staging` biến mất hoàn toàn, config môi trường tập trung

**Independent Test**: [quickstart.md](quickstart.md) V1 — 4/4 tổ hợp boot hiển thị đúng environment; chạy flavor staging phải lỗi; grep `staging` sạch

- [ ] T007 [US1] Tạo `lib/core/config/app_config.dart`: enum `AppEnvironment {development, production}` + class `AppConfig {environment, apiBaseUrl, appKey}` immutable theo [data-model.md](data-model.md); factory/const cho từng flavor — development: baseUrl platform-aware (`Platform.isAndroid ? 'http://10.0.2.2:8000' : 'http://localhost:8000'`), dev appKey commit thẳng; production: placeholder `https://api.livecanvas.example` (TODO chốt domain) + `appKey = String.fromEnvironment('APP_KEY')`
- [ ] T008 [US1] Entrypoints: sửa `lib/main_development.dart` + `lib/main_production.dart` gọi `bootstrap(AppConfig.development()/.production())` (sửa `lib/bootstrap.dart` nhận `AppConfig`); XOÁ `lib/main_staging.dart`
- [ ] T009 [US1] Gỡ staging Android: xoá flavor `staging` khỏi `android/app/build.gradle` (productFlavors) + mọi resource/config staging kèm theo; verify `cd android && ./gradlew tasks | grep -i staging` → rỗng
- [ ] T010 [US1] Gỡ staging iOS: xoá scheme `staging` (`ios/Runner.xcodeproj/xcshareddata/xcschemes/staging.xcscheme`), build configurations `Debug-staging`/`Release-staging`/`Profile-staging` trong `project.pbxproj`, xcconfig staging nếu có; verify `xcodebuild -list -project ios/Runner.xcodeproj` chỉ còn development/production
- [ ] T011 [US1] Placeholder page `lib/app/view/app.dart` (+ page tối giản) hiển thị `config.environment.name` (đọc AppConfig — tạm truyền constructor, chuyển sang DI ở T016) + widget test `test/app/view/app_test.dart` verify hiển thị đúng tên environment
- [ ] T012 [US1] Verify toàn bộ V1 [quickstart.md](quickstart.md): 4/4 tổ hợp `flutter run` (iOS sim + Android emu × 2 flavor), `flutter run --flavor staging` fail, `grep -ri staging lib android ios` (đuôi dart/gradle/xcconfig/pbxproj/xcscheme) = 0 kết quả

**Checkpoint**: US1 = MVP — SC-002/SC-003 đạt, app flavor-correct trên cả 2 platform

---

## Phase 4: User Story 2 — API client sinh từ contract (Priority: P2)

**Goal**: Client dart-dio sinh từ contract v0.3.2, regenerate idempotent, mọi request tự mang `X-App-Key`

**Independent Test**: [quickstart.md](quickstart.md) V2 + V3 — xoá `lib/core/api` regenerate lại sạch; backend local nhận đúng header

- [ ] T013 [P] [US2] Contract Sync (FR-006): copy `.claude/openapi.yaml` → `contracts/openapi.yaml`; verify `diff .claude/openapi.yaml contracts/openapi.yaml` = identical
- [ ] T014 [US2] Tạo `openapitools.json` (pin generator core **7.14.0**) + `scripts/generate_api.sh` idempotent: xoá `lib/core/api/` → `npx @openapitools/openapi-generator-cli generate -g dart-dio -i contracts/openapi.yaml -o lib/core/api --additional-properties=serializationLibrary=json_serializable,...` → chạy build_runner cho code sinh nếu generator yêu cầu → `dart format lib/core/api`; script fail rõ (exit ≠ 0) khi yaml lỗi/thiếu Java
- [ ] T015 [US2] Chạy `scripts/generate_api.sh` lần đầu: client vào `lib/core/api/`; thêm `lib/core/api/README.md` cảnh báo GENERATED-ONLY (không sửa tay — Principle I); project compile, `flutter analyze` 0 warning (thêm exclude cho `lib/core/api/**` trong analysis_options nếu code sinh vi phạm lint — chỉ exclude thư mục generated)
- [ ] T016 [US2] DI `lib/core/di/injection.dart`: setup get_it + injectable (`@InjectableInit`, build_runner gen `injection.config.dart`); đăng ký `AppConfig` (từ bootstrap) + `Dio` với interceptor gắn header `X-App-Key` từ `AppConfig` (FR-005); `bootstrap()` gọi `configureDependencies(config)`; T011 placeholder chuyển sang đọc config từ getIt
- [ ] T017 [US2] Unit test `test/core/di/app_key_interceptor_test.dart`: request qua Dio đã đăng ký có header `X-App-Key` đúng giá trị config; verify V2 (rm -rf + regenerate → analyze 0 warning, git diff chỉ trong `lib/core/api`) + V3 (backend local: curl không key → 401 `INVALID_APP_KEY`, có key → 200)

**Checkpoint**: US1 + US2 độc lập hoạt động — SC-004 đạt

---

## Phase 5: User Story 3 — Nền tảng kiến trúc & chất lượng (Priority: P3)

**Goal**: Router, i18n vi-first, icon Phosphor, tài liệu dev — sẵn cho MO-002

**Independent Test**: Spec US3 acceptance — đối chiếu pubspec với R1; chuỗi UI từ ARB; cấu trúc đúng Principle XI

- [ ] T018 [P] [US3] `lib/core/router/app_router.dart`: go_router tối giản — abstract final class `AppRoutes` (const path `/`) + `GoRouter` 1 route placeholder page; `App` widget dùng `MaterialApp.router(routerConfig:)`; không dùng `Navigator.of` (Principle X)
- [ ] T019 [P] [US3] i18n vi-first (Principle XV): `l10n.yaml` với `template-arb-file: app_vi.arb`, `arb-dir: lib/l10n/arb`; tạo `lib/l10n/arb/app_vi.arb` (template, mặc định) + `app_en.arb`; chuyển mọi chuỗi placeholder page sang `context.l10n` (kèm `@description`); widget test T011 cập nhật theo
- [ ] T020 [P] [US3] Dùng `PhosphorIcon` trong placeholder page (1 icon bất kỳ từ `phosphor_flutter`) — smoke-proof bộ icon hoạt động, không mix `Icons.*` cho content icon (Principle VI)
- [ ] T021 [US3] Cập nhật `README.md` (FR-011): prerequisites ([quickstart.md](quickstart.md) bảng), lệnh chạy từng flavor + build release với `--dart-define=APP_KEY`, lệnh `scripts/generate_api.sh` + yêu cầu Java, pre-commit checklist constitution (`dart format .` / `flutter analyze` / `very_good test` / `bloc lint .`)

**Checkpoint**: Toàn bộ story nền hoàn thành

---

## Phase 6: User Story 4 — CI chặn code kém chất lượng (Priority: P3)

**Goal**: 4 gate tự động trên mọi PR, xanh ≤ 10 phút

**Independent Test**: Spec US4 acceptance — commit vi phạm format → CI đỏ; sửa → xanh

- [ ] T022 [US4] Tạo `.github/workflows/main.yaml`: trigger PR + push main; steps checkout → `subosito/flutter-action` (channel stable, cache: true) → `flutter pub get` → `dart format --set-exit-if-changed .` → `flutter analyze` → `dart pub global activate very_good_cli` + `very_good test` → `dart pub global activate bloc_tools` + `bloc lint .`; cache pub
- [ ] T023 [US4] Verify CI: push branch → workflow chạy đủ 4 gate xanh ≤ 10 phút (SC-006); test negative: commit tạm phá format → CI đỏ → revert (chứng minh gate chặn thật)

**Checkpoint**: Mọi PR từ nay có gate

---

## Phase 7: Polish & Cross-Cutting

- [ ] T024 Chạy full [quickstart.md](quickstart.md) V1→V5 + đối chiếu SC-001→SC-006 của [spec.md](spec.md); fix mọi lệch phát hiện
- [ ] T025 Cập nhật planning docs: `.claude/project-context.md` (trạng thái MO-001, follow-up amend constitution contract v0.3.0→v0.3.2), `.claude/sdd-roadmap.md` (MO-001 status), `.claude/changelog.md` (entry ship MO-001)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 → 2 → 3 (US1)**: tuần tự bắt buộc (chưa scaffold thì chưa có gì)
- **US2 (Phase 4)**: cần Phase 2 (deps) + T007 (AppConfig cho interceptor); T013 (contract sync) làm được ngay sau Phase 1
- **US3 (Phase 5)**: cần Phase 2 + T011 (placeholder page để gắn router/i18n/icon)
- **US4 (Phase 6)**: cần Phase 2 (lint config) — có thể làm song song với US2/US3; gate test cần ≥ 1 test tồn tại (T011)
- **Phase 7**: sau tất cả

### Story Dependencies

- **US1 (P1)**: chỉ cần Phase 1+2 — MVP độc lập
- **US2 (P2)**: T016 sửa cách placeholder đọc config (T011) — điểm chạm duy nhất với US1
- **US3 (P3)**: chạm T011 (page) nhưng test độc lập theo acceptance riêng
- **US4 (P3)**: độc lập sau khi có ≥ 1 test

### Parallel Opportunities

```text
Sau Phase 2:  US1 (T007→T012) tuần tự
Sau T007:     T013 [P] (contract sync — file độc lập)
Sau T011:     T018/T019/T020 [P] với nhau (router/ARB/icon — file khác nhau)
Song song:    US4 (T022) với US2/US3 — file .github độc lập
```

---

## Implementation Strategy

**MVP first**: Phase 1 → 2 → US1 (T012 checkpoint = demo được flavor đúng trên 2 platform) → dừng validate → US2 → US3 → US4 → Polish. Solo dev: đi tuần tự theo số task; commit sau mỗi task hoặc nhóm logic (T002 scaffold nguyên bản là 1 commit mốc riêng để diff gỡ-staging dễ review).

**Tổng**: 25 tasks — Setup 3 · Foundational 3 · US1 6 · US2 5 · US3 4 · US4 2 · Polish 2.
