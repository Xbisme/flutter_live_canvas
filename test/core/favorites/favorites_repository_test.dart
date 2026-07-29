import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/favorites/favorites_repository.dart';
import 'package:livecanvas/core/favorites/favorites_store.dart';
import 'package:mocktail/mocktail.dart';

class _MockStore extends Mock implements FavoritesStore {}

void main() {
  late _MockStore store;
  late FavoritesRepositoryImpl repo;

  setUp(() {
    store = _MockStore();
    when(() => store.read()).thenAnswer((_) async => const [101, 205]);
    when(() => store.write(any())).thenAnswer((_) async {});
    repo = FavoritesRepositoryImpl(store);
  });

  test('hydrates from the store', () async {
    // Hydration completes and publishes the stored set to the notifier.
    await repo.toggle(999); // awaits hydration internally
    await repo.toggle(999); // undo → back to the hydrated set
    expect(repo.currentIds, {101, 205});
    expect(repo.orderedIds, const [101, 205]);
    expect(repo.isFavorite(101), isTrue);
    expect(repo.isFavorite(998), isFalse);
  });

  test('toggle adds a new id and persists', () async {
    await repo.toggle(310);

    expect(repo.isFavorite(310), isTrue);
    expect(repo.orderedIds, const [101, 205, 310]);
    verify(() => store.write(const [101, 205, 310])).called(1);
  });

  test('toggle removes an existing id', () async {
    await repo.toggle(101);

    expect(repo.isFavorite(101), isFalse);
    expect(repo.orderedIds, const [205]);
    verify(() => store.write(const [205])).called(1);
  });

  test('double toggle returns to the original state', () async {
    await repo.toggle(310);
    await repo.toggle(310);

    expect(repo.isFavorite(310), isFalse);
    expect(repo.orderedIds, const [101, 205]);
  });

  test('listenable notifies on each change', () async {
    final values = <Set<int>>[];
    void listener() => values.add(repo.listenable.value);
    repo.listenable.addListener(listener);

    await repo.toggle(310); // add
    await repo.toggle(101); // remove
    repo.listenable.removeListener(listener);

    expect(values, [
      {101, 205, 310},
      {205, 310},
    ]);
  });

  test('two per-id observers each keep seeing their own changes', () async {
    // Mirrors two FavoritableWallpaperTile bindings for different ids: reading
    // listenable.value synchronously never misses a rapid second toggle.
    final a = <bool>[];
    final b = <bool>[];
    void obsA() => a.add(repo.listenable.value.contains(1));
    void obsB() => b.add(repo.listenable.value.contains(2));
    repo.listenable
      ..addListener(obsA)
      ..addListener(obsB);

    await repo.toggle(1); // tile A → favourite
    await repo.toggle(2); // tile B → favourite (this broke on device)

    repo.listenable
      ..removeListener(obsA)
      ..removeListener(obsB);
    expect(a, [true, true], reason: 'A notified on both changes');
    expect(b, [false, true], reason: 'B still updates on the 2nd toggle');
  });

  test('prune drops missing ids and persists', () async {
    await repo.prune({205, 999});

    expect(repo.isFavorite(205), isFalse);
    expect(repo.orderedIds, const [101]);
    verify(() => store.write(const [101])).called(1);
  });

  test('prune is a no-op when nothing matches', () async {
    await repo.prune({999});

    expect(repo.orderedIds, const [101, 205]);
    verifyNever(() => store.write(any()));
  });
}
