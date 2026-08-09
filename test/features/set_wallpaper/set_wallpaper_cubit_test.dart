import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/core/wallpaper/download_progress.dart';
import 'package:livecanvas/core/wallpaper/set_wallpaper_use_case.dart';
import 'package:livecanvas/core/wallpaper/wallpaper_file.dart';
import 'package:livecanvas/features/set_wallpaper/presentation/cubit/set_wallpaper_cubit.dart';
import 'package:livecanvas/features/set_wallpaper/presentation/cubit/set_wallpaper_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockUseCase extends Mock implements SetWallpaperUseCase {}

const _file = WallpaperFile(
  wallpaperId: 101,
  path: '/tmp/wallpapers/101.mp4',
  sizeBytes: 1024,
);

void main() {
  late _MockUseCase useCase;

  setUpAll(() {
    registerFallbackValue(_file);
    registerFallbackValue(CancelToken());
  });

  setUp(() {
    useCase = _MockUseCase();
    when(() => useCase.discardPartial(any())).thenAnswer((_) async {});
  });

  void stubPrepare(Result<WallpaperFile> result) => when(
    () => useCase.prepare(
      any(),
      onProgress: any(named: 'onProgress'),
      cancelToken: any(named: 'cancelToken'),
    ),
  ).thenAnswer((_) async => result);

  group('startDownload', () {
    blocTest<SetWallpaperCubit, SetWallpaperState>(
      'Initial -> LoadingDownload -> LoadedReady',
      setUp: () => stubPrepare(const Ok(_file)),
      build: () => SetWallpaperCubit(useCase),
      act: (cubit) => cubit.startDownload(101),
      expect: () => [
        const SetWallpaperLoadingDownload(DownloadProgress.initial()),
        const SetWallpaperLoadedReady(_file),
      ],
    );

    blocTest<SetWallpaperCubit, SetWallpaperState>(
      'emits each progress update',
      setUp: () {
        when(
          () => useCase.prepare(
            any(),
            onProgress: any(named: 'onProgress'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer((invocation) async {
          final onProgress =
              invocation.namedArguments[#onProgress]
                  as void Function(DownloadProgress)?;
          onProgress?.call(
            const DownloadProgress(receivedBytes: 50, totalBytes: 100),
          );
          return const Ok(_file);
        });
      },
      build: () => SetWallpaperCubit(useCase),
      act: (cubit) => cubit.startDownload(101),
      expect: () => [
        const SetWallpaperLoadingDownload(DownloadProgress.initial()),
        const SetWallpaperLoadingDownload(
          DownloadProgress(receivedBytes: 50, totalBytes: 100),
        ),
        const SetWallpaperLoadedReady(_file),
      ],
    );

    blocTest<SetWallpaperCubit, SetWallpaperState>(
      'a failure surfaces as Error carrying the mapped AppFailure',
      setUp: () => stubPrepare(const Err(NetworkFailure())),
      build: () => SetWallpaperCubit(useCase),
      act: (cubit) => cubit.startDownload(101),
      expect: () => [
        const SetWallpaperLoadingDownload(DownloadProgress.initial()),
        const SetWallpaperError(NetworkFailure()),
      ],
    );

    blocTest<SetWallpaperCubit, SetWallpaperState>(
      'a second start while one is in flight is ignored (FR-009, INV-3)',
      setUp: () => stubPrepare(const Ok(_file)),
      build: () => SetWallpaperCubit(useCase),
      act: (cubit) async {
        // Not awaited: the second call lands while the first is still running.
        unawaited(cubit.startDownload(101));
        await cubit.startDownload(101);
      },
      verify: (_) {
        verify(
          () => useCase.prepare(
            any(),
            onProgress: any(named: 'onProgress'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).called(1);
      },
    );
  });

  group('cancel and dismissal both clean up (FR-008, INV-4)', () {
    blocTest<SetWallpaperCubit, SetWallpaperState>(
      'cancel returns to Initial and discards the partial file',
      setUp: () =>
          when(
            () => useCase.prepare(
              any(),
              onProgress: any(named: 'onProgress'),
              cancelToken: any(named: 'cancelToken'),
            ),
          ).thenAnswer((_) async {
            await Future<void>.delayed(const Duration(milliseconds: 50));
            return const Err(DownloadFailedFailure());
          }),
      build: () => SetWallpaperCubit(useCase),
      act: (cubit) async {
        unawaited(cubit.startDownload(101));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        await cubit.cancel();
      },
      expect: () => [
        const SetWallpaperLoadingDownload(DownloadProgress.initial()),
        const SetWallpaperInitial(),
      ],
      verify: (_) => verify(() => useCase.discardPartial(101)).called(1),
    );

    test(
      'closing the cubit mid-download also discards — swiping the sheet away '
      'never reaches cancel(), so close() has to clean up too',
      () async {
        when(
          () => useCase.prepare(
            any(),
            onProgress: any(named: 'onProgress'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return const Err(DownloadFailedFailure());
        });

        final cubit = SetWallpaperCubit(useCase);
        unawaited(cubit.startDownload(101));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        await cubit.close();

        verify(() => useCase.discardPartial(101)).called(1);
      },
    );
  });

  group('applyWallpaper', () {
    blocTest<SetWallpaperCubit, SetWallpaperState>(
      'applied -> LoadedApplied',
      setUp: () {
        stubPrepare(const Ok(_file));
        when(
          () => useCase.apply(any()),
        ).thenAnswer((_) async => const Ok(true));
      },
      build: () => SetWallpaperCubit(useCase),
      act: (cubit) async {
        await cubit.startDownload(101);
        await cubit.applyWallpaper();
      },
      skip: 2,
      expect: () => [const SetWallpaperLoadedApplied(_file)],
    );

    blocTest<SetWallpaperCubit, SetWallpaperState>(
      'backing out of the system preview keeps LoadedReady, and is NOT an '
      'error state (FR-016, INV-7)',
      setUp: () {
        stubPrepare(const Ok(_file));
        when(
          () => useCase.apply(any()),
        ).thenAnswer((_) async => const Ok(false));
      },
      build: () => SetWallpaperCubit(useCase),
      act: (cubit) async {
        await cubit.startDownload(101);
        await cubit.applyWallpaper();
      },
      skip: 2,
      expect: () => <SetWallpaperState>[],
      verify: (cubit) =>
          expect(cubit.state, const SetWallpaperLoadedReady(_file)),
    );

    blocTest<SetWallpaperCubit, SetWallpaperState>(
      'a native failure surfaces as Error',
      setUp: () {
        stubPrepare(const Ok(_file));
        when(
          () => useCase.apply(any()),
        ).thenAnswer((_) async => const Err(WallpaperSetFailedFailure()));
      },
      build: () => SetWallpaperCubit(useCase),
      act: (cubit) async {
        await cubit.startDownload(101);
        await cubit.applyWallpaper();
      },
      skip: 2,
      expect: () => [const SetWallpaperError(WallpaperSetFailedFailure())],
    );
  });

  group('saveToPhotos', () {
    blocTest<SetWallpaperCubit, SetWallpaperState>(
      'saved -> LoadedApplied',
      setUp: () {
        stubPrepare(const Ok(_file));
        when(
          () => useCase.saveToPhotos(any()),
        ).thenAnswer((_) async => const Ok(true));
      },
      build: () => SetWallpaperCubit(useCase),
      act: (cubit) async {
        await cubit.startDownload(101);
        await cubit.saveToPhotos();
      },
      skip: 2,
      expect: () => [const SetWallpaperLoadedApplied(_file)],
    );

    blocTest<SetWallpaperCubit, SetWallpaperState>(
      'permission denied surfaces as Error',
      setUp: () {
        stubPrepare(const Ok(_file));
        when(
          () => useCase.saveToPhotos(any()),
        ).thenAnswer((_) async => const Err(FileWriteFailedFailure()));
      },
      build: () => SetWallpaperCubit(useCase),
      act: (cubit) async {
        await cubit.startDownload(101);
        await cubit.saveToPhotos();
      },
      skip: 2,
      expect: () => [const SetWallpaperError(FileWriteFailedFailure())],
    );
  });

  blocTest<SetWallpaperCubit, SetWallpaperState>(
    'retry goes back to Initial so the next attempt fetches a FRESH link '
    '(FR-005, INV-2)',
    setUp: () => stubPrepare(const Err(NetworkFailure())),
    build: () => SetWallpaperCubit(useCase),
    act: (cubit) async {
      await cubit.startDownload(101);
      cubit.retry();
    },
    skip: 2,
    expect: () => [const SetWallpaperInitial()],
  );
}
