import 'package:flutter/material.dart';
import 'package:livecanvas/core/config/app_config.dart';
import 'package:livecanvas/core/di/injection.dart';
import 'package:livecanvas/l10n/l10n.dart';

/// Bootstrap placeholder — proves the flavor wiring works by showing which
/// environment the app was launched with. Replaced by the real shell in
/// MO-002.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final config = getIt<AppConfig>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // NOTE(MO-002): design icons must be Phosphor (Principle VI) —
            // phosphor_flutter 2.1.0 is currently incompatible with Flutter
            // 3.44 (IconData is final); resolve before building real UI.
            Text(l10n.environmentLabel(config.environment.name)),
          ],
        ),
      ),
    );
  }
}
