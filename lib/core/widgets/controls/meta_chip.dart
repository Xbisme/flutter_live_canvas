import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';

/// Small mono metadata pill (duration / resolution / size) — the handoff
/// `MetaChip`, glass tone. When [live] it shows a pulsing aqua dot before the
/// text (the "live loop" indicator used on wallpaper tiles).
class MetaChip extends StatelessWidget {
  const MetaChip({required this.text, this.live = false, super.key});

  final String text;
  final bool live;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp2),
      decoration: BoxDecoration(
        color: const Color(0x8C0D0A13), // rgba(13,10,19,0.55)
        borderRadius: BorderRadius.circular(AppSpacing.rSm),
        border: Border.all(color: const Color(0x1FFFFFFF)), // white 0.12
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (live) ...[
            const _LiveDot(),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: AppTypography.monoMeta.copyWith(color: AppColors.textHi),
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
