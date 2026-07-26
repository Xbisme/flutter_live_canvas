import 'dart:async';

import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/widgets/feedback/skeleton/shimmer_box.dart';
import 'package:video_player/video_player.dart';

/// A looping, muted preview that only holds a [VideoPlayerController] while it
/// is actually being watched (Principle II — NON-NEGOTIABLE: bound the number
/// of live decoders — and a hard limit on Android, which reclaims H.264
/// decoders once too many run at once).
///
/// In a grid ([autoPlay] false) the tile shows only its poster; the clip plays
/// on **hover** (pointer devices) or **press-and-hold** (touch), and is paused
/// + **disposed** the instant the pointer leaves or the finger lifts — so at
/// most one decoder runs at a time and scrolling never spins any up. A plain
/// tap does nothing here; it falls through to the card, which opens the detail
/// view.
///
/// On the detail view ([autoPlay] true) the clip plays as soon as it
/// initialises and stays playing, since it is the focus of the screen.
class VideoPreview extends StatefulWidget {
  const VideoPreview({
    required this.videoUrl,
    required this.posterUrl,
    this.autoPlay = false,
    super.key,
  });

  final String videoUrl;
  final String posterUrl;

  /// Play immediately on init instead of waiting for hover/press. Used by the
  /// detail view, where the preview is the focus.
  final bool autoPlay;

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  VideoPlayerController? _controller;
  bool _initializing = false;
  bool _failed = false;

  /// The user is currently hovering/holding (or autoPlay is on) — i.e. the clip
  /// *should* be live. Guards against a controller that finishes initialising
  /// after the pointer has already left.
  bool _active = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) unawaited(_activate());
  }

  Future<void> _activate() async {
    if (_active) return;
    _active = true;
    if (_controller != null ||
        _initializing ||
        _failed ||
        widget.videoUrl.isEmpty) {
      return;
    }
    _initializing = true;
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      // The pointer may have left (or the tile been disposed) mid-init.
      if (!mounted || !_active) {
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

  Future<void> _deactivate() async {
    // The detail view keeps playing regardless of pointer.
    if (widget.autoPlay) return;
    _active = false;
    final controller = _controller;
    if (controller == null) return;
    _controller = null;
    if (mounted) setState(() {});
    await controller.pause();
    await controller.dispose();
  }

  @override
  void dispose() {
    _active = false;
    final controller = _controller;
    _controller = null;
    if (controller != null) unawaited(controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final content = ColoredBox(
      color: AppColors.onyx,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Poster is always painted; the video fades in over it. Decode it at
          // the tile's display size (not the full JPEG) — full decodes are a
          // primary source of grid scroll jank. Per-tile shimmer while loading.
          LayoutBuilder(
            builder: (context, constraints) {
              final dpr = MediaQuery.devicePixelRatioOf(context);
              final cacheW = (constraints.maxWidth * dpr).round();
              return Image.network(
                widget.posterUrl,
                fit: BoxFit.cover,
                cacheWidth: cacheW > 0 ? cacheW : null,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const ShimmerBox(expand: true, radius: 0),
                errorBuilder: (_, _, _) =>
                    const ColoredBox(color: AppColors.onyx),
              );
            },
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
    );

    if (widget.autoPlay) return content;

    // Grid: hover (pointer) or press-and-hold (touch) to preview; releasing
    // stops + disposes. A quick tap is left for the card's onTap (open detail).
    return MouseRegion(
      onEnter: (_) => unawaited(_activate()),
      onExit: (_) => unawaited(_deactivate()),
      child: GestureDetector(
        onLongPressStart: (_) => unawaited(_activate()),
        onLongPressEnd: (_) => unawaited(_deactivate()),
        onLongPressCancel: () => unawaited(_deactivate()),
        child: content,
      ),
    );
  }
}
