import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';

/// Small metadata label in Space Mono — duration / resolution / size / counts.
/// A raised, low-emphasis pill used on cards and detail chrome.
class MetaChip extends StatelessWidget {
  const MetaChip({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp2,
        vertical: AppSpacing.sp1,
      ),
      decoration: BoxDecoration(
        color: AppColors.scrim,
        borderRadius: BorderRadius.circular(AppSpacing.rXs),
      ),
      child: Text(text, style: AppTypography.monoMeta),
    );
  }
}
