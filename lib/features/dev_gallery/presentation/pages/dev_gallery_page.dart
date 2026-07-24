import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_icons.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';
import 'package:livecanvas/core/widgets/controls/app_button.dart';
import 'package:livecanvas/core/widgets/controls/app_icon_button.dart';
import 'package:livecanvas/core/widgets/controls/filter_chip.dart';
import 'package:livecanvas/core/widgets/controls/meta_chip.dart';
import 'package:livecanvas/core/widgets/feedback/empty_state.dart';
import 'package:livecanvas/core/widgets/feedback/toast.dart';
import 'package:livecanvas/core/widgets/navigation/top_bar.dart';
import 'package:livecanvas/core/widgets/sheet/app_sheet.dart';
import 'package:livecanvas/core/widgets/wallpaper/premium_badge.dart';
import 'package:livecanvas/core/widgets/wallpaper/wallpaper_card.dart';

/// Dev-only gallery (FR-006a) — renders every shared widget with sample data
/// so it can be checked against the prototype (SC-005). Reachable only via the
/// `/dev/gallery` route; never surfaced in the user-facing flow.
class DevGalleryPage extends StatelessWidget {
  const DevGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const TopBar(title: 'Gallery'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.gutter),
              children: [
                const _Section('WallpaperCard (free / premium)'),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: WallpaperCard(
                        preview: _gradientPreview(
                          const [AppColors.blush500, AppColors.iris500],
                        ),
                        auraColor: AppColors.blush500.withValues(alpha: 0.62),
                        title: 'Neon Rain',
                        author: 'studiolux',
                        meta: const WallpaperMeta(duration: '0:08'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.gridGap),
                    Expanded(
                      child: WallpaperCard(
                        preview: _gradientPreview(
                          const [AppColors.aqua500, AppColors.success],
                        ),
                        auraColor: AppColors.aqua500.withValues(alpha: 0.55),
                        title: 'Aurora Drift',
                        author: 'nord',
                        premium: true,
                        isFav: true,
                        meta: const WallpaperMeta(duration: '0:12'),
                      ),
                    ),
                  ],
                ),
                const _Section('Badges & meta'),
                const Wrap(
                  spacing: AppSpacing.sp3,
                  runSpacing: AppSpacing.sp2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    PremiumBadge(),
                    MetaChip(text: '4K'),
                    MetaChip(text: '18MB'),
                    MetaChip(text: '0:12'),
                  ],
                ),
                const _Section('Filter chips'),
                Wrap(
                  spacing: AppSpacing.sp2,
                  children: [
                    AppFilterChip(
                      label: 'Tất cả',
                      selected: true,
                      onTap: () {},
                    ),
                    AppFilterChip(label: 'Neon', selected: false, onTap: () {}),
                    AppFilterChip(
                      label: 'Thiên nhiên',
                      selected: false,
                      onTap: () {},
                    ),
                  ],
                ),
                const _Section('Buttons'),
                AppButton(label: 'Mở khoá', gradient: true, onPressed: () {}),
                const SizedBox(height: AppSpacing.sp3),
                AppButton(label: 'Tải xuống', onPressed: () {}),
                const SizedBox(height: AppSpacing.sp3),
                AppButton(
                  label: 'Chia sẻ',
                  variant: AppButtonVariant.ghost,
                  onPressed: () {},
                ),
                const _Section('Icon buttons'),
                Row(
                  children: [
                    AppIconButton(icon: AppIcons.heart, onPressed: () {}),
                    const SizedBox(width: AppSpacing.sp3),
                    AppIconButton(
                      icon: AppIcons.share,
                      variant: AppIconButtonVariant.solid,
                      onPressed: () {},
                    ),
                    const SizedBox(width: AppSpacing.sp3),
                    AppIconButton(icon: AppIcons.dotsThree, onPressed: () {}),
                  ],
                ),
                const _Section('Sheet & Toast'),
                Row(
                  children: [
                    AppButton(
                      label: 'Show sheet',
                      variant: AppButtonVariant.ghost,
                      onPressed: () => showAppSheet<void>(
                        context,
                        builder: (_) => const _DemoSheetBody(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sp3),
                    AppButton(
                      label: 'Show toast',
                      variant: AppButtonVariant.ghost,
                      onPressed: () =>
                          showToast(context, 'Đã sao chép liên kết'),
                    ),
                  ],
                ),
                const _Section('EmptyState'),
                SizedBox(
                  height: 220,
                  child: EmptyState(
                    icon: AppIcons.heart,
                    title: 'Chưa có yêu thích',
                    message: 'Những hình nền bạn thích sẽ xuất hiện ở đây.',
                    action: AppButton(label: 'Khám phá', onPressed: () {}),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _gradientPreview(List<Color> colors) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ),
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(
      top: AppSpacing.sp6,
      bottom: AppSpacing.sp3,
    ),
    child: Text(title, style: AppTypography.eyebrow),
  );
}

class _DemoSheetBody extends StatelessWidget {
  const _DemoSheetBody();

  @override
  Widget build(BuildContext context) => const Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Bottom sheet', style: AppTypography.h3),
      SizedBox(height: AppSpacing.sp3),
      Text(
        'AppSheet — rounded top, grab handle, safe-area aware.',
        style: AppTypography.small,
      ),
    ],
  );
}
