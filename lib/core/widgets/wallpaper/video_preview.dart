import 'dart:async';

import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// A looping, muted preview video that only holds a [VideoPlayerController]
/// while it is on (or near) screen (Principle II — NON-NEGOTIABLE).
///
/// The controller is created + played when at least ~60% of the widget is
/// visible, and paused + **disposed** the moment it leaves the
/// viewport, falling back to the static [posterUrl]. This bounds the number of
/// simultaneously live decoders so a fast-scrolled grid stays memory-flat.
///
/// [detectorKey] must be unique per tile (e.g. the wallpaper id) — the
/// visibility detector needs a stable, unique key.
class VideoPreview extends StatefulWidget {
  const VideoPreview({
    required this.videoUrl,
    required this.posterUrl,
    required this.detectorKey,
    super.key,
  });

  final String videoUrl;
  final String posterUrl;
  final String detectorKey;

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  static const _visibleThreshold = 0.6;

  VideoPlayerController? _controller;
  bool _initializing = false;
  bool _failed = false;

  Future<void> _ensurePlaying() async {
    if (_controller != null || _initializing || _failed) return;
    _initializing = true;
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      await controller.play();
      setState(() => _controller = controller);
    } on Object {
      await controller.dispose();
      if (mounted) setState(() => _failed = true);
    } finally {
      _initializing = false;
    }
  }

  Future<void> _release() async {
    final controller = _controller;
    if (controller == null) return;
    _controller = null;
    if (mounted) setState(() {});
    await controller.pause();
    await controller.dispose();
  }

  void _onVisibility(VisibilityInfo info) {
    if (!mounted) return;
    if (info.visibleFraction >= _visibleThreshold) {
      unawaited(_ensurePlaying());
    } else if (info.visibleFraction == 0) {
      unawaited(_release());
    }
  }

  @override
  void dispose() {
    final controller = _controller;
    _controller = null;
    if (controller != null) unawaited(controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return VisibilityDetector(
      key: Key('video-${widget.detectorKey}'),
      onVisibilityChanged: _onVisibility,
      child: ColoredBox(
        color: AppColors.onyx,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Poster is always painted; the video fades in over it.
            Image.network(
              widget.posterUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: AppColors.onyx),
            ),
            if (controller != null && controller.value.isInitialized)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
