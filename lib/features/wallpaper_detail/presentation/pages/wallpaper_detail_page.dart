import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:livecanvas/core/di/injection.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_icons.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';
import 'package:livecanvas/core/widgets/controls/app_button.dart';
import 'package:livecanvas/core/widgets/controls/meta_chip.dart';
import 'package:livecanvas/core/widgets/feedback/failure_view.dart';
import 'package:livecanvas/core/widgets/feedback/skeleton/wallpaper_detail_skeleton.dart';
import 'package:livecanvas/core/widgets/feedback/toast.dart';
import 'package:livecanvas/core/widgets/wallpaper/premium_badge.dart';
import 'package:livecanvas/core/widgets/wallpaper/video_preview.dart';
import 'package:livecanvas/features/wallpaper_detail/presentation/cubit/wallpaper_detail_cubit.dart';
import 'package:livecanvas/features/wallpaper_detail/presentation/cubit/wallpaper_detail_state.dart';
import 'package:livecanvas/l10n/l10n.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// Full-screen Wallpaper Detail (US2): large looping preview, metadata, premium
/// state (display-only — Principle V), and links to any collections it belongs
/// to. Set/Download are visual anchors only in MO-003 (MO-005/MO-006).
class WallpaperDetailPage extends StatelessWidget {
  const WallpaperDetailPage({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    final wallpaperId = int.tryParse(id) ?? -1;
    return BlocProvider(
      create: (_) {
        final cubit = getIt<WallpaperDetailCubit>();
        unawaited(cubit.load(wallpaperId));
        return cubit;
      },
      child: _DetailView(wallpaperId: wallpaperId),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.wallpaperId});

  final int wallpaperId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: BlocBuilder<WallpaperDetailCubit, WallpaperDetailState>(
        builder: (context, state) {
          final body = switch (state) {
            WallpaperDetailInitial() ||
            WallpaperDetailLoading() => const WallpaperDetailSkeleton(),
            WallpaperDetailError(:final failure) => FailureView(
              failure: failure,
              onRetry: () =>
                  context.read<WallpaperDetailCubit>().load(wallpaperId),
            ),
            WallpaperDetailLoaded(:final wallpaper) => _Content(
              wallpaper: wallpaper,
            ),
          };
          return Stack(children: [body, const _BackButton()]);
        },
      ),
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
  const _Content({required this.wallpaper});

  final Wallpaper wallpaper;

  @override
  Widget build(BuildContext context) {
    final tags = wallpaper.tags ?? const [];
    final collections = wallpaper.collections ?? const [];
    final isPremium = wallpaper.isPremium ?? false;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        AspectRatio(
          aspectRatio: AppSpacing.wallRatio,
          child: VideoPreview(
            videoUrl: wallpaper.previewVideoUrl ?? '',
            posterUrl: wallpaper.thumbnailUrl ?? '',
            detectorKey: 'detail-${wallpaper.id}',
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(wallpaper.title ?? '', style: AppTypography.h1),
                  ),
                  if (isPremium) ...[
                    const SizedBox(width: AppSpacing.sp2),
                    const PremiumBadge(),
                  ],
                ],
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sp4),
                Wrap(
                  spacing: AppSpacing.sp2,
                  runSpacing: AppSpacing.sp2,
                  children: [
                    for (final tag in tags) MetaChip(text: tag.name ?? ''),
                  ],
                ),
              ],
              for (final ref in collections) _CollectionLink(ref: ref),
              const SizedBox(height: AppSpacing.sp6),
              _Actions(isPremium: isPremium),
            ],
          ),
        ),
      ],
    );
  }
}

class _CollectionLink extends StatelessWidget {
  const _CollectionLink({required this.ref});

  final CollectionRef ref;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sp4),
      child: InkWell(
        onTap: () => context.push('/collection/${ref.id}'),
        borderRadius: BorderRadius.circular(AppSpacing.rSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sp1),
          child: Row(
            children: [
              const Icon(
                AppIcons.collections,
                size: 18,
                color: AppColors.accent,
              ),
              const SizedBox(width: AppSpacing.sp2),
              Expanded(
                child: Text(
                  '${context.l10n.detailFromCollection} · ${ref.title ?? ''}',
                  style: AppTypography.small.copyWith(color: AppColors.accent),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                AppIcons.caretRight,
                size: 16,
                color: AppColors.accent,
              ),
            ],
          ),
        ),
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
    // MO-003: all actions are visual placeholders — native set / download and
    // real entitlement land in MO-005/MO-006 (Principle V).
    void placeholder() => showToast(context, l10n.placeholderComingSoon);

    if (isPremium) {
      return AppButton(
        label: l10n.detailUnlock,
        onPressed: placeholder,
        gradient: true,
      );
    }
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: l10n.detailSetWallpaper,
            onPressed: placeholder,
          ),
        ),
        const SizedBox(width: AppSpacing.sp3),
        Expanded(
          child: AppButton(
            label: l10n.detailDownload,
            onPressed: placeholder,
            variant: AppButtonVariant.ghost,
          ),
        ),
      ],
    );
  }
}
