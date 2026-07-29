import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:livecanvas/core/di/injection.dart';
import 'package:livecanvas/core/responsive/breakpoints.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_icons.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';
import 'package:livecanvas/core/widgets/feedback/empty_state.dart';
import 'package:livecanvas/core/widgets/feedback/failure_view.dart';
import 'package:livecanvas/core/widgets/feedback/skeleton/wallpaper_grid_skeleton.dart';
import 'package:livecanvas/core/widgets/wallpaper/favoritable_wallpaper_tile.dart';
import 'package:livecanvas/features/download_history/presentation/cubit/download_history_cubit.dart';
import 'package:livecanvas/features/download_history/presentation/cubit/download_history_state.dart';
import 'package:livecanvas/l10n/l10n.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// Download History (MO-004, US4): a minimal list of wallpapers the user has
/// downloaded, newest-first. Re-fetches fresh data by ID (Principle IX). No
/// design handoff exists for this screen yet — it reuses the shared grid/empty/
/// failure widgets (plan §Complexity); MO-005 wires the recording point.
class DownloadHistoryPage extends StatelessWidget {
  const DownloadHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<DownloadHistoryCubit>();
        unawaited(cubit.load());
        return cubit;
      },
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: Column(
        children: [
          _Header(title: context.l10n.downloadHistoryTitle),
          Expanded(
            child: BlocBuilder<DownloadHistoryCubit, DownloadHistoryState>(
              builder: (context, state) {
                return switch (state) {
                  DownloadHistoryInitial() ||
                  DownloadHistoryLoading() => const WallpaperGridSkeleton(),
                  DownloadHistoryError(:final failure) => FailureView(
                    failure: failure,
                    onRetry: () => context.read<DownloadHistoryCubit>().load(),
                  ),
                  DownloadHistoryLoaded(:final items) =>
                    items.isEmpty ? const _Empty() : _Grid(items: items),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp2),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(AppIcons.caretLeft, color: AppColors.textHi),
              onPressed: () => context.pop(),
            ),
            const SizedBox(width: AppSpacing.sp1),
            Text(title, style: AppTypography.h2),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return EmptyState(
      icon: AppIcons.download,
      title: l10n.downloadHistoryEmptyTitle,
      message: l10n.downloadHistoryEmptyMessage,
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.items});

  final List<Wallpaper> items;

  @override
  Widget build(BuildContext context) {
    final columns = Breakpoints.gridColumns(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnWidth =
            (constraints.maxWidth -
                AppSpacing.gutter * 2 -
                AppSpacing.gridGap * (columns - 1)) /
            columns;
        final cellHeight = columnWidth / AppSpacing.wallRatio;
        return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppSpacing.gridGap,
            mainAxisSpacing: AppSpacing.gridGap,
            childAspectRatio: columnWidth / cellHeight,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final wallpaper = items[index];
            return RepaintBoundary(
              child: FavoritableWallpaperTile(
                wallpaper: wallpaper,
                onTap: () => context.push('/wallpaper/${wallpaper.id}'),
              ),
            );
          },
        );
      },
    );
  }
}
