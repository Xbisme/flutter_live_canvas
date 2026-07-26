import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_icons.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';

/// The "PRO" badge — an iridescent aurora-gradient pill with a diamond gem,
/// per the handoff `PremiumBadge` (variant "tag"). Deliberately NO lock icon.
class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        gradient: AppColors.aurora,
        borderRadius: BorderRadius.circular(AppSpacing.rPill),
        boxShadow: const [
          BoxShadow(
            color: Color(0x737C5CFF), // rgba(124,92,255,0.45)
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(AppIcons.diamond, size: 10, color: AppColors.onAccent),
          const SizedBox(width: 4),
          Text(
            'PRO',
            style: AppTypography.small.copyWith(
              fontSize: 10,
              height: 1,
              fontWeight: AppTypography.bold,
              letterSpacing: 1, // 0.1em
              color: AppColors.onAccent,
            ),
          ),
        ],
      ),
    );
  }
}
