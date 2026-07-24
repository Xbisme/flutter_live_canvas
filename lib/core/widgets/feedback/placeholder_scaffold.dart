import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_icons.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';
import 'package:livecanvas/core/widgets/navigation/top_bar.dart';

/// A themed placeholder screen used by MO-002 tab bodies and full-screen
/// route stubs. The real content for each screen arrives in later specs
/// (MO-003+); this proves the shell, theme and navigation work end-to-end.
class PlaceholderScaffold extends StatelessWidget {
  const PlaceholderScaffold({
    required this.title,
    required this.message,
    this.wordmark = false,
    super.key,
  });

  final String title;
  final String message;
  final bool wordmark;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TopBar(title: wordmark ? null : title, wordmark: wordmark),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sp8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      AppIcons.sparkle,
                      size: 40,
                      color: AppColors.accent,
                    ),
                    const SizedBox(height: AppSpacing.sp4),
                    Text(
                      title,
                      style: AppTypography.h3,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sp2),
                    Text(
                      message,
                      style: AppTypography.small,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
