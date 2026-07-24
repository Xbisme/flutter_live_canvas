import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:livecanvas/core/di/injection.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_icons.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';
import 'package:livecanvas/core/widgets/feedback/empty_state.dart';
import 'package:livecanvas/core/widgets/feedback/failure_view.dart';
import 'package:livecanvas/core/widgets/feedback/skeleton/wallpaper_grid_skeleton.dart';
import 'package:livecanvas/features/browse/presentation/widgets/wallpaper_grid.dart';
import 'package:livecanvas/features/search/presentation/cubit/search_cubit.dart';
import 'package:livecanvas/features/search/presentation/cubit/search_state.dart';
import 'package:livecanvas/l10n/l10n.dart';

/// Search tab (US4): a debounced live search reusing the Browse grid.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SearchCubit>(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<SearchCubit>();
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.gutter),
              child: TextField(
                controller: _controller,
                onChanged: cubit.queryChanged,
                autofocus: true,
                style: AppTypography.bodyText,
                cursorColor: AppColors.accent,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  hintStyle: AppTypography.bodyText.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  prefixIcon: const Icon(
                    AppIcons.search,
                    color: AppColors.textTertiary,
                  ),
                  filled: true,
                  fillColor: AppColors.bgRaised,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.rPill),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(child: _Results(controller: _controller)),
          ],
        ),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<SearchCubit>();
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        return switch (state) {
          SearchInitial() => EmptyState(
            icon: AppIcons.search,
            title: l10n.tabSearch,
            message: l10n.searchPrompt,
          ),
          SearchLoading() => const WallpaperGridSkeleton(),
          SearchEmpty() => EmptyState(
            icon: AppIcons.search,
            title: l10n.searchEmptyTitle,
            message: l10n.searchEmptyMessage,
          ),
          SearchError(:final failure) => FailureView(
            failure: failure,
            onRetry: () => cubit.queryChanged(controller.text),
          ),
          SearchLoaded() => WallpaperGrid(
            items: state.items,
            hasMore: state.hasMore,
            isLoadingMore: state.isLoadingMore,
            loadMoreFailed: state.loadMoreFailed,
            onLoadMore: cubit.loadMore,
            onTap: (wallpaper) => context.push('/wallpaper/${wallpaper.id}'),
          ),
        };
      },
    );
  }
}
