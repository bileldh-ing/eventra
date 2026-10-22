import 'package:eventra/features/events/domain/entities/event_category.dart';
import 'package:flutter/material.dart';

/// What the user is into. Each interest maps onto the catalogue categories
/// that the smart feed rewards.
enum Interest {
  music('Music', Icons.music_note_outlined, {EventCategory.music}),
  cinema('Cinema', Icons.movie_outlined, {EventCategory.cinema}),
  sports('Sports', Icons.sports_basketball_outlined, {EventCategory.sports}),
  social('Social', Icons.groups_outlined, {EventCategory.social}),
  art('Art', Icons.palette_outlined, {EventCategory.art}),
  tech('Tech', Icons.memory_outlined, {EventCategory.tech}),
  food('Food', Icons.restaurant_outlined, {EventCategory.food}),
  comedy('Comedy', Icons.theater_comedy_outlined, {EventCategory.comedy}),
  outdoors('Outdoors', Icons.landscape_outlined, {
    EventCategory.sports,
    EventCategory.food,
  }),
  nightlife('Nightlife', Icons.nightlife_outlined, {
    EventCategory.music,
    EventCategory.social,
  }),
  charity('Charity', Icons.volunteer_activism_outlined, {
    EventCategory.social,
  }),
  business('Business', Icons.work_outline_rounded, {EventCategory.tech});

  const Interest(this.label, this.icon, this.categories);

  final String label;
  final IconData icon;
  final Set<EventCategory> categories;

  static const minimum = 3;

  static Interest? byName(String name) {
    for (final i in values) {
      if (i.name == name) return i;
    }
    return null;
  }
}

/// Categories rewarded by a set of interests, in interest order.
List<EventCategory> categoriesFor(Iterable<Interest> interests) {
  final out = <EventCategory>[];
  for (final i in interests) {
    for (final c in i.categories) {
      if (!out.contains(c)) out.add(c);
    }
  }
  return out;
}
