import 'package:flutter/material.dart';
import 'package:livecanvas/app/router/app_router.dart';
import 'package:livecanvas/core/theme/app_theme.dart';
import 'package:livecanvas/l10n/l10n.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.dark,
      // Dark-only: the handoff defines no light palette (research R4).
      themeMode: ThemeMode.dark,
      routerConfig: buildAppRouter(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
