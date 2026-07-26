import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livecanvas/core/favorites/favorites_repository.dart';
import 'package:livecanvas/core/favorites/favorites_store.dart';
import 'package:livecanvas/core/theme/app_icons.dart';
import 'package:livecanvas/core/widgets/wallpaper/favoritable_wallpaper_tile.dart';
import 'package:livecanvas_api/livecanvas_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/mock_shared_prefs.dart';
import '../../helpers/pump_app.dart';

void main() {
  testWidgets(
    'favouriting a second, different tile still updates (real repo)',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      useInMemorySharedPreferences();
      final repo = FavoritesRepositoryImpl(
        FavoritesStore(SharedPreferencesAsync()),
      );
      addTearDown(repo.dispose);

      await tester.pumpApp(
        Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                for (final id in [1, 2])
                  SizedBox(
                    width: 160,
                    child: FavoritableWallpaperTile(
                      wallpaper: Wallpaper(id: id, title: 'w$id'),
                      favorites: repo,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(AppIcons.heart), findsNWidgets(2));

      // Favourite the first tile.
      await tester.tap(find.byIcon(AppIcons.heart).first);
      await tester.pump();
      expect(find.byIcon(AppIcons.heartFill), findsOneWidget);

      // Favourite the SECOND, different tile — this is what fails on device.
      await tester.tap(find.byIcon(AppIcons.heart));
      await tester.pump();
      expect(find.byIcon(AppIcons.heartFill), findsNWidgets(2));
    },
  );
}
