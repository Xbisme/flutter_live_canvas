# Quickstart — MO-003 Wallpaper Browse, Collections & Detail

Hướng dẫn chạy & nghiệm thu MO-003. Không chứa mã triển khai (thuộc `tasks.md` + implement).

## Prerequisites

- Flutter ≥3.44 / Dart ^3.12 (đã pin MO-001), Java (regen client nếu cần), Node/npx (Prism).
- Backend BE-002/BE-003 chạy local (`localhost:8000`, Android emulator `10.0.2.2:8000`) **có seed data**, HOẶC dùng mock Prism.
- Đã `flutter pub get` sau khi thêm dep mới (xem research.md §Tổng hợp).

## Setup

```bash
# 1) Cài dependency mới + DI codegen
flutter pub get
dart run lean_builder build          # DI (injection.config.dart) — như MO-001/002
#   State là sealed class + Equatable (KHÔNG freezed/build_runner — research R1).

# 2a) Chạy trên backend thật (development flavor mặc định trỏ localhost:8000)
flutter run --flavor development -t lib/main_development.dart

# 2b) HOẶC chạy trên mock Prism (không cần backend)
bash scripts/mock_server.sh          # Prism port 4010
flutter run --flavor development -t lib/main_development.dart --dart-define=USE_MOCK=true
```

iOS lần đầu sau khi thêm `video_player`: `cd ios && pod install`.

## Nghiệm thu theo User Story (map Success Criteria)

### US1 — Browse + lọc tag (P1)
1. Mở app → tab **Khám phá**. **Kỳ vọng**: skeleton shimmer lưới hiện ngay (đúng số cột theo `Breakpoints.gridColumns`), rồi thay bằng wallpaper thật <2s; mỗi ô tự phát preview muted-loop; chip "Tất cả" chọn sẵn. *(SC-001, SC-009, FR-001/002/005/026)*
2. Cuộn gần đáy → trang kế tự nối, skeleton nhỏ ở cuối; cuộn tới hết → dừng, không còn chỉ báo. *(FR-003/030)*
3. Cuộn nhanh ≥100 item, mở DevTools memory/performance → **số `VideoPlayerController` giữ giới hạn (chỉ tile visible), bộ nhớ phẳng**, không giật. *(SC-002, Principle II — bằng chứng bắt buộc)*
4. Chạm 1 tag → lưới lọc lại <1.5s; chạm "Tất cả" → toàn bộ; đổi tag nhanh không nhấp nháy kết quả cũ. *(SC-003, FR-006, R6)*
5. Kéo xuống đầu lưới → làm mới từ đầu (reset cursor). *(FR-031)*
6. Tắt mạng, mở lại tab → trạng thái lỗi thân thiện + thử lại (không text kỹ thuật). *(SC-007, FR-007)*

### US2 — Wallpaper Detail (P2)
1. Chạm 1 wallpaper → Detail full-screen (che tab bar); skeleton hero+meta → video lớn phát <1s + tên/tag. *(SC-004, FR-009/010)*
2. Wallpaper premium → badge PRO + nút đặt/tải ở trạng thái khoá (chạm KHÔNG cấp quyền). *(FR-012, Principle V)*
3. Wallpaper thuộc bộ → link "Từ bộ sưu tập ·…" → chạm mở đúng Collection Detail (1 chạm). *(SC-005, FR-011)*
4. Back → về đúng nguồn tại vị trí cũ. Mở id không tồn tại → "không tìm thấy". *(FR-014)*

### US3 — Collections (P3)
1. Tab **Bộ sưu tập** → skeleton cover card → list thật. Chạm 1 bộ → Collection Detail (hero cover + `accent_color` + mô tả + lưới items đúng thứ tự). *(FR-015/016)*
2. Bộ premium → nút "Mở khoá"/"Tải tất cả" khoá; chạm mở placeholder paywall, KHÔNG cấp quyền. *(FR-017, Principle V)*
3. Chạm item trong bộ → Wallpaper Detail; back về Collection Detail. *(FR-018)*

### US4 — Search (P4)
1. Tab **Tìm**, chưa nhập → gợi ý (không tải toàn thư viện). Gõ 1 ký tự → chưa gọi API; ≥2 ký tự + ngừng ~350ms → tìm 1 lần. *(FR-019/020, R6)*
2. Từ khoá khớp → skeleton → lưới kết quả (preview + phân trang). Từ khoá không khớp → EmptyState gợi ý. *(SC-006, FR-020)*
3. Chạm kết quả → Detail; back về kết quả. *(FR-021)*

### Xuyên suốt
- iPhone (notch/Dynamic Island) + iPad → không vỡ layout, lưới & **skeleton** đúng số cột theo breakpoint. *(SC-008, FR-025/027)*
- Mọi chuỗi tiếng Việt qua `context.l10n`; màu/spacing/typography/icon từ `lib/core/theme` + Phosphor. *(FR-023)*

## Pre-commit gate (Constitution Dev Workflow)

```bash
dart format .
flutter analyze                       # 0 warning
very_good test --test-randomize-ordering-seed random
dart run bloc_tools:bloc lint .       # 0 vi phạm
```
Commit lại `pubspec.lock` + `ios/Podfile.lock` (Principle XVI). Verify build cả iOS + Android (video_player kéo native pod/gradle).
