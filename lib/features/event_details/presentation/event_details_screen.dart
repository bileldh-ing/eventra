import 'dart:math' as math;

import 'package:eventra/app/nav.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/utils/formatters.dart';
import 'package:eventra/core/widgets/avatar_stack.dart';
import 'package:eventra/core/widgets/event_image.dart';
import 'package:eventra/core/widgets/glass.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/core/widgets/pressable.dart';
import 'package:eventra/core/widgets/state_views.dart';
import 'package:eventra/features/event_details/presentation/details_providers.dart';
import 'package:eventra/features/event_details/presentation/widgets/details_sections.dart';
import 'package:eventra/features/event_details/presentation/widgets/expandable_text.dart';
import 'package:eventra/features/event_details/presentation/widgets/mini_map.dart';
import 'package:eventra/features/event_details/presentation/widgets/ticket_button.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/events/presentation/widgets/bookmark_button.dart';
import 'package:eventra/features/events/presentation/widgets/event_cards.dart';
import 'package:eventra/features/events/presentation/widgets/participants_sheet.dart';
import 'package:eventra/features/events/presentation/widgets/share_event.dart';
import 'package:eventra/features/reviews/presentation/review_widgets.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EventDetailsScreen extends ConsumerWidget {
  const EventDetailsScreen({required this.eventId, super.key, this.heroTag});

  final String eventId;
  final String? heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final async = ref.watch(eventByIdProvider(eventId));
    return async.when(
      data: (event) => _DetailsView(
        event: event,
        heroTag: heroTag ?? defaultHeroTag(eventId),
      ),
      loading: () => Scaffold(
        backgroundColor: t.sheet,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: t.sheet,
        appBar: AppBar(backgroundColor: t.sheet),
        body: Center(
          child: MessageView.error(
            message: '$e',
            onRetry: () => ref.invalidate(eventByIdProvider(eventId)),
          ),
        ),
      ),
    );
  }
}

class _DetailsView extends ConsumerStatefulWidget {
  const _DetailsView({required this.event, required this.heroTag});
  final Event event;
  final String heroTag;

  @override
  ConsumerState<_DetailsView> createState() => _DetailsViewState();
}

class _DetailsViewState extends ConsumerState<_DetailsView> {
  final _scroll = ScrollController();
  final _offset = ValueNotifier<double>(0);
  bool _dismissing = false;

