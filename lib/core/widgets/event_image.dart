import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventra/features/events/domain/entities/event_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ImageProviderFactory = ImageProvider<Object> Function(String url);

/// Disk-cached network images by default; tests override this to serve local
/// fixtures or to force failures.
final imageProviderFactory = Provider<ImageProviderFactory>(
  (ref) => CachedNetworkImageProvider.new,
);

/// Gradient tints per category used by the image fallback.
List<Color> categoryGradient(EventCategory? c) => switch (c) {
  EventCategory.music => const [Color(0xFFE58CFF), Color(0xFF7B3FE4)],
  EventCategory.cinema => const [Color(0xFF8DA7EE), Color(0xFF4A3FB8)],
  EventCategory.sports => const [Color(0xFF7EE0C3), Color(0xFF2F8BD8)],
  EventCategory.social => const [Color(0xFFFFB38A), Color(0xFFE5579A)],
  EventCategory.art => const [Color(0xFFFFD27A), Color(0xFFE85FA8)],
  EventCategory.tech => const [Color(0xFFA9D9F2), Color(0xFF6D5AE6)],
  EventCategory.food => const [Color(0xFFF6A15B), Color(0xFFE5484D)],
  EventCategory.comedy => const [Color(0xFFFFE08A), Color(0xFFF6A15B)],
  null => const [Color(0xFFC86CF2), Color(0xFF8DA7EE)],
};

/// Gradient placeholder with a category icon, so cards never look broken.
class ImageFallback extends StatelessWidget {
  const ImageFallback({super.key, this.category, this.iconSize = 40});
  final EventCategory? category;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey('image-fallback'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: categoryGradient(category),
        ),
      ),
      child: Center(
        child: Icon(
          category?.icon ?? Icons.event_outlined,
          size: iconSize,
          color: Colors.white.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}

/// Event photo with fade-in, decode-at-size and the gradient fallback.
class EventImage extends ConsumerWidget {
  const EventImage({
    required this.url,
    super.key,
    this.category,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.cacheWidth,
    this.semanticLabel,
  });

  final String url;
  final EventCategory? category;

  /// Read by screen readers; null marks the photo decorative (the card or
  /// tile around it already carries a label).
  final String? semanticLabel;
  final BoxFit fit;
  final Alignment alignment;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factory = ref.watch(imageProviderFactory);
    var provider = factory(url);
    if (cacheWidth != null) {
      provider = ResizeImage(
        provider,
        width: cacheWidth,
        policy: ResizeImagePolicy.fit,
      );
    }
    return Image(
      image: provider,
      fit: fit,
      alignment: alignment,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true,
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
      frameBuilder: (context, child, frame, sync) {
        if (sync || frame != null) return child;
        return ImageFallback(category: category);
      },
      errorBuilder: (context, error, stack) =>
          ImageFallback(category: category),
    );
  }
}

/// Circular avatar with white border and an initials fallback.
class NetAvatar extends ConsumerWidget {
  const NetAvatar({
    required this.url,
    super.key,
    this.size = 28,
    this.borderWidth = 2,
    this.borderColor = Colors.white,
    this.name,
  });

  final String url;
  final double size;
  final double borderWidth;
  final Color borderColor;
  final String? name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factory = ref.watch(imageProviderFactory);
    final initials = (name ?? '')
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0])
        .join();
    final fallback = DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE58CFF), Color(0xFF8DA7EE)],
        ),
      ),
      child: Center(
        child: initials.isEmpty
            ? Icon(Icons.person, color: Colors.white, size: size * 0.55)
            : Text(
                initials,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.36,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderWidth > 0
            ? Border.all(color: borderColor, width: borderWidth)
            : null,
      ),
      child: ClipOval(
        child: url.isEmpty
            ? fallback
            : Image(
                image: ResizeImage(
                  factory(url),
                  width: (size * 3).round(),
                  policy: ResizeImagePolicy.fit,
                ),
                fit: BoxFit.cover,
                width: size,
                height: size,
                frameBuilder: (context, child, frame, sync) =>
                    (sync || frame != null) ? child : fallback,
                errorBuilder: (context, error, stack) => fallback,
              ),
      ),
    );
  }
}
