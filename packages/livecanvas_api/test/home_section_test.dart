import 'package:test/test.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

// tests for HomeSection
void main() {
  final HomeSection? instance = /* HomeSection(...) */ null;
  // TODO add properties to the entity

  group(HomeSection, () {
    // Slug của collection. Định danh ổn định cho client (analytics/scroll-state) — đổi `title` không làm đổi `key`.
    // String key
    test('to test the property `key`', () async {
      // TODO
    });

    // String title
    test('to test the property `title`', () async {
      // TODO
    });

    // Target của \"Xem tất cả\" → `GET /collections/{id}` (đã có).
    // int collectionId
    test('to test the property `collectionId`', () async {
      // TODO
    });

    // String coverUrl
    test('to test the property `coverUrl`', () async {
      // TODO
    });

    // String accentColor
    test('to test the property `accentColor`', () async {
      // TODO
    });

    // CHỈ để hiển thị badge/nút \"Mở khoá\" — KHÔNG phải gate entitlement.
    // bool isPremium
    test('to test the property `isPremium`', () async {
      // TODO
    });

    // Tối đa 10 wallpaper published theo đúng thứ tự curate (`position`). Cùng schema Wallpaper như mọi list khác — `collections` rỗng.
    // List<Wallpaper> items
    test('to test the property `items`', () async {
      // TODO
    });
  });
}
