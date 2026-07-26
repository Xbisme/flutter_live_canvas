import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/theme/app_icons.dart';
import 'package:livecanvas/core/widgets/wallpaper/favoritable_wallpaper_tile.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

import '../../helpers/fake_favorites_repository.dart';
import '../../helpers/pump_app.dart';

void main() {
  final wallpaper = Wallpaper(id: 5, title: 'Neon');

  testWidgets('tapping the heart toggles favourite state', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final favorites = FakeFavoritesRepository();
    addTearDown(favorites.dispose);

    await tester.pumpApp(
      Scaffold(
        body: FavoritableWallpaperTile(
          wallpaper: wallpaper,
          favorites: favorites,
        ),
      ),
    );
    await tester.pump();

    // Starts unfavourited (outline heart).
    expect(find.byIcon(AppIcons.heart), findsOneWidget);
    expect(favorites.isFavorite(5), isFalse);

    await tester.tap(find.byIcon(AppIcons.heart));
    await tester.pump();

    expect(favorites.isFavorite(5), isTrue);
    expect(find.byIcon(AppIcons.heartFill), findsOneWidget);
  });

  testWidgets('two tiles for the same id stay in sync via the stream', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final favorites = FakeFavoritesRepository();
    addTearDown(favorites.dispose);

    await tester.pumpApp(
      Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: 160,
                child: FavoritableWallpaperTile(
                  wallpaper: wallpaper,
                  favorites: favorites,
                ),
              ),
              SizedBox(
                width: 160,
                child: FavoritableWallpaperTile(
                  wallpaper: wallpaper,
                  favorites: favorites,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(AppIcons.heart), findsNWidgets(2));

    // Toggling one tile reflects on both (FR-004).
    await tester.tap(find.byIcon(AppIcons.heart).first);
    await tester.pump();

    expect(find.byIcon(AppIcons.heartFill), findsNWidgets(2));
  });
}
