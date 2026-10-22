import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// The tab root of the current location ('/home', '/explore', ...), so pages
/// pushed from a tab stay inside that tab's navigator.
String currentTabRoot(BuildContext context) {
  final segments = GoRouterState.of(context).uri.pathSegments;
  const tabs = {'home', 'explore', 'favorites', 'tickets', 'profile'};
  final first = segments.isEmpty ? 'home' : segments.first;
  return '/${tabs.contains(first) ? first : 'home'}';
}

/// Opens Event Details with the shared-element hero tag of the source card.
void openEvent(BuildContext context, Event event, {String? heroTag}) {
  context.push(
    '${currentTabRoot(context)}/event/${event.id}',
    extra: heroTag,
  );
}

String defaultHeroTag(String eventId) => 'event-photo-$eventId';
