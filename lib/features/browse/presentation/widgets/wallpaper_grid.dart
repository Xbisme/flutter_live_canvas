import 'package:flutter/material.dart';
import 'package:livecanvas/core/responsive/breakpoints.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';
import 'package:livecanvas/core/widgets/wallpaper/wallpaper_tile.dart';
import 'package:livecanvas/l10n/l10n.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// Lazy, cursor-paginated wallpaper grid reused by Browse and Search (research
/// R7). Prefetches the next page ~600px before the end; the footer shows the
/// load-more state (skeleton while appending, a retry on failure). Per-tile
/// video lifecycle is handled inside [WallpaperTile] (Principle II).
class WallpaperGrid extends StatefulWidget {
  const WallpaperGrid({
    required this.items,
    required this.hasMore,
    required this.isLoadingMore,
    required this.loadMoreFailed,
    required this.onLoadMore,
    required this.onTap,
    super.key,
  });

  final List<Wallpaper> items;
  final bool hasMore;
  final bool isLoadingMore;
  final bool loadMoreFailed;
  final VoidCallback onLoadMore;
  final ValueChanged<Wallpaper> onTap;

  @override
  State<WallpaperGrid> createState() => _WallpaperGridState();
}

class _WallpaperGridState extends State<WallpaperGrid> {
  static const _prefetchExtent = 600.0;

  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    if (position.pixels >= position.maxScrollExtent - _prefetchExtent) {
      widget.onLoadMore();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final columns = Breakpoints.gridColumns(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        // Cell height = 9:16 preview + the card's title/author block, so the
        // WallpaperCard column never overflows its grid cell.
        final columnWidth =
            (constraints.maxWidth -
                AppSpacing.gutter * 2 -
                AppSpacing.gridGap * (columns - 1)) /
            columns;
        final cellHeight =
            columnWidth / AppSpacing.wallRatio + _textBlockHeight;
        return CustomScrollView(
          controller: _controller,
          slivers: [
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
                  final wallpaper = widget.items[index];
                  return WallpaperTile(
                    wallpaper: wallpaper,
                    onTap: () => widget.onTap(wallpaper),
                  );
                }, childCount: widget.items.length),
              ),
            ),
            SliverToBoxAdapter(child: _Footer(widget: widget)),
          ],
        );
      },
    );
  }

  /// Room under the preview for the title + author lines in [WallpaperTile].
  static const _textBlockHeight = 52.0;
}

class _Footer extends StatelessWidget {
  const _Footer({required this.widget});

  final WallpaperGrid widget;

  @override
  Widget build(BuildContext context) {
    if (widget.loadMoreFailed) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.sp5),
        child: Center(
          child: TextButton(
            onPressed: widget.onLoadMore,
            child: Text(
              context.l10n.retry,
              style: AppTypography.small.copyWith(color: AppColors.accent),
            ),
          ),
        ),
      );
    }
    if (widget.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.sp5),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accent,
            ),
          ),
        ),
      );
    }
    return const SizedBox(height: AppSpacing.sp8);
  }
}
