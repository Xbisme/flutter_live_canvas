# Bootstrap Interfaces (MO-001)

> API contract thật của app nằm ở `contracts/openapi.yaml` (repo root, v0.3.2 — Contract Sync từ backend). File này chỉ mô tả các "contract" mà bootstrap expose cho developer và cho các spec sau.

## 1. Run contract (flavor)

```bash
flutter run --flavor development -t lib/main_development.dart   # → backend local, dev key
flutter run --flavor production  -t lib/main_production.dart    # → placeholder URL, APP_KEY qua --dart-define
flutter run --flavor staging ...                                # PHẢI FAIL — flavor không tồn tại
```

Build release production:

```bash
flutter build apk --flavor production -t lib/main_production.dart --dart-define=APP_KEY=<key>
flutter build ipa --flavor production -t lib/main_production.dart --dart-define=APP_KEY=<key>
```

## 2. Regenerate contract (API client)

```bash
scripts/generate_api.sh
```

Hành vi cam kết: idempotent — xoá `lib/core/api/` cũ, sinh lại từ `contracts/openapi.yaml`, format; fail rõ ràng (exit ≠ 0) nếu yaml không hợp lệ hoặc thiếu Java. Sau khi chạy: `flutter analyze` 0 warning, project compile (SC-004).

## 3. Config contract (cho MO-002+)

```dart
// Đọc qua DI — KHÔNG import file config flavor trực tiếp:
final config = getIt<AppConfig>();
config.environment  // AppEnvironment.development | .production
config.apiBaseUrl   // base URL backend của flavor
config.appKey       // X-App-Key — chỉ interceptor dùng, feature code không cần đụng
```

Mọi request qua Dio của client sinh ra tự mang header `X-App-Key` (interceptor đăng ký trong `lib/core/di/`).

## 4. CI contract (gate trên mọi PR)

| Gate | Lệnh | Fail khi |
|---|---|---|
| Format | `dart format --set-exit-if-changed .` | có file chưa format |
| Analyze | `flutter analyze` | ≥ 1 warning/info (very_good_analysis) |
| Test | `very_good test` | ≥ 1 test fail |
| BLoC lint | `bloc lint .` (bloc_tools) | ≥ 1 vi phạm |
