import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';

enum AppIconButtonVariant { solid, ghost }

/// Circular icon button (`iconBtn` diameter). Icons come from the Phosphor set
/// via `AppIcons` (Principle VI) — never Flutter's `Icons`.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    this.variant = AppIconButtonVariant.ghost,
    this.semanticLabel,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final AppIconButtonVariant variant;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final solid = variant == AppIconButtonVariant.solid;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: solid ? AppColors.bgRaised : Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: AppSpacing.iconBtn,
            height: AppSpacing.iconBtn,
            child: Icon(icon, size: 22, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
