import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/catalog/wallpaper_repository.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:livecanvas/features/favorites/presentation/cubit/favorites_state.dart';
import 'package:livecanvas_api/livecanvas_api.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_favorites_repository.dart';

class _MockWallpaperRepo extends Mock implements WallpaperRepository {}

Wallpaper _wp(int id) => Wallpaper(id: id, title: 'w$id');

void main() {
  late _MockWallpaperRepo wallpapers;
  late FakeFavoritesRepository favorites;

  setUpAll(() => registerFallbackValue(<int>[]));

  setUp(() {
    wallpapers = _MockWallpaperRepo();
  });

  tearDown(() => favorites.dispose());

  /// Echoes the requested ids back as wallpapers (server returns what exists).
  void stubEcho() {
    when(() => wallpapers.batch(any())).thenAnswer((inv) async {
      final ids = inv.positionalArguments[0] as List<int>;
      return Ok(ids.map(_wp).toList());
    });
  }

  FavoritesCubit build(List<int> ids) {
    favorites = FakeFavoritesRepository(ids);
    return FavoritesCubit(wallpapers, favorites);
  }

  blocTest<FavoritesCubit, FavoritesState>(
    'no favourites → [Loading, Loaded([])]',
    build: () => build(const []),
    act: (c) => c.load(),
    expect: () => [
      const FavoritesLoading(),
      const FavoritesLoaded([]),
    ],
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'success → newest-added first',
    setUp: stubEcho,
    build: () => build(const [101, 205, 310]),
    act: (c) => c.load(),
    verify: (_) {
      verify(() => wallpapers.batch(const [310, 205, 101])).called(1);
    },
    expect: () => [
      const FavoritesLoading(),
      FavoritesLoaded([_wp(310), _wp(205), _wp(101)]),
    ],
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'batch failure → [Loading, Error]',
    setUp: () {
      when(
        () => wallpapers.batch(any()),
      ).thenAnswer((_) async => const Err(NetworkFailure()));
    },
    build: () => build(const [101]),
    act: (c) => c.load(),
    expect: () => [
      const FavoritesLoading(),
      const FavoritesError(NetworkFailure()),
    ],
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'chunks a large list into batches of 100 (SC-005)',
    setUp: stubEcho,
    build: () => build(List<int>.generate(250, (i) => i + 1)),
    act: (c) => c.load(),
    verify: (_) {
      verify(() => wallpapers.batch(any())).called(3);
    },
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'un-favouriting in place drops the item without a refetch',
    setUp: stubEcho,
    build: () => build(const [101, 205]),
    act: (c) async {
      await c.load();
      await favorites.toggle(101); // removes 101 → dropped in place
    },
    skip: 2, // Loading, first Loaded
    expect: () => [
      FavoritesLoaded([_wp(205)]),
    ],
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'favouriting a new id while loaded reloads to include it',
    setUp: stubEcho,
    build: () => build(const [101]),
    act: (c) async {
      await c.load();
      await favorites.toggle(205); // add from elsewhere → must appear
    },
    skip: 2, // Loading, first Loaded([101])
    expect: () => [
      const FavoritesLoading(),
      FavoritesLoaded([_wp(205), _wp(101)]), // newest-first
    ],
  );
}
