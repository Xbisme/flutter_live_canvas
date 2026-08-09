import 'package:equatable/equatable.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/wallpaper/download_progress.dart';
import 'package:livecanvas/core/wallpaper/wallpaper_file.dart';

/// State of the "Set as wallpaper" sheet.
///
/// Native sealed class + Equatable rather than `@freezed` — the deviation
/// approved in MO-003 (freezed pins analyzer <11 and breaks lean_builder).
/// Extended variants keep the base-state prefix required by Principle III
/// (`loadingDownload`, `loadedReady`, `loadedApplied`), never
/// `success`/`failed`/`empty`.
sealed class SetWallpaperState extends Equatable {
  const SetWallpaperState();

  @override
  List<Object?> get props => [];
}

/// Sheet just opened; nothing requested yet.
final class SetWallpaperInitial extends SetWallpaperState {
  const SetWallpaperInitial();
}

/// Transferring the master file.
final class SetWallpaperLoadingDownload extends SetWallpaperState {
  const SetWallpaperLoadingDownload(this.progress);

  final DownloadProgress progress;

  @override
  List<Object?> get props => [progress];
}

/// File is on the device — the prototype's "Đã tải xuống" state.
final class SetWallpaperLoadedReady extends SetWallpaperState {
  const SetWallpaperLoadedReady(this.file);

  final WallpaperFile file;

  @override
  List<Object?> get props => [file];
}

/// Android: the wallpaper is live. iOS: the video is in Photos.
final class SetWallpaperLoadedApplied extends SetWallpaperState {
  const SetWallpaperLoadedApplied(this.file);

  final WallpaperFile file;

  @override
  List<Object?> get props => [file];
}

/// Any failure, carrying the mapped [AppFailure] — never a raw exception.
final class SetWallpaperError extends SetWallpaperState {
  const SetWallpaperError(this.failure);

  final AppFailure failure;

  @override
  List<Object?> get props => [failure];
}
