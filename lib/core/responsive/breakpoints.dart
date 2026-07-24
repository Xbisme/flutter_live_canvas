import 'package:flutter/widgets.dart';

/// Responsive breakpoints (FR-011b). The shell and shared widgets stay
/// responsive-aware so they don't break on iPad; the full multi-column grid
/// tuning per `ipad.html` lands in MO-003 when there is real content to lay
/// out.
abstract final class Breakpoints {
  /// At or above this logical width the layout is treated as tablet.
  static const double tablet = 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;

  /// Suggested wallpaper-grid column count for the current width. Phones get
  /// 2 columns, tablets 3–4 as they widen. Consumed by MO-003 grids; exposed
  /// now so the foundation is responsive-ready.
  static int gridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1000) return 4;
    if (width >= tablet) return 3;
    return 2;
  }
}
