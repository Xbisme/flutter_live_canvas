import 'package:test/test.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

// tests for AdminCollectionCreateRequest
void main() {
  final AdminCollectionCreateRequest?
  instance = /* AdminCollectionCreateRequest(...) */ null;
  // TODO add properties to the entity

  group(AdminCollectionCreateRequest, () {
    // String slug
    test('to test the property `slug`', () async {
      // TODO
    });

    // String title
    test('to test the property `title`', () async {
      // TODO
    });

    // String author
    test('to test the property `author`', () async {
      // TODO
    });

    // String description
    test('to test the property `description`', () async {
      // TODO
    });

    // upload_key ảnh cover (lấy từ POST /admin/uploads/presign)
    // String coverUploadKey
    test('to test the property `coverUploadKey`', () async {
      // TODO
    });

    // String accentColor
    test('to test the property `accentColor`', () async {
      // TODO
    });

    // bool isPremium (default value: false)
    test('to test the property `isPremium`', () async {
      // TODO
    });

    // (v0.7.0) Cho collection này hiện thành section ở màn Browse (`GET /home`). Mặc định tắt. Bật quá 10 collection vẫn hợp lệ — trần chỉ áp lúc đọc.
    // bool showOnHome (default value: false)
    test('to test the property `showOnHome`', () async {
      // TODO
    });

    // (v0.7.0) Vị trí section trên Browse, tăng dần. KHÔNG unique — trùng vị trí thì tie-break theo id. Vô nghĩa khi `show_on_home=false`.
    // int homePosition (default value: 0)
    test('to test the property `homePosition`', () async {
      // TODO
    });

    // Danh sách wallpaper có thứ tự — phải trỏ tới wallpaper đã tồn tại
    // List<int> wallpaperIds
    test('to test the property `wallpaperIds`', () async {
      // TODO
    });
  });
}
