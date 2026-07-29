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

  setUp(() => wallpapers = _MockWallpaperRepo());
  tearDown(() => favorites.dispose());

  FavoritesCubit build(List<int> ids) {
    favorites = FakeFavoritesRepository(ids);
    return FavoritesCubit(wallpapers, favorites);
  }

  blocTest<FavoritesCubit, FavoritesState>(
    'drops IDs missing from a successful batch (FR-010)',
    setUp: () {
      // 310 was removed by admin → server omits it silently.
      when(
        () => wallpapers.batch(any()),
      ).thenAnswer((_) async => Ok([_wp(205), _wp(101)]));
    },
    build: () => build(const [101, 205, 310]),
    act: (c) => c.load(),
    expect: () => [
      const FavoritesLoading(),
      FavoritesLoaded([_wp(205), _wp(101)]),
    ],
    verify: (_) {
      // 310 pruned from local storage; the others kept.
      expect(favorites.currentIds, {101, 205});
    },
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'does NOT prune when the batch fails (FR-011)',
    setUp: () {
      when(
        () => wallpapers.batch(any()),
      ).thenAnswer((_) async => const Err(NetworkFailure()));
    },
    build: () => build(const [101, 205, 310]),
    act: (c) => c.load(),
    expect: () => [
      const FavoritesLoading(),
      const FavoritesError(NetworkFailure()),
    ],
    verify: (_) {
      expect(favorites.currentIds, {101, 205, 310});
    },
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'all removed → empty state, all IDs pruned',
    setUp: () {
      when(
        () => wallpapers.batch(any()),
      ).thenAnswer((_) async => const Ok(<Wallpaper>[]));
    },
    build: () => build(const [101, 205]),
    act: (c) => c.load(),
    expect: () => [
      const FavoritesLoading(),
      const FavoritesLoaded([]),
    ],
    verify: (_) {
      expect(favorites.currentIds, isEmpty);
    },
  );
}
