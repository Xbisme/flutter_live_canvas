import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_elevation.dart';
import 'package:livecanvas/core/theme/app_icons.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';
import 'package:livecanvas/core/widgets/controls/meta_chip.dart';
import 'package:livecanvas/core/widgets/wallpaper/premium_badge.dart';

/// Optional metadata shown on a card / detail (mono chips).
class WallpaperMeta {
  const WallpaperMeta({this.duration, this.resolution, this.size});
  final String? duration;
  final String? resolution;
  final String? size;
}

/// The wallpaper tile — the product's core content unit. A 9:16 [preview]
/// (a looping video in MO-003; a gradient placeholder here) sits under an
/// "Aura" glow whose hue is [auraColor] (mock/static in MO-002, palette-derived
/// in MO-003), with the title/author, a PRO badge when [premium], and a
/// favourite toggle.
class WallpaperCard extends StatelessWidget {
  const WallpaperCard({
    required this.preview,
    required this.auraColor,
    required this.title,
    this.author,
    this.premium = false,
    this.meta,
    this.isFav = false,
    this.onTap,
    this.onFav,
    super.key,
  });

  final Widget preview;
  final Color auraColor;
  final String title;

  /// Attribution handle shown under the title (e.g. `@tokyo`). Hidden when null
  /// — the `Wallpaper` schema has no author, so tiles pass null (MO-003).
  final String? author;
  final bool premium;
  final WallpaperMeta? meta;
  final bool isFav;
  final VoidCallback? onTap;
  final VoidCallback? onFav;

  @override
  Widget build(BuildContext context) {
    final durationChip = meta?.duration;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: AppSpacing.wallRatio,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.rLg),
                boxShadow: [AppElevation.aura(auraColor)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.rLg),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    preview,
                    Positioned(
                      top: AppSpacing.sp2,
                      left: AppSpacing.sp2,
                      child: durationChip == null
                          ? const SizedBox.shrink()
                          : MetaChip(text: durationChip),
                    ),
                    if (premium)
                      const Positioned(
                        top: AppSpacing.sp2,
                        right: AppSpacing.sp2,
                        child: PremiumBadge(),
                      ),
                    Positioned(
                      bottom: AppSpacing.sp2,
                      right: AppSpacing.sp2,
                      child: _FavButton(isFav: isFav, onFav: onFav),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sp2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.h3.copyWith(fontSize: 15),
          ),
          if (author != null && author!.isNotEmpty)
            Text(
              '@$author',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.small,
            ),
        ],
      ),
    );
  }
}

class _FavButton extends StatelessWidget {
  const _FavButton({required this.isFav, required this.onFav});
  final bool isFav;
  final VoidCallback? onFav;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onFav,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sp1),
        decoration: BoxDecoration(
          color: AppColors.scrim,
          borderRadius: BorderRadius.circular(AppSpacing.rPill),
        ),
        child: Icon(
          isFav ? AppIcons.heartFill : AppIcons.heart,
          size: 18,
          color: isFav ? AppColors.favorite : AppColors.textPrimary,
        ),
      ),
    );
  }
}
