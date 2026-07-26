import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/widgets/feedback/skeleton/shimmer_box.dart';

/// Loading placeholder for the Collections tab: shimmer cover cards matching
/// the real list layout (FR-027). State-driven (FR-029).
class CollectionListSkeleton extends StatelessWidget {
  const CollectionListSkeleton({this.itemCount = 4, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.gutter),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sp5),
      itemBuilder: (context, index) => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(aspectRatio: 16 / 9, radius: AppSpacing.rLg),
          SizedBox(height: AppSpacing.sp2),
          ShimmerBox(width: 160, height: 16),
        ],
      ),
    );
  }
}
