import 'package:flutter/material.dart';
import 'package:livecanvas/core/widgets/feedback/placeholder_scaffold.dart';
import 'package:livecanvas/l10n/l10n.dart';

/// Collections tab body — placeholder for MO-002. Real curated collections
/// list + Collection Detail: MO-003.
class CollectionsPlaceholderPage extends StatelessWidget {
  const CollectionsPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PlaceholderScaffold(
      title: l10n.tabCollections,
      message: l10n.placeholderTabBody(l10n.tabCollections),
    );
  }
}
