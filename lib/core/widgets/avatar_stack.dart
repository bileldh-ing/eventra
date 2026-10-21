import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/event_image.dart';
import 'package:flutter/material.dart';

/// Overlapping circular avatars, optionally followed by a purple "+N" circle.
class AvatarStack extends StatelessWidget {
  const AvatarStack({
    required this.urls,
    super.key,
    this.size = 28,
    this.overlap = 0.35,
    this.extraCount,
    this.borderWidth = 2,
  });

  final List<String> urls;
  final double size;
  final double overlap;
  final int? extraCount;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final step = size * (1 - overlap);
    final count = urls.length + (extraCount != null && extraCount! > 0 ? 1 : 0);
    return SizedBox(
      width: count == 0 ? 0 : step * (count - 1) + size,
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < urls.length; i++)
            Positioned(
              left: i * step,
              child: NetAvatar(
                url: urls[i],
                size: size,
                borderWidth: borderWidth,
              ),
            ),
          if (extraCount != null && extraCount! > 0)
            Positioned(
              left: urls.length * step,
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: t.primaryGradient,
                  border: Border.all(color: Colors.white, width: borderWidth),
                ),
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Text(
                      '+$extraCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size * 0.36,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
