import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_elevation.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';

/// Bottom sheet surface faithful to the prototype: rounded top (`rXl`),
/// raised surface, a grab handle, safe-area aware.
class AppSheet extends StatelessWidget {
  const AppSheet({required this.child, this.padding, super.key});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.rXl),
        ),
        boxShadow: AppElevation.shadowSheet,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding:
              padding ??
              const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.sp3,
                AppSpacing.gutter,
                AppSpacing.sp6,
              ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSpacing.sp10,
                height: AppSpacing.sp1,
                margin: const EdgeInsets.only(bottom: AppSpacing.sp4),
                decoration: BoxDecoration(
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(AppSpacing.rPill),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows an [AppSheet]. Route rule (FR-010 / Principle X): to swap one sheet for
/// another, the caller must `Navigator`-pop the current one first and call this
/// inside `WidgetsBinding.addPostFrameCallback` — never push two sheets in the
/// same frame. Use [replaceSheet] for that flow.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => AppSheet(child: builder(context)),
  );
}

/// Dismiss the current sheet, then open [builder]'s sheet on the next frame —
/// the safe way to chain sheets (FR-010: never two in one frame). Pass the
/// screen [context] (stable across the swap); `context.pop()` (go_router)
/// dismisses the top-most sheet — no direct `Navigator.of` (Principle X).
void replaceSheet(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  context.pop();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) {
      unawaited(showAppSheet<void>(context, builder: builder));
    }
  });
}
