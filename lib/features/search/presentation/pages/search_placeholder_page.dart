import 'package:flutter/material.dart';
import 'package:livecanvas/core/widgets/feedback/placeholder_scaffold.dart';
import 'package:livecanvas/l10n/l10n.dart';

/// Search tab body — placeholder for MO-002. Real search + tag chips: MO-003.
class SearchPlaceholderPage extends StatelessWidget {
  const SearchPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PlaceholderScaffold(
      title: l10n.tabSearch,
      message: l10n.placeholderTabBody(l10n.tabSearch),
    );
  }
}
