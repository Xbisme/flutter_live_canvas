import 'package:flutter/material.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/error/failure_l10n.dart';
import 'package:livecanvas/core/theme/app_icons.dart';
import 'package:livecanvas/core/widgets/controls/app_button.dart';
import 'package:livecanvas/core/widgets/feedback/empty_state.dart';
import 'package:livecanvas/l10n/l10n.dart';

/// Friendly, retryable error state driven by an [AppFailure] (FR-007 / SC-007).
/// The only place a failure becomes a full-screen message — never raw text.
class FailureView extends StatelessWidget {
  const FailureView({required this.failure, required this.onRetry, super.key});

  final AppFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isNotFound = failure is NotFoundFailure;
    return EmptyState(
      icon: isNotFound ? AppIcons.imageSquare : AppIcons.warning,
      title: isNotFound ? l10n.failureNotFound : l10n.errorTitle,
      message: failure.localizedMessage(context),
      action: SizedBox(
        width: 160,
        child: AppButton(
          label: l10n.retry,
          onPressed: onRetry,
          variant: AppButtonVariant.ghost,
        ),
      ),
    );
  }
}
