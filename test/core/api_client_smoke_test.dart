import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

void main() {
  test('generated client exposes PublicApi', () {
    final client = LivecanvasApi();
    expect(client.getPublicApi(), isA<PublicApi>());
  });
}
