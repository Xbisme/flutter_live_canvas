import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';

/// The single app [ThemeData] — dark-only (the handoff defines no light
/// variant; research R4). Assembled entirely from the token layers so no
/// surface hardcodes visual values (Principle VI).
abstract final class AppTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      surface: AppColors.bgSurface,
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.aqua500,
      error: AppColors.danger,
      onSurface: AppColors.textPrimary,
      outline: AppColors.borderStrong,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bgApp,
      canvasColor: AppColors.bgApp,
      fontFamily: AppTypography.bodyFamily,
      textTheme: AppTypography.textTheme,
      splashColor: AppColors.iris500.withValues(alpha: 0.12),
      highlightColor: AppColors.iris500.withValues(alpha: 0.08),
      dividerColor: AppColors.borderSubtle,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.bgSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.rXl),
          ),
        ),
      ),
    );
  }
}
