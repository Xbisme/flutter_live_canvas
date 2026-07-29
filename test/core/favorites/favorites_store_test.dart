import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/favorites/favorites_store.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockPrefs extends Mock implements SharedPreferencesAsync {}

void main() {
  const key = 'favorites.ids.v1';

  late _MockPrefs prefs;
  late FavoritesStore store;

  setUp(() {
    prefs = _MockPrefs();
    store = FavoritesStore(prefs);
  });

  group('read', () {
    test('returns stored ids in order', () async {
      when(
        () => prefs.getStringList(key),
      ).thenAnswer((_) async => ['101', '205', '310']);

      expect(await store.read(), const [101, 205, 310]);
    });

    test('empty when key absent', () async {
      when(() => prefs.getStringList(key)).thenAnswer((_) async => null);

      expect(await store.read(), isEmpty);
    });

    test('skips malformed entries without wiping the rest', () async {
      when(
        () => prefs.getStringList(key),
      ).thenAnswer((_) async => ['101', 'oops', '310']);

      expect(await store.read(), const [101, 310]);
    });
  });

  group('write', () {
    test('persists ids as strings in the given order', () async {
      when(
        () => prefs.setStringList(any(), any()),
      ).thenAnswer((_) async {});

      await store.write(const [7, 3, 9]);

      verify(() => prefs.setStringList(key, ['7', '3', '9'])).called(1);
    });
  });
}
