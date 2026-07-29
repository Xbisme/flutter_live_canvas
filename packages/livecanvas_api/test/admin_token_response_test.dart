import 'package:test/test.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

// tests for AdminTokenResponse
void main() {
  final AdminTokenResponse? instance = /* AdminTokenResponse(...) */ null;
  // TODO add properties to the entity

  group(AdminTokenResponse, () {
    // JWT access — gắn `Authorization Bearer` cho /admin/_*, sống 30 phút
    // String access
    test('to test the property `access`', () async {
      // TODO
    });

    // Refresh token MỚI (rotate mỗi lần dùng; bản cũ bị vô hiệu), sống 7 ngày
    // String refresh
    test('to test the property `refresh`', () async {
      // TODO
    });

    // Số giây còn lại của access token
    // int expiresIn
    test('to test the property `expiresIn`', () async {
      // TODO
    });
  });
}
