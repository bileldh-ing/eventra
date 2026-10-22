import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/feed/presentation/feed_providers.dart';
import 'package:eventra/features/home/domain/event_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeFilterNotifier extends Notifier<EventFilter> {
  @override
  EventFilter build() => EventFilter.none;

  // A Notifier is the right home for this setter-style API.
  // ignore: use_setters_to_change_properties
  void set(EventFilter filter) => state = filter;

  void reset() => state = EventFilter.none;
}

final homeFilterProvider = NotifierProvider<HomeFilterNotifier, EventFilter>(
  HomeFilterNotifier.new,
);

/// Carousel / See All content: upcoming events through the active filter.
final filteredEventsProvider = Provider<AsyncValue<List<Event>>>((ref) {
  final filter = ref.watch(homeFilterProvider);
  final profile = ref.watch(feedProfileProvider);
  return ref
      .watch(upcomingEventsProvider)
      .whenData(
        (list) => filter.apply(list, origin: profile.origin, profile: profile),
      );
});

final homeSectionsProvider = Provider<AsyncValue<HomeSections>>((ref) {
  final profile = ref.watch(feedProfileProvider);
  return ref
      .watch(upcomingEventsProvider)
      .whenData(
        (list) => HomeSections.from(list, profile.now, profile: profile),
      );
});
