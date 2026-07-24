import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livecanvas/core/theme/app_icons.dart';
import 'package:livecanvas/core/widgets/navigation/app_tab_bar.dart';
import 'package:livecanvas/l10n/l10n.dart';

/// The 5-tab shell scaffold — hosts the branch navigators (whose per-tab state
/// is preserved by `StatefulShellRoute.indexedStack`) and the [AppTabBar].
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      AppTabItem(
        icon: AppIcons.browse,
        activeIcon: AppIcons.browseActive,
        label: l10n.tabBrowse,
      ),
      AppTabItem(
        icon: AppIcons.search,
        activeIcon: AppIcons.searchActive,
        label: l10n.tabSearch,
      ),
      AppTabItem(
        icon: AppIcons.collections,
        activeIcon: AppIcons.collectionsActive,
        label: l10n.tabCollections,
      ),
      AppTabItem(
        icon: AppIcons.favorites,
        activeIcon: AppIcons.favoritesActive,
        label: l10n.tabFavorites,
      ),
      AppTabItem(
        icon: AppIcons.profile,
        activeIcon: AppIcons.profileActive,
        label: l10n.tabProfile,
      ),
    ];

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppTabBar(
        items: items,
        currentIndex: navigationShell.currentIndex,
        // goBranch keeps each tab's navigation stack; initialLocation:true on
        // re-tapping the active tab returns it to its root.
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
