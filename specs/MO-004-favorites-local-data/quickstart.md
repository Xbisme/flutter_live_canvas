# Quickstart — Nghiệm thu Favorites & Local Data (MO-004)

Hướng dẫn chạy & kiểm chứng end-to-end. Chi tiết interface xem [contracts/](contracts/), state xem [data-model.md](data-model.md).

## Prerequisites
- Nhánh `MO-004-favorites-local-data`.
- `shared_preferences` ^2.5.5 đã thêm vào `pubspec.yaml` (xác nhận latest trên pub.dev trước — Principle XVI); `flutter pub get`.
- DI regen: `dart run lean_builder build` (sau khi thêm `@LazySingleton`/`@module` mới).
- l10n regen (nếu thêm khóa ARB): `flutter gen-l10n` (hoặc build tự sinh).
- Backend/mock: dùng backend local thật (contract v0.4.0) hoặc Prism `scripts/mock_server.sh` + `--dart-define=USE_MOCK=true`.

## Chạy app
```bash
flutter run --flavor development -t lib/main_development.dart
# máy thật LAN: thêm --dart-define=API_HOST=<host-ip> (xem changelog MO-003)
```

## Kịch bản nghiệm thu

### US1 — Toggle & bền vững
1. Mở Khám phá → chạm nút tim trên 1 tile → tim đổi trạng thái **tức thời** (<100ms), có haptic.
2. Mở Wallpaper Detail của tile khác → chạm tim → quay lại Khám phá thấy tile đó cũng đã-yêu-thích (nhất quán xuyên màn — FR-004).
3. Tắt hẳn app, mở lại → trạng thái tim giữ nguyên (SC-001).

### US2 — Màn Favorites data tươi
4. Vào tab "Yêu thích" → lưới hiển thị đúng các mục đã lưu với **dữ liệu mới nhất** (batch), TopBar có số đếm.
5. Chạm 1 mục → mở Wallpaper Detail. Bỏ tim 1 mục ngay trong lưới → mục biến mất tức thì (FR-007).
6. Chưa có mục nào → `EmptyState` heart + CTA "Khám phá hình nền".
7. Tắt mạng, mở lại tab Yêu thích → `FailureView` retry; **id local không mất** (SC-006).

### US3 — Reconcile
8. Với backend/mock: cho 1 id đã favorite không còn được batch trả về (xóa/unpublish) → mở tab Yêu thích: mục đó **không hiển thị** và bị xóa khỏi store (mở lại lần sau không thử lấy nữa) — 0 ô hỏng (SC-003, FR-010).
9. Xác minh chỉ reconcile khi batch **thành công**: lỗi mạng KHÔNG xóa id (FR-011).

### US4 — Lịch sử tải (seed)
10. Seed vài `DownloadHistoryEntry` qua `DownloadHistoryRepository.record(id)` (test/dev) → vào tab "Bạn" → "Lịch sử tải": danh sách theo **mới-tải-trước**, mỗi wallpaper 1 mục (FR-014), chạm mở Detail.
11. `record` cùng id 2 lần → chỉ 1 mục, đưa lên đầu.

### Scale
12. Seed ~250 favorite id → mở tab Yêu thích: hiển thị đủ, đúng thứ tự, không mất mục do giới hạn lô 100 (SC-005) — kiểm chunk batch.

## Kiểm thử tự động (Principle XIII)
```bash
very_good test --test-randomize-ordering-seed random
```
Bao phủ tối thiểu:
- **Unit**: `FavoritesStore`/`DownloadHistoryStore` (read/write/prune, thứ tự, parse hỏng), `WallpaperRepository.batch` (Ok/Err mapping), logic chunk ≤100, logic reconcile (missing = local − returned).
- **bloc_test**: `FavoritesCubit` (initial→loading→loaded/empty/error; toggle qua stream cập nhật items; reconcile prune), `DownloadHistoryCubit`.
- **Widget**: `FavoritesPage` (empty/loaded/error/toggle-remove), tile forward `isFav`/`onFav`.

## Gate trước khi mở PR (Pre-Commit Checklist hiến pháp)
```bash
dart format .
flutter analyze                  # 0 warning
very_good test
dart run bloc_tools:bloc lint .  # 0 vi phạm
```
