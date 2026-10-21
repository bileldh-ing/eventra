import 'package:flutter/material.dart';

/// One-shot entrance: fades in and rises [offset] px after [delay].
/// Skipped entirely when the platform asks to reduce motion.
class Entrance extends StatelessWidget {
  const Entrance({
    required this.child,
    super.key,
    this.delay = Duration.zero,
    this.offset = 18,
    this.fromScale = 1,
  });

  final Widget child;
  final Duration delay;
  final double offset;
  final double fromScale;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return child;
    const run = Duration(milliseconds: 480);
    final total = delay + run;
    final start = delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * offset),
          child: Transform.scale(
            scale: fromScale + (1 - fromScale) * v,
            child: child,
          ),
        ),
      ),
    );
  }
}
