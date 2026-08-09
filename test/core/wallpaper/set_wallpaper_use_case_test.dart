import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/core/favorites/download_history_repository.dart';
import 'package:livecanvas/core/wallpaper/set_wallpaper_use_case.dart';
import 'package:livecanvas/core/wallpaper/wallpaper_download_repository.dart';
import 'package:livecanvas/core/wallpaper/wallpaper_file.dart';
import 'package:livecanvas/core/wallpaper/wallpaper_platform_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockDownloads extends Mock implements WallpaperDownloadRepository {}

class _MockPlatform extends Mock implements WallpaperPlatformService {}

class _MockHistory extends Mock implements DownloadHistoryRepository {}

const _file = WallpaperFile(
  wallpaperId: 101,
  path: '/tmp/wallpapers/101.mp4',
  sizeBytes: 1024,
);

void main() {
  late _MockDownloads downloads;
  late _MockPlatform platform;
  late _MockHistory history;
  late SetWallpaperUseCase useCase;

  setUpAll(() {
    registerFallbackValue(_file);
    registerFallbackValue(CancelToken());
  });

  setUp(() {
    downloads = _MockDownloads();
    platform = _MockPlatform();
    history = _MockHistory();
    useCase = SetWallpaperUseCaseImpl(downloads, platform, history);

    when(() => history.record(any())).thenAnswer((_) async => const Ok(null));
    when(
      () => downloads.pruneExcept(any()),
    ).thenAnswer((_) async => const Ok(null));
    when(() => downloads.delete(any())).thenAnswer((_) async => const Ok(null));
    when(
      () => downloads.discardPartial(any()),
    ).thenAnswer((_) async => const Ok(null));
  });

  void stubDownload(Result<WallpaperFile> result) => when(
    () => downloads.download(
      any(),
      onProgress: any(named: 'onProgress'),
      cancelToken: any(named: 'cancelToken'),
    ),
  ).thenAnswer((_) async => result);

  group('prepare records history exactly once, and only on success', () {
    test('success -> record called once with the right id (INV-1)', () async {
      stubDownload(const Ok(_file));

      final result = await useCase.prepare(101);

      expect(result, isA<Ok<WallpaperFile>>());
      verify(() => history.record(101)).called(1);
    });

    test('network error -> never recorded (FR-024)', () async {
      stubDownload(const Err(NetworkFailure()));

      await useCase.prepare(101);

      verifyNever(() => history.record(any()));
    });

    test('cancelled -> never recorded (FR-024)', () async {
      stubDownload(const Err(DownloadFailedFailure()));

      await useCase.prepare(101);

      verifyNever(() => history.record(any()));
    });

    test('402 premium block -> never recorded (FR-024, SC-008)', () async {
      stubDownload(const Err(EntitlementRequiredFailure()));

      await useCase.prepare(101);

      verifyNever(() => history.record(any()));
    });

    test(
      'a failing history write must not sink the download — the log is a '
      'convenience, setting the wallpaper is the job',
      () async {
        stubDownload(const Ok(_file));
        when(
          () => history.record(any()),
        ).thenAnswer((_) async => const Err(UnknownFailure()));

        final result = await useCase.prepare(101);

        expect(result, isA<Ok<WallpaperFile>>());
      },
    );

    test(
      'three downloads of the same id record three times (SC-005)',
      () async {
        stubDownload(const Ok(_file));

        await useCase.prepare(101);
        await useCase.prepare(101);
        await useCase.prepare(101);

        // Dedupe to a single newest-first entry is the store's job (MO-004);
        // the use case's contract is simply to report every completed download.
        verify(() => history.record(101)).called(3);
      },
    );
  });

  group('apply', () {
    test('applied -> prunes the files no longer in use (FR-015)', () async {
      when(
        () => platform.setLiveWallpaper(any()),
      ).thenAnswer((_) async => const Ok(true));

      await useCase.apply(_file);

      verify(() => downloads.pruneExcept(101)).called(1);
    });

    test(
      'user backed out -> keeps the file so a retry costs no second '
      'download (FR-016, INV-7)',
      () async {
        when(
          () => platform.setLiveWallpaper(any()),
        ).thenAnswer((_) async => const Ok(false));

        final result = await useCase.apply(_file);

        expect((result as Ok<bool>).value, isFalse);
        verifyNever(() => downloads.pruneExcept(any()));
      },
    );

    test('native failure -> no pruning', () async {
      when(
        () => platform.setLiveWallpaper(any()),
      ).thenAnswer((_) async => const Err(WallpaperSetFailedFailure()));

      await useCase.apply(_file);

      verifyNever(() => downloads.pruneExcept(any()));
    });
  });

  group('saveToPhotos', () {
    test('saved -> drops the staging copy', () async {
      when(
        () => platform.saveVideoToPhotos(any()),
      ).thenAnswer((_) async => const Ok(true));

      await useCase.saveToPhotos(_file);

      verify(() => downloads.delete(101)).called(1);
    });

    test('denied -> keeps the file for a retry after granting', () async {
      when(
        () => platform.saveVideoToPhotos(any()),
      ).thenAnswer((_) async => const Err(FileWriteFailedFailure()));

      await useCase.saveToPhotos(_file);

      verifyNever(() => downloads.delete(any()));
    });
  });
}
