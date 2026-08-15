import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:livecanvas/core/di/injection.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/core/error/failure_l10n.dart';
import 'package:livecanvas/core/router/app_routes.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_icons.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';
import 'package:livecanvas/core/wallpaper/wallpaper_platform_service.dart';
import 'package:livecanvas/core/widgets/controls/app_button.dart';
import 'package:livecanvas/core/widgets/controls/glass_icon_button.dart';
import 'package:livecanvas/core/widgets/feedback/toast.dart';
import 'package:livecanvas/core/widgets/sheet/app_sheet.dart';
import 'package:livecanvas/features/set_wallpaper/presentation/cubit/set_wallpaper_cubit.dart';
import 'package:livecanvas/features/set_wallpaper/presentation/cubit/set_wallpaper_state.dart';
import 'package:livecanvas/l10n/l10n.dart';

/// Opens the "Set as wallpaper" sheet for [wallpaperId].
///
/// On a tablet the prototype (`ipad.html`) centres it as a dialog rather than
/// letting it span the full width from the bottom (FR-031).
Future<void> showSetWallpaperSheet(
  BuildContext context, {
  required int wallpaperId,
  required String wallpaperTitle,
}) {
  final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    constraints: isTablet ? const BoxConstraints(maxWidth: 480) : null,
    builder: (_) => BlocProvider(
      create: (_) => getIt<SetWallpaperCubit>(),
      child: SetWallpaperSheet(
        wallpaperId: wallpaperId,
        wallpaperTitle: wallpaperTitle,
      ),
    ),
  );
}

/// The sheet body, faithful to `SetWallpaper.jsx`.
///
/// The prototype's Android/iPhone segmented control is a web demo affordance
/// only — a real device is on exactly one platform, so it is not rendered
/// (FR-002).
class SetWallpaperSheet extends StatelessWidget {
  const SetWallpaperSheet({
    required this.wallpaperId,
    required this.wallpaperTitle,
    this.platformOverride,
    super.key,
  });

  final int wallpaperId;
  final String wallpaperTitle;

  /// Test seam; production reads [defaultTargetPlatform].
  @visibleForTesting
  final TargetPlatform? platformOverride;

  bool get _isAndroid =>
      (platformOverride ?? defaultTargetPlatform) == TargetPlatform.android;

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      child: BlocConsumer<SetWallpaperCubit, SetWallpaperState>(
        listener: _onStateChanged,
        builder: (context, state) => switch (state) {
          // Android is done once the file is on the device — the next tap opens
          // the system preview. iOS still has a step to go: the video only
          // reaches Photos after saveToPhotos succeeds, and the Shortcuts guide
          // is pointless until the user has something to pick.
          SetWallpaperLoadedReady() when _isAndroid => _DoneBody(
            isAndroid: true,
            wallpaperTitle: wallpaperTitle,
          ),
          SetWallpaperLoadedApplied() => _DoneBody(
            isAndroid: _isAndroid,
            wallpaperTitle: wallpaperTitle,
          ),
          _ => _IntroBody(
            isAndroid: _isAndroid,
            wallpaperId: wallpaperId,
            state: state,
          ),
        },
      ),
    );
  }

  /// Side effects live here, never in the builder (Principle III).
  void _onStateChanged(BuildContext context, SetWallpaperState state) {
    switch (state) {
      case SetWallpaperLoadingDownload(:final progress)
          when progress.receivedBytes == 0:
        unawaited(HapticFeedback.selectionClick());
      // On iOS the download is only half the job — chain straight into the
      // Photos write so "Lưu video vào Ảnh" actually saves the video.
      case SetWallpaperLoadedReady() when !_isAndroid:
        unawaited(context.read<SetWallpaperCubit>().saveToPhotos());
      case SetWallpaperLoadedApplied():
        unawaited(HapticFeedback.mediumImpact());
      case SetWallpaperError(failure: EntitlementRequiredFailure()):
        _openPaywall(context);
      case _:
        break;
    }
  }

  /// Principle X names "Paywall, Set Wallpaper" explicitly: dismiss this sheet
  /// FIRST, then open the Paywall on the next frame. Pushing while the sheet is
  /// still mounted puts two surfaces in the same frame.
  void _openPaywall(BuildContext context) {
    context.pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) unawaited(context.push(AppRoutes.paywall));
    });
  }
}

class _IntroBody extends StatelessWidget {
  const _IntroBody({
    required this.isAndroid,
    required this.wallpaperId,
    required this.state,
  });

