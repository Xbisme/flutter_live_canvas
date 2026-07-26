import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/widgets/feedback/skeleton/shimmer_box.dart';

/// Loading placeholder for Wallpaper Detail: a hero preview block plus title /
/// meta lines, matching the loaded layout (FR-027). State-driven (FR-029).
class WallpaperDetailSkeleton extends StatelessWidget {
  const WallpaperDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: const [
        ShimmerBox(aspectRatio: AppSpacing.wallRatio, radius: 0),
        Padding(
          padding: EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 200, height: 28),
              SizedBox(height: AppSpacing.sp3),
              ShimmerBox(width: 140, height: 16),
              SizedBox(height: AppSpacing.sp6),
              ShimmerBox(height: AppSpacing.btnH, radius: AppSpacing.rPill),
            ],
          ),
        ),
      ],
    );
  }
}
