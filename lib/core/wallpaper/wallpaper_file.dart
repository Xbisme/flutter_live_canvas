import 'package:equatable/equatable.dart';

/// A master wallpaper video that has been downloaded to app-private storage.
///
/// Lives under `<applicationSupportDirectory>/wallpapers/` — deliberately NOT
/// the cache dir: on Android the live wallpaper service keeps reading this
/// file long after the app is gone (including across reboots), and the OS is
/// free to purge cache at any time (research R4).
///
/// Invariant: once a wallpaper has been applied, exactly one of these
/// survives — the one currently in use (FR-015, SC-007).
class WallpaperFile extends Equatable {
  const WallpaperFile({
    required this.wallpaperId,
    required this.path,
    required this.sizeBytes,
  });

  final int wallpaperId;

  /// Absolute path inside the app's private support directory.
  final String path;

  final int sizeBytes;

  @override
  List<Object?> get props => [wallpaperId, path, sizeBytes];
}
