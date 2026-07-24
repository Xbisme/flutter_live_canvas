import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:livecanvas/core/router/app_routes.dart';
import 'package:livecanvas/core/router/app_shell.dart';
import 'package:livecanvas/features/browse/presentation/pages/browse_page.dart';
import 'package:livecanvas/features/collection_detail/presentation/pages/collection_detail_page.dart';
import 'package:livecanvas/features/collections/presentation/pages/collections_page.dart';
import 'package:livecanvas/features/dev_gallery/presentation/pages/dev_gallery_page.dart';
import 'package:livecanvas/features/favorites/presentation/pages/favorites_placeholder_page.dart';
import 'package:livecanvas/features/profile/presentation/pages/profile_placeholder_page.dart';
import 'package:livecanvas/features/search/presentation/pages/search_page.dart';
import 'package:livecanvas/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart';

/// Composition root for navigation. Lives in the app layer (not `lib/core/`)
/// because it wires feature pages to routes — core must not import features
/// (Principle XI). Route path constants live in [AppRoutes] (core, pure).
///
/// A 5-tab `StatefulShellRoute.indexedStack` (each branch keeps its own state)
/// with full-screen Detail/Collection pushes that cover the tab bar, plus a
/// dev-only gallery route.
final _rootKey = GlobalKey<NavigatorState>();

GoRouter buildAppRouter() => GoRouter(
  navigatorKey: _rootKey,
  initialLocation: AppRoutes.browse,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.browse,
              builder: (context, state) => const BrowsePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.search,
              builder: (context, state) => const SearchPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.collections,
              builder: (context, state) => const CollectionsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.favorites,
              builder: (context, state) => const FavoritesPlaceholderPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfilePlaceholderPage(),
            ),
          ],
        ),
      ],
    ),
    // Full-screen pushes over the shell (cover the tab bar).
    GoRoute(
      path: AppRoutes.wallpaperDetail,
      parentNavigatorKey: _rootKey,
      builder: (context, state) =>
          WallpaperDetailPage(id: state.pathParameters['id'] ?? ''),
    ),
    GoRoute(
      path: AppRoutes.collectionDetail,
      parentNavigatorKey: _rootKey,
      builder: (context, state) =>
          CollectionDetailPage(id: state.pathParameters['id'] ?? ''),
    ),
    GoRoute(
      path: AppRoutes.devGallery,
      parentNavigatorKey: _rootKey,
      builder: (context, state) => const DevGalleryPage(),
    ),
  ],
);
