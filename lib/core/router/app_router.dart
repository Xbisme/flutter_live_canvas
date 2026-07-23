import 'package:go_router/go_router.dart';
import 'package:livecanvas/app/view/home_page.dart';

/// Central route path constants (Principle X) — never hardcode paths at
/// call sites.
abstract final class AppRoutes {
  static const home = '/';
}

/// Minimal bootstrap router: one placeholder route. The 5-tab
/// `StatefulShellRoute.indexedStack` shell arrives with MO-002.
GoRouter buildAppRouter() => GoRouter(
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
  ],
);
