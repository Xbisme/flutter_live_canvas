import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';

/// The "PRO" badge — one-glance premium distinction via the aurora gradient,
/// per the handoff `premium-treatment` guideline. Deliberately NO lock icon.
class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.aurora,
        borderRadius: BorderRadius.circular(AppSpacing.rXs),
      ),
      child: Text(
        'PRO',
        style: AppTypography.eyebrow.copyWith(color: AppColors.onAccent),
      ),
    );
  }
}
