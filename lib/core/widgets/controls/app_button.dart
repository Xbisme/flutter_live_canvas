import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';

enum AppButtonVariant { primary, ghost }

/// Primary / ghost button faithful to the prototype. `gradient: true` paints
/// the aurora gradient (brand CTA); otherwise the flat accent (primary) or a
/// bordered surface (ghost).
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.gradient = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == AppButtonVariant.primary;
    final labelColor = isPrimary ? AppColors.onAccent : AppColors.textPrimary;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.rPill),
          child: Ink(
            height: AppSpacing.btnH,
            decoration: BoxDecoration(
              gradient: gradient ? AppColors.aurora : null,
              color: gradient
                  ? null
                  : (isPrimary ? AppColors.accent : AppColors.bgRaised),
              borderRadius: BorderRadius.circular(AppSpacing.rPill),
              border: isPrimary
                  ? null
                  : Border.all(color: AppColors.borderStrong),
            ),
            child: Center(
              child: Text(
                label,
                style: AppTypography.h3.copyWith(color: labelColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
