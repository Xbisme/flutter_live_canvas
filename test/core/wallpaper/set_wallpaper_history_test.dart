import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/core/favorites/download_history_entry.dart';
import 'package:livecanvas/core/favorites/download_history_repository.dart';
import 'package:livecanvas/core/wallpaper/set_wallpaper_use_case.dart';
import 'package:livecanvas/core/wallpaper/wallpaper_download_repository.dart';
import 'package:livecanvas/core/wallpaper/wallpaper_file.dart';
import 'package:livecanvas/core/wallpaper/wallpaper_platform_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockDownloads extends Mock implements WallpaperDownloadRepository {}

class _MockPlatform extends Mock implements WallpaperPlatformService {}

/// A real-enough history: dedupes by id and keeps newest first, exactly like
/// the store MO-004 shipped. Using this instead of a bare mock lets the test
/// assert the end state a user actually sees.
class _FakeHistory implements DownloadHistoryRepository {
  final List<DownloadHistoryEntry> entries = [];
  DateTime clock = DateTime.utc(2026, 8, 9);

  @override
  Future<Result<void>> record(int wallpaperId) async {
    clock = clock.add(const Duration(minutes: 1));
    entries
      ..removeWhere((e) => e.wallpaperId == wallpaperId)
      ..insert(
        0,
        DownloadHistoryEntry(wallpaperId: wallpaperId, downloadedAt: clock),
      );
    return const Ok(null);
  }

  @override
  Future<Result<List<DownloadHistoryEntry>>> read() async => Ok(entries);

  @override
  Future<void> prune(Set<int> ids) async =>
      entries.removeWhere((e) => ids.contains(e.wallpaperId));
}

const _file = WallpaperFile(
  wallpaperId: 101,
  path: '/tmp/wallpapers/101.mp4',
  sizeBytes: 1024,
);

void main() {
  late _MockDownloads downloads;
  late _FakeHistory history;
  late SetWallpaperUseCase useCase;

  setUpAll(() {
    registerFallbackValue(_file);
    registerFallbackValue(CancelToken());
  });

  setUp(() {
    downloads = _MockDownloads();
    history = _FakeHistory();
    useCase = SetWallpaperUseCaseImpl(downloads, _MockPlatform(), history);
  });

  void stubDownload(Result<WallpaperFile> result) => when(
    () => downloads.download(
      any(),
      onProgress: any(named: 'onProgress'),
      cancelToken: any(named: 'cancelToken'),
    ),
  ).thenAnswer((_) async => result);

  test('a completed download lands at the top of the history', () async {
    stubDownload(const Ok(_file));

    await useCase.prepare(101);

    expect(history.entries.single.wallpaperId, 101);
  });

  test(
    'downloading the same wallpaper three times leaves ONE entry, at the top '
    '(SC-005)',
    () async {
      stubDownload(const Ok(_file));
      const other = WallpaperFile(
        wallpaperId: 202,
        path: '/tmp/wallpapers/202.mp4',
        sizeBytes: 1,
      );

      await useCase.prepare(101);
      stubDownload(const Ok(other));
      await useCase.prepare(202);
      stubDownload(const Ok(_file));
      await useCase.prepare(101);
      await useCase.prepare(101);

      expect(history.entries.map((e) => e.wallpaperId), [101, 202]);
    },
  );

  test('nothing is recorded when the download never completes', () async {
    stubDownload(const Err(NetworkFailure()));
    await useCase.prepare(101);

    stubDownload(const Err(DownloadFailedFailure()));
    await useCase.prepare(102);

    stubDownload(const Err(EntitlementRequiredFailure()));
    await useCase.prepare(103);

    expect(history.entries, isEmpty);
  });
}
