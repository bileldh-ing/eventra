import 'dart:ui';

import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/pressable.dart';
import 'package:flutter/material.dart';

/// Frosted glass surface: BackdropFilter blur (sigma 14) with the spec's
/// glass fill and border.
class Glass extends StatelessWidget {
  const Glass({
    required this.child,
    super.key,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.fill,
    this.padding,
    this.gradient,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final Color? fill;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final decoration = BoxDecoration(
      color: gradient == null ? (fill ?? t.glassFill) : null,
      gradient: gradient,
      shape: shape,
      borderRadius: shape == BoxShape.circle ? null : borderRadius,
      border: Border.all(color: t.glassBorder),
    );
    final content = DecoratedBox(
      decoration: decoration,
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );
    final filter = BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: t.glassBlurSigma,
        sigmaY: t.glassBlurSigma,
      ),
      child: content,
    );
    if (shape == BoxShape.circle) return ClipOval(child: filter);
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: filter,
    );
  }
}

/// Circular glass icon button (40-56dp) used over photos and gradients.
class GlassCircleButton extends StatelessWidget {
  const GlassCircleButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    super.key,
    this.size = 48,
    this.iconSize = 22,
    this.iconColor = Colors.white,
    this.badge = false,
    this.fill,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final double size;
  final double iconSize;
  final Color iconColor;
  final bool badge;
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Pressable(
        onTap: onPressed,
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            children: [
              Positioned.fill(
                child: Glass(
                  shape: BoxShape.circle,
                  fill: fill,
                  child: Center(
                    child: Icon(icon, color: iconColor, size: iconSize),
                  ),
                ),
              ),
              if (badge)
                Positioned(
                  top: size * 0.26,
                  right: size * 0.3,
                  child: Container(
                    key: const ValueKey('notification-dot'),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: t.notificationRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// White circular button used on the map screen.
class WhiteCircleButton extends StatelessWidget {
  const WhiteCircleButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    super.key,
    this.size = 52,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String semanticLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Pressable(
        onTap: onPressed,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: t.surface,
            shape: BoxShape.circle,
            boxShadow: t.softShadow,
          ),
          child: Icon(icon, color: t.textPrimary, size: 24),
        ),
      ),
    );
  }
}
