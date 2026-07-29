import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_colors.dart';

/// Circular glass icon button (handoff `IconButton variant="glass"`): a
/// translucent dark fill with a white hairline that sits over content — the
/// floating chrome on Wallpaper/Collection Detail (back / share / heart / more).
/// When [active] it fills with the blush favourite colour and glows.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    required this.icon,
    required this.onTap,
    this.active = false,
    this.size = 44,
    this.semanticLabel,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool active;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.favorite : const Color(0x7014101E),
            border: Border.all(
              color: active ? Colors.transparent : const Color(0x24FFFFFF),
            ),
            boxShadow: active
                ? const [
                    BoxShadow(
                      color: Color(0x73FF6F9C), // rgba(255,111,156,0.45)
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(icon, size: size * 0.46, color: AppColors.onAccent),
        ),
      ),
    );
  }
}
