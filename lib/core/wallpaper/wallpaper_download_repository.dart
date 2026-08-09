import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/core/error/dio_error_mapper.dart';
import 'package:livecanvas/core/wallpaper/download_progress.dart';
import 'package:livecanvas/core/wallpaper/wallpaper_file.dart';
import 'package:livecanvas_api/livecanvas_api.dart';
import 'package:path_provider/path_provider.dart';

/// Downloads the full-resolution master file to app-private storage.
///
/// Lives in `core/` because Collection Detail's "Tải tất cả" (MO-006) will
/// reuse it — `core/` never imports `features/` (Principle XI).
abstract interface class WallpaperDownloadRepository {
  /// Returns the already-downloaded master if there is one, otherwise requests
  /// a FRESH download link and downloads the file.
  ///
  /// The *link* is never stored or reused between calls: it expires in <= 5
  /// minutes, so a cached one is a guaranteed failure later (FR-005). The
  /// *file* is the opposite — reusing it is what makes a second attempt free
  /// (FR-016).
  Future<Result<WallpaperFile>> download(
    int wallpaperId, {
    void Function(DownloadProgress progress)? onProgress,
    CancelToken? cancelToken,
  });

  /// Deletes every master file except [keepWallpaperId] (FR-015, SC-007).
  Future<Result<void>> pruneExcept(int keepWallpaperId);

  /// Removes the partial file left by a cancelled or failed download.
  Future<Result<void>> discardPartial(int wallpaperId);

  /// Deletes the master file for [wallpaperId] (iOS: the copy in Photos is the
  /// one that matters, so the staging file is dropped once saved).
  Future<Result<void>> delete(int wallpaperId);
}

@LazySingleton(as: WallpaperDownloadRepository)
class WallpaperDownloadRepositoryImpl implements WallpaperDownloadRepository {
  /// Builds its own bare [Dio]. Deliberately NOT injected: `get_it` holds the
  /// generated client's Dio, which carries the `X-App-Key` interceptor — taking
  /// that one would ship our app key to the storage provider (research R2).
  WallpaperDownloadRepositoryImpl(this._api) : _fileDio = createFileDio();

  @visibleForTesting
  WallpaperDownloadRepositoryImpl.withDio(this._api, this._fileDio);

  /// The bare client used for the file transfer, exposed so a test can assert
  /// it stays free of interceptors and of the app key.
  @visibleForTesting
  static Dio createFileDio() => Dio();

  final PublicApi _api;

  /// A BARE Dio — deliberately not the generated client's instance.
  ///
  /// That one carries the `X-App-Key` interceptor and the backend base URL,
  /// while the download link points at an S3/R2 host. Sending our app key to a
  /// third-party storage provider would leak it, and unexpected headers risk
  /// colliding with the presigned signature (research R2).
  final Dio _fileDio;

  static const _dirName = 'wallpapers';

  @override
  Future<Result<WallpaperFile>> download(
    int wallpaperId, {
    void Function(DownloadProgress progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    // A complete master already on disk is the answer (FR-016). Only a file
    // that finished the `.part` -> final rename can be here, so "it exists"
    // does mean "it is whole" — a torn download never gets this name.
    final cached = await _completedFile(wallpaperId);
    if (cached != null) {
      onProgress?.call(
        DownloadProgress(
          receivedBytes: cached.sizeBytes,
          totalBytes: cached.sizeBytes,
        ),
      );
      return Ok(cached);
    }

    final String url;
    try {
      final resp = await _api.wallpapersIdDownloadUrlGet(id: wallpaperId);
      final link = resp.data?.downloadUrl;
      if (link == null || link.isEmpty) {
        return const Err(UnknownFailure(message: 'empty body'));
      }
      url = link;
    } on Object catch (e) {
      return Err(_mapDownloadUrlError(e));
    }

    final dir = await _wallpapersDir();
    final target = '${dir.path}/$wallpaperId.${_extensionFor(url)}';
    final partial = '$target.part';

    try {
      await _fileDio.download(
        url,
        partial,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) => onProgress?.call(
          DownloadProgress(
            receivedBytes: received,
            totalBytes: total < 0 ? null : total,
          ),
        ),
      );
    } on Object catch (e) {
      await _deleteQuietly(partial);
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return const Err(DownloadFailedFailure());
      }
      return Err(mapDioError(e));
    }

    try {
      // Write to `.part` then rename, so a torn download never looks valid.
      final file = await File(partial).rename(target);
      return Ok(
        WallpaperFile(
          wallpaperId: wallpaperId,
          path: file.path,
          sizeBytes: await file.length(),
        ),
      );
    } on Object catch (_) {
      await _deleteQuietly(partial);
      return const Err(FileWriteFailedFailure());
    }
  }

