import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livecanvas/core/theme/app_icons.dart';
import 'package:livecanvas/core/widgets/feedback/placeholder_scaffold.dart';
import 'package:livecanvas/l10n/l10n.dart';

/// Full-screen Collection Detail — placeholder route for MO-002. Pushes over
/// the tab shell and pops back to the source tab; real curated grid arrives in
/// MO-003.
class CollectionDetailPlaceholderPage extends StatelessWidget {
  const CollectionDetailPlaceholderPage({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PlaceholderScaffold(
          title: context.l10n.collectionDetailPlaceholder(id),
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
