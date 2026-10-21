import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Full pill button with the primary gradient and glow. Pressed state scales
/// to 0.97 and brightens.
class GradientPillButton extends StatefulWidget {
  const GradientPillButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.height,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final double? height;
  final IconData? icon;
  final bool expand;

  @override
  State<GradientPillButton> createState() => _GradientPillButtonState();
}

class _GradientPillButtonState extends State<GradientPillButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final enabled = widget.onPressed != null;
    final height = widget.height ?? t.buttonHeight;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: enabled
            ? () {
                HapticFeedback.lightImpact();
                widget.onPressed!();
              }
            : null,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: t.motion.fast,
          child: AnimatedContainer(
            duration: t.motion.fast,
            height: height,
            width: widget.expand ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: 28),
            decoration: BoxDecoration(
              gradient: enabled ? t.primaryGradient : null,
              color: enabled ? null : const Color(0xFFD9D2E3),
              borderRadius: BorderRadius.circular(height / 2),
              boxShadow: enabled ? t.primaryGlow : null,
            ),
            foregroundDecoration: BoxDecoration(
              color: _pressed ? const Color(0x1FFFFFFF) : Colors.transparent,
              borderRadius: BorderRadius.circular(height / 2),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                ],
                Text(widget.label, style: EventraText.button),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
