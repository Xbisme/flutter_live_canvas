import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:livecanvas/core/di/injection.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_icons.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/widgets/feedback/empty_state.dart';
import 'package:livecanvas/core/widgets/feedback/failure_view.dart';
import 'package:livecanvas/core/widgets/feedback/skeleton/wallpaper_grid_skeleton.dart';
import 'package:livecanvas/core/widgets/navigation/top_bar.dart';
import 'package:livecanvas/features/browse/presentation/cubit/browse_cubit.dart';
import 'package:livecanvas/features/browse/presentation/cubit/browse_state.dart';
import 'package:livecanvas/features/browse/presentation/widgets/tag_filter_bar.dart';
import 'package:livecanvas/features/browse/presentation/widgets/wallpaper_grid.dart';
import 'package:livecanvas/l10n/l10n.dart';

/// Browse tab (US1): the live wallpaper grid with tag filtering, cursor
/// pagination, pull-to-refresh, and state-driven skeleton shimmer.
class BrowsePage extends StatelessWidget {
  const BrowsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<BrowseCubit>();
        unawaited(cubit.load());
        return cubit;
      },
      child: const _BrowseView(),
    );
  }
}

class _BrowseView extends StatelessWidget {
  const _BrowseView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: const TopBar(wordmark: true),
      body: BlocBuilder<BrowseCubit, BrowseState>(
        builder: (context, state) {
          return switch (state) {
            BrowseInitial() || BrowseLoading() => const WallpaperGridSkeleton(),
            BrowseError(:final failure) => FailureView(
              failure: failure,
              onRetry: () => context.read<BrowseCubit>().load(),
            ),
            BrowseLoaded() => _LoadedView(state: state),
          };
        },
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.state});

  final BrowseLoaded state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BrowseCubit>();
    return Column(
      children: [
        const SizedBox(height: AppSpacing.sp3),
        TagFilterBar(
          tags: state.tags,
          selectedId: state.selectedTagId,
          onSelected: cubit.selectTag,
        ),
        const SizedBox(height: AppSpacing.sp3),
        Expanded(
          child: _GridArea(state: state, cubit: cubit),
        ),
      ],
    );
  }
}

class _GridArea extends StatelessWidget {
  const _GridArea({required this.state, required this.cubit});

  final BrowseLoaded state;
  final BrowseCubit cubit;

  @override
  Widget build(BuildContext context) {
    if (state.isReloading) return const WallpaperGridSkeleton();
    if (state.items.isEmpty) {
      final l10n = context.l10n;
      return EmptyState(
        icon: AppIcons.imageSquare,
        title: l10n.browseEmptyTitle,
        message: l10n.browseEmptyMessage,
      );
    }
    return RefreshIndicator(
      onRefresh: cubit.refresh,
      color: AppColors.accent,
      backgroundColor: AppColors.bgSurface,
      child: WallpaperGrid(
        items: state.items,
        hasMore: state.hasMore,
        isLoadingMore: state.isLoadingMore,
        loadMoreFailed: state.loadMoreFailed,
        onLoadMore: cubit.loadMore,
        onTap: (wallpaper) => context.push('/wallpaper/${wallpaper.id}'),
      ),
    );
  }
}
