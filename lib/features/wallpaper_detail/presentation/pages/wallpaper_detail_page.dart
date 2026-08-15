import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:livecanvas/core/di/injection.dart';
import 'package:livecanvas/core/favorites/favorites_repository.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_icons.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';
import 'package:livecanvas/core/widgets/controls/app_button.dart';
import 'package:livecanvas/core/widgets/controls/glass_icon_button.dart';
import 'package:livecanvas/core/widgets/controls/meta_chip.dart';
import 'package:livecanvas/core/widgets/feedback/failure_view.dart';
import 'package:livecanvas/core/widgets/feedback/skeleton/wallpaper_detail_skeleton.dart';
import 'package:livecanvas/core/widgets/feedback/toast.dart';
import 'package:livecanvas/core/widgets/wallpaper/favoritable_wallpaper_tile.dart';
import 'package:livecanvas/core/widgets/wallpaper/premium_badge.dart';
import 'package:livecanvas/core/widgets/wallpaper/video_preview.dart';
import 'package:livecanvas/features/set_wallpaper/set_wallpaper.dart';
import 'package:livecanvas/features/wallpaper_detail/presentation/cubit/wallpaper_detail_cubit.dart';
import 'package:livecanvas/features/wallpaper_detail/presentation/cubit/wallpaper_detail_state.dart';
import 'package:livecanvas/l10n/l10n.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// Full-screen Wallpaper Detail (US2 + design pass): a tall looping preview
/// with floating glass chrome, and an info sheet that overlaps it (rounded top
/// + aura shadow) carrying title, meta, actions, stats and collection links.
/// Set/Download/Share are visual anchors in MO-003 (real work in MO-005/006).
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
            WallpaperDetailLoaded(:final wallpaper, :final related) => _Content(
              wallpaper: wallpaper,
              related: related,
            ),
          };
          return Stack(
            children: [
              body,
              _Chrome(wallpaperId: wallpaperId),
            ],
          );
        },
      ),
    );
  }
}

/// Floating glass top row — stays over the preview while content scrolls.
class _Chrome extends StatelessWidget {
  const _Chrome({required this.wallpaperId});

