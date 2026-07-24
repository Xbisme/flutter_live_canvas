import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:shimmer/shimmer.dart';

/// A single shimmering skeleton block, styled to the dark "Void" palette
/// (Principle VI / FR-028). Compose these into layout-matching skeletons
/// (grid tiles, cards, hero) shown while a Cubit is in its `loading` state.
///
/// The shimmer is a pure visual affordance — it is shown/hidden by the widget
/// tree reacting to state, never on a timer (FR-029).
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    this.width,
    this.height,
    this.radius = AppSpacing.rMd,
    this.aspectRatio,
    super.key,
  });

  final double? width;
  final double? height;
  final double radius;

  /// If set, the box sizes by aspect ratio instead of a fixed [height]
  /// (e.g. `AppSpacing.wallRatio` for wallpaper tiles).
  final double? aspectRatio;

  @override
  Widget build(BuildContext context) {
    final box = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.onyx2,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: SizedBox(width: width, height: height),
    );

    final sized = aspectRatio != null
        ? AspectRatio(aspectRatio: aspectRatio!, child: box)
        : box;

    return Shimmer.fromColors(
      baseColor: AppColors.onyx2,
      highlightColor: AppColors.onyx3,
      child: sized,
    );
  }
}
