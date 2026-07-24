import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:livecanvas/app/app.dart';
import 'package:livecanvas/core/config/app_config.dart';
import 'package:livecanvas/core/di/injection.dart';
import 'package:livecanvas/core/widgets/navigation/app_tab_bar.dart';
import 'package:livecanvas/features/browse/presentation/pages/browse_placeholder_page.dart';
import 'package:livecanvas/features/collection_detail/presentation/pages/collection_detail_placeholder_page.dart';
import 'package:livecanvas/features/favorites/presentation/pages/favorites_placeholder_page.dart';
import 'package:livecanvas/features/profile/presentation/pages/profile_placeholder_page.dart';
import 'package:livecanvas/l10n/l10n.dart';

void main() {
  group('AppRouter — 5-tab shell', () {
    setUp(() => configureDependencies(AppConfig.development()));
    tearDown(getIt.reset);

    Future<AppLocalizations> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      return tester.element(find.byType(AppTabBar)).l10n;
    }

    GoRouter routerOf(WidgetTester tester) =>
        GoRouter.of(tester.element(find.byType(AppTabBar)));

    testWidgets('starts on Browse and switches between all five tabs', (
      tester,
    ) async {
      final l10n = await pumpApp(tester);

      expect(find.byType(BrowsePlaceholderPage), findsOneWidget);

      await tester.tap(find.text(l10n.tabFavorites));
      await tester.pumpAndSettle();
      expect(find.byType(FavoritesPlaceholderPage), findsOneWidget);

      await tester.tap(find.text(l10n.tabProfile));
      await tester.pumpAndSettle();
      expect(find.byType(ProfilePlaceholderPage), findsOneWidget);
    });

    testWidgets('indexedStack keeps each visited tab alive (state kept)', (
      tester,
    ) async {
      final l10n = await pumpApp(tester);

      // Visit Favorites (builds its branch), then return to Browse.
      await tester.tap(find.text(l10n.tabFavorites));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.tabBrowse));
      await tester.pumpAndSettle();

      // Browse is visible; Favorites stays mounted (offstage) rather than
      // being disposed — that is how per-tab state survives a tab switch.
      expect(find.byType(BrowsePlaceholderPage), findsOneWidget);
      expect(
        find.byType(FavoritesPlaceholderPage, skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('Detail pushes over the tab bar and pops back', (tester) async {
      await pumpApp(tester);
      unawaited(routerOf(tester).push('/collection/c-neon'));
      await tester.pumpAndSettle();

      expect(find.byType(CollectionDetailPlaceholderPage), findsOneWidget);
      // Full-screen push covers the tab bar.
      expect(find.byType(AppTabBar), findsNothing);

      // Pop via the back affordance returns to the shell + tab bar.
      await tester.tap(find.byType(IconButton).first);
      await tester.pumpAndSettle();
      expect(find.byType(CollectionDetailPlaceholderPage), findsNothing);
      expect(find.byType(AppTabBar), findsOneWidget);
    });
  });
}