  final int wallpaperId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = getIt<FavoritesRepository>();
    void soon() => showToast(context, l10n.placeholderComingSoon);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sp4,
          14,
          AppSpacing.sp4,
          0,
        ),
        child: Row(
          children: [
            GlassIconButton(
              icon: AppIcons.arrowLeft,
              onTap: () => context.pop(),
            ),
            const Spacer(),
            GlassIconButton(icon: AppIcons.share, onTap: soon),
            const SizedBox(width: AppSpacing.sp2),
            ValueListenableBuilder<Set<int>>(
              valueListenable: repo.listenable,
              builder: (context, ids, _) => GlassIconButton(
                icon: ids.contains(wallpaperId)
                    ? AppIcons.heartFill
                    : AppIcons.heart,
                active: ids.contains(wallpaperId),
                onTap: () {
                  unawaited(HapticFeedback.selectionClick());
                  unawaited(repo.toggle(wallpaperId));
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sp2),
            GlassIconButton(icon: AppIcons.dotsThreeVertical, onTap: soon),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.wallpaper, this.related = const []});

  final Wallpaper wallpaper;
  final List<Wallpaper> related;

  static const double _heroHeight = 468;
  static const double _overlap = 28;

  @override
  Widget build(BuildContext context) {
    // Design's sticky preview + sheet that slides up over it. The live video
    // hero is a FIXED background layer (not inside the scroll), and the sheet
    // scrolls over it with a transparent spacer revealing the hero — so the
    // sheet's rounded top overlaps the preview (parallax) exactly like the
    // prototype. Keeping the video out of the scroll avoids the iOS platform-
    // view positioning bug that broke the earlier sliver + transform version.
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: _heroHeight,
          child: _Preview(wallpaper: wallpaper),
        ),
        Positioned.fill(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: _heroHeight - _overlap),
                _Sheet(wallpaper: wallpaper, related: related),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.wallpaper});

  final Wallpaper wallpaper;

  @override
  Widget build(BuildContext context) {
    final duration = _fmtDuration(wallpaper.durationSeconds);
    return SizedBox(
      height: 468,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          VideoPreview(
            videoUrl: wallpaper.previewVideoUrl ?? '',
            posterUrl: wallpaper.thumbnailUrl ?? '',
            autoPlay: true,
          ),
          // Legibility scrim for the floating chrome + sheet seam.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x8C09070E),
                  Color(0x0009070E),
                  Color(0x7309070E),
                ],
                stops: [0, 0.3, 1],
              ),
            ),
          ),
          if (duration != null)
            Positioned(
              top: 70,
              left: 0,
              right: 0,
              child: Center(
                child: MetaChip(text: '$duration · LOOP', live: true),
              ),
            ),
        ],
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.wallpaper, this.related = const []});

  final Wallpaper wallpaper;
  final List<Wallpaper> related;

  @override
  Widget build(BuildContext context) {
    final w = wallpaper;
    final isPremium = w.isPremium ?? false;
    final tag = (w.tags ?? const []).isNotEmpty ? w.tags!.first.name : null;
    final collections = w.collections ?? const [];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgApp,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.rXl),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 40,
            offset: Offset(0, -12),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sp5,
        10,
        AppSpacing.sp5,
        28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grab handle.
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Premium + tag row.
          Row(
            children: [
              if (isPremium) ...[
                const PremiumBadge(),
                const SizedBox(width: AppSpacing.sp2),
              ],
              if (tag != null && tag.isNotEmpty) _TagPill(tag: tag),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            w.title ?? '',
            style: AppTypography.h1.copyWith(
              fontSize: 32,
              height: 1.05,
              fontWeight: AppTypography.medium,
              letterSpacing: -0.64,
            ),
          ),
          for (final ref in collections)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sp4),
              child: _CollectionCard(ref: ref),
            ),
          const SizedBox(height: AppSpacing.sp4),
          _MetaRow(wallpaper: w),
          const SizedBox(height: AppSpacing.sp5),
          _Actions(wallpaper: w),
          const SizedBox(height: AppSpacing.sp5),
          _Stats(wallpaper: w),
          if ((w.description ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sp6),
            _SectionLabel(text: context.l10n.detailDescription),
            const SizedBox(height: AppSpacing.sp3),
            Text(
              w.description!.trim(),
              style: AppTypography.bodyText.copyWith(
                fontSize: 14,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (related.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sp6),
            _SectionLabel(text: context.l10n.detailRelated),
            const SizedBox(height: AppSpacing.sp3),
            _RelatedGrid(items: related),
          ],
        ],
      ),
    );
  }
}

/// Display-font section header (handoff `SectionLabel`, 19/600).
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.h1.copyWith(
        fontSize: 19,
        fontWeight: AppTypography.medium,
        letterSpacing: -0.38,
      ),
    );
  }
}

