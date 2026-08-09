import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:livecanvas/core/constants/channel_methods.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/domain/result.dart';
import 'package:livecanvas/core/wallpaper/wallpaper_file.dart';

/// The Dart side of `com.livecanvas/wallpaper` (Principle VIII).
///
/// This is the ONLY place native error codes become [AppFailure] — a raw
/// [PlatformException] must never reach the UI (FR-029).
abstract interface class WallpaperPlatformService {
  /// Whether this device can set a live wallpaper at all.
  ///
  /// A capability check, not a platform check — see [WallpaperChannel].
  Future<bool> isLiveWallpaperSupported();

  /// Android: opens the system live-wallpaper preview.
  ///
  /// `Ok(true)` = the user applied it. `Ok(false)` = the user backed out, which
  /// is a normal action and NOT a failure (FR-016).
  Future<Result<bool>> setLiveWallpaper(WallpaperFile file);

  /// iOS: saves the video to the Photos library as-is.
  Future<Result<bool>> saveVideoToPhotos(WallpaperFile file);

  /// iOS: opens the Shortcuts app. `false` = it isn't installed, which the UI
  /// explains in plain language rather than as an error (FR-022).
  Future<bool> openShortcuts();
}

@LazySingleton(as: WallpaperPlatformService)
class WallpaperPlatformServiceImpl implements WallpaperPlatformService {
  WallpaperPlatformServiceImpl()
    : _channel = const MethodChannel(WallpaperChannel.name);

  @visibleForTesting
  WallpaperPlatformServiceImpl.withChannel(this._channel);

  final MethodChannel _channel;

  @override
  Future<bool> isLiveWallpaperSupported() async {
    try {
      final supported = await _channel.invokeMethod<bool>(
        WallpaperChannel.isLiveWallpaperSupported,
      );
      return supported ?? false;
    } on Object catch (_) {
      // A missing implementation means "no" — never a crash.
      return false;
    }
  }

  @override
  Future<Result<bool>> setLiveWallpaper(WallpaperFile file) async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        WallpaperChannel.setLiveWallpaper,
        {
          'filePath': file.path,
          'wallpaperId': file.wallpaperId,
        },
      );
      return Ok(result?['applied'] as bool? ?? false);
    } on Object catch (e) {
      return Err(_mapNativeError(e));
    }
  }

  @override
  Future<Result<bool>> saveVideoToPhotos(WallpaperFile file) async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        WallpaperChannel.saveVideoToPhotos,
        {'filePath': file.path},
      );
      return Ok(result?['saved'] as bool? ?? false);
    } on Object catch (e) {
      return Err(_mapNativeError(e));
    }
  }

  @override
  Future<bool> openShortcuts() async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        WallpaperChannel.openShortcuts,
      );
      return result?['opened'] as bool? ?? false;
    } on Object catch (_) {
      // Not installed, or Android: the caller shows friendly copy, not an
      // error.
      return false;
    }
  }

  static AppFailure _mapNativeError(Object error) {
    if (error is MissingPluginException) {
      return const PlatformUnsupportedFailure();
    }
    if (error is! PlatformException) return UnknownFailure(error: error);

    return switch (error.code) {
      WallpaperChannelError.unsupported => const PlatformUnsupportedFailure(),
      // "Couldn't write where we needed to write" — covers both a vanished
      // source file and the user denying the Photos library. The differing
      // *advice* (open Settings) is a UI concern, not a new failure kind:
      // AppFailure is the closed set the constitution enumerates.
      WallpaperChannelError.fileMissing => const FileWriteFailedFailure(),
      WallpaperChannelError.permissionDenied => const FileWriteFailedFailure(),
      WallpaperChannelError.setFailed => const WallpaperSetFailedFailure(),
      WallpaperChannelError.saveFailed => const WallpaperSetFailedFailure(),
      _ => UnknownFailure(message: error.message, error: error),
    };
  }
}
