/// Spacing, radius and control-sizing tokens — a 4px base grid from the
/// handoff (`_ds/tokens/spacing.css`). Named constants only (Principle VI):
/// magic pixel numbers at call sites are forbidden.
abstract final class AppSpacing {
  // 4px scale
  static const double sp1 = 4;
  static const double sp2 = 8;
  static const double sp3 = 12;
  static const double sp4 = 16;
  static const double sp5 = 20;
  static const double sp6 = 24;
  static const double sp8 = 32;
  static const double sp10 = 40;
  static const double sp12 = 48;
  static const double sp16 = 64;

  // Screen gutters + grid
  static const double gutter = 16; // screen edge padding
  static const double gridGap = 12; // gap between wallpaper tiles

  // Corner radius
  static const double rXs = 6;
  static const double rSm = 10;
  static const double rMd = 14;
  static const double rLg = 20; // wallpaper tile
  static const double rXl = 28; // hero card / bottom sheet
  static const double rPill = 999;

  // Control sizing
  static const double hit = 44; // minimum touch target
  static const double btnH = 52; // primary button height
  static const double chipH = 36; // filter chip height
  static const double iconBtn = 44; // circular icon button
  static const double tabbarH = 64; // bottom nav height

  /// Wallpaper tile aspect ratio (width / height).
  static const double wallRatio = 9 / 16;
}
