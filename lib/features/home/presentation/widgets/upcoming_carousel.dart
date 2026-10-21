import 'package:eventra/core/widgets/skeleton.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/presentation/widgets/event_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

String carouselHeroTag(String id) => 'carousel-$id';

/// PageView carousel (viewportFraction 0.8): the centered card is full size,
/// neighbors scale to 0.9 and darken; photos shift with parallax.
class UpcomingCarousel extends StatefulWidget {
  const UpcomingCarousel({
    required this.events,
    required this.height,
    super.key,
  });

  final List<Event> events;
  final double height;

  @override
  State<UpcomingCarousel> createState() => _UpcomingCarouselState();
}

class _UpcomingCarouselState extends State<UpcomingCarousel> {
  late final PageController _controller = PageController(
    viewportFraction: 0.8,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        key: const ValueKey('upcoming-carousel'),
        controller: _controller,
        itemCount: widget.events.length,
        onPageChanged: (_) => HapticFeedback.selectionClick(),
        itemBuilder: (context, i) {
          final event = widget.events[i];
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final page =
                  _controller.hasClients && _controller.position.haveDimensions
                  ? _controller.page ?? 0
                  : 0.0;
              final delta = (i - page).clamp(-1.0, 1.0);
              final distance = delta.abs();
              return Transform.scale(
                scale: 1 - 0.1 * distance,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: EventCarouselCard(
                    event: event,
                    heroTag: carouselHeroTag(event.id),
                    dim: distance,
                    parallax: -delta,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Skeleton shimmer shown while the feed loads.
class CarouselSkeleton extends StatelessWidget {
  const CarouselSkeleton({required this.height, super.key});
  final double height;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Shimmer(
      key: const ValueKey('carousel-skeleton'),
      child: SizedBox(
        height: height,
        child: OverflowBox(
          maxWidth: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkeletonBox(
                width: w * 0.8 - 16,
                height: height * 0.9,
                radius: 32,
              ),
              const SizedBox(width: 16),
              SkeletonBox(width: w * 0.8 - 16, height: height, radius: 32),
              const SizedBox(width: 16),
              SkeletonBox(
                width: w * 0.8 - 16,
                height: height * 0.9,
                radius: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
