import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_theme.dart';
import 'package:livecanvas/core/theme/app_typography.dart';

void main() {
  group('AppTheme', () {
    test('is dark-only with the Void background', () {
      final theme = AppTheme.dark;
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppColors.bgApp);
      expect(theme.colorScheme.primary, AppColors.accent);
    });

    test('uses Satoshi as the default body family', () {
      expect(AppTheme.dark.textTheme.bodyLarge?.fontFamily, 'Satoshi');
    });
  });

  group('AppTypography', () {
    test('maps the three brand families', () {
      expect(AppTypography.displayFamily, 'ClashDisplay');
      expect(AppTypography.bodyFamily, 'Satoshi');
      expect(AppTypography.monoFamily, 'SpaceMono');
    });

    test('honours the handoff type scale', () {
      expect(AppTypography.display.fontSize, 40);
      expect(AppTypography.h1.fontSize, 28);
      expect(AppTypography.h2.fontSize, 22);
      expect(AppTypography.h3.fontSize, 18);
      expect(AppTypography.bodyText.fontSize, 15);
      expect(AppTypography.monoMeta.fontSize, 11);
    });
  });

  group('AppSpacing', () {
    test('exposes the 4px grid and wallpaper ratio', () {
      expect(AppSpacing.sp4, 16);
      expect(AppSpacing.tabbarH, 64);
      expect(AppSpacing.wallRatio, 9 / 16);
    });
  });

  group('Bundled fonts', () {
    test('all declared weights exist on disk (no runtime fetch)', () {
      const files = [
        'assets/fonts/ClashDisplay-Regular.ttf',
        'assets/fonts/ClashDisplay-Medium.ttf',
        'assets/fonts/ClashDisplay-Semibold.ttf',
        'assets/fonts/ClashDisplay-Bold.ttf',
        'assets/fonts/Satoshi-Regular.ttf',
        'assets/fonts/Satoshi-Medium.ttf',
        'assets/fonts/Satoshi-Bold.ttf',
        'assets/fonts/Satoshi-Black.ttf',
        'assets/fonts/SpaceMono-Regular.ttf',
        'assets/fonts/SpaceMono-Bold.ttf',
      ];
      for (final path in files) {
        expect(File(path).existsSync(), isTrue, reason: 'missing $path');
      }
    });
  });
}
