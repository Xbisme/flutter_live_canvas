import 'package:flutter/widgets.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// Single source for content icons — the Phosphor set (Principle VI, FR-005).
/// Content icons MUST come from here; mixing Flutter's `Icons`/`CupertinoIcons`
/// is forbidden. Maps the prototype's kebab-case names to the corresponding
/// `PhosphorIcons*` constants (regular by default, fill for active states).
abstract final class AppIcons {
  // Tab bar (regular = inactive, fill = active) — see AppTabBar.
  static const IconData browse = PhosphorIconsRegular.squaresFour;
  static const IconData browseActive = PhosphorIconsFill.squaresFour;
  static const IconData search = PhosphorIconsRegular.magnifyingGlass;
  static const IconData searchActive = PhosphorIconsFill.magnifyingGlass;
  static const IconData collections = PhosphorIconsRegular.stack;
  static const IconData collectionsActive = PhosphorIconsFill.stack;
  static const IconData favorites = PhosphorIconsRegular.heart;
  static const IconData favoritesActive = PhosphorIconsFill.heart;
  static const IconData profile = PhosphorIconsRegular.user;
  static const IconData profileActive = PhosphorIconsFill.user;

  // Common content / control icons used across screens.
  static const IconData caretRight = PhosphorIconsBold.caretRight;
  static const IconData caretLeft = PhosphorIconsBold.caretLeft;
  static const IconData close = PhosphorIconsBold.x;
  static const IconData heart = PhosphorIconsRegular.heart;
  static const IconData heartFill = PhosphorIconsFill.heart;
  static const IconData download = PhosphorIconsRegular.downloadSimple;
  static const IconData share = PhosphorIconsRegular.shareNetwork;
  static const IconData dotsThree = PhosphorIconsBold.dotsThree;
  static const IconData play = PhosphorIconsFill.play;
  static const IconData sparkle = PhosphorIconsFill.sparkle;
  static const IconData check = PhosphorIconsBold.check;
  static const IconData flag = PhosphorIconsRegular.flag;
  static const IconData warning = PhosphorIconsRegular.warningCircle;
  static const IconData imageSquare = PhosphorIconsRegular.imageSquare;
}
