import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:livecanvas/core/di/injection.dart';
import 'package:livecanvas/core/router/app_routes.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_icons.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';
import 'package:livecanvas/core/widgets/feedback/empty_state.dart';
import 'package:livecanvas/core/widgets/feedback/failure_view.dart';
import 'package:livecanvas/core/widgets/feedback/skeleton/wallpaper_grid_skeleton.dart';
import 'package:livecanvas/core/widgets/navigation/top_bar.dart';
import 'package:livecanvas/core/widgets/wallpaper/favoritable_wallpaper_tile.dart';
import 'package:livecanvas/features/browse/presentation/cubit/browse_cubit.dart';
import 'package:livecanvas/features/browse/presentation/cubit/browse_state.dart';
import 'package:livecanvas/features/browse/presentation/widgets/tag_filter_bar.dart';
import 'package:livecanvas/features/browse/presentation/widgets/wallpaper_grid.dart';
import 'package:livecanvas/l10n/l10n.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

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
      appBar: TopBar(
        wordmark: true,
        trailing: IconButton(
          icon: const Icon(AppIcons.search, color: AppColors.textPrimary),
          onPressed: () => context.go(AppRoutes.search),
        ),
      ),
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

    // "Tất cả" → curated sections; a specific tag → the flat grid.
    if (state.isSectionsView) {
      if (state.sections.isEmpty) return const _Empty();
      return RefreshIndicator(
        onRefresh: cubit.refresh,
        color: AppColors.accent,
        backgroundColor: AppColors.bgSurface,
        child: _SectionsList(sections: state.sections),
      );
    }

    if (state.items.isEmpty) return const _Empty();
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

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return EmptyState(
      icon: AppIcons.imageSquare,
      title: l10n.browseEmptyTitle,
      message: l10n.browseEmptyMessage,
    );
  }
}

/// The curated Browse: a scroll of titled sections (handoff `SectionGrid`).
class _SectionsList extends StatelessWidget {
  const _SectionsList({required this.sections});

  final List<HomeSection> sections;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppSpacing.sp6),
      itemCount: sections.length,
      itemBuilder: (context, index) => _SectionGrid(section: sections[index]),
    );
  }
}

class _SectionGrid extends StatelessWidget {
  const _SectionGrid({required this.section});

  final HomeSection section;

  @override
  Widget build(BuildContext context) {
    final items = section.items;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        0,
        AppSpacing.gutter,
        AppSpacing.sp6 + 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      context.push('/collection/${section.collectionId}'),
                  child: Text(
                    section.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.h1.copyWith(
                      fontSize: 22,
                      fontWeight: AppTypography.medium,
                      letterSpacing: -0.44,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sp2),
              Text(
                '${items.length}',
                style: AppTypography.monoMeta.copyWith(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp3),
          _SectionItems(items: items),
        ],
      ),
    );
  }
}

class _SectionItems extends StatelessWidget {
  const _SectionItems({required this.items});

  final List<Wallpaper> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 2;
        final columnWidth =
            (constraints.maxWidth - AppSpacing.gridGap * (columns - 1)) /
            columns;
        final cellHeight = columnWidth / AppSpacing.wallRatio;
        return GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
