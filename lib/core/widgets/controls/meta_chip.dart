import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';

/// Tone of a [MetaChip]: [glass] sits over content (blurred dark), [surface]
/// sits on dark UI (raised, bordered).
enum MetaChipTone { glass, surface }

/// Small mono metadata pill (duration / resolution / size) — the handoff
/// `MetaChip`. When [live] it shows a pulsing aqua dot; an optional [icon] sits
/// before the text (used by the detail spec chips).
class MetaChip extends StatelessWidget {
  const MetaChip({
    required this.text,
    this.live = false,
    this.icon,
    this.tone = MetaChipTone.glass,
    super.key,
  });

  final String text;
  final bool live;
  final IconData? icon;
  final MetaChipTone tone;

  @override
  Widget build(BuildContext context) {
    final isGlass = tone == MetaChipTone.glass;
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp2),
      decoration: BoxDecoration(
        color: isGlass
            ? const Color(0x8C0D0A13) // rgba(13,10,19,0.55)
            : AppColors.bgRaised,
        borderRadius: BorderRadius.circular(AppSpacing.rSm),
        border: Border.all(
          color: isGlass ? const Color(0x1FFFFFFF) : AppColors.borderSubtle,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (live) ...[
            const _LiveDot(),
            const SizedBox(width: 5),
          ] else if (icon != null) ...[
            Icon(
              icon,
              size: 13,
              color: isGlass ? AppColors.textHi : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: AppTypography.monoMeta.copyWith(
              color: isGlass ? AppColors.textHi : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pulsing aqua "live loop" indicator.
class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.aqua500,
        boxShadow: [BoxShadow(color: AppColors.aqua500, blurRadius: 6)],
      ),
    );
  }
}
