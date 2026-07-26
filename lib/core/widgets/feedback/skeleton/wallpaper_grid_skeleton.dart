import 'package:flutter/material.dart';
import 'package:livecanvas/core/responsive/breakpoints.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/widgets/feedback/skeleton/shimmer_box.dart';

/// Loading placeholder for a wallpaper grid: shimmer tiles laid out at the same
/// column count and aspect ratio as the real grid (FR-027). Shown while the
/// Cubit is in its loading/reloading state — never on a timer (FR-029).
class WallpaperGridSkeleton extends StatelessWidget {
  const WallpaperGridSkeleton({this.itemCount = 6, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.gutter),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Breakpoints.gridColumns(context),
        crossAxisSpacing: AppSpacing.gridGap,
        mainAxisSpacing: AppSpacing.gridGap,
        childAspectRatio: AppSpacing.wallRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ShimmerBox(radius: AppSpacing.rLg),
    );
  }
}
