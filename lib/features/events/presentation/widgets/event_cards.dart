import 'package:eventra/app/nav.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/utils/formatters.dart';
import 'package:eventra/core/widgets/avatar_stack.dart';
import 'package:eventra/core/widgets/event_image.dart';
import 'package:eventra/core/widgets/glass.dart';
import 'package:eventra/core/widgets/highlighted_text.dart';
import 'package:eventra/core/widgets/pressable.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/presentation/widgets/bookmark_button.dart';
import 'package:eventra/features/events/presentation/widgets/participants_sheet.dart';
import 'package:eventra/features/feed/presentation/quick_preview.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Large photo card used by the Upcoming Events carousel.
class EventCarouselCard extends StatelessWidget {
  const EventCarouselCard({
    required this.event,
    required this.heroTag,
    super.key,
    this.dim = 0,
    this.parallax = 0,
  });

  final Event event;
  final String heroTag;

  /// 0..1 darkening applied to off-center cards.
  final double dim;

  /// -1..1 horizontal photo shift relative to the page offset.
  final double parallax;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final radius = BorderRadius.circular(t.radii.eventCard);
    final extra = event.participantsCount - 3;
    return Semantics(
      label:
          '${event.title}, ${formatCardDate(event.startAt)}, ${event.address}',
      button: true,
      child: GestureDetector(
        key: ValueKey('card-${event.id}'),
        onTap: () => openEvent(context, event, heroTag: heroTag),
        onLongPress: () => showQuickPreview(context, event, heroTag: heroTag),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: heroTag,
                child: EventImage(
                  url: event.coverImageUrl,
                  category: event.category,
                  alignment: Alignment(parallax.clamp(-1, 1) * 0.5, 0),
                  cacheWidth: 900,
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x26000000),
                      Color(0x00000000),
                      Color(0x00000000),
                      Color(0xB3140A24),
                    ],
                    stops: [0, 0.25, 0.5, 1],
                  ),
                ),
              ),
              PositionedDirectional(
                top: 20,
                start: 20,
                end: 76,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Glass(
                    borderRadius: BorderRadius.circular(999),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.my_location_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            event.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.caption.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                top: 18,
                end: 18,
                child: BookmarkButton(eventId: event.id, size: 44),
              ),
              PositionedDirectional(
                start: 18,
                end: 16,
                bottom: 20,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FitTitle(
                            event.title,
                            style: context.text.cardTitleOnPhoto.copyWith(
                              fontSize: 20,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              GestureDetector(
                                key: ValueKey('avatars-${event.id}'),
                                onTap: () =>
                                    showParticipantsSheet(context, event),
                                child: AvatarStack(
                                  urls: event.participantAvatars
                                      .take(3)
                                      .toList(),
                                  extraCount: extra,
                                  size: 26,
                                  overlap: 0.42,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  formatCardDate(event.startAt),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.text.body.copyWith(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    ArrowButton(
                      size: 48,
                      onTap: () => openEvent(context, event, heroTag: heroTag),
                    ),
                  ],
                ),
              ),
              IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  color: Colors.black.withValues(alpha: dim * 0.35),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Glass circle with an up-right arrow that rotates 45 degrees while pressed.
class ArrowButton extends StatefulWidget {
  const ArrowButton({required this.onTap, super.key, this.size = 50});
  final VoidCallback onTap;
  final double size;

  @override
  State<ArrowButton> createState() => _ArrowButtonState();
}

class _ArrowButtonState extends State<ArrowButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.openEvent,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedRotation(
          turns: _down ? 0.125 : 0,
          duration: const Duration(milliseconds: 160),
          child: SizedBox.square(
            dimension: widget.size,
            child: Glass(
              shape: BoxShape.circle,
              fill: Colors.black.withValues(alpha: 0.18),
              child: const Center(
                child: Icon(
                  Icons.north_east_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact card for the horizontal sections below the carousel.
class CompactEventCard extends StatelessWidget {
  const CompactEventCard({
    required this.event,
    required this.heroTag,
    super.key,
    this.reason,
  });

  final Event event;
  final String heroTag;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Pressable(
      key: ValueKey('compact-$heroTag'),
      pressedScale: 0.97,
      onTap: () => openEvent(context, event, heroTag: heroTag),
      onLongPress: () => showQuickPreview(context, event, heroTag: heroTag),
      child: Container(
        width: 210,
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(t.radii.listCard),
          boxShadow: t.softShadow,
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 112,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Hero(
                      tag: heroTag,
                      child: EventImage(
                        url: event.coverImageUrl,
                        category: event.category,
                        cacheWidth: 500,
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    top: 8,
                    end: 8,
                    child: BookmarkButton(
                      eventId: event.id,
                      size: 34,
                      iconSize: 17,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 10, 8, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.cardTitle.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reason ?? formatCardDate(event.startAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.caption,
                        ),
                      ),
                      Text(
                        formatPrice(event.price),
                        style: context.text.caption.copyWith(
                          color: t.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// White list card: thumbnail, title, date, address and price.
class EventListTile extends StatelessWidget {
  const EventListTile({
    required this.event,
    required this.heroTag,
    super.key,
    this.trailing,
    this.highlight = '',
    this.onOpen,
  });

  final Event event;
  final String heroTag;
  final Widget? trailing;

  /// Search text to emphasise in the title and address.
  final String highlight;

  /// Called just before Event Details opens (e.g. to remember a search).
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Pressable(
      key: ValueKey('tile-${event.id}'),
      pressedScale: 0.98,
      onTap: () {
        onOpen?.call();
        openEvent(context, event, heroTag: heroTag);
      },
      onLongPress: () => showQuickPreview(context, event, heroTag: heroTag),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(t.radii.listCard),
          boxShadow: t.softShadow,
        ),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(t.radii.thumbnail),
                child: Hero(
                  tag: heroTag,
                  child: EventImage(
                    url: event.coverImageUrl,
                    category: event.category,
                    cacheWidth: 300,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HighlightedText(
                    event.title,
                    query: highlight,
                    style: context.text.cardTitle.copyWith(fontSize: 17),
                    highlightStyle: TextStyle(
                      color: t.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatCardDate(event.startAt),
                    style: context.text.caption,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: t.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: HighlightedText(
                          highlight.isEmpty
                              ? event.address
                              : '${event.venue}, ${event.address}',
                          query: highlight,
                          style: context.text.caption,
                          highlightStyle: TextStyle(
                            color: t.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing ??
                Text(
                  formatPrice(event.price),
                  style: context.text.cardTitle.copyWith(
                    color: t.primary,
                    fontSize: 17,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

/// Single-line title that shrinks (down to [minFontSize]) to fit its width,
/// like the mockup's card titles; wraps to two lines only when even the
/// minimum size cannot fit.
class FitTitle extends StatelessWidget {
  const FitTitle(
    this.text, {
    required this.style,
    super.key,
    this.minFontSize = 16,
  });

  final String text;
  final TextStyle style;
  final double minFontSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scaler = MediaQuery.textScalerOf(context);
        final base = DefaultTextStyle.of(context).style.merge(style);
        var size = base.fontSize ?? 20;
        while (size > minFontSize) {
          final painter = TextPainter(
            text: TextSpan(
              text: text,
              style: base.copyWith(fontSize: size),
            ),
            maxLines: 1,
            textDirection: Directionality.of(context),
            textScaler: scaler,
          )..layout();
          // A small margin: the paragraph's own line breaking can round a
          // hair wider than TextPainter's measurement.
          final fits = painter.width + 2 <= constraints.maxWidth;
          painter.dispose();
          if (fits) break;
          size -= 0.5;
        }
        final oneLine = size > minFontSize;
        return Text(
          text,
          maxLines: oneLine ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          style: base.copyWith(fontSize: oneLine ? size : minFontSize + 1),
        );
      },
    );
  }
}
