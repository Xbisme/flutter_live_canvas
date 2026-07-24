/// Central route path constants (Principle X) — never hardcode paths at call
/// sites. Navigate only via `context.go/push/pop`; `Navigator.of` is forbidden.
///
/// Pure constants: this lives in `lib/core/` and must NOT import features. The
/// router that wires these paths to feature pages is the composition root in
/// `lib/app/router/` (Principle XI — core does not depend on features).
abstract final class AppRoutes {
  static const browse = '/browse';
  static const search = '/search';
  static const collections = '/collections';
  static const favorites = '/favorites';
  static const profile = '/profile';
  static const wallpaperDetail = '/wallpaper/:id';
  static const collectionDetail = '/collection/:id';

  /// Dev-only widget gallery (FR-006a) — not part of the user-facing flow.
  static const devGallery = '/dev/gallery';
}
