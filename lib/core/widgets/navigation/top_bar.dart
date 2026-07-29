import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_colors.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/theme/app_typography.dart';

/// Top app bar faithful to the prototype: an opaque `bg-app` header showing
/// either the brand wordmark (Clash Display 22 + aurora gradient) or a title
/// (Clash Display 28), with an optional trailing action.
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
    return ColoredBox(
      color: AppColors.bgApp,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: _height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
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
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    overflow: TextOverflow.ellipsis,
    style: AppTypography.h1.copyWith(
      fontWeight: AppTypography.medium,
      letterSpacing: -0.56, // -0.02em
    ),
  );
}

/// The brand wordmark — Clash Display 22, painted with the aurora gradient.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => AppColors.aurora.createShader(bounds),
      child: Text(
        'LiveCanvas',
        style: AppTypography.h2.copyWith(
          fontWeight: AppTypography.medium,
          letterSpacing: -0.44, // -0.02em
          color: AppColors.onAccent,
        ),
      ),
    );
  }
}
