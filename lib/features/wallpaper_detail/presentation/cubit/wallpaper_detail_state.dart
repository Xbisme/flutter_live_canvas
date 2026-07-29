import 'package:equatable/equatable.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// State for the Wallpaper Detail screen (US2).
sealed class WallpaperDetailState extends Equatable {
  const WallpaperDetailState();

  @override
  List<Object?> get props => const [];
}

final class WallpaperDetailInitial extends WallpaperDetailState {
  const WallpaperDetailInitial();
}

final class WallpaperDetailLoading extends WallpaperDetailState {
  const WallpaperDetailLoading();
}

final class WallpaperDetailLoaded extends WallpaperDetailState {
  const WallpaperDetailLoaded(this.wallpaper, {this.related = const []});

  final Wallpaper wallpaper;

  /// Wallpapers sharing this one's first tag (fills in after the detail loads;
  /// empty when none / not yet fetched).
  final List<Wallpaper> related;

  @override
  List<Object?> get props => [wallpaper, related];
}

final class WallpaperDetailError extends WallpaperDetailState {
  const WallpaperDetailError(this.failure);

  final AppFailure failure;

  @override
  List<Object?> get props => [failure];
}
