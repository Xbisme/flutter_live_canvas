# Quickstart / Validation: Foundation, Navigation & Design System (MO-002)

> Hướng dẫn chạy & nghiệm thu MO-002. Chi tiết widget/route → [contracts/ui-contracts.md](contracts/ui-contracts.md); token/model → [data-model.md](data-model.md).

## Prerequisites

- Flutter 3.44.7 (dev đang 3.44.4 → `flutter upgrade`), Dart 3.12.2.
- Node/npm (đã có) — cho Prism mock (`npx`, không cần cài global).
- Java ≥ 11 chỉ cần khi regenerate client (MO-001) — MO-002 không bắt buộc.

## Setup

```bash
# 1. Font: tải TTF Fontshare (Clash Display, Satoshi) + Google Fonts (Space Mono) vào assets/fonts/
scripts/fetch_fonts.sh

# 2. Dependencies (phosphoricons_flutter mới; gỡ phosphor_flutter)
flutter pub get

# 3. Codegen nếu cần (injectable DI — lean_builder, như MO-001)
dart run lean_builder build
```

## Chạy app (foundation)

```bash
# Mock server (terminal riêng) — dữ liệu mẫu từ contract
scripts/mock_server.sh                     # npx prism mock contracts/openapi.yaml -p 4010

# App flavor development (trỏ mock)
flutter run --flavor development -t lib/main_development.dart
```

## Kịch bản nghiệm thu (map tới Success Criteria)

### SC-001 — Điều hướng 5 tab giữ trạng thái (US1)
1. Mở app → thấy 5 tab (Khám phá / Tìm / Bộ sưu tập / Yêu thích / Bạn), tab đầu active.
2. Chạm từng tab → body đổi sang placeholder tương ứng; tab active đánh dấu đúng.
3. Cuộn trong 1 tab → sang tab khác → quay lại → **vị trí cuộn/state giữ nguyên**.
4. Kích hoạt route Detail/Collection placeholder → phủ full-screen che TabBar → back về đúng tab nguồn.
5. Tab "Bạn" → thấy shell rỗng tiêu đề "Bạn".

### SC-002/003/004 — Design system (US2)
- So màu nền/nhấn, spacing, bo góc, đổ bóng với prototype → khớp token.
- Chữ đúng 3 font (Clash Display tiêu đề, Satoshi body, Space Mono meta) theo type scale; **tắt mạng vẫn đúng font** (SC-003).
- Mọi icon nội dung thuộc Phosphor (SC-004).
- Grep xác nhận **0 hardcode**: `grep -rnE "Color\(0x|EdgeInsets\.all\([0-9]" lib/` chỉ được khớp trong `lib/core/theme/` (nơi định nghĩa token), 0 ở call site khác (SC-002).

### SC-005 — Shared widgets (US3)
- Mở màn **gallery demo dev-only** (`/dev/gallery`) → từng widget (WallpaperCard, TabBar, TopBar, PremiumBadge, Button, FilterChip, IconButton, MetaChip, EmptyState, Sheet, Toast) render khớp prototype.
- PremiumBadge = "PRO" aurora gradient, **không icon khoá**.
- WallpaperCard có Aura glow theo `auraColor`.

### SC-006 — Đa nền tảng & responsive
- Chạy iOS simulator + Android emulator: điều hướng đúng.
- Chạy trên iPad simulator: shell + widgets **không vỡ/tràn** (responsive-aware).

### SC-007 — Mock server
```bash
scripts/mock_server.sh &
curl -s localhost:4010/wallpapers | head        # payload đúng schema
curl -s localhost:4010/collections | head
```

### SC-008 — CI 4 gate
```bash
dart format --set-exit-if-changed .
flutter analyze                 # 0 warning
very_good test                  # widget/route test xanh
bloc lint .                     # 0 vi phạm
```

## Definition of Done (từ spec)
App điều hướng được 5 tab (giữ state); theme + 3 font + icon Phosphor áp đúng; shared widgets khớp prototype trong gallery demo; chạy iOS + Android + iPad không vỡ; Prism mock trả data đúng schema; CI 4 gate xanh.
