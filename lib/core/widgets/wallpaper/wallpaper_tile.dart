import 'dart:async';

import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/widgets/wallpaper/video_preview.dart';
import 'package:livecanvas/core/widgets/wallpaper/wallpaper_card.dart';
import 'package:livecanvas_api/livecanvas_api.dart';
import 'package:palette_generator/palette_generator.dart';

/// A single wallpaper in a grid: a lifecycle-managed [VideoPreview] inside the
/// shared [WallpaperCard], with an "Aura" glow whose hue is derived from the
/// thumbnail via `palette_generator` (research R4). Falls back to the brand
/// accent until (or if) the palette resolves.
class WallpaperTile extends StatefulWidget {
  const WallpaperTile({required this.wallpaper, this.onTap, super.key});

  final Wallpaper wallpaper;
  final VoidCallback? onTap;

  @override
  State<WallpaperTile> createState() => _WallpaperTileState();
}

class _WallpaperTileState extends State<WallpaperTile> {
  /// Derived aura hues cached by id so recycled tiles don't recompute.
  static final Map<int, Color> _auraCache = {};

  Color _aura = AppColors.accent;

  @override
  void initState() {
    super.initState();
    unawaited(_resolveAura());
  }

  Future<void> _resolveAura() async {
    final id = widget.wallpaper.id;
    final thumb = widget.wallpaper.thumbnailUrl;
    if (id != null && _auraCache.containsKey(id)) {
      _aura = _auraCache[id]!;
      return;
    }
    if (thumb == null || thumb.isEmpty) return;
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        NetworkImage(thumb),
        size: const Size(64, 64),
        maximumColorCount: 8,
      );
      final color =
          palette.vibrantColor?.color ??
          palette.dominantColor?.color ??
          AppColors.accent;
      if (id != null) _auraCache[id] = color;
      if (mounted) setState(() => _aura = color);
    } on Object {
      // Keep the fallback accent — aura is decorative (spec assumption).
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.wallpaper;
    final duration = w.durationSeconds;
    return WallpaperCard(
      auraColor: _aura,
      title: w.title ?? '',
      premium: w.isPremium ?? false,
      meta: duration == null
          ? null
          : WallpaperMeta(duration: '${duration.round()}s'),
      onTap: widget.onTap,
      preview: VideoPreview(
        videoUrl: w.previewVideoUrl ?? '',
        posterUrl: w.thumbnailUrl ?? '',
        detectorKey: '${w.id ?? w.hashCode}',
      ),
    );
  }
}
