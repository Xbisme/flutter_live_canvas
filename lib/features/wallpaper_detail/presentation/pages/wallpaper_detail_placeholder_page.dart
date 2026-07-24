import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livecanvas/core/theme/app_icons.dart';
import 'package:livecanvas/core/widgets/feedback/placeholder_scaffold.dart';
import 'package:livecanvas/l10n/l10n.dart';

/// Full-screen Wallpaper Detail — placeholder route for MO-002. It pushes over
/// the tab shell and pops back to the source tab; real detail + video preview
/// arrives in MO-003. A back affordance is provided so the push/pop lifecycle
/// is exercisable now.
class WallpaperDetailPlaceholderPage extends StatelessWidget {
  const WallpaperDetailPlaceholderPage({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PlaceholderScaffold(
          title: context.l10n.wallpaperDetailPlaceholder(id),
          message: context.l10n.placeholderComingSoon,
        ),
        SafeArea(
          child: IconButton(
            icon: const Icon(AppIcons.caretLeft),
            onPressed: () => context.pop(),
          ),
        ),
      ],
    );
  }
}