  @override
  Future<Result<void>> pruneExcept(int keepWallpaperId) async {
    try {
      final dir = await _wallpapersDir();
      final keep = '$keepWallpaperId';
      for (final entity in dir.listSync().whereType<File>()) {
        final name = entity.uri.pathSegments.last;
        if (name.split('.').first != keep) await _deleteQuietly(entity.path);
      }
      return const Ok(null);
    } on Object catch (e) {
      return Err(UnknownFailure(error: e));
    }
  }

  @override
  Future<Result<void>> discardPartial(int wallpaperId) async {
    try {
      final dir = await _wallpapersDir();
      final prefix = '$wallpaperId.';
      for (final entity in dir.listSync().whereType<File>()) {
        final name = entity.uri.pathSegments.last;
        if (name.startsWith(prefix) && name.endsWith('.part')) {
          await _deleteQuietly(entity.path);
        }
      }
      return const Ok(null);
    } on Object catch (e) {
      return Err(UnknownFailure(error: e));
    }
  }

  @override
  Future<Result<void>> delete(int wallpaperId) async {
    try {
      final dir = await _wallpapersDir();
      final prefix = '$wallpaperId.';
      for (final entity in dir.listSync().whereType<File>()) {
        if (entity.uri.pathSegments.last.startsWith(prefix)) {
          await _deleteQuietly(entity.path);
        }
      }
      return const Ok(null);
    } on Object catch (e) {
      return Err(UnknownFailure(error: e));
    }
  }

  /// The finished master for [wallpaperId], or null if it was never downloaded
  /// (or got pruned by [pruneExcept] when another wallpaper was applied).
  ///
  /// Matches on the `<id>.` prefix rather than a fixed extension: the container
  /// comes from the download link, so the same wallpaper is `.mp4` here and
  /// could be `.mov` elsewhere. `.part` files are skipped — those are torn.
  Future<WallpaperFile?> _completedFile(int wallpaperId) async {
    try {
      final dir = await _wallpapersDir();
      final prefix = '$wallpaperId.';
      for (final entity in dir.listSync().whereType<File>()) {
        final name = entity.uri.pathSegments.last;
        if (!name.startsWith(prefix) || name.endsWith('.part')) continue;
        final size = await entity.length();
        if (size <= 0) continue;
        return WallpaperFile(
          wallpaperId: wallpaperId,
          path: entity.path,
          sizeBytes: size,
        );
      }
      return null;
    } on Object catch (_) {
      // Unreadable cache is not an error: fall through and download again.
      return null;
    }
  }

  Future<Directory> _wallpapersDir() async {
    final support = await getApplicationSupportDirectory();
    final dir = Directory('${support.path}/$_dirName');
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  Future<void> _deleteQuietly(String path) async {
    try {
      final file = File(path);
      if (file.existsSync()) await file.delete();
    } on Object catch (_) {
      // Best-effort cleanup: a leftover temp file must never fail the flow.
    }
  }

  /// Container extension for the downloaded file.
  ///
  /// Derived from the URL path with the query string stripped (presigned links
  /// carry a long `?X-Amz-...` tail). Never hardcoded to `mp4`: the master may
  /// be `.mov`, and a mislabelled file makes `PHAsset` creation on iOS fail in
  /// a way that is hard to trace. The host itself is never inspected (FR-006).
  static String _extensionFor(String url) {
    final path = Uri.tryParse(url)?.path ?? '';
    final name = path.split('/').last;
    final dot = name.lastIndexOf('.');
    if (dot <= 0 || dot == name.length - 1) return 'mp4';
    final ext = name.substring(dot + 1).toLowerCase();
    return RegExp(r'^[a-z0-9]{1,5}$').hasMatch(ext) ? ext : 'mp4';
  }

  /// `download-url` has two outcomes the generic mapper would blur:
  /// 402 means "premium, no entitlement" (-> Paywall, FR-026) and 404 means the
  /// wallpaper is gone — never "you lack permission".
  static AppFailure _mapDownloadUrlError(Object error) {
    if (error is DioException &&
        error.type == DioExceptionType.badResponse &&
        error.response?.statusCode == 402) {
      return const EntitlementRequiredFailure();
    }
    return mapDioError(error);
  }
}
