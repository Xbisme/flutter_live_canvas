import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';

/// Pill filter chip (`chipH` tall). Selected → accent fill; the "All" chip is
/// selected by default at the call site (MO-003).
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.accent : AppColors.bgRaised,
      borderRadius: BorderRadius.circular(AppSpacing.rPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.rPill),
        child: Container(
          height: AppSpacing.chipH,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.small.copyWith(
              color: selected ? AppColors.onAccent : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
