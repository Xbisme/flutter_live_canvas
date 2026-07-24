import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_elevation.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';

/// Top app bar faithful to the prototype: a glass (blurred) chrome that shows
/// either the brand wordmark (Clash Display + aurora gradient) or a plain
/// title, with an optional trailing action.
class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({this.title, this.wordmark = false, this.trailing, super.key})
    : assert(
        title != null || wordmark,
        'TopBar needs a title or wordmark',
      );

  final String? title;
  final bool wordmark;
  final Widget? trailing;

  static const double _height = 56;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppElevation.blurBar,
          sigmaY: AppElevation.blurBar,
        ),
        child: ColoredBox(
          color: AppColors.bgApp.withValues(alpha: 0.72),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: _height,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.gutter,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: wordmark ? const _Wordmark() : _Title(title!),
                    ),
                    ?trailing,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTypography.h2, overflow: TextOverflow.ellipsis);
}

/// The brand wordmark — Clash Display, painted with the aurora gradient.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => AppColors.aurora.createShader(bounds),
      child: Text(
        'LiveCanvas',
        style: AppTypography.h1.copyWith(color: AppColors.onAccent),
      ),
    );
  }
}
