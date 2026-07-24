import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/catalog/wallpaper_repository.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/features/wallpaper_detail/presentation/cubit/wallpaper_detail_cubit.dart';
import 'package:livecanvas/features/wallpaper_detail/presentation/cubit/wallpaper_detail_state.dart';
import 'package:livecanvas_api/livecanvas_api.dart';
import 'package:mocktail/mocktail.dart';

class _MockWallpaperRepo extends Mock implements WallpaperRepository {}

void main() {
  late _MockWallpaperRepo wallpapers;

  setUp(() => wallpapers = _MockWallpaperRepo());

  WallpaperDetailCubit create() => WallpaperDetailCubit(wallpapers);

  blocTest<WallpaperDetailCubit, WallpaperDetailState>(
    'load emits [Loading, Loaded] on success',
    setUp: () => when(() => wallpapers.getById(5)).thenAnswer(
      (_) async => Ok(Wallpaper(id: 5, title: 'Neon')),
    ),
    build: create,
    act: (c) => c.load(5),
    expect: () => [
      isA<WallpaperDetailLoading>(),
      isA<WallpaperDetailLoaded>().having(
        (s) => s.wallpaper.id,
        'id',
        5,
      ),
    ],
  );

  blocTest<WallpaperDetailCubit, WallpaperDetailState>(
    'load emits [Loading, Error(NotFound)] when removed',
    setUp: () => when(
      () => wallpapers.getById(9),
    ).thenAnswer((_) async => const Err(NotFoundFailure())),
    build: create,
    act: (c) => c.load(9),
    expect: () => [
      isA<WallpaperDetailLoading>(),
      isA<WallpaperDetailError>().having(
        (s) => s.failure,
        'failure',
        isA<NotFoundFailure>(),
      ),
    ],
  );
}
