import 'package:flutter/widgets.dart';

/// Elevation + the "Aura" signature glow from the handoff
/// (`_ds/tokens/elevation.css`). Shadows are dark and soft (dark UI).
///
/// The Aura is a large, colour-derived glow cast by wallpaper content — its
/// COLOUR is supplied at runtime (`auraColor`); MO-002 uses the hue provided
/// by mock/gallery data, MO-003 derives it from the real image. Everything
/// except the hue is fixed here.
abstract final class AppElevation {
  static const List<BoxShadow> shadow1 = [
    BoxShadow(color: Color(0x4D000000), offset: Offset(0, 2), blurRadius: 8),
  ];
  static const List<BoxShadow> shadow2 = [
    BoxShadow(color: Color(0x6B000000), offset: Offset(0, 8), blurRadius: 24),
  ];
  static const List<BoxShadow> shadow3 = [
    BoxShadow(color: Color(0x80000000), offset: Offset(0, 16), blurRadius: 48),
  ];
  static const List<BoxShadow> shadowSheet = [
    BoxShadow(color: Color(0x8C000000), offset: Offset(0, -10), blurRadius: 44),
  ];

  // Aura tuning (colour is per-tile, passed in).
  static const double auraBlur = 36;
  static const double auraSpread = -6;
  static const Color auraDefault = Color(0x8C7C5CFF); // iris500 @ 55%

  // Glass backdrops (bars / sheets) → BackdropFilter(ImageFilter.blur).
  static const double blurBar = 18;
  static const double blurSheet = 28;

  /// The signature glow behind a wallpaper tile. [color] = content hue.
  static BoxShadow aura(Color color) => BoxShadow(
    color: color,
    blurRadius: auraBlur,
    spreadRadius: auraSpread,
    offset: const Offset(0, 10),
  );
}
