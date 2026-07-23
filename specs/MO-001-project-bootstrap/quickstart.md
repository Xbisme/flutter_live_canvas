# Quickstart & Validation: MO-001 Project Bootstrap

Hướng dẫn verify end-to-end sau khi implement. Chi tiết quyết định → [research.md](research.md), interface → [contracts/bootstrap-interfaces.md](contracts/bootstrap-interfaces.md).

## Prerequisites

| Công cụ | Version | Cài |
|---|---|---|
| Flutter SDK | 3.44.7 stable | máy cá nhân: `~/Documents/develop/flutter` (đang 3.44.4 → `flutter upgrade`); thêm `bin` vào PATH |
| very_good_cli | 1.3.0 | `dart pub global activate very_good_cli` |
| bloc_tools | latest | `dart pub global activate bloc_tools` |
| Java (JRE ≥ 11) | temurin | `brew install temurin` — máy cá nhân CHƯA có (openapi-generator cần) |
| Node/npm | có sẵn (npx 11.x) | dùng cho `@openapitools/openapi-generator-cli` |
| Backend local | BE-003 merged | `/Users/xbism3/Documents/backend_live_canvas` — chạy `python manage.py runserver` (flavor dev) |

## Validation Scenarios

### V1 — Hai flavor chạy được, staging biến mất (US1, SC-002/SC-003)

```bash
flutter run --flavor development -t lib/main_development.dart -d <ios-sim>      # ✅ boot, hiển thị "development"
flutter run --flavor development -t lib/main_development.dart -d <android-emu>  # ✅
flutter run --flavor production  -t lib/main_production.dart  -d <ios-sim>      # ✅ boot, hiển thị "production"
flutter run --flavor production  -t lib/main_production.dart  -d <android-emu>  # ✅
flutter run --flavor staging -t lib/main_development.dart                       # ❌ PHẢI lỗi "flavor not found"
grep -ri staging --include="*.dart" --include="*.gradle*" --include="*.xcconfig" --include="*.pbxproj" --include="*.xcscheme" lib android ios  # → 0 kết quả
```

Expected: 4/4 tổ hợp boot; placeholder page hiện đúng tên environment; grep sạch.

### V2 — Client regenerate lặp lại được (US2, SC-004)

```bash
rm -rf lib/core/api && scripts/generate_api.sh
flutter analyze          # 0 warning
flutter test             # pass
git status               # diff chỉ nằm trong lib/core/api (hoặc sạch nếu contract không đổi)
```

### V3 — X-App-Key interceptor (US2)

Chạy backend local + app flavor development → app gọi thử 1 endpoint (vd. `GET /categories` từ placeholder hoặc test tích hợp Dio) → log backend nhận header `X-App-Key` đúng dev key; gọi thiếu key (curl không header) → 401 `INVALID_APP_KEY` chứng minh gate hoạt động.

```bash
curl -s http://localhost:8000/api/v1/categories                       # 401 INVALID_APP_KEY
curl -s -H "X-App-Key: <dev-key>" http://localhost:8000/api/v1/categories  # 200
```

### V4 — Nền tảng & chất lượng (US3/US4, SC-005/SC-006)

```bash
dart format --set-exit-if-changed .   # exit 0
flutter analyze                       # 0 warning
very_good test                        # pass (≥ 1 widget test placeholder)
bloc lint .                           # 0 vi phạm
```

Đối chiếu `pubspec.yaml` với bảng version [research.md](research.md) R1 (SC-005). Đẩy PR → CI 4 gate xanh ≤ 10 phút; commit chứa `pubspec.lock`.

### V5 — Clone-to-run ≤ 15 phút (SC-001)

Máy sạch (hoặc xoá cache): clone → README → chạy được V1 dòng đầu trong ≤ 15 phút không cần hỏi.

## Contract Sync check (FR-006)

```bash
diff .claude/openapi.yaml contracts/openapi.yaml && echo "IDENTICAL"   # bắt buộc IDENTICAL
```
