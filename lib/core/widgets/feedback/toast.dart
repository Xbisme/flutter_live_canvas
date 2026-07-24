import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_elevation.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';

/// A short floating toast (e.g. "Đã sao chép liên kết"). Presentation-only;
/// show it with [showToast].
class Toast extends StatelessWidget {
  const Toast({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp4,
        vertical: AppSpacing.sp3,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgRaised,
        borderRadius: BorderRadius.circular(AppSpacing.rMd),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppElevation.shadow2,
      ),
      child: Text(
        text,
        style: AppTypography.small.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}

/// Shows a [Toast] as a transient overlay above the current screen.
void showToast(
  BuildContext context,
  String text, {
  Duration duration = const Duration(seconds: 2),
}) {
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (context) => Positioned(
      left: AppSpacing.gutter,
      right: AppSpacing.gutter,
      bottom: AppSpacing.tabbarH + AppSpacing.sp6,
      child: SafeArea(
        child: Center(child: Toast(text: text)),
      ),
    ),
  );
  overlay.insert(entry);
  Future<void>.delayed(duration, entry.remove);
}