  static const _dismissThreshold = 120.0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() => _offset.value = _scroll.offset);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _offset.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification n) {
    // Drag down on the hero past the threshold dismisses the screen.
    if (!_dismissing &&
        n is ScrollUpdateNotification &&
        n.dragDetails != null &&
        n.metrics.pixels < -_dismissThreshold) {
      _dismissing = true;
      HapticFeedback.lightImpact();
      Navigator.of(context).maybePop();
    }
    return false;
  }

  void _openMap() =>
      context.push('${currentTabRoot(context)}/event/${widget.event.id}/map');

  void _openTickets() => context.push(
    '${currentTabRoot(context)}/event/${widget.event.id}/tickets',
  );

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final e = widget.event;
    final size = MediaQuery.sizeOf(context);
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final heroH = size.height * 0.46;
    final collapseAt = heroH - top - 90;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ValueListenableBuilder<double>(
        valueListenable: _offset,
        builder: (context, offset, child) {
          // Interactive scale-down while pulling the hero down to dismiss.
          final double pull = math.max(0, -offset);
          final scale = 1.0 - math.min(pull / 1400, 0.08);
          return Transform.scale(scale: scale, child: child);
        },
        child: Scaffold(
          backgroundColor: t.sheet,
          body: Stack(
            children: [
              // Hero photo: parallax on scroll, stretch on overscroll.
              ValueListenableBuilder<double>(
                valueListenable: _offset,
                builder: (context, offset, child) {
                  final over = math.max(0, -offset).toDouble();
                  return PositionedDirectional(
                    top: -math.max(0, offset) * 0.5,
                    start: 0,
                    end: 0,
                    height: heroH + over,
                    child: child!,
                  );
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: widget.heroTag,
                      child: EventImage(
                        url: e.coverImageUrl,
                        category: e.category,
                      ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x66000000), Color(0x00000000)],
                          stops: [0, 0.35],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              NotificationListener<ScrollNotification>(
                onNotification: _onScroll,
                child: CustomScrollView(
                  key: const ValueKey('details-scroll'),
                  controller: _scroll,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(child: SizedBox(height: heroH - 36)),
                    SliverToBoxAdapter(
                      child: _SheetEntrance(
                        child: Container(
                          decoration: BoxDecoration(
                            color: t.sheet,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(t.radii.sheet),
                            ),
                          ),
                          padding: EdgeInsetsDirectional.fromSTEB(
                            20,
                            28,
                            20,
                            120 + bottom,
                          ),
                          child: _SheetContent(
                            event: e,
                            onOpenMap: _openMap,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Top overlay: back, title, bookmark. Turns solid once the
              // sheet reaches the top and the event title fades in.
              ValueListenableBuilder<double>(
                valueListenable: _offset,
                builder: (context, offset, _) {
                  final p = ((offset - collapseAt) / 60).clamp(0.0, 1.0);
                  return _TopBar(
                    event: e,
                    progress: p,
                    top: top,
                  );
                },
              ),
              PositionedDirectional(
                start: 0,
                end: 0,
                bottom: 0,
                child: _BottomBar(
                  event: e,
                  bottomInset: bottom,
                  onTicket: _openTickets,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sheet slides up with a spring when the page opens.
class _SheetEntrance extends StatelessWidget {
  const _SheetEntrance({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutBack,
      child: child,
      builder: (context, v, child) =>
          Transform.translate(offset: Offset(0, 60 * v), child: child),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.event,
    required this.progress,
    required this.top,
  });

  final Event event;
  final double progress;
  final double top;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final solid = progress > 0.5;
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(20, top + 14, 20, 12),
      decoration: BoxDecoration(
        color: t.sheet.withValues(alpha: progress),
        boxShadow: progress > 0.9 ? t.softShadow : null,
      ),
      child: Row(
        children: [
          GlassCircleButton(
            key: const ValueKey('details-back'),
            icon: Icons.arrow_back_rounded,
            semanticLabel: context.l10n.back,
            size: 50,
            iconSize: 24,
            fill: solid ? t.primary.withValues(alpha: 0.9) : null,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: 1 - progress,
                  child: Text(
                    context.l10n.detailsTitle,
                    style: context.text.heroTitle.copyWith(fontSize: 24),
                  ),
                ),
                Opacity(
                  opacity: progress,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.cardTitle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: solid ? t.primary.withValues(alpha: 0.9) : null,
            ),
            child: BookmarkButton(eventId: event.id, size: 50, iconSize: 22),
          ),
        ],
      ),
    );
  }
}

class _SheetContent extends ConsumerWidget {
  const _SheetContent({required this.event, required this.onOpenMap});
  final Event event;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final e = event;
    final similar = (ref.watch(upcomingEventsProvider).value ?? const <Event>[])
        .where((x) => x.category == e.category && x.id != e.id)
        .take(8)
        .toList();
    final meta = context.text.body.copyWith(
      color: t.textSecondary,
      fontSize: 13.5,
      fontWeight: FontWeight.w500,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.title,
                    style: context.text.detailsTitle.copyWith(fontSize: 23),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 18,
                            color: t.textSecondary,
                          ),
                          const SizedBox(width: 5),
                          Text(formatDetailsDate(e.startAt), style: meta),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: t.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 150),
                            child: Text(
                              e.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: meta,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                formatPrice(e.price),
                key: const ValueKey('details-price'),
                style: context.text.price,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Pressable(
          key: const ValueKey('details-participants'),
          onTap: () => showParticipantsSheet(context, e),
          pressedScale: 0.98,
          child: Row(
            children: [
              AvatarStack(
                urls: e.participantAvatars.take(4).toList(),
                size: 42,
                overlap: 0.28,
                borderWidth: 0,
              ),
              const SizedBox(width: 14),
              Text(
                context.l10n.plusParticipants(
                  math.max(0, e.participantsCount - 4).toString(),
                ),
                style: context.text.body.copyWith(
                  fontSize: 18,
                  color: t.textPrimary.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
        DetailsSectionTitle(context.l10n.detailsAbout),
        ExpandableText(
          text: e.description,
          style: context.text.body.copyWith(color: t.textSecondary),
        ),
        DetailsSectionTitle(context.l10n.detailsLocation),
        MiniMapCard(event: e, onOpen: onOpenMap),
        const SizedBox(height: 8),
        Text('${e.venue}, ${e.address}', style: context.text.caption),
        DetailsSectionTitle(context.l10n.detailsOrganizer),
        OrganizerCard(organizer: e.organizer),
        if (e.lineup.isNotEmpty) ...[
          DetailsSectionTitle(context.l10n.detailsLineup),
          LineupTimeline(items: e.lineup),
        ],
        DetailsSectionTitle(context.l10n.detailsPolicy),
        PolicyCard(policy: e.policy),
        EventReviewsSection(event: e),
        if (similar.isNotEmpty) ...[
          DetailsSectionTitle(context.l10n.detailsSimilar),
          SizedBox(
            height: 196,
            child: ListView.separated(
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              itemCount: similar.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, i) => CompactEventCard(
                event: similar[i],
                heroTag: 'similar-${e.id}-${similar[i].id}',
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _BottomBar extends ConsumerWidget {
  const _BottomBar({
    required this.event,
    required this.bottomInset,
    required this.onTicket,
  });

  final Event event;
  final double bottomInset;
  final VoidCallback onTicket;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final waitlisted = ref.watch(
      waitlistProvider.select((s) => s.contains(event.id)),
    );
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(20, 14, 20, 14 + bottomInset),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: context.tokens.shadow(0.12),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: [
          Builder(
            builder: (context) => Semantics(
              button: true,
              label: context.l10n.shareEvent,
              child: Pressable(
                key: const ValueKey('details-share'),
                onTap: () => shareEvent(context, event),
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: t.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.ios_share_rounded, color: t.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: event.isSoldOut
                ? Row(
                    children: [
                      Expanded(
                        child: GradientPillButton(
                          label: context.l10n.soldOut,
                          onPressed: null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        key: const ValueKey('join-waitlist'),
                        onPressed: () {
                          final added = ref
                              .read(waitlistProvider.notifier)
                              .toggle(event.id);
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(
                                  added
                                      ? context.l10n.waitlistJoined
                                      : context.l10n.waitlistLeft,
                                ),
                              ),
                            );
                        },
                        child: Text(
                          waitlisted
                              ? context.l10n.onWaitlist
                              : context.l10n.joinWaitlist,
                          style: TextStyle(
                            color: t.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  )
                : TicketButton(onConfirmed: onTicket),
          ),
        ],
      ),
    );
  }
}