class _RelatedGrid extends StatelessWidget {
  const _RelatedGrid({required this.items});

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
            return FavoritableWallpaperTile(
              wallpaper: wallpaper,
              onTap: () => context.push('/wallpaper/${wallpaper.id}'),
            );
          },
        );
      },
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp3 - 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.bgRaised,
        borderRadius: BorderRadius.circular(AppSpacing.rPill),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Text(
        '#$tag',
        style: AppTypography.small.copyWith(
          fontSize: 12,
          fontWeight: AppTypography.medium,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.wallpaper});

  final Wallpaper wallpaper;

  @override
  Widget build(BuildContext context) {
    final duration = _fmtDuration(wallpaper.durationSeconds);
    final size = _fmtSize(wallpaper.fileSizeBytes);
    final res = wallpaper.resolution;
    return Wrap(
      spacing: AppSpacing.sp2,
      runSpacing: AppSpacing.sp2,
      children: [
        if (res != null && res.isNotEmpty)
          MetaChip(
            text: res,
            icon: AppIcons.monitor,
            tone: MetaChipTone.surface,
          ),
        if (duration != null)
          MetaChip(
            text: duration,
            icon: AppIcons.clock,
            tone: MetaChipTone.surface,
          ),
        if (size != null)
          MetaChip(
            text: size,
            icon: AppIcons.download,
            tone: MetaChipTone.surface,
          ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.wallpaper});

  final Wallpaper wallpaper;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // The prototype wires BOTH "Tải xuống" and "Đặt làm hình nền" to the same
    // sheet, which is where the actual action is chosen (FR-001). Premium is
    // NOT gated here — the sheet calls download-url and lets the server's 402
    // decide (Principle V, FR-027).
    // The generated model types `id` as nullable; without one there is
    // nothing to download, so the actions are disabled rather than
    // force-unwrapped.
    final id = wallpaper.id;
    final openSheet = id == null
        ? null
        : () => unawaited(
            showSetWallpaperSheet(
              context,
              wallpaperId: id,
              wallpaperTitle: wallpaper.title ?? '',
            ),
          );

    if (wallpaper.isPremium ?? false) {
      return AppButton(
        label: l10n.detailUnlock,
        onPressed: openSheet,
        gradient: true,
        icon: AppIcons.sparkle,
      );
    }
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: l10n.detailDownload,
            onPressed: openSheet,
            variant: AppButtonVariant.ghost,
            icon: AppIcons.download,
          ),
        ),
        const SizedBox(width: AppSpacing.sp3),
        Expanded(
          child: AppButton(
            label: l10n.detailSetWallpaper,
            onPressed: openSheet,
            variant: AppButtonVariant.light,
            icon: AppIcons.paintBrush,
          ),
        ),
      ],
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.wallpaper});

  final Wallpaper wallpaper;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stats = <_Stat>[
      if (wallpaper.downloadCount != null)
        _Stat(
          icon: AppIcons.download,
          value: _fmtCount(wallpaper.downloadCount!),
          label: l10n.detailStatDownloads,
        ),
      if (wallpaper.likeCount != null)
        _Stat(
          icon: AppIcons.heart,
          value: _fmtCount(wallpaper.likeCount!),
          label: l10n.detailStatLikes,
        ),
      if ((wallpaper.resolution ?? '').isNotEmpty)
        _Stat(
          icon: AppIcons.monitorPlay,
          value: wallpaper.resolution!,
          label: l10n.detailStatResolution,
        ),
    ];
    if (stats.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sp4),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppSpacing.rMd),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0)
              const SizedBox(
                height: 40,
                child: VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: AppColors.borderSubtle,
                ),
              ),
            Expanded(child: stats[i]),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.iris400),
        const SizedBox(height: AppSpacing.sp1),
        Text(
          value,
          style: AppTypography.monoMeta.copyWith(
            fontSize: 15,
            fontWeight: AppTypography.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: AppTypography.small.copyWith(
            fontSize: 11,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.ref});

  final CollectionRef ref;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/collection/${ref.id}'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sp3),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppSpacing.rMd),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.rSm),
              child: SizedBox(
                width: 52,
                height: 68,
                child: Image.network(
                  ref.coverUrl ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const ColoredBox(color: AppColors.onyx),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sp3 + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.detailFromCollectionEyebrow,
                    style: AppTypography.eyebrow.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ref.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.h3.copyWith(
                      fontFamily: AppTypography.displayFamily,
                      fontSize: 17,
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              AppIcons.caretRight,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

// ---- formatters ----

String? _fmtDuration(num? seconds) {
  if (seconds == null) return null;
  final total = seconds.round();
  final m = total ~/ 60;
  final s = total % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

String? _fmtSize(int? bytes) {
  if (bytes == null) return null;
  const mb = 1024 * 1024;
  if (bytes >= mb) {
    final digits = bytes >= 10 * mb ? 0 : 1;
    return '${(bytes / mb).toStringAsFixed(digits)} MB';
  }
  return '${(bytes / 1024).round()} KB';
}

String _fmtCount(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}
