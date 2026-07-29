import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:livecanvas/core/di/injection.dart';
import 'package:livecanvas/core/responsive/breakpoints.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_icons.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';
import 'package:livecanvas/core/widgets/controls/app_button.dart';
import 'package:livecanvas/core/widgets/controls/glass_icon_button.dart';
import 'package:livecanvas/core/widgets/feedback/failure_view.dart';
import 'package:livecanvas/core/widgets/feedback/skeleton/shimmer_box.dart';
import 'package:livecanvas/core/widgets/feedback/skeleton/wallpaper_grid_skeleton.dart';
import 'package:livecanvas/core/widgets/feedback/toast.dart';
import 'package:livecanvas/core/widgets/wallpaper/favoritable_wallpaper_tile.dart';
import 'package:livecanvas/core/widgets/wallpaper/premium_badge.dart';
import 'package:livecanvas/features/collection_detail/presentation/cubit/collection_detail_cubit.dart';
import 'package:livecanvas/features/collection_detail/presentation/cubit/collection_detail_state.dart';
import 'package:livecanvas/l10n/l10n.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// Full-screen Collection Detail (US3 + design pass): a 300px cover hero that
/// adopts the collection hue (blurred accent blob + fade to bg), the curated
/// grid, and premium unlock / download-all actions (display-only — Principle V).
class CollectionDetailPage extends StatelessWidget {
  const CollectionDetailPage({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    final collectionId = int.tryParse(id) ?? -1;
    return BlocProvider(
      create: (_) {
        final cubit = getIt<CollectionDetailCubit>();
        unawaited(cubit.load(collectionId));
        return cubit;
      },
      child: _DetailView(collectionId: collectionId),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.collectionId});

  final int collectionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: BlocBuilder<CollectionDetailCubit, CollectionDetailState>(
        builder: (context, state) {
          final body = switch (state) {
            CollectionDetailInitial() ||
            CollectionDetailLoading() => const _LoadingView(),
            CollectionDetailErrorState(:final failure) => FailureView(
              failure: failure,
              onRetry: () =>
                  context.read<CollectionDetailCubit>().load(collectionId),
            ),
            CollectionDetailLoaded(:final collection) => _Content(
              collection: collection,
            ),
          };
          return Stack(children: [body, const _Chrome()]);
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: const [
        ShimmerBox(aspectRatio: 390 / 300, radius: 0),
        SizedBox(height: AppSpacing.sp4),
        WallpaperGridSkeleton(),
      ],
    );
  }
}

/// Floating glass chrome: back (left) + share (right).
class _Chrome extends StatelessWidget {
  const _Chrome();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sp4,
          14,
          AppSpacing.sp4,
          0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GlassIconButton(
              icon: AppIcons.arrowLeft,
              onTap: () => context.pop(),
            ),
            GlassIconButton(
              icon: AppIcons.share,
              onTap: () => showToast(context, l10n.placeholderComingSoon),
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.collection});

  final CollectionDetail collection;

  @override
  Widget build(BuildContext context) {
    final items = collection.items ?? const [];
    final columns = Breakpoints.gridColumns(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnWidth =
            (constraints.maxWidth -
                AppSpacing.gutter * 2 -
                AppSpacing.gridGap * (columns - 1)) /
            columns;
        final cellHeight = columnWidth / AppSpacing.wallRatio;
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Hero(collection: collection)),
            SliverToBoxAdapter(child: _Meta(collection: collection)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.sp5,
                AppSpacing.gutter,
                AppSpacing.sp8,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: AppSpacing.gridGap,
                  mainAxisSpacing: AppSpacing.gridGap,
                  childAspectRatio: columnWidth / cellHeight,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final wallpaper = items[index];
                  return FavoritableWallpaperTile(
                    wallpaper: wallpaper,
                    onTap: () => context.push('/wallpaper/${wallpaper.id}'),
                  );
                }, childCount: items.length),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.collection});

  final CollectionDetail collection;

  @override
  Widget build(BuildContext context) {
    final accent = _parseHex(collection.accentColor) ?? AppColors.accent;
    final isPremium = collection.isPremium ?? false;
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            collection.coverUrl ?? '',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.onyx),
          ),
          // Blurred accent blob — the collection hue bleeding through.
          Positioned(
            left: 40,
            top: 54,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                width: 220,
                height: 135,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
          // Fade the hero into the page.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.void_,
                  Color(0x3309070E),
                  Color(0x5909070E),
                ],
                stops: [0.02, 0.55, 1],
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.sp5,
            right: AppSpacing.sp5,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (isPremium) ...[
                      const PremiumBadge(),
                      const SizedBox(width: AppSpacing.sp2),
                    ],
                    Text(
                      context.l10n.collectionEyebrow,
                      style: AppTypography.eyebrow.copyWith(
                        color: const Color(0xB3F6F3FB),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  collection.title ?? '',
                  style: AppTypography.h1.copyWith(
                    fontSize: 34,
                    height: 1.02,
                    fontWeight: AppTypography.medium,
                    letterSpacing: -0.68,
                    color: AppColors.onAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.collection});

  final CollectionDetail collection;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final author = collection.author;
    final count = collection.wallpaperCount ?? (collection.items?.length ?? 0);
    final description = collection.description ?? '';
    final isPremium = collection.isPremium ?? false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.sp5, 18, AppSpacing.sp5, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.aurora,
                ),
                child: const Icon(
                  AppIcons.profile,
                  size: 16,
                  color: AppColors.onAccent,
                ),
              ),
              const SizedBox(width: AppSpacing.sp3 - 2),
              if (author != null && author.isNotEmpty) ...[
                Text(
                  '@$author',
                  style: AppTypography.small.copyWith(
                    fontSize: 14,
                    fontWeight: AppTypography.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sp2),
                const Text(
                  '·',
                  style: TextStyle(color: AppColors.textTertiary),
                ),
                const SizedBox(width: AppSpacing.sp2),
              ],
              Text(
                l10n.collectionCount(count),
                style: AppTypography.monoMeta.copyWith(fontSize: 12),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              description,
              style: AppTypography.bodyText.copyWith(
                fontSize: 14,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 18),
          _Actions(isPremium: isPremium),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.isPremium});

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    void soon() => showToast(context, l10n.placeholderComingSoon);

    if (isPremium) {
      return AppButton(
        label: l10n.collectionUnlock,
        onPressed: soon,
        gradient: true,
        icon: AppIcons.sparkle,
      );
    }
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: l10n.actionShare,
            onPressed: soon,
            variant: AppButtonVariant.ghost,
            icon: AppIcons.share,
          ),
        ),
        const SizedBox(width: AppSpacing.sp3),
        Expanded(
          child: AppButton(
            label: l10n.collectionDownloadAll,
            onPressed: soon,
            icon: AppIcons.download,
          ),
        ),
      ],
    );
  }
}

Color? _parseHex(String? hex) {
  if (hex == null) return null;
  final cleaned = hex.replaceFirst('#', '');
  final value = int.tryParse('FF$cleaned', radix: 16);
  return value == null ? null : Color(value);
}
