import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';

/// Centered empty-state: a Phosphor icon, a title, a message, and an optional
/// action. Used where a list has no items (Favorites, filtered results).
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sp8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.textTertiary),
            const SizedBox(height: AppSpacing.sp4),
            Text(title, style: AppTypography.h3, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sp2),
            Text(
              message,
              style: AppTypography.small,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.sp5),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
