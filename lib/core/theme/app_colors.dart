import 'package:flutter/widgets.dart';

/// Design colour tokens — the dark, violet-tinted "Void" palette from the
/// handoff (`_ds/tokens/colors.css`). Single source of colour (Principle VI):
/// raw `Color(0xFF...)` at call sites is forbidden — reference these instead.
///
/// The app is dark-only: the handoff defines no light variant (research R4).
abstract final class AppColors {
  // ---- Neutrals: violet-tinted ink, never pure black ----
  static const void_ = Color(0xFF0D0A13); // app background
  static const ink = Color(0xFF12101A); // alt background / scrim base
  static const onyx = Color(0xFF1A1626); // surface: cards, sheets, bars
  static const onyx2 = Color(0xFF241E33); // raised: chips, inputs, pressed
  static const onyx3 = Color(0xFF302943); // hover / active raised

  static const line = Color(0x14FFFFFF); // rgba(255,255,255,.08) hairline
  static const lineStrong = Color(0x29FFFFFF); // rgba(255,255,255,.16)
  static const scrim = Color(0xB809070E); // rgba(9,7,14,.72)

  // ---- Text ----
  static const textHi = Color(0xFFF6F3FB); // primary
  static const textMid = Color(0xFFADA4BE); // secondary
  static const textLo = Color(0xFF6E6683); // tertiary / disabled

  // ---- Brand triad (forms the Aurora gradient) ----
  static const iris400 = Color(0xFF9B82FF); // accent hover / lighter
  static const iris500 = Color(0xFF7C5CFF); // PRIMARY accent
  static const iris600 = Color(0xFF6344E6); // accent press / darker
  static const blush500 = Color(0xFFFF6F9C); // warm — favourites / like
  static const blush400 = Color(0xFFFF8FB2);
  static const aqua500 = Color(0xFF46D5E6); // cool — info / new

  // ---- Semantic ----
  static const Color success = Color(0xFF3FE0A6);
  static const Color warn = Color(0xFFFFC24C);
  static const Color danger = Color(0xFFFF5D6C);

  // ---- Semantic aliases (what components reference) ----
  static const Color bgApp = void_;
  static const Color bgSurface = onyx;
  static const Color bgRaised = onyx2;
  static const Color bgRaisedHover = onyx3;
  static const Color borderSubtle = line;
  static const Color borderStrong = lineStrong;

  static const Color textPrimary = textHi;
  static const Color textSecondary = textMid;
  static const Color textTertiary = textLo;

  static const Color accent = iris500;
  static const Color accentHover = iris400;
  static const Color accentPress = iris600;
  static const Color onAccent = Color(0xFFFFFFFF);
  static const Color favorite = blush500;

  /// Aurora gradient — the brand expression (wordmark, PRO badge, paywall CTA).
  /// 105° sweep across the brand triad (blush → iris → aqua).
  static const aurora = LinearGradient(
    begin: Alignment(-0.87, -0.5),
    end: Alignment(0.87, 0.5),
    colors: [blush500, iris500, aqua500],
    stops: [0, 0.52, 1],
  );

  /// Soft (22% alpha) aurora for large fills / glows.
  static const auroraSoft = LinearGradient(
    begin: Alignment(-0.87, -0.5),
    end: Alignment(0.87, 0.5),
    colors: [Color(0x38FF6F9C), Color(0x387C5CFF), Color(0x3846D5E6)],
    stops: [0, 0.52, 1],
  );
}
