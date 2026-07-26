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
import 'package:livecanvas/core/widgets/controls/app_button.dart';
import 'package:livecanvas/core/widgets/feedback/failure_view.dart';
import 'package:livecanvas/core/widgets/feedback/skeleton/shimmer_box.dart';
import 'package:livecanvas/core/widgets/feedback/skeleton/wallpaper_grid_skeleton.dart';
import 'package:livecanvas/core/widgets/feedback/toast.dart';
import 'package:livecanvas/core/widgets/wallpaper/premium_badge.dart';
import 'package:livecanvas/core/widgets/wallpaper/wallpaper_tile.dart';
import 'package:livecanvas/features/collection_detail/presentation/cubit/collection_detail_cubit.dart';
import 'package:livecanvas/features/collection_detail/presentation/cubit/collection_detail_state.dart';
import 'package:livecanvas/l10n/l10n.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// Full-screen Collection Detail (US3): hero cover + description, a grid of the
/// collection's ordered wallpapers, and premium unlock/download-all actions
/// (display-only in MO-003 — Principle V).
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
          return Stack(children: [body, const _BackButton()]);
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
        ShimmerBox(aspectRatio: 16 / 9, radius: 0),
        SizedBox(height: AppSpacing.sp4),
        WallpaperGridSkeleton(),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sp2),
        child: Align(
          alignment: Alignment.topLeft,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.scrim,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(AppIcons.caretLeft, color: AppColors.textHi),
              onPressed: () => context.pop(),
            ),
          ),
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
        final cellHeight = columnWidth / AppSpacing.wallRatio + 52.0;
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header(collection: collection)),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.gutter),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: AppSpacing.gridGap,
                  mainAxisSpacing: AppSpacing.gridGap,
                  childAspectRatio: columnWidth / cellHeight,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final wallpaper = items[index];
                  return WallpaperTile(
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

class _Header extends StatelessWidget {
  const _Header({required this.collection});

  final CollectionDetail collection;

  @override
  Widget build(BuildContext context) {
    final isPremium = collection.isPremium ?? false;
    final accent = _parseHex(collection.accentColor) ?? AppColors.accent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: accent.withValues(alpha: 0.4), blurRadius: 48),
              ],
            ),
            child: Image.network(
              collection.coverUrl ?? '',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: AppColors.onyx),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(collection.title ?? '', style: AppTypography.h1),
              if ((collection.description ?? '').isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sp2),
                Text(collection.description!, style: AppTypography.bodyText),
              ],
              if (isPremium) ...[
                const SizedBox(height: AppSpacing.sp5),
                _PremiumActions(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Color? _parseHex(String? hex) {
    if (hex == null) return null;
    final cleaned = hex.replaceFirst('#', '');
    final value = int.tryParse('FF$cleaned', radix: 16);
    return value == null ? null : Color(value);
  }
}

class _PremiumActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    void placeholder() => showToast(context, l10n.placeholderComingSoon);
    return Row(
      children: [
        const PremiumBadge(),
        const SizedBox(width: AppSpacing.sp3),
        Expanded(
          child: AppButton(
            label: l10n.detailUnlock,
            onPressed: placeholder,
            gradient: true,
          ),
        ),
        const SizedBox(width: AppSpacing.sp3),
        Expanded(
          child: AppButton(
            label: l10n.collectionDownloadAll,
            onPressed: placeholder,
            variant: AppButtonVariant.ghost,
          ),
        ),
      ],
    );
  }
}
