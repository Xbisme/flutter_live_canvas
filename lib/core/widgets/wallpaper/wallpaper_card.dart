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

/// The wallpaper tile — the product's signature 9:16 unit (handoff
/// `WallpaperCard`). A [preview] fills the tile under an "Aura" glow
/// ([auraColor]); the title/author sit **inside** the tile over a bottom scrim
/// gradient, with a live duration chip + PRO badge up top and a glass favourite
/// heart bottom-right. Premium tiles carry an iridescent aurora hairline ring.
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

  /// Attribution handle shown under the title (e.g. `tokyo`). Hidden when null
  /// — the `Wallpaper` schema has no author, so tiles pass null (MO-003).
  final String? author;
  final bool premium;
  final WallpaperMeta? meta;
  final bool isFav;
  final VoidCallback? onTap;
  final VoidCallback? onFav;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: AppSpacing.wallRatio,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.rLg),
            boxShadow: [AppElevation.aura(auraColor)],
          ),
          child: _RingedTile(premium: premium, child: _content()),
        ),
      ),
    );
  }

  Widget _content() {
    final duration = meta?.duration;
    return Stack(
      fit: StackFit.expand,
      children: [
        preview,
        // Top row: live duration chip (left) + PRO badge (right).
        Positioned(
          top: AppSpacing.sp2,
          left: AppSpacing.sp2,
          right: AppSpacing.sp2,
          child: Row(
            children: [
              if (duration != null) MetaChip(text: duration, live: true),
              const Spacer(),
              if (premium) const PremiumBadge(),
            ],
          ),
        ),
        // Bottom scrim + title/author.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _TitleScrim(title: title, author: author),
        ),
        // Favourite heart.
        Positioned(
          right: AppSpacing.sp2,
          bottom: AppSpacing.sp3 - 2, // 10
          child: _FavButton(isFav: isFav, onFav: onFav),
        ),
      ],
    );
  }
}

/// Adds the tile's rounded clip plus the border: a 1px hairline for free tiles,
/// an aurora gradient ring for premium ones.
class _RingedTile extends StatelessWidget {
  const _RingedTile({required this.premium, required this.child});

  final bool premium;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSpacing.rLg);
    if (premium) {
      return Container(
        decoration: BoxDecoration(
          gradient: AppColors.aurora,
          borderRadius: radius,
        ),
        padding: const EdgeInsets.all(1.5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.rLg - 1.5),
          child: child,
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: ClipRRect(borderRadius: radius, child: child),
    );
  }
}

class _TitleScrim extends StatelessWidget {
  const _TitleScrim({required this.title, this.author});

  final String title;
  final String? author;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 26, 12, 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xC709070E), Color(0x0009070E)], // 0.78 → 0
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.small.copyWith(
              fontSize: 13,
              height: 1.2,
              fontWeight: AppTypography.bold,
              color: AppColors.onAccent,
            ),
          ),
          if (author != null && author!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                author!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.small.copyWith(
                  fontSize: 10,
                  color: const Color(0xB8F6F3FB), // rgba(246,243,251,0.72)
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Circular glass favourite heart (handoff `IconButton variant="glass"`,
/// size 36). Fills blush + glows when active.
class _FavButton extends StatelessWidget {
  const _FavButton({required this.isFav, required this.onFav});
  final bool isFav;
  final VoidCallback? onFav;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onFav,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isFav ? AppColors.favorite : const Color(0x7014101E),
          border: Border.all(
            color: isFav ? Colors.transparent : const Color(0x24FFFFFF),
          ),
          boxShadow: isFav
              ? const [
                  BoxShadow(
                    color: Color(0x73FF6F9C), // rgba(255,111,156,0.45)
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          isFav ? AppIcons.heartFill : AppIcons.heart,
          size: 17,
          color: AppColors.onAccent,
        ),
      ),
    );
  }
}
