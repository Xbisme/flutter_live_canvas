import 'dart:async';

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
import 'package:livecanvas/core/widgets/feedback/skeleton/collection_list_skeleton.dart';
import 'package:livecanvas/core/widgets/navigation/top_bar.dart';
import 'package:livecanvas/core/widgets/wallpaper/premium_badge.dart';
import 'package:livecanvas/features/collections/presentation/cubit/collections_cubit.dart';
import 'package:livecanvas/features/collections/presentation/cubit/collections_state.dart';
import 'package:livecanvas/l10n/l10n.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// Collections tab (US3): a scrollable list of curated cover cards.
class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<CollectionsCubit>();
        unawaited(cubit.load());
        return cubit;
      },
      child: const _CollectionsView(),
    );
  }
}

class _CollectionsView extends StatelessWidget {
  const _CollectionsView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: TopBar(title: l10n.tabCollections),
      body: BlocBuilder<CollectionsCubit, CollectionsState>(
        builder: (context, state) {
          return switch (state) {
            CollectionsInitial() ||
            CollectionsLoading() => const CollectionListSkeleton(),
            CollectionsEmpty() => EmptyState(
              icon: AppIcons.collections,
              title: l10n.collectionsEmptyTitle,
              message: l10n.collectionsEmptyMessage,
            ),
            CollectionsError(:final failure) => FailureView(
              failure: failure,
              onRetry: () => context.read<CollectionsCubit>().load(),
            ),
            CollectionsLoaded(:final items) => RefreshIndicator(
              onRefresh: context.read<CollectionsCubit>().refresh,
              color: AppColors.accent,
              backgroundColor: AppColors.bgSurface,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.gutter),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sp5),
                itemBuilder: (context, index) =>
                    _CoverCard(collection: items[index]),
              ),
            ),
          };
        },
      ),
    );
  }
}

class _CoverCard extends StatelessWidget {
  const _CoverCard({required this.collection});

  final Collection collection;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPremium = collection.isPremium ?? false;
    return InkWell(
      onTap: () => context.push('/collection/${collection.id}'),
      borderRadius: BorderRadius.circular(AppSpacing.rLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.rLg),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    collection.coverUrl ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const ColoredBox(color: AppColors.onyx),
                  ),
                  if (isPremium)
                    const Positioned(
                      top: AppSpacing.sp2,
                      right: AppSpacing.sp2,
                      child: PremiumBadge(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sp2),
          Text(
            collection.title ?? '',
            style: AppTypography.h3,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            l10n.collectionCount(collection.wallpaperCount ?? 0),
            style: AppTypography.small,
          ),
        ],
      ),
    );
  }
}
