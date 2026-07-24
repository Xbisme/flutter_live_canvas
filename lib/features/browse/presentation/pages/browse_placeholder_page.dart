import 'package:flutter/material.dart';
import 'package:livecanvas/core/widgets/feedback/placeholder_scaffold.dart';
import 'package:livecanvas/l10n/l10n.dart';

/// Browse tab body — placeholder for MO-002. The real wallpaper grid (cursor
/// pagination, category filter, search entry) lands in MO-003.
class BrowsePlaceholderPage extends StatelessWidget {
  const BrowsePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PlaceholderScaffold(
      wordmark: true,
      title: l10n.tabBrowse,
      message: l10n.placeholderTabBody(l10n.tabBrowse),
    );
  }
}
