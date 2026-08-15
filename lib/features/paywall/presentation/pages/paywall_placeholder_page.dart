import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_icons.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';
import 'package:livecanvas/core/widgets/feedback/empty_state.dart';
import 'package:livecanvas/l10n/l10n.dart';

/// Placeholder destination for a 402 block (MO-005, US4).
///
/// Deliberately minimal: MO-005 only needs somewhere to send the user when the
/// server refuses a premium download. The real paywall — pricing, purchase,
/// restore — is MO-006, and the backend's IAP spec (BE-005) lands first.
/// Mirrors the Download History header pattern, which has the same status.
class PaywallPlaceholderPage extends StatelessWidget {
  const PaywallPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp2),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      AppIcons.caretLeft,
                      color: AppColors.textHi,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: AppSpacing.sp1),
                  Text(l10n.paywallTitle, style: AppTypography.h2),
                ],
              ),
            ),
          ),
          Expanded(
            child: EmptyState(
              icon: AppIcons.diamond,
              title: l10n.paywallPlaceholderTitle,
              message: l10n.paywallPlaceholderMessage,
            ),
          ),
        ],
      ),
    );
  }
}
