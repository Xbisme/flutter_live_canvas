import 'package:flutter/material.dart';
import 'package:livecanvas/core/widgets/navigation/top_bar.dart';
import 'package:livecanvas/l10n/l10n.dart';

/// Profile tab ("Bạn") — an empty shell for MO-002. Its real content
/// (premium status, restore purchase, settings) is built in MO-006 alongside
/// IAP, so only the titled chrome exists here.
class ProfilePlaceholderPage extends StatelessWidget {
  const ProfilePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [TopBar(title: context.l10n.tabProfile)],
      ),
    );
  }
}
