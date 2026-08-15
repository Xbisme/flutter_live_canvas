import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/core/favorites/download_history_repository.dart';
import 'package:livecanvas/core/wallpaper/download_progress.dart';
import 'package:livecanvas/core/wallpaper/wallpaper_download_repository.dart';
import 'package:livecanvas/core/wallpaper/wallpaper_file.dart';
import 'package:livecanvas/core/wallpaper/wallpaper_platform_service.dart';

/// Orchestrates download -> history -> set/save.
///
/// It exists because Principle XI forbids repository-to-repository calls:
/// [WallpaperDownloadRepository] and [DownloadHistoryRepository] are peers in
/// `core/`, so something above both has to bridge them (research R9).
abstract interface class SetWallpaperUseCase {
  /// Downloads the master file, then records the download in local history
  /// exactly once — and only when the file actually landed (FR-023).
  ///
  /// Because the write sits here, the cancelled / network-error / 402 paths
  /// skip it automatically instead of needing a guard in each branch.
  Future<Result<WallpaperFile>> prepare(
    int wallpaperId, {
    void Function(DownloadProgress progress)? onProgress,
    CancelToken? cancelToken,
  });

  /// Android: applies the wallpaper, then prunes the files no longer in use.
  ///
  /// `Ok(false)` = the user backed out of the system preview; the file is kept
  /// so a retry costs no second download (FR-016).
  Future<Result<bool>> apply(WallpaperFile file);

  /// iOS: saves to Photos, then drops the staging copy.
  Future<Result<bool>> saveToPhotos(WallpaperFile file);

  /// Drops the partial file left behind by a cancelled download (FR-008).
  Future<void> discardPartial(int wallpaperId);
}

@LazySingleton(as: SetWallpaperUseCase)
class SetWallpaperUseCaseImpl implements SetWallpaperUseCase {
  SetWallpaperUseCaseImpl(this._downloads, this._platform, this._history);

  final WallpaperDownloadRepository _downloads;
  final WallpaperPlatformService _platform;
  final DownloadHistoryRepository _history;

  @override
  Future<Result<WallpaperFile>> prepare(
    int wallpaperId, {
    void Function(DownloadProgress progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final result = await _downloads.download(
      wallpaperId,
      onProgress: onProgress,
      cancelToken: cancelToken,
    );

    if (result is Ok<WallpaperFile>) {
      // History is a convenience log. If it fails, the user must still be able
      // to set their wallpaper — so the failure is swallowed, not propagated.
      await _history.record(wallpaperId);
    }
    return result;
  }

  @override
  Future<Result<bool>> apply(WallpaperFile file) async {
    final result = await _platform.setLiveWallpaper(file);
    if (result is Ok<bool> && result.value) {
      await _downloads.pruneExcept(file.wallpaperId);
    }
    return result;
  }

  @override
  Future<Result<bool>> saveToPhotos(WallpaperFile file) async {
    final result = await _platform.saveVideoToPhotos(file);
    if (result is Ok<bool> && result.value) {
      await _downloads.delete(file.wallpaperId);
    }
    return result;
  }

  @override
  Future<void> discardPartial(int wallpaperId) =>
      _downloads.discardPartial(wallpaperId);
}
