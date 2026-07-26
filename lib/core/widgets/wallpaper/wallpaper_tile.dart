import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/widgets/wallpaper/video_preview.dart';
import 'package:livecanvas/core/widgets/wallpaper/wallpaper_card.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// A single wallpaper in a grid: a lifecycle-managed [VideoPreview] inside the
/// shared [WallpaperCard], with an "Aura" glow.
///
/// The glow hue is picked deterministically from the brand triad by wallpaper
/// id — cheap and stable. It used to be derived from the thumbnail via
/// `palette_generator`, but that decoded + quantized an image on the UI thread
/// for every tile (and decoded the thumbnail a second time), which was a real
/// source of scroll jank. The Aura is decorative, so an exact content colour
/// isn't worth that cost.
class WallpaperTile extends StatelessWidget {
  const WallpaperTile({
    required this.wallpaper,
    this.onTap,
    this.isFav = false,
    this.onFav,
    super.key,
  });

  final Wallpaper wallpaper;
  final VoidCallback? onTap;

  /// Favourite state + toggle, forwarded to the shared [WallpaperCard] heart.
  /// Wired from `FavoritesRepository` (MO-004); default off keeps older callers
  /// compiling unchanged.
  final bool isFav;
  final VoidCallback? onFav;

  /// On-brand aura hues (aurora triad + tints) cycled by id — no decode cost.
  static const List<Color> _auraHues = [
    AppColors.iris500,
    AppColors.blush500,
    AppColors.aqua500,
    AppColors.iris400,
    AppColors.blush400,
  ];

  Color get _aura {
    final seed = wallpaper.id ?? wallpaper.title?.hashCode ?? 0;
    return _auraHues[seed.abs() % _auraHues.length];
  }

  @override
  Widget build(BuildContext context) {
    final w = wallpaper;
    final duration = w.durationSeconds;
    return WallpaperCard(
      auraColor: _aura,
      title: w.title ?? '',
      premium: w.isPremium ?? false,
      meta: duration == null
          ? null
          : WallpaperMeta(duration: '${duration.round()}s'),
      onTap: onTap,
      isFav: isFav,
      onFav: onFav,
      preview: VideoPreview(
        videoUrl: w.previewVideoUrl ?? '',
        posterUrl: w.thumbnailUrl ?? '',
      ),
    );
  }
}
