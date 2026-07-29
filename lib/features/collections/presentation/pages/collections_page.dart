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
      appBar: TopBar(title: l10n.tabCollections, trailing: const _Count()),
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
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  AppSpacing.sp1 + 2,
                  AppSpacing.gutter,
                  AppSpacing.gutter,
                ),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sp4),
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

/// Full-bleed cover card (handoff `CollectionsBrowse`): a 168px cover with the
/// title/author/count overlaid over a bottom scrim and a per-collection aura
/// drop-shadow.
class _CoverCard extends StatelessWidget {
  const _CoverCard({required this.collection});

  final Collection collection;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPremium = collection.isPremium ?? false;
    final aura = _parseHex(collection.accentColor) ?? AppColors.accent;
    final author = collection.author;

    return GestureDetector(
      onTap: () => context.push('/collection/${collection.id}'),
      child: Container(
        height: 168,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.rLg),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: aura.withValues(alpha: 0.35),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.rLg),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                collection.coverUrl ?? '',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const ColoredBox(color: AppColors.onyx),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xD909070E), Color(0x1A09070E)],
                    stops: [0, 0.55],
                  ),
                ),
              ),
              if (isPremium)
                const Positioned(
                  top: AppSpacing.sp3,
                  right: AppSpacing.sp3,
                  child: PremiumBadge(),
                ),
              Positioned(
                left: AppSpacing.sp4,
                right: AppSpacing.sp4,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      collection.title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.h1.copyWith(
                        fontSize: 24,
                        fontWeight: AppTypography.medium,
                        letterSpacing: -0.48,
                        color: AppColors.onAccent,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp1),
                    Row(
                      children: [
                        if (author != null && author.isNotEmpty) ...[
                          Text(
                            '@$author',
                            style: AppTypography.small.copyWith(
                              color: const Color(0xCCF6F3FB),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sp2),
                          const Text(
                            '·',
                            style: TextStyle(color: Color(0x80F6F3FB)),
                          ),
                          const SizedBox(width: AppSpacing.sp2),
                        ],
                        Text(
                          l10n.collectionCount(collection.wallpaperCount ?? 0),
                          style: AppTypography.monoMeta.copyWith(
                            fontSize: 12,
                            color: const Color(0xB3F6F3FB),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Collection count shown in the TopBar trailing slot (mono, tertiary).
class _Count extends StatelessWidget {
  const _Count();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollectionsCubit, CollectionsState>(
      builder: (context, state) {
        final count = state is CollectionsLoaded ? state.items.length : 0;
        if (count == 0) return const SizedBox.shrink();
        return Text(
          '$count',
          style: AppTypography.monoMeta.copyWith(fontSize: 12),
        );
      },
    );
  }
}

Color? _parseHex(String? hex) {
  if (hex == null) return null;
  final cleaned = hex.replaceFirst('#', '');
  final value = int.tryParse('FF$cleaned', radix: 16);
  return value == null ? null : Color(value);
}
