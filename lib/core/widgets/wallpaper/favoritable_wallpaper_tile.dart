import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:livecanvas/core/di/injection.dart';
import 'package:livecanvas/core/favorites/favorites_repository.dart';
import 'package:livecanvas/core/widgets/wallpaper/wallpaper_tile.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// A [WallpaperTile] whose heart is bound to the shared [FavoritesRepository]
/// (MO-004). Used in every grid (Browse, Search, Collection Detail, Favorites)
/// so favourite state stays consistent everywhere (FR-004).
///
/// Binds via [ValueListenableBuilder] so it reads the current set synchronously
/// and rebuilds on every change — no async gap where a rapid second toggle on a
/// different tile is missed. Tapping the heart is optimistic (the repository
/// notifies immediately) with haptic feedback (Principle VII).
class FavoritableWallpaperTile extends StatelessWidget {
  const FavoritableWallpaperTile({
    required this.wallpaper,
    this.onTap,
    this.favorites,
    super.key,
  });

  final Wallpaper wallpaper;
  final VoidCallback? onTap;

  /// Injected in tests; falls back to the registered singleton in the app.
  final FavoritesRepository? favorites;

  @override
  Widget build(BuildContext context) {
    final id = wallpaper.id;
    if (id == null) return WallpaperTile(wallpaper: wallpaper, onTap: onTap);

    final repo = favorites ?? getIt<FavoritesRepository>();
    return ValueListenableBuilder<Set<int>>(
      valueListenable: repo.listenable,
      builder: (context, ids, _) {
        return WallpaperTile(
          wallpaper: wallpaper,
          onTap: onTap,
          isFav: ids.contains(id),
          onFav: () {
            unawaited(HapticFeedback.selectionClick());
            unawaited(repo.toggle(id));
          },
        );
      },
    );
  }
}
