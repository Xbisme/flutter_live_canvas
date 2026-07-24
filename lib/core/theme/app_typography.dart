import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_colors.dart';

/// Typography tokens — the three-family type system from the handoff
/// (`_ds/tokens/typography.css`). Shared text styles live here (Principle VI):
/// inline `.copyWith` for shared type values is forbidden.
///
///   Display : Clash Display — headlines, wordmark, big paywall numbers
///   Body/UI : Satoshi       — every UI surface, buttons, body (default)
///   Utility : Space Mono    — metadata (duration/res/size), tags, counts
abstract final class AppTypography {
  static const String displayFamily = 'ClashDisplay';
  static const String bodyFamily = 'Satoshi';
  static const String monoFamily = 'SpaceMono';

  // Weights
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight black = FontWeight.w900;

  // Named shared styles (colour defaults to primary; override per surface).
  static const TextStyle display = TextStyle(
    fontFamily: displayFamily,
    fontSize: 40,
    height: 1.05,
    letterSpacing: -0.8, // -0.02em
    fontWeight: bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: displayFamily,
    fontSize: 28,
    height: 1.2,
    fontWeight: bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: displayFamily,
    fontSize: 22,
    height: 1.2,
    fontWeight: medium,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 18,
    height: 1.2,
    fontWeight: bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyText = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 15,
    height: 1.45,
    fontWeight: regular,
    color: AppColors.textPrimary,
  );

  static const TextStyle small = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 13,
    height: 1.45,
    fontWeight: medium,
    color: AppColors.textSecondary,
  );

  /// Metadata / tags / counts — Space Mono, wide tracking.
  static const TextStyle monoMeta = TextStyle(
    fontFamily: monoFamily,
    fontSize: 11,
    height: 1.2,
    letterSpacing: 0.88, // 0.08em
    fontWeight: regular,
    color: AppColors.textSecondary,
  );

  /// Micro eyebrow label — mono, wide tracking, uppercase at call site.
  static const TextStyle eyebrow = TextStyle(
    fontFamily: monoFamily,
    fontSize: 10,
    height: 1.2,
    letterSpacing: 0.8,
    fontWeight: bold,
    color: AppColors.textTertiary,
  );

  /// Assembles the Material [TextTheme] from the tokens above.
  static const TextTheme textTheme = TextTheme(
    displayLarge: display,
    headlineLarge: h1,
    headlineMedium: h2,
    titleLarge: h3,
    bodyLarge: bodyText,
    bodyMedium: bodyText,
    labelLarge: small,
    labelSmall: eyebrow,
  );
}
