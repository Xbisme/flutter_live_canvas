import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/core/favorites/download_history_entry.dart';
import 'package:livecanvas/core/favorites/download_history_repository.dart';
import 'package:livecanvas/core/favorites/download_history_store.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockPrefs extends Mock implements SharedPreferencesAsync {}

void main() {
  const key = 'download_history.entries.v1';

  late _MockPrefs prefs;
  late DownloadHistoryStore store;
  late DownloadHistoryRepository repo;

  /// Captures whatever the store last wrote, so we can assert on order/dedupe.
  var written = <String>[];

  setUp(() {
    prefs = _MockPrefs();
    store = DownloadHistoryStore(prefs);
    repo = DownloadHistoryRepositoryImpl(store);
    written = [];
    when(() => prefs.getStringList(key)).thenAnswer((_) async => written);
    when(() => prefs.setStringList(key, any())).thenAnswer((inv) async {
      written = inv.positionalArguments[1] as List<String>;
    });
  });

  test('record inserts an entry at the front', () async {
    final result = await repo.record(101);

    expect(result, isA<Ok<void>>());
    final entries = await repo.read().then((r) => (r as Ok).value);
    expect((entries as List<DownloadHistoryEntry>).single.wallpaperId, 101);
  });

  test('recording an existing id dedupes and moves it to the front', () async {
    await repo.record(101);
    await repo.record(205);
    await repo.record(101); // again → single entry, now first

    final entries =
        (await repo.read().then((r) => (r as Ok).value))
            as List<DownloadHistoryEntry>;
    expect(entries.map((e) => e.wallpaperId), [101, 205]);
  });

  test('read returns entries newest-first', () async {
    await repo.record(1);
    await repo.record(2);
    await repo.record(3);

    final entries =
        (await repo.read().then((r) => (r as Ok).value))
            as List<DownloadHistoryEntry>;
    expect(entries.map((e) => e.wallpaperId), [3, 2, 1]);
  });

  test('prune drops the given ids', () async {
    await repo.record(1);
    await repo.record(2);
    await repo.record(3);

    await repo.prune({2});

    final entries =
        (await repo.read().then((r) => (r as Ok).value))
            as List<DownloadHistoryEntry>;
    expect(entries.map((e) => e.wallpaperId), [3, 1]);
  });

  test('store skips malformed elements without wiping the rest', () async {
    written = [
      '{"id":1,"at":"2026-07-26T10:00:00.000Z"}',
      'not-json',
      '{"id":"bad"}',
      '{"id":2,"at":"2026-07-26T11:00:00.000Z"}',
    ];

    final entries = await store.read();
    expect(entries.map((e) => e.wallpaperId), [1, 2]);
  });
}
