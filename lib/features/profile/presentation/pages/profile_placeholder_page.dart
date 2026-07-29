import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livecanvas/core/router/app_routes.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_icons.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';
import 'package:livecanvas/core/widgets/navigation/top_bar.dart';
import 'package:livecanvas/l10n/l10n.dart';

/// Profile tab ("Bạn"). Most of its content (premium status, restore purchase,
/// settings) lands in MO-006; MO-004 adds the entry point to local Download
/// History (US4).
class ProfilePlaceholderPage extends StatelessWidget {
  const ProfilePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: Column(
        children: [
          TopBar(title: l10n.tabProfile),
          ListTile(
            leading: const Icon(
              AppIcons.download,
              color: AppColors.textPrimary,
            ),
            title: Text(
              l10n.profileDownloadHistory,
              style: AppTypography.bodyText,
            ),
            trailing: const Icon(
              AppIcons.caretRight,
              size: 16,
              color: AppColors.textTertiary,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.gutter,
            ),
            onTap: () => context.push(AppRoutes.downloadHistory),
          ),
        ],
      ),
    );
  }
}