  final bool isAndroid;
  final int wallpaperId;
  final SetWallpaperState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<SetWallpaperCubit>();
    final downloading = state is SetWallpaperLoadingDownload;
    // iOS only: the file has landed and the Photos write is running. Offering
    // the CTA here invites a second download of a file we already have.
    final saving = !isAndroid && state is SetWallpaperLoadedReady;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.setWallpaperTitle, style: AppTypography.h2),
            GlassIconButton(
              icon: AppIcons.close,
              onTap: () => context.pop(),
              semanticLabel: l10n.setWallpaperCancel,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sp3),
        Text(
          isAndroid ? l10n.setWallpaperAndroidIntro : l10n.setWallpaperIosIntro,
          style: AppTypography.small.copyWith(color: AppColors.textTertiary),
        ),
        if (state case SetWallpaperError(:final failure)) ...[
          const SizedBox(height: AppSpacing.sp3),
          Text(
            failure is EntitlementRequiredFailure
                ? l10n.premiumRequiredMessage
                : failure.localizedMessage(context),
            style: AppTypography.small.copyWith(color: AppColors.danger),
          ),
        ],
        const SizedBox(height: AppSpacing.sp4),
        if (downloading)
          _DownloadingBlock(state: state as SetWallpaperLoadingDownload)
        else if (saving)
          _BusyBlock(label: l10n.setWallpaperSaving)
        else
          AppButton(
            label: state is SetWallpaperError
                ? l10n.setWallpaperRetry
                : (isAndroid
                      ? l10n.setWallpaperAndroidCta
                      : l10n.setWallpaperIosCta),
            icon: AppIcons.download,
            onPressed: () => cubit.startDownload(wallpaperId),
          ),
      ],
    );
  }
}

/// Indeterminate progress for a step with no byte count to report.
class _BusyBlock extends StatelessWidget {
  const _BusyBlock({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.rPill),
          child: const LinearProgressIndicator(
            minHeight: AppSpacing.sp2,
            backgroundColor: AppColors.bgRaised,
            valueColor: AlwaysStoppedAnimation(AppColors.accent),
          ),
        ),
        const SizedBox(height: AppSpacing.sp3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.monoMeta.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _DownloadingBlock extends StatelessWidget {
  const _DownloadingBlock({required this.state});

  final SetWallpaperLoadingDownload state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fraction = state.progress.fraction;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.rPill),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: AppSpacing.sp2,
            backgroundColor: AppColors.bgRaised,
            valueColor: const AlwaysStoppedAnimation(AppColors.accent),
          ),
        ),
        const SizedBox(height: AppSpacing.sp3),
        Text(
          fraction == null
              ? l10n.setWallpaperDownloading
              : '${(fraction * 100).round()}%',
          textAlign: TextAlign.center,
          style: AppTypography.monoMeta.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sp3),
        AppButton(
          label: l10n.setWallpaperCancel,
          variant: AppButtonVariant.ghost,
          onPressed: context.read<SetWallpaperCubit>().cancel,
        ),
      ],
    );
  }
}

class _DoneBody extends StatelessWidget {
  const _DoneBody({required this.isAndroid, required this.wallpaperTitle});

  final bool isAndroid;
  final String wallpaperTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          AppIcons.checkCircle,
          size: AppSpacing.sp16 - AppSpacing.sp2,
          color: AppColors.success,
        ),
        const SizedBox(height: AppSpacing.sp3),
        Text(
          l10n.setWallpaperDoneTitle,
          style: AppTypography.h1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sp1),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: Text(
            isAndroid
                ? l10n.setWallpaperDoneAndroid(wallpaperTitle)
                : l10n.setWallpaperDoneIos,
            textAlign: TextAlign.center,
            style: AppTypography.small.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sp5),
        // Full-bleed CTA per the prototype; this Column centres its children,
        // so the width has to be forced.
        SizedBox(
          width: double.infinity,
          child: isAndroid
              ? AppButton(
                  label: l10n.setWallpaperApplyCta,
                  icon: AppIcons.paintBrush,
                  onPressed: context.read<SetWallpaperCubit>().applyWallpaper,
                )
              : const _PhotosGuide(),
        ),
      ],
    );
  }
}

/// The three-step guide from the prototype.
///
/// iOS has no public API for setting a wallpaper, so this is genuinely what the
/// user has to do — the copy must never imply otherwise (FR-018).
class _PhotosGuide extends StatelessWidget {
  const _PhotosGuide();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Step(number: 1, text: l10n.setWallpaperStep1),
        _Step(number: 2, text: l10n.setWallpaperStep2),
        _Step(number: 3, text: l10n.setWallpaperStep3),
        const SizedBox(height: AppSpacing.sp3),
        AppButton(
          label: l10n.setWallpaperOpenPhotos,
          icon: AppIcons.arrowSquareOut,
          variant: AppButtonVariant.ghost,
          onPressed: () => _openPhotos(context),
        ),
      ],
    );
  }

  /// Goes through our own channel rather than adding `url_launcher` for a
  /// single scheme (Principle XIV).
  Future<void> _openPhotos(BuildContext context) async {
    final message = context.l10n.setWallpaperPhotosMissing;
    final opened = await getIt<WallpaperPlatformService>().openPhotos();
    if (opened || !context.mounted) return;
    showToast(context, message);
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sp2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSpacing.sp6 + 2,
            height: AppSpacing.sp6 + 2,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppColors.auroraSoft,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Text(
              '$number',
              style: AppTypography.monoMeta.copyWith(
                color: AppColors.iris400,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sp3),
          Expanded(
            child: Text(
              text,
              style: AppTypography.small.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
