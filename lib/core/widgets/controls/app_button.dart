import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';

/// Button variants from the handoff `Button`:
/// - [primary]  iris solid
/// - [ghost]    raised bordered surface (the design's "secondary")
/// - [light]    white contrast button (the Detail "Set wallpaper" hero)
enum AppButtonVariant { primary, ghost, light }

/// Action button faithful to the prototype: pill shape, body 15/700 label, an
/// optional leading [icon], and a soft shadow. `gradient: true` paints the
/// aurora brand CTA; [glow] tints the drop shadow (e.g. a wallpaper's aura on
/// the "Set" hero).
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.gradient = false,
    this.icon,
    this.glow,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool gradient;
  final IconData? icon;
  final Color? glow;

  @override
  Widget build(BuildContext context) {
    final labelColor = switch (variant) {
      AppButtonVariant.primary => AppColors.onAccent,
      AppButtonVariant.light => const Color(0xFF141018),
      AppButtonVariant.ghost => AppColors.textPrimary,
    };
    final fill = gradient
        ? null
        : switch (variant) {
            AppButtonVariant.primary => AppColors.accent,
            AppButtonVariant.light => AppColors.onAccent,
            AppButtonVariant.ghost => AppColors.bgRaised,
          };

    final shadow = _shadow();

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
              color: fill,
              borderRadius: BorderRadius.circular(AppSpacing.rPill),
              border: variant == AppButtonVariant.ghost
                  ? Border.all(color: AppColors.borderStrong)
                  : null,
              boxShadow: shadow,
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 19, color: labelColor),
                    const SizedBox(width: AppSpacing.sp2),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyText.copyWith(
                        fontWeight: AppTypography.bold,
                        letterSpacing: 0.15,
                        color: labelColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<BoxShadow>? _shadow() {
    if (glow != null) {
      return [
        BoxShadow(color: glow!, blurRadius: 24, offset: const Offset(0, 8)),
      ];
    }
    if (gradient) {
      return const [
        BoxShadow(
          color: Color(0x667C5CFF), // rgba(124,92,255,0.40)
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ];
    }
    if (variant == AppButtonVariant.primary) {
      return const [
        BoxShadow(
          color: Color(0x617C5CFF), // rgba(124,92,255,0.38)
          blurRadius: 18,
          offset: Offset(0, 6),
        ),
      ];
    }
    return null;
  }
}
