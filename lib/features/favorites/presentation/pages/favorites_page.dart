import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:livecanvas/core/di/injection.dart';
import 'package:livecanvas/core/responsive/breakpoints.dart';
import 'package:livecanvas/core/router/app_routes.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_icons.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';
import 'package:livecanvas/core/widgets/controls/app_button.dart';
import 'package:livecanvas/core/widgets/feedback/empty_state.dart';
import 'package:livecanvas/core/widgets/feedback/failure_view.dart';
import 'package:livecanvas/core/widgets/feedback/skeleton/wallpaper_grid_skeleton.dart';
import 'package:livecanvas/core/widgets/navigation/top_bar.dart';
import 'package:livecanvas/core/widgets/wallpaper/favoritable_wallpaper_tile.dart';
import 'package:livecanvas/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:livecanvas/features/favorites/presentation/cubit/favorites_state.dart';
import 'package:livecanvas/l10n/l10n.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// Favorites tab (MO-004): a grid of the user's saved wallpapers, re-fetched
/// fresh on each open via batch (Principle IX) and reconciled for removed IDs.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<FavoritesCubit>();
        unawaited(cubit.load());
        return cubit;
      },
      child: const _FavoritesView(),
    );
  }
}

class _FavoritesView extends StatelessWidget {
  const _FavoritesView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: Column(
        children: [
          BlocBuilder<FavoritesCubit, FavoritesState>(
            buildWhen: (a, b) =>
                a.runtimeType != b.runtimeType || b is FavoritesLoaded,
            builder: (context, state) {
              final count = state is FavoritesLoaded ? state.items.length : 0;
              return TopBar(
                title: l10n.tabFavorites,
                trailing: count == 0
                    ? null
                    : Text('$count', style: AppTypography.monoMeta),
              );
            },
          ),
          Expanded(
            child: BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, state) {
                return switch (state) {
                  FavoritesInitial() ||
                  FavoritesLoading() => const WallpaperGridSkeleton(),
                  FavoritesError(:final failure) => FailureView(
                    failure: failure,
                    onRetry: () => context.read<FavoritesCubit>().load(),
                  ),
                  FavoritesLoaded(:final items) =>
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

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return EmptyState(
      icon: AppIcons.heart,
      title: l10n.favoritesEmptyTitle,
      message: l10n.favoritesEmptyMessage,
      action: AppButton(
        label: l10n.favoritesEmptyAction,
        onPressed: () => context.go(AppRoutes.browse),
      ),
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
