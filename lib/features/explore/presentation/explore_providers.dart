import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/explore/domain/nearest.dart';
import 'package:eventra/features/home/domain/event_filter.dart';
import 'package:eventra/features/home/presentation/home_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Explore list query (the sheet's search field).
class ExploreQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  // A method (not a setter) so it can be passed as a callback.
  // ignore: use_setters_to_change_properties
  void set(String q) => state = q;
}

final exploreQueryProvider = NotifierProvider<ExploreQueryNotifier, String>(
  ExploreQueryNotifier.new,
);

/// Upcoming events sorted by distance from the user location, narrowed by
/// the query and the category/price filters (sort is always by distance).
final nearestEventsProvider = Provider<List<NearbyEvent>>((ref) {
  final origin = ref.watch(userLocationProvider).position;
  final query = ref.watch(exploreQueryProvider);
  final f = ref.watch(homeFilterProvider);
  final events = ref.watch(upcomingEventsProvider).value ?? const [];
  return nearestEvents(
    events,
    origin,
    query: query,
    // Distance is the list itself here, so the radius is not applied.
    filter: f.copyWith(maxDistanceKm: () => null, sort: EventSort.recommended),
    now: ref.watch(clockProvider)(),
  );
});
