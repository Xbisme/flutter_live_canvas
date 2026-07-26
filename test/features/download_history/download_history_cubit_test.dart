import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/catalog/wallpaper_repository.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/core/favorites/download_history_entry.dart';
import 'package:livecanvas/core/favorites/download_history_repository.dart';
import 'package:livecanvas/features/download_history/presentation/cubit/download_history_cubit.dart';
import 'package:livecanvas/features/download_history/presentation/cubit/download_history_state.dart';
import 'package:livecanvas_api/livecanvas_api.dart';
import 'package:mocktail/mocktail.dart';

class _MockWallpaperRepo extends Mock implements WallpaperRepository {}

class _MockHistoryRepo extends Mock implements DownloadHistoryRepository {}

Wallpaper _wp(int id) => Wallpaper(id: id, title: 'w$id');

DownloadHistoryEntry _entry(int id) =>
    DownloadHistoryEntry(wallpaperId: id, downloadedAt: DateTime.utc(2026, id));

void main() {
  late _MockWallpaperRepo wallpapers;
  late _MockHistoryRepo history;

  setUpAll(() {
    registerFallbackValue(<int>[]);
    registerFallbackValue(<int>{});
  });

  setUp(() {
    wallpapers = _MockWallpaperRepo();
    history = _MockHistoryRepo();
    when(() => history.prune(any())).thenAnswer((_) async {});
  });

  DownloadHistoryCubit build() => DownloadHistoryCubit(wallpapers, history);

  void stubEcho() {
    when(() => wallpapers.batch(any())).thenAnswer((inv) async {
      final ids = inv.positionalArguments[0] as List<int>;
      return Ok(ids.map(_wp).toList());
    });
  }

  blocTest<DownloadHistoryCubit, DownloadHistoryState>(
    'empty history → Loaded([])',
    setUp: () => when(
      () => history.read(),
    ).thenAnswer((_) async => const Ok(<DownloadHistoryEntry>[])),
    build: build,
    act: (c) => c.load(),
    expect: () => [
      const DownloadHistoryLoading(),
      const DownloadHistoryLoaded([]),
    ],
  );

  blocTest<DownloadHistoryCubit, DownloadHistoryState>(
    'loads entries newest-first',
    setUp: () {
      when(
        () => history.read(),
      ).thenAnswer((_) async => Ok([_entry(3), _entry(2), _entry(1)]));
      stubEcho();
    },
    build: build,
    act: (c) => c.load(),
    expect: () => [
      const DownloadHistoryLoading(),
      DownloadHistoryLoaded([_wp(3), _wp(2), _wp(1)]),
    ],
  );

  blocTest<DownloadHistoryCubit, DownloadHistoryState>(
    'batch failure → Error',
    setUp: () {
      when(() => history.read()).thenAnswer((_) async => Ok([_entry(1)]));
      when(
        () => wallpapers.batch(any()),
      ).thenAnswer((_) async => const Err(NetworkFailure()));
    },
    build: build,
    act: (c) => c.load(),
    expect: () => [
      const DownloadHistoryLoading(),
      const DownloadHistoryError(NetworkFailure()),
    ],
  );

  blocTest<DownloadHistoryCubit, DownloadHistoryState>(
    'reconciles entries whose wallpaper was removed (FR-015)',
    setUp: () {
      when(
        () => history.read(),
      ).thenAnswer((_) async => Ok([_entry(1), _entry(2)]));
      // 2 no longer exists — server omits it.
      when(() => wallpapers.batch(any())).thenAnswer((_) async => Ok([_wp(1)]));
    },
    build: build,
    act: (c) => c.load(),
    expect: () => [
      const DownloadHistoryLoading(),
      DownloadHistoryLoaded([_wp(1)]),
    ],
    verify: (_) {
      verify(() => history.prune({2})).called(1);
    },
  );
}
