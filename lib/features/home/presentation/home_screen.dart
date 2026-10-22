import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/utils/geo.dart';
import 'package:eventra/core/widgets/entrance.dart';
import 'package:eventra/core/widgets/state_views.dart';
import 'package:eventra/features/auth/domain/auth_models.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/home/presentation/filters_sheet.dart';
import 'package:eventra/features/home/presentation/home_providers.dart';
import 'package:eventra/features/home/presentation/widgets/category_chips.dart';
import 'package:eventra/features/home/presentation/widgets/home_header.dart';
import 'package:eventra/features/home/presentation/widgets/home_section.dart';
import 'package:eventra/features/home/presentation/widgets/upcoming_carousel.dart';
import 'package:eventra/features/notifications/presentation/notifications_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scroll = ScrollController();
  final _parallax = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      // Very slow parallax on the faceted pattern.
      _parallax.value = (_scroll.offset * 0.15).clamp(-40, 80);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _parallax.dispose();
    super.dispose();
  }

  double _cardHeight(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    return (h - 540).clamp(300.0, 450.0);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final filter = ref.watch(homeFilterProvider);
    final feed = ref.watch(filteredEventsProvider);
    final hasUnread = ref.watch(unreadCountProvider) > 0;
    final user = ref.watch(authControllerProvider).user;
    final cardHeight = _cardHeight(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: t.background,
        body: RefreshIndicator(
          key: const ValueKey('home-refresh'),
          color: t.primary,
          edgeOffset: MediaQuery.paddingOf(context).top,
          onRefresh: () => ref.read(eventsProvider.notifier).refresh(),
          child: CustomScrollView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: ValueListenableBuilder<double>(
                  valueListenable: _parallax,
                  builder: (context, shift, _) => HomeHeader(
                    parallax: shift,
                    userName: user?.name,
                    avatarUrl: user?.email == kDemoEmail ? kDemoUserAvatar : '',
                    hasUnread: hasUnread,
                    activeFilters: filter.refinementCount,
                    onAvatar: () => StatefulNavigationShell.maybeOf(
                      context,
                    )?.goBranch(3),
                    onBell: () => context.push('/home/notifications'),
                    onSearch: () => context.push('/home/search'),
                    onFilter: () => showFiltersSheet(context),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Entrance(
                  delay: const Duration(milliseconds: 140),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: CategoryChips(
                      selected: filter.category,
                      onSelected: (c) => ref
                          .read(homeFilterProvider.notifier)
                          .set(filter.copyWith(category: () => c)),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Upcoming Events',
                  actionLabel: 'See All',
                  onAction: () => context.push('/home/all'),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: Entrance(
                  delay: const Duration(milliseconds: 220),
                  offset: 40,
                  child: AnimatedSwitcher(
                    duration: t.motion.medium,
                    switchInCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0.08, 0),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: _carousel(feed, filter.hashCode, cardHeight),
                  ),
                ),
              ),
              ..._sections(),
              const SliverToBoxAdapter(child: SizedBox(height: 130)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _carousel(AsyncValue<List<Event>> feed, int key, double height) {
    if (feed.hasValue) {
      final events = feed.requireValue;
      if (events.isEmpty) {
        return MessageView(
          key: const ValueKey('empty-view'),
          icon: Icons.event_busy_outlined,
          title: 'No events match',
          message: 'Try another category or reset your filters.',
          actionLabel: 'Show all events',
          onAction: () => ref.read(homeFilterProvider.notifier).reset(),
        );
      }
      return UpcomingCarousel(
        key: ValueKey('carousel-$key'),
        events: events,
        height: height,
      );
    }
    if (feed.hasError) {
      return MessageView.error(
        message: feed.error.toString(),
        onRetry: () => ref.read(eventsProvider.notifier).refresh(),
      );
    }
    return CarouselSkeleton(height: height);
  }

  List<Widget> _sections() {
    final sections = ref.watch(homeSectionsProvider).value;
    if (sections == null) return const [];
    final origin = ref.watch(userLocationProvider.select((l) => l.position));
    String distance(Event e) {
      final km = haversineKm(origin, LatLng(e.latitude, e.longitude));
      return '${km.toStringAsFixed(1)} km away';
    }

    return [
      SliverToBoxAdapter(
        child: HomeSection(
          id: 'trending',
          title: 'Trending This Week',
          events: sections.trending,
          reasonFor: (e) => '${e.participantsCount} going',
        ),
      ),
      SliverToBoxAdapter(
        child: HomeSection(
          id: 'music',
          title: 'Because You Like Music',
          events: sections.becauseYouLikeMusic,
          reasonFor: distance,
        ),
      ),
      SliverToBoxAdapter(
        child: HomeSection(
          id: 'free',
          title: 'Free Events',
          events: sections.free,
        ),
      ),
      SliverToBoxAdapter(
        child: HomeSection(
          id: 'weekend',
          title: 'This Weekend',
          events: sections.thisWeekend,
        ),
      ),
    ];
  }
}
